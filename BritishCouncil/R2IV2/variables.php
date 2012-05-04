<?php
	$thisDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$commonDomain = 'http://'.$_SERVER['HTTP_HOST'].'/';
	$startFolder = 'BritishCouncil/R2IV2/';
	/*$thisDomain = 'http://www.roadtoielts.com/';
	$commonDomain = 'http://www.roadtoielts.com/';*/
	$dbHost = 102;

	// you can set the expiry date to a fixed one, or a period from now
	$expiryDate = '2012-05-30';
	$expiryDate = strftime('%Y-%m-%d %H:%M:%S', strtotime("+3 months"));
	
	// Will we write out lots of log messages?
	$debugLog = true;
	$debugFile = "GR2IV2.log";
	
	// types of login $vars['LOGINOPTION']
	$searchType = 1; // name 
	$searchType = 2; // id
	$searchType = 4; // both
	$searchType = 8; // Email 
	$searchType = 64; // UserID 
?>
