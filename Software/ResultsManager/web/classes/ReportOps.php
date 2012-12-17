<?php
require_once(dirname(__FILE__)."/ReportBuilder.php");
require_once(dirname(__FILE__)."/ContentOps.php");

class ReportOps {
	
	var $db;
	
	var $contentMap;
	
	var $total;
	
	function ReportOps($db) {
		$this->db = $db;
	}

	/**
	 * If you changed the db, you'll need to refresh it here
	 * Not a very neat function...
	 */
	function changeDB($db) {
		$this->db = $db;
	}
	
	function getReport($onReportableIDObjects, $onClass, $forReportableIDObjects, $forClass, $reportOpts, $template, $returnXMLString = false) {
		//echo 'reportOps.getReport $tempOnClass='.$onClass.' forClass='.$forClass.' template='.$template.'<br/>';
		// Get the content map for converting ids to names
		$contentOps = new ContentOps($this->db);
		$this->contentMap = $contentOps->getContentMap();
		
		// v3.4 Then we need to get editedContent to merge it.
		// The group list should be in session I think. It relates to the group of the logged in user.
		// So if you want to generate a report for a group lower in your tree, this group is NOT in session.
		// But it will be in $onReportables, though any groups between the top level and it won't be, so you have to build it anyway.
		// And what if you are reporting on multiple groups? What if they have different editedContent?
		// So first get the group(s) from $onReportables and find the parents.
		// TODO: I am going to start this just looking at $onReportables=manageables, not content. Please do the other way round later.
		// TODO: v3.5 MySQL query needs to have all userIDs as well as groupIDs
		if ($onClass == "Group" || $onClass == "User") {
			$groupIDs = array();				
			if ($onClass == "Group") {
				foreach ($onReportableIDObjects as $idObject) {
					$groupIDs[] = $idObject['Group'];
				}
			} else if ($onClass == "User") {
				// users have their class as part of their value {"User":"13428.69477"}
				// RM stops you trying to generate a report on multiple individual users. So you will only have one group to deal with in this case.
				foreach ($onReportableIDObjects as $idObject) {
					$idArray = explode('.', $idObject['User']);
					$groupIDs[] = $idArray[0];
				}
			}
			// If there are multiple groups, if they don't have identical results from getEditedContent I want to throw all of it away I think.
			// What kind of warning to give? Mind you the ids should all work themselves out uniquely. It is moved stuff that will be a problem
			// though I suppose that I do know the groupID of each student - wow that would be complex.
			// NOTE: Start by just including editedContent if there is only one group.
			if (count($groupIDs) == 1) {
				$parentGroupList = array_reverse($contentOps->manageableOps->getGroupParents($groupIDs[0]));
			} else {
				// Or I could go a little better and get editedContent for my group. Is there any value in that?
				// You would describe it as saying that when reporting on multiple groups you will only see common editedContent. Seems reasonable.
				$parentGroupList = Session::get('parentGroupIDs');
			}
			// For now lets just set it so that we will ignore such complexity.
			//print_r($parentGroupList); 
			$editedContentRecords = $contentOps->getEditedContent($parentGroupList);
			// Merge the editedContentRecords into the content tree, then the rest of reporting should be unchanged
			$this->mergeEditedContentRecords($editedContentRecords, $parentGroupList);
			
		} else {
			// For content based reports, just ignore editedContent?
		}
		
		// Variable bindings to static classes (e.g. $myClassString::getStuff()) not supported < PHP 5.3.0 so create temporary object
		$tempOnClass = new $onClass();
		//echo 'reportOps.getReport $tempOnClass='.$onClass.' forClass='.$forClass.' template='.$template.'<br/>';
		
		// Get the options for the reportables we are creating this report on
		// AR One of the $reportOps can have an impact on this function. Is it OK to tell it?
		// And some of the classes (eg User.php) will pass reportOpts by reference and change values.
		$opts = $tempOnClass->getReportBuilderOpts($forClass, $reportOpts, $template);

		// Filter for the reportables we are creating this report on
		$opts = array_merge($opts, $this->getReportFilters($onClass, $onReportableIDObjects));
		
		// Filter for the reportables we are creating this report for
		$opts = array_merge($opts, $this->getReportFilters($forClass, $forReportableIDObjects));
		
		// Add in all supported reportOpts
		foreach ($reportOpts as $reportOpt => $reportOptValue) {
			switch ($reportOpt) {
				case "fromDate":
					$opts[ReportBuilder::FROM_DATE] = $reportOptValue;
					break;
				case "toDate":
					$opts[ReportBuilder::TO_DATE] = $reportOptValue;
					break;
				case "attempts":
					$opts[ReportBuilder::ATTEMPTS] = $reportOptValue;
					break;
				case "scoreLessThan":
					$opts[ReportBuilder::SCORE_LESS_THAN] = $reportOptValue;
					break;
				case "scoreMoreThan":
					$opts[ReportBuilder::SCORE_MORE_THAN] = $reportOptValue;
					break;
				case "durationLessThan":
					$opts[ReportBuilder::DURATION_LESS_THAN] = $reportOptValue;
					break;
				case "durationMoreThan":
					$opts[ReportBuilder::DURATION_MORE_THAN] = $reportOptValue;
					break;
				case "detailedReport":
					$opts[ReportBuilder::DETAILED_REPORT] = $reportOptValue;
					break;
				case "includeStudentID":
					//echo $reportOpt."=".$reportOptValue;
					$opts[ReportBuilder::SHOW_STUDENTID] = $reportOptValue;
					break;
				case "includeEmail":
					$opts[ReportBuilder::SHOW_EMAIL] = $reportOptValue;
					break;
				case "headers":
					// Headers are just included in the root xml element for the XSL to do whatever it likes with them
					$headers = $reportOptValue;
					break;
				default:
					throw new Exception("Unknown report option ".$reportOpt);
			}
		}
		
		// v3.4 Summary (test) reports want sessionID to allow grouping
		if (stripos($template,"summary")!==false) {
			$opts[ReportBuilder::SHOW_SESSIONID] = true;
			// And they may want email to be displayed
			$opts[ReportBuilder::SHOW_EMAIL] = true;
		}
		
		// Create the ReportBuilder and set the options
		$reportBuilder = new ReportBuilder($this->db);
		foreach ($opts as $opt => $value)
			$reportBuilder->setOpt($opt, $value);
		
		//echo "ReportOps::".ReportBuilder::SHOW_COURSE."=".$reportBuilder->getOpt(ReportBuilder::SHOW_COURSE)."         ";
		// Execute the query - for some crazy reason its necessary to store the sql in a variable before passing to to AdoDB
		$sql = $reportBuilder->buildReportSQL();
		//echo $sql.'<br/>'; exit();
		$rows = $this->db->GetArray($sql);
		//echo 'hi'; exit();
		// v3.4 If a particular report needs score details (as the Clarity test does), this would seem like a good place to get the data.
		// Build a second SQL and get the data from it into another array. Then you can process this array below too.
		// Once all the data you need is in the dom, you can let the xsl pick it up.
		// Or it might be a better idea to do the necessary processing (summing, weighting etc) in here as PHP will be easier thatn XSL (for most stuff).
		//if ($template == "ClarityTestSummary") {
		// Clarity's Practical Placement Test (ClarityTestSummary and 3levelTestSummary)
		if (strpos($template,'TestSummary')!==false) {
			$this->PPTSelfAssessmentExerciseID = '1292227313781';
			
			// A great deal of the data will be the same (groupname etc) so use a similar setup
			// But I want extra filtering on a particular exercise (in this case)
			$newOpts = $reportBuilder->getOpt(ReportBuilder::FOR_IDOBJECTS);
			$newOpts[0]['Exercise'] = $this->PPTSelfAssessmentExerciseID;
			$reportBuilder->setOpt(ReportBuilder::FOR_IDOBJECTS, $newOpts);
			
			$detailSQL = $reportBuilder->buildDetailReportSQL();
			//echo $detailSQL.'<br/>'; exit();
			$details = $this->db->GetArray($detailSQL);
			
			// #1 You have all the rows now and the details, so need to summarise here
			$summarisedRows = array();
			$buildRow = array();
			$rowName = '';
			$rowSID = '';
			
			// Summary is always for one title (true?) Is there much performance hit from doing it many times?			
			foreach ($rows as $row) {
				// Is this a row that is part of a different test?
				//echo var_dump($row);
				if ($row['userName'] != $rowName || $row['sessionID'] != $rowSID) {
				
					// Do we have an already built row to write out from the previous test?
					if (isset($buildRow['userName'])) {
						$summarisedRows[] = $this->addDetailSummary($buildRow, $details);
					}
					
					// Make a new build row ready for the next test record
					$buildRow = array('userName' => $row['userName'],'sessionID' => $row['sessionID']);
					if (isset($row['productCode']))
						$buildRow['productCode'] = $row['productCode'];
					if (isset($row['groupName']))
						$buildRow['groupName'] = $row['groupName'];
					if (isset($row['email']))
						$buildRow['email'] = $row['email'];
					if (isset($row['start_date']))
						$buildRow['myStartDate'] = $row['start_date'];
					if (isset($row['courseID']))
						$buildRow['courseID'] = $row['courseID'];
					if (isset($row['unitID']))
						$buildRow['unitID'] = $row['unitID'];
					$buildRow['grammarCorrect'] = $buildRow['vocabularyCorrect'] = $buildRow['listeningCorrect'] = 0;
					$buildRow['grammarWrong'] = $buildRow['vocabularyWrong'] = $buildRow['listeningWrong'] = 0;
					$buildRow['grammarMissed'] = $buildRow['vocabularyMissed'] = $buildRow['listeningMissed'] = 0;
					$buildRow['grammarDuration'] = $buildRow['vocabularyDuration'] = $buildRow['listeningDuration'] = 0;
						
					$rowName = $row['userName'];
					$rowSID = $row['sessionID'];
				}
				
				// If this row doesn't have an exerciseName attribute, I don't want it
				if (!isset($row['exerciseID']))
					continue 1;
					
				// Need to get the exercise name from the id to allow grouping based on the name
				$title = $this->getTitle($row['productCode']);
				$exerciseName = $title->courses[$row['courseID']]->units[$row['unitID']]->exercises[$row['exerciseID']]->name;
				$buildRow['exerciseName'] = $exerciseName;
				
				if (!stristr($exerciseName, 'grammar') === FALSE) {
					$buildRow['grammarCorrect'] += intval($row['correct']);
					$buildRow['grammarWrong'] += intval($row['wrong']);
					$buildRow['grammarMissed'] += intval($row['missed']);
					$buildRow['grammarDuration'] += intval($row['duration']);
				}
				if (!stristr($exerciseName, 'vocabulary') === FALSE) {
					$buildRow['vocabularyCorrect'] += intval($row['correct']);
					$buildRow['vocabularyWrong'] += intval($row['wrong']);
					$buildRow['vocabularyMissed'] += intval($row['missed']);
					$buildRow['vocabularyDuration'] += intval($row['duration']);
				}
				if (!stristr($exerciseName, 'listening') === FALSE) {
					$buildRow['listeningCorrect'] += intval($row['correct']);
					$buildRow['listeningWrong'] += intval($row['wrong']);
					$buildRow['listeningMissed'] += intval($row['missed']);
					$buildRow['listeningDuration'] += intval($row['duration']);
				}
			}
			// Write out the final row you built
			if (isset($buildRow['userName'])) {
				$summarisedRows[] = $this->addDetailSummary($buildRow, $details);
			}
			
			// Reset our rows to the summarised one for the rest of the reporting code
			$rows = $summarisedRows;			
		
		// British Council LearnEnglish Level Test (CEFSummary)
		} else if (strpos($template, 'CEFSummary') !== false) {

			// #1 You have all the rows, so need to summarise here
			$summarisedRows = array();
			$buildRow = array();
			$rowName = '';
			$rowSID = '';
			
			foreach ($rows as $row) {
				// Is this a row that is part of a different test?
				if ($row['userName'] != $rowName || $row['sessionID'] != $rowSID) {
				
					// Do we have an already built row to write out from the previous test?
					if (isset($buildRow['unitName'])) {
						$summarisedRows[] = $buildRow;
					}
					
					// Make a new build row ready for the next test record
					$buildRow = array('userName' => $row['userName'],'sessionID' => $row['sessionID']);
					if (isset($row['productCode']))
						$buildRow['productCode'] = $row['productCode'];
					if (isset($row['groupName']))
						$buildRow['groupName'] = $row['groupName'];
					if (isset($row['email']))
						$buildRow['email'] = $row['email'];
					if (isset($row['start_date']))
						$buildRow['start_date'] = $row['start_date'];
					if (isset($row['courseID']))
						$buildRow['courseID'] = $row['courseID'];

					$buildRow['grammarCorrect'] = $buildRow['vocabularyCorrect'] = $buildRow['readingCorrect'] = 0;
					$buildRow['grammarWrong'] = $buildRow['vocabularyWrong'] = $buildRow['readingWrong'] = 0;
					$buildRow['grammarMissed'] = $buildRow['vocabularyMissed'] = $buildRow['readingMissed'] = 0;
					$buildRow['duration'] = 0;
						
					$rowName = $row['userName'];
					$rowSID = $row['sessionID'];
				}
				
				// If this row doesn't have an exerciseName attribute, I don't want it
				if (!isset($row['exerciseID']))
					continue 1;
					
				// Need to get the exercise name from the id to allow grouping based on the name
				//echo var_dump($row);
				$title = $this->getTitle($row['productCode']);
				$course = $title->courses[$row['courseID']];
				$unit = $course->units[$row['unitID']];
				if (isset($unit->exercises[$row['exerciseID']])){
					$exerciseName = $unit->exercises[$row['exerciseID']]->name;
				} else {
					$exerciseName = 'unknown';
				}
				$buildRow['exerciseName'] = $exerciseName;
				
				// There are two units that will have been used in each test, we only care about the one that
				// contains these exercises
				if (!stristr($exerciseName, 'grammar') === FALSE) {
					$buildRow['unitName'] = $unit->name;
					$buildRow['grammarCorrect'] += intval($row['correct']);
					$buildRow['grammarWrong'] += intval($row['wrong']);
					$buildRow['grammarMissed'] += intval($row['missed']);
					$buildRow['duration'] += intval($row['duration']);
				} else if (!stristr($exerciseName, 'vocabulary') === FALSE) {
					$buildRow['unitName'] = $unit->name;
					$buildRow['vocabularyCorrect'] += intval($row['correct']);
					$buildRow['vocabularyWrong'] += intval($row['wrong']);
					$buildRow['vocabularyMissed'] += intval($row['missed']);
					$buildRow['duration'] += intval($row['duration']);
				} else if (!stristr($exerciseName, 'reading') === FALSE) {
					$buildRow['unitName'] = $unit->name;
					$buildRow['readingCorrect'] += intval($row['correct']);
					$buildRow['readingWrong'] += intval($row['wrong']);
					$buildRow['readingMissed'] += intval($row['missed']);
					$buildRow['duration'] += intval($row['duration']);
				} else {
					$buildRow['duration'] += intval($row['duration']);
				}
			}
			// Write out the final row you built
			if (isset($buildRow['unitName'])) {
				$summarisedRows[] = $buildRow;
			}
			
			// Reset our rows to the summarised one for the rest of the reporting code
			$rows = $summarisedRows;			

		}

		$dom = new DOMDocument("1.0", "UTF-8");
		$reportXML = $dom->createElement("report");
		
		// Add in the headers to the root XML object
		foreach ($headers as $header => $headerValue) {
			//echo "$header has $headerValue";
			
			if (!mb_check_encoding($value, 'UTF-8')) {
				$reportXML->setAttribute($header, utf8_encode($headerValue));
			} else {
				$reportXML->setAttribute($header, $headerValue);
			}
		}
		
		// Go through the results replacing IDs with names, seconds with hh:ss and converting everything to an XML document
		// AR It seems that we leave the times as seconds and let the xsl format it
		foreach ($rows as $row) {
			$rowXML = $dom->createElement("row");		
			
			//echo var_dump($row);
			$row = $this->processRowFields($row);
			
			 foreach ($row as $key => $value) {
				// This was throwing up the error DOMElement::setAttribute() [domelement.setattribute]: string is not in UTF-8
				// But if I solve it using utf8_encode, then it screws up Chinese characters.
				//$rowXML->setAttribute($key, $value);
				if (!mb_check_encoding($value, 'UTF-8')) {
					$rowXML->setAttribute($key, utf8_encode($value));
				} else {
					$rowXML->setAttribute($key, $value);
				}
			}			
			    $reportXML->appendChild($rowXML);   						
		}
		
		if (isset($details) && $details) {
			foreach ($details as $row) {
				$rowXML = $dom->createElement("detail");
				// Since courseID doesn't come back from T_ScoreDetail, we need to hardcode it
				//if ($template == "ClarityTestSummary") {
				if (strpos($template,'TestSummary')!==false) {
					$row['courseID'] = '1216948569658';
				}
				//echo var_dump($row);
				$row = $this->processRowFields($row);
				
				foreach ($row as $key => $value)
					if (!mb_check_encoding($value, 'UTF-8')) {
						$rowXML->setAttribute($key, utf8_encode($value));
					} else {
						$rowXML->setAttribute($key, $value);
					}
				
				$reportXML->appendChild($rowXML);
			}
		}
		$dom->appendChild($reportXML);
		
		if ($returnXMLString) {
			$dom->formatOutput = true;
			return $dom->saveXML();
		} else {
			return $dom;
		}
	}
	
