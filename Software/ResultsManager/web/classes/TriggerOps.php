<?php
class TriggerOps {

	var $db;

	function TriggerOps($db) {
		$this->db = $db;
		//$this->copyOps = new CopyOps();
		// Is it acceptable to do this here? Any kind of duplication?"
		$this->accountOps = new AccountOps($this->db);
	}
	
	/**
	 * Get the triggers.  
	 * If $triggerIDArray is specified then only get those triggers, otherwise get them all.
	 * If $timeStamp is specified, the trigger must be valid at that time.
	 */
	function getTriggers($msgType = null, $triggerIDArray = null, $timeStamp = null, $frequency = null) {
		//echo $msgType.'     '.intval($msgType).'       '.is_numeric(intval($msgType)).'#';
		// Get all the triggers
		$sql  = "SELECT ".Trigger::getSelectFields($this->db)." ";
		$sql .= "FROM T_Triggers t ";
		
		$where = array();
		
		if ($triggerIDArray) {
			$where[] = "F_TriggerID IN (".join($triggerIDArray, ",").")";
		}
		if ($timeStamp) {
			$where[] = "(t.F_ValidFromDate <= '".date("Y-m-d", $timeStamp)."' OR t.F_ValidFromDate is null)";
			$where[] = "(t.F_ValidToDate >= '".date("Y-m-d", $timeStamp)."' OR t.F_ValidToDate is null)";
		}
		if ($frequency) {
			$where[] = "(t.F_Frequency = '".strtolower($frequency)."')";
		}
		if (!is_null($msgType) && is_numeric(intval($msgType))) {
			$where[] = "(t.F_MessageType = ".intval($msgType).")";
		}
		if (sizeof($where) > 0) {
			$sql .= "WHERE ".implode(" AND ", $where)." ";
		}
		if (!$triggerIDArray) {
			$sql .= "ORDER BY F_Name";
		}	
		// Perform the query and create an array of trigger objects from the results
		//echo $sql;
		$triggersRS = $this->db->Execute($sql);
		
		$result = array();
		
		if ($triggersRS->RecordCount() > 0) {
			while ($triggerObj = $triggersRS->FetchNextObj()) {
			
				// Create the trigger object
				$trigger = $this->_createTriggerFromObj($triggerObj, $timeStamp);
				
				$result[] = $trigger;
			}
		}
		
		return $result;
	}
	/*
	* Apply a condition to the database and return all objects that meet the condition.
	* The type of object returned depends on the condition.
	* We pass the effective trigger date in case that is needed, defaults to now.
	*/
	function applyCondition($trigger, $timeStamp = null) {
	
		switch ($trigger->condition->method) {
			case "getAccounts":
			case "getUsers":
				$accountConditions = array();
				if (isset($trigger->condition->expiryDate)) {
					$accountConditions["expiryDate"] = $trigger->condition->expiryDate;
				} else {
					$accountConditions["expiryDate"] = null;
				}
				if (isset($trigger->condition->accountType)) $accountConditions["accountType"] = $trigger->condition->accountType;
				// v3.7 The trigger system should ignore accountStatus=suspended (3) unless specifically set
				if (isset($trigger->condition->accountStatus)) {
					$accountConditions["accountStatus"] = $trigger->condition->accountStatus;
				} else {
					$accountConditions["notAccountStatus"] = 3;
				}
				if (isset($trigger->condition->licenceType)) $accountConditions["licenceType"] = $trigger->condition->licenceType;
				if (isset($trigger->condition->notLicenceType)) $accountConditions["notLicenceType"] = $trigger->condition->notLicenceType;
				if (isset($trigger->condition->productCode)) $accountConditions["productCode"] = $trigger->condition->productCode;
				if (isset($trigger->condition->notProductCode)) $accountConditions["notProductCode"] = $trigger->condition->notProductCode;
				if (isset($trigger->condition->deliveryFrequency)) $accountConditions["deliveryFrequency"] = $trigger->condition->deliveryFrequency;
				if (isset($trigger->condition->individuals)) $accountConditions["individuals"] = $trigger->condition->individuals;
				if (isset($trigger->condition->active)) $accountConditions["active"] = $trigger->condition->active;
				// v3.4.3
				if (isset($trigger->condition->selfHost)) $accountConditions["selfHost"] = $trigger->condition->selfHost;
				// v3.5 Subscription reminders also based on start date now. This should mean the RM start date.
				if (isset($trigger->condition->startDate)) $accountConditions["startDate"] = $trigger->condition->startDate;
				if (isset($trigger->condition->startDay)) $accountConditions["startDay"] = $trigger->condition->startDay;
				
				// These next conditions are not account conditions, but are for searching users within the found accounts
				//if (isset($trigger->condition->contactMethod)) $accountConditions["contactMethod"] = $trigger->condition->contactMethod;
				//if (isset($trigger->condition->userStartDate)) $accountConditions["userStartDate"] = $trigger->condition->userStartDate;

				// v3.5 The trigger system should ignore accounts that have opted out of subscription reminders 
				$accountConditions["optOutEmails"] = true;
				// (unless we override this for internal reports)
				if (isset($trigger->condition->optOutEmails) && ($trigger->condition->optOutEmails == false)) {
					unset ($accountConditions["optOutEmails"]);
				}
				
				//$expiryDate = $trigger->condition->expiryDate;
				//$triggerResults = $this->accountOps->getAccounts(null, $expiryDate);
				// Pick up the root if specified in the trigger. Group doesn't make any sense for accounts.
				if (is_array($trigger->rootID)) {
					$accountIDs = $trigger->rootID;
				} elseif (isset($trigger->rootID) && ($trigger->rootID > 0)) {
					$accountIDs = Array($trigger->rootID);
				} else {
					$accountIDs = null;
				}
				//echo "selfHost trigger condtion=".$trigger->condition->selfHost;
				$triggerResults = $this->accountOps->getAccounts($accountIDs, $accountConditions);
				//echo "got ".count($triggerResults)." accounts that expire on ".$trigger->condition->expiryDate ."<br />";
				//$executor = $trigger->executor;
				break;

			case "dbChange":
				//echo "run sql=".$trigger->condition->select."<br/>";
				$triggerResults = $this->_runSQL($trigger->condition->select);
				break;
			default:
		}
		return $triggerResults;
	}
	/*
	 * A function that is currently very specific until I work out how it relates more generically
	 * It gets all users in the passed account who have a specified start date.
	 */
	public function usersInAccount($account, $trigger) {
		// Look for all users in this account who match the trigger conditions (probably just userStartDate)
		// If we are working with delivery frequency, this is not know until now, so we need to do some
		// extra processing on the start date. {now}-1f
		//echo "account $account->id look for userExpiryDate={$trigger->condition->userExpiryDate}</br>";
		//echo "account $account->id look for trigger={$trigger->condition->toString()} and deliveryFrequency={$myTitle->deliveryFrequency}</br>";
		if ($trigger->condition->userStartDate && stristr($trigger->condition->userStartDate, '{')) {
			// We have to assume that the first title controls delivery frequency for all, or that we know a default value
			$dF = $account->getTitleByProductCode($trigger->condition->productCode)->deliveryFrequency;
			if ($dF > 0) {
				$trigger->condition->deliveryFrequency = $dF;
			} else {
				switch ($trigger->condition->productCode) {
					case 1001:
					default:
						$trigger->condition->deliveryFrequency = 3;
						break;
				}
			}
			$trigger->condition->userStartDate = $trigger->condition->evaluateDateVariables($trigger->condition->userStartDate);
			//echo "account $account->id look for userStartDate={$trigger->condition->userStartDate}</br>";
			//echo "after evaluation userStartDate={$trigger->condition->userStartDate}</br>";
		}
		if ($trigger->condition->userExpiryDate && stristr($trigger->condition->userExpiryDate, '{')) {
			$trigger->condition->userExpiryDate = $trigger->condition->evaluateDateVariables($trigger->condition->userExpiryDate);
		}
		
		$sql  = "SELECT ".User::getSelectFields($this->db)." ";
		$sql .= "FROM T_User u, T_Membership m ";

		// TODO: You need to think about filtering by group too.
		//	if (isset($trigger->groupID) && ($trigger->groupID > 0))

		$bindingParams = array();
		$where = array();
		$where[] = "m.F_userID=u.F_UserID";
		$where[] = "m.F_RootID=".$account->id;
		if ($trigger->condition->userStartDate) {
			// v3.3 MySQL Conversion
			//$where[] = "(u.F_StartDate>=convert(datetime,?,120) AND u.F_StartDate<=convert(datetime,?,120))";
			$where[] = "(u.F_StartDate>=? AND u.F_StartDate<=?)";
			$bindingParams[] = $trigger->condition->userStartDate." 00:00:00";
			$bindingParams[] = $trigger->condition->userStartDate." 23:59:59";
		}
		if ($trigger->condition->userExpiryDate) {
			$where[] = "(u.F_ExpiryDate>=? AND u.F_ExpiryDate<=?)";
			$bindingParams[] = $trigger->condition->userExpiryDate." 00:00:00";
			$bindingParams[] = $trigger->condition->userExpiryDate." 23:59:59";
		}
		if ($trigger->condition->contactMethod) {
			$where[] = "(u.F_ContactMethod=? OR u.F_ContactMethod is null)";
			$bindingParams[] = $trigger->condition->contactMethod;
		}
		if (sizeof($where) > 0) {
			$sql .= "WHERE ".implode(" AND ", $where)." ";
		}
		$sql .= "ORDER BY u.F_UserName";
		// Perform the query and create an array of trigger objects from the results
		//echo $sql;
		$triggersRS = $this->db->Execute($sql, $bindingParams);
		
		$result = array();
		
		if ($triggersRS->RecordCount() > 0) {
			while ($triggerObj = $triggersRS->FetchNextObj()) {
			
				// Create the user object
				$user = $this->_createUserFromObj($triggerObj);
				
				$result[] = $user;
			}
		}
		
		return $result;
		
	}
	/*
	 * For updating database changes through triggers.
	 * This should run preset scripts rather than being freeform SQL
	 */
	function updateDatabase($sql) {
		//echo $sql."</br>";
		$this->db->Execute($sql);
	}
	/*
	 * This method creates a new Trigger from an AdoDB object returned by FetchNextObject()
	 */	
	private function _createTriggerFromObj($triggerObj, $timeStamp = null) {
		//echo "build trigger for $timeStamp";
		$trigger = new Trigger($timeStamp);
		$trigger->fromDatabaseObj($triggerObj);
		return $trigger;
	}
	/*
	 * This method creates a new User from an AdoDB object returned by FetchNextObject()
	 */	
	private function _createUserFromObj($triggerObj, $timeStamp = null) {
		//echo "build trigger for $timeStamp";
		$user = new User();
		$user->fromDatabaseObj($triggerObj);
		return $user;
	}	
	/*
	 * This is for running general SQL queries from conditions.
	 * Only run queries that you know to be safe.
	 */
	private function _runSQL($sql) {
		return $this->db->GetArray($sql);
	}

}
?>
