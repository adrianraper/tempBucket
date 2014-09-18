<?php
$rootPath= $_SERVER['DOCUMENT_ROOT'];
//$adodbPath= $rootPath.'/Database';
$dbPath= $rootPath.'/Database';
$adodbPath= $rootPath.'/Software/Common';
require_once($adodbPath."/adodb5/adodb-exceptions.inc.php");
require_once($adodbPath."/adodb5/adodb.inc.php");
//require_once(dirname(__FILE__)."/dbPath.php");
//require_once($dbPath."/dbDetails-SQLServer.php");
require_once($dbPath."/dbDetails.php");

// make the database connection
global $db;
global 	$current_subsite;
$dbDetails = new DBDetails(2);
//print($dbDetails->dsn);
$db = &ADONewConnection($dbDetails->dsn);
 
 // v3.6 UTF8 character mismatch between PHP and MySQL
 if ($dbDetails->driver == 'mysql') {
  $charSetRC = mysql_set_charset('utf8');
  //echo 'charSet='.$charSetRC;
 }

if (!$db) die("Connection failed");
//$db->debug = true;
$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
?>
