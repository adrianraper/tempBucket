<?php
class claritySerialNumber {

	var $productCode;
	var $expiryDate;
	var $licences;
	var $productType;
	var $licenceType;
	var $controlType;
	var $checkSum;
	var $sequenceNumber;
	
	public function init() {
		$this->productCode = null;
		$this->expiryDate = null;
	}
	
	public function echoCRLF($value) {
		$lineBreak = "\r\n";
		$lineBreak = "<br/>";
		echo($value.$lineBreak);
	}
	
	public function decode($serial) {
		
		//$this->echoCRLF('');
		// First remove hyphens
		$simpleNumber = str_replace("-", "", $serial, $hyphenCount);
		if ($hyphenCount!=4)
			return false;
			
		// Take off the sequence number
		$patternRaw = substr($simpleNumber, -4);
		$sequenceNumber = intval($patternRaw, 16);
		//$this->echoCRLF('$sequenceNumber='.$sequenceNumber);
		
		// unshuffle based on the pattern
		$decodeBuildNumber = $this->unshufflePattern(substr($simpleNumber, 0, 16), $sequenceNumber);
		//$this->echoCRLF('$decodeBuildNumber='.$decodeBuildNumber);
		
		// Take off the checksum
		$decodeCheckSum = substr($decodeBuildNumber, -6);
		//$this->echoCRLF('$decodeCheckSum='.$decodeCheckSum);
		
		// Confirm that the base number matches the checksum
		$rawNumber = substr($decodeBuildNumber, 0, strlen($decodeBuildNumber)-6);
		//$this->echoCRLF("rawNumber=$rawNumber");
		$confirmCheckSum = $this->calculateCheckSum($rawNumber);
		//$this->echoCRLF("confirmCheckSum=$confirmCheckSum");
		if ($confirmCheckSum <> $decodeCheckSum) {
			//trace("checksums don't match, from serial=" + decodeCheckSum + " calculated=" + confirmCheckSum);
			// set everything to initialised so you don't have rubbish
			$this->init();
			return false;
		} else {
			//trace("valid check sum " + $confirmCheckSum);
		}
		// So set this part
		$this->checkSum = $decodeCheckSum;
		
		// format is mergedPadded(2) + productCodePadded(2)  + licencesPadded(2)  + expiryPadded(4) + checkSum(6) + patternPadded(4);
		// Pull out the rest and put back to hex
		$decodeProductCode = intval(substr($decodeBuildNumber, 2, 2), 16);
		//$this->echoCRLF("decode product code=$decodeProductCode");
		// So set this part
		$this->productCode = $decodeProductCode;
		
		$decodeLicences = intval(substr($decodeBuildNumber, 4, 2), 16);
		//$this->echoCRLF("decode licences=$decodeLicences");
		// So set this part
		$this->licences = $decodeLicences;
		
		$daysToExpiry = intval(substr($decodeBuildNumber, 6, 4), 16);
		//$this->echoCRLF("decode expiry days=$daysToExpiry");
		$playDate = new DateTime('1970-01-01');
		$decodeExpiry = $playDate->add(new DateInterval("P".$daysToExpiry."D"));
		//$this->echoCRLF("decode expiry date=".$decodeExpiry->format('Y-m-d'));
		// So set this part
		$this->expiryDate = $decodeExpiry->format('Y-m-d');
		
		$decodeType = intval(substr($decodeBuildNumber, 0, 2), 16);
		//$this->echoCRLF("decode type=$decodeType");
		$productMask = (pow(2,8) - pow(2,5));
		$decodeProductType = ($decodeType & $productMask) / pow(2,5);
		//$this->echoCRLF("decode product type=$decodeProductType");
		$licenceMask = (pow(2,5) - pow(2,2));
		$decodeLicenceType = ($decodeType & $licenceMask) / pow(2,2);
		//$this->echoCRLF("decode licence type=$decodeLicenceType");
		$controlMask = (pow(2,2) - pow(2,0));
		$decodeControlType = ($decodeType & $controlMask) / pow(2,0);
		//$this->echoCRLF("decode control=$decodeControlType");
		// So set this part
		$this->productType = $decodeProductType;
		$this->licenceType = $decodeLicenceType;
		$this->controlType = $decodeControlType;
		
		// all was well so say good
		return true;
	}

