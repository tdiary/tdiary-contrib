/*
 image_ex.js: javascript for image_ex.rb plugin of tDiary

 Copyright (C) 2012 by Shugo Maeda
 You can redistribute it and/or modify it under GPL2.
 */

$(function() {
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
		return false;
	}

	var maxSize = null;

	function getMaxSize() {
		if (maxSize != null) {
			return maxSize;
		}

		var windowSize = getWindowSize();
		if (windowSize == false) {
			maxSize = false;
		}
		else {
			maxSize = {
				width: windowSize.width * 0.8,
				height: windowSize.height * 0.8
			};
		}
		return maxSize;
	}

	function resizeImage(img) {
		var maxSize = getMaxSize();

		if (img.width > maxSize.width || img.height > maxSize.height) {
			if (img.width / maxSize.width > img.height / maxSize.height) {
				img.width = maxSize.width;
			}
			else {
				img.height = maxSize.height;
			}
		}
	}

	$(document).ready(function() {
		$("img.image-ex").bind("load", function() {
			resizeImage(this);
		});
	});

	// for when images have been cached
	$(window).bind("load", function() {
		$("img.image-ex").each(function() {
			resizeImage(this);
		});
	});
});

// vim: set ts=3 sw=3 noexpandtab :
