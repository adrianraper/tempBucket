<?php
/*
 * This script is a gateway for discount functions
 */
/*
 * The purpose of this script is to be the main APIs for online Individual subscription
 * Anybody can call this script to 
 *		create new campaign and generate new discount codes
 *		check discount code information
 *		update an existing discount code information and create a record for using a discount code
 *
 * You send it a JSON object in POST data
 * 
 * Methods:
 * generateDiscountCodes
 * This is used when you have collected campaign information and
 * want to generate new discount codes for the campaign. It puts as much information as it can into the T_DiscountCode, T_Campaign and T_CampaignOffer tables
 * and gives you back an url link to download a CSV file which contains the discount codes.
 * mandatory input: campaignName, startDate, endDate, offerIDs, codeLength, codeBase, discountType, discountAmount, maxCount, numberOfCodes
 * optional input: targetRootID, codePrefix, dividerLength, campaignID, usedCount
 * returns: discount codes
 * 
 * checkAndGetDiscountCode
 * This is used when you have a discount code and want to check if this code is valid
 * mandatory input: discountCode, offerID, originalPrice
 * optional input: campaignID, rootID,
 * returns: false if the code is not valid, otherwise T_DiscountCode data
 * 
 * useDiscountCode
 * This is used when the discount code use with order placed
 * mandatory input: discountCode, offerID, originalPrice, discountedAmount, discountedPrice, subscriptionID
 * optional input: campaignID, rootID
 * returns: false if the data is not valid, otherwise T_DiscountCode data
 * 
 * checkDiscountRecords
 * This is used to the discount records 
 * mandatory input: discountCode or subscriptionID
 * returns: false if the data is not valid, otherwise T_DiscountCode and T_DiscountRecord data
 */

require_once(dirname(__FILE__)."/DMSService.php");
require_once(dirname(__FILE__)."../../core/shared/util/Authenticate.php");

$dmsService = new DMSService();
$nonApiInformation = array();

