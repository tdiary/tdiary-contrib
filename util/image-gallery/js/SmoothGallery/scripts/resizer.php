<?php
/* ----------------------------------------------------------------
Script coming with JonDesign's SmoothGallery (http://smoothgallery.jondesign.net).

It is an adapted version of
http://sneak.co.nz/2006/10/27/dynamic-image-resizing/
which is itself an improvement of the original script from
Timothy Crowe's 'veryraw' website, with caching additions added by Trent Davies:
http://veryraw.com/history/2005/03/image-resizing-with-php/

Thanks to:
Tim Novinger for finding the image extension problem (fixed by an strtolower())
---------------------------------------------------------------- */

$max_height = 1000;
$max_width = 2000;
if (isset($_GET["imgfile"]))
{
	if (function_exists(get_magic_quotes_gpc) && get_magic_quotes_gpc())
	{
	    $image = stripslashes( $_GET["imgfile"] );
	} else  $image = $_GET["imgfile"];
	if (isset($_GET["max_width"])) { if($_GET["max_width"] < 2000) $max_width = $_GET["max_width"]; }
	if (isset($_GET["max_height"])) { if($_GET["max_height"] < 1000) $max_height = $_GET["max_height"]; }
	
	if (strrchr($image, '/')) {
		$filename = substr(strrchr($image, '/'), 1); // remove folder references
	} else {
		$filename = $image;
	}
	
	$size = getimagesize($image);
	$width = $size[0];
	$height = $size[1];
	
	// get the ratio needed
	$x_ratio = $max_width / $width;
	$y_ratio = $max_height / $height;
	
	// if image already meets criteria, load current values in
	// if not, use ratios to load new size info
	if (($width <= $max_width) && ($height <= $max_height) ) {
		$tn_width = $width;
		$tn_height = $height;
	} else if (($x_ratio * $height) < $max_height) {
		$tn_height = ceil($x_ratio * $height);
		$tn_width = $max_width;
	} else {
		$tn_width = ceil($y_ratio * $width);
		$tn_height = $max_height;
	}
	
	/* Caching additions by Trent Davies */
	// first check cache
	// cache must be world-readable
	$resized = 'cache/'.$tn_width.'x'.$tn_height.'-'.$filename;
	$imageModified = @filemtime($image);
	$thumbModified = @filemtime($resized);
	
	header("Content-type: image/jpeg");
	
	// if thumbnail is newer than image then output cached thumbnail and exit
	if($imageModified<$thumbModified) {
		header("Last-Modified: ".gmdate("D, d M Y H:i:s",$thumbModified)." GMT");
		readfile($resized);
		exit;
	}
	
	// read image
	$ext = strtolower(substr(strrchr($image, '.'), 1)); // get the file extension
	switch ($ext) { 
		case 'jpg':     // jpg
			$src = imagecreatefromjpeg($image) or notfound();
			break;
		case 'png':     // png
			$src = imagecreatefrompng($image) or notfound();
			break;
		case 'gif':     // gif
			$src = imagecreatefromgif($image) or notfound();
			break;
		default:
			notfound();
	}
	
	// set up canvas
	$dst = imagecreatetruecolor($tn_width,$tn_height);
	
	imageantialias ($dst, true);
	
	// copy resized image to new canvas
	imagecopyresampled ($dst, $src, 0, 0, 0, 0, $tn_width, $tn_height, $width, $height);
	
	/* Sharpening adddition by Mike Harding */
	// sharpen the image (only available in PHP5.1)
	/*if (function_exists("imageconvolution")) {
		$matrix = array(    array( -1, -1, -1 ),
	                    array( -1, 32, -1 ),
	                    array( -1, -1, -1 ) );
		$divisor = 24;
		$offset = 0;
	
		imageconvolution($dst, $matrix, $divisor, $offset);
	}*/
	
	// send the header and new image
	imagejpeg($dst, null, 90);
	imagejpeg($dst, $resized, 90); // write the thumbnail to cache as well...
	
	// clear out the resources
	imagedestroy($src);
	imagedestroy($dst);
}
?>