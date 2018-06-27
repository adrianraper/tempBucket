<?php 
/*
 * Picked up data passed to the start page in different ways
 */
	require_once(dirname(__FILE__).'/../Software/Common/encryptURL.php');
    
    // Set up the URLs that you want to encrypt
    
    $urlArray = [];
    //$urlArray[] = 'prefix=TD&navigation=true&course=1287130100000&startingPoint=unit:1287130110000';
    $urlArray[] = 'prefix=Clarity&login=dandy@email&password=password';
    $urlArray[] = 'prefix=NMS&studentID=adrian';

    $crypt = new Crypt();
    foreach ($urlArray as $url) {
        echo "?data=".$crypt->encodeSafeChars($crypt->encrypt($url))."<br/>";
    }
    
    exit();