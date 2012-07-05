<?php

	if (isset($_GET['loginID'])) {
		$studentID= $_GET['loginID'];
	} else {
		$studentID= '1219-9557-0049';
	}
	$password = 'F4394783';
	
	// Check the password with hash of name, if it is the password of hash change to the edit page.
	$ctx = hash_init('sha1');
	hash_update($ctx, $studentID);
	$cPasswd = substr(hash_final($ctx), 0, 8);
	$cPasswd = strtoupper($cPasswd);

	echo $cPasswd;
