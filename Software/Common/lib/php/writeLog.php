<?php
// Write out any data sent to you
// Build up the message
// Use ; to delimit to make it easier to process
$msg = '';
if (isset($_POST['thisWidget'])) {
	$msg.=$_POST['thisWidget'].'; ';
} else {
	$msg.='unknown;';
}
if (isset($_POST['referrer'])) {
	//$msg.='from '.$_POST['referrer'].' ';
	$msg.=$_POST['referrer'].'; ';
} else {
	$msg.='unknown;';
}
if (isset($_POST['stageWidth'])) {
	//$msg.='using width='.$_POST['stageWidth'].' ';
	$msg.=$_POST['stageWidth'].'; ';
} else {
	$msg.='0;';
}
$msg.= date('Y-m-d');
//error_log($msg."on $now\r\n", 3, '..\..\..\..\BritishCouncil\widgetLog.txt');
//error_log($msg."on $now\r\n", 3, dirname(__FILE__).'/../../../../BritishCouncil/widgetLog.txt');
// Because of multiple webservers, we need, as a first step, to use IP to get different logs
error_log("$msg\r\n", 3, dirname(__FILE__).'/../../../../BritishCouncil/widgetLog.txt');
$logName = 'widgetLog_'.$_SERVER['SERVER_ADDR'].'.txt';
error_log("$msg\r\n", 3, dirname(__FILE__).'/../../../../BritishCouncil/'.$logName);
?>
