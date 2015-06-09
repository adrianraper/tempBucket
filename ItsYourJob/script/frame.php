<?php
if($_GET['t'] == "My_Progress"){
	//echo file_get_contents('myaccount.php');
	include '../myprogress.php';
}else if($_GET['t'] == "My_Account"){
	//echo file_get_contents('myaccount.php');
	include '../myaccount.php';
}else{
	//echo file_get_contents('mycourse.php');
	include '../mycourse.php';
}
?>