	// shuffling based on a pattern
	private	function unshufflePattern($originalString, $pattern) {
		$movedArray = array();
		for ($i=0, $counter=0; $i<strlen($originalString); $i++) {
			//trace(i);
			// is the pattern binary mask set for this digit, in which case it moved
			if (pow(2, $i) & $pattern) {
				// it is, so add to the end of the array and up the counter
				//$this->echoCRLF($i.":moved ".substr($originalString, $counter, 1));
				$movedArray[] = substr($originalString, $counter++, 1);
			} else {
				//$this->echoCRLF($i.":nothing");
			}
		}
		// You now know the 'base' point of the String, put it into the array
		//$this->echoCRLF("base=$counter");
		$builtArray = array();
		//$this->echoCRLF("start build=".implode('', $builtArray));
		// now see if the rest of the string moved
		for ($i=0, $j = strlen($originalString)-1; $i<strlen($originalString); $i++, $j--) {
			//$this->echoCRLF("i=$i j=$j");
			// is the pattern binary mask set for this digit, in which case it moved
			if (pow(2, $j) & $pattern) {
				// it is, so pick it from the moved array (at the end)
				//$this->echoCRLF("take from moved");
				$builtArray[] = array_pop($movedArray);
			} else {
				// it isn't so pick it from the string
				//$this->echoCRLF("take ".substr($originalString, $counter, 1));
				$builtArray[] = substr($originalString, $counter++, 1);
			}
			//$this->echoCRLF("built=".implode(",", $builtArray));
		}
		$builtArray = array_reverse($builtArray);
		return implode("", $builtArray);
	}
	
	private function zeroPad($value, $digits) {
		$stringValue = (string)$value;
		while (strlen($stringValue) < $digits) {
			$stringValue = "0" + $stringValue;
		}
		return $stringValue;
	}

	private	function calculateCheckSum($buildNumber) {
		$firstPart = 1;
		$secondPart = 0;
		for ($i=0; $i<strlen($buildNumber); $i++) {
			//$this->echoCRLF("code=".ord(substr($buildNumber, $i, 1)));
			$firstPart += ord(substr($buildNumber, $i, 1));
			$secondPart += $firstPart;
		}
		// make sure the parts fit into 3 bytes
		$firstPart = $firstPart % 0xFFF; 
		$secondPart = $secondPart % 0xFFF; 
		//$this->echoCRLF("check sum first part = ".$firstPart." second part = ".$secondPart);
		
		//trace("check sum first part = " + firstPart + " second part = " + secondPart);
		return $this->zeroPad(strtoupper(dechex($secondPart)), 0, 3).$this->zeroPad(strtoupper(dechex($firstPart)), 0, 3);
	}
	
}

