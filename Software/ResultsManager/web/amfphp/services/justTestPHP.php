<?php
	$args = "prefix=GLOBAL&session=123gadfasdf456798&studentID=P574528(8)&password=Sunshine1787&padding=00000000000000000000000000";
	
	$key = '123457980123457890';
	$key = sha1($key, true); // get 20 digit hash
	$key = base64_encode($key); // nFXx CBo/ xe00 3MNw QbXK UwLf ECU= // This is 28 characters
	
	$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
	$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
	$encryptedArgs = mcrypt_encrypt(MCRYPT_RIJNDAEL_256, $key, $args, MCRYPT_MODE_ECB, $iv);
	/*
	$td = mcrypt_module_open('rijndael-256', '', 'ofb', '');
	$iv = mcrypt_create_iv(mcrypt_enc_get_iv_size($td), MCRYPT_RAND);
    $ks = mcrypt_enc_get_key_size($td);
    $key = substr(md5($key), 0, $ks);
    mcrypt_generic_init($td, $key, $iv);
    $encryptedArgs = mcrypt_generic($td, $args);
	mcrypt_generic_deinit($td);
	mcrypt_module_close($td);
	*/
    
	$passedArgs = base64_encode($encryptedArgs);
	$newURL = 'http://dock.projectbench/Software/ResultsManager/web/amfphp/services/justTestPHP2.php?data='.$passedArgs;
	header('Location: ' . $newURL);
	
flush();
exit();
