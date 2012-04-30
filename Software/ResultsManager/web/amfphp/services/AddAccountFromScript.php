<?php
/*
 * This is not really an AMFPHP service but its in this folder to maintain path integrity in all of the require_once calls.
 * Since there are no classes or methods here it does not represent a security risk.
 */

/*
 * The purpose of this script is to add an account to the database from outside of DMS.
 * It expects to be passed the following in the POST array
 *		name
 *		email
 *		expiryDate
 *		country
 *		productCode
 *		contact method (email, facebook, sms, twitter, none)
 *		verification code, from credit card acceptance
 *		checksum, ideally this would let us know we came from an authenticated page
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();

date_default_timezone_set('UTC');

// Lets just see what we get from POST first
//var_dump($_POST);
//exit(0);

if (!Authenticate::isAuthenticated()) {
	// v3.1 This script doesn't require authentication if it is run from a) the payment gateway. How to tell?
	// It will have to be based on a checksum of some sort, hopefully based on our https SSL cert?
	// This is critical because this is a powerful script!
	if (isset($_POST['CLS_checkSum'])) {
		// do something to confirm this checksum
		if ($_POST['CLS_checkSum'] == "rubbish" ) {
			throw new Exception("Corrupt data passed.");
			//exit(0);
		}
	} else if (!isset($_SERVER["SERVER_NAME"])) {
		// CRON job or similar
	} else if (Authenticate::isAuthenticated()) {
	} else {
		//echo "<h2>You are not logged in</h2>";
		throw new Exception("You are not logged in.");
	}
}

// If you have an account, do something to it
function addTitleToAccount($account) {
	global $dmsService;
	$rootID = $account->id;
	foreach ($account->titles as $title) {
		
		// Find existing Road to IELTS Academic and duplicate it to Road to IELTS 2 Academic
		switch ($title->productCode) {
		case 12:
			// You can't have a loop to weed out any that already have 52 as getAccounts only sends back titles that match.
			// Never mind, the T_Accounts table doesn't allow duplicate titles so just catch sql errors.
			/*
			foreach ($account->titles as $checkTitle) {
				if ($checkTitle->productCode == 52) {
					echo 'Jumped as already got 52 for '.$account->name."\n";
					continue 2;
				}
			}
			*/
			$newTitle = new Title($title);
			$newTitle->productCode = 52;
			$newTitle->languageCode = 'R2IFV';
		
			$newTitle->checkSum = $dmsService->accountOps->generateChecksumForTitle($title, $account);
			
			$titleArray = $newTitle->toAssocArray();
			$titleArray["F_RootID"] = $rootID;
			
			try {
				$dmsService->db->AutoExecute("T_Accounts", $titleArray, "INSERT");
				echo 'Added 52 for '.$account->name."\n";
			} catch (Exception $e) {
				echo 'Error for '.$account->name.' is '.$e->getMessage()."\n";
			}
			break;
			
		case 13:
			// Find existing Road to IELTS GT and duplicate it to Road to IELTS 2 Academic
			$newTitle = new Title($title);
			$newTitle->productCode = 53;
			$newTitle->languageCode = 'R2IFV';
		
			$newTitle->checkSum = $dmsService->accountOps->generateChecksumForTitle($title, $account);
			
			$titleArray = $newTitle->toAssocArray();
			$titleArray["F_RootID"] = $rootID;
			
			try {
				$dmsService->db->AutoExecute("T_Accounts", $titleArray, "INSERT");
				echo 'Added 53 for '.$account->name."\n";
			} catch (Exception $e) {
				echo 'Error for '.$account->name.' is '.$e->getMessage()."\n";
			}
		}
	}
}

