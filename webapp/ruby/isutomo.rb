require 'sinatra/base'
require 'sinatra/json'
require 'mysql2-cs-bind'
require 'json'
require 'rack-lineprof'
require_relative './const_users'

module Isutomo
  class WebApp < Sinatra::Base
    use Rack::Lineprof, profile: 'isutomo.rb'
    set :environment, ENV["RACK_ENV"] == "deployment"? :production : ENV["RACK_ENV"].to_sym


    helpers do
      def db
        Thread.current[:isutomo_db] ||= Mysql2::Client.new(
          host: ENV['YJ_ISUCON_DB_HOST'] || 'localhost',
          port: ENV['YJ_ISUCON_DB_PORT'] ? ENV['YJ_ISUCON_DB_PORT'].to_i : 3306,
          username: ENV['YJ_ISUCON_DB_USER'] || 'root',
          password: ENV['YJ_ISUCON_DB_PASSWORD'],
          database: ENV['YJ_ISUCON_DB_NAME'] || 'isutomo',
          reconnect: true,
        )
      end

      def get_user_id name
        return nil if name.nil?
        return user_ids[name]
      end

      def get_user_name id
        return nil if id.nil?
        return users[id]
      end

      def get_friends user
        user_id = get_user_id(user)
        friends = db.xquery(%| SELECT * FROM friend WHERE me = ? |, user_id).all
        return nil unless friends
      end


      def get_friends_concat user
        user_id = get_user_id(user)
        friends = db.xquery(%| SELECT GROUP_CONCAT(fname separator ',') FROM friend WHERE me = ? |, user_id).first
        return nil unless friends
      end

      def set_friend user, friend
        user_id = get_user_id(user)
        db.xquery(%|
          INSERT into friends(me,fname) VALUE(?,?)
        |, user_id,friend)
      end

      def rm_friend user, friend
        user_id = get_user_id(user)
        fid = get_user_id(user)
        db.xquery(%|
          DELETE from friends WHERE me = ? and fid = ?
        |, user_id,fid)
      end

      def find_friend user, friend
        user_id = get_user_id(user)
        fid = get_user_id(friend)
        f = db.xquery(%|
           SELECT TOP (1) * FROM friends WHERE me = ? and fid = ?
        |, user_id, fid)
        return f ? True : False
      end

      def exist_friend user
        user_id = get_user_id(user)
        f = db.xquery(%|
           SELECT TOP (1) * FROM friends WHERE me = ? and fid = ?
        |, user_id)
        return f ? True : False
      end

    end

    get '/initialize' do
      ok = system("mysql -u root -D isutomo < #{Dir.pwd}/../sql/seed_isutomo.sql")
      halt 500, 'error' unless ok
      res = { result: 'OK' }
      json res
    end

    get '/:me' do
      me = params[:me]
      friends = get_friends_concat(me)
      halt 500, 'error' unless friends

      res = { friends: friends }
      json res
    end

    post '/:me' do
      me = params[:me]
      new_friend = params[:user]
      halt 500, 'error' unless exist_friend me

      if find_friend me, new_friend
        halt 500, new_friend + ' is already your friends.'
      end

      set_friend me, new_friend
      res = { friends: get_friends_concat me }
      json res
    end

    delete '/:me' do
      me = params[:me]
      del_friend = params[:user]
      unless find_friend me, del_friend
        halt 500, del_friend + ' is not your friends.'
      end

      rm_friend user, del_friend
      res = { friends: get_friends_concat me }
      json res
    end
  end
end
