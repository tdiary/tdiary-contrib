/*
 image_ex.js: javascript for image_ex.rb plugin of tDiary

 Copyright (C) 2012 by Shugo Maeda
 You can redistribute it and/or modify it under GPL2.
 */

var imageExMaxSize = function () {
	function getWindowSize() {
		if (window.innerWidth) {
			return {
				width: window.innerWidth,
				height: window.innerHeight
			};
		}
		else if (document.documentElement &&
				  	document.documentElement.clientWidth != 0 ) {
			return {
				width: document.documentElement.clientWidth,
				height: document.documentElement.clientHeight
			};
		}
		else if ( document.body ) {
			return {
				width: document.body.clientWidth,
				height: document.body.clientHeight
			}
		}
		return null;
	}
	var windowSize = getWindowSize();
	if (windowSize == null) {
		return null;
	}
	else {
		return {
			width: windowSize.width * 0.8,
			height: windowSize.height * 0.8
		};
	}
}();

function imageExResizeImage(id) {
	if (imageExMaxSize == null) {
		return;
	}

	var img = document.getElementById(id);

	if (img.width > imageExMaxSize.width ||
		img.height > imageExMaxSize.height) {
		if (img.width / imageExMaxSize.width >
			 img.height / imageExMaxSize.height) {
			img.width = imageExMaxSize.width;
		}
		else {
			img.height = imageExMaxSize.height;
		}
	}
}
