# encoding: utf-8
require 'digest/sha1'
require 'json'
require 'net/http'
#require 'rack-lineprof'

require 'sinatra/base'
require 'sinatra/json'
require 'mysql2-cs-bind'

require_relative './const_users.rb'

module Isuwitter
  class WebApp < Sinatra::Base
    use Rack::Session::Cookie, key: 'isu_session', secret: 'kioicho'
    #use Rack::Lineprof, profile: 'isuwitter.rb'
    set :environment, ENV["RACK_ENV"] == "deployment"? :production : ENV["RACK_ENV"].to_sym

    PERPAGE = 50
    ISUTOMO_ENDPOINT = 'http://localhost:8081'

    USERS = const_users
    USER_IDS = {}
    USERS.each_with_index { |v,i| USER_IDS[v] = i }

    helpers do
      def db
        Thread.current[:isuwitter_db] ||= Mysql2::Client.new(
          host: ENV['YJ_ISUCON_DB_HOST'] || 'localhost',
          port: ENV['YJ_ISUCON_DB_PORT'] ? ENV['YJ_ISUCON_DB_PORT'].to_i : 3306,
          username: ENV['YJ_ISUCON_DB_USER'] || 'root',
          password: ENV['YJ_ISUCON_DB_PASSWORD'] || 'Superpoe1234!',
          database: ENV['YJ_ISUCON_DB_NAME'] || 'isuwitter',
          reconnect: true,
        )
      end

      def get_all_tweets(until_time, limit, query=nil)
        if until_time
          if query
            db.xquery(%| SELECT * FROM tweets WHERE created_at < ? AND text LIKE ? ORDER BY id DESC LIMIT #{limit} |, until_time, "%#{query}%")
          else
            db.xquery(%| SELECT * FROM tweets WHERE created_at < ? ORDER BY id DESC LIMIT #{limit} |, until_time)
          end
        else
          if query
            db.xquery(%| SELECT * FROM tweets WHERE text LIKE ? ORDER BY id DESC LIMIT #{limit} |, "%#{query}%")
          else
            db.query(%| SELECT * FROM tweets ORDER BY id DESC LIMIT #{limit} |)
          end
        end
      end

      def get_user_id name
        return nil if name.nil?
        return USER_IDS[name]
      end

      def get_user_name id
        return nil if id.nil?
        return USERS[id]
      end

      def htmlify text
        text ||= ''
        text
          .gsub('&', '&amp;')
          .gsub('<', '&lt;')
          .gsub('>', '&gt;')
          .gsub('\'', '&apos;')
          .gsub('"', '&quot;')
          .gsub(/#(\S+)(\s|$)/, '<a class="hashtag" href="/hashtag/\1">#\1</a>\2')
      end
    end

    get '/' do
      @name = get_user_name session[:userId]
      if @name.nil?
        @flush = session[:flush]
        session.clear
        return erb :index, layout: :layout
      end

      url = URI.parse "#{ISUTOMO_ENDPOINT}/#{@name}"
      req = Net::HTTP::Get.new url.path
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request req
      end
      friends = JSON.parse(res.body)['friends']

      friends_name = {}
      @tweets = []
      get_all_tweets(params[:until], 114514).each do |row|
        row['html'] = row['text']
        row['time'] = row['created_at'].strftime '%F %T'
        friends_name[row['user_id']] ||= get_user_name row['user_id']
        row['name'] = friends_name[row['user_id']]
        @tweets.push row if friends.include? row['name']
        break if @tweets.length == PERPAGE
      end

      if params[:append]
        erb :_tweets, layout: false
      else

        erb :index, layout: :layout
      end
    end

    post '/' do
      name = get_user_name session[:userId]
      text = params[:text]
      if name.nil? || text == ''
        redirect '/'
      end

      if text.length > 128
        redirect '/abort'
      end



      db.xquery(%|
        INSERT INTO tweets (user_id, text, created_at) VALUES (?, ?, NOW())
      |, session[:userId], htmlify(text))

      redirect '/'
    end

    get '/initialize' do
      db.query(%| DELETE FROM tweets WHERE id > 100000 |)
      db.query(%| DELETE FROM users WHERE id > 1000 |)
      url = URI.parse "#{ISUTOMO_ENDPOINT}/initialize"
      req = Net::HTTP::Get.new url.path
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request req
      end
      halt 500, 'error' if res.code != '200'

      res = { result: 'OK' }
      json res
    end

    post '/login' do
      name = params[:name]
      password = params[:password]

      user = db.xquery(%| SELECT * FROM users WHERE name = ? |, name).first
      unless user
        halt 404, 'not found'
      end

      sha1digest = Digest::SHA1.hexdigest(user['salt'] + password)
      if user['password'] != sha1digest
        session[:flush] = 'ログインエラー'
        redirect '/'
      end

      session[:userId] = user['id']
      redirect '/'
    end

    post '/logout' do
      session.clear
      redirect '/'
    end

    post '/follow' do
      name = get_user_name session[:userId]
      if name.nil?
        redirect '/'
      end

      user = params[:user]
      url = URI.parse "#{ISUTOMO_ENDPOINT}/#{name}"
      req = Net::HTTP::Post.new url.path
      req.set_form_data({'user' => user}, ';')
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request req
      end
      halt 500, 'error' if res.code != '200'

      redirect "/#{user}"
    end

    post '/unfollow' do
      name = get_user_name session[:userId]
      if name.nil?
        redirect '/'
      end

      user = params[:user]
      url = URI.parse "#{ISUTOMO_ENDPOINT}/#{name}"
      req = Net::HTTP::Delete.new url.path
      req.set_form_data({'user' => user}, ';')
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request req
      end
      halt 500, 'error' if res.code != '200'

      redirect "/#{user}"
    end

    def search session, params
      @name = get_user_name session[:userId]
      @query = params[:q]
      @query = "##{params[:tag]}" if params[:tag]

      friends_name = {}
      @tweets = []
      get_all_tweets(params[:until], PERPAGE, @query).each do |row|
        row['html'] = row['text']
        row['time'] = row['created_at'].strftime '%F %T'
        friends_name[row['user_id']] ||= get_user_name row['user_id']
        row['name'] = friends_name[row['user_id']]
        @tweets.push row
      end

      if params[:append]
        erb :_tweets, layout: false
      else
        erb :search, layout: :layout
      end
    end

    get '/hashtag/:tag' do
      search session, params
    end

    get '/search' do
      search session, params
    end

    get '/:user' do
      @name = get_user_name session[:userId]
      @user = params[:user]
      @mypage = @name == @user

      user_id = get_user_id @user
      halt 404, 'not found' if user_id.nil?

      @is_friend = false
      if @name
        url = URI.parse "#{ISUTOMO_ENDPOINT}/#{@name}"
        req = Net::HTTP::Get.new url.path
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request req
        end
        friends = JSON.parse(res.body)['friends']
        @is_friend = friends.include? @user
      end

      if params[:until]
        rows = db.xquery(%|
          SELECT * FROM tweets WHERE user_id = ? AND created_at < ? ORDER BY id DESC LIMIT #{PERPAGE}
        |, user_id, params[:until])
      else
        rows = db.xquery(%|
          SELECT * FROM tweets WHERE user_id = ? ORDER BY id DESC LIMIT #{PERPAGE}
        |, user_id)
      end

      @tweets = []
      rows.each do |row|
        row['html'] = row['text']
        row['time'] = row['created_at'].strftime '%F %T'
        row['name'] = @user
        @tweets.push row
      end

      if params[:append]
        erb :_tweets, layout: false
      else
        erb :user, layout: :layout
      end
    end

  end
end