// Core function is to add records to the database for Account and Titles (T_AccountRoot and T_Accounts).
// Let DMS worry about other details.
function addAccountFromPaymentGateway($accountInformation) {
	//echo "addAccountFromPaymentGateway"; 
	global $dmsService;
	global $returnURL;
	global $justForTesting;
	
	// Structure the information sent from the payment gateway.
	$account = new Account();
	
	$account->name = $accountInformation['name'];
	$account->email = $accountInformation['email'];
	$account->invoiceNumber = $accountInformation['orderRef'];
	
	// And what is fixed for all such accounts?
	$account->resellerCode = 21;
	$account->tacStatus = 2;
	$account->accountType = 1;
	$account->selfHost = false;
	$account->loginOption = 65;
	$account->accountStatus = 2;

	// What do we need from the database?
	$account->prefix = $dmsService->accountOps->getNextPrefix();
	//echo "account new prefix=$account->prefix"."<br />";
	
	// Before adding the account, I need to confirm if certain key fields are unique, but not enforced in the database.
	//if (!$dmsService->manageableOps->checkUniqueEmail($account->email)) {
	if (!$dmsService->manageableOps->checkUniqueEmail($account->email, $accountInformation['licenceType'])) {
		header('Content-Type: text/plain');
		echo "&error=200&message=Email address already used.";
		exit(0);
	}

	// Adding the learner as the supposed admin user - can this be done?
	$thisUser = new User();
	$thisUser->name = $account->name;
	$thisUser->email = $account->email;
	// v3.6.2 You may send the password to the script, in which case use that
	if (isset($accountInformation['password'])) {
		$thisUser->password = $accountInformation['password'];
	} else {
		$thisUser->password = generatePassword();
	}
	$thisUser->userType = User::USER_TYPE_STUDENT;
	if (isset($accountInformation['studentID'])) {
		$thisUser->studentID = $accountInformation['studentID'];
	}
	//RL: The user expiryDate should not be added otherwise will conflict with the title expirydate date, also because DMS cannot change this.
	//$thisUser->expiryDate = $accountInformation['expiryDate'];
	//AR: NULL should go into the database, check that this works
	$thisUser->expiryDate = '';
	if (isset($accountInformation['country'])) {
		$thisUser->country = $accountInformation['country'];
	}
	if (isset($accountInformation['city'])) {
		$thisUser->city = $accountInformation['city'];
	}
	// One other field is essential for EMUs
	$thisUser->startDate = $accountInformation['startDate'];
	$thisUser->contactMethod = $accountInformation['contactMethod'];
	$account->adminUser = $thisUser;
	
	// Adding the product(s)
	// Expecting 9:EN-39:NAMEN-1001:INDEN
	//echo $accountInformation['productCode'];
	$productPairs = explode("-", $accountInformation['productCode']);
	foreach ($productPairs as $productNameValue) {
		$pclc = explode(":", $productNameValue);
		$productCode= $pclc[0];
		$languageCode= $pclc[1];
		$thisTitle = new Title();
		//$thisTitle-> productCode = $accountInformation['productCode'];
		$thisTitle-> productCode = $productCode;
		// This looks odd, why isn't contentOps defined at the DMSService level? Stil it works just fine.
		// v3.3 Not good. The defaultContentLocation is useless, you have to base it on the productCode AND the language code
		// So do that now.
		//$thisProduct = $dmsService->accountOps->contentOps->getDetailsFromProductCode($thisTitle->productCode);
		//$thisProduct = $dmsService->accountOps->contentOps->getDetailsFromProductCode($thisTitle->productCode, $accountInformation['languageCode']);
		$thisProduct = $dmsService->accountOps->contentOps->getDetailsFromProductCode($productCode, $languageCode);
		$thisTitle-> name = $thisProduct['name'];
		// v3.3 I don't see we are using this for anything. And if we are it should surely go in T_ProductLanguage
		//$thisTitle-> softwareLocation = $thisProduct['softwareLocation'];
		// v3.3 We don't want to put anything in contentLocation unless you are overriding the default, which you aren't here
		//$thisTitle->contentLocation = $thisProduct['contentLocation'];
		
		$thisTitle->licenceType = $accountInformation['licenceType'];
		$thisTitle->maxStudents = $accountInformation['maxStudents'];
		$thisTitle->maxTeachers = $accountInformation['maxTeachers'];
		$thisTitle->maxReporters = $accountInformation['maxReporters'];
		$thisTitle->maxAuthors = $accountInformation['maxAuthors'];
		
		$thisTitle->expiryDate = $accountInformation['expiryDate'];
		$thisTitle->licenceStartDate = $accountInformation['startDate'];
		//$thisTitle->languageCode = $accountInformation['languageCode'];
		$thisTitle->languageCode = $languageCode;
		$thisTitle->deliveryFrequency = $accountInformation['deliveryFrequency'];

		$account->addTitles(array($thisTitle));
		// Now, if this product is an emu, it might contain other products. This is recorded in the Emu.
		// So we need to use contentOps to read the emu and search for licencedProductCode in any item.
		
		//if ($thisTitle->productCode>1000) {
		if ($productCode>1000) {
			//$licencedProductCodes = $dmsService->accountOps->contentOps->getLicencedProductCodes($thisTitle-> productCode);
			$licencedProductCodes = $dmsService->accountOps->contentOps->getLicencedProductCodes($productCode);
			//echo "licenced product codes=".print_r($licencedProductCodes)."<br/>";
			foreach ($licencedProductCodes as $licencedProductCode) {
				//echo "add account for product ".$productCode."<br/>";
				// get the product details and turn into a 'title'
				$thisTitle = new Title();
				$thisTitle->productCode = $licencedProductCode;
				//$thisProduct = $dmsService->accountOps->contentOps->getDetailsFromProductCode($licencedProductCode, $accountInformation['languageCode']);
				$thisProduct = $dmsService->accountOps->contentOps->getDetailsFromProductCode($licencedProductCode, $languageCode);
				$thisTitle->name = $thisProduct['name'];
				//echo "each has name=".$thisTitle->name."<br/>";
				// v3.3 I don't see we are using this for anything. And if we are it should surely go in T_ProductLanguage
				//$thisTitle->softwareLocation = $thisProduct['softwareLocation'];
				//$thisTitle->contentLocation = $thisProduct['contentLocation'];
				
				$thisTitle->licenceType = $accountInformation['licenceType'];
				$thisTitle->maxStudents = $accountInformation['maxStudents'];
				$thisTitle->maxTeachers = $accountInformation['maxTeachers'];
				$thisTitle->maxReporters = $accountInformation['maxReporters'];
				$thisTitle->maxAuthors = $accountInformation['maxAuthors'];
				
				$thisTitle->expiryDate = $accountInformation['expiryDate'];
				$thisTitle->licenceStartDate = $accountInformation['startDate'];
				//$thisTitle->languageCode = $accountInformation['languageCode'];
				$thisTitle->languageCode = $languageCode;
				
				$account->addTitles(array($thisTitle));
				
				// For these titles, we will be logging with userID, so set the action=validatedLogin
				$account->licenceAttributes[] = array('licenceKey' => 'action', 'licenceValue' => 'validatedLogin', 'productCode' => $licencedProductCode);
			}
		} else {
			$licencedProductCodes = array();
		}
	}
	//echo var_dump($account);
	
	// Use standard DMS function to add this account. This will cope with account root, accounts, group and user (admin)
	$rc = $dmsService->accountOps->addAccount($account);

	// Triggers are not used to send emails as they are daily or hourly. We need immediate.
	// So just send the email from here.
	//echo "say that these are hidden ".var_dump($licencedProductCodes)."<br/>";
	$emailArray = array();
	$emailArray[] = array("to" => $account->email
							,"data" => array("account" => $account, "hiddenProducts" => $licencedProductCodes)
							,"bcc" => array("adrian.raper@clarityenglish.com")
						);
						
	// Send the emails
	//$templateID = 'IYJ_welcome_individual';
	if (isset($accountInformation['templateID'])) {
		$templateID = $accountInformation['templateID'];
	} else {
		$templateID = 'CLS_welcome';
	}
	$dmsService->emailOps->sendEmails("", $templateID, $emailArray);
	// If you are just testing, display the email template on screen.
	if ($justForTesting) {
		echo "<b>Email: ".$account->email."</b><br/><br/>".$dmsService->emailOps->fetchEmail($templateID, array("account" => $account, 
																											"hiddenProducts" => $licencedProductCodes))."<hr/>";
	} else {
		// It doesn't work to set session variable since Curl puts us into a different session space (or something)
		//$_SESSION['CLS_password'] = $thisUser->password;
		// Lets assume that we are generating plain text
		header('Content-Type: text/plain');
		echo "&error=0&password={$thisUser->password}";
	}
}

