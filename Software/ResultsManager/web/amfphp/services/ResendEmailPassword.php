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

session_start();
date_default_timezone_set('UTC');

// Lets just see what we get from POST first
//var_dump($_POST);
//exit(0);

//check if the user has the IYJ licience
//if yes, check if the condition is passed
//if not, return ture
function passIYJ($user) {
	if(!isset($_POST['IYJ_productCode'])) {
		return false;
	}
	require_once($_SERVER['DOCUMENT_ROOT'].'/db_login.php');
	$userid = $user->userID;
	$querry_results = $db->Execute("Select * From T_Accounts a, T_Membership m where a.F_ProductCode=1001 AND m.F_UserID=$userid AND m.F_RootID=a.F_RootID");
	return ($querry_results->RecordCount() > 0) ;
}


// Core function is to look up the user based on the email, and any other information possible
// We really don't need any special DMS classes apart from email, oh and manageableOps!
function getUserFromEmail($userInformation) {
	//echo "addAccountFromPaymentGateway"; 
	global $dmsService;
	global $returnURL;
	
	$email = $userInformation['email'];
	// Change from productCode to licenceType as a way to check on unique email addresses
	//$pc = $userInformation['productCode'];
	$licenceType = $userInformation['licenceType'];
	
	// Before adding the account, I need to confirm if certain key fields are unique, but not enforced in the database.
	//$users = $dmsService-> manageableOps->getUserFromEmail($email, pc);
	$users = $dmsService-> manageableOps->getUserFromEmail($email, $licenceType);
	if ($users) {
	// RL: There is nowhere to use this script if it only accepts IYJ users. And nobody knows who write this passIYJ function. Should we just remove it?
	// And we can assume the user is the same person if the email is the same, let alone how many records we found!
		//if (count($users)==1 && passIYJ($users[0])) {
		if (count($users)>0) {
			// So just send the email from here.
			//echo "say that these are hidden ".var_dump($licencedProductCodes)."<br/>";
			$emailArray[] = array("to" => $users[0]->email
									,"data" => array("user" => $users[0])
									//,"cc" => array("adrian.raper@clarityenglish.com")
								);
								
			// Send the emails
			$templateID = isset($_POST['templateID'])?$_POST['templateID']:'CLS_forgot_password';
			$dmsService->emailOps->sendEmails("Clarity Support", $templateID, $emailArray);
			// If you are just testing, display the email template on screen.
			if ($returnURL != "") {
				// It doesn't work to set session variable since Curl puts us into a different session space (or something)
				//$_SESSION['IYJreg_password'] = $thisUser->password;
				// Lets assume that we are generating plain text
				header('Content-Type: text/plain');
				echo "&error=0&password={$users[0]->password}";
			} else {
				echo "<b>Email: ".$users[0]->email."</b><br/><br/>".$dmsService->emailOps->fetchEmail($templateID, array("user" => $users[0]))."<hr/>";
			}
		} else {
			header('Content-Type: text/plain');
			echo "&error=211&message=Duplicate emails found.";
		}
	} else {
		header('Content-Type: text/plain');
		echo "&error=210&message=Email not found.";
	}
}

// Account information will come in session variables
function loadUserInformation() {
	$userInformation = array();
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
	} else {
		$userInformation['licenceType'] = 5;
	}
	
	return $userInformation;
}

/*
 * Action for the script
 */
// Load the passed data
try {
	$userInformation = loadUserInformation();
	// Create the accounts
	getUserFromEmail($userInformation);
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	header('Content-Type: text/plain');
	echo '&error=1&message='.$e->getMessage();
}
exit(0)
?>