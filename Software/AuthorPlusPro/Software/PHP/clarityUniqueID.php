<?php
// This file contains functions for forming strings of time stamp and ClarityUniqueID
// getTimeStamp() - returns YYYYMMDDHHmmss
// getCurrentServerTime() is now used for generating IDs
// ClarityUniqueID is found to be too long to fit in an integer field in databases
// use "milliseconds since 1 Jan 1970" instead
// but if the script is running quickly, it'll be giving the same id for the whole script
// so i change the last 3 digits to a random number

// Update so that you don't use random numbers but a static variable instead. This guarantees 999 unique numbers each second.
static $idCount = 0;

function getTimeStamp() {
	return date("YmdHis");
}
/*
function getCurrentServerTime() {
	$now = (string)microtime();
	$now = explode(' ', $now);
	$unique_id = substr($now[1].str_replace('.', '', $now[0]), 0, 10);
	unset($now);
	
	$n = rand(100, 999);
	$unique_id .= $n;
	
	return $unique_id;
}
*/
function getCurrentServerTime() {
	global $idCount;
	$now = (string)time();
	$base = substr($now, -10, 10);
	
	$idCount++;
	$unique_id = $base.sprintf("%03d",$idCount);
	
	if ($idCount>998)
		$idCount=0;
	return $unique_id;
}