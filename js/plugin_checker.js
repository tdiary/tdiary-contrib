/**
 * plugin_checker.js - Notify plugin updates
 *
 * Copyright (C) 2012 by MATSUOKA Kohei <kmachu@gmail.com>
 * You can distribute it under GPL.
 */

$(function() {
  var url = 'http://tdiary-plugin-checker.herokuapp.com/t_diary_plugin_files.json';

  function saveCheckedDate(date) {
    if (!localStorage) { return; }
    var pluginChecker = localStorage.pluginChecker ? JSON.parse(localStorage.pluginChecker) : {};
    pluginChecker.checkedDate = date;
    localStorage.pluginChecker = JSON.stringify(pluginChecker);
  }

  function loadCheckedDate() {
    if (!localStorage || !localStorage.pluginChecker) {
      return null;
    }
    return (JSON.parse(localStorage.pluginChecker)).checkedDate;
  }

  function createNotify(plugins) {
    var ul = $('<ul>');
    $.each(plugins, function(i, plugin) {
      var path = $('<a>')
        .attr('href', 'https://github.com/tdiary/tdiary-contrib/tree/master/' + plugin.path)
        .append(plugin.path);
      var message = $('<a>')
        .attr('href', 'https://github.com/tdiary/tdiary-contrib/commit/' + plugin.commit.sha)
        .append(plugin.commit.message);
      ul.append(
        $('<li>')
          .append(path).append(': ').append(message)
      );
    });
    var close = $('<div style="float: right">')
      .append(
        $('<button style="padding: 0.5em">閉じる</button>')
          .click(function() {
            saveCheckedDate(plugins[0].commit.date);
            notify.hide();
          })
      );
    var notify = $('<div class="plugin_checker">プラグインの更新が見つかりました。</div>')
      .append(close)
      .append(ul);

    return notify;
  }

  $.get(url, function(plugins) {
    var now = new Date();
    var checkedDate = loadCheckedDate();
    var updates = $.grep(plugins, function(plugin) {
      // TODO: 条件を追加する（使用中プラグイン）
      if (checkedDate) {
        return (checkedDate < plugin.commit.date);
      } else {
        var age = parseInt((now - new Date(plugin.commit.date)) / 1000 / 3600 / 24);
        return (age < 7);
      }
    });
    if (updates.length > 0) {
      $('form.update').before(createNotify(updates));
    }
    $tDiary.updates = updates;
  });
});
