<?php
//start the session
session_start();

//echo $_SESSION['UserName']."<br>";
//check to make sure the session variable is registered
// iyjdemo does not has UserID passed....
//if(session_is_registered('UserID')){
if (isset($_SESSION['UserID']) OR (isset($_SESSION['UserName'])=="iyjguest")){
	if (isset($_SESSION['Shared'])) {
		$prefix = $_SESSION['Prefix'];
		$isShared = true;
	}
	//session variable is registered, the user is ready to logout
	session_unset();
	session_destroy();
}
?>

<?php 
if (stripos($_SERVER["SERVER_NAME"], 'online.nas.ca')!==false) {
	header("location: http://online.nas.ca/NASindex.php");
} else {
	header("location: /");
}
?>