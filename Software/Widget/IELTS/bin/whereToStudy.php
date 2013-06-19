<?php
// This is to output javascript code for blog insertion, allowing for parameters to be passed
//
if (isset($_GET['widgetdatabackgroundcolor'])) {$color = $_GET['widgetdatabackgroundcolor'];} else {$color = '#FFFFFF';}
if (isset($_GET['widgetdatawidth'])) {$dataWidth = $_GET['widgetdatawidth'];} else {$dataWidth = '160';}
if (isset($_GET['widgetdataheight'])) {$dataHeight = $_GET['widgetdataheight'];} else {$dataHeight = '300';}
if (isset($_GET['widgetdatalanguage'])) {$dataLanguage = $_GET['widgetdatalanguage'];} else {$dataLanguage = 'EN';}
if (isset($_GET['widgetdatacountry'])) {$dataCountry = $_GET['widgetdatacountry'];} else {$dataCountry = 'none';}
if (isset($_GET['widgetdatabclogo'])) {$dataBCLogo = $_GET['widgetdatabclogo'];} else {$dataBCLogo = 'false';}
if ($dataWidth>220) {
	$swfWidth='240';
	$dataWidth = 240;
} elseif ($dataWidth<180) {
	$swfWidth='160';
	$dataWidth = 160;
} else {
	$swfWidth='200';
	$dataWidth = 200;
}
// What page is the widget embedded on?
// it is dangerous to send the whole referrer as you might get confused with parameters (specifically content)
$referrer = '';
if (isset($_SERVER['HTTP_REFERER'])) {
	if (strpos($_SERVER['HTTP_REFERER'],'?')) {
		$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
	} else {
		$referrer = $_SERVER['HTTP_REFERER'];
	}
}
// How do we want to write it to the server? From here or within the widget?
// We don't really want to get an item logged each time a page is refreshed that contains the widget.
// So choose to log each time the widget action button is clicked.
echo ('var flashVars={widgetdatalanguage:"'.$dataLanguage.'", widgetdatacountry:"'.$dataCountry.'", widgetdatabclogo:"'.$dataBCLogo.'", widgetdatareferrer:"'.$referrer.'", widgetdatawidth:"'.$dataWidth.'", widgetdataheight:"'.$dataHeight.'"};var params={salign:"left", scale:"noscale", bgcolor:"'.$color.'"};');
echo ('swfobject.embedSWF("http://'.$_SERVER['HTTP_HOST'].'/Software/Widget/IELTS/bin/WhereToStudy-'.$swfWidth.'.swf", "WhereToStudy", "'.$dataWidth.'", "'.$dataHeight.'", "9.0.28", null, flashVars, params);');
echo ('document.write("<div id=\"WhereToStudy\" >Replace with widget</div>");');
?>