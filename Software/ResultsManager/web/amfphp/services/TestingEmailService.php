<?php
/*
 * This script will test our Email service
 */

require_once(dirname(__FILE__)."/EmailService.php");

$emailService = new EmailService();
session_start();
date_default_timezone_set('UTC');

$emailArray = array();
$emailArray[] = array("name" => 'Adrian Raper', "email" => 'adrian@clarityenglish.com');
$emailArray[] = array("name" => 'Andrew Stokes', "email" => 'andrew@clarityenglish.com');
$emailArray[] = array("name" => 'Rickson Lo', "email" => 'rickson@clarityenglish.com');
$emailArray[] = array("name" => 'Kenix Wong', "email" => 'kenix@clarityenglish.com');

$sender = array("name" => 'Jagdish Burma', "email" => 'jagdish@burma.com');
$template = "iLearnIELTSTellAFriend-1";
$emailService->sendEmails($template, $emailArray, $sender);

exit(0);
?>