<?php
// Write out any data sent to you
// Build up the message
// Use ; to delimit to make it easier to process

session_start();
date_default_timezone_set("UTC");

$msg = '';

/*
 * Now also use this for performance logging from R2I
 */
if (isset($_POST['method'])) {
	$method = $_POST['method'];
} else {
	$method = null;
}
if ($method = 'R2I_performance_log') {

	$msg .= 'timeStamp='.date('Y-m-d H:i:s');
	if (isset($_POST['task'])) {
		$msg .= '&task='.$_POST['task'];
	} else {
		$msg .= '&task='.'unknown';
	}
	// Are you told the time taken, or given a start and (optional) end time?
	if (isset($_POST['timeTaken'])) {
		$timeTaken = $_POST['timeTaken'];
		
	} elseif (isset($_POST['startTime'])) {
		// If there is no endTime, set it to now
		if (!isset($_POST['endTime'])) {
			$msec = round(microtime(true) * 1000);
			$timeTaken = $msec - $_POST['startTime'];
		} else {
			$timeTaken = $_POST['endTime'] - $_POST['startTime'];
		}
	} else {
		// You weren't given anything 
		$timeTaken = -1;
	}

	$msg .= '&timeTaken='.$timeTaken;
	if (isset($_POST['IP']))
		$msg .= '&ip='.$_POST['IP'];
	if (isset($_POST['data']))
		$msg .= '&data='.$_POST['data'];
		
	$logName = $method.'_'.$_SERVER['SERVER_ADDR'].'.txt';
	error_log("$msg\r\n", 3, dirname(__FILE__).'/../../logs/R2I/'.$logName);
		
} else {
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
	// Because of multiple webservers, we need, as a first step, to use IP to get different logs
	//error_log("$msg\r\n", 3, dirname(__FILE__).'/../../../../BritishCouncil/widgetLog.txt');
	$logName = 'widgetLog_'.$_SERVER['SERVER_ADDR'].'.txt';
	error_log("$msg\r\n", 3, dirname(__FILE__).'/../../../../BritishCouncil/'.$logName);
}
