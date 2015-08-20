<?php
	session_start();
	unset($_SESSION['dbHost']);
	if (isset($_REQUEST['dbHost'])) $_SESSION['dbHost']=$_REQUEST['dbHost'];
	
	$userName = $password = $extraParam = $licenceFile = '';
	if (isset($_SESSION['UserName'])) $userName = rawurlencode($_SESSION['UserName']);  
	if (isset($_SESSION['Password'])) $password = rawurlencode($_SESSION['Password']);
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Results Manager bulk importer</title>
	<link rel="shortcut icon" href="/Software/RM.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />

</head>
<body>
    <form action="http://dock.projectbench/Software/ResultsManager/web/amfphp/services/BulkImportToRM.php" method="post" enctype="multipart/form-data">
    <input type="file" name="csv" value="" />
    <input type="submit" name="submit" value="Save" /></form>
</body>
</html>