/*
 * 
 * class claritySerialNumber
{
	// raw parts
	private var c_productCode:Number;
	private var c_licences:Number;
	private var c_expiryDate:Date;
	private var c_productType:Number;
	private var c_licenceType:Number;
	private var c_controlType:Number;
	private var c_sequenceNumber:Number;
	// calculated parts
	private var c_daysToExpiry:Number;
	private var checkSum:String;
	private var serialNumber:String;
	private var baseNumber:String;
	
	public function claritySerialNumber () {
		// When you create an instance, set everything to empty
		initSerialNumber();
	}
	private function initSerialNumber() {
		productCode = 0;
		licences = 0;
		expiryDate = new Date();
		productType = 0;
		licenceType = 0;
		controlType = 0;
		sequenceNumber = 0;
	}
	function get productCode():Number  {
		return c_productCode;
	}
	function get licences():Number  {
		return c_licences;
	}
	function get expiryDate():Date  {
		return c_expiryDate;
	}
	function get productType():Number  {
		return c_productType;
	}
	function get licenceType():Number  {
		return c_licenceType;
	}
	function get controlType():Number  {
		return c_controlType;
	}
	function get sequenceNumber():Number  {
		return c_sequenceNumber;
	}
	function set productCode(code:Number):Void  {
		if (code < 256) {
			c_productCode = code;
		} else {
			c_productCode = 0;
		}
	}
	function set licences(code:Number):Void  {
		if (code < 256) {
			c_licences = code;
		} else {
			c_licences = 0;
		}
	}
	function set expiryDate(code:Date):Void  {
		//trace("setting expiryDate to " + code.toString());
		c_expiryDate = code;
		c_daysToExpiry = Math.ceil(code.valueOf()/(1000*60*60*24));
		//trace("c_daysToExpiry=" + c_daysToExpiry);
	}
	function set productType(code:Number):Void {
		if (code < 8) {
			c_productType = code;
		} else {
			c_productType = 0;
		}
	}
	function set licenceType(code:Number):Void {
		if (code < 8) {
			c_licenceType = code;
		} else {
			c_licenceType = 0;
		}
	}
	function set controlType(code:Number):Void  {
		if (code < 4) {
			c_controlType = code;
		} else {
			c_controlType = 0;
		}
	}
	function set sequenceNumber(code:Number):Void  {
		if (code == undefined) {
			c_sequenceNumber = Math.random() * 0xFFFF;
		} else if (code > 0 && code < 0xFFFF) {
			c_sequenceNumber = code;
		} else {
			c_sequenceNumber = 0;
		}
	}
	// To get a serial number from the class
	function createSerialNumber():String {
		//trace("createSN, licences=" + c_licences + " title=" + c_productCode + " days=" + c_daysToExpiry);
		// Have the key settings been made?
		if (c_productCode > 0 && c_licences > 0 && c_daysToExpiry > 0) {
			// What is the base of the serial number (before checksum and shuffling)
			var productCodePadded:String = zeroPad(c_productCode.toString(16).toUpperCase(),2);
			var licencesPadded:String = zeroPad(c_licences.toString(16).toUpperCase(),2);
			var expiryPadded = zeroPad(c_daysToExpiry.toString(16).toUpperCase(),4);
			var productPart = c_productType * Math.pow(2,5);
			var licencePart = c_licenceType * Math.pow(2,2);
			var controlPart = c_controlType * Math.pow(2,0);
			var mergedPadded:String = zeroPad((productPart + licencePart + controlPart).toString(16).toUpperCase(),2);
			baseNumber = mergedPadded + productCodePadded  + licencesPadded  + expiryPadded;
			//trace("base num=" + baseNumber);
			
			// Add the checksum to the base
			checkSum = calculateCheckSum(baseNumber);
			//trace("checksum=" + checkSum);
			
			// Shuffle this based on the sequence number (as a pattern mask)
			var shuffledString:String = shufflePattern(baseNumber + checkSum, c_sequenceNumber);
			var patternPadded:String = zeroPad(c_sequenceNumber.toString(16).toUpperCase(),4);
			//trace("pattern=" + c_sequenceNumber.toString(2));
			serialNumber = hyphenate(shuffledString + patternPadded,4);
		
		// they haven't so you can't create a serial number
		} else {
			if (c_productCode <= 0) { 
				trace("productCode is blank " + c_productCode);
			}
			if (c_licences <= 0) {
				trace("licences is blank " + c_licences);
			}
			if (c_daysToExpiry <= 0) {
				trace("days to expiry " + c_daysToExpiry);
			}
			serialNumber = hyphenate("00000000000000000000",4);
		}
		return serialNumber;
	}

	// This function takes a serial number and tries to break it down into the component parts
	public function decodeSerialNumber(thisNumber:String):Boolean {
		
		trace("decode " + thisNumber);
		// Clear anything out from the existing object
		initSerialNumber();
		
		// First remove hyphens
		var simpleNumber:String = thisNumber.split("-").join("");
	
		// Take off the patten and unshuffle
		var patternRaw:String = simpleNumber.substr(-4);
		//trace("decode patternRaw=" + patternRaw);
		var decodePattern = parseInt(patternRaw,16);
		trace("decode pattern=" + decodePattern.toString());
		// So set this part
		sequenceNumber = decodePattern;
		
		var decodeBuildNumber =  unshufflePattern(simpleNumber.substr(0,16), decodePattern);
		//trace("decode build=" + decodeBuildNumber);
		
		// Take off the checksum
		var decodeCheckSum = decodeBuildNumber.substr(-6);
		//trace("read checksum=" + decodeCheckSum);
		// Confirm that the base number matches the checksum
		var rawNumber = decodeBuildNumber.substr(0,decodeBuildNumber.length-6);
		//trace("rawNumber=" + rawNumber);
		var confirmCheckSum:String = calculateCheckSum(rawNumber);
		if (confirmCheckSum <> decodeCheckSum) {
			trace("checksums don't match, from serial=" + decodeCheckSum + " calculated=" + confirmCheckSum);
			// set everything to initialised so you don't have rubbish
			initSerialNumber();
			return false;
		} else {
			trace("valid check sum " + confirmCheckSum);
		}
		// So set this part
		checkSum = decodeCheckSum;
		
		// format is mergedPadded(2) + productCodePadded(2)  + licencesPadded(2)  + expiryPadded(4) + checkSum(6) + patternPadded(4);
		// Pull out the rest and put back to hex
		var decodeproductCode = parseInt(decodeBuildNumber.substr(2,2),16);
		//trace("decode title code=" + decodeproductCode);
		// So set this part
		productCode = decodeproductCode;
		
		var decodeLicences = parseInt(decodeBuildNumber.substr(4,2),16);
		//trace("decode licences=" + decodeLicences);
		// So set this part
		licences = decodeLicences;
		
		var daysToExpiry:Number = parseInt(decodeBuildNumber.substr(6,4),16);
		//trace("decode expiry days=" + daysToExpiry);
		var decodeExpiry:Date = new Date(daysToExpiry*1000*60*60*24);
		//trace("decode expiry date=" + decodeExpiry.toString());
		// So set this part
		expiryDate = decodeExpiry;
		
		var decodeType:Number = parseInt(decodeBuildNumber.substr(0,2),16);
		//trace("decode type=" + decodeType);
		var productMask = (Math.pow(2,8)-Math.pow(2,5));
		var decodeProductType:Number = (decodeType & productMask) / Math.pow(2,5);
		//trace("decode product type=" + decodeProductType);
		var licenceMask = (Math.pow(2,5)-Math.pow(2,2));
		var decodeLicenceType:Number = (decodeType & licenceMask) / Math.pow(2,2);
		//trace("decode licence type=" + decodeLicenceType);
		var controlMask = (Math.pow(2,2)-Math.pow(2,0));
		var decodeControlType:Number = (decodeType & controlMask) / Math.pow(2,0);
		//trace("decode control=" + decodeControlType);
		// So set this part
		productType = decodeProductType;
		licenceType = decodeLicenceType;
		controlType = decodeControlType;
		
		// all was well so say good
		return true;
	}
	public function toString():String {
		return "Title:" + productCode + " licences:" + licences + " expiry:" + expiryDate.toString() + " sequence:" + sequenceNumber + " types - product:" + productType + " licence:" + licenceType + " control:" + controlType;
	}
	
	function calculateCheckSum(buildNumber:String):String {
		var firstPart:Number = 1;
		var secondPart:Number = 0;
		for (var i=0; i<buildNumber.length; i++) {
			//trace("code=" + serial.charCodeAt(i));
			firstPart+=buildNumber.charCodeAt(i);
			secondPart+=firstPart;
		}
		// make sure the parts fit into 3 bytes
		firstPart %= 0xFFF+1; 
		secondPart %= 0xFFF+1; 
		//trace("check sum first part = " + firstPart + " second part = " + secondPart);
		return zeroPad(secondPart.toString(16).toUpperCase(),3) + zeroPad(firstPart.toString(16).toUpperCase(),3);
	}
	function shufflePattern(originalString:String, pattern:Number):String {
		//trace("original=" + originalString)
		var builtArray:Array = new Array();
		var i=originalString.length-1;
		while (i>=0) {
			// is this string position set in the pattern binary mask?
			if (Math.pow(2,i) & pattern) {
				//trace(i + ": matches bit so front " + originalString.substr(i,1));
				// it is, so move it to the front
				builtArray.unshift(originalString.substr(i,1));
			} else {
				//trace(i + ": not in so end " + originalString.substr(i,1));
				// otherwise add it to the end
				builtArray.push(originalString.substr(i,1));
			}
			i--;
		}
		//trace("final=" + builtArray.join(""))
		return builtArray.join("");
	}
	function unshufflePattern(originalString:String, pattern:Number):String {
		var movedArray:Array = new Array();
		for (var i=0, counter=0; i<originalString.length;i++) {
			//trace(i);
			// is the pattern binary mask set for this digit, in which case it moved
			if (Math.pow(2,i) & pattern) {
				// it is, so add to the end of the array and up the counter
				//trace(i + ":moved " + originalString.substr(counter,1));
				movedArray.push(originalString.substr(counter++,1));
			} else {
				//trace(i + ":nothing");
			}
		}
		// You now know the 'base' point of the String, put it into the array
		//trace("base=" + counter);
		var builtArray:Array = new Array();
		//trace("start build=" + builtArray.toString());
		// now see if the rest of the string moved
		for (var i=0, j=originalString.length-1; i<originalString.length;i++, j--) {
			//trace("i=" + i + " j=" + j);
			// is the pattern binary mask set for this digit, in which case it moved
			if (Math.pow(2,j) & pattern) {
				// it is, so pick it from the moved array (at the end)
				//trace("take from moved")
				builtArray.push(movedArray.pop());
			} else {
				// it isn't so pick it from the string
				//trace("take " + originalString.substr(counter,1))
				builtArray.push(originalString.substr(counter++,1));
			}
			//trace("built=" + builtArray.toString());
		}
		builtArray.reverse();
		return builtArray.join("");
	}
	function zeroPad(value, digits):String {
		var stringValue:String = value.toString();
		while (stringValue.length < digits) {
			stringValue="0"+stringValue;
		}
		return stringValue;
	}
	function hyphenate(originalString:String, numDigits:Number) {
		var brokenArray = new Array();
		for (var i=0; i<originalString.length;i=i+numDigits){
			brokenArray.push(originalString.substr(i,numDigits));
		}
		return brokenArray.join("-");
	}
}

 */