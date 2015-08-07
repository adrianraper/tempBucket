<?php
require_once("crypto/claritySerialNumber.php");

class FUNCTIONS {
	function FUNCTIONS() {
	}

	// Decode the passed serial number
	function decodeSerialNumber($vars, &$node){
		$serialNumberText = $vars['SERIALNUMBER'];
		$serialNumber = new claritySerialNumber();
		if ($serialNumber->decode($serialNumberText)) {
			$node .= "<register productCode='$serialNumber->productCode' expiryDate='$serialNumber->expiryDate' licences='$serialNumber->licences' />";
		} else {
			$node .= "<err serialNumberText='$serialNumberText' />";
		}
	}
	
	// v6.5.5 Is this serial number controlled in some way?
	function isNotBlacklisted( &$vars, &$node ){
		global $db;
		
		//' Match the serial against the control table
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
			if (stristr($vars['PRODUCT'],'MyCanada')) {
				$node .= "<register code='serialblocked' />";
			} else {
				$node .= "<register code='0' />";
			}
			$rs->Close();
			return false;
		}
	}
	// v6.5.5 Add the user's registration details to the database
	function insertDetails( &$vars, &$node ){
		global $db;
	
		$instName = $vars['INSTNAME'];
		$product = $vars['PRODUCT'];
		$Expiry = $vars['EXPIRY'];
		$Licences = $vars['LICENCES'];
		$dateNow = date('Y-m-d G:i:s', time());
		$SerialNumber = $vars['SERIALNUMBER'];
		$installationDate = $vars['INSTALLDATE'];
		$address1 = $vars['ADDRESS1'];
		$address2 = $vars['ADDRESS2'];
		$address3 = $vars['ADDRESS3'];
		$address4 = $vars['ADDRESS4'];
		$city = $vars['CITY'];
		$state = $vars['STATE'];
		$postcode = $vars['POSTCODE'];
		$contactTitle = $vars['CONTACTTITLE'];
		$contactName = $vars['CONTACTNAME'];
		$contactJob = $vars['CONTACTJOB'];
		$tel = $vars['TEL'];
		$fax = $vars['FAX'];
		$country = $vars['COUNTRY'];
		$email = $vars['EMAIL'];
		$MachineID = $vars['MACHINEID'];

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
		
		$bindingParams = array($instName, $product, $Expiry, $Licences, $dateNow, $SerialNumber,$address1,$address2,$address3,$address4);
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
		$bindingParams[] = $MachineID;
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
		
		if ( $rs ) {
			if (stristr($vars['PRODUCT'],'MyCanada')) {
				$node .= "<register code='success' />";
			} else {
				$checkSum = $this->CreateAVCode($SerialNumber, $installationDate);
				$node .= "<register code='".$checkSum."' />";
			}
			return true;
		} else {
			$node .= "<err code='202'>failed to insert licence record</err>";
			return false;
		}
	
	}
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
	
}
?>
