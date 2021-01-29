# -*- coding: utf-8 -*-
# 祝日対応カレンダーモジュール
# Atsushi YAMAMOTO <yamamoto@graco.c.u-tokyo.ac.jp>
# Copyright (c) 2001-2007 Atsushi YAMAMOTO. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# on condition that redistributions contain above copyright notice.
# This program is provided ``AS IS'' and there are NO WARRANTY.


module Calendar

  # 定数群
  Monthname_short = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  Monthname_long = ['January','February','March','April','May','June','July','August','September','October','November','December']
  Monthname_jp_old = ['睦月','如月','弥生','卯月','皐月','水無月','文月','葉月','長月','神無月','霜月','師走']
  Monthname_jp = ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
  Day_2 = ['Su','Mo','Tu','We','Th','Fr','Sa']
  Day_3 = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
  Day_jp = ['日','月','火','水','木','金','土']
  Day_of_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  SPDAYFILE = ".specialday"

  Holidayname = {
    # とりあえず一部のみ
    '元日' => 'New Year\'s Day',
    '成人の日' => 'Coming of Age Day',
    '建国記念の日' => 'National Foundation Day',
    '春分の日' => 'Vernal Equinox',
    '天皇誕生日' => 'Emperor\'s Birthday',
    '昭和の日' => 'Showa Day',
    'みどりの日' => 'Greenery Day',
    '憲法記念日' => 'Constitution Day',
    'こどもの日' => 'Children\'s Day',
    '国民の休日' => 'Holiday for a Nation',
    '振替休日' => 'Compensatory holiday',
    '海の日' => 'Marine Day',
    '敬老の日' => 'Respect for the Aged Day',
    '秋分の日' => 'Autumnal Equinox',
    '体育の日' => 'Health and Sports Day',
    '文化の日' => 'National Culture Day',
    '勤労感謝の日' => 'Labor Thanksgiving Day'
  }

  def days_of_month(month, year)
    if month == 2 and (year%400 == 0 or year%100 != 0 and year%4 == 0)
      return 29
    else
      return Day_of_month[month-1]
    end    
  end

  def holiday_jan(day, year, wday)

    if year <= 1948
      if day == 3
	return "元始祭"
      elsif day == 5
	return "新年宴會"
      elsif year < 1913 and day == 30
	return "孝明天皇祭"
      end
    elsif year < 2000
      if day == 1
	return "元日"
      elsif day == 15
	return "成人の日"
      end
    else
      if day == 1
	return "元日"
      elsif day >= 8 and day <= 14 and wday == 1 and year > 1999
        return "成人の日"
      end
    end
    return nil
  end

  def holiday_feb(day, year, wday)
    if year <= 1948
      if day == 11
	return "紀元節"
      end
    elsif year > 1966
      if day == 11
	return "建国記念の日"
      elsif year == 1989
	if day == 24
	  return "大喪の礼"
	end
      end
    end
    return nil
  end

  def holiday_mar(day, year, wday)
    if year <= 1948
      if year >= 1900 and day == (year*0.24242 - year/4 + 35.84).to_i
	return "春季皇靈祭"
      end
    else
      if year <= 2099 and day == (year*0.24242 - year/4 + 35.84).to_i
	return "春分の日"
      end
    end
    return nil
  end

  def holiday_apr(day, year, wday)
    if year <= 1948
      if day == 3
	return "神武天皇祭"
      elsif day == 29 and year > 1926
	return "天長節"
      end
    elsif year == 1959 and day == 10
      return "明仁親王結婚の儀"
    elsif year < 1989
      if day == 29
	return "天皇誕生日"
      end
    else
      if day == 29
        if year < 2007
          return "みどりの日"
        else
          return "昭和の日"
        end
      end
    end
    return nil
  end

  def holiday_may(day, year, wday)
    if year > 1948
      if day == 3
	return "憲法記念日"
      elsif day == 5
	return "こどもの日"
      elsif year > 2006 and day == 4
        return "みどりの日"
      elsif year > 1985 and day == 4 and wday > 1
	return "国民の休日"
      end
    end
    return nil
  end

  def holiday_jun(day, year, wday)
    if day == 9 and year == 1993
      return "徳仁親王結婚の儀"
    end
  end

  def holiday_jul(day, year, wday)
    if year < 1926 and year > 1912
      if day == 30
	return "明治天皇祭"
      end
    elsif year > 1995
      if year < 2003
	return "海の日"  if day == 20
      elsif day >= 15 and day <= 21 and wday == 1
	return "海の日"
      end
    end
    return nil
  end

  def holiday_aug(day, year, wday)
    if year < 1926 and year > 1912
      if day == 31
	return "天長節"
      end
    end
  end

  def holiday_sep(day, year, wday)
    if year < 1948
      if year < 1879 and day == 17
	return "神嘗祭"
      elsif year >= 1900 and day == (year*0.24204 - year/4 + 39.01).to_i
	return "秋季皇靈祭"
      end
    else
      if year <= 2099 and day == (year*0.24204 - year/4 + 39.01).to_i
	return "秋分の日"
      elsif year > 1965
	if year < 2003
	  return "敬老の日"  if day == 15
	elsif day >= 15 and day <= 21 and wday == 1
	  return "敬老の日"
	elsif day >= 16 and day <= 22 and wday == 2 and 
	    year <= 2099 and (day+1) == (year*0.24204 - year/4 + 39.01).to_i
	  return "国民の休日"
	end
      end
    end
    return nil
  end

  def holiday_oct(day, year, wday)
    if year <= 1947
      if year >= 1879 and day == 17
	return "神嘗祭"
      elsif year < 1927 and year > 1912
	return "天長節祝日" if day == 31
      end
    elsif year > 1965
      if year < 2000
	if day == 10
	  return "体育の日"
	end
      else
	if day >= 8 and day <= 14 and wday == 1
	  return "体育の日"
	end
      end
    end
    return nil
  end

  def holiday_nov(day, year, wday)
    if year <= 1947
      if day == 23
	return "新嘗祭"
      elsif year == 1915
	return "即位ノ禮" if day == 10
	return "大嘗祭" if day == 14
	return "即位禮及大嘗祭後大饗第一日" if day == 16
      elsif year < 1912
	return "天長節" if day == 3
      elsif year > 1926
	return "明治節" if day == 3
	if year == 1928
	  return "即位ノ禮" if day == 10
	  return "大嘗祭" if day == 14
	  return "即位禮及大嘗祭後大饗第一日" if day == 16
	end
      end
    else
      if day == 3
	return "文化の日"
      elsif day == 23
	return "勤労感謝の日"
      elsif day == 12 and year == 1990
	return "即位礼正殿の儀"
      end
    end
    return nil
  end

  def holiday_dec(day, year, wday)
    if year <= 1947
      if year > 1926
	if day == 25
	  return "大正天皇祭"
	end
      end
    elsif year > 1988
      if day == 23
	return "天皇誕生日"
      end
    end
    return nil
  end

  def holiday(day, month, year, wday=-1)
    wday = what_day(year, month, day) if wday == -1
    return nil if year <= 1872 or (year == 1873 and month <= 10)
    case month
    when 1
      return holiday_jan(day, year, wday)
    when 2
      return holiday_feb(day, year, wday)
    when 3
      return holiday_mar(day, year, wday)
    when 4
      return holiday_apr(day, year, wday)
    when 5
      return holiday_may(day, year, wday)
    when 6
      return holiday_jun(day, year, wday)
    when 7
      return holiday_jul(day, year, wday)
    when 8
      return holiday_aug(day, year, wday)
    when 9
      return holiday_sep(day, year, wday)
    when 10
      return holiday_oct(day, year, wday)
    when 11
      return holiday_nov(day, year, wday)
    when 12
      return holiday_dec(day, year, wday)
    else
      raise "Month 1-12 [" + month.to_s + "]"
    end
    return nil
  end

  @@Specialdayname = {}
  @@Specialdaycolor = {}
  @@Specialdaycolor2 = {}
  def specialday(day, month, year, wday=-1)
    _specialday(day, month, year, wday)
  end

  def _specialday(day, month, year, wday=-1)
    if ENV['HOME'] and FileTest.exists?(ENV['HOME'] + "/" + SPDAYFILE)
      spfile = ENV["HOME"] + "/" + SPDAYFILE
    elsif FileTest.exists?(SPDAYFILE)
      spfile = SPDAYFILE
    end
    if spfile
      File.open(spfile, "r"){|f|
	wday = what_day(year, month, day) if wday == -1
	f.each{|s|
	  s.chomp!
#	  s.gsub!(" ", "")
	  next if /^#/ =~ s
#	  puts s.split(",\s*")
#	  puts "#{day} #{month} #{year}"
	  y, m, d, w, j, e, c = s.split(",\s*")
	  if (y == "*" or y == year.to_s) and
	      (m == "*" or m == month.to_s) and
	      (w == "*" or w == wday.to_s) and
	      (d == "*" or d == day.to_s)
	    if j and j != ""
	      @@Specialdayname[j] = e
	      @@Specialdaycolor[j] = c
	      return j
	    else
	      @@Specialdaycolor2["#{day}/#{month}/#{year}"] = c
	      return ""
	    end
	  end
	}
      }
    end
    return nil
  end

  def specialdaycolor(name)
    @@Specialdaycolor[name]
  end

  def specialdaycolor2(name)
    @@Specialdaycolor2[name]
  end

  # Zeller(ツェラー)の公式 1583年から3999年まで
  def what_day(year, month, day=1)
