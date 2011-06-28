/**
 * flickr.js: javascript for flickr.rb plugin of tDiary
 *
 * Copyright (C) 2011 by MATSUOKA Kohei <kmachu@gmail.com>
 * You can distribute it under GPL.
 */

$(function() {
  var userId = $tDiary.plugin.flickr.userId;
  var apiKey = $tDiary.plugin.flickr.apiKey;
  var client = new flickrClient(apiKey);

  if (userId == undefined) {
    $('#flickr_photos').append('[ERROR] flickr.rb: User ID is not specified.');
  }

  $('#flickr_search').click(function() {
    $('#flickr_photo_size').show();
    $('#flickr_photos').empty();
    $('#flickr_photos').append('Loading...');
    console.log("start getPublicPhotos()");
    var searchCount = $('#flickr_search_count').val();
    var searchText = $('#flickr_search_text').val();
    if (searchText == "") {
      client.getPublicPhotos(userId, searchCount, showPhotos);
    } else {
      client.searchPhotos(userId, searchCount, searchText, showPhotos);
    }
  });

  function showPhotos(data) {
    console.log(data);
    console.log("end getPublicPhotos()");
    var target = $('#flickr_photos');
    target.empty();
    $.each(data.photos.photo, function(i, photo) {
      var src = client.photoUrl(photo, "square");
      $('<img>')
        .attr({id: photo.id, src: src, title: photo.title})
        .css({margin: "2px", border: "1px solid #999", cursor: "pointer"})
        .click(function(event) {
          var size = $('input[@name=flickr_to_blog_photo_size]:checked').val();
          var tag = $.makePluginTag("flickr '" + event.target.id + "', '" + size + "'");
          $('#body').insertAtCaret(tag);
        })
        .appendTo(target);
    });
  }

  $('#flickr_photo_size').hide();
});

/**
 * a Flickr API client for JavaScript
 */
flickrClient = function(apiKey) {
  this.baseUrl = 'http://api.flickr.com/services/rest/?';
  this.apiKey = apiKey;
}

flickrClient.prototype = {
  /**
   * return photo URL for this photo
   * @param {Object} photo
   * @param {String} size
   * @return
   */
  call: function(method, params, callback) {
    params = $.extend({
      api_key: this.apiKey,
      method: method,
      format: 'json'
    }, params);
    $.ajax({
      url: this.baseUrl + this.serialize(params),
      dataType: "jsonp",
      jsonp: "jsoncallback",
      success: function(data, textStatus) {
        if (data.stat != "ok") {
          alert("failed to call Flickr API: " + data.message);
          return;
        }
        callback(data);
      }
    });
  },

  /**
   * return photo URL for this photo
   * @param {Object} photo
   * @param {String} size
   * @return
   */
  photoUrl: function(photo, size) {
    if (typeof size == "undefined") {
      size = "small";
    }
    var url = "http://farm" + photo.farm + ".static.flickr.com/" + photo.server + "/" + photo.id + "_" + photo.secret;
    url += {
      square: "_s",
      thumbnail: "_t",
      small: "_m",
      medium: "",
      large: "_b"
    }[size];
    return url + ".jpg";
  },

  /**
   * return Flickr web URL for this photo
   * @param {Object} user
   * @param {Object} photo
   * @return
   */
  webUrl: function(user, photo) {
    return user.photosurl._content + photo.id;
  },

  /**
   * convert hash format parameter to query string
   * @param {Object} params
   * @return
   */
  serialize: function(params) {
    var query = [];
    $.each(params, function(key, val){ query.push(key + "=" + val)});
    return query.join("&");
  },

  getPublicPhotos: function(userId, perPage, callback) {
    var method = 'flickr.people.getPublicPhotos';
    var params = {
      user_id: userId,
      per_page: perPage
    };
    this.call(method, params, callback);
  },

  searchPhotos: function(userId, perPage, text, callback) {
    var method = 'flickr.photos.search';
    var params = {
      user_id: userId,
      per_page: perPage,
      text: text
    };
    this.call(method, params, callback);
  },

  findByUsername: function(username, callback) {
    var method = 'flickr.people.findByUsername';
    var params = {
      username: username
    };
    this.call(method, params, callback);
  }
// end of flickrToBlog.flickrClient
};
