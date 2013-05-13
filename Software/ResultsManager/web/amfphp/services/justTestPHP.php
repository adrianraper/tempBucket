<?php
/*
	$args = "prefix=GLOBAL&session=123gadfasdf456798&studentID=P574528(8)&password=Sunshine1787&padding=00000000000000000000000000";
	
	$key = '123457980123457890';
	$key = sha1($key, true); // get 20 digit hash
	$key = base64_encode($key); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters
	
	$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	$encryptedArgs = mcrypt_encrypt(MCRYPT_RIJNDAEL_256, $key, $args, MCRYPT_MODE_ECB, $iv);
	$td = mcrypt_module_open('rijndael-256', '', 'ofb', '');
	$iv = mcrypt_create_iv(mcrypt_enc_get_iv_size($td), MCRYPT_RAND);
    $ks = mcrypt_enc_get_key_size($td);
    $key = substr(md5($key), 0, $ks);
    mcrypt_generic_init($td, $key, $iv);
    $encryptedArgs = mcrypt_generic($td, $args);
	mcrypt_generic_deinit($td);
	mcrypt_module_close($td);
    
	$passedArgs = base64_encode($encryptedArgs);
	$newURL = 'http://dock.projectbench/Software/ResultsManager/web/amfphp/services/justTestPHP2.php?data='.$passedArgs;
	header('Location: ' . $newURL);
	*/

/*
	$validUnitIds = array();
	$validUnitIds[] = '377666536745193046';

		$thisUnitID = '377666536745193047';
				if (in_array($thisUnitID, $validUnitIds, true)) {
					$goodGosh = true;
				} else {
					$goodGosh = false;
				}
		$thisUnitID = '377666536';
				if (in_array($thisUnitID, $validUnitIds)) {
					$goodness = true;
				} else {
					$goodGosh = false;
				}
	$validUnitIds = array();
	$validUnitIds[] = '377666536745';

		$thisUnitID = '377666536746';
				if (in_array($thisUnitID, $validUnitIds)) {
					$goodGosh = true;
				} else {
					$goodGosh = false;
				}
		$thisUnitID = '377666536';
				if (in_array('adfsadf', $validUnitIds)) {
					$goodness = true;
				} else {
					$goodGosh = false;
				}
*/
	if (strtotime('2013-05-04 23:59:59') > strtotime(date("Y-m-d"))) {
		echo "it is still valid";
	} else {
		echo "you have expired";
	}
	
	if (version_compare(PHP_VERSION, '5.3.0') >= 0) {
    	echo 'I am at least PHP version 5.3.0, my version: ' . PHP_VERSION . "\n";
	}	
		
flush();
exit();
