#
# Japanese resource of livedoor_weather plugin $Revision$
#
# Copyright (C) 2006 SHIBATA Hiroshi <h-sbt@nifty.com>
# You can redistribute it and/or modify it under GPL2.
#

#
# tdiary.confにおける設定:
#   @options['lwws.city_id']  : 天気情報を取得したい都市のIDを指定(設定画面から編集可能)
#

@lwws_rest_url = 'http://weather.livedoor.com/forecast/webservice/rest/v1'
@lwws_plugin_name = 'livedoor 天気情報'
@lwws_label_city_id = '都市IDの設定'
@lwws_desc_city_id = '天気情報を取得する都市IDを指定します。<a href ="http://weather.livedoor.com/forecast/rss/forecastmap.xml">全国の地点定義表（RSS）</a>内の「1次細分区（cityタグ）」のidから選択してください。(初期設定は東京)'
@lwws_label_disp_item = '表示項目の設定'
@lwws_desc_disp_item = '表示させたい項目を選択してください。'
@lwws_icon_label = 'アイコン表示の設定'
@lwws_icon_desc = '天気情報をアイコン表示にする(詳細へのリンクは画像に設定)'
@lwws_max_temp_label = '最高気温'
@lwws_min_temp_label = '最低気温'
@celsius_label = '℃'
@lwws_label_cache = 'キャッシュの自動更新'
@lwws_desc_cache = '自動更新を有効にする。'
@lwws_desc_cache_time = 'キャッシュの更新間隔を時間で指定します。(初期設定は6時間)'