#    raise "year 1583-3999 [" + year.to_s + "]" if year < 1583 or year > 3999
    if month == 1 or month == 2 then
      month += 12
      year -= 1
    end
    c = (year/100).to_i  # 西暦の上二桁
    year -= 100 * c      # 西暦の下二桁
    return ((c/4).to_i - 2*c + year + (year/4).to_i + (2.6*(month + 1)).to_i + day - 1)%7 
  end

  def y2j(month, year)
  end
  
  if(FileTest.exists?("mycal.rb"))
    File::open("mycal.rb", "r"){|f|
      src = ""
      f.each{|s|
	src << s
      }
      module_eval(src)
    }
  end

end

include Calendar
class Week
  @days
  @month
  @year

  def initialize(start, num_of_days, wday, month, year, day_class=Day)
    @month, @year = month, year
    @days = []
    wday.times{|d|
      @days.push(day_class.new(nil, nil, nil, nil))
    }
    prevholiday = false # 振替休日制以来，月の最終日が祝日ではない
    wday.upto(6){|w|
      if start <= num_of_days
	@days.push(day_class.new(start, month, year, w, prevholiday))
	start += 1
      else
	@days.push(day_class.new(nil, nil, nil, nil))
      end
      prevholiday = (@days.last.holiday? and (prevholiday or w == 0))
    }
  end

  def to_s
    str = ""
    @days.each{|d|
      str << d.to_s
    }
    str << " "
    @days.each{|d|
      if d.specialday? and d.specialday_name != ""
	str << "[#{d.day}:#{d.specialday_name}]"
      end
      if d.holiday?
	str << "[#{d.day}:#{d.holiday_name}]"
      end
    }
    return str
  end

