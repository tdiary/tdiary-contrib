/*
 * preview.js: view preview automatically
 *
 * Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
 * Distributed under the GPL2 or any later version.
 */
$(function() {

var previewButton = $('input[name*="preview"]');

$tDiary.plugin.preview.reload = function() {
  previewButton.prop("disabled", true);
  $.post(
    'update.rb',
    $('form.update').serialize() + "&appendpreview=1",
    function(data) {
      $('div.autopagerize_page_element').replaceWith(
        $(data).find('div.autopagerize_page_element')
      );
      $('div.day')
        .css('flex', "1 1 " + $tDiary.plugin.preview.minWidth / 2 + "px");
      setTimeout($tDiary.plugin.preview.reload,
        $tDiary.plugin.preview.interval * 1000);
    },
    'html'
  )
  .always(function() {
    previewButton.prop("disabled", false);
  });
}

if ($('div.autopagerize_page_element').length == 0) {
  $('div.update').before(
    '<div class="day autopagerize_page_element">'
  );
}

$('<div class="preview-container"></div>')
  .css('display', 'flex')
  .css('flex-flow', 'row-reverse wrap')
  .insertAfter('h1')
  .append($('div.day'));
$('div.day')
  .css('flex', "1 1 " + $tDiary.plugin.preview.minWidth / 2 + "px");

// プレビューボタンを押した時もajaxで更新するよう設定
previewButton.click(
  function(event) {
    event.preventDefault();
    $tDiary.plugin.preview.reload();
  }
);

$tDiary.plugin.preview.reload();

});
