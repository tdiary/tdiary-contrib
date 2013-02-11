/**
 * referer.js: fetch referer with ajax
 *
 * Copyright (C) 2013 by MATSUOKA Kohei <kmachu@gmail.com>
 * You can distribute it under GPL.
 */

$(function() {
  $('div.main').on('click', 'button.lazy_referer', function(e) {
    var button = $(this);
    button.attr("disabled", "disabled");
    $.get(button.data('endpoint'), function (data) {
      button.after($(data));
      button.hide();
    }, 'html');
  });
});
