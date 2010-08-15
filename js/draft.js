$(function() {

if (!localStorage) { return; }

var Draft = function(storage, text) {
  // 保存先のストレージ
  this.storage = storage;
  // 下書きの保存件数
  this.maxCount = 10;
  // 下書き一覧
  this.items = [];

  this.initialize(text);
};

Draft.prototype = {
  // ローカルストレージから下書きを読み込む
  initialize: function(text) {
    this.items = this.storage.drafts ? JSON.parse(this.storage.drafts) : new Array();
    // 下書きに空の日記・テキストエリアと同じ日記が存在すれば削除する
    this.items = jQuery.grep(this.items, function(item, index) {
      // 改行と空白文字を無視して比較（プレビュー時に末尾へ改行が付加されるため)
      if (item.value == "" || DraftUtils.trim(item.value) == DraftUtils.trim(text)) {
        return false;
      } else {
        return true;
      }
    });
    this.save(text, true);
    // console.log('Draft.initialized');
  },

  // ローカルストレージに下書きを保存する
  // append が true の場合は、下書き一覧の末尾に追加する
  // append が false の場合は、最後の下書きに上書きする
  save: function(text, append) {
    if (!append) {
      this.items.pop();
    }
    this.items.push({
      date: new Date(),
      value: text
    });
    // 最大でmaxCount件数の履歴を保持
    if (this.items.length > this.maxCount) {
      this.items.shift();
    }
    this.storage.drafts = JSON.stringify(this.items);
  },

  // 下書き一覧から index 番目の下書きを取得する
  // 取得した下書きは一覧の末尾に移動する
  load: function(index) {
    var item = this.items.splice(index, 1)[0];
    this.items.push(item);
    return item.value;
  },

  // 下書きのタイトル一覧の配列を返す（表示用）
  // タイトルは textarea の先頭1行目 + 更新日時
  titles: function() {
    return this.items.map(function(item) {
      var date = DraftUtils.dateToString(item.date);
      var title;
      if (!item.value) {
        title = "No-Name";
      } else if (item.value.indexOf("\n") == -1) {
        title = item.value;
      } else {
        title = item.value.substring(0, item.value.indexOf("\n"));
      }
      return title + " (" + date + ")";
    }, this);
  },

};

// ユーティリティ関数
var DraftUtils = {
  // 日付を yyyy-mm-dd HH:MM:SS 形式に変換する
  dateToString: function(date) {
      var d = new Date(date);
      var year = d.getFullYear();
      var month = d.getMonth() + 1;
      if (month < 10) { month = "0" + month }
      var date = d.getDate();
      if (date < 10) { date = "0" + date }
      var hour = d.getHours();
      if (hour < 10) { hour = "0" + hour }
      var min = d.getMinutes();
      if (min < 10) { min = "0" + min }
      var sec = d.getSeconds();
      if (sec < 10) { sec = "0" + sec }
      return year + "-" + month + "-" + date + " " + hour + ":" + min + ":" + sec;
  },
  // 文字列から改行と空白文字を取り除く
  trim: function(str) {
    return str.replace(/\n+/g, "").replace(/\s+/g, "");
  }
};

// ---------------------------------------
// ここからDOMの初期化処理
// ---------------------------------------

// 保存対象のテキストエリア
var textarea = $('[name=body]');
// 下書き一覧を表示するセレクトボックス
var select = $('[name=drafts]');
// 自動保存の間隔（ミリ秒）
var autoSaveInterval = 5 * 1000;

var draft = new Draft(localStorage, textarea.val());

// 下書き保存
saveDraft = function() {
  draft.save(textarea.val());
  showSelectForm(true);
}
// 下書き読み込み
loadDraft = function() {
  textarea.val(draft.load(select.val()));
  showSelectForm(false);
}
// 下書き選択用のセレクトボックスを描画
showSelectForm = function(keepIndex) {
  var index = select.val();
  select.empty();
  jQuery.each(draft.titles(), function(i, title) {
    select.append($("<option>").attr("value", i).text(title));
    select.val(i);
  });
  if (keepIndex) {
    select.val(index);
  }
}

// DOMイベント設定
$('#draft_load').click(loadDraft);
setInterval(saveDraft, autoSaveInterval);
textarea.change(saveDraft);

showSelectForm(false);
// console.log('ready');

});