end

class Week_jp < Week
  def to_s
    str = ""
    @days.each{|d|
      str << d.to_s
    }
    str << " "
    @days.each{|d|
      if d.specialday? and d.specialday_name_jp != ""
	str << "[#{d.day}:#{d.specialday_name_jp}]"
      end
      if d.holiday?
	str << "[#{d.day}:#{d.holiday_name_jp}]"
      end
    }
    return str
  end
end

class Day
  @day
  @month
  @year
  @wday
  @isholiday
  @istoday # 起動時の「今日」
  @exchange_holiday

  def initialize(day, month, year, wday, prevholiday = false)
    @day, @month, @year, @wday = day, month, year, wday
    if !day.nil?
      @holiday_name = holiday(day, month, year, wday)
      @specialday_name = specialday(day, month, year, wday)
      @isholiday = !@holiday_name.nil?
      @isspecialday = !@specialday_name.nil?
      @istoday = (Time::now.month == month and Time::now.year == year and Time::now.day == day)
      if year > 2006
        
      end
      @exchange_holiday = (prevholiday and ((year > 2006) or
                             ((wday == 1 and (year > 1973 or (year == 1973 and month >= 3))))))
      # ruby-list:38728 thanks!
    end
  end
  
  def sunday?
    @wday == 0
  end

  def saturday?
    @wday == 6
  end

  def exchange_holiday?
    @exchange_holiday
  end

  def holiday?
    @isholiday
  end

  def today?
    @istoday
  end

  def specialday?
    @isspecialday
  end

  def holiday_name_jp
    @holiday_name
  end

  def holiday_name
    holiday_en =  Holidayname[@holiday_name]
    if holiday_en
      holiday_en
    else
      @holiday_name
    end
  end

  def specialday_name_jp
    @specialday_name
  end

  def specialday_name
    if @@Specialdayname
      specialday_en =  @@Specialdayname[@specialday_name]
      if specialday_en
	return specialday_en
      end
    end
    @specialday_name
  end

  def day
    @day
  end

  def to_s
    if @day.nil?
      return "   "
    elsif @day < 10
      return " " << @day.to_s << " "
    else
      return @day.to_s << " "
    end
  end