// All information will come in JSON format
function loadAPIInformation() {
	global $dmsService;
	
	$inputData = file_get_contents("php://input");
	//$inputData = '{"method":"generateDiscountCodes","campaignName":"IP.com testing","campaignID":"8","startDate":"2015-03-01","endDate":"2015-05-31","offerIDs":"59,60,61,62,63,64,65","codeLength":8,"codeBase":1,"discountType":1,"discountAmount":99.99,"maxCount":21,"numberOfCodes":10,"codePrefix":"skysky","dividerLength":5}';
	//$inputData = '{"method":"generateDiscountCodes","campaignName":"IP.com testing 2","startDate":"2015-02-01","endDate":"2015-03-31","offerIDs":"1,2,3,4,5","codeLength":8,"codeBase":2,"discountType":1,"discountAmount":19.99,"maxCount":1,"numberOfCodes":10,"codePrefix":"test","dividerLength":4}';
	//$inputData = '{"method":"generateDiscountCodes","campaignName":"IP.com testing 3","startDate":"2015-04-01","endDate":"2015-07-31","offerIDs":"1,2,3,4,5","codeLength":24,"codeBase":3,"discountType":3,"discountAmount":100,"maxCount":5,"numberOfCodes":20}';
	//$inputData = '{"method":"checkAndGetDiscountCode","discountCode":"TEST-LGTS","offerID":"1","originalPrice":"49.99"}';
	//$inputData = '{"method":"checkAndGetDiscountCode","discountCode":"skytesta","offerID":"1","campaignID":"11","rootID":"12"}';
	//$inputData = '{"method":"useDiscountCode","discountCode":"TEST-LGTS","offerID":"1","originalPrice":"49.99","discountedAmount":"9.99","discountedPrice":"40.00","subscriptionID":"123456"}';
	//$inputData = '{"method":"checkDiscountRecords","discountCode":"","subscriptionID":"35995"}';
	$postInformation= json_decode($inputData, true);	
	if (!$postInformation) 
		// TODO. Ready for PHP 5.3
		//throw new Exception("Error decoding data: ".json_last_error().': '.$inputData);
		throw new Exception('Error decoding data: '.$inputData);
	
	// We are expecting a method and parameters as an object
	// First check mandatory fields exist
	if (!isset($postInformation['method']))
		throw new Exception("No method has been sent");
		
	// check the mandatory data for each method
	$hasAllMandatoryData = true;
	switch ($postInformation['method']){
		case "generateDiscountCodes" : 
				if (!isset($postInformation['campaignName'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['startDate'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['endDate'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['offerIDs'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['codeLength'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['codeBase'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['discountType'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['discountAmount'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['maxCount'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['numberOfCodes'])) $hasAllMandatoryData = false;
				break;
				
		case "checkAndGetDiscountCode" :
				if (!isset($postInformation['discountCode'])) $hasAllMandatoryData = false; 
				if (!isset($postInformation['offerID'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['originalPrice'])) $hasAllMandatoryData = false;
				break;
		
		case "useDiscountCode" :
				if (!isset($postInformation['discountCode'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['offerID'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['originalPrice'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['discountedAmount'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['discountedPrice'])) $hasAllMandatoryData = false;
				if (!isset($postInformation['subscriptionID'])) $hasAllMandatoryData = false;
				break;
		
		case "checkDiscountRecords" :
				if (!isset($postInformation['discountCode']) && !isset($postInformation['subscriptionID'])) $hasAllMandatoryData = false;
				break;
		
		default : 
			throw new Exception("No method has been sent");
	}
	if (!$hasAllMandatoryData) {
		throw new Exception("Missing API Information");	
	}
	
	return $postInformation;
	
}	

function checkCampaign($campaignID){
	global $dmsService;
	
	$returnData = Array();
	
	$sql = <<<EOD
	SELECT * FROM T_Campaign
	WHERE F_CampaignID = ?
EOD;
	$bindingParams = array($campaignID);
	$rs = $dmsService->db->Execute($sql, $bindingParams);
	if ($rs->RecordCount() == 0){
		return 0;	
	} else if ($rs->RecordCount() == 1){
		$dbObj = $rs->FetchNextObj();
		$returnData['campaignName'] = $dbObj->F_CampaignName;
	} else {
		returnError(1, 'More than one campaign record with discount code '.$discountCode);
	}

	return $returnData;
}	

function checkCampaignOffer($campaignID){
	global $dmsService;
	
	$returnData = Array();
	
	$sql = <<<EOD
	SELECT * FROM T_CampaignOffer
	WHERE F_CampaignID = ?
EOD;
	$bindingParams = array($campaignID);
	$rs = $dmsService->db->Execute($sql, $bindingParams);
	if ($rs->RecordCount() > 0){
		$returnData['offerIDs'] = array();
		while ($dbObj = $rs->FetchNextObj()){
			array_push($returnData['offerIDs'],$dbObj->F_OfferID);
		}
		
	} else {
		return 0;
	}

	return $returnData;
}	

function checkDiscountCode($discountCode){
	global $dmsService;
	
	$returnData = Array();
	$sql = <<<EOD
	SELECT * FROM T_DiscountCode
	WHERE F_DiscountCode = ?
EOD;
	$bindingParams = array(str_replace('-','',$discountCode));
	$rs = $dmsService->db->Execute($sql, $bindingParams);
	if ($rs->RecordCount() == 0){
		return 0;
	} else if ($rs->RecordCount() == 1){
		$dbObj = $rs->FetchNextObj();
		$returnData['discountCode'] = $discountCode;
		$returnData['startDate'] = $dbObj->F_StartDate;
		$returnData['endDate'] = $dbObj->F_EndDate;
		$returnData['discountType'] = $dbObj->F_DiscountType;
		$returnData['discountAmount'] = $dbObj->F_DiscountAmount;
		$returnData['remainingAmount'] = $dbObj->F_RemainingAmount;
		$returnData['maxCount'] = $dbObj->F_MaxCount;
		$returnData['usedCount'] = $dbObj->F_UsedCount;
		$returnData['campaignID'] = $dbObj->F_CampaignID;
		$returnData['targetRootID'] = $dbObj->F_TargetRootID;
		
	} else {
		returnError(1, 'More than one discount code record with discount code '.$discountCode);
	}
	
	$returnData['campaign'] = checkCampaign($returnData['campaignID']);
	
	if ($returnData['campaign'] == 0){
		returnError(1, 'No campaign record is found with discount code '.$discountCode);	
	}
	
	$returnData['campaignOffer'] = checkCampaignOffer($returnData['campaignID']);
	
	if ($returnData['campaignOffer'] == 0){
		returnError(1, 'No OfferID record is found with discount code '.$discountCode);	
	}

	return $returnData;
}	

function checkDiscountRecordByDiscountCode($discountCode){
	global $dmsService;
	
	$returnData = Array();
	$sql = <<<EOD
	SELECT * FROM T_DiscountRecord
	WHERE F_DiscountCode = ?
EOD;
	$bindingParams = array(str_replace('-','',$discountCode));
	$rs = $dmsService->db->Execute($sql, $bindingParams);
	if ($rs->RecordCount() == 0){
		return 0;
	} else {
		while ($dbObj = $rs->FetchNextObj()){
			$discountRecord = array();
			$discountRecord['discountCode'] = $discountCode;
			$discountRecord['timeStamp'] = $dbObj->F_TimeStamp;
			$discountRecord['subscriptionID'] = $dbObj->F_SubscriptionID;
			$discountRecord['originalPrice'] = $dbObj->F_OriginalPrice;
			$discountRecord['discountedAmount'] = $dbObj->F_DiscountedAmount;
			$discountRecord['discountedPrice'] = $dbObj->F_DiscountedPrice;
			array_push($returnData, $discountRecord);
		}
	}

	return $returnData;
}	

function checkDiscountRecordBySubscriptionID($subscriptionID){
	global $dmsService;
	
	$returnData = Array();
	$sql = <<<EOD
	SELECT * FROM T_DiscountRecord
	WHERE F_SubscriptionID = ?
EOD;
	$bindingParams = array($subscriptionID);
	$rs = $dmsService->db->Execute($sql, $bindingParams);
	if ($rs->RecordCount() == 0){
		return 0;
	} else if ($rs->RecordCount() == 1){
		$dbObj = $rs->FetchNextObj();
		$discountRecord = array();
		$discountRecord['discountCode'] = $dbObj->F_DiscountCode;
		$discountRecord['timeStamp'] = $dbObj->F_TimeStamp;
		$discountRecord['subscriptionID'] = $dbObj->F_SubscriptionID;
		$discountRecord['originalPrice'] = $dbObj->F_OriginalPrice;
		$discountRecord['discountedAmount'] = $dbObj->F_DiscountedAmount;
		$discountRecord['discountedPrice'] = $dbObj->F_DiscountedPrice;
		array_push($returnData, $discountRecord);
	} else {
		returnError(1, 'More than one discount code record with subscriptionID '.$subscriptionID);
	}

	return $returnData;
}

function insertDiscountCode($discountCodeData){
	global $dmsService;
	
	$sql = <<<EOD
	INSERT INTO T_DiscountCode(F_DiscountCode, F_StartDate, F_EndDate, F_DiscountType, F_DiscountAmount, F_RemainingAmount, F_MaxCount, F_UsedCount, F_CampaignID, F_TargetRootID)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
EOD;
	$bindingParams = array(	str_replace('-','',$discountCodeData['discountCode']),
							$discountCodeData['startDate']." 00:00:00",
							$discountCodeData['endDate']." 23:59:59",
							$discountCodeData['discountType'],
							$discountCodeData['discountAmount'],
							$discountCodeData['remainingAmount'],
							$discountCodeData['maxCount'],
							$discountCodeData['usedCount'],
							$discountCodeData['campaignID'],
							$discountCodeData['targetRootID']
					);
	$rs = $dmsService->db->Execute($sql, $bindingParams);
}

function updateDiscountCode($discountCodeData){
	global $dmsService;
	
	$sql = <<<EOD
	UPDATE T_DiscountCode SET F_RemainingAmount=?, F_UsedCount=?
	WHERE F_DiscountCode=?
EOD;
	$bindingParams = array(	$discountCodeData['remainingAmount'],
							$discountCodeData['usedCount'],
							str_replace('-','',$discountCodeData['discountCode'])
					);
	$rs = $dmsService->db->Execute($sql, $bindingParams);
}

function insertDiscountRecord($discountRecordData){
	global $dmsService;
	
	$sql = <<<EOD
	INSERT INTO T_DiscountRecord(F_DiscountCode, F_SubscriptionID, F_OriginalPrice, F_DiscountedAmount, F_DiscountedPrice)
	VALUES (?, ?, ?, ?, ?)
EOD;
	$bindingParams = array(	str_replace('-','',$discountRecordData['discountCode']),
							$discountRecordData['subscriptionID'],
							$discountRecordData['originalPrice'],
							$discountRecordData['discountedAmount'],
							$discountRecordData['discountedPrice']
					);
	$rs = $dmsService->db->Execute($sql, $bindingParams);
	
	return $dmsService->db->Insert_ID();
}

function insertCampaign($campaignData){
	global $dmsService;
	
	$sql = <<<EOD
	INSERT INTO T_Campaign(F_CampaignName)
	VALUES (?)
EOD;
	$bindingParams = array(	$campaignData['campaignName']);
	$rs = $dmsService->db->Execute($sql, $bindingParams);
	
	return $dmsService->db->Insert_ID();
}

function insertCampaignOffer($campaignOfferData){
	global $dmsService;
	
	foreach ($campaignOfferData['offerIDs'] as $offerID){
		$sql = <<<EOD
		INSERT INTO T_CampaignOffer(F_CampaignID, F_OfferID)
		VALUES (?,?)
EOD;
		$bindingParams = array(	$campaignOfferData['campaignID'],$offerID);
		$rs = $dmsService->db->Execute($sql, $bindingParams);
	}
}


function returnError($errCode, $data = null) {
	global $dmsService;
	$apiReturnInfo = array('error'=>$errCode);
	switch ($errCode) {
		case 1:
			$apiReturnInfo['message'] = 'Exception, '.$data;
			break;
		case 201:
		case 301:
			$apiReturnInfo['message'] = 'No record is found with discount code '.$data;
			break;
		case 202:
		case 302:
			$apiReturnInfo['message'] = 'This discount code cannot be used with the offerID  '.$data;
			break;
		case 203:
		case 303:
			$apiReturnInfo['message'] = 'This discount code cannot be used with the campaignID  '.$data;
			break;
		case 204:
		case 304:
			$apiReturnInfo['message'] = 'This discount code cannot be used with the rootID  '.$data;
			break;
		case 205:
		case 305:
			$apiReturnInfo['message'] = 'This discount code has expired '.$data;
			break;
		case 206:
		case 306:
			$apiReturnInfo['message'] = 'This discount code has not started '.$data;
			break;
		case 207:
		case 307:
			$apiReturnInfo['message'] = 'This discount code is used '.$data;
			break;
		case 208:
		case 308:
			$apiReturnInfo['message'] = 'This discount code has an invalid discountType '.$data;
			break;
		case 309:
			$apiReturnInfo['message'] = 'Incorrect discounted price '.$data;
			break;
		case 310:
			$apiReturnInfo['message'] = 'Incorrect discounted amount '.$data;
			break;
		default:
			$apiReturnInfo['message'] = 'Unknown error'.$data;
			break;
	}
	// Write out the error to the log (we probably don't know the orderRef, but if we do, include it)
	$logMessage = 'returnError '.$errCode.': '.$apiReturnInfo['message'];
	AbstractService::$debugLog->err($logMessage);

	echo json_encode($apiReturnInfo);
	exit(0);
}

/*
 * Action for the script
 */
// Load the passed data
try {
	// Read and validate the data
	$apiInformation = loadAPIInformation();
	
	switch ($apiInformation['method']) {
		
		// Called to simply save a set of details in our table. Most likely to be called
		// before we send details to payment gateway to help us recover later.
		case "generateDiscountCodes":
			//Create a new Campaign if no campaignID provided or campaignID is not valid
			if (isset($apiInformation['campaignID']) && checkCampaign($apiInformation['campaignID'])){
				$campaignID = $apiInformation['campaignID'];
			}else{
				$campaignID = insertCampaign(array('campaignName' => $apiInformation['campaignName']));
				insertCampaignOffer(array('campaignID' => $campaignID, 'offerIDs' => explode(",", $apiInformation['offerIDs'])));
			}
			
			if ($apiInformation['codeLength'] < 8 or $apiInformation['codeLength'] > 40){
				returnError(1, 'The length of the discount must be between 8 and 40. '.$apiInformation['codeLength']);
			}
			
			switch ($apiInformation['codeBase']){
				case 1 : 
					$chars = array(0,1,2,3,4,5,6,7,8,9);
					break;
				case 2 :
					$chars = array('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');
					break; 
				case 3 :
					$chars = array(0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');
					break;
				default:
					returnError(1, 'No such code base '.$apiInformation['codeBase']);
			}
			
			if (isset($apiInformation['dividerLength'])){
				$divider = $apiInformation['dividerLength'];
			}else{
				$divider = $apiInformation['codeLength'];
			}
			
			$discountCodeData = array(
								'discountCode'  => '',
								'startDate'  => $apiInformation['startDate'],
								'endDate'  => $apiInformation['endDate'],
								'discountType'  => $apiInformation['discountType'],
								'discountAmount'  => $apiInformation['discountAmount'],
								'remainingAmount'  => (isset($apiInformation['remainingAmount'])?$apiInformation['']:$apiInformation['discountAmount']),
								'maxCount'  => $apiInformation['maxCount'],
								'usedCount'  => (isset($apiInformation['usedCount'])?$apiInformation['usedCount']:0),
								'campaignID'  => $campaignID,
								'targetRootID'  => (isset($apiInformation['targetRootID'])?$apiInformation['targetRootID']:null)
							);
			
			$serialNumbers = array();
			
			for ($j=0; $j<$apiInformation['numberOfCodes'] ;$j++){
			
				if (isset($apiInformation['codePrefix'])){
					$serial = strtoupper($apiInformation['codePrefix']);
				}else{
					$serial = '';
				}
				
				$max = count($chars)-1;
				
				for($i=strlen($serial);$i<$apiInformation['codeLength'] ;$i++){
					$serial .= (!($i % $divider) && $i ? '-' : '').$chars[rand(0, $max)];
				}
				
				if (checkDiscountCode(str_replace('-','',$serial))){
					echo "[[".$serial."]]";
					$j--;
					continue;
				}
				
				$discountCodeData['discountCode'] = $serial;
				
				insertDiscountCode($discountCodeData);
				
				array_push($serialNumbers,$serial);
			}
			
			//echo json_encode($serialNumbers);
			$returnInfo['campaignID'] = $campaignID;
			$returnInfo['discountCodes'] = $serialNumbers;
			//exit();
			
			break;
			
		case "checkAndGetDiscountCode":
			$discountCodeData = checkDiscountCode($apiInformation['discountCode']);
			if ($discountCodeData == 0)
				returnError(201, $apiInformation['discountCode']);
			if (!in_array($apiInformation['offerID'], $discountCodeData['campaignOffer']['offerIDs']))
				returnError(202, $apiInformation['offerID']);
			if (isset($apiInformation['campaignID']) && $apiInformation['campaignID'] != $discountCodeData['campaignID'])
				returnError(203, $apiInformation['campaignID']);
			if (isset($apiInformation['rootID']) && $apiInformation['rootID'] != $discountCodeData['targetRootID'])
				returnError(204, $apiInformation['rootID']);
			if (!isset($apiInformation['rootID']) && $discountCodeData['targetRootID'] != null)
				returnError(1, "Missing API Information");

			//check if the validity of the discount code
			$currentTime = time();
			if ($discountCodeData['startDate'] != null){
				$startTime = strtotime($discountCodeData['startDate']);
				if ($currentTime < $startTime)
					returnError(206, $apiInformation['discountCode']);
			}
			if ($discountCodeData['endDate'] != null){
				$endTime = strtotime($discountCodeData['endDate']);
				if ($currentTime > $endTime)
					returnError(205, $apiInformation['discountCode']);
			}
			
			if ($discountCodeData['discountType'] == "1"){
				if ($discountCodeData['remainingAmount'] == 0)
					returnError(207, $apiInformation['discountCode']);
				if ($discountCodeData['maxCount'] == $discountCodeData['usedCount'])
					returnError(207, $apiInformation['discountCode']);
			}			
			if ($discountCodeData['discountType'] == "3"){
				if ($discountCodeData['maxCount'] == $discountCodeData['usedCount'])
					returnError(207, $apiInformation['discountCode']);
			}
				
				
			if ($discountCodeData['discountType'] == "1" || $discountCodeData['discountType'] == "2"){
				$discountCodeData['discountedPrice'] = $apiInformation['originalPrice'] - $discountCodeData['remainingAmount'];
				if ($discountCodeData['discountedPrice'] < 0){
					$discountCodeData['discountedPrice'] = 0;
					$discountCodeData['discountedAmount'] = $apiInformation['originalPrice'];
				}else{
					$discountCodeData['discountedAmount'] = $discountCodeData['remainingAmount'];
				}
			}else if ($discountCodeData['discountType'] == "3" || $discountCodeData['discountType'] == "4"){
				$discountCodeData['discountedPrice'] = round($apiInformation['originalPrice'] * (100 - $discountCodeData['discountAmount']) / 100, 2);
				$discountCodeData['discountedAmount'] = round($apiInformation['originalPrice'] * $discountCodeData['discountAmount'] / 100, 2);
			}else {
				returnError(208, $discountCodeData['discountType']);
			}
			
			$discountCodeData['originalPrice'] = $apiInformation['originalPrice'];
				
			//echo json_encode($discountCodeData);
			$returnInfo = $discountCodeData;
			break;
			
		case "useDiscountCode":		
			$discountCodeData = checkDiscountCode($apiInformation['discountCode']);
			if ($discountCodeData == 0)
				returnError(301, $apiInformation['discountCode']);
			if (!in_array($apiInformation['offerID'], $discountCodeData['campaignOffer']['offerIDs']))
				returnError(302, $apiInformation['offerID']);
			if (isset($apiInformation['campaignID']) && $apiInformation['campaignID'] != $discountCodeData['campaignID'])
				returnError(303, $apiInformation['campaignID']);
			if (isset($apiInformation['rootID']) && $apiInformation['rootID'] != $discountCodeData['targetRootID'])
				returnError(304, $apiInformation['rootID']);
			if (!isset($apiInformation['rootID']) && $discountCodeData['targetRootID'] != null)
				returnError(1, "Missing API Information");

			//check if the validity of the discount code
			$currentTime = time();
			if ($discountCodeData['startDate'] != null){
				$startTime = strtotime($discountCodeData['startDate']);
				if ($currentTime < $startTime)
					returnError(306, $apiInformation['discountCode']);
			}
			if ($discountCodeData['endDate'] != null){
				$endTime = strtotime($discountCodeData['endDate']);
				if ($currentTime > $endTime)
					returnError(305, $apiInformation['discountCode']);
			}
			
			if ($discountCodeData['discountType'] == "1"){
				if ($discountCodeData['remainingAmount'] == 0)
					returnError(307, $apiInformation['discountCode']);
				if ($discountCodeData['maxCount'] == $discountCodeData['usedCount'])
					returnError(307, $apiInformation['discountCode']);
			}			
			if ($discountCodeData['discountType'] == "3"){
				if ($discountCodeData['maxCount'] == $discountCodeData['usedCount'])
					returnError(307, $apiInformation['discountCode']);
			}
			
			if ($discountCodeData['discountType'] == "1" || $discountCodeData['discountType'] == "2"){
				$discountCodeData['discountedPrice'] = $apiInformation['originalPrice'] - $discountCodeData['remainingAmount'];
				if ($discountCodeData['discountedPrice'] <= 0){
					$discountCodeData['discountedPrice'] = 0;
					$discountCodeData['discountedAmount'] = $apiInformation['originalPrice'];
					$discountCodeData['remainingAmount'] = $discountCodeData['remainingAmount'] - $apiInformation['originalPrice'];
				}else{
					$discountCodeData['discountedAmount'] = $discountCodeData['remainingAmount'];
					$discountCodeData['remainingAmount'] = 0;
				}
			}else if ($discountCodeData['discountType'] == "3" || $discountCodeData['discountType'] == "4"){
				$discountCodeData['discountedPrice'] = round($apiInformation['originalPrice'] * (100 - $discountCodeData['discountAmount']) / 100, 2);
				$discountCodeData['discountedAmount'] = round($apiInformation['originalPrice'] * $discountCodeData['discountAmount'] / 100, 2);
			}else {
				returnError(308, $discountCodeData['discountType']);
			}
			
			$discountCodeData['usedCount']++;
			
			$discountCodeData['originalPrice'] = $apiInformation['originalPrice'];
			
			if (abs($discountCodeData['discountedPrice']-$apiInformation['discountedPrice']) > 0.01)
				returnError(309, $apiInformation['discountedPrice']);
			if (abs($discountCodeData['discountedAmount']-$apiInformation['discountedAmount']) > 0.01)
				returnError(310, $apiInformation['discountedAmount']);
			
			$returnInfo = $discountCodeData;
			$returnInfo['discountRecordID'] = insertDiscountRecord($apiInformation);
			updateDiscountCode($discountCodeData);
			
			break;
			
		case "checkDiscountRecords":
			
			if ($apiInformation['discountCode'] == ""){
				$discountRecordData = checkDiscountRecordBySubscriptionID($apiInformation['subscriptionID']);
				$discountCodeData = checkDiscountCode($discountRecordData[0]['discountCode']);
			}else{
				$discountRecordData = checkDiscountRecordByDiscountCode($apiInformation['discountCode']);
				$discountCodeData = checkDiscountCode($apiInformation['discountCode']);
			}
			//echo json_encode($discountCodeData);
			$returnInfo['discountCode'] = $discountCodeData;
			$returnInfo['discountRecord'] = $discountRecordData;
			break;

			
		default:
			returnError(1, 'Invalid method '.$apiInformation->method);	
	}
	
	echo json_encode($returnInfo);
	
} catch (Exception $e) {
	// Lets assume that we are generating plain text
	returnError(1, $e->getMessage());
}
flush();
exit(0);