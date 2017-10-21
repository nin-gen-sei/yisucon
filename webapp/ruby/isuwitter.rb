require 'digest/sha1'
require 'json'
require 'net/http'

require 'sinatra/base'
require 'sinatra/json'
require 'mysql2-cs-bind'


users = {"Akifumi",
         "Akihiko",
         "Akihiro",
         "Akihisa",
         "Akihito",
         "Akimasa",
         "Akimitsu",
         "Akinobu",
         "Akinori",
         "Akio",
         "Akisada",
         "Akishige",
         "Akito",
         "Akitoshi",
         "Akitsugu",
         "Akiyoshi",
         "Akiyuki",
         "Arata",
         "Arihiro",
         "Arinaga",
         "Arinobu",
         "Aritomo",
         "Asao",
         "Asuka",
         "Atomu",
         "Atsuhiko",
         "Atsuhiro",
         "Atsuo",
         "Atsushi",
         "Atsuto",
         "Atsuya",
         "Azuma",
         "Banri",
         "Bunji",
         "Bunta",
         "Chikara",
         "Chikashi",
         "Chikayoshi",
         "Choei",
         "Choki",
         "Chuichi",
         "Dai",
         "Daichi",
         "Daigo",
         "Daiki",
         "Dairoku",
         "Daishin",
         "Daisuke",
         "Daizo",
         "Eiichi",
         "Eiichiro",
         "Eiji",
         "Eijiro",
         "Eikichi",
         "Einosuke",
         "Eishun",
         "Eisuke",
         "Eita",
         "Eizo",
         "Etsuji",
         "Fujio",
         "Fumiaki",
         "Fumihiko",
         "Fumihiro",
         "Fumio",
         "Fumito",
         "Fumiya",
         "Fusanosuke",
         "Fusazane",
         "Futoshi",
         "Fuyuki",
         "Gaku",
         "Gakuto",
         "Genichi",
         "Genichiro",
         "Genjiro",
         "Genta",
         "Gentaro",
         "Genzo",
         "Giichi",
         "Goichi",
         "Goro",
         "Hachiro",
         "Hakaru",
         "Haruaki",
         "Haruchika",
         "Haruhiko",
         "Haruhiro",
         "Haruhisa",
         "Haruki",
         "Harunobu",
         "Haruo",
         "Harutaka",
         "Haruto",
         "Haruyoshi",
         "Hatsuo",
         "Hayanari",
         "Hayato",
         "Heihachiro",
         "Heisuke",
         "Hideaki",
         "Hideharu",
         "Hidehiko",
         "Hidehito",
         "Hideji",
         "Hidekazu",
         "Hideki",
         "Hidemasa",
         "Hidemi",
         "Hidemitsu",
         "Hidenobu",
         "Hidenori",
         "Hideo",
         "Hideshi",
         "Hidetaka",
         "Hideto",
         "Hidetoshi",
         "Hidetsugu",
         "Hideyo",
         "Hideyoshi",
         "Hideyuki",
         "Hiro",
         "Hiroaki",
         "Hirofumi",
         "Hirohide",
         "Hirohisa",
         "Hiroji",
         "Hirokatsu",
         "Hirokazu",
         "Hiroki",
         "Hirokuni",
         "Hiromasa",
         "Hiromichi",
         "Hiromitsu",
         "Hiromori",
         "Hironari",
         "Hironobu",
         "Hironori",
         "Hirosada",
         "Hiroshi",
         "Hiroshige",
         "Hirotaka",
         "Hirotami",
         "Hiroto",
         "Hirotoki",
         "Hirotomo",
         "Hirotoshi",
         "Hirotsugu",
         "Hiroya",
         "Hiroyasu",
         "Hiroyoshi",
         "Hiroyuki",
         "Hisahito",
         "Hisamitsu",
         "Hisamoto",
         "Hisanobu",
         "Hisanori",
         "Hisao",
         "Hisashi",
         "Hisataka",
         "Hisateru",
         "Hisato",
         "Hisatsugu",
         "Hisaya",
         "Hisayasu",
         "Hisayoshi",
         "Hisayuki",
         "Hitoshi",
         "Hokuto",
         "Hozumi",
         "Ichiei",
         "Ichiro",
         "Ichizo",
         "Iehisa",
         "Iemasa",
         "Iemon",
         "Iesada",
         "Ikki",
         "Ikko",
         "Ikuo",
         "Ikuro",
         "Ippei",
         "Isami",
         "Isamu",
         "Isao",
         "Issei",
         "Itaru",
         "Iwao",
         "Jiichiro",
         "Jin",
         "Jinichi",
         "Jinpachi",
         "Jiro",
         "Joichiro",
         "Joji",
         "Jokichi",
         "Jotaro",
         "Jubei",
         "Jukichi",
         "Junichi",
         "Junichiro",
         "Junji",
         "Junki",
         "Junpei",
         "Junya",
         "Junzo",
         "Jushiro",
         "Jutaro",
         "Juzo",
         "Kagemori",
         "Kagenori",
         "Kagetaka",
         "Kaichi",
         "Kaii",
         "Kaiji",
         "Kaito",
         "Kakichi",
         "Kaku",
         "Kakuji",
         "Kanehira",
         "Kanehiro",
         "Kanematsu",
         "Kanemoto",
         "Kanesuke",
         "Kanetake",
         "Kaneto",
         "Kanetsugu",
         "Kaneyoshi",
         "Kanichi",
         "Kankuro",
         "Kansuke",
         "Katsuaki",
         "Katsuei",
         "Katsuhiko",
         "Katsuhiro",
         "Katsuhisa",
         "Katsuhito",
         "Katsuji",
         "Katsuki",
         "Katsukiyo",
         "Katsumasa",
         "Katsumoto",
         "Katsunaga",
         "Katsunari",
         "Katsunori",
         "Katsunosuke",
         "Katsuo",
         "Katsushi",
         "Katsusuke",
         "Katsutaro",
         "Katsuteru",
         "Katsutomo",
         "Katsutoshi",
         "Katsuya",
         "Katsuyoshi",
         "Katsuyuki",
         "Kazuaki",
         "Kazuharu",
         "Kazuhiko",
         "Kazuhiro",
         "Kazuhisa",
         "Kazuhito",
         "Kazuki",
         "Kazuma",
         "Kazumasa",
         "Kazunari",
         "Kazunori",
         "Kazuo",
         "Kazuoki",
         "Kazuro",
         "Kazushi",
         "Kazushige",
         "Kazutaka",
         "Kazuto",
         "Kazutoki",
         "Kazutoshi",
         "Kazuya",
         "Kazuyoshi",
         "Kazuyuki",
         "Keigo",
         "Keiichi",
         "Keiichiro",
         "Keiji",
         "Keijiro",
         "Keiju",
         "Keiki",
         "Keinosuke",
         "Keishi",
         "Keisuke",
         "Keita",
         "Keizo",
         "Ken",
         "Kenichi",
         "Kengo",
         "Kenichiro",
         "Kenji",
         "Kenjiro",
         "Kenki",
         "Kenkichi",
         "Kensaku",
         "Kenshin",
         "Kensuke",
         "Kenta",
         "Kentaro",
         "Kento",
         "Kenyu",
         "Kenzo",
         "Kesao",
         "Kihachi",
         "Kihachiro",
         "Kihei",
         "Kiichiro",
         "Kikuo",
         "Kimio",
         "Kimiya",
         "Kinichi",
         "Kinichiro",
         "Kinji",
         "Kinjiro",
         "Kintaro",
         "Kinya",
         "Kisaburo",
         "Kisho",
         "Kiyoaki",
         "Kiyofumi",
         "Kiyohide",
         "Kiyohiko",
         "Kiyohiro",
         "Kiyoji",
         "Kiyokazu",
         "Kiyomoto",
         "Kiyonari",
         "Kiyonori",
         "Kiyoshi",
         "Kiyosue",
         "Kiyotaka",
         "Kiyotake",
         "Kiyoyuki",
         "Kogoro",
         "Kohei",
         "Koichi",
         "Koichiro",
         "Koji",
         "Kojiro",
         "Koki",
         "Kokichi",
         "Konosuke",
         "Kosaku",
         "Kosei",
         "Koshiro",
         "Koson",
         "Kosuke",
         "Kotaro",
         "Kouta",
         "Koya",
         "Kozo",
         "Kumataro",
         "Kuniaki",
         "Kunihiko",
         "Kunihiro",
         "Kunihisa",
         "Kunimasa",
         "Kunimitsu",
         "Kunio",
         "Kunitake",
         "Kuniyuki",
         "Kuranosuke",
         "Kusuo",
         "Kyohei",
         "Kyoichi",
         "Kyoji",
         "Kyosuke",
         "Kyukichi",
         "Mahiro",
         "Makio",
         "Mamoru",
         "Manabu",
         "Manjiro",
         "Mantaro",
         "Mareo",
         "Masaaki",
         "Masabumi",
         "Masachika",
         "Masafumi",
         "Masaharu",
         "Masahide",
         "Masahiko",
         "Masahiro",
         "Masahisa",
         "Masahito",
         "Masaichi",
         "Masaie",
         "Masaji",
         "Masakage",
         "Masakatsu",
         "Masakazu",
         "Masaki",
         "Masakuni",
         "Masamichi",
         "Masamitsu",
         "Masamori",
         "Masamune",
         "Masamura",
         "Masanao",
         "Masanobu",
         "Masanori",
         "Masao",
         "Masaomi",
         "Masaru",
         "Masashi",
         "Masashige",
         "Masataka",
         "Masatake",
         "Masatane",
         "Masateru",
         "Masato",
         "Masatomo",
         "Masatoshi",
         "Masatsugu",
         "Masaya",
         "Masayoshi",
         "Masayuki",
         "Masazumi",
         "Masuo",
         "Masuzo",
         "Matabei",
         "Matsuchi",
         "Matsuki",
         "Matsuo",
         "Matsushige",
         "Michiaki",
         "Michiharu",
         "Michihiko",
         "Michihiro",
         "Michihisa",
         "Michinori",
         "Michio",
         "Michiro",
         "Michitaka",
         "Michitaro",
         "Michiya",
         "Michiyoshi",
         "Mikio",
         "Mikuni",
         "Mineichi",
         "Mineo",
         "Mitsuaki",
         "Mitsugi",
         "Mitsugu",
         "Mitsuharu",
         "Mitsuhide",
         "Mitsuhiko",
         "Mitsuhira",
         "Mitsuhiro",
         "Mitsuhisa",
         "Mitsumasa",
         "Mitsumori",
         "Mitsunobu",
         "Mitsunori",
         "Mitsuo",
         "Mitsuomi",
         "Mitsusuke",
         "Mitsutaka",
         "Mitsuteru",
         "Mitsutoshi",
         "Mitsuyasu",
         "Mitsuyo",
         "Mitsuyoshi",
         "Mitsuyuki",
         "Mochiaki",
         "Mokichi",
         "Morihiko",
         "Morihiro",
         "Morikazu",
         "Morimasa",
         "Morio",
         "Moritaka",
         "Mosuke",
         "Motoaki",
         "Motoharu",
         "Motohiko",
         "Motohiro",
         "Motoichi",
         "Motojiro",
         "Motoki",
         "Motomu",
         "Motonobu",
         "Motoshi",
         "Motoshige",
         "Motosuke",
         "Mototada",
         "Mototsugu",
         "Motoyasu",
         "Motoyuki",
         "Motozane",
         "Mukuro",
         "Munehiro",
         "Munemori",
         "Munenobu",
         "Munenori",
         "Muneo",
         "Muneshige",
         "Munetaka",
         "Munetoki",
         "Munetoshi",
         "Murashige",
         "Mutsuo",
         "Nagaharu",
         "Nagahide",
         "Nagamasa",
         "Nagamichi",
         "Naganao",
         "Naganori",
         "Nagatoki",
         "Nagatomo",
         "Namio",
         "Nankichi",
         "Naofumi",
         "Naohiko",
         "Naohiro",
         "Naohisa",
         "Naohito",
         "Naoji",
         "Naokatsu",
         "Naoki",
         "Naomasa",
         "Naomichi",
         "Naomori",
         "Naoshi",
         "Naotaka",
         "Naotake",
         "Naoto",
         "Naoya",
         "Naoyuki",
         "Naozumi",
         "Nariaki",
         "Nariakira",
         "Naritaka",
         "Nariyasu",
         "Nariyuki",
         "Naruhisa",
         "Naruhito",
         "Noboru",
         "Nobuaki",
         "Nobuatsu",
         "Nobuharu",
         "Nobuhiko",
         "Nobuhiro",
         "Nobuhisa",
         "Nobuhito",
         "Nobukatsu",
         "Nobukazu",
         "Nobumasa",
         "Nobumitsu",
         "Nobumoto",
         "Nobunao",
         "Nobunari",
         "Nobuo",
         "Nobusada",
         "Nobusuke",
         "Nobutaka",
         "Nobuteru",
         "Nobutoki",
         "Nobutomo",
         "Nobutoshi",
         "Nobutsuna",
         "Nobuyasu",
         "Nobuyoshi",
         "Nobuyuki",
         "Noriaki",
         "Norifumi",
         "Norifusa",
         "Norihiko",
         "Norihiro",
         "Norihito",
         "Norikazu",
         "Norimasa",
         "Norio",
         "Noriyasu",
         "Noriyoshi",
         "Noriyuki",
         "Nozomu",
         "Okimoto",
         "Okitsugu",
         "Osamu",
         "Otohiko",
         "Raizo",
         "Reiichi",
         "Reiji",
         "Reizo",
         "Rentaro",
         "Riichi",
         "Rikichi",
         "Rikiya",
         "Rinsho",
         "Ritsuo",
         "Rokuro",
         "Ryohei",
         "Ryoichi",
         "Ryoji",
         "Ryoma",
         "Ryosei",
         "Ryosuke",
         "Ryota",
         "Ryotaro",
         "Ryozo",
         "Ryu",
         "Ryuhei",
         "Ryuichi",
         "Ryuji",
         "Ryuki",
         "Ryunosuke",
         "Ryusaku",
         "Ryusei",
         "Ryusuke",
         "Ryuta",
         "Ryutaro",
         "Ryuya",
         "Ryuzo",
         "Saburo",
         "Sachio",
         "Sadaaki",
         "Sadaharu",
         "Sadahiko",
         "Sadao",
         "Sadatoshi",
         "Sadayoshi",
         "Sadazane",
         "Saiichi",
         "Sakichi",
         "Sanji",
         "Satonari",
         "Satoru",
         "Satoshi",
         "Satsuo",
         "Seigen",
         "Seigo",
         "Seiho",
         "Seiichi",
         "Seiichiro",
         "Seiji",
         "Seijin",
         "Seijiro",
         "Seiki",
         "Seikichi",
         "Seishi",
         "Seishiro",
         "Seiya",
         "Seizo",
         "Senkichi",
         "Shichiro",
         "Shigeaki",
         "Shigefumi",
         "Shigeharu",
         "Shigehiro",
         "Shigehisa",
         "Shigekazu",
         "Shigeki",
         "Shigemasa",
         "Shigematsu",
         "Shigemi",
         "Shigemitsu",
         "Shigenaga",
         "Shigenobu",
         "Shigenori",
         "Shigeo",
         "Shigeru",
         "Shigetada",
         "Shigetaka",
         "Shigeto",
         "Shigetoshi",
         "Shigeyasu",
         "Shigeyoshi",
         "Shigeyuki",
         "Shiko",
         "Shin",
         "Shingo",
         "Shinichi",
         "Shinichiro",
         "Shinji",
         "Shinjiro",
         "Shinjo",
         "Shinkichi",
         "Shinpei",
         "Shinsaku",
         "Shinsuke",
         "Shinta",
         "Shintaro",
         "Shinya",
         "Shinzo",
         "Shiryu",
         "Shizuo",
         "Sho",
         "Shogo",
         "Shohei",
         "Shoichi",
         "Shoji",
         "Shojiro",
         "Shoma",
         "Shosuke",
         "Shota",
         "Shotaro",
         "Shoya",
         "Shozo",
         "Shugo",
         "Shuhei",
         "Shuichi",
         "Shuji",
         "Shuko",
         "Shun",
         "Shunichi",
         "Shunichiro",
         "Shunji",
         "Shunkichi",
         "Shunnosuke",
         "Shunpei",
         "Shunsaku",
         "Shunsuke",
         "Shuntaro",
         "Shunya",
         "Shunzo",
         "Shusaku",
         "Shusuke",
         "Shuta",
         "Shuzo",
         "Sogen",
         "Soichi",
         "Soichiro",
         "Soji",
         "Sonosuke",
         "Sosuke",
         "Sotaro",
         "Suehiro",
         "Suguru",
         "Sukehiro",
         "Sukemasa",
         "Suketoshi",
         "Suketsugu",
         "Sumio",
         "Sumiyoshi",
         "Sunao",
         "Susumu",
         "Tadaaki",
         "Tadachika",
         "Tadafumi",
         "Tadaharu",
         "Tadahiko",
         "Tadahiro",
         "Tadahito",
         "Tadakatsu",
         "Tadamasa",
         "Tadami",
         "Tadamori",
         "Tadanaga",
         "Tadanao",
         "Tadanari",
         "Tadanobu",
         "Tadanori",
         "Tadao",
         "Tadaoki",
         "Tadashi",
         "Tadataka",
         "Tadateru",
         "Tadatomo",
         "Tadatoshi",
         "Tadatsugu",
         "Tadatsune",
         "Tadayo",
         "Tadayoshi",
         "Tadayuki",
         "Taichi",
         "Taichiro",
         "Taiga",
         "Taiichi",
         "Taiji",
         "Taiki",
         "Taishi",
         "Taisuke",
         "Taizo",
         "Takaaki",
         "Takafumi",
         "Takahide",
         "Takahiko",
         "Takahiro",
         "Takahisa",
         "Takahito",
         "Takaki",
         "Takamasa",
         "Takamitsu",
         "Takamori",
         "Takanobu",
         "Takanori",
         "Takao",
         "Takashi",
         "Takato",
         "Takatomi",
         "Takatoshi",
         "Takatsugu",
         "Takauji",
         "Takaya",
         "Takayasu",
         "Takayoshi",
         "Takayuki",
         "Takeaki",
         "Takefumi",
         "Takeharu",
         "Takehiko",
         "Takehiro",
         "Takehisa",
         "Takehito",
         "Takeichi",
         "Takejiro",
         "Takenaga",
         "Takenori",
         "Takeo",
         "Takeru",
         "Takeshi",
         "Taketo",
         "Taketora",
         "Taketoshi",
         "Takeya",
         "Takeyoshi",
         "Takezo",
         "Taku",
         "Takuji",
         "Takuma",
         "Takumi",
         "Takuo",
         "Takuro",
         "Takuto",
         "Takuya",
         "Takuzo",
         "Tamio",
         "Tamotsu",
         "Taro",
         "Tateo",
         "Tatsuaki",
         "Tatsuhiko",
         "Tatsuhiro",
         "Tatsuhito",
         "Tatsuji",
         "Tatsuma",
         "Tatsumi",
         "Tatsunori",
         "Tatsuo",
         "Tatsuro",
         "Tatsushi",
         "Tatsuya",
         "Tatsuyoshi",
         "Tatsuyuki",
         "Teiji",
         "Teijiro",
         "Teiko",
         "Teizo",
         "Teppei",
         "Teruaki",
         "Teruhiko",
         "Teruhisa",
         "Terumasa",
         "Terunobu",
         "Teruo",
         "Teruyoshi",
         "Teruyuki",
         "Tetsu",
         "Tetsuharu",
         "Tetsuji",
         "Tetsumasa",
         "Tetsuo",
         "Tetsuro",
         "Tetsushi",
         "Tetsutaro",
         "Tetsuya",
         "Tetsuzo",
         "Togo",
         "Tokihiko",
         "Tokio",
         "Tokuji",
         "Tokujiro",
         "Tokuo",
         "Tokuro",
         "Tokutaro",
         "Tomio",
         "Tomoaki",
         "Tomochika",
         "Tomoharu",
         "Tomohide",
         "Tomohiko",
         "Tomohiro",
         "Tomohisa",
         "Tomohito",
         "Tomoji",
         "Tomokazu",
         "Tomoki",
         "Tomomichi",
         "Tomonobu",
         "Tomonori",
         "Tomotaka",
         "Tomoya",
         "Tomoyasu",
         "Tomoyoshi",
         "Tomoyuki",
         "Torahiko",
         "Toru",
         "Toshi",
         "Toshiaki",
         "Toshiharu",
         "Toshihide",
         "Toshihiko",
         "Toshihiro",
         "Toshihisa",
         "Toshihito",
         "Toshikatsu",
         "Toshikazu",
         "Toshiki",
         "Toshimasa",
         "Toshimi",
         "Toshimichi",
         "Toshimitsu",
         "Toshinaga",
         "Toshinari",
         "Toshinobu",
         "Toshinori",
         "Toshio",
         "Toshiro",
         "Toshitada",
         "Toshitaka",
         "Toshitsugu",
         "Toshiya",
         "Toshiyasu",
         "Toshiyuki",
         "Toshizo",
         "Toyoaki",
         "Toyohiko",
         "Toyokazu",
         "Toyomatsu",
         "Toyoshige",
         "Toyozo",
         "Tsugio",
         "Tsuneharu",
         "Tsunehisa",
         "Tsunejiro",
         "Tsunemi",
         "Tsunenori",
         "Tsuneo",
         "Tsuneyoshi",
         "Tsuneyuki",
         "Tsutomu",
         "Tsuyoshi",
         "Umanosuke",
         "Umeji",
         "Wataru",
         "Yahiko",
         "Yahiro",
         "Yanosuke",
         "Yashiro",
         "Yasuaki",
         "Yasufumi",
         "Yasuharu",
         "Yasuhide",
         "Yasuhiko",
         "Yasuhiro",
         "Yasuhisa",
         "Yasuji",
         "Yasujiro",
         "Yasukazu",
         "Yasuki",
         "Yasumasa",
         "Yasumi",
         "Yasumichi",
         "Yasunari",
         "Yasunobu",
         "Yasunori",
         "Yasuo",
         "Yasuro",
         "Yasushi",
         "Yasutaka",
         "Yasutake",
         "Yasutomo",
         "Yasutoshi",
         "Yasuyoshi",
         "Yasuyuki",
         "Yataro",
         "Yohei",
         "Yoichi",
         "Yoichiro",
         "Yoji",
         "Yojiro",
         "Yorimitsu",
         "Yorinobu",
         "Yorishige",
         "Yoritaka",
         "Yoritsugu",
         "Yoritsune",
         "Yoriyuki",
         "Yoshi",
         "Yoshifumi",
         "Yoshihide",
         "Yosuke",
         "Yukihiro",
         "Yusuke"}