end


class Day_color < Day
  
  Color = {
    "Default" => "\C-[[m",
    "Black" => "\C-[[30m",
    "Red" => "\C-[[31m",
    "Green" => "\C-[[32m",
    "Brown" => "\C-[[33m",
    "Blue" => "\C-[[34m",
    "Magenta" => "\C-[[35m",
    "Cyan" => "\C-[[36m",
    "White" => "\C-[[37m",
    "Reverse" => "\C-[[7m",
    "Bold" => "\C-[[1m",
    "Underline" => "\C-[[04m"
  }

  def to_s
    str = super.to_s
    if today?
#      str = Underline + str
      str = Color["Reverse"] + str
    end
    if specialday?
      if @specialday_name != "" and Color[specialdaycolor(@specialday_name)]
	c = Color[specialdaycolor(@specialday_name)]
      elsif Color[specialdaycolor2("#{@day}/#{@month}/#{@year}")]
	c = Color[specialdaycolor2("#{@day}/#{@month}/#{@year}")]
      else
	c = Color["Cyan"]
      end
      return (Color["Reverse"] + c + str).sub(/ $/ , Color["Default"] + " ")
    elsif sunday? or holiday? or exchange_holiday?
      return (Color["Red"] + str).sub(/ $/ , Color["Default"] + " ")
    elsif @wday == 6
      return (Color["Blue"] + str).sub(/ $/ , Color["Default"] + " ")
    else
      return (Color["Bold"] + str).sub(/ $/ , Color["Default"] + " ")
    end
  end

end

class Day_long < Day
  
  def to_s
    str = super.to_s
    str.sub!(/ $/, "")
    if today?
      return "|#{str}|"
    elsif specialday?
      return "##{str}#"
    elsif sunday? or holiday? or exchange_holiday?
      return "[#{str}]"
    elsif @wday == 6
      return "<#{str}>"
    else
      return " #{str} "
    end
  end
end

