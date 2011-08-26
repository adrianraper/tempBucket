<?php
/*
 * This script will send an email based on passed parameters only.
 */

require_once(dirname(__FILE__)."/EmailService.php");
require_once($GLOBALS['smarty_libs']."/Smarty.class.php");
$smarty = new Smarty();
$smarty->template_dir = $GLOBALS['smarty_template_dir'];
$smarty->compile_dir = $GLOBALS['smarty_compile_dir'];
$smarty->config_dir = $GLOBALS['smarty_config_dir'];
$smarty->cache_dir = $GLOBALS['smarty_cache_dir'];
$smarty->plugins_dir[] = $GLOBALS['smarty_plugins_dir'];

$emailService = new EmailService();
session_start();
date_default_timezone_set('UTC');

// TODO: get POST parameters for
// $to
// $cc - optional
// $templateID
// $question
//	$name = $_POST['name'];
//	$email = $_POST['email'];
//	$country = $_POST['country'];
//	$expiryDate = $_POST['expiryDate'];
//	$question = $_POST['question'];
$name =' Rickson Lo';
$email = 'rickson.lo@clarityenglish.com';
$country = 'Afghanistan';
$expiryDate = '2011-12-31';
$question = 'I want to do well in the speaking test?';
$dataArray = array("name" => $name, "email" => $email, "country" => $country, "expiryDate" => $expiryDate, "question" => $question);

// First of all, send the question to the expert
	$to = 'customerservice@ilearnIELTS.com';	
	$templateID = 'iLearnIELTSAskTheExpert-1';
	$emailArray = array("to" => $to
						,"data" => $dataArray
					);
					
	if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		$emailService->emailOps->sendEmails("", $templateID, array($emailArray));
		echo "<b>Email: ".$to."</b><br/>";
	} else {
		echo "<b>$to</b><br/><br/>".$emailService->emailOps->fetchEmail($templateID, $dataArray)."<hr/>";
	}

// Then, confirm that it has gone with an email to the customer
	$to = $email;	
	$templateID = 'iLearnIELTSAskTheExpert-ToCustomer';

	$emailArray = array("to" => $to
						,"data" => $dataArray
					);
					
	if (isset($_REQUEST['send']) || !isset($_SERVER["SERVER_NAME"])) {
		$emailService->emailOps->sendEmails("", $templateID, array($emailArray));
		echo "<b>Email: ".$to."</b><br/>";
	} else {
		echo "<b>$to</b><br/><br/>".$emailService->emailOps->fetchEmail($templateID, $dataArray)."<hr/>";
	}

exit(0);
?>