// Account information will come in session variables
// No. Account information now comes from POST
function loadAccountInformation() {
	$accountInformation = array();
	global $returnURL;
	// First mandatory fields
	if (isset($_POST['CLS_name'])) {
		$accountInformation['name'] = $_POST['CLS_name'];
	} else {
		throw new Exception("No name has been provided");
	}
	if (isset($_POST['CLS_email'])) {
		$accountInformation['email'] = $_POST['CLS_email'];
	} else {
		throw new Exception("No email has been provided");
	}
	if (isset($_POST['CLS_product'])) {
		$accountInformation['productCode'] = $_POST['CLS_product'];
	} else {
		throw new Exception("No product code has been provided");
	}
	if (isset($_POST['CLS_orderRef'])) {
		$accountInformation['orderRef'] = $_POST['CLS_orderRef'];
	} else {
		throw new Exception("No order ref has been provided");
	}
	// Then fields you can default if no information passed
	// This now part of productCode
	//if (isset($_POST['CLS_language'])) {
	//	$accountInformation['languageCode'] = $_POST['CLS_language'];
	//} else {
	//	$accountInformation['languageCode'] = 'EN';
	//}
	if (isset($_POST['CLS_country'])) {
		$accountInformation['country'] = $_POST['CLS_country'];
	} else {
		$accountInformation['country'] = "global";
	}
	if (isset($_POST['CLS_city'])) {
		$accountInformation['city'] = $_POST['CLS_city'];
	} else {
		$accountInformation['city'] = "";
	}
	if (isset($_POST['CLS_contactMethod'])) {
		$accountInformation['contactMethod'] = $_POST['CLS_contactMethod'];
	} else {
		$accountInformation['contactMethod'] = "email"; 
	}
	// Then work out defaults specifically by product
	switch (intval($accountInformation['productCode'])) {
		case 1001:
		default:
				$courseDuration = 42; // days
				$defaultFrequency = 3;
				$licenceType = 5; // individual
				$maxStudents = 1;
				$maxAuthors = 0;
				$maxReporters = 0;
				$maxTeachers = 0;
			break;
	}
	if (isset($_POST['CLS_deliveryFrequency'])) {
		$accountInformation['deliveryFrequency'] = $_POST['CLS_deliveryFrequency'];
	} else {
		$accountInformation['deliveryFrequency'] = $defaultFrequency; // number of days
	}
	// Assume we will use server time for this. Force start time to be set here
	if (isset($_POST['CLS_startDate'])) {
		$accountInformation['startDate'] = $_POST['CLS_startDate'];
	} else {
		$accountInformation['startDate'] = date("Y-m-d 00:00:00");
	}
	if (isset($_POST['CLS_expiryDate'])) {
		$accountInformation['expiryDate'] = $_POST['CLS_expiryDate'];
	} else {
		$accountInformation['expiryDate'] = date('Y-m-d G:i:s', time() + (intval($courseDuration) * 24 * 60 * 60));
	}
	if (isset($_POST['CLS_licenceType'])) {
		$accountInformation['licenceType'] = intval($_POST['CLS_licenceType']);
	} else {
		$accountInformation['licenceType'] = $licenceType;
	}
	if (isset($_POST['CLS_maxStudents'])) {
		$accountInformation['maxStudents'] = intval($_POST['CLS_maxStudents']);
	} else {
		$accountInformation['maxStudents'] = $maxStudents;
	}
	// Optional stuff
	if (isset($_POST['CLS_password'])) {
		$accountInformation['password'] = $_POST['CLS_password'];
	}
	if (isset($_POST['CLS_studentID'])) {
		$accountInformation['studentID'] = $_POST['CLS_studentID'];
	}
	if (isset($_POST['CLS_templateID'])) {
		$accountInformation['templateID'] = $_POST['CLS_templateID'];
	}
	// Then things you never pass
	$accountInformation['maxAuthors'] = 0;
	$accountInformation['maxTeachers'] = 0;
	$accountInformation['maxReporters'] = 0;
	// And finally information for where to go back to
	// No, CURL can do this automatically
	//if (isset($_POST['CLS_returnURL'])) {
	//	$returnURL = $_POST['CLS_returnURL'];
	//}
	return $accountInformation;

}

