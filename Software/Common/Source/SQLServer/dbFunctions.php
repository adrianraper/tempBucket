<?php
require_once("crypto/claritySerialNumber.php");
require_once("crypto/Base8.php");
require_once("crypto/RSAKey.php");

class FUNCTIONS {
	
	private $dmsKey;
	private $orchidPublicKey;
	
	// gh#1277 This will now handle the creation of the checksum for a title to be passed back with internet regisgtration	
	function FUNCTIONS() {
		$this->dmsKey = new RSAKey("a6f945c79fa1db830591618a0178f1ec4076436bd22e2c264de61b114eb78fad", "10001", "8fe751ce63b3b95dc854ad7da51b3953811b560d00d6a1248d91cff6a2976841");
		$this->orchidPublicKey = new RSAKey("00c2053455fe3c7c7b22a629d53ab2d98a2f46a2c403457da8d044116df9ab43fb", "10001");
	}

	// gh#1277 Decode the passed serial number
	function decodeSerialNumber(&$vars, &$node){
		$serialNumberText = $vars['SERIALNUMBER'];
		$serialNumber = new claritySerialNumber();
		$rc = $serialNumber->decode($serialNumberText);
		if ($rc){
			if ($vars['PRODUCTCODE'] != "" && $vars['PRODUCTCODE'] != $serialNumber->productCode) {
				$node .= "<err code='404'>This serial number is for a different program (".$vars['PRODUCTCODE']." vs ".$serialNumber->productCode.")</err>";
				return false;
			} else {
				$node .= "<licence productCode='$serialNumber->productCode' expiryDate='$serialNumber->expiryDate' licences='$serialNumber->licences' licenceType='$serialNumber->licenceType' />";
				$vars['PRODUCTCODE'] = $serialNumber->productCode;
				$vars['EXPIRY'] = $serialNumber->expiryDate;
				$vars['LICENCES'] = $serialNumber->licences;
				$vars['LICENCETYPE'] = $serialNumber->licenceType;
			}
		} else {
			$node .= "<err code='402'>This serial number is not recognised.</err>";
			return false;
		}
		return true;
	}
	
	// v6.5.5 Is this serial number controlled in some way?
	function isNotBlacklisted( &$vars, &$node ){
		global $db;
		
		// Match the serial against the control table
		$sql = <<<EOD
				SELECT * from T_SerialNumberAdmin 
				WHERE F_SerialNumber=?
				AND F_Status=0
EOD;

		$serialNumber = $vars['SERIALNUMBER'];
		$bindingParams = array($serialNumber);
		$rs = $db->Execute($sql, $bindingParams);
		
		// no columns means this serialNumber is NOT blacklisted, so nothing to do
		if ($rs->RecordCount()==0) {
			$rs->Close();
			return true;
		} else {
			// otherwise set the return node
			$node .= "<err code='401'>This serial number has been blacklisted.</err>";
			$rs->Close();
			return false;
		}
	}
	
	// gh#1277 Generate a checksum for this licence
	function generateCheckSum($vars, &$node){
		
		// Assume that we are dealing with the network installation - or is root passed?
		$rootID = 1;
		$protectedString = $vars['INSTNAME'].$vars['EXPIRY'].' 23:59:59'.$vars['LICENCES'].$vars['LICENCETYPE'].$rootID.$vars['PRODUCTCODE'];
		$escapedString = $this->actionscriptEscape($protectedString);
		$hash = md5($escapedString);
		$m = Base8::encode($hash);
		$c = $this->dmsKey->sign($m);
		$c = $this->orchidPublicKey->encrypt($c);
		return $c;
	}
	
