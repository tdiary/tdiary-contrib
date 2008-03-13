require 'Calendar.rb'
require 'date'
unless Time::new.respond_to?( :strftime_holiday_backup )   
then
 eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
  class Time
   alias strftime_holiday_backup strftime
   def strftime( format )
    holiday = ""
    day = Day.new(self.day,self.month,self.year,self.wday)
    holiday = day.holiday_name_jp if day.holiday?
    strftime_holiday_backup( format.gsub( /%K/, holiday ) )
   end
  end
 MODIFY_CLASS
end