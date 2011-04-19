<?php
// Write out any data sent to you
// Build up the message
if (isset($_POST['thisWidget'])) {
	$msg.=$_POST['thisWidget'].' ';
} else {
	$msg.='A widget'.': ';
}
if (isset($_POST['referrer'])) {
	$msg.='from '.$_POST['referrer'].' ';
} else {
	$msg.='from unknown website ';
}
if (isset($_POST['stageWidth'])) {
	$msg.='using width='.$_POST['stageWidth'].' ';
}
$now = date('Y-m-j');
error_log($msg."on $now\r\n", 3, '../../logs/widgetLog.txt');
?>
