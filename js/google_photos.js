$(function() {
  var developerKey = $tDiary.plugin.google_photos.api_key;
  var clientId = $tDiary.plugin.google_photos.client_id;
  var oauthToken;

  if (!developerKey || !clientId) {
    $('#google_photos').after($('<p>設定画面でAPIキーとクライアントIDを登録してください</p>'));
    return false;
  }

  gapi.load('auth',
    { callback: function() { console.debug('load auth function') } });
  gapi.load('picker',
    { callback: function() { console.debug('load picker function') } });

  $('#google_photos').click(function() {
    if (oauthToken) {
      createPicker();
    } else {
      authentication();
    }
  });

  function authentication() {
    window.gapi.auth.authorize(
    {
      'client_id': clientId,
      'scope': ['https://www.googleapis.com/auth/photos'],
      'immediate': false
    },
    function(authResult) {
      if (!authResult || authResult.error) {
        console.error('[google_photos] authentication faild');
        return false;
      }
      oauthToken = authResult.access_token;
      createPicker();
    });
  }

  function createPicker() {
    var picker = new google.picker.PickerBuilder()
      .addView(new google.picker.PhotosView()
        .setType(google.picker.PhotosView.Type.UPLOADED))
      .addView(google.picker.ViewId.PHOTOS)
      .addView(google.picker.ViewId.PHOTO_UPLOAD)
      .setOAuthToken(oauthToken)
      .setDeveloperKey(developerKey)
      .setLocale('ja')
      .setCallback(pickerCallback)
      .build();
    picker.setVisible(true);
  }

  function pickerCallback(data) {
    if (data[google.picker.Response.ACTION] == google.picker.Action.PICKED) {
      var doc = data[google.picker.Response.DOCUMENTS][0];
      var image = doc.thumbnails[doc.thumbnails.length - 1];
      var tag = $.makePluginTag("google_photos '" + image.url + "', '" + image.width + "', '" + image.height + "'");
      $('#body').insertAtCaret(tag);
    }
  }
});
