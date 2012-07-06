<?php
//start the session
session_start(  );

//echo $_SESSION['UserName']."<br>";
//check to make sure the session variable is registered
if(session_is_registered('UserName')){
	//session variable is registered, the user is ready to logout
	session_unset();
	session_destroy();
}
//debug: check whether the seesion has been cleared
#if(session_is_registered('userName')){ echo("yes"); } else { echo("no"); }

header("location: index.php");
?>