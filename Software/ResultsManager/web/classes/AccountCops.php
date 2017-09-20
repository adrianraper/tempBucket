<?php
require_once(dirname(__FILE__)."/crypto/RSAKey.php");
require_once(dirname(__FILE__)."/crypto/Base8.php");

class AccountCops {

	var $db;
	
	private $dmsKey;
	private $orchidPublicKey;

	function AccountCops($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
		$this->contentOps = new ContentOps($db);
		$this->manageableOps = new ManageableOps($db);
		
		// These key-pairs generated by OpenSSL. DK generated 256 bit key. 
		// It seems that I can only sign text that is shorter than the modulus of the key - which is 64bits.
		// So, lets not be too literal. You could sign a MD5 version of the full string.
		//$this->dmsKey = new RSAKey("00c9be86502ec265831d104f4f0ce071490aa0b707ac5ae2ac16306ba758368ee9", "10001", "573b03364e518db4f86f21ebab44ac96443df53a07a8e75ca24dcb42be0c2d05");
		$this->dmsKey = new RSAKey("a6f945c79fa1db830591618a0178f1ec4076436bd22e2c264de61b114eb78fad", "10001", "8fe751ce63b3b95dc854ad7da51b3953811b560d00d6a1248d91cff6a2976841");
		$this->orchidPublicKey = new RSAKey("00c2053455fe3c7c7b22a629d53ab2d98a2f46a2c403457da8d044116df9ab43fb", "10001");
	}

	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
		$this->contentOps->changeDB($db);
		$this->manageableOps->changeDB($db);
	}

    // Moved from LoginOps
    public function getAccount($productCode, $prefix, $ip, $ru) {

        // gh#39 productCode might be a comma delimited list '52,53'
        if (!$productCode)
            throw $this->copyOps->getExceptionForId("errorNoProductCode");

        if ($prefix) {
            // Kind of silly, but bento is usually keyed on prefix and getAccounts always works on rootID
            // so add an extra call if you don't currently know the rootID
            $rootId = (int) $this->getAccountRootID($prefix);
            // There is no account for this prefix, so this is an error
            if (!$rootId) {
                throw $this->copyOps->getExceptionForId("errorNoPrefixForRoot", array("prefix" => $prefix));
            }
            // TODO We could do any licence control for IP and RU at this point, then no need for app to worry about it
        } else {
            // gh#315 Allow lookup for IP
            if ($ip) {
                $rootId = (int) $this->getRootIDFromIP($ip, $productCode);
            }
        }

        // #519
        if (!$rootId) {
            // You haven't found an account that matches the IP, but this is fine, you can continue with email login
            return false;
        }

        $account = $this->getBentoAccount($rootId, $productCode);
        $account->addLicenceAttributes($this->getAccountLicenceDetails($rootId, null, $productCode));

        return $account;
    }

    /**
	 * Bento specific function to getAccount details as need far less than RM and some RM bits are wrong
	 */
	function getBentoAccount($rootID, $productCode) {
		
		// gh#39 product code might be a comma delimited list. 
		// This is a small query, so no performance problems just doing the IN always.
		$sql = <<< SQL
				SELECT r.*, t.* 
				FROM T_AccountRoot r, T_Accounts t
				WHERE r.F_RootID = ?
				AND r.F_RootID = t.F_RootID
				AND t.F_ProductCode in ($productCode);
SQL;
		$bindingParams = array($rootID);
		$rs = $this->db->Execute($sql, $bindingParams);

		// gh#39 It would be an error to have more titles than the number of product codes
		$numProductCodes = substr_count($productCode, ',') + 1;
		
		// It would be an error to have more or less than one account
		// It would be an error to have more or less than one title in that account
		if ($rs->RecordCount() > $numProductCodes) {
			throw $this->copyOps->getExceptionForId("errorMultipleProductCodeInRoot", array("productCode" => $productCode));
		} else if ($rs->RecordCount() == 0) {
			throw $this->copyOps->getExceptionForId("errorNoProductCodeInRoot", array("productCode" => $productCode, "rootID" => $rootID));
		} 

		// Create the account object (just use the first record if multiple ones as they will all be the same account details)
		$dbObj = $rs->FetchObj();
		$account = new Account();
		$account->fromDatabaseObj($dbObj);

		// gh#1448 Is the account suspended?
		if ($account->accountStatus == Account::SUSPENDED)
            throw $this->copyOps->getExceptionForId("errorAccountSuspended");

		// gh#39 You might have multiple matching titles
		while ($dbObj = $rs->FetchNextObj()) {
            $title = new Title();
            $title->fromDatabaseObj($dbObj);

            // gh#1404 Is the checksum valid for this account?
            if (!$this->_validateChecksum($title, $account))
                throw $this->copyOps->getExceptionForId("errorTitleCorrupted", array("productCode" => $productCode));

            $account->addTitles(array($title));
		}
				
		return $account;
	}

    /**
     * Get the licence attributes for an account.
     * v4.0 Allow productCode to be optionally specified
     */
    function getAccountLicenceDetails($accountID, $config=null, $productCode=null) {

        // Can I delay doing this until I want to edit an account? It is pretty rare anyway.
        $licenceAttributes = $this->db->GetArray("SELECT F_Key licenceKey, F_Value licenceValue, F_ProductCode productCode FROM T_LicenceAttributes WHERE F_RootID=?", array($accountID));
        if ($productCode && $licenceAttributes && count($licenceAttributes>0)) {
            $relevantAttributes = array();
            // If you set the productCode, then it means you want all null values, and any value that includes your pc in the list
            // I think this is going to be simplest to do post query.
            foreach ($licenceAttributes as $detail) {
                if ($detail['productCode']=='') {
                    $relevantAttributes[] = $detail;
                } else {
                    $codes = explode(',',$detail['productCode']);
                    foreach ($codes as $code) {
                        if ($code==$productCode) {
                            $relevantAttributes[] = $detail;
                            break;
                        }
                    }
                }
            }
        } else {
            $relevantAttributes = $licenceAttributes;
        }
        return $relevantAttributes;
    }

    /**
     * Go through all the titles in the account generating the checksum for each of them
     */
    public function generateChecksumForTitle($title, $account) {
        // Note that the encoded hash ($m) must be <= to length of n in hex (32)
        // We want to protect the
        // 	institution name (from T_AccountRoot)
        //	hosting domain (need to add to T_AccountRoot) -- but what would this be for network? Just empty I suppose.
        //	expiry date
        //	maxStudents
        //	licenceType
        //	rootID
        //	productCode
        $protectedString = $account->name.$title->expiryDate.$title->maxStudents.$title->licenceType.$account->id.$title->productCode;
        $escapedString = $this->actionscriptEscape($protectedString);

        // v6.5.5.5 because php and javascript do md5 differently, we need to escape first
        $hash = md5($escapedString);

        // Encode and sign the hash
        $m = Base8::encode($hash);
        $c = $this->dmsKey->sign($m);
        $c = $this->orchidPublicKey->encrypt($c);

        return $c;
    }
    // gh#1404 Decode a checksum to validate it
    private function _validateChecksum($title, $account) {
        //AbstractService::$debugLog->info("checksum is ".$this->generateChecksumForTitle($title, $account)." compare against ".$title->checksum);
        return (strtolower($title->checksum) == strtolower($this->generateChecksumForTitle($title, $account)));
    }

	public function getAccountFromPrefix($prefix) {

        $rootID = $this->getAccountRootID($prefix);

		// now get the account (just one)
		if ($rootID)
			return array_shift($this->getAccounts(array($rootID)));

        return null;
	}
	
	/**
	 * gh#315 Is there an account linked to an IP in the licence attributes?
	 */
	public function getRootIDFromIP($ip, $productCode = null) {
		// You can match against a complete IP like this:
		//		AND l.F_Value like '%$ip%'
		// But since many are ranges we have to do that in a php loop I think - or could a regex cope?
		$sql = 	<<<EOD
				SELECT l.F_RootID as rootID, l.F_Value as ranges
				FROM T_LicenceAttributes l
				WHERE l.F_Key = 'IPrange'
EOD;
		// gh#723
        // gh#1176 add this link to product code back again
		if ($productCode)
            $sql .= " AND (l.F_ProductCode in ($productCode) OR l.F_ProductCode is null)";

		$rs = $this->db->Execute($sql);
		
		$foundRoots = array();
		if ($rs->RecordCount() > 0) {
			while ($rsObj = $rs->FetchNextObj()) {
				// now simple check to see if the passed ip is in this range
				if ($this->isIPInRange($ip, $rsObj->ranges))
					$foundRoots[] = $rsObj->rootID;
			}
			$foundRoots = array_unique($foundRoots);
		}
		
		switch (count($foundRoots)) {
			case 0:
				// No such account, quite fine
				return false;
				break;
			case 1:
				// One record, good. Pick up the root
				$rootID = $foundRoots[0];
				break;
			default:
				// Many records means we can't know which root this user belongs to, raise an error
				throw $this->copyOps->getExceptionForId("errorMultipleIPMatches", array("ip" => $ip));
		}
		
		return $rootID;
	}
	/*
	 * Will check if a single, full defined IP matches any range in a list
	 */
	private function isIPInRange($ip, $ipRangeList) {
	 	$ipRangeArray = explode(',', $ipRangeList);
		foreach ($ipRangeArray as $ipRange) {
			$ipRange = trim($ipRange);
			
			// loop through the ip addresses you are running from
		 	$myIpArray = explode(',', $ip);
			foreach ($myIpArray as $myIp) {
				$myIp = trim($myIp);

				// first, is there an exact match?
				if ($myIp == $ipRange)
					return true;
				
				// or does it fall in the range? 
				// assume nnn.nnn.nnn.x-y or nnn.nnn.x-y
				$targetBlocks = explode('.',$ipRange);
				$thisBlocks = explode(".",$myIp);
				// how far down do they specify?
				for ($i=0; $i<count($targetBlocks); $i++) {
					// echo "match ".$thisBlocks[$i]." against ".$targetBlocks[$i]."<br/>";
					if ($targetBlocks[$i] == $thisBlocks[$i]) {
					} else if (strpos($targetBlocks[$i], '-') !== FALSE) {
						$targetArray = explode('-',$targetBlocks[$i]);
						$targetStart = (int) $targetArray[0];
						$targetEnd = (int) $targetArray[1];
						$thisDetail = (int) $thisBlocks[$i];
						// gh#1564 if a pattern has two ranges, matching the first then ignores the second
                        // which means that 192.168.8-10.0-32 would match 192.168.8.64
                        // But there are NO examples of this, the second range is only ever 0-255
						if ($targetStart <= $thisDetail && $thisDetail <= $targetEnd) {
							return true;
						//gh#1564 if a pattern has a range, not matching it is fatal
						} else {
						    break;
                        }

					} else {
						//myTrace("no match between " + targetBlocks[i] + " and " + thisBlocks[i]);
						break;
					}
				}
			}
		}
		return false;
	}
	
	/**
	 * Get an account when you know the user
	 */
	public function getAccountFromUser($user) {
		$sql = 	<<<EOD
				SELECT m.F_RootID as rootID
				FROM T_Membership m
				WHERE m.F_UserID = ?
				WHERE m.F_UserID = ?
EOD;
		$rs = $this->db->Execute($sql, array($user->id));
		
		switch ($rs->RecordCount()) {
			case 0:
				// No membership record, should be impossible
				return false;
				break;
			case 1:
				// One record, good. Send back the root
				$rootID = $rs->FetchNextObj()->rootID;
				break;
			default:
				// Many records means we can't know which root this user belongs to, raise an error
				return false;
		}
		
		// now get the account (just one)
		$accounts = $this->getAccounts(array($rootID));
		return array_shift($accounts);
	}
	
	/*
	 * Utility function to get the rootID for a particular prefix
	 */
	public function getAccountRootID($prefix) {
		$lowerCasePrefix = strtolower($prefix);
		$sql = 	<<<EOD
				SELECT F_RootID AS rootID 
				FROM T_AccountRoot
				WHERE LOWER(F_Prefix)='$lowerCasePrefix'
EOD;
		$rs = $this->db->Execute($sql);
		if ($rs) {
			if ($rs->RecordCount() <= 0) {
				$logMessage = 'prefix error 0 record';
				AbstractService::$debugLog->err($logMessage);
			} else {
				return $rs->FetchNextObj()->rootID;
			}
		} else {
			$logMessage = 'prefix error sql, err='.$this->db->ErrorMsg();
			AbstractService::$debugLog->err($logMessage);
		}
	}
	/*
	 * Used by couloir
	 */
	public function getLicenceDetails($rootId, $productCode) {
        $sql = 	<<<EOD
				SELECT * FROM T_Accounts
				WHERE F_RootID=?
				AND F_ProductCode=?
EOD;
        $rs = $this->db->Execute($sql, array($rootId, $productCode));
        if ($rs) {
            $licence = new Licence();
            $licence->fromDbRecordset($rs->FetchNextObj());
            return $licence;
        }
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
