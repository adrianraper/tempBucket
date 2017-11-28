<?php
/**
 * This script is a debug gateway for Bento
 * Passed data will come in JSON format, but set to mimic calls from Bento programs via amfphp
 *
 */

// You have to call a concrete service which implements BentoService
require_once(dirname(__FILE__)."/ActiveReadingService.php");
// Classes normally included in amfphp but need to be manually included here
require_once(dirname(__FILE__)."/../core/shared/util/Authenticate.php");

$thisService = new ActiveReadingService();
ini_set('max_execution_time', 300); // 5 minutes

header('Content-Type: text/plain; charset=utf-8');

function loadAPIInformation() {
	global $thisService;

	//$inputData = file_get_contents("php://input");
	$inputData = '{"method":"getAccountSettings", "config":{"prefix":"Clarity", "rootID":0, "productCode":56}, "dbHost":2}';

    //$inputData = '{"method":"login", "loginObj":{"password": "dpt", "email":"nat@cat", "ip":"127.0.0.1"},
    //$inputData = '{"method":"login", "loginObj":{"password": "password", "email":"dandy@email", "ip":"127.0.0.1"},
    //$inputData = '{"method":"login", "loginObj":{"password": "dpt", "email":"frog@dog", "ip":"127.0.0.1"},
    //$inputData = '{"method":"login", "loginObj":{"password": "dpt", "email":"claire@dpt", "ip":"127.0.0.1"},
	//                "loginOption":128, "verified": true,
	//               "licence":{"licenceStartDate":"2015-01-01 00:00:00", "licenceClearanceFrequency":"1 year", "licenceType":1, "licenceControlStartDate":"2017-02-01", "maxStudents":3, "licenceClearanceDate":"2017-02-01", "expiryDate":"2018-12-31"}, "rootID":"163", "productCode":61, "dbHost":2}';
    //$inputData = '{"method":"login", "loginObj":null, "loginOption":128, "verified": true,
    //                "licence":{"licenceStartDate":"2015-01-01 00:00:00", "licenceClearanceFrequency":"1 year", "licenceType":2, "signInAs":2, "licenceControlStartDate":"2017-02-01", "maxStudents":3, "licenceClearanceDate":"2017-02-01", "expiryDate":"2018-12-31"},
    //                "rootID":[163], "productCode":"61", "dbHost":2}';

    // Do you want to fake a special date for testing?
    $GLOBALS['fake_now'] = '2017-08-29 09:00:00';

	$postInformation= json_decode($inputData, true);
	if (!$postInformation)
		throw new Exception('Error decoding data: '.': '.$inputData);

	// First check mandatory fields exist
	if (!isset($postInformation['method'])) {
		throw new Exception("No method has been sent");
	}

	return $postInformation;
}
function returnError($errCode, $data = null) {
	global $thisService;
	global $apiInformation;
	$apiReturnInfo = array('error'=>$errCode);
	switch ($errCode) {
		case 1:
			$apiReturnInfo['message'] = 'Exception, '.$data;
			break;
		case 200:
			$apiReturnInfo['message'] = 'Email address already registered, '.$data;
			break;
		case 201:
			$apiReturnInfo['message'] = 'Email/password combination is not correct';
			break;
		case 202:
			$apiReturnInfo['message'] = 'OfferID is not valid, '.$data;
			break;
		case 203:
			$apiReturnInfo['message'] = 'Email/password matches multiple accounts';
			break;
		case 204:
			$apiReturnInfo['message'] = 'ResellerID is not valid, '.$data;
			break;
		case 205:
			$apiReturnInfo['message'] = 'Discount code has been used before, '.$data;
			break;
		case 206:
			$apiReturnInfo['message'] = 'Discount code is not valid, '.$data;
			break;
		case 207:
			// Maybe this isn't an error, but instead we would just add a new record?
			$apiReturnInfo['message'] = 'SubscriptionID is not valid, '.$data;
			break;
		case 100:
			$apiReturnInfo['message'] = 'No such studentID '.$data;
			break;
		default:
			$apiReturnInfo['message'] = 'Unknown error';
			break;
	}
	// Write out the error to the log (we probably don't know the orderRef, but if we do, include it)
	$logMessage = 'returnError '.$errCode.': '.$apiReturnInfo['message'];
	AbstractService::$debugLog->err($logMessage);

	$apiReturnInfo['dsn'] = $GLOBALS['db'];
	$apiReturnInfo['dbHost'] = $GLOBALS['dbHost'];

	$returnInfo = array_merge($apiReturnInfo);
	echo json_encode($returnInfo);
	exit(0);
}

/*
 * Action for the script
 */
// Load the passed data
try {
	// Read and validate the data
	$apiInformation = loadAPIInformation();
	//AbstractService::$log->notice("calling validate=".$apiInformation->resellerID);
	//echo "loaded API";

	// You might want a different dbHost which you have now got - so override the settings from config.php
	if ($GLOBALS['dbHost'] != $apiInformation['dbHost'])
		$thisService->changeDbHost($apiInformation['dbHost']);

	switch ($apiInformation['method']) {
		case 'getAccountSettings':
            $rc = $thisService->getAccountSettings($apiInformation['config']);
			break;

        case 'login':
            $licence = new Licence();
            $licence->fromArray($apiInformation['licence']);
            $rc = $thisService->login($apiInformation['loginObj'], $apiInformation['loginOption'], $apiInformation['verified'], null, $licence, $apiInformation['rootID'], $apiInformation['productCode'], $apiInformation['dbHost']);
            break;

        default:
            throw new Exception('Couldn\'t handle method: '.$apiInformation['method']);
	}

	if (isset($rc['errCode']) && intval($rc['errCode']) > 0) {
		returnError($rc['errCode'], $rc['data']);
	}

	// Send back success variables
	//$apiReturnInfo = array('user' => $user);
	// Also send back any variables that you were sent, but don't understand
	//$returnInfo = array_merge($apiReturnInfo);
	echo json_encode($rc);

} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}

flush();
exit(0);
