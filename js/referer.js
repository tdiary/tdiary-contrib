/**
 * referer.js: fetch referer with ajax
 *
 * Copyright (C) 2013 by MATSUOKA Kohei <kmachu@gmail.com>
 * You can distribute it under GPL.
 */

$(function() {
  var button = $('.lazy_referer');
  var endpoint = button.data('endpoint');

  button.click(function() {
    button.attr("disabled", "disabled");
    $.ajax({
      type: 'GET',
      dataType: "html",
      url: endpoint,
      success: function(data) {
        button.after($(data));
        button.hide();
      }
    });
  });
});
