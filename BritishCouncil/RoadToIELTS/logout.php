<?php
	session_start();
	require_once "Variables.php";

	// Unset all of the session variables.
	$_SESSION = array();
	session_destroy();

	redirect($domain.$startFolder."login.php");
	
	// useful functions
	// http://php.dzone.com/news/php-redirect-function
	function redirect ($url) {
		header('Location: ' . $url);
		exit;
	}

?>