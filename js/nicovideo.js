/*
 * nicovideo.js : expandable nico nico douga inline player for tDiary
 *
 * Copyright (C) 2012 by TADA Tadashi <t@tdtds.jp>
 * You can modify and/or distribute it under GPL.
 */

function nicovideoPlayer( video_id ) {
	$( "#thumbnail-" + video_id ).hide();
	$( "#player-" + video_id ).show();
	return false;
}
function nicovideoThumbnail( video_id ) {
	$( "#player-" + video_id ).hide();
	$( "#thumbnail-" + video_id ).show();
	return false;
}
