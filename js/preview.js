/*
 * preview.js: view preview automatically
 *
 * Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
 * Distributed under the GPL2 or any later version.
 */
$(function() {

var previewButton = $('input[name="appendpreview"]');

$tDiary.plugin.preview = function() {
  previewButton.prop("disabled", true);
  $.post(
    'update.rb',
    $('form.update').serialize() + "&appendpreview=1",
    function(data) {
      var beforeOffset = $('div.update').offset();
      $('div.autopagerize_page_element').replaceWith(
        $(data).find('div.autopagerize_page_element')
      )
      var afterOffset = $('div.update').offset();
      // 自動更新時にスクロール位置を自動調整してみたがカクカクする
      // window.scrollTo($(window).scrollLeft(),
      //   $(window).scrollTop() + afterOffset.top - beforeOffset.top);
      previewButton.prop("disabled", false);
    },
    'html'
  );
}

if ($('div.autopagerize_page_element').length == 0) {
  $('div.update').before(
    $('<div class="autopagerize_page_element"></div>')
  );
}

// プレビューボタンを押した時もajaxで更新するよう設定
previewButton.click(
  function(event) {
    event.preventDefault();
    $tDiary.plugin.preview();
  }
);

setInterval($tDiary.plugin.preview, 10000);

});