// Just used for testing from a form or from standalone
function setDefaultsForTesting() {
	if (isset($_POST['CLS_name'])) {
		//$_SESSION['CLS_name'] = $_POST['name'];
	} else {
		//$_SESSION['CLS_name'] = "Clarity Harry";
		$_POST['CLS_name'] = "Nicole3 Lung";
	}
	if (isset($_POST['CLS_studentID'])) {
		//$_SESSION['CLS_name'] = $_POST['name'];
	} else {
		//$_SESSION['CLS_name'] = "Clarity Harry";
		$_POST['CLS_studentID'] = "1234-5678-9012";
	}
	if (isset($_POST['CLS_password'])) {
	} else {
		$_POST['CLS_password'] = "Nicole3";
	}
	if (isset($_POST['CLS_email'])) {
		//$_SESSION['CLS_email'] = $_POST['email'];
	} else {
		//$_SESSION['CLS_email'] = "adrian.raper@clarityenglish.com";
		$_POST['CLS_email'] = "nicole3@clarity.com.hk";
	}
	if (isset($_POST['CLS_product'])) {
		//$_SESSION['CLS_product'] = $_POST['productCode'];
	} else {
		$_POST['CLS_product'] = "9:EN-33:EN-39:BREN-3:EN";
	}
	if (isset($_POST['CLS_orderRef'])) {
		//$_SESSION['CLS_orderRef'] = $_POST['orderRef'];
	} else {
		$_POST['CLS_orderRef'] = "123457";
	}
	if (isset($_POST['CLS_checkSum'])) {
		//$_SESSION['CLS_checkSum'] = $_POST['checkSum'];
	} else {
		$_POST['CLS_checkSum'] = "aoijsdfPopianl;kanXXjnadfgadfg";
	}
	if (isset($_POST['CLS_country'])) {
	} else {
		$_POST['CLS_country'] = 'global';
	}
	if (isset($_POST['CLS_city'])) {
	} else {
		$_POST['CLS_city'] = 'Sai Kung';
	}
	if (isset($_POST['CLS_deliveryFrequency'])) {
		//$_SESSION['CLS_deliveryFrequency'] = $_POST['deliveryFrequency'];
	}
	//$_SESSION['CLS_returnURL'] = "true";
	//$_SESSION['CLS_returnURL'] = "";
}
/* 
 * Generating passwords. Ref Jon Haworth, www.laughing-buddha.net
 */
