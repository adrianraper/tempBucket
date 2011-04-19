<?php
// ** 
// If the relative path from this file to the database folder is changed
// you will need to change the path here
// Assumes /Clarity/Database and
// /Clarity/Software/AuthorPlusPro/Software/MySQL
// **
//$thisPath = '../../../Orchid/Database/dbDetails-MySQL.php';
$thisPath = '../../../../Database/dbDetails-MySQL.php';
if(!@file_exists($thisPath) ) {
   echo 'cannot find dbDetails file ' .$thisPath;
} else {
   include_once($thisPath);
}
?>