	// v6.5.5 Add the user's registration details to the database
	function insertDetails($vars, &$node){
		global $db;
		
		$instName = (isset($vars['INSTNAME'])) ? $vars['INSTNAME'] : 'unknown school'; 
		$product = (isset($vars['PRODUCT'])) ? $vars['PRODUCT'] : $vars['PRODUCTCODE'];
		$expiryDate = (isset($vars['EXPIRY'])) ? $vars['EXPIRY'] : '2000-01-01';
		$licences = (isset($vars['LICENCES'])) ? $vars['LICENCES'] : 0;
		$dateNow = date('Y-m-d G:i:s', time());
		$serialNumber = (isset($vars['SERIALNUMBER'])) ? $vars['SERIALNUMBER'] : 'unknown serial' ;
		$installationDate = (isset($vars['INSTALLDATE'])) ? $vars['INSTALLDATE'] : $dateNow;
		$address1 = (isset($vars['ADDRESS1'])) ? $vars['ADDRESS1'] : null;
		$address2 = (isset($vars['ADDRESS2'])) ? $vars['ADDRESS2'] : null;
		$address3 = (isset($vars['ADDRESS3'])) ? $vars['ADDRESS3'] : null;
		$address4 = (isset($vars['ADDRESS4'])) ? $vars['ADDRESS4'] : null;
		$city = (isset($vars['CITY'])) ? $vars['CITY'] : null;
		$state = (isset($vars['STATE'])) ? $vars['STATE'] : null;
		$postcode = (isset($vars['POSTCODE'])) ? $vars['POSTCODE'] : null;
		$contactTitle = (isset($vars['CONTACTTITLE'])) ? $vars['CONTACTTITLE'] : null;
		$contactName = (isset($vars['CONTACTNAME'])) ? $vars['CONTACTNAME'] : null;
		$contactJob = (isset($vars['CONTACTJOB'])) ? $vars['CONTACTJOB'] : null;
		$tel = (isset($vars['TEL'])) ? $vars['TEL'] : null;
		$fax = (isset($vars['FAX'])) ? $vars['FAX'] : null;
		$country = (isset($vars['COUNTRY'])) ? $vars['COUNTRY'] : null;
		$email = (isset($vars['EMAIL'])) ? $vars['EMAIL'] : null;
		$machineID = (isset($vars['MACHINEID'])) ? $vars['MACHINEID'] : null;

		// gh#895
		if (isset ( $_SERVER ['HTTP_X_FORWARDED_FOR'] )) {
			$ip = $_SERVER ['HTTP_X_FORWARDED_FOR'];
		} elseif (isset ( $_SERVER ['HTTP_TRUE_CLIENT_IP'] )) {
			$ip = $_SERVER ['HTTP_TRUE_CLIENT_IP'];
		} elseif (isset ( $_SERVER ["HTTP_CLIENT_IP"] )) {
			$ip = $_SERVER ["HTTP_CLIENT_IP"];
		} else {
			$ip = $_SERVER ["REMOTE_ADDR"];
		}
		
		$bindingParams = array($instName, $product, $expiryDate, $licences, $dateNow, $serialNumber, $address1,$address2,$address3,$address4);
		$bindingParams[] = $city;
		$bindingParams[] = $state;
		$bindingParams[] = $postcode;
		$bindingParams[] = $city;
		$bindingParams[] = $contactTitle;
		$bindingParams[] = $contactName;
		$bindingParams[] = $contactJob;
		$bindingParams[] = $tel;
		$bindingParams[] = $fax;
		$bindingParams[] = $country;
		$bindingParams[] = $email;
		$bindingParams[] = $ip;
		$bindingParams[] = $machineID;
		// v6.5.6.5 No need for CONVERT with a MySQL database
		//	'Network', CONVERT(datetime, ?, 120), 0,
		$sql = <<<EOD
			INSERT INTO T_Registration (F_InstitutionName, F_Product, F_ExpiryDate, F_MaxStu, 
									F_Licencing, F_CreateDate, F_UserID, 
									F_Serial, F_Addr1, F_Addr2, F_Addr3, F_Addr4, F_City, F_State, F_PostCode, 
									F_ContactTitle, F_ContactName, F_ContactJob, F_Tel, F_Fax, F_Country, F_InstType, 
									F_Email, F_IP, F_MachineID)
			VALUES
			(?, ?, ?, ?, 
			'Network', ?, 0,
			?, ?, ?, ?, ?, ?, ?, ?,
			?, ?, ?, ?, ?, ?, ?,
			?, ?, ?
			)
EOD;
		$rs = $db->Execute($sql, $bindingParams);
		
		if ($rs) {
			if (stristr($product,'MyCanada')) {
				$node .= "<register code='success' />";
			} else {
				$avCode = $this->CreateAVCode($serialNumber, $installationDate);
				$node .= "<register code='".$avCode."' />";
			}
			return true;
		} else {
			$node .= "<err code='403'>Failed to register your details.</err>";
			return false;
		}
	
	}
	// gh#1277 redundant when you send back a checksum
	// v6.5.5 Create a registration code to send back to the user
	function createAVCode($xSerialNo, $xfactor) {
	
		$src=$xSerialNo;
		$src = str_ireplace("-","",$src);
		
		$step=1;
		$firstbit=$secondbit=$thirdbit=$fourthbit=$fifthbit="";
		for ($i=0; $i<strlen($src); $i+=$step) {
			$firstbit .= substr($src,$i, 1);
		}
		//print ("firstbit=".$firstbit);
		$firstbit = $this->ZipText($firstbit, $step);
		//print ("firstbit=".$firstbit);
		$step=2;
		for ($i=1; $i<strlen($src); $i+=$step) {
			$secondbit .= substr($src,$i, 1);
		}
		$secondbit = $this->ZipText($secondbit, $step);
		$step=3;
		for ($i=2; $i<strlen($src); $i+=$step) {
			$thirdbit .= substr($src,$i, 1);
		}
		$thirdbit = $this->ZipText($thirdbit, $step);
		$step=4;
		for ($i=3; $i<strlen($src); $i+=$step) {
			$fourthbit .= substr($src,$i, 1);
		}
		$fourthbit = $this->ZipText($fourthbit, $step);
		
		$step=5;
		if ($xfactor == "") {
			for ($i=4; $i<strlen($src); $i+=$step) {
				$fifthbit .= substr($src,$i, 1);
			}
		} else {
			$fifthbit=$xfactor;
		}
		$fifthbit=$this->ZipText($fifthbit, $step);
		//print("bits=" .$firstbit .$secondbit .$thirdbit  .$fourthbit .$fifthbit);
		
		$Checkbit=$firstbit.$secondbit.$thirdbit.$fourthbit.$fifthbit;
		$Checkbit=$this->ZipText($Checkbit, 0);
		//myTrace("Checkbit=" + Checkbit);	
		//print("avcode:" +  .$firstbit .$secondbit .$thirdbit.$Checkbit.$fourthbit .$fifthbit);
		return $firstbit .$secondbit .$thirdbit.$Checkbit.$fourthbit .$fifthbit;	
	}
	function ZipText($src, $keyvalue) {
	
		$text=$src;
		$sumx=$keyvalue;
		//print $text."=";
		for ($i=0; $i<strlen($text); $i+=1) {
			//print ord(substr($text,$i, 1))."+";
			$sumx += ord(substr($text,$i, 1));
		}
		//print "".$sumx;
		
		//$Letteri=ord("I") - ord("A");
		$Letteri=8;
		//$Lettero=ord("O") - ord("A");
		$Lettero=14;
		//print " ".$Letteri." ".$Lettero;
		
		$RtnIndex = ($sumx - (24 * floor($sumx/24))) + 1;
		
		if ($RtnIndex >= $Letteri) {
			if ($RtnIndex >= $Lettero) {
				$RtnIndex += 2;
			} else {
				$RtnIndex += 1;
			}	
		}
		$RtnIndex += 64;
		//print " ".$RtnIndex." is ".chr($RtnIndex);
		return chr($RtnIndex);
	}
	/*
	 * This is a simple version of ActionScript escape function
	 */
	private function actionscriptEscape($text) {
		$needles = array('_','-','.');
		$replaces = array('%5F','%2D','%2E');
		return str_replace($needles,$replaces,rawurlencode($text));
	}
	
}
