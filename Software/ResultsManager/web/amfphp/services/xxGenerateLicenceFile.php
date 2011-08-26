<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */
require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

session_start();

$template = "licence_file";

$account_id = $_REQUEST['rootID'];
$productCode = $_REQUEST['productCode'];

$dmsService = new DMSService();

// Get the licence file text and print it
echo $dmsService-> licenceOps->generateLicenceFile($account_id, $productCode);

exit(0)
?>