/*
 * appstore.js : embeded iTunes information
 *
 * Copyright (C) 2011 by tamoot <tamoot+tdiary@gmail.com>
 * You can distribute it under GPL.
 */

$( function() {

	function appstore_desc(text) {
		return jQuery('<span><span/>').addClass("amazon-price").text(text).append("<br>");
	};

	function appstore_detail(app_url, app_id, appstore_a) {
		var params = {
			output : 'json',
			id : app_id
		};
		
		var price = "$";
		if($('html').attr('lang') == 'ja-JP') {
			$.extend(params, {
				lang : 'ja_jp',
				country : 'JP'
			});
			price = "\\"
		};
		
		
		$.ajax({
			type : 'GET',
			url : 'http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsLookup?',
			data : params,
			dataType : 'jsonp',
			//
			// callback on error..
			//
			error : function() {
				var itunes_a = jQuery('<a>').attr({
					target : "_blank",
					href : app_url
				}).addClass("amazon-detail");

				$(appstore_a).prepend(itunes_a);
			},
			//
			// append dom
			//
			success : function(data) {
				app = data["results"][0];
				
				if(app == null) {
					appstore_a.text('Search Error: ' + app_url);
					return
				};
				$(appstore_a).addClass("amazon-detail");
				
				var appstore_spand = jQuery('<span></span>').addClass("amazon-detail");
				$(appstore_a).append(appstore_spand);

				appstore_spand.prepend(jQuery('<img />').attr({
					src : app["artworkUrl100"],
					width : 128,
					height : 128
				}).addClass("amazon-detail").addClass("left"));

				var appstore_spandd = jQuery('<span></span>');
				appstore_spandd.addClass("amazon-detail-desc");
				appstore_spand.append(appstore_spandd);

				appstore_spandd.append(jQuery('<span><span/>').addClass("amazon-title").text(app["trackCensoredName"] + " "));
				appstore_spandd.append(appstore_desc(app["version"]));
				appstore_spandd.append(appstore_desc(app["releaseDate"]));
				appstore_spandd.append(appstore_desc(app["sellerName"]));
				appstore_spandd.append(appstore_desc(price + app["price"]));
				appstore_spandd.append(appstore_desc(app["supportedDevices"].join(', ')));
				appstore_spand.append('<br style="clear: left;">');
			}
		});
	};

	function appstore(target) {
		$('.appstore', target).each( function() {
			var appstore_url = $(this).attr('href');
			var appstore_id  = $(this).attr('data-appstoreid')
			appstore_detail(appstore_url, appstore_id, this);
		});
	};

	// for AutoPagerize
	$(window).bind('AutoPagerize_DOMNodeInserted', function(event) {
		appstore(event.target);
	});
	
	// for AuthPatchWork
	// NOTE: jQuery.bind() cannot handle an event that include a dot charactor.
	// see http://todayspython.blogspot.com/2011/06/autopager-autopagerize.html
	if(window.addEventListener) {
		window.addEventListener('AutoPatchWork.DOMNodeInserted', function(event) {
			appstore(event.target);
		}, false);
	} else if(window.attachEvent) {
		window.attachEvent('onAutoPatchWork.DOMNodeInserted', function(event) {
			appstore(event.target);
		});
	};

	appstore(document);
});