function generatePassword ($length = 8){

  // start with a blank password
  $password = "";

  // define possible characters (drop some vowels to avoid real words) and any other confusing characters
  $possible = "abcdefghjkmnpqrstvwxyz"; 
    
  $i = 0; 
  // add random characters to $password until $length is reached
  while ($i < $length) { 

    // pick a random character from the possible ones
    $char = substr($possible, mt_rand(0, strlen($possible)-1), 1);
        
    // doesn't matter if it is duplicated
    //if (!strstr($password, $char)) { 
      $password .= $char;
      $i++;
    //}
  }
  return $password;
}

/*
 * Action for the script
 */
// Load the passed data
try {
	//
	// This section for testing with selected accounts
	//
	header('Content-Type: text/plain');
	$conditions['active'] = true;
	$conditions['accountType'] = 1; // Standard invoice (ignores trials, distributors etc)
	$conditions['productCode'] = '12,13'; // existing RTI titles
	$conditions['selfHost'] = 'false';
	//$conditions['reseller'] = 7;
	
	//$conditions['excludeRootIDs'] = 'true';
	$rootList = null;
	$rootList = array(163,10732,10697);
	$accounts = $dmsService->accountOps->getAccounts($rootList, $conditions);
	if ($accounts) {
		echo "try to update ".count($accounts)." accounts\n";
		foreach ($accounts as $account) {
			addTitleToAccount($account);
		}
	}
	/*
	//
	// This section for testing with form or gateway
	//
	// Only if testing from a form or standalone
	$justForTesting = true;
	if ($justForTesting) {
		setDefaultsForTesting();
	}
	$accountInformation = loadAccountInformation();
	// Create the accounts
	addAccountFromPaymentGateway($accountInformation);
	*/
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	echo '&error=1&message='.$e->getMessage();
}
exit(0);
