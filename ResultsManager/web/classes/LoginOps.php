<?php

class LoginOps {
	
	var $db;
	
	function LoginOps($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($db);
	}
	
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
											"a.F_MaxReporters"));
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
							(SELECT F_RootID, F_LanguageCode, F_MaxTeachers, F_MaxAuthors, F_MaxReporters, F_ExpiryDate
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
				if ($loginObj->ProductExpiryDate && 
						(strtotime($loginObj->ProductExpiryDate) < strtotime(date("Y-m-d"))))
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
	
}
?>
