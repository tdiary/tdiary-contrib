/*
 * hide_sidebar_smartphone.js
 *
 * Copyright (C) 2011 by TADA Tadashi <t@tdtds.jp>
 * You can distribute it under GPL2 or any later version.
 */

$(function(){
	if($(window).width() <= 360) {
		$('div.sidebar').hide();
		$('div.main').attr('width', '100%').attr('float', 'none');
	}
});

