<?php
//start the session
session_start(  );

//check to make sure the session variable is registered
//if(session_is_registered('UserName')){
if (isset($_SESSION['UserName'])
	//session variable is registered, the user is ready to logout
	session_unset();
	session_destroy();
}

header("location: index.php");
