<?php 

/*
 * Security checking for all Start.php files in area1
 */
	$server = (isset($_SERVER['HTTP_X_FORWARDED_HOST'])) ? $_SERVER['HTTP_X_FORWARDED_HOST'] : $_SERVER['HTTP_HOST'];
	$httpProtocol = (isset($_SERVER['HTTPS']) && ($_SERVER['HTTPS'] != '')) ? 'https://' : 'http://';
	
	// v6.5.6 Add support for HTTP_X_FORWARDED_FOR
	if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
		// This might show a list of IPs. Assume/hope that EZProxy puts itself at the head of the list.
		// Not always it doesn't. So need to send the whole list to the licence checking algorithm. Better send as a list than an array.
		//$ipList = explode(',',$_SERVER['HTTP_X_FORWARDED_FOR']);
		//$ip = $ipList[0];
		$ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
	} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
		$ip=$_SERVER['HTTP_TRUE_CLIENT_IP'];
	} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
		$ip = $_SERVER["HTTP_CLIENT_IP"];
	} else {
		$ip = $_SERVER["REMOTE_ADDR"];
	}
	
	//added by sky
	$ip = str_replace(" ", "", $ip);
	
	// it is dangerous to send the whole referrer as you might get confused with parameters (specifically content)
	if (isset($_SERVER['HTTP_REFERER'])) {
		if (strpos($_SERVER['HTTP_REFERER'],'?')) {
			$referrer=substr($_SERVER['HTTP_REFERER'],0,strpos($_SERVER['HTTP_REFERER'],'?'));
		} else {
			$referrer = $_SERVER['HTTP_REFERER'];
		}
	} else if (isset($_SESSION['Referer'])) {
		$referrer = $_SESSION['Referer'];
	}

