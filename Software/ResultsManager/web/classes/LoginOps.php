<?php

class LoginOps {
	
	var $db;
	
	function LoginOps($db) {
		
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($db);
		$this->accountOps = new AccountOps($db);
	}
	
	// Bento login has different options than RM
	// For now write this as a different function so it can exist in the same file yet be completely different
	function loginBento($loginObj, $loginOption, $userTypes, $rootID, $productCode = null) {
		
		// Pull out the relevant login details from the passed object
		// loginOption controls what fields you use to login with.
		// TODO. make it use constants.
		// TODO. The code below ONLY uses username/studentID at the moment
		if ($loginOption==1) {
			if (isset($loginObj['username'])) {
				$key = 'u.F_UserName';
				$keyValue = $loginObj['username'];
			}
		} elseif ($loginOption==2) {
			if (isset($loginObj['studentID'])) {
				$key = 'u.F_StudentID';
				$keyValue = $loginObj['studentID'];
			}
		}
		if (isset($loginObj['password']))
			$password = $loginObj['password'];
			
		
		// Build the basic login query
		// TODO: This currently binds the language to productCode=2 (RM) but we'll want to make this configurable when we add more products)
		// AR I also want to know the login user's ID back in RM. Hmm, I think I was able to pick this up anyway without it being in the selectFields. How?
		// No, I don't think it was being properly passed. Anyway, it is now.
		// AR. Surely I should pass back the entire user object? Why ever wouldn't I?
		/*
		$selectFields = array("g.F_GroupID as groupID",
							  "m.F_RootID",
							  "u.F_UserType",
							  "u.F_UserName",
							  "u.F_UserID",
							  "u.F_Password",
							  $this->db->SQLDate("Y-m-d H:i:s", "u.F_StartDate")." UserStartDate",
							  $this->db->SQLDate("Y-m-d H:i:s", "u.F_ExpiryDate")." UserExpiryDate");
		*/					  
		$selectFields = array("g.F_GroupID as groupID",
							  "m.F_RootID",
							  "u.*");
		$sql  = "SELECT ".join(",", $selectFields);
		$sql .=	<<<EOD
				FROM T_User u LEFT JOIN 
				T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
				T_Groupstructure g ON m.F_GroupID = g.F_GroupID 
EOD;
		
		// Check password in the code afterwards
		//		AND u.F_Password=?
		$sql .=	<<<EOD
				WHERE $key = ?
EOD;
			
		// Construct the allowed login types into an SQL string and add it to the end of the query
		$userTypesSQL = array();
		foreach ($userTypes as $userType)
			$userTypesSQL[] = "u.F_UserType=$userType";
		$sql .= " AND (".implode(" OR ", $userTypesSQL).")";
	
		// Create the binding parameters
		//$bindingParams = array($username, $password);
		//$bindingParams = array($keyValue, $password);
		$bindingParams = array($keyValue);
		
		if ($rootID != null) {
			$sql.= "AND m.F_RootID=?";
			$bindingParams[] = $rootID;
		}
		
		//NetDebug::trace("sql=".$sql);
		//NetDebug::trace("bindingParams=".implode(",",$bindingParams));
		$rs = $this->db->Execute($sql, $bindingParams);
		//NetDebug::trace("records==".$rs->RecordCount());
		
		switch ($rs->RecordCount()) {
			case 0:
				// Invalid login
				// Bento requires an error object as explanation
				throw new Exception("No such user", 100);
				break;
			case 1:
				// Valid login
				$loginObj = $rs->FetchNextObj();

				// A special case to check that the password matches the case (by default MSSQL and MYSQL are case-insensitive)
				if ($password != $loginObj->F_Password) {
					//return false;
					// If I do this as an Exception - can I catch it in BentoService? Yes
					throw new Exception("Wrong password", 100);
				}
				
				// Check if the user has expired.  Specify the language code as EN when getting copy as we haven't logged in yet.
				// AR Some users have NULL expiry date, so this will throw an exception, so add an extra condition to test for this
				// Also, you can't use strtotime on this date format if year > 2038
				if ($loginObj->UserExpiryDate && ($loginObj->UserExpiryDate > '2038')) $loginObj->UserExpiryDate = '2038-01-01';
				if ($loginObj->UserExpiryDate && 
						(strtotime($loginObj->UserExpiryDate) > 0) && 
						(strtotime($loginObj->UserExpiryDate) < strtotime(date("Y-m-d")))) {
					//throw new Exception($this->copyOps->getCopyForId("userExpiredError", array("date" => $loginObj->UserExpiryDate), "EN"));
					//throw new Exception("Your user account expired on ".date("d M Y", strtotime($loginObj->UserExpiryDate)));
					throw new Exception("Your user account expired on ".date("d M Y", strtotime($loginObj->UserExpiryDate)), 100);
				}

				// Authenticate the user with the session
				Authenticate::login($loginObj->F_UserName, $loginObj->F_UserType);
				
				// Return the loginObj so the specific service can continue with whatever action it likes
				return $loginObj;
				break;
				
			default:
				// More than one user with this name/password
				throw new Exception("More than one user matches these details", 100);
		}
		
	}
	// Results Manager login
	function login($username, $password, $userTypes, $rootID, $productCode = null) {
		// Network version. SQLite can't cope with this query. RIGHT and FULL OUTER JOINs are not currently supported.
		// I suspect that for a network login it can be made simpler as there will only be 1 root.
		// v3.4.1 Need to pass back name to pick up 'correct' capitalisation
		if ($GLOBALS['dbms'] == 'pdo_sqlite') {
			$sql .=	<<<EOD
				SELECT g.F_GroupID, m.F_RootID,
						u.F_UserType, u.F_UserID, u.F_Password, u.F_StartDate UserStartDate, u.F_ExpiryDate UserExpiryDate,
						u.F_UserName,
						a.F_ExpiryDate ProductExpiryDate,a.F_LanguageCode,a.F_MaxTeachers,a.F_MaxAuthors,a.F_MaxReporters				
				FROM T_User u 
					LEFT JOIN 
						T_Membership m ON m.F_UserID = u.F_UserID
					LEFT JOIN
						T_Groupstructure g ON m.F_GroupID = g.F_GroupID 					
					LEFT JOIN
						T_Accounts a ON a.F_RootID = m.F_RootID				
				WHERE a.F_ProductCode=?
				AND u.F_UserName=?
				AND u.F_Password=?
				AND (u.F_UserType=1 OR u.F_UserType=2 OR u.F_UserType=3 OR u.F_UserType=4)
EOD;
		} else {

			// Build the basic login query
			// TODO: This currently binds the language to productCode=2 (RM) but we'll want to make this configurable when we add more products)
			// AR I also want to know the login user's ID back in RM. Hmm, I think I was able to pick this up anyway without it being in the selectFields. How?
			// No, I don't think it was being properly passed. Anyway, it is now.
			$selectFields = array("g.F_GroupID",
								  "m.F_RootID",
								  "u.F_UserType",
								  "u.F_UserName",
								  "u.F_UserID",
								  "u.F_Password",
								  $this->db->SQLDate("Y-m-d H:i:s", "u.F_StartDate")." UserStartDate",
								  $this->db->SQLDate("Y-m-d H:i:s", "u.F_ExpiryDate")." UserExpiryDate");
								  
			// Only add in the titles fields if $productCode is specified (i.e. this is not DMS)
			if ($productCode) { 
				$selectFields = array_merge($selectFields, 
									  array($this->db->SQLDate("Y-m-d H:i:s", "a.F_ExpiryDate")." ProductExpiryDate",
											"a.F_LanguageCode",
											"a.F_MaxTeachers",
											"a.F_MaxAuthors", 
											"a.F_MaxReporters",
											"a.F_LicenceType"));
			}
			
			$sql  = "SELECT ".join(",", $selectFields);
			$sql .=	<<<EOD
					FROM T_User u LEFT JOIN 
					T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
					T_Groupstructure g ON m.F_GroupID = g.F_GroupID 
EOD;
			
			// Only add in the titles fields if $productCode is specified (i.e. this is not DMS)
			if ($productCode) {
				$sql .=	<<<EOD
						RIGHT JOIN
							(SELECT F_RootID, F_LanguageCode, F_MaxTeachers, F_MaxAuthors, F_MaxReporters, F_ExpiryDate, F_LicenceType
							FROM T_Accounts
							WHERE F_ProductCode = ?) a ON a.F_RootID = m.F_RootID
EOD;
			}
			
			$sql .=	<<<EOD
					WHERE u.F_UserName=?
					AND u.F_Password=?
EOD;
			
			// Construct the allowed login types into an SQL string and add it to the end of the query
			$userTypesSQL = array();
				foreach ($userTypes as $userType)
					$userTypesSQL[] = "u.F_UserType=$userType";
			$sql .= " AND (".implode(" OR ", $userTypesSQL).")";
		
		}		
		// Create the binding parameters
		$bindingParams = array($username, $password);
		
		// Only add in the titles productcode binding if $productCode is specified (i.e. this is not DMS)
		if ($productCode) array_unshift($bindingParams, $productCode);
		
		if ($rootID != null) {
			$sql.= "AND m.F_RootID=?";
			$bindingParams[] = $rootID;
		}
		
		//NetDebug::trace("sql=".$sql);
		//NetDebug::trace("bindingParams=".implode(",",$bindingParams));
		$rs = $this->db->Execute($sql, $bindingParams);
		//NetDebug::trace("records==".$rs->RecordCount());
		
		switch ($rs->RecordCount()) {
			case 0:
				// Invalid login
				return false;
			case 1:
				// Valid login
				$loginObj = $rs->FetchNextObj();
		
				// A special case to check that the password matches the case (by default MSSQL and MYSQL are case-insensitive)
				if ($password != $loginObj->F_Password) return false;
				
				// Check if the user has expired.  Specify the language code as EN when getting copy as we haven't logged in yet.
				// AR Some users have NULL expiry date, so this will throw an exception, so add an extra condition to test for this
				// Also, you can't use strtotime on this date format if year > 2038
				if ($loginObj->UserExpiryDate && ($loginObj->UserExpiryDate > '2038')) $loginObj->UserExpiryDate = '2038-01-01';
				if ($loginObj->UserExpiryDate && 
						(strtotime($loginObj->UserExpiryDate) > 0) && 
						(strtotime($loginObj->UserExpiryDate) < strtotime(date("Y-m-d"))))
					//throw new Exception($this->copyOps->getCopyForId("userExpiredError", array("date" => $loginObj->UserExpiryDate), "EN"));
					throw new Exception("Your user account expired on ".date("d M Y", strtotime($loginObj->UserExpiryDate)));
				
				// Check if the product has expired.  Specify the language code as EN when getting copy as we haven't logged in yet.
				// It seems that copyOps not yet loaded? But this should do it as required, right?
				if ($loginObj->ProductExpiryDate && ($loginObj->ProductExpiryDate > '2038')) $loginObj->ProductExpiryDate = '2038-01-01';
				// v3.4 We ask people to look at usage stats in the email sent 2 weeks after other titles expired.
				// But usually RM is set to expire at the same time. Easiest fix is to allow RM login for 2 weeks after it's expiry
				// but then (ideally) limit access to usage stats. Not sure how to do that bit, so just let them in anyway.
						//(strtotime($loginObj->ProductExpiryDate) < strtotime(date("Y-m-d"))))
				if ($loginObj->ProductExpiryDate && 
						(strtotime($loginObj->ProductExpiryDate) < strtotime("-3 weeks")))
					//throw new Exception($this->copyOps->getCopyForId("productExpiredError", array("date" => $loginObj->ProductExpiryDate, "EN")));
					throw new Exception("Your Results Manager expired on ".date("d M Y", strtotime($loginObj->ProductExpiryDate)));
				
				// Authenticate the user with the session
				Authenticate::login($username, $loginObj->F_UserType);
				
				// Store information about this login in the session
				Session::set('userID', $loginObj->F_UserID);
				Session::set('userType', $loginObj->F_UserType);

				// Return the loginObj so the specific service can continue with whatever action it likes
				return $loginObj;
				
			default:
				// Something is wrong with the database
				throw new Exception("Multiple users were returned from this login or there are multiple 'Results Manager' titles registered to this account.");
		}
		
	}