	// #1 This function takes a summary row and adds in the relevant stuff from the detail records
	function addDetailSummary($buildRow, $details) {
		// Get the keys from the summary
		$userName = $buildRow['userName'];
		$sID = $buildRow['sessionID'];
		$selfAssessmentList = array();
		$selfAssessmentScore = 0;
		foreach ($details as $detail) {
			if ($detail['userName'] == $userName && $detail['sessionID'] == $sID && $detail['exerciseID'] == $this->PPTSelfAssessmentExerciseID) {
				$itemScore = intval($detail['score']);
				if ($itemScore > 0) {
					$selfAssessmentList[] = $detail['itemID'];
					// The self-assessment score is the question number (ie: you get more points for the latter questions)
					$selfAssessmentScore += intval($detail['itemID']);
				}
			}
		}
		sort($selfAssessmentList, SORT_NUMERIC);
		$buildRow['selfAssessmentList'] = implode(',', $selfAssessmentList);
		$buildRow['selfAssessment'] = $selfAssessmentScore;
		
		return $buildRow;
	}
	
	function getReportFilters($class, $idObjects) {
		switch ($class) {
			case "Course":
				// Get all the Course objects out of the array
				//gh:#23
				/*$ids = array();
				foreach ($idObjects as $idObject)
					$ids[] = $idObject['Course'];
					
				return array(ReportBuilder::FOR_COURSES => $ids);*/
			case "Unit":
			case "Exercise":
			case "Title":
				// This needs to OR bunches of (F_CourseID=<course> AND F_UnitID=<unit> AND F_ExerciseID=$id) since they are not unique
				// across courses - passing the idObjects array takes care of this
				return array(ReportBuilder::FOR_IDOBJECTS => $idObjects);
			case "Group":
				$ids = array();				
				foreach ($idObjects as $idObject) {
					$ids[] = $idObject['Group'];
				}
				//echo "ids=".implode(",", $ids);
					
				// The report SQL doesn't understand groups, so we need to get all the users in this group
				// v3.3 But why not? You could easily put groupID into the SQL.
				// So change reports for groups to use FOR_GROUPS rather than FOR_USERS
				// This has the big advantage that you can generate a report even for large accounts where we have hidden the learners.
				$manageableOps = new ManageableOps($this->db);
				$groups = $manageableOps->getManageables($ids, false);
			
				// Keep the original IDs and then find all subGroups for them.
				//$ids = array();
				foreach ($groups as $group) {
					$ids = array_merge($group->getSubGroupIds(), $ids);
				}
				//echo "ids=".implode(",", $ids);
				return array(ReportBuilder::FOR_GROUPS => $ids);
				// skip this if I can do the above
				$ids = array();
				foreach ($groups as $group) {
					$ids = array_merge($group->getSubUserIds(), $ids);
				}
				
				return array(ReportBuilder::FOR_USERS => $ids);
			case "User":
				// Get all the User objects out of the array
				$ids = array();
				foreach ($idObjects as $idObject) {
					// v3.4 Multi-group users
					// if the userID has a group as well, just drop it. Do it by picking up the last item split by '.'
					$idArray = explode('.', $idObject['User']);
					$ids[] = array_pop($idArray);
				}
					
				return array(ReportBuilder::FOR_USERS => $ids);
			default:
				throw new Exception("Unable to get filters for reportable of type '".$class."'");
		}
	}
	
