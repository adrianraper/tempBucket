<?php
require_once(dirname(__FILE__)."/SelectBuilder.php");
require_once(dirname(__FILE__)."/crypto/RSAKey.php");
require_once(dirname(__FILE__)."/crypto/Base8.php");

$mypostfix = $neg_mypostfix = "";
for($i=0;$i<10;++$i) {
	if($i > 0) {
		$mypostfix .= ' AND';
		$neg_mypostfix .= ' OR';
	}
	$mypostfix .= " F_Prefix NOT LIKE '$i%'";
	$neg_mypostfix .= " F_Prefix LIKE '$i%'";
}

for($i=0;$i<10;++$i) {
	$mypostfix .= " AND F_Prefix NOT LIKE '_$i%'";
	$neg_mypostfix .= " OR F_Prefix LIKE '_$i%'";
}

DEFINE('MYPOSTFIX', $mypostfix);
DEFINE('NEG_MYPOSTFIX', $neg_mypostfix);

class AccountOps {

	var $db;
	
	private $dmsKey;
	private $orchidPublicKey;

	function AccountOps($db) {
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
	 * Get the accounts.  If $accountIDArray is specified then only get those accounts, otherwise get them all.
	 * If onExpiryDate is specified then only accounts expiring on that day will be found.
	 * AR v3.1 This needs to be extended to get accounts based on lots of different criteria, not just expiryDate.
	 * Which must be similar to search I suppose. Except that that is all done by filtering on a dataGrid.
	 * So I need to use something like SelectBuilder and a set of conditions set in an array.
	 */
	//function getAccounts($accountIDArray = null, $onExpiryDate = null) {
	function getAccounts($accountIDArray = null, $conditions = null, $sortOrder = null) {

		// Get each account root that has at least one account expiring on this date
		// This SQL is written to return a row for each title in the accounts. I think this is wrong, it
		// should return only those titles that match the conditions.
		// Also changed so that we only get distinct roots back from this call.
		//$sql  = "SELECT ".Account::getSelectFields($this->db)." ";
		$selectBuilder = new SelectBuilder();	
		$needsAccountsTable = false;
		
		//$where = array();
		
		// Uncomment this line to only display accounts beginning with the letter A - makes it faster to developer :)
		//if (isset($_SESSION['justClarity'])) {
		//	$selectBuilder->addWhere('F_Name LIKE \'Clarity%\'');
		//}
		// If I don't want to see any accounts created by online subscription - filter on prefix (get rid of numeric ones)
		//NetDebug::trace("GLOBALS['onlineSubs']=".$GLOBALS['onlineSubs']);
		// Let this be a DMS interface switch
		//if ($GLOBALS['onlineSubs']) {
		//	$selectBuilder->addWhere('F_Prefix NOT LIKE \'%[^0-9]%\'');
		//} else {
		//	$selectBuilder->addWhere('F_Prefix LIKE \'%[^0-9]%\'');
		//}
		//$accountIDArray = array(13292, 13293, 13294);
		if ($accountIDArray)
			//$where[] = "F_RootID IN (".join($accountIDArray, ",").")";
			$selectBuilder->addWhere("a.F_RootID IN (".join($accountIDArray, ",").")");
		
		if (sizeof($conditions) > 0) {
			foreach ($conditions as $condition => $value) {
				//NetDebug::trace("condition=$condition=$value");
				//echo "condition=$condition=$value<br/>";
				switch ($condition) {
					case 'individuals':
						if ($value == 'true') {
							$selectBuilder->addWhere(NEG_MYPOSTFIX);
						} else {
							$selectBuilder->addWhere(MYPOSTFIX);
						}
						break;
					case 'expiryDate':
						//echo "expiryDate set to $value";
						//$where[] = "t.F_ExpiryDate = '".$onExpiryDate."'";
						// v3.3 Problem here in that expiry date in the db contains a time, whereas the value I am passing doesn't
						// I can either add '23:59:59' to the end on teh grounds that this is when all accounts should end
						// Or I can do a double condition to cover all day.
						// TODO: I think that MySQL wants DATE_ADD as the function name. adodb will surely help me.
						//	$selectBuilder->addWhere("t.F_ExpiryDate < DATEADD(Day,1,'".$value."')");
						// Or do it like this:
						if ($value != null) {
							$selectBuilder->addWhere("t.F_ExpiryDate >= '".substr($value,0,10)." 00:00:00'");
							$selectBuilder->addWhere("t.F_ExpiryDate <= '".substr($value,0,10)." 23:59:59'");
							$needsAccountsTable = true;
						}
						break;
					case 'licenceType':
						$selectBuilder->addWhere("t.F_LicenceType = '".$value."'");
						$needsAccountsTable = true;
						break;
					// v3.3 If I find I want this a lot, it would be better to build a general not function for all conditions
					case 'notLicenceType':
						$selectBuilder->addWhere("NOT t.F_LicenceType = '".$value."'");
						$needsAccountsTable = true;
						break;
					case 'accountType':
						$selectBuilder->addWhere("a.F_AccountType = '".$value."'");
						break;
					case 'accountStatus':
						$selectBuilder->addWhere("a.F_AccountStatus = '".$value."'");
						break;
					case 'productCode':
						// Note that this doesn't just find accounts that have this product, it ONLY returns this product in the accounts
						$selectBuilder->addWhere("t.F_ProductCode = '".$value."'");
						$needsAccountsTable = true;
						break;
					// v3.4.3 This is a boolean - should it be string enclosed?
					case 'selfHost':
						$selectBuilder->addWhere("a.F_SelfHost = '".$value."'");
						break;
					case 'deliveryFrequency':
						$selectBuilder->addWhere("t.F_DeliveryFrequency = '".$value."'");
						$needsAccountsTable = true;
						break;
					case 'active':
						if ($value == 'true') {
							$now = date('Y-m-d');
							$selectBuilder->addWhere("t.F_ExpiryDate >= '$now 00:00:00'");
							$needsAccountsTable = true;
						}
						break;
					// v3.5 Flexibility of email triggers. Ignore accounts that have opted out, for a while.
					case 'optOutEmails':
						$now = date('Y-m-d');
						$selectBuilder->addWhere("a.F_OptOutEmails = 0", true);
						$selectBuilder->addWhere("(a.F_OptOutEmails = 1 AND a.F_OptOutEmailDate < '$now 00:00:00')", true);
						$needsAccountsTable = true;
						break;
					// v3.6 Early Warning System
					case 'reseller':
						$selectBuilder->addWhere("a.F_ResellerCode IN (".join($value, ",").")");
						break;
					// v3.5 Subscription reminders need start date for first few emails - and they are only based on RM
					case 'startDate':
						//echo "startDate set to $value";
						if ($value != null) {
							$selectBuilder->addWhere("t.F_LicenceStartDate >= '".substr($value,0,10)." 00:00:00'");
							$selectBuilder->addWhere("t.F_LicenceStartDate <= '".substr($value,0,10)." 23:59:59'");
							$selectBuilder->addWhere("t.F_ProductCode=2");
							$needsAccountsTable = true;
						}
						break;
					// When you have a recurring day part of the date - also only applies to RM
					case 'startDay':
						//echo "startDay set to $value ";
						if ($value != null) {
							// Tested with MySQL, but not with SQLServer, though it should work
							//$selectBuilder->addWhere("DAYOFMONTH(t.F_LicenceStartDate) = $value");
							$buildDateString = $this->db->SQLDate('d','t.F_LicenceStartDate');
							$selectBuilder->addWhere("$buildDateString = $value");
							$selectBuilder->addWhere("t.F_ProductCode=2");
							$needsAccountsTable = true;
						}
						break;
				}
			}
		}
		// Build the from part
		//$sql  = "SELECT DISTINCT (a.F_RootID),".Account::getSelectFields($this->db)." ";
		$selectBuilder->addSelect('DISTINCT (a.F_RootID)');
		$selectBuilder->addSelect(Account::getSelectFields($this->db));
		//$sql .= "FROM T_AccountRoot a ";	
		$sqlFrom = "T_AccountRoot a ";	
		// Special handling for conditions that involve linking to other tables
		// If date ranges are defined then only get accounts with titles within that date range
		// This necessitates joining to the T_Accounts table. 
		// As does licenceType...
		if ($needsAccountsTable) $sqlFrom .= "LEFT JOIN T_Accounts t ON a.F_RootID=t.F_RootID ";
		$selectBuilder->setFrom($sqlFrom);
		
		//if (sizeof($where) > 0)
		//	$sql .= "WHERE ".implode(" AND ", $where)." ";
		
		// v3.4.3 Why wouldn't you order by root anyway?
		//if (!$accountIDArray) {
			//$sql .= "ORDER BY a.F_RootID DESC";
			//$sql .= "ORDER BY a.F_Name";
			// v3.4 Turns out that alphabetic isn't a great default order. For any kind of automated scripts
			// we need to order by root so we can start and stop at a particular place.
			//$selectBuilder->addOrder('a.F_Name');
			//$selectBuilder->addOrder('a.F_RootID');
			// You can choose other sort orders, such as expiry date
			//$selectBuilder->addSelect('t.F_ExpiryDate');
			//$selectBuilder->addOrder('t.F_ExpiryDate');
		//}
		if ($sortOrder==null) {
			$sortOrder = array('default');
		}
		foreach ($sortOrder as $order) {
			//NetDebug::trace("condition=$condition=$value");
			switch ($order) {
				case 'name':
					$selectBuilder->addOrder('a.F_Name');
					break;
				case 'expiryDate':
					$selectBuilder->addSelect('t.F_ExpiryDate');
					$selectBuilder->addOrder('t.F_ExpiryDate');
					break;
				default:
					$selectBuilder->addOrder('a.F_RootID');
			}
		}
			
		// Perform the query and create an array of Account objects from the results
		//echo "db=".$GLOBALS['db']."<br/>"; 
		//echo $selectBuilder->toSQL()."<br/>"; // exit(0);
		//NetDebug::trace("sql=".$selectBuilder->toSQL());

		//throw new Exception($selectBuilder->toSQL());
		$sql = $selectBuilder->toSQL();
		//echo $sql;
		//$accountsRS = $this->db->Execute($selectBuilder->toSQL($sql)); 
		$accountsRS = $this->db->Execute($sql); 
		//NetDebug::trace("accounts=".$accountsRS->RecordCount());
		//echo "accounts=".$accountsRS->RecordCount();
		$result = array();
		
		if ($accountsRS->RecordCount() > 0) {
			while ($accountObj = $accountsRS->FetchNextObj()) {
				// Create the account object
				$account = $this->_createAccountFromObj($accountObj);
				
				// v3.3. Just to prevent warnings
				if (!isset($conditions['productCode'])) $conditions['productCode'] = null;
				if (!isset($conditions['expiryDate'])) $conditions['expiryDate'] = null;
				// Add the titles for this account (based on expiry date if desired)
				// Or should I get back all titles - which would be better for subscription reminders
				//$account->addTitles($this->contentOps->getTitles($account->id, $onExpiryDate));
				// v3.3 Confirm - we want all titles back, not just expiring ones. The reminder email can sort it out.
				//$account->addTitles($this->contentOps->getTitles($account->id, $conditions['expiryDate'], $conditions['productCode']));
				$account->addTitles($this->contentOps->getTitles($account->id, null, $conditions['productCode']));
				//$account->addTitles($this->contentOps->getTitles($account->id));
				
				// Get the admin user (if there is one) for this account and add it into the object
				if ($account->getAdminUserID()) {
					$account->adminUser = $this->manageableOps->getUserById($account->getAdminUserID());
				}
				
				// Get the licence attributes and add them them into the object
				// TODO this is a very slow call - about 14s from 500 accounts. Why?
				// Can I delay doing this until I want to edit an account? It is pretty rare anyway.
				//$account->licenceAttributes = $this->db->GetArray("SELECT F_Key licenceKey, F_Value licenceValue, F_ProductCode productCode FROM T_LicenceAttributes WHERE F_RootID=?", array($account->id));
				
				$result[] = $account;
			}
		}
		
		return $result;
	}
	
	/**
	 * Get the licence attributes for an account.
	 * v4.0 Allow productCode to be optionally specified 
	 */
	function getAccountLicenceDetails($accountID, $productCode=null) {
		
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
					$codes = implode(',',$detail['productCode']);
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
	 * This method returns the following dictionary dataProviders (for mapping ids to names):
	 * - accountStatus
	 * - approvalStatus
	 * - resellers
	 * - termsConditions
	 * - products
	 * - licenceTypes
	 */
	function getDictionary($dictionaryName) {
		//NetDebug::trace('AccountOps.getDictionary='.$dictionaryName);
		switch ($dictionaryName) {
			case "accountStatus":
				$result = $this->db->GetArray("SELECT F_Status data, F_Description label FROM T_AccountStatus");
				break;
			// v3.0.5 Change status handling
			//case "approvalStatus":
			//	return $this->db->GetArray("SELECT F_Status data, F_Description label FROM T_ApprovalStatus");
			case "accountType":
				$result = $this->db->GetArray("SELECT F_Type data, F_Description label FROM T_AccountType");
				break;
			case "resellers":
				$result = $this->db->GetArray("SELECT F_ResellerID data, F_ResellerName label FROM T_Reseller order by F_DisplayOrder");
				break;
			case "termsConditions":
				$result = $this->db->GetArray("SELECT F_Status data, F_Description label FROM T_TermsConditions");
				break;
			case "products":
				// v3.3 Drop DefaultContentLocation from here - move to T_ProductLangauge
				//return $this->db->GetArray("SELECT F_ProductCode data, F_ProductName label, F_DefaultContentLocation defaultContentLocation 
				//$result = $this->db->GetArray("SELECT F_ProductCode data, F_ProductName label FROM T_Product");
				$result = $this->db->GetArray("SELECT F_ProductCode data, F_ProductName label FROM T_Product order by F_DisplayOrder");
				break;
			case "licenceType":
				$result = $this->db->GetArray("SELECT F_Status data, F_Description label FROM T_LicenceType");
				break;
			// v3.3 What I am really interested in is the languages that a particular title can use
			//case "languageCode":
			//	return $this->db->GetArray("SELECT F_LanguageCode data, F_Description label FROM T_Language");
			case "languageCode":
				$sql = <<< EOD
					SELECT P.F_LanguageCode data, L.F_Description label, P.F_ProductCode productCode
					FROM T_Language L, T_ProductLanguage P
					WHERE P.F_LanguageCode = L.F_LanguageCode
					ORDER BY P.F_ProductCode
EOD;
				return $this->db->GetArray($sql);
			default:
				throw new Exception("Unknown dictionary name '".$dictionaryName."'");
		}
		
		// as mysql result return only string no matter what the types defined in the database
		// manual conversion is done here
		for($i=0;$i<count($result);++$i) {
			$result[$i]['data'] = intval($result[$i]['data']);
		}
		return $result;
		
	}
	// Similarly to the dictionary, I want to be able to get the reseller email based on their ID
	function getResellerEmail($id) {
		$sql = <<< EOD
				SELECT *
				FROM T_Reseller
				WHERE F_ResellerID = $id
EOD;
		$rs = $this->db->Execute($sql);	
		if ($rs)
			return $rs->FetchNextObj()->F_Email;
	}
	
	function addAccount($account) {
		if (!$this->isAccountValid($account))
			// This account cannot be added (probably because it does not have a unique prefix)
			throw new Exception($this->copyOps->getCopyForId("prefixExistsError", array("prefix" => $account->prefix)));
		
		$this->db->StartTrans();
				
		// Create an entry in account root
		$this->db->AutoExecute("T_AccountRoot", $account->toAssocArray(), "INSERT");
		
		// Set the root id
		$account->id = $this->db->Insert_ID();
		//echo "new root=$account->id"."<br/>";
		
		// Now update the titles within the account
		// vCLS It is possible you are adding an account with no titles (because you will add the titles later)
		if (count($account->titles)>0) {
			$this->updateAccountTitles($account);
		}
		
		// If an admin user is specified (as it always will be except with self-hosted accounts) then create a group and user
		if ($account->adminUser) {
			// Create and add a new group
			$group = new Group();
			$group->name = $account->name;
			$group = $this->manageableOps->addGroup($group);
			//echo "added group $group->id to root $account->id"."<br/>";
			
			// Create a new user, add them to the group then update adminUserID in $account with the newly added user id
			$adminUser = $this->manageableOps->addUser($account->adminUser, $group, $account->id);
			//echo "added user {$account->adminUser->id}"."<br/>";
			
			// Update the adminUserID field in the database to point at the newly created user
			// v3.4 Multi-group users
			//$this->db->Execute("UPDATE T_AccountRoot SET F_AdminUserID=? WHERE F_RootID=?", array($adminUser->id, $account->id));
			$this->db->Execute("UPDATE T_AccountRoot SET F_AdminUserID=? WHERE F_RootID=?", array($adminUser->userID, $account->id));
			AbstractService::$log->setRootID($account->id);
			// v3.4 Multi-group users
			//AbstractService::$log->notice("Created group name=".$account->name.", id=".$group->id.", and user name=".$account->adminUser->name.", id=".$account->adminUser->id);
			AbstractService::$log->notice("Created group name=".$account->name.", id=".$group->id.", and user name=".$account->adminUser->name.", id=".$account->adminUser->userID);
		}
		// v3.2 This was not added for new accounts. Generally it is not set for new accounts.
		if (isset($account->licenceAttributes)) {
			foreach ($account->licenceAttributes as $licenceAttribute) {
				$dbObj = array();
				$dbObj['F_RootID'] = $account->id;
				$dbObj['F_Key'] = $licenceAttribute['licenceKey'];
				$dbObj['F_Value'] = $licenceAttribute['licenceValue'];
				if ($licenceAttribute['productCode'] > 0) $dbObj['F_ProductCode'] = $licenceAttribute['productCode'];
				//NetDebug::trace('AccountOps.licenceAttribute insert '.$dbObj['F_Key'].'='.$dbObj['F_Value'].':'.$dbObj['F_ProductCode']);
				$this->db->AutoExecute("T_LicenceAttributes", $dbObj, "INSERT");
			}
		}
			
		// make the root of the changed account explicit in the log
		AbstractService::$log->setRootID($account->id);
		AbstractService::$log->notice("Created account name=".$account->name.", id=".$account->id);
		
		$this->db->CompleteTrans();
	}
	
	/**
	 * Update the given array of accounts in the database
	 * 
	 * @param accountsArray An array of Account objects
	 */
	function updateAccounts($accountsArray) {
		$this->db->StartTrans();
		
		foreach ($accountsArray as $account) {
			if (!$this->isAccountValid($account))
				// This account cannot be added (probably because it does not have a unique prefix)
				throw new Exception($this->copyOps->getCopyForId("prefixExistsError", array("prefix" => $account->prefix)));

			// First update the account root. This is failing because the account object has no loginOption.
			// getAccounts is sending back loginOption to DMS though. Seems we have to include it in the DetailsPane.
			//NetDebug::trace('AccountOps.updateAccounts loginOption='.$account->loginOption);
			$this->db->AutoExecute("T_AccountRoot", $account->toAssocArray(), "UPDATE", "F_RootID=".$account->id);
			
			// Then update the titles within the account
			$this->updateAccountTitles($account);
			
			// Update the admin user object if it exists
			if ($account->adminUser) $this->manageableOps->updateUsers(array($account->adminUser), $account->id);
			
			// Finally delete the licence attributes
			$this->db->Execute("DELETE FROM T_LicenceAttributes WHERE F_RootID=?", array($account->id));
			
			foreach ($account->licenceAttributes as $licenceAttribute) {
				$dbObj = array();
				$dbObj['F_RootID'] = $account->id;
				$dbObj['F_Key'] = $licenceAttribute['licenceKey'];
				$dbObj['F_Value'] = $licenceAttribute['licenceValue'];
				if ($licenceAttribute['productCode'] > 0) $dbObj['F_ProductCode'] = $licenceAttribute['productCode'];
				//NetDebug::trace('AccountOps.licenceAttribute insert '.$dbObj['F_Key'].'='.$dbObj['F_Value'].':'.$dbObj['F_ProductCode']);
				$this->db->AutoExecute("T_LicenceAttributes", $dbObj, "INSERT");
			}
		}
		
		// make the root of the changed account explicit in the log
		AbstractService::$log->setRootID($account->id);
		AbstractService::$log->notice("Updated account name=".$account->name.", id=".$account->id);
		
		$this->db->CompleteTrans();
	}
	
	function deleteAccounts($accountsArray) {
		$this->db->StartTrans();
		
		foreach ($accountsArray as $account) {
			//NetDebug::trace('AccountOps.deleteAccounts adminid='.$account->adminUser->id);
			if ($account->adminUser) {
				// Get the id of the top level group for this account
				// v3.4 Multi-group users
				//$rootGroupID = $this->manageableOps->getGroupIdForUserId($account->adminUser->id);
				$rootGroupID = $this->manageableOps->getGroupIdForUserId($account->adminUser->userID);
				//NetDebug::trace('AccountOps.deleteAccounts groupid='.$rootGroupID);
				
				// Get the managables for the top level group
				$group = $this->manageableOps->getManageables(array($rootGroupID), false);
				
				// Delete it (this will delete all sub users and groups including the admin user)
				// v3.0.6 But this fails... It is because getManageables already returns an array.
				//$this->manageableOps->deleteManageables(array($group));
				$this->manageableOps->deleteManageables($group);
				// Can I see what I have got for my manageables? Yes, Charles will show this.
				//return $group;
			}
			
			// Delete the titles associated with the root id
			$this->db->Execute("DELETE FROM T_Accounts WHERE F_RootID=?", array($account->id));
			
			// Delete any licence attributes
			$this->db->Execute("DELETE FROM T_LicenceAttributes WHERE F_RootID=?", array($account->id));
			
			// And finally delete the account itself
			$this->db->Execute("DELETE FROM T_AccountRoot WHERE F_RootID=?", array($account->id));
		}
		
		// make the root of the changed account explicit in the log
		AbstractService::$log->setRootID($account->id);
		AbstractService::$log->notice("Deleted account name=".$account->name.", id=".$account->id);
		
		$this->db->CompleteTrans();
	}
	
	/**
	 * Given an account object this deletes and then recreates all entries in T_Account for that account.  Used by add and update accounts.
	 */
	private function updateAccountTitles($account) {
	
		// v3.3 Can I do a validity check on the titles first?
		// For instance, the languageCode must be filled in
		// Then add in the new/updated titles
		foreach ($account->titles as $title) {
			if (!$this->isTitleValid($title))
				throw new Exception($this->copyOps->getCopyForId("mismatchedLanguageCode", array("productCode" => $title->productCode, "languageCode" => $title->languageCode)));
		}		
		// First delete any titles currently associated with this account
		//echo "updateAccountTitles for $account->id"."<br/>";
		$this->db->Execute("DELETE FROM T_Accounts WHERE F_RootID=?", array($account->id));
		
		$allLicencesAA = true;
		// Then add in the new/updated titles
		foreach ($account->titles as $title) {
			$titleArray = $title->toAssocArray();
			// v3.3 Before you create the checksum, make sure that the expiry date has been altered to 23:59:59
			$title->expiryDate = substr($title->expiryDate,0,10).' 23:59:59';
			$title->licenceStartDate = substr($title->licenceStartDate, 0, 10).' 00:00:00';
			
			$titleArray["F_RootID"] = $account->id;
			$titleArray["F_Checksum"] = $this->generateChecksumForTitle($title, $account);
			//NetDebug::trace("root=".$account->id." productCode=".$title->productCode." checksum=".$titleArray["F_Checksum"]);
			$this->db->AutoExecute("T_Accounts", $titleArray, "INSERT");
			
			// v3.0.6 We need to create an Author Plus folder, if they are adding AP for the first time, and this is not self-hosted
			if ($title->productCode == 1 && !$account->selfHost) {
				// v3.5 Now dbContentLocation is tied to the field in DMS and is the direct database link
				//$thisContentLocation = $this->contentOps->getContentFolder($title->contentLocation, $title->productCode);
				$thisContentLocation = $this->contentOps->getContentFolder($title->dbContentLocation, $title->productCode);
				//NetDebug::trace('AccountOps.addAccount AuthorPlus folder='.$thisContentLocation);
				if (!is_dir($thisContentLocation)) {
					// v4.3 I sometimes get error suggesting that copy(../../../../../ap/../ap/templates_empty/course.xml) doesn't exist.
					// Is this path wrong here, or some strange data thing? I only see it on claritymain. I think it is wrong.
					//$emptyTemplate = $this->contentOps->getContentFolder("../ap/templates_empty", $title->productCode);
					$emptyTemplate = $this->contentOps->getContentFolder("templates_empty", $title->productCode);
					//NetDebug::trace('AccountOps.addAccount need to create the folder');
					// it doesn't exist, so create it
					mkdir($thisContentLocation, 0777);
					// Do we need to add any files to it, or are they created on first entry by Authoring?
					// Create a Courses folder and an empty course.xml
					mkdir($thisContentLocation."/Courses", 0777);
					if (!copy($emptyTemplate."/course.xml", $thisContentLocation."/course.xml")) {
						//NetDebug::trace('AccountOps.addAccount failed to copy '.$emptyTemplate.'/course.xml');
					}
					AbstractService::$log->setRootID($account->id);
					AbstractService::$log->notice("Created ap folder=".$thisContentLocation);
				}
			}
			// v3.0.6 For any AA licences, add action=anonymous to the licence attributes, with a specific product code
			// Actually, no need as Orchid will automatically set AA licence to action=anonymous if nothing else is set.
			if ($title->licenceType == 2) {
				/*
				// We need to make sure we don't have this combination already to avoid duplicates, or indeed overwrite any 'action'
				$noDuplicates = true;
				foreach($account->licenceAttributes as $licenceRow) {
					//NetDebug::trace('AccountOps.licenceAttribute '.$licenceRow['licenceKey'].'='.$licenceRow['licenceValue'].':'.$licenceRow['productCode']);
					if ($licenceRow['licenceKey'] == 'action' && $licenceRow['productCode'] == $title-> productCode) {
						$noDuplicates = false;
						// update this row as we won't add a new one
						$licenceRow['licenceValue'] = 'anonymous';
						break;
					}
				}
				if ($noDuplicates) {
					NetDebug::trace('AccountOps.licenceAttribute add action=anonymous for '.$title-> productCode);
					$account->licenceAttributes[] = array( 'licenceKey' => 'action', 
														'licenceValue' => 'anonymous', 
														'productCode' => $title-> productCode );
				}
				*/
			} else {
				$allLicencesAA = false;
			}
		}
		// v3.0.6 If all the titles are AA licences, CE.com/shared will the portal they use for access.
		// This is signalled by adding 128 to the loginOption.
		//NetDebug::trace('AccountOps.updateAccounts original F_LoginOption='.$account->loginOption);
		if ($allLicencesAA) {
			$account->loginOption = $account->loginOption | 128; // make sure 128 is set
		} else {
			$account->loginOption = ($account->loginOption | 128) ^ 128; // make sure 128 is not set
		}
		//NetDebug::trace('AccountOps.updateAccounts allAA='.$allLicencesAA.' so set F_LoginOption='.$account->loginOption);
		$this->db->Execute("UPDATE T_AccountRoot SET F_LoginOption=? WHERE F_RootID=?", array($account->loginOption, $account->id));
		//echo "updatedAccountTitles"."<br/>";
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
		//$protectedString = $account->name.$account->selfHostDomain.$title-> expiryDate.$title-> maxStudents.$title-> licenceType.$account->id.$title-> productCode;
		$protectedString = $account->name.$title-> expiryDate.$title-> maxStudents.$title-> licenceType.$account->id.$title-> productCode;
		$escapedString = $this->actionscriptEscape($protectedString);
		//$protectedString = "adrian raper's college of languagehttp://www.clarityenglish.com2009-12-10153138";

		//NetDebug::trace("checksum protected=$protectedString");
		//NetDebug::trace("escaped=$escapedString");
		// v6.5.5.5 because php and actionscript do md5 differently, we need to escape first
		$hash = md5($escapedString);
		//NetDebug::trace("hash=$hash");
		
		// Encode and sign the hash
		$m = Base8::encode($hash);
		//NetDebug::trace("checksum m=$m");
		$c = $this->dmsKey->sign($m);
		//NetDebug::trace("checksum c=$c");
		$c = $this->orchidPublicKey->encrypt($c);
		//NetDebug::trace("checksum=$c");
		//echo "checksum c=$c";
		
		return $c;
	}
	/*
	 * This reads all the email addresses for this account who are registered to receive this type of message
	 */
	public function getEmailsForMessageType($rootID, $msgType = null) {
		// If you don't pass a msgType, return all emails
		$bindingParams = array($rootID);
		// Remember that the admin email is NOT stored here, you have to get that from T_User
		$sql = "SELECT u.F_Email FROM T_User u, T_AccountRoot a WHERE a.F_RootID=? AND u.F_UserID = a.F_AdminUserID";
		$rs = $this->db->Execute($sql, $bindingParams); 
		if ($rs)
			$adminUserEmail = $rs->FetchNextObj()->F_Email;
			
		// msgType from the table is sequential, but used as a binary flag in RM
		if (!is_null($msgType) && is_numeric(intval($msgType))) {
			$msgTypeFlag = pow(2,$msgType-1);
		}
		$sql = "SELECT F_Email, F_AdminUser FROM T_AccountEmails WHERE F_RootID=?";
		if (!is_null($msgType) && is_numeric(intval($msgType))) {
			$sql .= " AND F_MessageType&?";
			$bindingParams[] = intval($msgTypeFlag);
		}
		$accountsRS = $this->db->Execute($sql, $bindingParams); 
		$result = array();
		if ($accountsRS->RecordCount() > 0) {
			while ($emailObj = $accountsRS->FetchNextObj()) {
				if ($emailObj->F_AdminUser) {
					$result[] = $adminUserEmail;
				} else {
					$result[] = $emailObj->F_Email;
				}
			}
		}
		return $result;
	}
	
	/*
	 * This is a simple version of ActionScript escape function
	 */
	private function actionscriptEscape($text) {
		$needles = array('_','-','.');
		$replaces = array('%5F','%2D','%2E');
		return str_replace($needles,$replaces,rawurlencode($text));
	}
	
	/*
	 * This method creates a new Account from an AdoDB object returned by FetchNextObject()
	 */
	private function _createAccountFromObj($accountObj) {
		$account = new Account();
		$account->fromDatabaseObj($accountObj);
		return $account;
	}
	
	/**
	 * Determine if an account is valid.  An account is valid (i.e. can be updated / created) if its prefix is unique.
	 */
	private function isAccountValid($account) {
		// Ensure the prefix is unique (or empty if self-hosted)
		if ($account->selfHost) return true;
		$sql = 	<<<EOD
				SELECT F_RootID, F_Prefix
				FROM T_AccountRoot
				WHERE F_Prefix=?
EOD;
		$rs = $this->db->Execute($sql, array($account->prefix));
		
		switch ($rs->RecordCount()) {
			case 0:
				// There are no duplicates
				return true;
			case 1:
				// There is a duplicate, but if this is an update it might be the same record
				return ((int)($rs->FetchNextObj()->F_RootID) == (int)($account->id));
			default:
				// Something is wrong with the database!
				throw new Exception("isAccountValid: More than one account was returned with prefix '".$account->prefix."'");
		}
	}
	/**
	 * v3.3 Is this title Ok to save?
	 */
	private function isTitleValid($title) {
		// Ensure that the languageCode has a valid value
		$sql = 	<<<EOD
				SELECT *
				FROM T_ProductLanguage
				WHERE F_ProductCode=? 
				AND F_LanguageCode=?
EOD;
		$rs = $this->db->Execute($sql, array($title->productCode, $title->languageCode));
		
		switch ($rs->RecordCount()) {
			case 0:
				// There is no matching pair, raise an error
				return false;
			default:
		}
		// Also make sure that Author Plus has a content location
		// But how to differentiate this from the above error? 
		// Need to return an error code I suppose.
		// This is left for now. You get a double error message, but that is kind of OK
		// v3.5 Now dbContentLocation is tied to the field in DMS and is the direct database link
		//if ($title-> productCode == 1 && ($title->contentLocation == "" || $title->contentLocation == null))
		if ($title-> productCode == 1 && ($title->dbContentLocation == "" || $title->dbContentLocation == null))
			return false;
			
		return true;
	}

	/* 
	 * Functions to find an account based on key information
	 */
	// This one is for CLS accounts which have unique emails for the admin user
	public function getAccountFromEmail($email) {
	
		$sql = 	<<<EOD
				SELECT r.F_RootID rootID
				FROM T_AccountRoot r, T_User u
				WHERE r.F_AdminUserID = u.F_UserID
			AND u.F_Email = ?
EOD;
		$sql .= ' AND ('.NEG_MYPOSTFIX.')';
		//echo $sql;
		$rs = $this->db->Execute($sql, array($email));
		
		switch ($rs->RecordCount()) {
			case 0:
				// There is no matching pair, raise an error
				return false;
				break;
			case 1:
				// One record, good. Send back the root
				$rootID = $rs->FetchNextObj()->rootID;
				break;
			default:
				return false;
		}
		
		// now get the account (just one)
		$accounts = $this->getAccounts(array($rootID));
		return array_shift($accounts);
	}
	/*
	 * Utility function to return the next sequential number for prefixes, (and obfuscate it)
	 */
	public function getNextPrefix() {
		$sql = 	<<<EOD
				SELECT MAX(F_Prefix) AS MAXPREFIX from T_AccountRoot
				WHERE   
EOD;
		$sql .= NEG_MYPOSTFIX;
		$rs = $this->db->Execute($sql);
		return ((string)((int)($rs->FetchNextObj()->MAXPREFIX) + 1));
	}
}
?>