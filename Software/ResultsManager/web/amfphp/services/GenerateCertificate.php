<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

require_once(dirname(__FILE__)."/CouloirService.php");
$service = new CouloirService();

// We have been passed a token that contains all the information to go into the certificate
if (!isset($_REQUEST['token']) || trim($_REQUEST['token']) == "")
    throw $this->copyOps->getExceptionForId("errorTokenInvalid");
$token = $_REQUEST['token'];

$summary = $service->authenticationCops->getPayloadFromToken($token);

echo $service->emailOps->fetchEmail($summary->data->template, $summary->data);
flush();
exit(0);
