/*
Proxy - PureMVC
*/
package com.clarityenglish.resultsmanager.model {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.common.vo.content.Exercise;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.content.Unit;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.utils.ArrayUtils;
	import mx.utils.ObjectUtil;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	//import nl.demonsters.debugger.MonsterDebugger;
	import com.clarityenglish.utils.TraceUtils;

	/**
	 * A proxy
	 */
	public class ContentProxy extends Proxy implements IProxy, IDelegateResponder {
		namespace embed;
		embed static var title:Title;
		embed static var unit:Unit;
		embed static var course:Course;
		embed static var exercise:Exercise;
		
		public static const NAME:String = "ContentProxy";

		private var _titles:Array;
		// v3.4 Editing Clarity Content - a copy of the data that comes back from getContent so we can easily reset to it
		private var _resetContent:Array;
		
		private var hiddenContent:Object;
		private var editedContent:Object;
		
		public function ContentProxy(data:Object = null) {
			super(NAME, data);

			// v3.4 In a bid to not overload AMF or anything else, lets getContent after we have got manageables, not at the same time.
			//new RemoteDelegate("getContent", [], this).execute();
		}
		
		public function get titles():Array { return _titles; }
		
		public function set titles(value:Array):void {
			_titles = value;
		}
		// v3.4 And for the edited content reset saving array. Is it better to use the getter/setter or direct variable within this proxy?
		public function get resetContent():Array { return _resetContent; }
		public function set resetContent(value:Array):void {
			_resetContent = value;
		}
		
		// v3.4 Refresh all content from files - optional for the learner after they do some editing
		public function getContent():void {
			new RemoteDelegate("getContent", [], this).execute();
		}
		
		// v3.4 To help with refreshing the tree - go back to the original data and then pick up editedContent
		public function refreshContentData():void {
			//TraceUtils.myTrace("refreshContentData, _titles.length=" + _titles.length);
			_titles = ObjectUtil.copy(_resetContent) as Array;
			sendNotification(RMNotifications.CONTENT_LOADED, _titles);			
		}
		public function getHiddenContent():void {
			new RemoteDelegate("getHiddenContent", [], this).execute();
		}
		// Could or should this be merged with the above function?
		public function getEditedContent():void {
			new RemoteDelegate("getEditedContent", [Constants.parentGroupIDs], this).execute();
		}
		
		public function hasHiddenContent(group:Group):Boolean {
			//MonsterDebugger.trace(this, "hasHiddenContent");
			// Before the hidden content has loaded from the server just return false here
			if (!hiddenContent) return false;
			
			// If nothing is defined for the group then there is no hidden content
			if (!hiddenContent[group.id]) return false;
			
			// Otherwise if any of the values are false there is hidden content
			for (var key:String in hiddenContent[group.id])
				if (!hiddenContent[group.id][key]) return true;
			
			// ... otherwise not!
			return false;
		}
		// duplicate the above for edited content as it seems useful!
		// Not sure if it is! Especially as it doesn't go up looking to see if parents edited anything.
		// I don't think this is used.
		/*
		public function hasEditedContent(group:Group):Boolean {
			// Before the edited content has loaded from the server just return false here
			if (!editedContent) return false;
			
			// If nothing is defined for the group then there is no edited content
			if (!editedContent[group.id]) return false;
			
			// Otherwise if any of the values are false there is edited content
			for (var key:String in editedContent[group.id])
				if (!editedContent[group.id][key]) return true;
			
			// ... otherwise not!
			return false;
		}
		*/
		
		public function isContentVisible(content:Content, group:Group):Boolean {
			// Get the hidden content for the given group id
			var hiddenContentUIDs:Object = hiddenContent[group.id];
			//for each (var UID:String in hiddenContentUIDs) {
			//	MonsterDebugger.trace(this, "isContentVisible.hiddenContent uid=" + UID);
			//}
			
			// The algorithm to work out if a given uid is hidden is to search for that uid in the hidden content.  If it exists
			// return the hidden status (true or false).  If not check the parent and do the same.  Continue until there are no
			// parents (i.e. it is the title) and if it still hasn't been found then the content is visible.
			do {
				// If this uid is specifically in the hidden content then return the visible status
				if (hiddenContentUIDs && hiddenContentUIDs[content.uid] != undefined)
					return hiddenContentUIDs[content.uid];
				
				// Otherwise continue for the parent
				content = content.parent as Content;
			} while (content != null);
			
			// If the item is not found at all then return true
			return true;
		}
		
		public function setContentVisible(content:Content, group:Group, visible:Boolean):void {
			new RemoteDelegate("setHiddenContent", [ content.toIDObject(), group.id, visible ], this).execute();
		}

		// v3.4 Copy from above for edited content
		// Choose to instead do this in one go from the mediator when we click on a different group
		// This is all about displaying records from the table, not about the action of edit, move, insert etc
		public function mapEditedContentForGroup(group:Group = null):void {
			
			//MonsterDebugger.trace(this, "reset dataProvider for group=" + group.name);
			//TraceUtils.myTrace("reset dataProvider for group=" + group.name);
			// The algorithm to work out if a given uid is edited is to cascade down the groups, starting from the top.
			// The top means the very top for the account, not just the top group you can see.
			// If you find the uid for a group, then it is edited.
			// TODO a lower group might specifically reset it a higher groups edited content.
			
			// And what about undoing the eF you just set when you go to a group that doesn't have it?
			// I need a quick function to go through every exercise in the tree and undo the edited flag.
			// And how will you get rid of exercises inserted for another group? Huh?
			// Will we really have to go back and do getContent again?
			// Lets see how far we can get by saving a reset version when we come back from getContent.
			/*
			for each (var title:Title in _titles) {
				for each (var course:Course in title.children) {
					for each (var unit:Unit in course.children) {
						for each (var exercise:Exercise in unit.children) {
							exercise.enabledFlag &= ~Exercise.ENABLED_FLAG_EDITED;
							// If this eF shows that it was inserted as part of EditedContent, then remove it
							if (exercise.enabledFlag & Exercise.ENABLED_FLAG_EDITEDCONTENT_INSERT) {
								//unit.deleteExercise(exercise);
							}
						}
					}
				}
			}
			*/
			// This will replace the data, but then we have broken the link to the tree.dataProvider
			// If you send a noticiation that hangs everything. Not sure why. Send it at the end of this function?
			// No still not. But not sure why needs it? Surely if I just change _titles it should impact the dataProvider
			// too since it is just a reference? Yes, it was a poor recursive array duplicator utility.
			// Unless I send the notification I don't refresh the tree correctly, though the underlying data is good.
			//_titles = ArrayUtils.duplicate(_resetContent, true) as Array;
			// Lets get this into a public function that the mediator can call too when it wants to redraw the tree
			//_titles = ObjectUtil.copy(_resetContent) as Array;
			//sendNotification(RMNotifications.CONTENT_LOADED, _titles);
			refreshContentData();
			
			// Build a group hierarchy list from the very top down to this group.
			// We have the top down to this user's group in parentGroupIDs.
			// v3.5 AR I really don't see why we care two hoots about any edited content records for subgroups?
			//var topGroupList:Array = Constants.parentGroupIDs;
			var allGroupList:Array = Constants.parentGroupIDs;
			/*
			// Then we need to stick the subgroups on if necessary.
			//MonsterDebugger.trace(this, "top group list=" + topGroupList.toString());
			var subGroupList:Array = new Array();
			// Change to a while loop so that it doesn't matter if group is null (no group has been selected)
			while (group != null) {
				//MonsterDebugger.trace(this, "add on " + group.id);
				// Add this subgroup id to the array and go up
				subGroupList.push(group.id);
				
				// Otherwise continue for the parent
				group = group.parent as Group;
			};
			subGroupList.reverse();
			//MonsterDebugger.trace(this, "sub group list=" + subGroupList.toString());
			
			// There should be an overlap for this user's group. So ditch the duplicate, which is the first in our second array.
			var allGroupList:Array = topGroupList.concat(subGroupList.slice(1));
			//MonsterDebugger.trace(this, "all group list=" + allGroupList.toString());
			*/
			
			// predefine some variables that we use throughout this
			var UID:String;
			var mappedIds:Array;
			var thisTitle:Title;
			var thisCourse:Course;
			var thisUnit:Unit;
			var thisExercise:Exercise;
			var relatedUID:String;
			var relatedMappedIds:Array;
			var relatedTitle:Title;
			var relatedCourse:Course;
			var relatedUnit:Unit;
			var relatedExercise:Exercise;

			// v3.5 You need to process the ECC records in a careful order. If a record has a related ID that is itself a UID
			// then it means that you have moved a record so that it is relative to another moved record. You must do the 
			// moves in the same order. So the first stage is to simply go through the ECC records and give them a sequence number.
			// You need to go through repeatedly until you have found no records related to other moved records.
			// v3.5 Actually this is now simplified because I am going to handle the complexity in move when I write to the database.
			// So if you move a record that had things related to it, you will update their related things in the database.
			// Lets see if I can just skip this sequence stuff
			/*
			for each (groupID in allGroupList) {
				editedContentRecords = editedContent[groupID];
				var sequenceDepth:uint = 1;
				var foundSequence:uint = 0;
				do {
					//TraceUtils.myTrace("start loop " + sequenceDepth);
					foundSequence = 0;
					for each (record in editedContentRecords) {
						//TraceUtils.myTrace("check-"+sequenceDepth+": UID " + record.editedContentUID + " seq=" + record.sequence);
						// Does this record refer to another record in the table? If so it must come later
						if (record.sequence==sequenceDepth) {
							var thisRelatedID:String = record.relatedUID;
							for each (var relatedRecord:Object in editedContentRecords) {
								if (thisRelatedID == relatedRecord.editedContentUID && relatedRecord.sequence>=sequenceDepth) {
									// we found a match, so set the sequence to this iteration
									record.sequence = sequenceDepth+1;
									//TraceUtils.myTrace("matched-"+sequenceDepth+": related of " + thisRelatedID + " seq=" + record.sequence);
									foundSequence++;
									break;
								}
							}
						}
					}
					sequenceDepth++;
				} while (foundSequence > 1 && sequenceDepth<20);
				
			}	
			// Then lets sort and trace
			for each (groupID in allGroupList) {
				//TraceUtils.myTrace("group=" + groupID);
				editedContentRecords = editedContent[groupID];
				// Since some groups have no records, need to check if we really have an array before sorting it
				if (editedContentRecords) {
					//TraceUtils.myTrace("length.1=" + editedContentRecords.length);
					editedContentRecords.sortOn("sequence", Array.NUMERIC);
					//TraceUtils.myTrace("length.2=" + editedContent[groupID2].length);
					for each (record in editedContentRecords) {
						TraceUtils.myTrace("new: " + record.editedContentUID + " as " + record.sequence);
					}
				}
			}
			*/
			// Go through the group tree
			for each (var groupID:String in allGroupList) {
				// Get the edited content for the given group id
				TraceUtils.myTrace("checking edited content for " + groupID);
				var editedContentRecords:Array = editedContent[groupID];
				//MonsterDebugger.trace(this, "mapEditedContent");
				//MonsterDebugger.trace(this, editedContentRecords);
				//for (var UID:String in editedContentRecords) {
				for each (var record:Object in editedContentRecords) {
					TraceUtils.myTrace("record: " + record.editedContentUID + " as " + record.sequence);
					// First of all work out what is the mode for this editedContent
					// v3.5 Note that MySQL returns all integer types from adodb as strings.
					//TraceUtils.myTrace("ECC record, mode=" + record.mode);
					// I'd prefer to do the type casting in PHP
					//record.mode = parseInt(record.mode);
					switch (record.mode) {
						case Exercise.EDIT_MODE_EDITED:
							// If it is editing then...
							UID = record.editedContentUID;
							TraceUtils.myTrace("edit, got " + UID);
							// Now I need to find the object reference by that UID. I can't find anything built in to do this, but I would have thought I should be able to.
							mappedIds = UID.split(".");
							thisTitle = ArrayUtils.searchArrayForObject(_titles, mappedIds[0], "id") as Title;
							//TraceUtils.myTrace("edit, title " + thisTitle.name); // disabled by WZ, since thisTitle.name is not exist.
							//MonsterDebugger.trace(this, "got it for " + UID);
							//MonsterDebugger.trace(this, thisTitle);
							if (thisTitle && mappedIds[1]) {
								thisCourse = ArrayUtils.searchArrayForObject(thisTitle.children, mappedIds[1], "id") as Course;
								if (thisCourse && mappedIds[2]) {
									thisUnit = ArrayUtils.searchArrayForObject(thisCourse.children, mappedIds[2], "id") as Unit;
									if (thisUnit && mappedIds[3]) {
										thisExercise = ArrayUtils.searchArrayForObject(thisUnit.children, mappedIds[3], "id") as Exercise;
										thisExercise.enabledFlag |= Exercise.ENABLED_FLAG_EDITED;
										TraceUtils.myTrace("Edited, so set eF of " + thisExercise.name + " to " + thisExercise.enabledFlag);
										//thisExercise.name = "i changed you";
										
										// Now we want to see if the caption has changed, so look up the related UID in the Author Plus folder
										relatedUID = record.relatedUID;
										//MonsterDebugger.trace(this, relatedUID);
										relatedMappedIds = relatedUID.split(".");
										TraceUtils.myTrace("relatedMappedIds[0]=" + relatedMappedIds[0]);
										relatedTitle = ArrayUtils.searchArrayForObject(_titles, relatedMappedIds[0], "id") as Title;
										if (relatedTitle && mappedIds[1]) {
											TraceUtils.myTrace("found related title " + relatedTitle.name);
											relatedCourse = ArrayUtils.searchArrayForObject(relatedTitle.children, relatedMappedIds[1], "id") as Course;
											if (relatedCourse) {
												TraceUtils.myTrace("found related course " + relatedCourse.name);
												// so this is the Author Plus course. We don't know which unit it is in, but we know the exerciseID so 
												// just need to search them all
												moveOuterLoop: for each (relatedUnit in relatedCourse.children) {
													for each (relatedExercise in relatedUnit.children) {
														TraceUtils.myTrace("looking at " + relatedUnit.name + " and ex=" + relatedExercise.name);
														if (relatedExercise.id == thisExercise.id) {
															thisExercise.name = relatedExercise.name;
															TraceUtils.myTrace("found new name of " + relatedExercise.name);
															break moveOuterLoop;
														}
													}
												}
											} else {
												//MonsterDebugger.trace(this, "didn't find APCourse for T_ECC " + relatedUID);
											}
										}
									}
								}
							} else {
								//MonsterDebugger.trace(this, "ECC record for editing, but related UID doesn't exist");
							}
							break;
						case Exercise.EDIT_MODE_INSERTEDAFTER:
						case Exercise.EDIT_MODE_INSERTEDBEFORE:
						
							// TODO: It is quite plausible that you will click in RM to insert, go to AP and then not save
							// So if you can't find the exercise in AP you might as well delete this record.
							
							// Find out about the exercise itself (in Author Plus)
							UID = record.editedContentUID;
							mappedIds = UID.split(".");
							
							// I need to find the related UID object as that is where I will insert this one
							relatedUID = record.relatedUID;
							// Now I need to find the object reference by that UID. I can't find anything built in to do this, but I would have thought I should be able to.
							relatedMappedIds = relatedUID.split(".");
							relatedTitle = ArrayUtils.searchArrayForObject(_titles, relatedMappedIds[0], "id") as Title;
							
							if (relatedTitle && relatedMappedIds[1]) {
								relatedCourse = ArrayUtils.searchArrayForObject(relatedTitle.children, relatedMappedIds[1], "id") as Course;
								TraceUtils.myTrace("ADD: found related course " + relatedCourse.name);
								if (relatedCourse && relatedMappedIds[2]) {
									relatedUnit = ArrayUtils.searchArrayForObject(relatedCourse.children, relatedMappedIds[2], "id") as Unit;
									if (relatedUnit && relatedMappedIds[3]) {
										
										// Finrst, find the exercise in Author Plus so we can get the caption. Based on UID.
										// Do this first because if the exercise doesn't exist, we can just skip out.
										//MonsterDebugger.trace(this, UID);
										thisTitle = ArrayUtils.searchArrayForObject(_titles, mappedIds[0], "id") as Title;
										if (thisTitle && mappedIds[1]) {
											//MonsterDebugger.trace(this, "found title " + thisTitle.name);
											thisCourse = ArrayUtils.searchArrayForObject(thisTitle.children, mappedIds[1], "id") as Course;
											if (thisCourse) {
												//MonsterDebugger.trace(this, "found AP course " + thisCourse.name);
												// so this is the Author Plus course. We don't know which unit it is in, but we know the exerciseID so 
												// just need to search them all
												insertOuterLoop: for each (thisUnit in thisCourse.children) {
													for each (thisExercise in thisUnit.children) {
														//MonsterDebugger.trace(this, "looking at " + thisUnit.name + " and ex=" + thisExercise.name);
														if (thisExercise.id == mappedIds[3]) {
															var insertedCaption:String = thisExercise.name;
															//MonsterDebugger.trace(this, "found AP unit " + thisUnit.name);
															break insertOuterLoop;
														}
													}
												}
											}
										}
										// If you didn't find the exercise it means it doesn't exist so you should drop the item
										if (insertedCaption) {											
											// Now find the exercise I am going to insert before/after
											relatedExercise = ArrayUtils.searchArrayForObject(relatedUnit.children, relatedMappedIds[3], "id") as Exercise;
											// Build a new exercise to insert
											var insertedExercise:Exercise = new Exercise();
											insertedExercise.id = mappedIds[3];
											// v3.5 Lets use a different icon for edited and inserted
											//insertedExercise.enabledFlag |= Exercise.ENABLED_FLAG_EDITED;
											insertedExercise.enabledFlag |= Exercise.ENABLED_FLAG_INSERTED;
											//insertedExercise.name = "(a new exercise)"; // expect this to be overriden with caption from AP
											insertedExercise.name = insertedCaption;
											
											// v3.5 AR To allow this item to be tracked back to the original, save the original UID
											insertedExercise.originalUID = UID;
											
											var addedTheExercise:Boolean = false;
											if (relatedExercise) {
												//MonsterDebugger.trace(this, "found related exercise " + relatedExercise.name);
												// need to splice it into the middle of the exercises
												for (var idx:uint = 0; idx < relatedUnit.exercises.length; idx++) {
													if (relatedUnit.exercises[idx] == relatedExercise) {
														//MonsterDebugger.trace(this, "add ex in at idx= " + idx);
														if (record.mode == Exercise.EDIT_MODE_INSERTEDAFTER)
															idx++;
														relatedUnit.exercises.splice(idx, 0, insertedExercise);
														addedTheExercise = true;
														break;
													}
												}
											}
											if (!addedTheExercise) {
												//MonsterDebugger.trace(this, "adding exercise at the end as can't find related.");
												relatedUnit.addExercise(insertedExercise);
											}
											insertedExercise.parent = relatedUnit;
										} else {
											//MonsterDebugger.trace(this, "couldn't find the inserted exercise " + UID);
										}
									}
								}
							}
							break;
						case Exercise.EDIT_MODE_MOVEDAFTER:
						case Exercise.EDIT_MODE_MOVEDBEFORE:
							// If it is moved then I need to first of all delete the original from the tree, then find the related UID object as that is where I will insert this one
							// First find the original. I wonder if you can just find it and then change the parents to get it to move?
							UID = record.editedContentUID;
							mappedIds = UID.split(".");
							thisTitle = ArrayUtils.searchArrayForObject(_titles, mappedIds[0], "id") as Title;
							
							if (thisTitle && mappedIds[1]) {
								thisCourse = ArrayUtils.searchArrayForObject(thisTitle.children, mappedIds[1], "id") as Course;
								if (thisCourse && mappedIds[2]) {
									thisUnit = ArrayUtils.searchArrayForObject(thisCourse.children, mappedIds[2], "id") as Unit;
									if (thisUnit && mappedIds[3]) {
										thisExercise = ArrayUtils.searchArrayForObject(thisUnit.children, mappedIds[3], "id") as Exercise;
									} else {
										// TODO: So you want to move a unit? That can come later but it would go something like this:
										// Find the related course and, hopefully, related unit below.
										// remove the original unit (you'll need to add a function to unit.as to do this)
										// and insert into the relatedCourse just as you do with exercise into unit.
										// Then reference the course as the parent.
									}
								}
							}
							// Then find where it should go
							relatedUID = record.relatedUID;
							// Now I need to find the object reference by that UID. I can't find anything built in to do this, but I would have thought I should be able to.
							relatedMappedIds = relatedUID.split(".");
							// This step might be unnecessary as you can't move out of a title, but that is just a rule...
							// NOTE: Here you are using the data from PHP as the related reference. But if you have moved other exercises
							// into the tree, these are not going to show in the _titles data. So perhaps we should be using the
							// tree itself to search for related stuff?
							relatedTitle = ArrayUtils.searchArrayForObject(_titles, relatedMappedIds[0], "id") as Title;
							//MonsterDebugger.trace(this, "found related title " + relatedTitle.name);
							
							if (relatedTitle && mappedIds[1]) {
								relatedCourse = ArrayUtils.searchArrayForObject(relatedTitle.children, relatedMappedIds[1], "id") as Course;
								//MonsterDebugger.trace(this, "found related course " + relatedCourse.name);
								if (relatedCourse && mappedIds[2]) {
									relatedUnit = ArrayUtils.searchArrayForObject(relatedCourse.children, relatedMappedIds[2], "id") as Unit;
									if (relatedUnit) {
										TraceUtils.myTrace("Move: found related unit " + relatedUnit.name);
										//MonsterDebugger.trace(this, "found related unit " + relatedUnit.name);
										// Need to add this before/after the related exercise - or at the end of the unit if you don't find the related one
										if (mappedIds[3]) {
											relatedExercise = ArrayUtils.searchArrayForObject(relatedUnit.children, relatedMappedIds[3], "id") as Exercise;
										}
										if (relatedExercise) {
											//MonsterDebugger.trace(this, "found related exercise " + relatedExercise.name);
										} else {
											//MonsterDebugger.trace(this, "no related exercise in UID");
										}
										// change the parent of this exercise, will that reset the tree?
										// Seems not. Need to do a remove and add. I could do this at any level I think. That would be useful.
										//thisExercise = ArrayUtils.searchArrayForObject(thisUnit.children, mappedIds[3], "id") as Exercise;
										//MonsterDebugger.trace(this, "found related exercise " + relatedUnit.name);
										
										// Remove the edited exercise from its original place in the tree
										thisUnit.removeExercise(thisExercise);
										//MonsterDebugger.trace(this, "removed " + thisExercise.name + " from " + thisUnit.name);

										addedTheExercise = false;
										if (relatedExercise) {
											// need to splice it into the middle of the exercises
											for (idx = 0; idx < relatedUnit.exercises.length; idx++) {
												if (relatedUnit.exercises[idx] == relatedExercise) {
													//MonsterDebugger.trace(this, "move ex in at idx= " + idx);
													if (record.mode == Exercise.EDIT_MODE_MOVEDAFTER)
														idx++;
													relatedUnit.exercises.splice(idx, 0, thisExercise);
													addedTheExercise = true;
													break;
												}
											}
										}
										if (!addedTheExercise) {
											//MonsterDebugger.trace(this, "adding exercise at the end as can't find related.");
											relatedUnit.addExercise(thisExercise);
										}
										thisExercise.parent = relatedUnit;
										//MonsterDebugger.trace(this, "moved: " + thisExercise.name + " into " + relatedUnit.name);
										
										// To allow this item to be tracked back to the original, save the original UID
										thisExercise.originalUID = UID;
										
										// v3.5 And let this be picked up as moved
										thisExercise.enabledFlag |= Exercise.ENABLED_FLAG_MOVED;

									}
								}
							}
							break;
					}
				}
			}
			//MonsterDebugger.trace(this, titles[0].courses[0].units[0]);
		}
		
		/**
		 * Make sure that this group is correctly setup for editing
		 * 
		 * @param	groupID
		 */
		public function checkEditedContentFolder(groupID:String):void {
			// v3.5 But the folder must have the same name as the id, so it won't be called this.
			// It is easiest to let PHP work out the name I think.
			//var editedContentLocation:String = '../../../ap/' + Constants.prefix + '/Courses/EditedContent-' + groupID;
			var editedContentLocation:String = '../../../ap/' + Constants.prefix;
			new RemoteDelegate("checkEditedContentFolder", [ editedContentLocation, groupID ], this).execute();			
		}
		/**
		 * Open this exercise in Author Plus by finding the path and sending it to Author Plus
		 * 
		 * @param	content, specifically an exercise
		 */
		//public function editInAuthorPlus(exercise:Exercise):void {
		public function editInAuthorPlus(exerciseUID:String, caption:String):void {
			//MonsterDebugger.trace(this, exerciseUID);
			//TraceUtils.myTrace("editInAuthorPlus for " + exerciseUID);
			
			// First you have to see if this exercise already exists in the Author Plus editing folder
			// In theory you can do this by looking at the enabledFlag to see if it is 'edited'
			// but it would be safer to actually check.
			// Is this safe to assume the ex, unit, course, title
			//var thisTitle:Title = exercise.parent.parent.parent as Title;
			//var thisCourse:Course = exercise.parent.parent as Course;
			var mappedIds:Array = exerciseUID.split(".");
			var thisTitleID:String = mappedIds[0];
			var thisCourseID:String = mappedIds[1];
			var thisUnitID:String = mappedIds[2];
			var thisExerciseID:String = mappedIds[3];
			// Actually you don't need to really find the object, passing the UID is sufficent
			// Also, if you are editing a moved exercise the original UID (which you should use to find the exercise) will not exist anyway
			// No - wrong. You need to send the caption to AP for it to build a menu.xml node in AP
			// Which is now passed in the event.
			// #132. Also I need to know the exercise.fileName as it might NOT be id.xml
			var thisTitle:Title = ArrayUtils.searchArrayForObject(_titles, mappedIds[0], "id") as Title;
			if (thisTitle) {
				//MonsterDebugger.trace(this, "found title");
				var thisCourse:Course = ArrayUtils.searchArrayForObject(thisTitle.courses, mappedIds[1], "id") as Course;
			}
			if (thisCourse) {
			//	MonsterDebugger.trace(this, "found course");
				// v3.5 AR You won't find this unit as you are looking for id="xx"
				// So either just hunt within all units to find the exercise or work out a better unit ID.
				// Try the first option...
				//var thisUnit:Unit = ArrayUtils.searchArrayForObject(thisCourse.units, mappedIds[2], "id") as Unit;
				editOuterLoop: for each (var thisUnit:Unit in thisCourse.units) {
					for each (var thisExercise:Exercise in thisUnit.exercises) {
						if (thisExercise.id == mappedIds[3]) {
							//TraceUtils.myTrace("I found the exercise");
							break editOuterLoop;
						}
					}
					// You didn't find the exercise
					thisExercise = undefined;
				}
			}
			//if (thisUnit) {
			//	// You can't find this exercise in the original unit as you have already moved it
			//	var thisExercise:Exercise = ArrayUtils.searchArrayForObject(thisUnit.exercises, mappedIds[3], "id") as Exercise;
			//}
			if (thisExercise) {
				//TraceUtils.myTrace("found exercise " + thisExercise.filename);
			}
			var myGroupID:String = Constants.groupID.toString();
			
			//var originalContentLocation:String = Constants.BASE_FOLDER + thisTitle.contentLocation + '/Courses/' + courseID + '/Exercises/' + exerciseID + '.xml';
			//var editedContentLocation:String = Constants.BASE_FOLDER + '../../../ap/' + Constants.prefix + '/Courses/EditedContent-' + myGroupID.toString() + '/Exercises/' + exerciseID + '.xml';
			// Bug fix. #132. TB, SSS, BW use course folder names that are NOT the course ID.
			// The subFolder attribute is never read and not easily passed. So I think we will have to drop this flexibility and change the folder names.
			// However, if you are too frightened to do this you could hardcode for these three titles?
			// Also you DO need the exercise item filename in case (SSS) that is different. 
			// But what will you put as the edited filename? Hopefully I can use ID for that. Yes you can.
			// v3.5 AR If you have inserted a new exercise and then want to edit it, the original is already in ap folder!
			// So thisTitle.contentLocation should point at '../../../ap/' + Constants.prefix. Does it?
			// Yes it does now, I had forgotten to save originalUID for inserted exercises.
			TraceUtils.myTrace("I found thisTitle.contentLocation=" + thisTitle.contentLocation + " and exercise=" + thisExercise.id);
			//var originalContentLocation:String = thisTitle.contentLocation + '/Courses/' + thisCourseID + '/Exercises/' + thisExerciseID + '.xml';
			var originalContentLocation:String = thisTitle.contentLocation + '/Courses/' + thisCourseID + '/Exercises/' + thisExercise.filename;
			// v3.5 But the folder must have the same name as the id, so it won't be called this.
			// It is easiest to let PHP work out the name I think.
			//var editedContentLocation:String = '../../../ap/' + Constants.prefix + '/Courses/EditedContent-' + myGroupID + '/Exercises/' + thisExerciseID + '.xml';
			var editedContentLocation:String = '../../../ap/' + Constants.prefix;
			// whilst I could read the file directly here, since I may well have to do a copy anyway I might as well do the whole thing in PHP
			// This remote action will copy the file if it doesn't exist and add a record to T_HiddenContent
			//MonsterDebugger.trace(this, "copy " + originalContentLocation + " to " + editedContentLocation + " for " + exerciseUID);
			//TraceUtils.myTrace("copy " + originalContentLocation + " to " + editedContentLocation + " for " + exerciseUID);
			//new RemoteDelegate("checkEditedContentExercise", [ originalContentLocation, editedContentLocation, myGroupID, thisExercise.toIDObject(), thisExercise.name ], this).execute();
			//new RemoteDelegate("checkEditedContentExercise", [ originalContentLocation, editedContentLocation, myGroupID, exerciseUID, thisExercise.name ], this).execute();
			//new RemoteDelegate("checkEditedContentExercise", [ originalContentLocation, editedContentLocation, myGroupID, exerciseUID, caption ], this).execute();
			// v3.5 So also pass exerciseID
			new RemoteDelegate("checkEditedContentExercise", [ originalContentLocation, editedContentLocation, myGroupID, exerciseUID, caption, thisExerciseID ], this).execute();
		}
		//private function startAuthorPlus(exercise:Exercise):void {
		// The courseID is the Editing Clarity Content course in Author Plus.
		private function startAuthorPlus(courseID:String, exerciseID:String, newExercise:Boolean = false):void {
			// Then you can fire the link
			// TODO Find the correct link for Author Plus Pro
			//Constants.BASE_FOLDER; // http://dock/Fixbench/Software/ResultsManager/web/
			//MonsterDebugger.trace(this, Constants);
			//var urlRequest:URLRequest = new URLRequest(Constants.BASE_FOLDER + "/../../area1/AuthorPlus/Author.php");
			var urlRequest:URLRequest = new URLRequest(Constants.HOST + "../../../area1/AuthorPlus/Author.php");
			//var urlRequest:URLRequest = new URLRequest("/Workbench/area1/AuthorPlus/Author.php");
			urlRequest.method = URLRequestMethod.GET;
			
			var sentVariables:URLVariables = new URLVariables();
			sentVariables.prefix = Constants.prefix;
			// TODO I would like to do a similar 'preview' technique here that I do between Arthur and Orchid.
			// But for now just pass on the command line.
			sentVariables.username = Constants.userName;
			sentVariables.password = Constants.password;
			// Not currently used, but would be nicer than using username for a validated login
			//sentVariables.userID = Constants.userID;
			
			//sentVariables.startingPoint = "ex:" + exercise.id;
			//sentVariables.course = exercise.parent.parent.id;
			sentVariables.preview = "true";
			sentVariables.startingPoint = "ex:" + exerciseID;
			//sentVariables.exerciseid = exerciseID;
			sentVariables.course = courseID;
			// use the same code for inserting, but need to tell AP about it
			if (newExercise)
				sentVariables.mode = "new";
			
			// For some reason s_preview is not getting through but prefix is!
			// s_preview goes in FlashVars and prefix goes in the argList.
			// It seems that the swfobject.getQueryParamValue() doesn't work when you do this to get parameter values
			// though it creates a URL that does work if you simply refresh the page.
			// I can get round it by using PHP to read the params rather than swfObject, but this can't be the whole picture
			// as username works through swfobject. Hmmm. Could it be the underscore somehow? Yes, that might be it.
			urlRequest.data = sentVariables;
			
			navigateToURL(urlRequest, "_blank");
		}
		// When you drag content around in the tree need to reflect this in the database
		public function moveContent(editedUID:String, groupID:String, relatedUID:String, mode:String):void {
			TraceUtils.myTrace("moving " + editedUID + " to " + relatedUID + " " + mode);
			switch (mode) {
				case RMNotifications.MOVE_CONTENT_AFTER:
					var editedContentMode:uint = Exercise.EDIT_MODE_MOVEDAFTER;
					break;
				case RMNotifications.MOVE_CONTENT_BEFORE:
					editedContentMode = Exercise.EDIT_MODE_MOVEDBEFORE;
					break;
			}
			// v3.5 Send title with the function
			// Which title are we interested in? Get it from editedUID to save having to put it into the content event.
			for each (var title:Title in _titles) {
				if (title.productCode == editedUID.split(".")[0]) {
					var thisTitle:Title = title;
					TraceUtils.myTrace("found title " + thisTitle.productCode);
					break;
				}
			}
			//new RemoteDelegate("moveContent", [ editedUID, groupID, relatedUID, editedContentMode ], this).execute();
			new RemoteDelegate("moveContent", [ editedUID, groupID, relatedUID, editedContentMode, thisTitle ], this).execute();
		}
		// To add a new exercise to content, insert it
		//public function insertContent(editedUID:String, groupID:String, relatedUID:String, mode:String):void {
		public function insertContent(exerciseID:String, groupID:String, relatedUID:String, mode:String):void {
			// v3.5 But the folder must have the same name as the id, so it won't be called this.
			// It is easiest to let PHP work out the name I think.
			//var editedContentLocation:String = '../ap/' + Constants.prefix + '/Courses/EditedContent-' + groupID;
			//var editedContentLocation:String = '../../../ap/' + Constants.prefix + '/Courses/EditedContent-' + groupID;
			var editedContentLocation:String = '../../../ap/' + Constants.prefix;
			switch (mode) {
				case RMNotifications.INSERT_CONTENT_BEFORE:
					var editedContentMode:uint = Exercise.EDIT_MODE_INSERTEDBEFORE;
					break;
				case RMNotifications.INSERT_CONTENT_AFTER:
					editedContentMode = Exercise.EDIT_MODE_INSERTEDAFTER;
					break;
			}
			//MonsterDebugger.trace(this, "going off to PHP with relatedUID=" + relatedUID + " and ex=" + exerciseID + " and mode=" + mode + " path=" + editedContentLocation);
			new RemoteDelegate("insertContent", [ exerciseID, groupID, relatedUID, editedContentMode, editedContentLocation ], this).execute();
		}
		// v3.4.1 When you drag from Author Plus to other content you are copying, but it ends up being the same as insert
		// except that you don't need to start Author Plus		
		public function copyContent(exerciseID:String, groupID:String, relatedUID:String, mode:String):void {
			// v3.5 But the folder must have the same name as the id, so it won't be called this.
			// It is easiest to let PHP work out the name I think.
			// Mind you copyContent doesn't use this path
			//var editedContentLocation:String = '../../../ap/' + Constants.prefix + '/Courses/EditedContent-' + groupID;
			var editedContentLocation:String = '../../../ap/' + Constants.prefix;
			switch (mode) {
				case RMNotifications.INSERT_CONTENT_BEFORE:
					var editedContentMode:uint = Exercise.EDIT_MODE_INSERTEDBEFORE;
					break;
				case RMNotifications.INSERT_CONTENT_AFTER:
					editedContentMode = Exercise.EDIT_MODE_INSERTEDAFTER;
					break;
			}
			new RemoteDelegate("copyContent", [ exerciseID, groupID, relatedUID, editedContentMode, editedContentLocation ], this).execute();
		}
		// Reset this edited content.
		public function resetEditedContent(editedUID:String, groupID:String):void {
			new RemoteDelegate("resetContent", [ editedUID, groupID ], this).execute();
		}

		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		
		public function onDelegateResult(operation:String, data:Object):void {
			switch (operation) {
				case "getContent":
					titles = data as Array;
					
					// v3.4 Also keep a version that you can use for reset.
					//resetContent = ArrayUtils.duplicate(data, true) as Array;
					resetContent = ObjectUtil.copy(titles) as Array;
					//MonsterDebugger.trace(this, "resetContent is original copy");
					//MonsterDebugger.trace(this, titles[0].courses[0]);
					//MonsterDebugger.trace(this, resetContent[0].courses[0]);

					// Now we have the main content get the data on what is hidden for groups
					getHiddenContent();
					// And get the edited content at the same time - or should I wait and get that after hiddenContent comes back?
					// Or indeed do it as part of getHiddenContent? The drawback with doing hidden and edited together is that both
					// trigger a refresh of the tree rendering.
					getEditedContent();
					
					sendNotification(RMNotifications.CONTENT_LOADED, titles);
					break;
				// When you move or insert content, you then need to get the latest hiddenContent records
				// and refresh the tree
				case "moveContent":
					getEditedContent();
					//sendNotification(RMNotifications.EDITED_CONTENT_LOADED);
					break;
				// Resetting also requires you to redraw the whole tree
				case "resetContent":
					getEditedContent();
					break;
				case "getHiddenContent":
					hiddenContent = data;
					//MonsterDebugger.trace(this, data);
					sendNotification(RMNotifications.HIDDEN_CONTENT_LOADED);
					break;
				case "getEditedContent":
					editedContent = data;
					//MonsterDebugger.trace(this, data);
					sendNotification(RMNotifications.EDITED_CONTENT_LOADED);
					break;
				case "setHiddenContent":
					getHiddenContent();
					break;
				case "insertContent":
					var newExercise:Boolean = true;
					// then keep going to AuthorPlus
				case "checkEditedContentExercise":
					//MonsterDebugger.trace(this, "back with courseID=" + data.courseID + " and off to AP");
					startAuthorPlus(data.courseID, data.exerciseID, newExercise);
					break;
				case "copyContent":
				case "checkEditedContentFolder":
					// Really nothing to do. Could tell the view to put up a success message.
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, operation + ": " + data);
		}
		
	}
}