class Month
  @year
  @month
  @weeks
  @header

  Opt = {"color" => Day_color, "normal" => Day, "long" => Day_long}

  def initialize(month, year, opt = "normal", weekclass = Week)
    @month, @year = month, year
    @weeks = []
    day_class = Opt[opt] or Opt["normal"]
    num_of_days = days_of_month(month, year)
    current = 1
    wday = what_day(year, month)
    while current <= num_of_days
      @weeks.push(weekclass.new(current, num_of_days, wday, month, year, day_class))
      current += 7 - wday
      wday = 0
    end
    @header = header(opt)
  end

  def to_s
    str = @header << "\n"
    @weeks.each{|w|
      str << w.to_s << "\n"
    }
    str << "\n"
    return str
  end

  def title
    name + " " + @year.to_s
  end

  def header(opt)
    if opt == "long"
      length = (27 - title.length)/2
      length = 0 if length < 0
      return (" " * length) + title + "\n" << Month.weekheader_long
    else
      length = (20 - title.length)/2
      length = 0 if length < 0
      return (" " * length) + title + "\n" << Month.weekheader
    end
  end

  def Month.weekheader
    str = ""
    Day_2.each{|w|
      str << w + " "
    }
    return str
  end

  def Month.weekheader_long
    str = " "
    Day_3.each{|w|
      str << w + " "
    }
    return str
  end

  def name
    Monthname_long[@month-1]
  end

  def name_short
    Monthname_short[@month-1]
  end

  def name_jp
    Monthname_jp[@month-1]
  end

  def name_jp_old
    Monthname_jp_old[@month-1]
  end

end

class Month_jp < Month
  
  def Month_jp.weekheader
    str = ""
    Day_jp.each{|w|
      str << w + " "
    }
    return str
  end

  def Month_jp.weekheader_long
    str = ""
    Day_jp.each{|w|
      str << " " + w + " "
    }
    return str
  end

  def title
    @year.to_s + "年 "+ name_jp
  end

  def header(opt)
    if opt == "long"
      length = (27 - title.length)/2
      length = 0 if length < 0
      return (" " * length) << title  << "\n" << Month_jp.weekheader_long
    else
      length = (20 - title.length)/2
      length = 0 if length < 0
      return (" " * length) << title  << "\n" << Month_jp.weekheader
    end
  end
end

class Month_jp_old < Month_jp

  def title
    @year.to_s + "年 "+ name_jp_old
  end

end

class Month_jp_eraname < Month_jp

  def title
   to_eraname(@year, @month) + " " +name_jp_old
  end

  def to_eraname(year, month)
    prev_y = -29
    prev_y2 = 1331
    prev_n = "垂仁"
    prev_n2 = ""
    y = 0, n = ""
    era = nil
    File.foreach("./era_name"){|l|
      if /^(\d+)(?:\/(\d+))?\s([^\|]*)$/e =~ l
	y, m, n = $1.to_i, $2.to_i, $3.chomp
	if y > year
	  era = "#{prev_n}#{year-prev_y+1}年"
	elsif y == year
	  if m == month
	    era = "#{prev_n}#{year-prev_y+1}年->#{n}元年"
	  elsif m < month
	    prev_n = n
	    era = "#{prev_n}元年"
	  else
	    era = "#{prev_n}#{year-prev_y+1}年"
	  end
	else
	  prev_y, prev_n = y, n
	  next
	end
	if prev_n == ""
	  era = "空白(西暦#{year})年"
	end
	break
      elsif /^(\d+)\s(\w+)\|(\w+)$/e =~ l
	y, n2, n = $1.to_i, $2, $3
	if y > year
	  if year == 1335
	    era = "建武2年"
	  elsif prev_n2 == ""
	    era = "#{prev_n}#{year-prev_y+1}年"
	  else
	    era = "#{prev_n2}#{year-prev_y2+1}年|#{prev_n}#{year-prev_y+1}年"
	  end
	  break
	elsif y == year
	  if y == 1334
	    era = "建武元年"
	  elsif prev_n != n
	    if prev_n2 != n2
	      era = "#{n2}元年|#{n}元年"
	    else
	      era = "#{prev_n2}#{year-prev_y2+1}年|#{n}元年"
	    end
	  else
	    era = "#{n2}元年|#{prev_n}#{year-prev_y+1}年"
	  end
	  break
	end
	if prev_n != n
	  # 北朝改元
	  prev_n, prev_y = n, y
	end
	if prev_n2 != n2
	  # 南朝改元
	  prev_n2, prev_y2 = n2, y
	end
      else
	raise "era_name file error?"
      end
    }
    if era.nil?
      era = "#{n}#{year-prev_y+1}年"
    end
    era.gsub!(/\//e, "\\1元年/")
    return era
  end

end
