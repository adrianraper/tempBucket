<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

/*
 * The purpose of this script is to send an email to someone telling them their password
 * It expects to be passed the following in the POST array
 *		email
 *		licenceType
 *		productCode (optional)
 */

require_once(dirname(__FILE__)."/DMSService.php");

$dmsService = new DMSService();
// For testing, set this to false
$returnURL = true;

// Lets just see what we get from POST first
//var_dump($_POST);
//exit(0);

// Core function is to send the user an email
function sendPasswordEmail($userInformation) {
	global $dmsService;
	global $returnURL;
	
	$email = $userInformation['email'];
	// Change from productCode to licenceType as a way to check on unique email addresses
	//$pc = $userInformation['productCode'];
	$licenceType = isset($userInformation['licenceType']) ? $userInformation['licenceType'] : null;
	$loginOption = isset($userInformation['loginOption']) ? $userInformation['loginOption'] : null;
	$templateID = isset($userInformation['templateID']) ? $userInformation['templateID'] : 'forgot_password';
	
	$users = $dmsService->manageableOps->getUserFromEmail($email, $licenceType);
	if ($users) {
		// You may have found multiple users for this email. 
		// If they all have the same password simply send it.
		// If the passwords are different - what to do? We have already filtered by licence type to try and catch
		// those who have LM or IP.com accounts as well as school accounts. I think it has to be an error message.
		$passwordsMatch = true;
		$firstPassword = $users[0]->password;
		foreach ($users as $user) {
			if ($user->password != $firstPassword)
				$passwordsMatch = false;
		}
		if ($passwordsMatch) {
			$emailArray[] = array("to" => $users[0]->email, "data" => array("user" => $users[0], "loginOption" => $loginOption));
								
			// Send the emails
			$dmsService->emailOps->sendEmails("Clarity support", $templateID, $emailArray);
			// If you are just testing, display the email template on screen.
			if ($returnURL != "") {
				header('Content-Type: text/plain');
				// We should NOT send back the password!
				//echo "&error=0&password={$users[0]->password}";
				echo "&error=0&message=Email sent";
			} else {
				echo "<b>Email: ".$users[0]->email."</b><br/><br/>".$dmsService->emailOps->fetchEmail($templateID, array("user" => $users[0], "loginOption" => $loginOption))."<hr/>";
			}
		} else {
			header('Content-Type: text/plain');
			echo "&error=211&message=Email registered with different passwords.";
		}
	} else {
		header('Content-Type: text/plain');
		echo "&error=210&message=Email not registered in our database.";
	}
}

// Account information will come in session variables
function loadUserInformation() {
	global $returnURL;
	
	$userInformation = array();
	// For debugging
	if ($returnURL == false) {
		$userInformation['email'] = 'adrian@noodles.hk';
		$userInformation['loginOption'] = 1;
		$userInformation['templateID'] = 'ccb_forgot_password';
		return $userInformation;
	} 
	
	// First mandatory fields
	if (isset($_POST['CLS_Email'])) {
		$userInformation['email'] = $_POST['CLS_Email'];
	} elseif (isset($_GET['email'])) {
		$userInformation['email'] = $_GET['email'];
	} elseif (isset($_POST['IYJ_Email'])) {
		$userInformation['email'] = $_POST['IYJ_Email'];
	} else {
		//throw Exception("No email has been provided");
		header('Content-Type: text/plain');
		echo("&error=212&message=No email has been provided.");
		exit(0);
	}
	// This is not sent as it is common to all products
	//if (isset($_POST['CLS_productCode'])) {
	//	$userInformation['productCode'] = $_POST['CLS_productCode'];
	//} else {
	//	$userInformation['productCode'] = 1001;
	//}
	// But now lets use licenceType as a way to get unique emails
	if (isset($_POST['CLS_LicenceType'])) {
		$userInformation['licenceType'] = $_POST['CLS_LicenceType'];
	} elseif (isset($_POST['IYJ_licenceType'])) {
		$userInformation['licenceType'] = $_POST['IYJ_licenceType'];
	} elseif (isset($_GET['licenceType'])) {
		$userInformation['licenceType'] = $_GET['licenceType'];
	// gh#487 no longer a sensible default
	//} else {
	//	$userInformation['licenceType'] = 5;
	}
	
	// gh#487 We might send rootID too
	if (isset($_POST['rootID']))
		$userInformation['rootID'] = $_POST['rootID'];
	if (isset($_POST['loginOption']))
		$userInformation['loginOption'] = $_POST['loginOption'];
	if (isset($_POST['templateID']))
		$userInformation['templateID'] = $_POST['templateID'];
		
	return $userInformation;
}

/*
 * Action for the script
 */
// Load the passed data
try {
	$userInformation = loadUserInformation();
	// Send the email password
	sendPasswordEmail($userInformation);
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	header('Content-Type: text/plain');
	echo '&error=1&message='.$e->getMessage();
}
exit(0);