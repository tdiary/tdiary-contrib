/**
 * referer.js: fetch referer with ajax
 *
 * Copyright (C) 2013 by MATSUOKA Kohei <kmachu@gmail.com>
 * You can distribute it under GPL.
 */

$(function() {
  
  function lazy_referer(target) {
    $('.lazy_referer', target).each(function () {
      var button = $(this);
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
  }

  // for AutoPagerize
  $(window).bind('AutoPagerize_DOMNodeInserted', function(event) {
    lazy_referer(event.target);
  });
  
  // for AuthPatchWork
  // NOTE: jQuery.bind() cannot handle an event that include a dot charactor.
  // see http://todayspython.blogspot.com/2011/06/autopager-autopagerize.html
  if(window.addEventListener) {
    window.addEventListener('AutoPatchWork.DOMNodeInserted', function(event) {
      lazy_referer(event.target);
    }, false);
  } else if(window.attachEvent) {
    window.attachEvent('onAutoPatchWork.DOMNodeInserted', function(event) {
      lazy_referer(event.target);
    });
  };

  lazy_referer(document);
});
