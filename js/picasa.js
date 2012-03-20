/*
 picasa.js: javascript for picasa.rb plugin of tDiary
 
 Copyright (C) 2011 by hb <smallstyle@gmail.com>
 You can redistribute it and/or modify it under GPL2.
 */
$(function () {
	var CanvasLoadingImage = function (rgb) {
			this.canvas = null;
			this.ctx = null;
			this.width = 200;
			this.height = 32;
			this.rgb = rgb || '0, 0, 0';
			this.initialize();
		}

	CanvasLoadingImage.prototype = {
		initialize: function () {
			this.canvas = $('<canvas>', {
				text: 'loading...'
			}).attr({
				'width': this.width,
				'height': this.height
			});
			if (this.canvas.get(0).getContext) {
				this.ctx = this.canvas.get(0).getContext('2d');
			}
		},

		draw: function (idx) {
			var ctx = this.ctx;
			ctx.clearRect(0, 0, this.width, this.height);
			for (i = 0; i < 10; i++) {
				ctx.fillStyle = i > idx ? 'rgba(' + this.rgb + ', 0.25)' : 'rgb(' + this.rgb + ')';
				ctx.fillRect(i * (this.width / 10), 0, (this.width / 10) - 4, this.height);
			}
			return idx < 10 ? idx + 1 : 0;
		},

		start: function () {
			var self = this;
			var idx = 0;
			this.timer = setInterval(function () {
				idx = self.draw(idx);
			}, 100)
		},

		stop: function () {
			clearInterval(this.timer);
		}
	}
	
	var PicasaService = function (userId, imgMax) {
			this.userId = userId;
			this.imgMax = imgMax || 400;
			this.has_more_photos = false;
			this.has_more_albums = false;
			this.recently_uploaded_photo_start_index = 1;
			this.album_start_index = 1;
		};

	PicasaService.prototype = {
		setRecentlyUploadedPhotoStartIndex: function(index) {
			this.recently_uploaded_photo_start_index = index;
		},

		setAlbumStartIndex: function(index) {
			this.album_start_index = 1;
		},
		
		hasMorePhotos: function () {
			return this.has_more_photos;
		},

		hasMoreAlbums: function() {
			return this.has_more_albums;
		},

		getAlbums: function (fn) {
			var timerId = this.setErrorHandler();
			var self = this;
			$.ajax({
				url: 'http://picasaweb.google.com/data/feed/api/user/' + this.userId,
				data: 'alt=json-in-script&max-results=25&thumbsize=128c&start-index=' + this.album_start_index,
				dataType: 'jsonp',
				success: function (data) {
					clearTimeout(timerId);
					self.album_start_index += 25;
					if (self.album_start_index < data.feed.openSearch$totalResults.$t) {
						self.has_more_albums = true;
					} else {
						self.has_more_albums = false;
					}
					fn(data.feed.entry);
				}
			});
		},

		getPhotos: function (albumId, fn) {
			var timerId = this.setErrorHandler();
			$.ajax({
				url: 'http://picasaweb.google.com/data/feed/api/user/' + this.userId + '/albumid/' + albumId,
				data: 'alt=json-in-script&imgmax=' + this.imgMax + '&thumbsize=200',
				dataType: 'jsonp',
				success: function (data) {
					clearTimeout(timerId);
					fn(data.feed.entry);
				}
			});
		},
		
		getPhotosRecentlyUploaded: function (fn) {
			var timerId = this.setErrorHandler();
			var self = this;
			$.ajax({
				url: 'http://picasaweb.google.com/data/feed/api/user/' + this.userId,
				data: 'alt=json-in-script&imgmax=' + this.imgMax + '&thumbsize=200&kind=photo&max-results=25&start-index=' + this.recently_uploaded_photo_start_index,
				dataType: 'jsonp',
				success: function (data) {
					clearTimeout(timerId);
					self.recently_uploaded_photo_start_index += 25;
					if (self.recently_uploaded_photo_start_index < data.feed.openSearch$totalResults.$t) {
						self.has_more_photos = true;
					} else {
						self.has_more_photos = false;
					}
					fn(data.feed.entry);
				}
			});
		},

		setErrorHandler: function () {
			var timerId = setTimeout(function () {
				clearTimeout(timerId);
				$('#plugin_picasa canvas').hide();
				$('#plugin_picasa').append(
				$('<span>', {
					text: 'Picasa Web Serviceの呼び出しに失敗しました'
				}).css('color', 'red'));
			}, 10000);
			return timerId;
		}
	};
	
	$('<input>')
		.attr({
			id: 'plugin_picasa_recent',
			type: 'button',
			value: 'Picasaから写真を取得する'
		})
		.css({
			'margin-left': '5px'
		})
		.appendTo('#plugin_picasa');

	var showPhoto = function(photo) {
		$('<img>')
			.click(function () {
				$('#body').insertAtCaret($.makePluginTag('picasa', [photo.content.src, $.trim(photo.summary.$t)]));
			})
			.attr({
				src: photo.media$group.media$thumbnail[0].url,
				title: $.trim(photo.summary.$t),
				alt: $.trim(photo.summary.$t)
			})
			.css({
				'cursor': 'pointer',
				'margin': '5px',
				'border': 'solid 1px #aaa'
			})
			.appendTo('#photos');
	};

	var showAlbum = function (album) {
				$('<li>').attr('title', album.title.$t + 'の写真一覧を表示する').css({
					'cursor': 'pointer',
					'list-style': 'none',
					'float': 'left',
					'width': '128px',
					'height': '128px',
					'background-image': 'url(' + album.media$group.media$thumbnail[0].url + ')',
					'margin': '5px',
					'border': 'solid 1px #aaaaaa',
					'overflow': 'hidden'
				}).click(function () {
					$('h3.plugin_picasa span')
						.css('cursor', 'pointer')
						.attr('title', 'アルバム一覧を表示する')
						.unbind('click')
						.click(function () {
							$('h3.plugin_picasa span.title').remove();
							$('.photo').remove();
							$('.album').show();
						});
					$('<span>', {
						text: ' > ' + album.title.$t
					}).addClass('title').appendTo('h3.plugin_picasa');
					$('<div>').css({
						'overflow': 'auto',
						'height': '300px'
					}).attr('id', 'photos').addClass('photo').appendTo('#plugin_picasa');
					$('.album').hide();
					$(loading.canvas).show();
					loading.start();
					service.getPhotos(album.gphoto$id.$t, function (photos) {
						$(loading.canvas).hide();
						loading.stop();
						$.each(photos, function (j, photo) {
							showPhoto(photo);
						});
					});
				}).append(
				$('<span>', {
					text: album.title.$t
				}).css({
					'display': 'block',
					'text-align': 'center',
					'color': '#fff',
					'background-color': 'rgba(0, 0, 0, 0.5)'
				})).appendTo('#albums');
	};

	var service = new PicasaService($tDiary.plugin.picasa.userId, $tDiary.plugin.picasa.imgMax);
	var loading = new CanvasLoadingImage();
	
	var showRecentlyPhotos = function() {
		$('h3.plugin_picasa span').unbind();
		service.setRecentlyUploadedPhotoStartIndex(1);
		loading.start();
		$(loading.canvas).show();
		service.getPhotosRecentlyUploaded(function (photos) {
			$(loading.canvas).hide();
			loading.stop();
			$('h3.plugin_picasa span')
				.css('cursor', 'pointer')
				.attr('title', 'アルバム一覧を表示する')
				.click(function() {
					$(this).unbind('click');
					service.setAlbumStartIndex(1);
					$('h3.plugin_picasa span.title').remove();
					$('#albums').remove();
					$('.photo').remove();
					$('<ul>').css({
						'overflow': 'auto',
						'height': '300px'
					}).attr('id', 'albums').addClass('album')
					.scroll(function(){
					if (($(this).height() + $(this).scrollTop()) > ($(this).get(0).scrollHeight - 250)) {
						if (!service.active && service.hasMoreAlbums()) {
							service.active = true;
							service.getAlbums(function(next_albums) {
								service.active = false;
								$.each(next_albums, function(m, next_album) {
									showAlbum(next_album);
								});
							});
						}
					}
					})
					.appendTo('#plugin_picasa');
				
					$(loading.canvas).show();
					loading.start();
					service.getAlbums(function (albums) {
						$(loading.canvas).hide();
						loading.stop();
						$.each(albums, function(l, album) {
							showAlbum(album)
						});
						$('<input>')
							.attr({
								'type': 'button',
								'value': '最近アップロードした写真の一覧を表示する'
							})
							.insertAfter('#plugin_picasa')
							.click(function(){
								$(this).remove();
								$('h3.plugin_picasa span.title').remove();
								$('#albums').remove();
								$('.photo').remove();
								showRecentlyPhotos();
							});
					});
				});
			$('<span>', {
				text: ' > Recently uploaded photos'
			}).addClass('title').appendTo('h3.plugin_picasa');
			$('<div>')
				.css({
					'overflow': 'auto',
					'height': '300px'
				})
				.attr('id', 'photos')
				.addClass('photo')
				.appendTo('#plugin_picasa')
				.scroll(function(){
					if (($(this).height() + $(this).scrollTop()) > ($(this).get(0).scrollHeight - 400)) {
						if (!service.active && service.hasMorePhotos()) {
							service.active = true;
							service.getPhotosRecentlyUploaded(function(next_photos) {
								service.active = false;
								$.each(next_photos, function(j, next_photo) {
									showPhoto(next_photo);
								});
							});
						}
					}
				});
			$.each(photos, function(i, photo){
				showPhoto(photo);
			});
		});
	};

	$('#plugin_picasa_recent').click(function(){
		$('#plugin_picasa')
			.css('height', '300px')
			.empty();
		$(loading.canvas).appendTo($('#plugin_picasa'));
		showRecentlyPhotos();
	});
});
