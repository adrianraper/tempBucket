<?php

class ContentOps {
	
	var $db;
	
	function ContentOps($db) {
		$this->db = $db;
		
		$this->copyOps = new CopyOps();
		$this->manageableOps = new ManageableOps($this->db);
	}
	
	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
		$this->manageableOps->changeDB($db);
	}
	
	// Add optional productCode to allow this to work more efficently with Bento
	function getHiddenContent($productCode=null) {
		if (!Session::is_set('valid_groupIDs'))
			throw new Exception("Unable to get hidden content until manageables have been read for the first time.");
		
		$groupIDArray = Session::get('valid_groupIDs');
		
		AuthenticationOps::authenticateGroupIDs($groupIDArray);
		
		$groupIdInString = join(",", $groupIDArray);

		if ($productCode) {
			$whereClause = " AND F_ProductCode=$productCode ";
		} else {
			$whereClause = '';
		}
		$sql = 	<<<EOD
				SELECT F_GroupID, F_ProductCode, F_CourseID, F_UnitID, F_ExerciseID, F_EnabledFlag
				FROM T_HiddenContent
				WHERE F_GroupID IN ($groupIdInString)
				$whereClause
				ORDER BY F_GroupID
EOD;
		
		$hiddenRS = $this->db->Execute($sql);
		
		$result = array();
		
		// Structure the results as array[groupID] = { F_Product
		while ($hiddenObj = $hiddenRS->FetchNextObj()) {
			if (!isset($result[$hiddenObj->F_GroupID]))
				$result[$hiddenObj->F_GroupID] = array();
			
			// Build the UID of this content object (see Content.as for an explanation of how content IDs are mapped to unique UIDs)
			$uid = "";
			if ($hiddenObj->F_ProductCode != null) $uid = (string)$hiddenObj->F_ProductCode;
			if ($hiddenObj->F_CourseID != null) $uid .= ".".$hiddenObj->F_CourseID;
			if ($hiddenObj->F_UnitID != null) $uid .= ".".$hiddenObj->F_UnitID;
			if ($hiddenObj->F_ExerciseID != null) $uid .= ".".$hiddenObj->F_ExerciseID;
			
			// Add it to the array of hidden content for this group (for a given UID true means visible and false means hidden)
			$result[$hiddenObj->F_GroupID][$uid] = $hiddenObj->F_EnabledFlag == 0;
		}
		
		return $result;
	}
	
	function setHiddenContent($contentIDObject, $groupID, $visible) {
		$this->db->StartTrans();
		
		// Get the group for the given group ID (there will only ever be a single group for this)
		$rootGroupArray = $this->manageableOps->getManageables(array($groupID));
		$rootGroup = $rootGroupArray[0];
		
		// Get the ids of all sub-groups and merge with the given $groupID which gives us all the group IDs to set hidden content for
		$groupIDArray = array_merge(array($groupID), $rootGroup->getSubGroupIds());
		
		// Firstly we need to delete any existing rows in the table with the given ID object as setting new
		// hidden content will overwrite any settings lower down in the tree
		$whereArray = array();
		$groupIdInString = join(",", $groupIDArray);
		if ($contentIDObject['Title']) $whereArray[] = "F_ProductCode=?";
		if ($contentIDObject['Course']) $whereArray[] = "F_CourseID=?";
		if ($contentIDObject['Unit']) $whereArray[] = "F_UnitID=?";
		if ($contentIDObject['Exercise']) $whereArray[] = "F_ExerciseID=?";
		
		// v3.4 Why don't we delete based on UID? Ah, because we want to catch courses in a title, for instance if we only specify the title.
		//$sql = "DELETE FROM T_HiddenContent WHERE F_GroupID IN ($groupIdInString) AND F_HiddenContentUID=?";
		//$this->db->Execute($sql, array(Content::idObjectToUID($contentIDObject)));
		$sql = "DELETE FROM T_HiddenContent WHERE F_GroupID IN ($groupIdInString) AND ".join(" AND ", $whereArray);
		$this->db->Execute($sql, array($contentIDObject['Title'], $contentIDObject['Course'], $contentIDObject['Unit'], $contentIDObject['Exercise']));
		
		foreach ($groupIDArray as $groupID) {
			$dbObj = array();
			
			// SQL Server has a tendency to interpret UID as floats unless we explicitly quote them.
			// TODO: This needs to be tested in MySQL
			$dbObj['F_HiddenContentUID'] = "'".Content::idObjectToUID($contentIDObject)."'";
			$dbObj['F_GroupID'] = $groupID;
			
			$dbObj['F_EnabledFlag'] = ($visible == true) ? 0 : 8;
			$dbObj['F_ProductCode'] = $contentIDObject['Title'];
			$dbObj['F_CourseID'] = $contentIDObject['Course'];
			$dbObj['F_UnitID'] = $contentIDObject['Unit'];
			$dbObj['F_ExerciseID'] = $contentIDObject['Exercise'];
			
			// AR Why am I doing replace, surely the above delete got rid of any row that exists?
			$this->db->Replace("T_HiddenContent", $dbObj, array("F_HiddenContentUID", "F_GroupID"));
		}
		
		$this->db->CompleteTrans();
	}
	// v3.4 Edited content. For this we are not interested in our group and subgroups, but in our group and parents.
	// These are passed. Does it break DKs authentication ops to use these groups? I suspect it does.
	// You will only be passed the root groupID no matter which group in the hierarchy this user is part of.
	// This function has to return all edited content records for all groups.
	// Actually, I can pass this the current users' group and all above, and then merge with the sub-groups which are already found
	// Why do I want to get anything from the subgroups? If an author is editing, her changes always impact her group.
	// Sub-groups will pick this up unless they too have an author who overrules the parent.
	function getEditedContent($groupIDs) {
		if (!Session::is_set('valid_groupIDs'))
			throw new Exception("Unable to get edited content until manageables have been read for the first time.");
		
		// v3.5 Don't pull in subgroups
		
		$groupIDArray = $groupIDs;
		//$groupIDArray = array_unique(array_merge($groupIDs, Session::get('valid_groupIDs')));
		
		// v3.4 Remove authentication. Though I need to talk to DK to work out how to extend or more considerately skip it.
		// Its not as if I am going to do anything other than get information about those groups.
		//AuthenticationOps::authenticateGroupIDs($groupIDArray);
		
		//NetDebug::trace("groupIDArray=".print_r($groupIDArray));
		//echo "groupIDArray=".print_r($groupIDArray);
		$groupIdInString = join(",", $groupIDArray);
		//NetDebug::trace("groupIDString=".$groupIdInString);
		//echo "groupIDString=".$groupIdInString;
		
		//		SELECT F_GroupID, F_EditedContentUID, F_ProductF_ProductCode, F_CourseID, F_UnitID, F_ExerciseID, F_EnabledFlag, F_Mode
		// v3.5 WZ suggests ordering by mode then contentUID. He also prefers to order by hierarchy of groupIDs rather than just groupID.
		//		ORDER BY F_GroupID
		$sql = <<<EOD
				SELECT F_GroupID, F_EditedContentUID, F_RelatedUID, F_EnabledFlag, F_Mode
				FROM T_EditedContent
				WHERE F_GroupID IN ($groupIdInString)
				ORDER BY F_GroupID, F_Mode, F_EditedContentUID 
EOD;
		//throw new Exception("sql=".$sql);
		$editedRS = $this->db->Execute($sql);
		
		$result = array();
		
		// Structure the results as array[groupID] = [ UID, visible ]
		while ($editedRecord = $editedRS->FetchNextObj()) {
			if (!isset($result[$editedRecord->F_GroupID]))
				$result[$editedRecord->F_GroupID] = array();
			
			// Send all the edited content information back
			// v3.5 MySQL returns strings instead of integers
			// See if it still does this with mysqlt driver rather than mysqlt. Yes it does, so do type work here
			// v3.5 Default the sequence number to a very high one to make sorting easier
			// v3.4 WZ doesn't use a sequence number. And we aren't exactly doing much with this are we!
			$editedObj = array("editedContentUID" => $editedRecord->F_EditedContentUID,
								"relatedUID" => $editedRecord->F_RelatedUID,
								"mode" => (int)$editedRecord->F_Mode,
								//"caption" => $editedRecord->F_Caption,
								"sequence"=>(int)1,
								);
			
			// Add it to the array of edited content for this group (for a given UID an entry means edited in some way)
			$result[$editedRecord->F_GroupID][] = $editedObj;
		}
		return $result;
	}
	// v3.4 Editing Clarity Content - moving an exercise simply means adding the edited content record
	// v3.5 No, it isn't that simple. If this ID that I am moving is already the related ID of a different record, 
	// we will need to update that other record so that its related is not me anymore but the one after me.
	// For now, lets just worry about it within 1 group, though this is not strictly correct.
	// So, first see if this relatedID is the relatedID of any other moved or inserted exercises
	// To help with finding new anchors for related moves, lets send the title. Which title if you move AP into TB? Worry later.
	function moveContent($editedUID, $groupID, $relatedUID, $mode, $title) {
		//NetDebug::trace("moving $editedUID as mode=$mode to $relatedUID with title=".$title->productCode);
		$sql = 	<<<EOD
				SELECT F_GroupID, F_EditedContentUID, F_RelatedUID, F_Mode
				FROM T_EditedContent
				WHERE F_GroupID = ?
				AND F_RelatedUID = ?
				AND F_Mode in (2, 3, 4, 5)
				ORDER BY F_Mode, F_EditedContentUID
EOD;
		//throw new Exception("sql=".$sql);
		//$relatedRS = $this->db->Execute($sql, array($groupID, $relatedUID));
		// v3.5 What I really want is to find records related to me
		$relatedRS = $this->db->Execute($sql, array($groupID, $editedUID));
		// For each record that comes back we need to see if we should change it's related ID to us
		// If we are moving before an exercise that is already the relatedID for a move before, then we become the other ones move before.
		if ($relatedRS->RecordCount()>0) {
			//NetDebug::trace("when moving found ".$relatedRS->RecordCount()." record(s) already linked to the moving one.");
		} else {
			//NetDebug::trace("nothing uses me as a relatedID");
		}

		// If there are several records all pointing at me, then they should all end up pointing at the same other exercise (next or prev)
		$nextUID = $title-> getNextExercise($editedUID);
		$prevUID = $title->getPrevExercise($editedUID);
		while ($relatedObj = $relatedRS->FetchNextObj()) {
			//NetDebug::trace("found relatedID");
			// I need to change this other record because it is pointing to me and I am about to move
			// But here I have no idea what the new relatedUID should be do I? If the old mode is move before then it is the next one.
			// Maybe I should just leave it and let the related one move with this one. At least it would kind of make sense.
			// No, it makes no sense!
			if ($relatedObj->F_Mode == 4) {
				// It is rather poor programming, but if the item you are looking for is at the end of the unit, return the last ex as a UID
				// rather than a full exercise class.
				if (isset($nextUID->uid)) {
					//NetDebug::trace("I found a moveBefore {$relatedObj->F_EditedContentUID} that should be re-anchored to NEXT ".$nextUID->uid);
					$this->updateEditedContentRecord($relatedObj->F_EditedContentUID, $relatedObj->F_GroupID, $relatedObj->F_Mode, $nextUID->uid, $relatedObj->F_Mode);
				} else if ($nextUID!=false) {
					//NetDebug::trace("I found a moveAfter {$relatedObj->F_EditedContentUID} that should be re-anchored to NEXT ".$nextUID);
					$this->updateEditedContentRecord($relatedObj->F_EditedContentUID, $relatedObj->F_GroupID, $relatedObj->F_Mode, $nextUID, 5);
				} else {
					//NetDebug::trace("I didn't find the NEXT record.");
				}
			// So, what happens if it used to be after the one I want to move?
			} else if ($relatedObj->F_Mode == 5) {
				// It is rather poor programming, but if the item you are looking for is at the beginning of the unit, return the next ex as a UID
				// rather than a full exercise class. Mind you, I think that moveAfter's only ever happen at the end of the unit.
				if (isset($prevUID->uid)) {
					//NetDebug::trace("I found a moveAfter {$relatedObj->F_EditedContentUID} that should be re-anchored to PREV ".$prevUID->uid);
					$this->updateEditedContentRecord($relatedObj->F_EditedContentUID, $relatedObj->F_GroupID, $relatedObj->F_Mode, $prevUID->uid, $relatedObj->F_Mode);
				} else if ($prevUID!=false) {
					//NetDebug::trace("I found a moveBefore {$relatedObj->F_EditedContentUID} that should be re-anchored to PREV ".$prevUID);
					$this->updateEditedContentRecord($relatedObj->F_EditedContentUID, $relatedObj->F_GroupID, $relatedObj->F_Mode, $prevUID, 4);
				} else {
					//NetDebug::trace("I didn't find the PREV record.");
				}
			}
		}
		// v3.5 But what about checking to see if the item I am moving is moving to a record that 
		// is already acting as an anchor. In otherwords I am getting in between a moved exercise and its anchor.
		// This doesn't matter too much as I just have two records both before another. But if I really play around
		// too much I end up with 0 in the relatedID. Just wonder if it is simpler to do a check and change here.
		// Nope, this isn't working at all.
		/*
		$sql = 	<<<EOD
				SELECT F_GroupID, F_EditedContentUID, F_RelatedUID, F_Mode
				FROM T_EditedContent
				WHERE F_GroupID = ?
				AND F_RelatedUID = ?
				AND F_Mode in (2, 3, 4, 5)
				ORDER BY F_Mode, F_EditedContentUID
EOD;
		//throw new Exception("sql=".$sql);
		$relatedRS = $this->db->Execute($sql, array($groupID, $relatedUID));
		// For each record that comes back we need to see if we should change it's related ID to us
		// If we are moving before an exercise that is already the relatedID for a move before, then we become the other ones move before.
		if ($relatedRS->RecordCount()>0) {
			NetDebug::trace("when moving found ".$relatedRS->RecordCount()." record(s) already linked to where I am going.");
		} else {
			NetDebug::trace("nothing uses where I am going as a relatedID");
		}
		while ($relatedObj = $relatedRS->FetchNextObj()) {
			//NetDebug::trace("found relatedID");
			// I need to change this other record because it is pointing to the place I am about to move to.
			// I should replace it with me. But it isn't a straight me because I might be about to change my unit. 
			// My current unit is 
			$editedUIDList = explode(".",$editedUID);
			$edUIDtitle = $editedUIDList[0];
			$edUIDcourse = $editedUIDList[1];
			$edUIDunit = $editedUIDList[2];
			$edUIDexercise = $editedUIDList[3];
			// Where I am going is
			$relatedUIDList = explode(".",$relatedUID);
			$rUIDtitle = $relatedUIDList[0];
			$rUIDcourse = $relatedUIDList[1];
			$rUIDunit = $relatedUIDList[2];
			$rUIDexercise = $relatedUIDList[3];
			// So the new me is
			$newUID = "$edUIDtitle.$edUIDcourse.$rUIDunit.$edUIDexercise";
			if ($relatedObj->F_Mode == 4) {
				//$xUID = $title->getNextExercise($editedUID);
				// It is rather poor programming, but if the item you are looking for is at the end of the unit, return the last ex as a UID
				// rather than a full exercise class.
				//if (isset($xUID->uid)) {
					NetDebug::trace("I found a moveBefore {$relatedObj->F_EditedContentUID} that should be re-anchored to me ".$newUID);
					$this->updateEditedContentRecord($relatedObj->F_EditedContentUID, $relatedObj->F_GroupID, $relatedObj->F_Mode, $newUID, $relatedObj->F_Mode);
				//} else {
				//	NetDebug::trace("I found a moveAfter {$relatedObj->F_EditedContentUID} that should be re-anchored to NEXT ".$xUID);
				//	$this->updateEditedContentRecord($relatedObj->F_EditedContentUID, $relatedObj->F_GroupID, $relatedObj->F_Mode, $xUID, 5);
				//}
			// So, what happens if it used to be after the one I want to move?
			} else if ($relatedObj->F_Mode == 5) {
				$xUID = $title->getPrevExercise($editedUID);
				// It is rather poor programming, but if the item you are looking for is at the beginning of the unit, return the next ex as a UID
				// rather than a full exercise class. Mind you, I think that moveAfter's only ever happen at the end of the unit.
				if (isset($xUID->uid)) {
					NetDebug::trace("I found a moveAfter {$relatedObj->F_EditedContentUID} that should be re-anchored to PREV ".$xUID->uid);
					$this->updateEditedContentRecord($relatedObj->F_EditedContentUID, $relatedObj->F_GroupID, $relatedObj->F_Mode, $xUID->uid, $relatedObj->F_Mode);
				} else {
					NetDebug::trace("I found a moveBefore {$relatedObj->F_EditedContentUID} that should be re-anchored to PREV ".$xUID);
					$this->updateEditedContentRecord($relatedObj->F_EditedContentUID, $relatedObj->F_GroupID, $relatedObj->F_Mode, $xUID, 4);
				}
			}
		}
		*/		
		$this->insertEditedContentRecord($editedUID, $groupID, $relatedUID, $mode);
	}
	// v3.4 Editing Clarity Content - and so does copy (at least for now)
	function copyContent($editedUID, $groupID, $relatedUID, $mode, $editedContentLocation) {
		$this->insertEditedContentRecord($editedUID, $groupID, $relatedUID, $mode);
		// Perhaps I should also check that the original Author Plus exercise is in the right folder
	}
	// Function to add a record to T_EditedContent for moved and inserted records
	// TODO: Should I be clearing out any old records that apply to this UID? Or conflict with? Yes.
	function insertEditedContentRecord($editedUID, $groupID, $relatedUID, $mode) {
		if (!Session::is_set('valid_groupIDs'))
			throw new Exception("Unable to get edited content until manageables have been read for the first time.");

		// Lets instead see if we can just delete any records that conflict and add ours. Rather than update
		/*
		// First you need to see if this exercise has already been moved, in which case just update that record
		$sql = 	<<<EOD
				SELECT F_GroupID, F_EditedContentUID, F_RelatedUID, F_EnabledFlag, F_Mode
				FROM T_EditedContent
				WHERE F_GroupID = $groupID
				AND F_EditedContentUID = '$editedUID'
				AND F_Mode = $mode
EOD;
		//throw new Exception("sql=".$sql);
		$editedRS = $this->db->Execute($sql);
		if ($editedRS->recordCount() > 0) {
			// update
			$sql = 	<<<EOD
					UPDATE T_EditedContent
					SET F_RelatedUID = '$relatedUID'
					WHERE F_GroupID = $groupID
					AND F_EditedContentUID = '$editedUID'
					AND F_Mode = $mode
EOD;
		} else {
		*/
		// Note that as far as duplicates are concerned, move_before and move_after are identical, likewise insert
		if ($mode == 4 || $mode == 5) {
			$deleteMode='4,5';
		} else if ($mode == 2 || $mode == 3) {
			$deleteMode = '2,3';
		} else {
			$deleteMode = $mode;
		}
		$sql = 	<<<EOD
				DELETE 
				FROM T_EditedContent
				WHERE F_GroupID = $groupID
				AND F_EditedContentUID = '$editedUID'
				AND F_Mode in ($deleteMode)
EOD;
		$deletedRS = $this->db->Execute($sql);
		if ($deletedRS) {
			//NetDebug::trace("deleted {$this->db->Affected_Rows()} duplicate ECC records for $groupID.$editedUID" );
		}
		// insert
		$sql = 	<<<EOD
				INSERT INTO T_EditedContent
				(F_EditedContentUID, F_GroupID, F_Mode, F_RelatedUID)
				VALUES 
				('$editedUID', $groupID,  $mode, '$relatedUID')
EOD;
		//throw new Exception("sql=".$sql);
		return $this->db->Execute($sql);
	}
	// v3.5 New function that updates ECC records if I do something to its relatedUID and mode
	function updateEditedContentRecord($editedUID, $groupID, $mode, $newRelatedUID, $newMode) {
		$sql = 	<<<EOD
				UPDATE T_EditedContent
				SET F_RelatedUID = ?, F_Mode = ?
				WHERE F_EditedContentUID = ?
				AND F_GroupID = ?
				AND F_Mode = ?
EOD;
		//throw new Exception("sql=".$sql);
		return $this->db->Execute($sql, array($newRelatedUID, $newMode, $editedUID, $groupID, $mode));
	}
	// Function to clear the edited content records for a UID
	// Actually, you probably want to match any thing below this UID too.
	// So that if you reset a course, you will reset all exercises in that course.
	// Do that with 
	// AND F_EditedContentUID like '$editedUID%'
	function resetContent($editedUID, $groupID) {
		if (!Session::is_set('valid_groupIDs'))
			throw new Exception("Unable to get edited content until manageables have been read for the first time.");
		
		// You might want a drastic version which does everything for this group
		$sql = 	<<<EOD
				DELETE
				FROM T_EditedContent
				WHERE F_GroupID = $groupID
EOD;
		// v3.5 For inserted content you will pass the % already in the string
		if ($editedUID) {
			if (stristr($editedUID, '%')) {
				$sql.= " AND F_EditedContentUID like '$editedUID'";
			} else {
				$sql.= " AND F_EditedContentUID like '$editedUID%'";
			}
		} else {
			//throw new Exception("you sent an empty UID, so reset for whole group.");
		}
		// v3.5 Also do an integrity check and get rid of anything corrupt. Shouldn't happen, but it is a bit!
		$sql.= " OR F_RelatedUID='0'";
		$sql.= " OR F_RelatedUID is null";
			
		//NetDebug::trace("reset sql=".$sql);
		//throw new Exception("sql=".$sql);
		$editedRS = $this->db->Execute($sql);
		$numDeletedRows = $this->db->Affected_Rows();
		
		//throw new Exception("sql=".$sql);
		// Inserted records have a radically different editedContentUID which points to their AP location
		// So you have to match on their relatedUID. This works for course/unit resetting.
		if ($editedUID) {
			$sql = 	<<<EOD
					DELETE
					FROM T_EditedContent
					WHERE F_GroupID = $groupID
					AND F_Mode in (2,3)
					AND F_RelatedUID like '$editedUID%'
EOD;
			$editedRS = $this->db->Execute($sql);
			$numDeletedRows += $this->db->Affected_Rows();
			
			// Then if you click to reset just that exercise - you have to patch it up from relatedUID(product.course.unit), editedUID(exerciseID)
			$mappedIDs = explode(".", $editedUID);
			if ($mappedIDs[3]) {
				$pcuID = $mappedIDs[0].'.'.$mappedIDs[1].'.'.$mappedIDs[2];
				$exUID = '.'.$mappedIDs[3];
				$sql = 	<<<EOD
						DELETE
						FROM T_EditedContent
						WHERE F_GroupID = $groupID
						AND F_Mode in (2,3)
						AND F_RelatedUID like '$pcuUID%'
						AND F_EditedContentUID like '%$exUID'
EOD;
				$editedRS = $this->db->Execute($sql);
				$numDeletedRows += $this->db->Affected_Rows();
			}
		}
		// You might as well return something like the number of rows deleted
		//return $editedRS;
		return $numDeletedRows;
	}

	// v3.4 Editing Clarity Content - inserting an exercise means 
	//	inserting the edited content record
	//	making sure that everything is ready to call Author Plus (menu.xml, course.xml and the folders)
	//	(the starting Author Plus bit is done from the actionscript)
	function insertContent($newExerciseID, $groupID, $relatedUID, $mode, $editedContentLocation) {
		// Steps. (for more detailed comments see edit - and perhaps share some more code)
		// 1. Make sure that the target folder exists, set it up if not
		//$editedContentPath = dirname($sentToPath).'/../';
		//throw new Exception("editedContentLocation=".$editedContentLocation);
		$editedCourseID = $this->initEditedContent($editedContentLocation, $groupID);
		//throw new Exception("editedCourseID=".$editedCourseID);
		/*
		// We need to tell RM what the courseID is of the AP ECC course so it can direct start AP
		$coursePath = dirname(dirname(dirname(dirname($toPath))))."/course.xml";
		//throw new Exception("course.xml=$coursePath");
		if (!file_exists($coursePath)) {
			throw new Exception("Course doesn't have an index, $coursePath");
			return false;
		}
		// Read the course.xml and get the id of the course node for EditedContent
		//throw new Exception("course.xml=".$toCourse);
		$courseXML = simplexml_load_file($coursePath);
		//throw new Exception("courseList node=".$courseXML->asXML());
		$results = $courseXML->xpath("/courseList/course[@subFolder='EditedContent-$groupID']");		
		//throw new Exception("course node ".$results[0]->asXML());
		//throw new Exception("course id ".$results[0]->attributes()->id);
		$editedCourseID = $results[0]->attributes()->id;
		//throw new Exception("course id $apCourseID");
		*/
		//$newExerciseID = time();
		
		// Add the T_EditedContentRecord
		$UID = "1.$editedCourseID.xx.$newExerciseID";
		$this->insertEditedContentRecord($UID, $groupID, $relatedUID, $mode);
		return array("courseID" => (string) $editedCourseID, "exerciseID" => (string) $newExerciseID);
	}
	
	// v3.4 Request to make sure everything is ready for Author Plus to edit an original exercise
	function checkEditedContentFolder($sentECCPath, $groupID) {
		// v3.5 $sentECCPath has lost the course folder name, need to find it here
		// Or let initEditedContent do it... yes
		// Steps.
		// v3.4 Surely you don't need more relative paths?
		//$ECCPath = "../../".$sentECCPath;
		//throw new Exception("myBase=".__FILE__);
		//throw new Exception("path is : ".$sentECCPath);
		return $this->initEditedContent($sentECCPath, $groupID);
	}		
	// I'm surprised that I am not just sending a UID rather than the whole object. OK change so that you do just pass the UID
	//function checkEditedContentExercise($sentFromPath, $sentToPath, $groupID, $contentIDObject, $caption) {
	// v3.5 Also send exerciseID as path changes
	//function checkEditedContentExercise($sentFromPath, $sentToPath, $groupID, $UID, $caption) {
	function checkEditedContentExercise($sentFromPath, $sentECCPath, $groupID, $UID, $caption, $exerciseID) {
		// Steps.
		// See if the original does exist (hope so!) and the copy doesn't.
		// v3.5 $sentToPath has lost the course folder name, need to find it here
		// So first of all do initEditedContent
		// It should be impossible for the to folder to not exist as we will do an initialisation of the ECC at some point
		// Surely it is just better to call initEditedContent at this point since that will do all the checks as well as correct it if anything is wrong.
		// Or do I want to know if something is wrong as this would be unexpected? I might end up with two folders for the same group for instance.
		// editedContentPath should be like this: ../ap/ADRIAN/Courses/EditedContent-13419
		// $sentToPath is like ../ap/ADRIAN/Courses/EditedContent-13419/Exercises/123456789.xml
		//$editedContentPath = dirname($sentToPath).'/../';
		// v3.6 But initEditedContent will do this for me
		// use dirname twice to move up to the parent folder
		//$editedContentPath = dirname(dirname($sentToPath)); 
		//$editedCourseID = $this->initEditedContent($editedContentPath, $groupID);
		//$sentECCPath = "../../".$ECCPath;
		$editedCourseID = $this->initEditedContent($sentECCPath, $groupID);
		
		$fromPath = "../../".$sentFromPath;
		$toPath = "../../".$sentECCPath;
		$toPath .= "/Courses/".$editedCourseID."/Exercises/".$exerciseID.".xml";
		if (!file_exists($fromPath)) {
			throw new Exception("Original is missing: ".realpath($fromPath));
		}
		/*
		if (!file_exists(dirname($toPath))) {
			if (!mkdir(dirname($toPath), 0777, true)) {
				throw new Exception("Can't make destination folder ".dirname($toPath));
			} else {
				// for a new folder, make an empty menu.xml with at least one unit
				$fromMenuTemplate = $GLOBALS['smarty_template_dir'].'AuthorPlusContent/emptyMenu.xml';
				$toMenu = $toPath.'/../menu.xml';
				// You could look up the product name to add to unit 1 from getProductDetails or something
				// And then maybe use Smarty?
			}
		}
		*/
		if (!file_exists($toPath) && file_exists($fromPath)) {
			// If not, copy it from the original.
			if (!copy($fromPath, $toPath)) {
				throw new Exception("Failed to copy the original file.");
			}
		}
		// Split up the UID - we should write a module in Content.php to help with this
		$mappedIDs = explode(".", $UID);
		$thisExerciseID = $mappedIDs[3];
		
		// Add a node to menu.xml.
		$menuXMLfile = dirname($toPath)."/../menu.xml";
		$menuXML = simplexml_load_file($menuXMLfile);
		//throw new Exception("menu=".$menuXML->item->asXML());
		// Look for any id attribute that matches exerciseID.
		//$results = $menuXML->xpath("/item/item/item[@id='".$contentIDObject['Exercise']."']");
		$results = $menuXML->xpath("/item/item/item[@id='".$thisExerciseID."']");
		//	throw new Exception("matched exercise ".$results[0]->asXML());		
		// If it is already there, then this is a repeat and nothing to do, otherwise
		if (!$results) {
			// Which unit will you add it to? The first unit, last position.
			// Or how about trying to see if there is a unit for this title already?
			// <item unit="1" id="1150969280015" caption="Movie%20time%21" fileName="1150969280015.xml" action="1150969280015" exerciseID="1150969280015" enabledFlag="3" />
			// You can easily add a child with one attribute like this, but to add many attributes, better to get back the simpleXMLElement
			//$unit = $menuXML->item[0]->addChild('item')->addAttribute('caption','Adrian');
			foreach ($menuXML->item[0]->attributes() as $attr => $value) {
				if ($attr == 'unit') {
					$unitNumber = $value;
					break;
				}
			}
			$exercise = $menuXML->item[0]->addChild('item');
			$exercise->addAttribute('caption', $caption);
			$exercise->addAttribute('unit', $unitNumber); // Remember this is unit according to the AP menu.xml, not the original content
			//$exercise->addAttribute('id', $contentIDObject['Exercise']);
			$exercise->addAttribute('id', $thisExerciseID);
			//$exercise->addAttribute('fileName', $contentIDObject['Exercise'].'.xml');
			$exercise->addAttribute('fileName', $thisExerciseID.'.xml');
			$exercise->addAttribute('enabledFlag', 3);
			//throw new Exception("added exercise ".$menuXML->asXML());
			
			// then write it out again
			file_put_contents($menuXMLfile, $menuXML->asXML());
		}
		
		// Get this as return of initEditedContent now
		/*
		// We need to tell RM what the courseID is of the AP ECC course so it can direct start AP
		$coursePath = dirname(dirname(dirname(dirname($toPath))))."/course.xml";
		//throw new Exception("course.xml=$coursePath");
		if (!file_exists($coursePath)) {
			throw new Exception("Course doesn't have an index, $coursePath");
			return false;
		}
		// Read the course.xml and get the id of the course node for EditedContent
		//throw new Exception("course.xml=".$toCourse);
		$courseXML = simplexml_load_file($coursePath);
		//throw new Exception("courseList node=".$courseXML->asXML());
		$results = $courseXML->xpath("/courseList/course[@subFolder='EditedContent-$groupID']");		
		//throw new Exception("course node ".$results[0]->asXML());
		//throw new Exception("course id ".$results[0]->attributes()->id);
		$editedCourseID = $results[0]->attributes()->id;
		//throw new Exception("course id $apCourseID");
		*/
		
		// 3. Check that there is a T_EditedContent record for it, and add if not.
		// You must match the mode too. Because, in theory at least, you can move an edited exercise.
		$relatedUID = "1.$editedCourseID";
		//$this->insertEditedContentRecord(Content::idObjectToUID($contentIDObject), $groupID, $relatedUID, 0);
		$this->insertEditedContentRecord($UID, $groupID, $relatedUID, 0);
		/*
		$sql = 	<<<EOD
				SELECT *
				FROM T_EditedContent
				WHERE F_GroupID = ?
				AND F_EditedContentUID=?
				AND F_Mode=?
EOD;
		//throw new Exception("sql= ".$sql." with '".Content::idObjectToUID($contentIDObject)."'");
		$bindingParams = array($groupID, Content::idObjectToUID($contentIDObject));
		$bindingParams[] = 0; // Edit mode, no RM PHP constants setup yet
		$editedRS = $this->db->Execute($sql, $bindingParams);
		
		if ($editedRS->RecordCount() == 0) {
			$dbObj = array();
			
			// SQL Server has a tendency to interpret UID as floats unless we explicitly quote them.
			// TODO: This needs to be tested in MySQL
			//$dbObj['F_EditedContentUID'] = "'".Content::idObjectToUID($contentIDObject)."'";
			$dbObj['F_EditedContentUID'] = Content::idObjectToUID($contentIDObject);
			$dbObj['F_GroupID'] = $groupID;
			//$dbObj['F_RootID'] = Session::get('rootID');
			
			// We don't need these fields, let UID do it all
			//$dbObj['F_ProductCode'] = $contentIDObject['Title'];
			//$dbObj['F_CourseID'] = $contentIDObject['Course'];
			//$dbObj['F_UnitID'] = $contentIDObject['Unit'];
			//$dbObj['F_ExerciseID'] = $contentIDObject['Exercise'];
			
			$this->db->AutoExecute("T_EditedContent", $dbObj, 'INSERT');			
		}
		*/
		//NetDebug::trace("courseID=$editedCourseID" );
		// I need to return some data that I passed because otherwise it is lost when I get back to Actionscript.
		// Maybe the UID would be better on its own.
		// If you just do this, then you get the value of courseID as id='1231312' instead of just '1231312'
		//return array("courseID" => $editedCourseID, "exerciseID" => $contentIDObject['Exercise']);
		//return array("courseID" => (string) $editedCourseID, "exerciseID" => $contentIDObject['Exercise']);
		return array("courseID" => (string) $editedCourseID, "exerciseID" => $thisExerciseID);
	}
	// v3.4 Function to make sure that a particular group is ready for edited content
	function initEditedContent($editedContentPath, $groupID) {
		$editedContentPath = "../../".$editedContentPath;
		// v3.6 The $editedContentPath was something like ap/ADRIAN/Courses/EditedContent-10379.
		// But we can't have a folder that is not the same as the ID, so $editedContentPath will now be the root
		// ap/ADRIAN
		// And we need to find the id here. Which changes the order of everything.
		// dirname strips the last part of the name away. In our case that is the subfolder
		// Or now we simply need to add '/Courses'
		//$courseXMLPath = dirname(dirname($editedContentPath));
		$courseXMLPath = $editedContentPath;
		$toCourse = $courseXMLPath.'/course.xml';
		//NetDebug::trace("course file=".realpath($toCourse));
		
		// So first thing is to see if course.xml exists
		// make sure that course.xml exists, copy from template if not
		$fromCourseTemplate = $GLOBALS['smarty_template_dir'].'AuthorPlusContent/emptyCourse.xml';
		if (!file_exists($toCourse) && file_exists($fromCourseTemplate)) {
			// If not, copy it from the original.
			if (!copy($fromCourseTemplate, $toCourse)) {
				throw new Exception("Failed to copy empty course.xml.");
				return false;
			}
		}
		// Read the course.xml and make sure that there is a course node for EditedContent
		//throw new Exception("course.xml=".$toCourse);
		$courseXML = simplexml_load_file($toCourse);
		//NetDebug::trace("courseList node=".$courseXML->asXML());
		// v3.5 But, BIG BUT, you can't have a subFolder that is not the same as ID in course.xml. We know this!
		// For a start RM ECC fails, but it also seems that APP export fails too.
		// So we'll add an extra parameter into course.xml that holds the group ID and let us find the course that way
		//$results = $courseXML->xpath("/courseList/course[@subFolder='EditedContent-$groupID']");
		$results = $courseXML->xpath("/courseList/course[@editedContentGroup='$groupID']");
		// v3.4 There is no course for this group - so create one
		if (!$results) {
			//NetDebug::trace("no course for subFolder='EditedContent-$groupID'" );

			//  <course scaffold="menu.xml" subFolder="EditedContent-11576" courseFolder="Courses" enabledFlag="3" 
			//		name="Editing%20Existing%20content" id="1271325199593" /> 
			
			$course = $courseXML->addChild('course');
			//$course-> addAttribute('subFolder', 'EditedContent-'.$groupID);
			$course-> addAttribute('editedContentGroup', $groupID);
			// I want the group name rather than the ID. Seems neatest to look it up rather than passing it.
			$sql =	<<<EOD
				select F_GroupName as groupName
				from T_Groupstructure
				where F_GroupID = $groupID
EOD;
			$rs = $this->db->Execute($sql);
			if ($rs) {
				$recordObj = $rs->FetchNextObj();
				$groupName = $recordObj->groupName;
			} else {
				// If you can't find the group, things are looking bad!
				$groupName = $groupID;
			}
			//throw new Exception("groupname=".$groupName);
			
			$course->addAttribute('name', 'Edited%20content%20for%20'.$groupName);
			// save the ID - note that this gives seconds, not milliseconds like Actionscript so add three digits to keep things consistent
			// would be better to add a random three digit number.
			$courseID = time().'000';
			$course-> addAttribute('id', $courseID);
			// v3.5 Need subfolder to be the same as ID
			$course->addAttribute('subFolder', $courseID);
			$course->addAttribute('author', 'from Results Manager');
			$course->addAttribute('scaffold', 'menu.xml');
			$course->addAttribute('courseFolder', 'Courses');
			$course-> addAttribute('enabledFlag', '3'); 
			// v3.4 New attributes for privacy function
			$course->addAttribute('privacyFlag', '2'); // the default privacy flag should be 'group'
			$course->addAttribute('groupID', $groupID);
			$course->addAttribute('userID', Session::get('userID'));
			// then write it out again
			file_put_contents($toCourse, $courseXML->asXML());
		} else {
			$courseID = $results[0]->attributes()->id;
			//NetDebug::trace("already got subFolder='EditedContent-$groupID' with courseID=$courseID" );
			//NetDebug::trace("already got subFolder with courseID=$courseID" );
		}		
		// Now we can extend our root to include the folder
		$editedContentPath .= '/Courses/'.$courseID;
		
		// Steps, for each of the following, check to see if already there, or...
		// We can assume that the prefix folder exists as that is created when Author Plus is setup
		// Make a folder for this group to edit content in. $toPath = ../../../ap/ADRIAN/Courses/EditedContent-13419
		// Make a folder for this group to put exercises in. $toPath/Exercises
		// Make a folder for this group to put media in. $toPath/Media
		// Add a node to Author Plus's course.xml.
		// Make a an empty menu.xml $toPath/menu.xml
		//throw new Exception("course path=".$coursePath." from ecPath=".$editedContentPath);
		// Actually, these first two are really unnecessary since making /Exericses is recursive and will create them if they are not there.
		/*
		if (!file_exists($coursePath)) {
			if (!mkdir($coursePath, 0777, true)) {
				throw new Exception("Can't make destination folder ".$coursePath);
				return;
			}
		}
		if (!file_exists($toPath)) {
			if (!mkdir($toPath, 0777, true)) {
				throw new Exception("Can't make destination folder ".$toPath);
				return;
			}
		}
		*/
		//throw new Exception("Try to make folder ".$editedContentPath);
		if (!file_exists($editedContentPath.'/Exercises')) {
			if (!mkdir($editedContentPath.'/Exercises', 0777, true)) {
				throw new Exception("Can't make destination folder ".$editedContentPath);
				return false;
			} else {
				//NetDebug::trace("made folder $editedContentPath/Exercises" );
			}
		} else {
			//NetDebug::trace("already got folder $editedContentPath/Exercises" );
		}
		if (!file_exists($editedContentPath.'/Media')) {
			if (!mkdir($editedContentPath.'/Media', 0777, true)) {
				throw new Exception("Can't make destination folder ".$editedContentPath);
				return false;
			}
		}
		
		// for a new folder, make an empty menu.xml with at least one unit
		$fromMenuTemplate = $GLOBALS['smarty_template_dir'].'AuthorPlusContent/emptyMenu.xml';
		$toMenu = $editedContentPath.'/menu.xml';
		if (!file_exists($toMenu)) {
			//NetDebug::trace("make new menu.xml $toMenu" );
			// If not, copy it from the original.
			if (!file_exists($fromMenuTemplate) || !copy($fromMenuTemplate, $toMenu)) {
				throw new Exception("Failed to copy empty menu.xml.");
				return false;
			}
			// Need to add a unique ID to the blank unit
			$menuXML = simplexml_load_file($toMenu);
			//throw new Exception("menu=".$menuXML->item->asXML());
			// Need to put an ID to the menu - you can do the caption when they actually add an exercise
			$results = $menuXML->xpath("/item/item[@id='from Results Manager']");
			if ($results) {
				//throw new Exception("this unit=".$results[0]->asXML());
				// You can't do this as the results from xpath are not a reference to the original.
				// But as below, I think this is not the right place to do this anyway.
				$results[0]->attributes()->id = time().'000';
				// then write it out again
				file_put_contents($toMenu, $menuXML->asXML());
			} else {
				//NetDebug::trace("couldn't find any unit nodes with id=xx" );
			}
			
		} else {
			//NetDebug::trace("already got menu.xml" );
			// Make sure there is at least one unit to add exercises to
			// Maybe this is best done when you actually want to do it, not much point now
		}
		
		// For inserting I need to get the courseID
		//return true;
		return $courseID;
	}

	/**
	 * Returns a list of titles only for the given rootID [DMS]
	 */
	function getTitles($rootID, $onExpiryDate = null, $productCode = null) {
		return $this->parseContent(false, $rootID, true, $onExpiryDate, $productCode);
	}
	
	/*
	 * Returns the content tree for the logged in user
	 * gh#81
	 */
	function getContent($productCodes = null) {
		return $this->parseContent(false, null, false, null, $productCodes);
	}
	
	/*
	 * Returns a restricted content tree (limited by title) - currently used by ProgressWidget
	 */
	function getRestrictedContent($productCode) {
		$allProductCodes = $this->getLicencedProductCodes($productCode);
		$allProductCodes[] = $productCode;
		return $this->parseContent(false,null,false,null,implode(',',$allProductCodes));
	}
	/*
	 * This reads the content out of the context of any account. So it uses defaultContentLocation from T_Product
	 * Needs to pass language code to get this, or accept the first one that comes back from the table.
	 */
	//function getStandaloneContent($productCode) {
	function getStandaloneContent($productCode, $languageCode=null) {
		//echo "getStandaloneContent for $productCode"."<br/>";
		$productDetails = $this->getDetailsFromProductCode($productCode, $languageCode);
		$folder = $this->getContentFolder($productDetails['contentLocation'], $productCode);

		// Build the title (or the relevant bits) and return it
		$thisTitle = new Title();
		$thisTitle-> productCode = $productCode;
		if (intval($productCode) > 1000) {
			// case sensitive
			$thisTitle->indexFile = "Emu.xml";
		} else {
			$thisTitle->indexFile = "course.xml";
		}
		return $this->_buildTitle($thisTitle, $folder, false, false);
	}
	
	/**
	 * This returns the content tree starting from the given idObject.
	 */
	function getContentTreeFromIDObject($idObject) {
		$contentMap = $this->getContentMap();
		
		// Determine the lowest level of object in the idobject (i.e. where we want the tree to start)
		if (isset($idObject['Title'])) {
			$treeRoot = $contentMap[$idObject['Title']];
		} else {
			// At least Title must always exist otherwise something has gone wrong
			throw new Exception("Attempted to get content tree from an idObject which did not contain at least Title");
		}
		
		if (isset($idObject['Course'])) {
			$treeRoot = $treeRoot->courses[$idObject['Course']];
		}
		
		if (isset($idObject['Unit'])) {
			if (!isset($idObject['Course'])) throw new Exception("Attempted to get content tree from an idObject containing Unit with no Course");
			
			$treeRoot = $treeRoot->units[$idObject['Unit']];
		}
		
		if (isset($idObject['Exercise'])) {
			if (!isset($idObject['Course'])) throw new Exception("Attempted to get content tree from an idObject containing Exercise with no Course");
			if (!isset($idObject['Unit'])) throw new Exception("Attempted to get content tree from an idObject containing Exercise with no Unit");

			$treeRoot = $treeRoot->exercises[$idObject['Exercise']];
		}	
		
		return $treeRoot;
	}
	
	/*
	 * Returns the content tree for the logged in user, but mapped as id->object; this is used for matching up content ids in reports
	 * with their content name in O(1) time.
	 */
	function getContentMap() {
		return $this->parseContent(true);
	}
	
	/**
	 * Return the relative location of the content folder
	 * v3.3 Complicate slightly as different titles might have different roots
	 * Currently only applies to Author Plus.
	 */
	function getContentFolder($contentLocation, $productCode=null) {
		//NetDebug::trace("myBase=".__FILE__);
		switch ($productCode) {
			case 1:
				$folder = "../../".$GLOBALS['ap_data_dir']."/".$contentLocation;
				break;
			case 54:
				$folder =  "../../".$GLOBALS['ccb_data_dir']."/".$contentLocation;
				break;
			default:
				$folder =  "../../".$GLOBALS['data_dir']."/".$contentLocation;
		}
		//NetDebug::trace("getContentFolder=$folder");
		return $folder;
	}
	
	/**
	 * Read the account to find enabled titles, then for each get course.xml (or emu.xml) and drill down
	 * TODO. Make productCode an array so that reports can get several, but no need for all.
	 * gh#81 productCode is an array, including negative codes if you want to avoid this one
	 */
	private function parseContent($generateMaps, $rootID = null, $forDMS = false, $onExpiryDate = null, $productCodes = null) {
			
		// If the rootID is not given then default to the session root (this is normal behaviour except for DMS)
		if (!$rootID) $rootID = Session::get('rootID');
		$bindingParams = array($rootID);
		
		// Get all the titles this rootID is registered to use from t_accounts
		// AR.DK suggests joining this on T_Product
		// DK. rather than joining on T_Product we use getTitleCaptionFromProductCode in _buildTitle to get the names
		// v3.4 Order by a preference column in T_Product. Since this is a new field, we should do some error checking
		// to stop RM crashing if it doesn't exist. You can remove this check once you are happy that all databases are up to date.
		// v3.4 This should go, causing crashes if you don't have F_ProductCode=1
		//		WHERE F_ProductCode=1
		$sql =	<<<EOD
				SELECT * FROM T_Product
EOD;
		$columnNames = $this->db->Execute($sql);
		$recordObj = $columnNames->FetchNextObj();
		
		// v3.3 T_Accounts.F_ContentLocation is rarely used, replace with the default from T_ProductLanguage
		$sql  = "SELECT ".Title::getSelectFields($this->db);
		if (isset($recordObj->F_DisplayOrder)) {
			$dbOK = true;
			$sql .=	<<<EOD
					FROM T_Accounts a, T_Product p
					WHERE a.F_RootID = ?
					AND a.F_ProductCode = p.F_ProductCode
EOD;
		} else {
			// Must be an old database
			$dbOK = false;
			$sql .=	<<<EOD
					FROM T_Accounts a
					WHERE a.F_RootID = ?
EOD;
		}
		
		// v3.3. But expiry date might be just the base date, need to add in all day times.
		// Although getAccounts will now null the expiryDate and I doubt anyone else uses it.
		if ($onExpiryDate) {
			$sql .= " AND a.F_ExpiryDate >= '".substr($onExpiryDate,0,10)." 00:00:00' ";
			$sql .= " AND a.F_ExpiryDate <= '".substr($onExpiryDate,0,10)." 23:59:59' ";
		}
			
		// gh#81
		// It seems that nothing uses this as a list yet, but just in case
		if ($productCodes) {
			if (!is_array($productCodes))
				$productCodes = explode(',',$productCodes);
		} else if (!$forDMS) {
			// Unless this is DMS we want to ignore RM (productCode=2)
			$productCodes = array(-2);
		}
		
		/*Due to php version, array_reduce cannot be used in ClartyDevelop.
		if ($productCodes) {
			$sqlInList = array_reduce($productCodes, 
				function($codeArray, $item) {
					if (is_numeric($item) && $item > 0)
						$codeArray[] = $item;
					return $codeArray;
				}, null);
			$sqlNotInList = array_reduce($productCodes,
				function($codeList, $item) {
					if (is_numeric($item) && $item < 0)
						$codeArray[] = abs($item);
					return $codeArray;
				}, null);
			if ($sqlInList) $sql .= ' AND a.F_ProductCode in ('.implode(',',$sqlInList).')';
			if ($sqlNotInList) $sql .= ' AND a.F_ProductCode not in ('.implode(',',$sqlNotInList).')';
		}*/
		if ($productCodes) {
			$sql .= " AND a.F_ProductCode in ($productCodes)";
		}
					
		if ($dbOK) 
			$sql .= " ORDER BY p.F_DisplayOrder";
		
		// Perform the query and create a Group object from the results
		//NetDebug::trace("parseContent=".$sql."with ".implode(", ",$bindingParams));
		//echo $sql;
		$titlesRS = $this->db->Execute($sql, $bindingParams);
		//NetDebug::trace("records=".$titlesRS->RecordCount());
		
		$titles = array();
		
		// v3.1 Add in emus as well as courses. Currently this is based on F_ProductCode>1000 is an Emu.
		// TODO: would be better to have F_ProductType
		if ($titlesRS->RecordCount() > 0) {
			while ($titleObj = $titlesRS->FetchNextObj()) {
				// v3.3 There are some details we need from T_Product and T_ProductLanguage
				
				//NetDebug::trace("getDetails for =".$titleObj->F_ProductCode." and ".$titleObj->F_LanguageCode);
				$productDetails = $this->getDetailsFromProductCode($titleObj->F_ProductCode, $titleObj->F_LanguageCode);
				$titleObj->name = $productDetails['name'];
				// v3.3 This will now usually be picked up from T_ProductLanguage as the default
				// At this point we know if there is a specific content location set in T_Accounts. If there is, just use that
				// v3.4 If your database has an empty string rather than null, this will trigger.
				//if (isset($titleObj->F_ContentLocation)) {
				if (isset($titleObj->F_ContentLocation) && $titleObj->F_ContentLocation!='') {
					//NetDebug::trace("specific folder for ".$productDetails['name']);
					//AbstractService::$debugLog->notice("specific folder for ".$productDetails['name']);
					$folder = $this->getContentFolder($titleObj->F_ContentLocation, $titleObj->F_ProductCode);
				} else {
					// otherwise we need to use the language code we just picked up to find the default location
					//NetDebug::trace("default folder for ".$productDetails['name']." is ".$productDetails['contentLocation']);
					$folder = $this->getContentFolder($productDetails['contentLocation'], $titleObj->F_ProductCode);
				}
				
				// v3.4 How about we save the folder into $title->contentLocation so that RM or DMS can use it if necessary?
				// It can only be used for display purposes, not updated.
				// And I don't want the full folder path. Just that relative to the main app I suppose.
				// That means taking off "../../" that getContentFolder hardcodes on.
				// v3.5 But the moment you put it into the titleObj, when you save anything in DMS this will save too.
				// What was I doing with it anyway? It is used in editContent.
				// Look, the data we need comes from one of two places. Usually it is read from T_ProductLanguage
				// but sometimes it comes from T_Accounts. So after we have worked out which, we don't want to save it
				// in a database related field otherwise it will get written back out. So...
				//$titleObj->F_ContentLocation = substr($folder,6);
				
				// v3.1 Is this title is an emu or a regular Clarity course?
				// v3.5 Or is it a new Bento title?
				//NetDebug::trace("this folder is ".$folder);
				//NetDebug::trace("this product is code=".$titleObj->F_ProductCode);
				//NetDebug::trace("this lang is code=".$titleObj->F_LanguageCode);
				if (intval($titleObj->F_ProductCode) > 1000) {
					// case-sensitive
					$titleObj->indexFile = "Emu.xml";
					$courseType = 'emu';	
				// For Road to IELTS 2
				} else if ((intval($titleObj->F_ProductCode) == 52) || 
							(intval($titleObj->F_ProductCode) == 53)) {
					$courseType = 'bento';	
					switch ($titleObj->F_ProductVersion) {
						case 'R2ILM':
							$productVersionName = "LastMinute";
							break;
						case 'R2ITD':
							$productVersionName = "TestDrive";
							break;
						case 'R2IFV':
							$productVersionName = "FullVersion";
							break;
						case 'R2IHU':
							$productVersionName = "HomeUser";
							break;
						case 'R2ID':
							$productVersionName = "Demo";
							break;
						default:
							$productVersionName = 'x';
					}
					if (intval($titleObj->F_ProductCode) == 52) {
						$version = "Academic";
					} else {
						$version = "GeneralTraining";
					}					
					$titleObj->indexFile = "menu-$version-$productVersionName.xml";
					
				} else if (intval($titleObj->F_ProductCode) == 54) {
					$courseType = 'rotterdam';	
					$titleObj->indexFile = "courses.xml";
				 
				} else {
					$courseType = 'orchid';	
					$titleObj->indexFile = "course.xml";
				}
				// Build the title object (if the course.xml file doesn't exist then just skip it. However, if we are in $forDMS
				// mode then this is DMS and we want to display everything, even if course.xml doesn't exist.
				//NetDebug::trace("get content from =".$folder."/".$titleObj->indexFile);
				//AbstractService::$log->notice("get content from =".$folder."/".$titleObj->indexFile);

				if ($forDMS || file_exists($folder."/".$titleObj->indexFile)) {
					if ($courseType == 'bento') {
						$rs = $this->_buildBentoTitle($this->_createTitleFromObj($titleObj), $folder, $generateMaps, $forDMS, $courseType);
					} else {	
						$rs = $this->_buildTitle($this->_createTitleFromObj($titleObj), $folder, $generateMaps, $forDMS, $courseType);
					}
					if ($generateMaps) {
						//echo "this product is code=$titleObj->F_ProductCode and file=$titleObj->indexFile<br/>"; // break 1;
						$titles[$titleObj->F_ProductCode] = $rs;
					} else {
						// Build the title and add it to the array
						$titles[] = $rs;
					}
				}
			}
        }
		
		return $titles;
	}
		
	/**
	 * Build the titles for a given Bento product.
	 *
	 * @param String The folder containing the menu.xml file
	 * @param String The product code
	 * @return Array An Array of Title objects
	 */
	private function _buildBentoTitle($title, $folder, $generateMaps = false, $forDMS = false, $courseType = 'orchid') {
		// Replace backslashes with forward slashes for Windows/Unix independence
		// PHP 5.3
		$folder = preg_replace("/\\\\/", "/", $folder);
		
		// v3.5 We have worked out which folder to use, and now need to save that in the title object
		// It isn't done in createTitleFromObj because this is NOT a direct database field
		// The direct db field is dbContentLocation
		//NetDebug::trace("ContentOps: _buildBentoTitle=".$folder."/".$title->indexFile);
		$title->contentLocation = substr($folder, 6);
		
		//$title->name = $folder;
		//$title->caption = $this->getTitleCaptionFromProductCode($title->productCode);
		//NetDebug::trace("ContentOps: _buildTitle for ".$title-> productCode);
		// v3.3 Since you have to read product details before you call this to get the folder, can we get the name at the same time?
		//$title-> name = $this->getTitleCaptionFromProductCode($title-> productCode);
		// v3.3 What do I use this for?
		//$title->softwareLocation = $this->getTitleSoftwareLocationFromProductCode($title->productCode);
		
		// If we only want titles then stop here and don't load any more
		if ($forDMS) return $title;
		
		$doc = new DOMDocument();
		//NetDebug::trace("read folder=".$folder."/".$title->indexFile);
		// v3.2 Extra protection in case folders are missing
		if (!file_exists($folder."/".$title->indexFile)) {
			throw new Exception("missing title ".$folder."/".$title->indexFile);
		}
		$this->_loadFileIntoDOMDocument($doc, $folder."/".$title->indexFile);
		
		// Bento titles have course nodes
		$coursesXML = $doc->getElementsByTagName("course");
		
		// v3.5 For AP privacy
		$myType = Session::get('userType');
		
		// v3.8 Get course tree for Bento title
		foreach ($coursesXML as $courseXML) {
			
			// TODO. Privacy flags
				
			$course = new Course();
			$course->setParent($title);
			$course->id = $courseXML->getAttribute("id");
			$course->name = urldecode($courseXML->getAttribute("caption"));
			$course->enabledFlag = $courseXML->getAttribute("enabledFlag");
			//NetDebug::trace("ContentOps: course=".$course->name);
				
			$course->units = $this->_buildBentoUnits($courseXML, $course, $generateMaps, $courseType);
			//issue:#23
			$course-> totalUnits = count ($course-> units);
				
			if ($course->id != null) { // Ticket #104 - don't add content with missing id
				if ($generateMaps) {
					$title->courses[$course->id] = $course;
				} else {
					$title->courses[] = $course;
				}
				//NetDebug::trace("courses from ".$this->indexFile."-".$course-> id);	
			}
		}		
		return $title;
	}
	private function _buildBentoUnits($courseXML, $course, $generateMaps = false, $courseType = 'bento') {
		// As well as passing each unit node, need get group node down to the exercise level
		return $this->_buildUnits($courseXML->getElementsByTagName("unit"), $course, $generateMaps, $courseType, $courseXML->getElementsByTagName("group"));
	}

	/**
	 * Build the titles for a given folder and product code.
	 *
	 * @param String The folder containing the course.xml file
	 * @param String The product code
	 * @return Array An Array of Title objects
	 */
	private function _buildTitle($title, $folder, $generateMaps = false, $forDMS = false, $courseType = 'orchid') {
		// Replace backslashes with forward slashes for Windows/Unix independence
		// PHP 5.3
		$folder = preg_replace("/\\\\/", "/", $folder);
		
		// v3.5 We have worked out which folder to use, and now need to save that in the title object
		// It isn't done in createTitleFromObj because this is NOT a direct database field
		// The direct db field is dbContentLocation
		$title->contentLocation = substr($folder, 6);
		
		//$title->name = $folder;
		//$title->caption = $this->getTitleCaptionFromProductCode($title->productCode);
		//NetDebug::trace("ContentOps: _buildTitle for ".$title-> productCode);
		// v3.3 Since you have to read product details before you call this to get the folder, can we get the name at the same time?
		//$title-> name = $this->getTitleCaptionFromProductCode($title-> productCode);
		// v3.3 What do I use this for?
		//$title->softwareLocation = $this->getTitleSoftwareLocationFromProductCode($title->productCode);
		
		// If we only want titles then stop here and don't load any more
		if ($forDMS) return $title;
		
		$doc = new DOMDocument();
		//NetDebug::trace("read folder=".$folder."/".$title->indexFile);
		// v3.2 Extra protection in case folders are missing
		if (!file_exists($folder."/".$title->indexFile)) {
			throw new Exception("missing title ".$folder."/".$title->indexFile);
		}
		$this->_loadFileIntoDOMDocument($doc, $folder."/".$title->indexFile);
		
		// If there is a title node (expecting only one), then get its contents. This is where we will find if an EMU has other licencedProductCodes.
		// Regular Clarity courses don't have a title node
		$titleXML = $doc->getElementsByTagname("title")->item(0);
		if ($titleXML) {
			$title->licencedProductCodes = $titleXML->getAttribute("licencedProductCodes");
		}
		
		$coursesXML = $doc->getElementsByTagName("course");
		
		// v3.5 For AP privacy
		$myType = Session::get('userType');
		
		// v3.3 Can you cope with a course tree as in MyCanada?
		// If it is too difficult to display the tree, can we at least just pull out the leafs from just one file
		// #trac 131 fixed
		foreach ($coursesXML as $courseXML) {
			
			// See if this node is a bare course node with children
			// It it does, then just ignore it and traverse
			// But the emu.xml course node DOES have children that we want, so can't be this simple. 
			// MyCanada course folder nodes don't have IDs.
			if ($courseXML->hasChildNodes() && !$courseXML->getAttribute("id")) {
				//NetDebug::trace("ContentOps: item ".$courseXML->getAttribute("name")." skipped as not a course leaf");
			} else {
				// v3.5 First of all, do the privacy flags allow us to see this course?
				// No, first, are you an administrator?
				$privacyFlag = $courseXML->getAttribute("privacyFlag");
				if ($myType == User::USER_TYPE_ADMINISTRATOR) {
					// You can see anything
				} else if ($privacyFlag == 2 || $privacyFlag == 8) {
					// You can only see this if you are in the same group - or if you are the administrator
					$allowedGroup = $courseXML->getAttribute("groupID");
					// TODO. Are you sure this shouldn't be valid_groupIDs??
					$groupIDArray = Session::get('groupIDs');
					$groupIdInString = join(",", $groupIDArray);
					//NetDebug::trace("privacy flag for ".$courseXML->getAttribute("name")." is ".$privacyFlag." and group=".$allowedGroup." you are ".$groupIdInString);
					if (!stristr($groupIdInString, $allowedGroup)) {
						// None of your groups matches the allowed group, so you can't see this course
						//NetDebug::trace("blocked as not in group");
						continue;
					}
				} else if ($privacyFlag == 1) {
					// You can only see this if you are the author
					$owner = $courseXML->getAttribute("userID");
					$thisUserID = Session::get('userID');
					//NetDebug::trace("privacy flag for ".$courseXML->getAttribute("name")." is ".$privacyFlag." and owner=".$owner." you are ".$thisUserID);
					if ($owner!=$thisUserID) {
						// This is not your course, so don't display it
						//NetDebug::trace("blocked as not owner");
						continue;
					}
				// If it isn't private, than anyone can see it (really means privacyFlag==4)
				} else {
					// everyone can see this, so just go ahead
				}
				
				//NetDebug::trace("ContentOps: course'".$courseXML->getAttribute("id")." enableDate=".$courseXML->getAttribute("enableDate"));
				$course = new Course();
				$course->setParent($title);
				$course->id = $courseXML->getAttribute("id");
				//NetDebug::trace("ContentOps: courseID'".$course->id);
				$course->name = urldecode($courseXML->getAttribute("name"));
				$course->enabledFlag = $courseXML->getAttribute("enabledFlag");
				
				// v3.1 Split code based on emu or regular
				//NetDebug::trace($title->productCode." read folder=".$folder);
				if (intval($title->productCode) < 1000) {
					// Ticket #104 - if a required attribute is missing throw an error message
					if ($course-> id != null && ($courseXML->getAttribute("courseFolder") == null || $courseXML->getAttribute("subFolder") == null)) {
						// More useful to return a message than throw an exception.
						$course-> name .= " (This course has something wrong with it.)";
						//return;
						//throw new Exception($this->copyOps->getCopyForId("corruptXMLError", array("errorMessage" => "courseFolder/subFolder missing in course id ".$courseXML->getAttribute("id"))));
					} else {
						$subFolder = $folder."/".$courseXML->getAttribute("courseFolder")."/".$courseXML->getAttribute("subFolder");
						$course-> units = $this->_buildUnitsFromFile($subFolder, $courseXML->getAttribute("scaffold"), $course, $generateMaps, $courseType);
						//issue:#23
						$course-> totalUnits = count ($course-> units);
					}
				} else {
					// Ticket #104 - if a required attribute is missing throw an error message
					//if ($course->id != null && ($courseXML->getAttribute("enableDate") == null))
					//	throw new Exception($this->copyOps->getCopyForId("corruptXMLError", array("errorMessage" => "enableDate is missing in course ".$courseXML->getAttribute("id"))));
					$course->units = $this->_buildUnitsFromXML($courseXML, $course, $generateMaps, $courseType);
				}
				
				if ($course->id != null) { // Ticket #104 - don't add content with missing id
					if ($generateMaps) {
						$title->courses[$course->id] = $course;
					} else {
						$title->courses[] = $course;
					}
					//NetDebug::trace("courses from ".$this->indexFile."-".$course-> id);	
				}
			}
		}		
		return $title;
	}
	
	/**
	 * Build the units for a given folder and filename (a menu.xml file).  
	 * Or from the emu.xml
	 * NEXT LINE no longer true.
	 * The course is also given as a parameter as the caption is defined in the root of menu.xml so needs to be set after loading this.
	 * When the units are in an emu, just need the XMl to build units, not a full menu.xml file
	 *
	 * @param String The folder containing the menu.xml file
	 * @param String the name of the menu.xml file (this is almost always 'menu.xml', but could be something different)
	 * @param Course The course these units belong to.  This is given because the course caption is actually defined in this xml file
	 * @return Array An Array of Unit objects
	 */
	private function _buildUnitsFromFile($folder, $filename, $course, $generateMaps = false, $courseType = 'orchid') {
		// Replace backslashes with forward slashes for Windows/Unix independence
		// PHP 5.3
		$folder = preg_replace("/\\\\/", "/", $folder);
		
		$doc = new DOMDocument();
		// v3.3 Whilst it should be impossible for this file to not exist, it can happen somehow for an empty course in AP.
		// In which case just ignore it and go on rather than crashing please.
		if (!file_exists($folder."/".$filename)) {
			// Put some kind of note onto the tree that there was an error with this course?
			$course->name .= " (This course has something wrong with it.)";
			return;
		}
		$this->_loadFileIntoDOMDocument($doc, $folder."/".$filename);
		
		// This picks up the course caption from menu.xml, but I think it is better picked up from course.xml
		// $course->caption = urldecode($doc->documentElement->getAttribute("caption"));
		
		$xpath = new DOMxpath($doc);
		return $this->_buildUnits($xpath->evaluate("/item/item"), $course, $generateMaps, $courseType);
	}
	private function _buildUnitsFromXML($courseXML, $course, $generateMaps = false, $courseType = 'orchid') {
		return $this->_buildUnits($courseXML->getElementsByTagName("unit"), $course, $generateMaps, $courseType);
	}
	/**
	 * Find all the units in a course.
	 * @return Array An Array of Unit objects
	 */
	private function _buildUnits($unitsXML, $course, $generateMaps = false, $courseType = 'orchid', $groupXML = null) {
		
		$units = array();
		foreach ($unitsXML as $unitXML) {
			// v3.0.5 I could duplicate the check on enabledFlag in _buildExercises rather than basing it on special unit numbers.
			//if ($unitXML->getAttribute("unit") > "0") {  // DK: Uncomment this if clause if you want to ignore special units (certificates etc)

			//NetDebug::trace("ContentOps: unitXML, eF=".$unitXML->getAttribute("enabledFlag"));
			if ((intval($unitXML->getAttribute("enabledFlag")) & 8) || 
				(intval($unitXML->getAttribute("enabledFlag")) & 128) || 
				(!(intval($unitXML->getAttribute("enabledFlag")) & 3))) {
				// So this is a special unit that RM should not show.
			} else {
				$unit = new Unit();
				$unit->setParent($course);
				// For some reason the unit ID is stored in @unit, not @id. NO. The id is id, unit is a sequential thing.
				// But all of RM is built around these sequential 'unit numbers', because Orchid writes this to the database.
				// I am just going to have to live with this. Store the sequence number in case you can make it work.
				// So, if there is no unit attribute, use the id (this will be the case with all emus)
				$unit->id = $unitXML->getAttribute("unit") == "" ? $unitXML->getAttribute("id") : $unitXML->getAttribute("unit"); 
				$unit->sequenceNum = $unitXML->getAttribute("unit");
				// v3.4 For Protea, we are now saving the correct ID for unit in T_Score. So need to keep BOTH here.
				$unit->unitID = $unitXML->getAttribute("id");
				// v3.1 All old menu.xml have caption rather than name, but standardise on name.
				$unit->name = urldecode($unitXML->getAttribute("name")=="" ? $unitXML->getAttribute("caption") : $unitXML->getAttribute("name"));
				//$unit->caption = urldecode($unitXML->getAttribute("caption"));
				$unit->enabledFlag = $unitXML->getAttribute("enabledFlag");
				
				// v3.1 EMU information needed
				//$unit->licencedProductCode = $unitXML->getAttribute("licencedProductCode");
				//NetDebug::trace("ContentOps: unitXML, name=".$unit->name);

				$unit->exercises = $this->_buildExercises($unitXML, $unit, $generateMaps, $courseType, $groupXML);
                //issue:#23
				$unit-> totalExercises = count ($unit-> exercises);		
				
				if ($unit->id != null) { // Ticket #104 - don't add content with missing id
					if ($generateMaps) {
						$units[$unit->id] = $unit;
					} else {
						$units[] = $unit;
					}
					//NetDebug::trace("units from ".$this->indexFile."-".$unit->id);
				}
			}
		}
		
		return $units;
	}
	/**
	 * Build the exercises from a given item node.  Since the exercise details are defined in menu.xml this method does not take
	 * a filename.
	 *
	 * @param DOMElement The course node containing the exercises
	 * @return An array of exercise objects
	 */
	private function _buildExercises($unitXML, $unit, $generateMaps = false, $courseType = 'orchid', $groupXML = null) {
		if ($courseType == 'bento') {
			$exercisesXML = $unitXML->getElementsByTagName("exercise");
		} else {
			$exercisesXML = $unitXML->getElementsByTagName("item");
		}
		
		$exercises = array();
		
		foreach ($exercisesXML as $exerciseXML) {
			//NetDebug::trace("items from emu ".$exerciseXML->getAttribute("name"));		
			//if ($exerciseXML->getAttribute("id") > "100") {  // Use this to ignore special exercises (test banks, navigation etc)
			// v3.0.5 I want a way to stop special exercises from appearing in RM. Use the enabledFlag from menu.xml
			// If we have set an exercise to no-navigation and no-menu, then block it. Likewise disabled.
			// We may well set an exercise to question bank, yet still want to know about it.
			// For navigation exercises I can't set 8 or remove 2. So I'll need an extra flag. nonDisplay=128
			if ((intval($exerciseXML->getAttribute("enabledFlag")) & 8) || 
				(intval($exerciseXML->getAttribute("enabledFlag")) & 128) || 
				(!(intval($exerciseXML->getAttribute("enabledFlag")) & 3))) {
				// So this is a special exercise that RM should not show.
			} else {
				$exercise = new Exercise();
				$exercise->setParent($unit);
				// AR we should read id, not exerciseID which is a legacy attribute
				//$exercise->id = $exerciseXML->getAttribute("exerciseID");
				$exercise->id = $exerciseXML->getAttribute("id");
				// v3.1 Make sure we read either the name or the caption from the XML, but always save as name in our class.
				// For R2I we need to add a group name to the exercise since it is not really in the hierarchy, but essential for organising the report
				$groupCaption = null;
				if ($courseType == 'bento') {
					if ($exerciseXML->getAttribute("group") && $groupXML) {
						//NetDebug::trace("group id=".$exerciseXML->getAttribute("group"));
						// TODO. It would make sense to use xpath here, but our XML is built on DOM document rather than simple_xml
						// For now just do a quick loop.
						// $results = $groupXML->xpath("/group[@id='".$exerciseXML->getAttribute("group")."']");
						foreach ($groupXML as $groupNode) {
							if ($groupNode->getAttribute("id") == $exerciseXML->getAttribute("group")) {
								$groupCaption = (string) $groupNode->getAttribute("caption");
								break;
							}
						}
					}
				}
				$exercise->name = urldecode($exerciseXML->getAttribute("name")=="" ? $exerciseXML->getAttribute("caption") : $exerciseXML->getAttribute("name"));
				if ($groupCaption) {
					$exercise->name = $groupCaption.': '.$exercise->name;
				}
				//$exercise->caption = urldecode($exerciseXML->getAttribute("caption"));
				$exercise->enabledFlag = $exerciseXML->getAttribute("enabledFlag");
				// v3.1 EMU information needed
				//$exercise->licencedProductCode = $exerciseXML->getAttribute("licencedProductCode");
				$exercise->trackableID = $exerciseXML->getAttribute("trackableID");
				$exercise->maxScore = $exerciseXML->getAttribute("maxScore");
				// v3.4.1 Editing Clarity Content. Bug #132
				if ($courseType == 'bento') {
					$exercise->filename = $exerciseXML->getAttribute("href");
				} else {
					$exercise->filename = $exerciseXML->getAttribute("fileName");
				}

				if ($exercise->id != null) { // Ticket #104 - don't add content with missing id
					if ($generateMaps) {
						$exercises[$exercise->id] = $exercise;
					} else {
						$exercises[] = $exercise;
					}
					//NetDebug::trace("items from ".$this->indexFile."-".$exercise->id);	
				}
			}
		}
		
		return $exercises;
	}
	
	private function _loadFileIntoDOMDocument($doc, $filename) {
		// Load the filename into a string
		$xmlString = file_get_contents($filename);
		
		// The current Clarity XML is not well-formed in that it contains & characters, so go through and replace this with the correct
		// html entity before passing to the libxml parser.
		// PHP 5.3
		$xmlString = preg_replace('/&/', "&amp;", $xmlString);
		
		// Create the XML document from the string
		$doc->loadXML($xmlString, LIBXML_COMPACT);
	}
	
	/*
	 * This method creates a new Title from an AdoDB object returned by FetchNextObject()
	 */
	private function _createTitleFromObj($titleObj) {
		$title = new Title();
		$title->fromDatabaseObj($titleObj);
		return $title;
	}

	/*
	 * NOT USED as AccountOps will give me all titles that an account has access too anyway.
	 * Except that we read the emu to work out what titles to create with our account script, so it does need to be there.
	 * But we will only save it at title level.
	 * This very specific method will retrieve the whole content object for a product code and return
	 * the productCodes for any nodes that have a licencedProductCode attribute.
	 * If you already have the title, just race through it.
	 */
	public function getLicencedProductCodes($productCode, $title=null) {
		//echo "ContentOps.getLicencedProductCodes for $productCode <br/>";
		if ($title==null) {
			$title = $this->getStandaloneContent($productCode);
		}
		if (isset($title->licencedProductCodes) && $title->licencedProductCodes>0) {
			return explode(",",$title->licencedProductCodes);
		} else {
			return array();
		}
		/*
		$licencedProductCodes = array();
		//echo print_r($title);
		foreach ($title->courses as $course) {
			echo "ContentOps.checking course $course->name <br/>";
			if (isset($course-> licencedProductCode) && $course->licencedProductCode>0) {
				$licencedProductCodes[] = $course-> licencedProductCode;
			}
			foreach ($course->units as $unit) {
				echo "ContentOps.checking unit $unit->name <br/>";
				if (isset($unit-> licencedProductCode) && $unit->licencedProductCode>0) {
					$licencedProductCodes[] = $unit-> licencedProductCode;
				}
				foreach ($unit->exercises as $exercise) {
					echo "ContentOps.checking item $exercise->name <br/>";
					if (isset($exercise-> licencedProductCode) && $exercise->licencedProductCode>0) {
						$licencedProductCodes[] = $exercise-> licencedProductCode;
					}
				}
			}
		}
		
		return $licencedProductCodes;
		*/
	}
	/**
	 * Look in T_Product to get the title (caption) from the product code
	 * and the software location
	 */
	private function getTitleCaptionFromProductCode($productCode) {
		$rs = $this->db->getRow("SELECT F_ProductName FROM T_Product WHERE F_ProductCode=?", array($productCode));
		return ($rs['F_ProductName']) ? $rs['F_ProductName'] : "[Unknown product ID '$productCode']";
	}
	// v3.3 What do I use thsi for? If I do get it, surely it should come from T_ProductLangauge
	//private function getTitleSoftwareLocationFromProductCode($productCode) {
	//	$rs = $this->db->getRow("SELECT F_SoftwareLocation FROM T_Product WHERE F_ProductCode=?", array($productCode));
	//	return ($rs['F_SoftwareLocation']) ? $rs['F_SoftwareLocation'] : "[Unknown product ID '$productCode']";
	//}
	
	// v3.3 A version where you know the language code too
	//public function getDetailsFromProductCode($productCode) {
	//And drop softwareLocation as not used
	public function getDetailsFromProductCode($productCode, $languageCode=null) {
		$rs = $this->db->getRow("SELECT * FROM T_Product WHERE F_ProductCode=?", array($productCode));
		$partialReturn =  array('name' => ($rs['F_ProductName']) ?  $rs['F_ProductName'] : "[Unknown product ID '$productCode']"
					//,'softwareLocation' => $rs['F_SoftwareLocation']
					,'productCode' => $productCode
					//,'contentLocation' => $rs['F_DefaultContentLocation']
					);
		// v3.3 get contentLocation from T_ProductLanguage
		$sql = "SELECT * FROM T_ProductLanguage WHERE F_ProductCode=? ";
		$bindingParams = array($productCode);
		if (is_null($languageCode)) {
		} else {
			$sql.= "AND F_LanguageCode=?";
			$bindingParams[] = $languageCode;
		}
		// If you got more than one row because you didn't specify the language, just take the first as a default
		//NetDebug::trace("sql=".$sql);
		//echo "$sql with ".print_r($bindingParams)."<br/>";
		// v3.3 What if you get zero rows because this productCode and languageCode combo doesn't exist?
		$rs = $this->db->getRow($sql, $bindingParams);
		if ($rs) {
			$partialReturn['contentLocation'] = $rs['F_ContentLocation'];
		// Shouldn't happen, but it might!
		// I suppose we should redo the call with no languageCode to pick up the default
		} else {
			$sql = "SELECT * FROM T_ProductLanguage WHERE F_ProductCode=? ";
			$bindingParams = array($productCode);
			$rs = $this->db->getRow($sql, $bindingParams);
			$partialReturn['contentLocation'] = $rs['F_ContentLocation'];
			// If you had to come here, then useful to send back the languageCode you found
			//$partialReturn['languageCode'] = $rs['F_LanguageCode'];
		}
		$partialReturn['languageCode'] = $rs['F_LanguageCode'];
		return $partialReturn;
	}
}
?>
