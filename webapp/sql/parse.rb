require_relative './../ruby/const_users'

USERS = const_users
USER_IDS = {}

USERS.each_with_index { |v,i|
  USER_IDS[v] = i
}

ALP = "abcdefghijklmnopqrstuvwxyz"

def noise_del(str)
  s = ""
  str.each_char { |v|
    if ALP.include? v
      s += v
    end
  }
  return s
end

def changeIns(ins)
  ary = ins.split("),(")
  ary.each { |v|
    printIns v
  }
end

def printIns(ins)
  ary = ins.split(",")
  me = noise_del ary[1]
  me_id = USER_IDS[me]
  if me_id == nil
    return
  end
  ary.each_with_index { |v,i|
    if i > 1
      fname = noise_del v
      fid = USER_IDS[fname]
      if fid == nil
        return
      end
      print (sprintf("INSERT INTO `friends` VALUES (%d,%d,'%s');\n",
             me_id,fid,fname))
    end
  }
end

File.open("seed_isutomo.sql"){ |f|
  f.each_line{|line|
    ary = line.split(' ')
    if ary[0] == "INSERT"
      changeIns ary[4]
      #print ary[0]+" "+ary[1]+" "+ary[2]+" "+ary[3]+" "
    else
      print line
    end

  }
}