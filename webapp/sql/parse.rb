require_relative './../ruby/const_users'

USERS = const_users
USER_IDS = {}

USERS.each_with_index { |v,i|
  USER_IDS[v] = i
}

def noise_del(str)
  str = ""
  str.each { |i|

  }
end

def changeIns(ins)
  ary = ins.split(",")
  me = noise_del ary[1]
  

end


File.open("seed_isutomo.sql"){ |f|
  f.each_line{|line|
    ary = line.split(' ')
    if ary[0] == "INSERT"


      print ary[0]+" "+ary[1]+" "+ary[2]+" "+ary[3]+" "
    else
      print line
    end

  }
}