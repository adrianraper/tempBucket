<?php
// This file contains functions for forming strings of time stamp and ClarityUniqueID
// getTimeStamp() - returns YYYYMMDDHHmmss
// getCurrentServerTime() is now used for generating IDs
// ClarityUniqueID is found to be too long to fit in an integer field in databases
// use "milliseconds since 1 Jan 1970" instead
// but if the script is running quickly, it'll be giving the same id for the whole script
// so i change the last 3 digits to a random number

function getTimeStamp() {
	return date("YmdHis");
}

function getCurrentServerTime() {
	$now = (string)microtime();
	$now = explode(' ', $now);
	$unique_id = substr($now[1].str_replace('.', '', $now[0]), 0, 10);
	unset($now);
	
	$n = rand(100, 999);
	$unique_id .= $n;
	
	return $unique_id;
}
?>