user_ids = {}

module Isuwitter
  class WebApp < Sinatra::Base
    use Rack::Session::Cookie, key: 'isu_session', secret: 'kioicho'
    set :public_folder, File.expand_path('../../public', __FILE__)

    PERPAGE = 50
    ISUTOMO_ENDPOINT = 'http://localhost:8081'

    users.each_with_index {|v,i|
      user_ids[v] = i
    }

    helpers do
      def db
        Thread.current[:isuwitter_db] ||= Mysql2::Client.new(
          host: ENV['YJ_ISUCON_DB_HOST'] || 'localhost',
          port: ENV['YJ_ISUCON_DB_PORT'] ? ENV['YJ_ISUCON_DB_PORT'].to_i : 3306,
          username: ENV['YJ_ISUCON_DB_USER'] || 'root',
          password: ENV['YJ_ISUCON_DB_PASSWORD'],
          database: ENV['YJ_ISUCON_DB_NAME'] || 'isuwitter',
          reconnect: true,
        )
      end

      def get_all_tweets until_time
        if until_time
          db.xquery(%| SELECT * FROM tweets WHERE created_at < ? ORDER BY created_at DESC |, until_time)
        else
          db.query(%| SELECT * FROM tweets ORDER BY created_at DESC |)
        end
      end

      def get_user_id name
        return nil if name.nil?
        return user_ids[name]
      end

      def get_user_name id
        return nil if id.nil?
        return users[id]
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
      get_all_tweets(params[:until]).each do |row|
        row['html'] = htmlify row['text']
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

      db.xquery(%|
        INSERT INTO tweets (user_id, text, created_at) VALUES (?, ?, NOW())
      |, session[:userId], text)

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
      get_all_tweets(params[:until]).each do |row|
        row['html'] = htmlify row['text']
        row['time'] = row['created_at'].strftime '%F %T'
        friends_name[row['user_id']] ||= get_user_name row['user_id']
        row['name'] = friends_name[row['user_id']]
        @tweets.push row if row['text'].include? @query
        break if @tweets.length == PERPAGE
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
          SELECT * FROM tweets WHERE user_id = ? AND created_at < ? ORDER BY created_at DESC
        |, user_id, params[:until])
      else
        rows = db.xquery(%|
          SELECT * FROM tweets WHERE user_id = ? ORDER BY created_at DESC
        |, user_id)
      end

      @tweets = []
      rows.each do |row|
        row['html'] = htmlify row['text']
        row['time'] = row['created_at'].strftime '%F %T'
        row['name'] = @user
        @tweets.push row
        break if @tweets.length == PERPAGE
      end

      if params[:append]
        erb :_tweets, layout: false
      else
        erb :user, layout: :layout
      end
    end

  end
end