	/**
	 * Given an associative array (retrieved from running the report SQL) go through performing various operations on various bits of data.
	 * This includes replacing content IDs with names, formatting times, etc
	 *
	 * @param row An associative array containing a row of data retrieved from the database as the report
	 */
	private function processRowFields($row) {
		// If courseID is set replace it with the courseName and also add in titleName
		if (isset($row['courseID'])) {
			$courseID = $row['courseID'];
			unset($row['courseID']);
			
			// v3.4 For R2I this always returns Academic, even if they did GT because courseIDs are the same.
			// If we could get the correct title, then everything else would be OK. And the session records could tell us this.
			// So that would mean including T_Session in the SQL so I can add productCode to the returned results.
			// That doesn't seem to be too slow.
			if (isset($row['productCode'])) {
				$title = $this->getTitle($row['productCode']);
			} else {
				$title = $this->getTitleForCourseID($courseID);
			}
		
			if (isset($title->name)) {
				$row['titleName'] = $title->name;
			} else if (isset($title->caption)) {
				$row['titleName'] = $title->caption;
			} else {
				$row['titleName'] = '-no name-';
			} 
			if (isset($title->courses[$courseID]->caption)) {
				$row['courseName'] = $title->courses[$courseID]->caption;
			} else if (isset($title->courses[$courseID]->name)) {
				$row['courseName'] = $title->courses[$courseID]->name;
			} else {
				$row['courseName'] = '-no name-';
			}
			//gh:28
		    if (isset($row['exerciseUnit_percentage'])) {
			   $total = 0;
			   foreach ($title->courses[$courseID]->units as $unit) {
			       $total = $total + $unit->totalExercises;
			   }
		       $row['exerciseUnit_percentage'] =  $row['exerciseUnit_percentage']."/".$total;
		    }
		}
		
		
		// v3.4 You can't do this section unless courseID is set
		// If unitID is set replace it with the unitName.
		// v3.4 Note that the unitID comes from attribute 'unit' in menu.xml rather than 'id', which it should.
		// So Connected Speech and IIE2, which now correctly write id to T_Score, show it as -no name-
		// but since they used to write 'unit' we now need to cope with both.
		// v6.5.6.5 But RM as is sending Unit:3 to me, so when I query the db, my SQL has unit=3. 
		// This decoding is neither here nor there. I need to change the query.
		if (isset($row['unitID'])) {
			$unitID = $row['unitID'];
			unset($row['unitID']);
			//$row['unitName'] = $title->courses[$courseID]->units[$unitID]->caption;
			if (isset($title->courses[$courseID]->units[$unitID])) {
				//echo 'no need to decode '.$unitID.'<br/>';
				$row['unitName'] = $title->courses[$courseID]->units[$unitID]->name;
			} else {
				//echo 'need to decode '.$unitID.'<br/>';
				// I would now like to search to see if the 'id' rather than the 'unit' matches.
				// ContentOps.php changed to save unitID as an attribute of the unit class.
				$bestName = "-no name- ($unitID)";
				foreach ($title->courses[$courseID]->units as $unit) {
					//if ($unit->unitID == $unitID) {
					if ($unit->sequenceNum == $unitID) {
						$bestName = $unit->name;
						// As well as saving the name, swap to use this id so that the exercise name below is found too
						$unitID = $unit->id;
						break;
					}
				}
				$row['unitName'] = $bestName;
			}
			//gh:#28			
		    if (isset($row['exercise_percentage'])) {
			   //for AR, some exerciseID in DB is not exist in content xml file
			   /*if (!isset($title->courses[$courseID]->units[$unitID]->exercises[$exerciseID])) {
			        $row['exercise_percentage'] = $row['exercise_percentage'] - 1;
			   }*/
		       $row['exercise_percentage'] =  $row['exercise_percentage']."/".$title->courses[$courseID]->units[$unitID]->totalExercises;
		    }
			//echo "unitID=$unitID, name={$title->courses[$courseID]->units['0']->name}";
		}
		
		// If exerciseID is set replace it with the exerciseName
		if (isset($row['exerciseID'])) {
			$exerciseID = $row['exerciseID'];
			unset($row['exerciseID']);
			// Just in case the menu.xml has changed and an old exercise no longer exists:
			// It would be sensible to never remove exercises from a menu, but just to give them a 'special' eF,
			// then they will not be counted, but can have a decodable caption for just the following case.
			if (isset($title->courses[$courseID]->units[$unitID]) &&
				isset($title->courses[$courseID]->units[$unitID]->exercises[$exerciseID])) {
				//$row['exerciseName'] = $title-> courses[$courseID]->units[$unitID]->exercises[$exerciseID]->caption;
				$row['exerciseName'] = $title->courses[$courseID]->units[$unitID]->exercises[$exerciseID]->name;
			} else {
				//TODO: Whilst you can't find this exercise in this unit, it is quite likely that this is because
				// it was just moved to another place.
				// So you could do a search for the exercise ID (which is probably unique) in the whole title
				$bestName = "-no name- ($exerciseID)";
				foreach ($title-> courses as $course) {
					foreach ($course-> units as $unit) {
						foreach ($unit->exercises as $exercise) {
							if ($exercise-> id == $exerciseID) {
								$bestName = $exercise-> name.'*';
								break 3;
							}
						}
					}
				}
				$row['exerciseName'] = $bestName;
			}			
		}
		
		// Decode any apostrophes
		if (isset($row['groupName']))
			$row['groupName'] = Reportable::apos_decode($row['groupName']);
		
		// Decode any apostrophes
		if (isset($row['userName']))
			$row['userName'] = Reportable::apos_decode($row['userName']);
		
		// Reformat the start date into "Oct 10 2008 14:37" format (JS compatible to allow for sorting in the browser)
		if (isset($row['start_date'])) {
			$timeStamp = $this->db->UnixTimeStamp($row['start_date']);
			$row['start_date'] = date("M j Y H:i", $timeStamp);
		}
		
		return $row;
	}
	
