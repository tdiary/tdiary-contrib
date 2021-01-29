require 'holiday_japan'
require 'date'
unless Time::new.respond_to?( :strftime_holiday_backup )
then
 eval( <<-MODIFY_CLASS, TOPLEVEL_BINDING )
  class Time
   alias strftime_holiday_backup strftime
   def strftime( format )
    holiday = ""
    day = Date.new(self.year, self.month, self.day)
    holiday = HolidayJapan.name(day) if HolidayJapan.check(day)
    strftime_holiday_backup( format.gsub( /%K/, holiday ) )
   end
  end
 MODIFY_CLASS
end
