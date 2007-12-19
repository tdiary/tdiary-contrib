#
# Chinese resource of livedoor_weather plugin $Revision$
#
# Copyright (C) 2006 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.
#

#
# setting of tdiary.conf
#   @options['lwws.city_id']  : City ID where weather information is specified.
#

@lwws_rest_url = 'http://weather.livedoor.com/forecast/webservice/rest/v1'
@lwws_plugin_name = 'livedoor weather'
@lwws_label_city_id = 'City ID'
@lwws_desc_city_id = 'City ID where weather information is specified. Please select City ID from among <a href ="http://weather.livedoor.com/forecast/rss/forecastmap.xml">Point definition table(RSS)</a>'
@lwws_label_disp_item = 'View items'
@lwws_desc_disp_item = 'Please select the item to want to display.'
@lwws_icon_label = 'Icon'
@lwws_icon_desc = 'Weather information is displayed in the icon. '
@lwws_max_temp_label = 'Max Tempreture'
@lwws_min_temp_label = 'Min Tempreture'
@celsius_label = 'C'
@lwws_label_cache = 'Auto update of cache'
@lwws_desc_cache = 'Enable auto update.'
@lwws_desc_cache_time = 'Please set number of update time.'
