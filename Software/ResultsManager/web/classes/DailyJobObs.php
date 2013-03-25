<?php

class DailyJobObs {
	
	var $db;
	
	function DailyJobObs($db = null) {
		$this->db = $db;
		$this->manageableOps = new ManageableOps($this->db);
		if (version_compare(PHP_VERSION, '5.3.0') >= 0) {
			$this->courseOps = new CourseOps($this->db);
		}
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}
	
	// For archiving expired users from a number of roots.
	// Expected to be run by a daily CRON job
	function archiveExpiredUsers($expiryDate, $roots, $database) {
		
		if (is_array($roots)) {
			$rootList = implode(',', $roots);
		} else if ($roots) {
			$rootList = $roots;
		} else {
			return -1;
		}
		$bindingParams = array($expiryDate);
			
		// Find all the users who we want to expire
		// Note you can't pass rootList in bindingParams as it appears as a quoted string in that case
		$sql = <<<SQL
			SELECT * FROM $database.T_User u, $database.T_Membership m 
			WHERE u.F_ExpiryDate <= ?
			AND u.F_UserID = m.F_UserID
			AND m.F_RootID in ($rootList)
SQL;
		$rs = $this->db->Execute($sql, $bindingParams);

		// Loop round the recordset, inserting to *_Expiry then deleting the related records for each userID
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				
				$this->db->StartTrans();
				
				$userID = $dbObj->F_UserID;
				$bindingParams = array($userID);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Membership_Expiry
					SELECT * FROM $database.T_Membership 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Membership
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Session_Expiry
					SELECT * FROM $database.T_Session 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Session
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Score_Expiry
					SELECT * FROM $database.T_Score 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Score
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_User_Expiry
					SELECT * FROM $database.T_User 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_User
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$this->db->CompleteTrans();
			}
		}
		
		// send back the number of archived users
		return $rs->RecordCount();
		
	}
	
	// To delete records from T_Accounts when the licence has expired and move them to archive table
	function archiveExpiredAccounts($expiryDate, $database) {
		
		// copy the expired records to the expiry tables
		// first records from T_Accounts
		$sql = <<<SQL
			INSERT INTO $database.T_Accounts_Expiry
			SELECT * FROM $database.T_Accounts 
			WHERE F_ExpiryDate <= ?
SQL;
		$bindingParams = array($expiryDate);
		$rs = $this->db->Execute($sql, $bindingParams);

		// Then delete these records
		$sql = <<<SQL
			DELETE FROM $database.T_Accounts 
			WHERE F_ExpiryDate <= ?
SQL;
		$rs = $this->db->Execute($sql, $bindingParams);

		// send back the number of deleted users
		return $this->db->Affected_Rows();
		
	}

	// For archiving older users from a number of roots.
	function archiveOldUsers($roots, $registrationDate, $database = 'rack80829') {
		
		if (is_array($roots)) {
			$rootList = implode(',', $roots);
		} else if ($roots) {
			$rootList = $roots;
		} else {
			return -1;
		}
		$bindingParams = array($registrationDate);
			
		// Find all the users who we want to expire
		// Note you can't pass rootList in bindingParams as it appears as a quoted string in that case
		// Only archive students
		$sql = <<<SQL
			SELECT * FROM $database.T_User u, $database.T_Membership m 
			WHERE u.F_RegistrationDate <= ?
			AND u.F_UserID = m.F_UserID
			AND m.F_RootID in ($rootList)
			AND u.F_UserType = 0
SQL;
		$rs = $this->db->Execute($sql, $bindingParams);

		// Loop round the recordset, inserting to *_Expiry then deleting the related records for each userID
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				
				$this->db->StartTrans();
				
				$userID = $dbObj->F_UserID;
				$bindingParams = array($userID);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Membership_Expiry
					SELECT * FROM $database.T_Membership 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Membership
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Session_Expiry
					SELECT * FROM $database.T_Session 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Session
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_Score_Expiry
					SELECT * FROM $database.T_Score 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_Score
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO $database.T_User_Expiry
					SELECT * FROM $database.T_User 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM $database.T_User
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$this->db->CompleteTrans();
			}
		}
		
		// send back the number of archived users
		return $rs->RecordCount();
		
	}
	
	/*
	 * gh#122 For courses that are published as groupAssigned (the default) see if
	 * 		any groups have units start today. If they do, then get all active users in the groups
	 * 		and send them an email.
	 * 
	 */
	public function getEmailsForGroupUnitStart($today) {

		// Initialise
		$emailArray = array();
		
		$sql = <<<SQL
			SELECT us.*, 
					ar.F_Prefix as prefix, ar.F_LoginOption as loginOption,	a.F_ContentLocation as contentLocation
			FROM T_UnitStart us, T_CourseStart cs, T_AccountRoot ar, T_Accounts a 
			WHERE us.F_CourseID = cs.F_CourseID
			AND us.F_GroupID = cs.F_GroupID
			AND us.F_StartDate = ? 
			AND cs.F_StartMethod = 'group'
			AND ar.F_RootID = cs.F_RootID
			AND ar.F_RootID = a.F_RootID
			AND a.F_ProductCode = 54
			ORDER by us.F_CourseID
SQL;
		$bindingParams = array($today);
		$rs = $this->db->Execute($sql, $bindingParams);

		// Loop round the recordset of groups/units
		$savedCourseID = 0;
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				$courseID = $dbObj->F_CourseID;
				$groupID = $dbObj->F_GroupID;
				$unitID = $dbObj->F_UnitID;
				// TODO. Would it be better to get the whole account object?
				$contentLocation = $dbObj->contentLocation;
				$prefix = $dbObj->prefix;
				$loginOption = $dbObj->loginOption;
				
				// I want to get course and unit data - but that means reading the xml!
				// I would like to put the course name, teacher details, unit name, direct start URL into the email
				// If I order the SQL by group ID, then I can at least do all at once
				$this->courseOps->setAccountFolder('../../'.$GLOBALS['ccb_data_dir'].'/'.$contentLocation);
				
				if ($savedCourseID != $courseID) {
					// Add properties to the course object that we will send to the email
					// TODO. This seems abusive use of the course since we give it properties that are not in the class
					$course = new Course();
					$courseXML = $this->courseOps->getCourse($courseID);
					$courseXML->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
					
					foreach ($courseXML->attributes() as $key => $value)
						$course->{$key} = (string) $value;

					// Grab the unit caption
					$unitXML = $courseXML->xpath("//xmlns:unit[@id='$unitID']");
					foreach ($unitXML[0]->attributes() as $key => $value) {
						if (strtolower($key) == 'caption') {
							$course->unitName = (string) $value;
							break;
						}
					}
					// Add other useful data into the course
					$course->prefix = $prefix;
					$course->loginOption = $loginOption;
					$course->startDate = $today;
			
				}
				
				// Now we need get all the active users in this group
				$userRS = $this->courseOps->getCourseUsersFromGroup($courseID, $groupID, $today);
				
				// Loop round the users and build an email array
				if ($userRS->RecordCount() > 0) {
					while ($userObj = $userRS->FetchNextObj()) {
						$user = new User();
						$user->fromDatabaseObj($userObj);
						
						// Send email IF we have one
						if (isset($user->email) && $user->email) {
							// Just during inital testing - only send emails to me
							// $toEmail = $user->email;
							$toEmail = 'adrian@noodles.hk';
							$emailData = array("user" => $user, "course" => $course);
							$thisEmail = array("to" => $toEmail, "data" => $emailData);
							$emailArray[] = $thisEmail;
							
						}
					}
				}
			}
		}
		return $emailArray;
	}

	/*
	 * gh#122 For courses that are published as userFirstUse 
	 * 		get all active users in the group (and subgroups)
	 * 		check if they have ever used the course, if they have, find the first date
	 * 		see if any subsequent units are a unitInterval multiple of days away from that date
	 * 		send the email
	 * Note: this does NOT send a welcome email, so a course with just one unit never triggers this
	 */
	public function getEmailsForUserUnitStart($today) {

		// Initialise
		$emailArray = array();
		
		$sql = <<<SQL
			SELECT cs.* FROM T_CourseStart cs 
			WHERE cs.F_StartMethod = 'user'
			ORDER by cs.F_CourseID
SQL;
		$bindingParams = array();
		$rs = $this->db->Execute($sql, $bindingParams);

		// Loop round the recordset of courses and groups
		$savedCourseID = 0;
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
				$courseID = $dbObj->F_CourseID;
				$groupID = $dbObj->F_GroupID;
				$rootID = $dbObj->F_RootID;
				$unitsInterval = $dbObj->F_UnitInterval;

				// First do some simple SQL to see if anyone in this root has started the course yet
				// TODO. Or you could call getGroupSubgroups and then check all those groups for finer control
				// but the purpose of this call is to quickly weed out courses that no-one is doing.
				// Note however that this is NOT a quick call - is it worth it?
				$sql = <<<SQL
					SELECT count(*) FROM T_Session s, T_Membership m 
					WHERE s.F_UserID = m.F_UserID
					AND m.F_RootID = ?
SQL;
				$bindingParams = array($rootID);
				$rs1 = $this->db->Execute($sql, $bindingParams);
				
				// Nobody has started this course, so nothing to do
				if ($rs1->RecordCount() <= 0)
					break;
				
				// Then need all the users in this group and subgroups
				$userRS = $this->courseOps->getCourseUsersFromGroup($courseID, $groupID, $today);

				// and find out how many units there are
				if ($savedCourseID != $courseID) {
					$this->courseOps->setAccountFolder('../../'.$GLOBALS['ccb_data_dir'].'/'.'Clarity');
					
					$courseXML = $this->courseOps->getCourse($courseID);
					$courseXML->registerXPathNamespace('xmlns', 'http://www.w3.org/1999/xhtml');
					$units = count($courseXML->xpath("//xmlns:unit"));
					
					// a course with one unit never needs emails
					if ($units <= 1)
						break;
					
					// save the course details for adding to the email
					$course = new Course();
					foreach ($courseXML->attributes() as $key => $value)
						$course->{$key} = (string) $value;
											
				}
				
				// Loop round the users and see if any of them started the course a whole number of unitsInterval ago
				if ($userRS->RecordCount() > 0) {
					while ($userObj = $userRS->FetchNextObj()) {
						$user = new User();
						$user->fromDatabaseObj($userObj);

						// what was this user's first start date for this course?
						$sql = <<<SQL
							SELECT MIN(F_StartDateStamp) as startDate FROM T_Session s 
							WHERE s.F_UserID = ?
							AND s.F_CourseID = ?
SQL;
						$bindingParams = array($user->id, $courseID);
						$sessionRS = $this->db->Execute($sql, $bindingParams);
						
						if (!$sessionRS || $sessionRS->RecordCount() == 0)
							break 1; // this user has not started this course, so goto next user in loop
							
						// Note: requires PHP 5.3 for DateTime
						$userStartDate = new DateTime($sessionRS->FetchNextObj()->startDate);
						
						// we will ignore the first unit since that must have been run already
						for ($i=1; $i<$units; $i++) {
							$userStartDate->add(new DateInterval('P'.$unitsInterval.'D'));
							$today = new DateTime();
							if ($userStartDate->format('Y-m-d') == $today->format('Y-m-d')) {
								
								// You already have the course xml, so just grab the nth unit node
								$unitXML = $courseXML->unit[$i];
								foreach ($unitXML[0]->attributes() as $key => $value) {
									if (strtolower($key) == 'caption') {
										// TODO. Will this correctly save each different $course for every email
										// or do we have pass by reference issues?
										$course->unitName = (string) $value;
										break;
									}
								}
									
								$toEmail = $user->email;
								$emailData = array("user" => $user, "course" => $course);
								$thisEmail = array("to" => $toEmail, "data" => $emailData);
								$emailArray[] = $thisEmail;
								break 1; // found the unit that starts today, so goto next user in loop
							}
						}
						
					}
				}
			}
		}
		return $emailArray;
	}

	// Utility to bring back users from the archive table
	function restoreArchivedTeachers($roots) {
			
		if (is_array($roots)) {
			$rootList = implode(',', $roots);
		} else if ($roots) {
			$rootList = $roots;
		} else {
			return -1;
		}
			
		$sql = <<<SQL
			SELECT * FROM T_User_Expiry u, T_Membership_Expiry m 
			WHERE u.F_UserID = m.F_UserID
			AND m.F_RootID in ($rootList)
			AND u.F_UserType > 0
SQL;
		$rs = $this->db->Execute($sql);
		
		// Loop round the array, inserting to * then deleting the related records for each userID from _Expiry
		if ($rs->RecordCount() > 0) {
			while ($dbObj = $rs->FetchNextObj()) {
						
				$this->db->StartTrans();
				
				$userID = $dbObj->F_UserID;
				$bindingParams = array($userID);
				
				$sql = <<<SQL
					INSERT INTO T_Membership
					SELECT * FROM T_Membership_Expiry 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM T_Membership_Expiry
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$sql = <<<SQL
					INSERT INTO T_User
					SELECT * FROM T_User_Expiry 
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				$sql = <<<SQL
					DELETE FROM T_User_Expiry
					WHERE F_UserID = ?;
SQL;
				$rc = $this->db->Execute($sql, $bindingParams);
				
				$this->db->CompleteTrans();
			}
		}
		
		// send back the number of restored users
		return $rs->RecordCount();
		
	}
	
}
