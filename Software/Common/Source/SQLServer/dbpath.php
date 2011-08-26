<?PHP
// ** 
// If the relative path from this file to the database folder is changed
// you will need to change the path here
// Assumes /Clarity/database and
// /Clarity/Software/Common/Source/MySQL
// **
//$thisPath = '/Orchid/Database/dbDetails-MySQL.php';
//$thisPath= '../../../../Database/dbDetails-SQLServer.php';
$thisPath= '../../../../Database/dbDetails.php';
if(!@file_exists($thisPath) ) {
	echo 'cannot find dbDetails file ' .$thisPath;
} else {
	require_once($thisPath);
}
?>
