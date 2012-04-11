/*
 image_ex.js: javascript for image_ex.rb plugin of tDiary

 Copyright (C) 2012 by Shugo Maeda
 You can redistribute it and/or modify it under GPL2.
 */

var imageExMaxWidth = function () {
	function getWindowWidth() {
		if ( window.innerWidth ) {
			return window.innerWidth;
		}
		else if ( document.documentElement && document.documentElement.clientWidth != 0 ) {
			return document.documentElement.clientWidth;
		}
		else if ( document.body ) {
			return document.body.clientWidth;
		}
		return -1;
	}
	var windowWidth = getWindowWidth();
	if (windowWidth == -1) {
		retrun -1;
	}
	else {
		return windowWidth * 0.8;
	}
}();

function imageExResizeImage(id) {
	if (imageExMaxWidth == -1) {
		return;
	}

	var img = document.getElementById(id);

	if (img.width > imageExMaxWidth) {
		img.width = imageExMaxWidth;
	}
}