	/**
	 * 
	 * This function gets a group record
	 * @param Number $groupID
	 */
	function getGroup($groupID) {
		$sql = "SELECT * FROM T_Groupstructure WHERE F_GroupID=?";
		$rs = $this->db->Execute($sql, array($groupID));
		if ($rs)
			return $rs->FetchNextObj();
	}
	
	/**
	 * 
	 * This function updates a user record with an instance ID
	 * @param Number $instanceID
	 */
	function setInstanceID($userID, $instanceID) {
		
		// TODO. This seems messy to do it here rather than in config.php
		// But it isn't actually very important so leave here for now.
		// v6.5.6 Add support for HTTP_X_FORWARDED_FOR
		if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
			// This might show a list of IPs. Assume/hope that EZProxy puts itself at the head of the list.
			$ipList = explode(',',$_SERVER['HTTP_X_FORWARDED_FOR']);
			$ip = $ipList[0];
		} elseif (isset($_SERVER['HTTP_TRUE_CLIENT_IP'])) {
			$ip=$_SERVER['HTTP_TRUE_CLIENT_IP'];
		} elseif (isset($_SERVER["HTTP_CLIENT_IP"])) {
			$ip = $_SERVER["HTTP_CLIENT_IP"];
		} else {
			$ip = $_SERVER["REMOTE_ADDR"];
		}
		$sql .=	<<<EOD
				UPDATE T_User u					
				SET u.F_UserIP=?, u.F_LicenceID=? 
				WHERE u.F_UserID=?
EOD;
		$bindingParams = array($ip, $instanceID, $userID);
		$resultObj = $this->db->Execute($sql, $bindingParams);
		if ($resultObj)
			return true;
		throw new Exception("Can't set the instance ID for the user $userID", 100);
	}
	
	/**
	 * 
	 * This function gets the instanceID for a user
	 * @param Number $userID
	 */
	function getInstanceID($userID) {
		
		$sql .=	<<<EOD
				SELECT F_LicenceID 
				FROM T_User u					
				WHERE u.F_UserID=?
EOD;
		$bindingParams = array($userID);
		$rs = $this->db->Execute($sql, $bindingParams);
		if ($rs)
			return $rs->FetchNextObj()->F_LicenceID;
		throw new Exception("Can't get the instance ID for the user $userID", 100);
	}
	
	// v3.2 A simplified login which is for identification rather than authentication purposes
	// Not used yet.
	/*
	function simplelogin($userID) {		
		$selectFields = array("g.F_GroupID",
							  "m.F_RootID",
							  "u.F_UserType",
							  "u.F_UserID",
							  $this->db->SQLDate("Y-m-d H:i:s", "u.F_ExpiryDate")." UserExpiryDate");
							  
		
		$sql  = "SELECT ".join(",", $selectFields);
		$sql .=	<<<EOD
				FROM T_User u LEFT JOIN 
				T_Membership m ON m.F_UserID = u.F_UserID LEFT JOIN
				T_Groupstructure g ON m.F_GroupID = g.F_GroupID 
				WHERE u.F_UserID=?
EOD;
		
		// Create the binding parameters
		$bindingParams = array($userID);
		
		//NetDebug::trace("sql=".$sql);
		$rs = $this->db->Execute($sql, $bindingParams);
		
		switch ($rs->RecordCount()) {
			case 0:
				// Invalid login
				return false;
			case 1:
				// Valid login
				$loginObj = $rs->FetchNextObj();
		
				// Check if the user has expired.  Specify the language code as EN when getting copy as we haven't logged in yet.
				// AR Some users have NULL expiry date, so this will throw an exception, so add an extra condition to test for this
				// Also, you can't use strtotime on this date format if year > 2038
				if ($loginObj->UserExpiryDate && ($loginObj->UserExpiryDate > '2038')) $loginObj->UserExpiryDate = '2038-01-01';
				if ($loginObj->UserExpiryDate && 
						(strtotime($loginObj->UserExpiryDate) > 0) && 
						(strtotime($loginObj->UserExpiryDate) < strtotime(date("Y-m-d"))))
					throw new Exception($this->copyOps->getCopyForId("userExpiredError", array("date" => $loginObj->UserExpiryDate), "EN"));
				
				// Check if the product has expired.  Specify the language code as EN when getting copy as we haven't logged in yet.
				if ($loginObj->ProductExpiryDate && ($loginObj->ProductExpiryDate > '2038')) $loginObj->ProductExpiryDate = '2038-01-01';
				if ($loginObj->ProductExpiryDate && 
						(strtotime($loginObj->ProductExpiryDate) < strtotime(date("Y-m-d"))))
					throw new Exception($this->copyOps->getCopyForId("productExpiredError", array("date" => $loginObj->ProductExpiryDate, "EN")));
				
				// Authenticate the user with the session
				Authenticate::login($username, $loginObj->F_UserType);
				
				// Store information about this login in the session
				Session::set('userID', $loginObj->F_UserID);
				Session::set('userType', $loginObj->F_UserType);
				
				// Return the loginObj so the specific service can continue with whatever action it likes
				return $loginObj;
				
			default:
				// Something is wrong with the database
				throw new Exception("Multiple users were returned from this login or there are multiple 'Results Manager' titles registered to this account.");
		}
		
	}
	*/
	
	function logout() {
		Authenticate::logout();
		
		Session::clear();
		
		// TODO. Close the session and drop any licence control
		
		//session_unset();
		//unset($_SESSION['rootID']);
		//unset($_SESSION['userID']);
		//unset($_SESSION['userType']);
		
		// v6.5.4.7 Until we know which are our own RM session variables.
		//session_destroy();
		//$_SESSION = array();
	}
	
	// v3.0.6 I don't think this really has anything to do with RM or DMS login. It is for setting student login.
	// I think it fits better under AccountOps, although carefully protected as it is an RM update and a DMS update.
	// for now we are keeping accountOps for DMS, so leave it here, and add EmailOpts too!
	function getLoginOpts() {
		// AR Change to the account table
		//$sql = "SELECT F_LoginOption, F_SelfRegister, F_Verified FROM T_GroupStructure WHERE F_GroupID=?";
		//$resultObj = $this->db->GetRow($sql, array($_SESSION['rootGroupID']));
		$sql = "SELECT F_LoginOption, F_SelfRegister, F_Verified FROM T_AccountRoot WHERE F_RootID=?";
		$resultObj = $this->db->GetRow($sql, array(Session::get('rootID')));
		
		return array("loginOption" => $resultObj['F_LoginOption'],
					 "selfRegister" => $resultObj['F_SelfRegister'],
					 "passwordRequired" => $resultObj['F_Verified']);
	}
	function setLoginOpts($loginOption, $selfRegister, $passwordRequired) {
		// AR Change to the account table
		//$sql = "UPDATE T_GroupStructure SET F_LoginOption=?, F_SelfRegister=?, F_Verified=? WHERE F_GroupID=?";
		//$this->db->Execute($sql, array($loginOption, $selfRegister, $passwordRequired, $_SESSION['rootGroupID']));
		//$sql = "UPDATE T_AccountRoot SET F_LoginOption=?, F_SelfRegister=?, F_Verified=? WHERE F_RootID=?";
		//$this->db->Execute($sql, array($loginOption, $selfRegister, $passwordRequired, Session::get('rootID')));
		// v3.2 F_Verified is an integer
		$useVerified = ($passwordRequired) ? 1: 0;
		$sql = "UPDATE T_AccountRoot SET F_LoginOption=$loginOption, F_SelfRegister=$selfRegister, F_Verified=$useVerified WHERE F_RootID=?";
		//NetDebug::trace("sql=".$sql);
		$this->db->Execute($sql, array(Session::get('rootID')));
	}
	
	// To hold each contact email and the type of message that they should receive
	// Note that admin emails are NOT saved in the T_AccountEmails to avoid duplication and problems with editing
	// So you 
	function getEmailOpts() {
		$bindingParams = array(Session::get('rootID'));
		//	SELECT IF((e.F_Email IS NULL), u.F_Email, e.F_Email), e.F_MessageType 
		// TODO: Not tested in SQL Server yet
		$sql .=	<<<EOD
			SELECT CASE WHEN (e.F_Email IS NULL) THEN u.F_Email ELSE e.F_Email END as F_Email, e.F_MessageType 
			FROM T_AccountEmails e, T_AccountRoot r, T_User u
			WHERE r.F_RootID = ?
			AND r.F_RootID = e.F_RootID
			AND r.F_AdminUserID = u.F_UserID
			ORDER BY e.F_AdminUser DESC
EOD;
		//echo $sql;
		$resultObj = $this->db->GetArray($sql, $bindingParams);
		$emailArray = array();
		if ($resultObj) {
			foreach ($resultObj as $result) {
				$emailArray[] = array('email' => $result['F_Email'],'messageType' => intval($result['F_MessageType']));
			}
		}
		//echo print_r($emailArray);
		return $emailArray;
	}
	function setEmailOpts($emailArray) {
		$bindingParams = array(Session::get('rootID'));
		// First clear out existing emails and settings
		$this->db->Execute("DELETE FROM T_AccountEmails WHERE F_RootID=?", $bindingParams);
		
		$rootID = Session::get('rootID');
		for ($i=0; $i<count($emailArray); $i++) {
			// The first item is the admin user - so this has a special seting. This is why we do it with a for loop counter
			$emailItem = $emailArray[$i];
			if ($i == 0) {
				$email = null;
				$adminUser=true;
			} else {
				$email = $emailItem['email'];
				$adminUser=false;
			}
			$messageType = $emailItem['messageType'];
			NetDebug::trace("item ".$i.' has email='.$email.' and message='.$messageType. ' and admin='.$adminUser);

			if ($i==0 || ($email != '' && $email != null)) {
				if ($messageType == null || $messageType == '')
					$messageType=0;
				$dbObj = array();
				$dbObj['F_RootID'] = $rootID;
				$dbObj['F_Email'] = $email;
				$dbObj['F_MessageType'] = $messageType;
				$dbObj['F_AdminUser'] = $adminUser;
				$this->db->AutoExecute("T_AccountEmails", $dbObj, "INSERT");
			}
		}
		/*
		foreach ($emailArray as $emailItem) {
			// The first item is the admin user - so this has a special seting. This is why we do it with a for loop counter
			$email = $emailItem['email'];
			$messageType = $emailItem['messageType'];
			if ($email != '' && $email != null) {
				if ($messageType == null || $messageType == '')
					$messageType=0;
				$dbObj = array();
				$dbObj['F_RootID'] = $rootID;
				$dbObj['F_Email'] = $email;
				$dbObj['F_MessageType'] = $messageType;
				$this->db->AutoExecute("T_AccountEmails", $dbObj, "INSERT");
			}
		}
		*/
	}
	/**
	 * 
	 * Before you login a user, you need to find things like loginOptions from the account.
	 * @param Number productCode
	 * @param Number prefix
	 * @param Number rootID
	 */
	//function getAccountSettings($rootID=null, $productCode=null) {
	function getAccountSettings($config) {
		
		// Check data
		if (isset($config['prefix'])) 
			$prefix = $config['prefix'];
		if (isset($config['rootID'])) 
			$rootID = $config['rootID'];
		if (isset($config['productCode'])) 
			$productCode = $config['productCode'];
			
		if (!$productCode)
			throw new Exception("No productCode sent to getAccountSettings", 100);
		
		// RootID is more important than prefix.
		// TODO. At present getAccounts can only cope with rootID not prefix. 
		// That should be OK short term, but for max flexibility we should also be able to query from prefix.
		//} else if (isset($config['prefix'])) {
		//	$prefix = $config['prefix'];
		//if (!$rootID)
		//	throw new Exception("No rootID sent to getAccountSettings", 100);
		if (!$prefix && !$rootID)
			throw new Exception("No prefix or rootID sent to getAccountSettings", 100);
		
		// Query the database
		// Kind of silly, but bento is usually keyed on prefix and getAccounts always works on rootID
		// so add an extra call if you don't currently know the rootID
		if (is_numeric($rootID)) {
			$rootID = (int) $this->accountOps->getAccountRootID($prefix);
			if (!$rootID)
				throw new Exception("No prefix for rootID=$rootID", 100);
		}
		
		// First get the record from T_AccountRoot and T_Accounts
		//$conditions = array("productCode" => $productCode);
		// Hmm. By reusing AccountOps from RM/DMS we end up getting the whole course.xml, when we really don't want it.
		// It probably wouldn't really matter except that we end up with contentLocation goverened by config.php in RM/web which is wrong.
		// Since I have to change something, I might as well make a new method in AccountOps
		$account = $this->accountOps->getBentoAccount($rootID, $productCode);
		
		// It would be an error to have more or less than one title in that account
		if (count($account->titles)>1) {
			throw new Exception("More than one title with productCode $productCode", 100);
		} else if (count($account->titles)==0) {
			throw new Exception("No title with productCode $productCode in rootID $rootID", 100);
		} 
		
		// Next get account licence details, which are not pulled in from getAccounts as DMS doesn't usually want them
		$account->addLicenceAttributes($this->accountOps->getAccountLicenceDetails($rootID, $productCode));

		// Also check whether we want a default content location
		if (!$account->titles[0]->contentLocation) {
			$sql = <<< SQL
					SELECT F_ContentLocation 
					FROM T_ProductLanguage
					WHERE F_ProductCode = ?
					AND F_LanguageCode = ?;
SQL;
			$bindingParams = array($productCode, $account->titles[0]->languageCode);
			$rs = $this->db->Execute($sql, $bindingParams);	
			if ($rs) 
				$account->titles[0]->contentLocation = $rs->FetchNextObj()->F_ContentLocation;
		}
		
		return $account;
	}
	
	/**
	 * Check that this user can get a licence slot right now 
	 */
	function getLicenceSlot($userObj, $rootID, $productCode) {
		
		// During getAccountSettings we picked this up and saved it
		// TODO. Or do you want to pass it to login?
		$licenceType = Session::get('licenceType');
		$maxStudents = Session::get('maxStudents');
		$licenceClearanceDate = Session::get('licenceClearanceDate');
		$licenceClearanceFrequency = Session::get('licenceClearanceFrequency');
		$expiryDate = Session::get('expiryDate');
		$licenceStartDate = Session::get('licenceStartDate');
				
		// Some checks are independent of licence type
		if ($licenceStartDate > $now) 
			throw new Exception("Your licence hasn't started yet", 100);
		if ($expiryDate < $now) 
			throw new Exception("Your licence has expired", 100);
		if ($maxStudents < 1) 
			throw new Exception("You have no licences for this title", 100);
			
		// Then licence slot checking is based on licence type
		switch ($licenceType) {
			// Concurrent licences
			case 2:
			case 3:
				
				$aWhileAgo = time() - 1*60; // one minute
				$updateTime = date('Y-m-d H:i:s', $aWhileAgo);
				
				// First, just delete all old licences for this product/root
				$sql = <<<EOD
				DELETE FROM T_Licences 
				WHERE F_ProductCode=? 
				AND F_RootID IN (?)
				AND (F_LastUpdateTime<? OR F_LastUpdateTime is null) 
EOD;
				$bindingParams = array($updateTime, $productCode, $singleRootID);
				$rs = $db->Execute($sql, $bindingParams);
				// the sql call failed
				if (!$rs) 
					throw new Exception("Error, can't clear out old licences", 100);

				// Then count how many are currently in use
				$bindingParams = array($productCode, $rootID);			
	
				$sql = <<<EOD
				SELECT COUNT(F_LicenceID) as i FROM T_Licences 
				WHERE F_ProductCode=?
				AND F_RootID in (?) 
EOD;
				$rs = $db->Execute($sql, $bindingParams);
				$usedLicences = $rs->FetchNextObj()->i;

				if ($usedLicences >= $maxStudents) 
					throw new Exception("The licence is full, try again later", 100);
				
				// Insert this user in the licence control table
				$dateNow = date('Y-m-d H:i:s', time());
				$bindingParams = array($userIP, $dateNow, $dateNow, $rootID, $productCode, $userID);
				$sql = <<<EOD
				INSERT INTO T_Licences (F_UserHost, F_StartTime, F_LastUpdateTime, F_RootID, F_ProductCode, F_UserID) VALUES
				('$userIP', '$dateNow', '$dateNow', $singleRootID, $productCode, $userID)
EOD;
				$rs = $db->Execute($sql);
				// v6.5.4.8 adodb will get the identity ID (F_LicenceID) for us.
				// Except that it fails. Seems due to fact that with parameters, the insert is in a different scope to the identity scope call so fails. 
				// If I don't do it with parameters then it works. Seems safe since nothing is typed by the user.
				$licenceID = $db->Insert_ID();

				// Final error check
				if (!$licenceID)
					throw new Exception("Error, can't allocate a licence number", 100);

				break;
				
			// Named licences
			case 1:
			case 4:
				break;
		}
		
		return $licenceID;
				
	}
}