	private function getTitleForCourseID($courseID) {
		foreach ($this->contentMap as $title)
			// Avoid warning notices as you might be checking for courses in a different title here
			if (isset($title->courses[$courseID]) && $title->courses[$courseID]) {
				return $title;
			}
		
		return null;
	}
	// v3.4 Similar to the above except that we know the titleID
	private function getTitle($titleID) {
		foreach ($this->contentMap as $title) {
			if ($title->productCode==$titleID)
				return $title;
		}		
		return null;
	}

	// v3.4 Merge the editedContent records into the content map
	private function mergeEditedContentRecords($records, $groups) {
	
		$titles = $this->contentMap;
		
		// Go through the list of groups and for each change the content map (lower groups override higher ones)
		foreach ($groups as $groupID) {
			//echo "checking on group $groupID<br/>";
			if (isset($records[$groupID])) {
				$editedContentRecords = $records[$groupID];
				foreach ($editedContentRecords as $record) {
					//echo "found record for mode {$record['mode']}<br/>";
					switch ($record['mode']) {
						case 0: // Exercise.EDIT_MODE_EDITED
							$UID = $record['editedContentUID'];
							$mappedIds = explode(".", $UID);
							if (isset($titles[$mappedIds[0]]->courses[$mappedIds[1]]->units[$mappedIds[2]]->exercises[$mappedIds[3]])) {
								//echo "found an edited exercise {$titles[$mappedIds[0]]->courses[$mappedIds[1]]->units[$mappedIds[2]]->name}:{$titles[$mappedIds[0]]->courses[$mappedIds[1]]->units[$mappedIds[2]]->exercises[$mappedIds[3]]->name}<br/>";
								$titles[$mappedIds[0]]->courses[$mappedIds[1]]->units[$mappedIds[2]]->exercises[$mappedIds[3]]->name.=' (edited)';
							}
							break;
						case 5: // Exercise.EDIT_MODE_MOVEDAFTER
						case 4: // Exercise.EDIT_MODE_MOVEDBEFORE
							// If it is moved then I need to first of all delete the original from the tree, then find the related UID object as that is where I will insert this one
							// First find the original. I wonder if you can just find it and then change the parents to get it to move?
							$UID = $record['editedContentUID'];
							$mappedIds = explode(".", $UID);
							if (isset($titles[$mappedIds[0]]->courses[$mappedIds[1]]->units[$mappedIds[2]]->exercises[$mappedIds[3]])) {
								$thisExercise = $titles[$mappedIds[0]]->courses[$mappedIds[1]]->units[$mappedIds[2]]->exercises[$mappedIds[3]];
							}
							// remove this exercise from the unit
							$titles[$mappedIds[0]]->courses[$mappedIds[1]]->units[$mappedIds[2]]->removeExercise($thisExercise);
							//print_r($titles[$mappedIds[0]]->courses[$mappedIds[1]]->units[$mappedIds[2]]);
							
							// Then find where it should go
							$relatedUID = $record['relatedUID'];
							$relatedMappedIds = explode(".", $relatedUID);
							if (isset($titles[$relatedMappedIds[0]]->courses[$relatedMappedIds[1]]->units[$relatedMappedIds[2]])) {
								$relatedUnit = $titles[$relatedMappedIds[0]]->courses[$relatedMappedIds[1]]->units[$relatedMappedIds[2]];
								//echo "found the target unit in the content map, id={$relatedUnit->name}<br/>";
							}
							//echo "found '{$thisExercise->name}' moved from {$titles[$mappedIds[0]]->courses[$mappedIds[1]]->units[$mappedIds[2]]->name} to {$relatedUnit->name}<br/>";
							// Can you find the related exercise in this unit? If not, we will just add it at the end
							// Don't need this much detail
							/*
							if (isset($titles[$relatedMappedIds[0]]->courses[$relatedMappedIds[1]]->units[$relatedMappedIds[2]]->exercises[$relatedMappedIds[3]])) {
								$relatedExercise = $titles[$relatedMappedIds[0]]->courses[$relatedMappedIds[1]]->units[$relatedMappedIds[2]]->exercises[$relatedMappedIds[3]];
								//echo "and the exercise before/after is {$relatedExercise->name}<br/>";
							} else {
								$relatedExercise = null;
							}
							*/
							// I don't think I need to worry about making a unit like this, just throw it in using the ID
							//if ($relatedExercise) {
								/*
								$idx=0;
								foreach ($relatedUnit->exercises as $exercise) {
									if ($exercise == $relatedExercise) {
										if ($record['mode'] == 5) { // Exercise.EDIT_MODE_MOVEDAFTER
											$idx++;
										}
										array_splice($relatedUnit->exercises, $idx, 0, array($thisExercise));
										echo $relatedUnit->id.'.'.$thisExercise->id;
										$addedTheExercise=true;
										break;
									}
									$idx++;
								}
								*/
							//}
							//if (!$addedTheExercise) {
							//	$relatedUnit->exercises[] = $thisExercise;
							//}
							$relatedUnit->exercises[$thisExercise->id] = $thisExercise;
							$thisExercise->setParent($relatedUnit);
							
							// Lets just check the unit now:
							/*
							echo "{$relatedUnit->name} has :<br/>";
							foreach($relatedUnit->exercises as $exercise) {
								echo "  {$exercise->name}<br/>";
							}
							*/
							break;
						case 3: // Exercise.EDIT_MODE_INSERTEDAFTER:
						case 2: // Exercise.EDIT_MODE_INSERTEDBEFORE:
							// If it is inserting then the first thing I need to find is the related UID object as that is where I will insert this one
							$relatedUID = $record['relatedUID'];
							$relatedMappedIds = explode(".", $relatedUID);
							if (isset($titles[$relatedMappedIds[0]]->courses[$relatedMappedIds[1]]->units[$relatedMappedIds[2]])) {
								$relatedUnit = $titles[$relatedMappedIds[0]]->courses[$relatedMappedIds[1]]->units[$relatedMappedIds[2]];
								//echo "inserting: found the target unit, {$relatedUnit->name}<br/>";
							}
							// Can you find the related exercise in this unit? If not, we will just add it at the end
							if (isset($titles[$relatedMappedIds[0]]->courses[$relatedMappedIds[1]]->units[$relatedMappedIds[2]]->exercises[$relatedMappedIds[3]])) {
								$relatedExercise = $titles[$relatedMappedIds[0]]->courses[$relatedMappedIds[1]]->units[$relatedMappedIds[2]]->exercises[$relatedMappedIds[3]];
								//echo "and the exercise before/after is {$relatedExercise->name}<br/>";
							} else {
								$relatedExercise = null;
							}
							// Build the new exercise
							$UID = $record['editedContentUID'];
							$mappedIds = explode(".", $UID);
							if (isset($mappedIds[3])) {
								$insertedExercise = new Exercise();
								$insertedExercise->name = $record['caption'];
								$insertedExercise->id = $mappedIds[3];
								$insertedExercise-> enabledFlag = 16; //Exercise.ENABLED_FLAG_EDITED;
							} else {
								throw new Exception ("The inserted exercise has no id, uid=$UID");
							}
										
							// I don't think I need to worry about making a unit like this, just throw it in using the ID
							/*
							if ($relatedExercise) {
								$idx=0;
								foreach ($relatedUnit->exercises as $exercise) {
									if ($exercise == $relatedExercise) {
										if ($record['mode'] == 5) { // Exercise.EDIT_MODE_MOVEDAFTER
											$idx++;
										}
										array_splice($relatedUnit->exercises, $idx, 0, array($insertedExercise));
										$addedTheExercise=true;
										break;
									}
									$idx++;
								}
							}
							if (!$addedTheExercise) {
								$relatedUnit->exercises[] = $insertedExercise;
							}
							*/
							$relatedUnit->exercises[$insertedExercise->id] = $insertedExercise;
							$insertedExercise->setParent($relatedUnit);
							
							// Lets just check the unit now:
							/*
							echo "{$relatedUnit->name} has :<br/>";
							foreach($relatedUnit->exercises as $exercise) {
								echo "  {$exercise->name}<br/>";
							}
							*/
							break;
					}
				}
			}
		}
	}
	// AR I am pretty sure you mean secondsToMinutes($seconds)
	// AR It seems that we leave the times as seconds and let the xsl format it. See generateReport.php
	//private static function secondsToMinutes($minutes) {
	//	return sprintf("%d:%02d", abs((int)$minutes / 60), abs((int)$minutes % 60));
	//}

}

?>
