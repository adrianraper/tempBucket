// ActionScript Document
// v6.3.2 Add a new function so that a score record is created for exercises that don't have a marking button
justMarking = function() {
	var thisScore = new ScoreObject({itemID:_global.ORCHID.session.currentItem.ID, unit:_global.ORCHID.session.currentItem.unit});
	thisScore.skipped = thisScore.correct = thisScore.wrong = -1;
	// special score for non-marked exercises to show participation
	thisScore.score = -1;
	var me = _global.ORCHID.LoadedExercises[0];
	me.score = thisScore;
	// trace for return from the database
	thisScore.onReturnCode = function() {
		//myTrace("saved a null score record");
		// v6.3.4 Ugly flag to make sure all scores written before exit
		//if (_global.ORCHID.commandLine.scorm) {
			//myTrace("set scoreDirty to false");
			_global.ORCHID.session.currentItem.scoreDirty = false;
		//}
	}
	// v6.2 - bug correction. Only save the score the first time that you click marking. You will still display
	// it for other times, but NOT save it.
	if (!_global.ORCHID.session.currentItem.marked) {
		// send the score record to the database 
		myTrace("just marking: write out score for unit=" + thisScore.unit + " itemID=" + thisScore.itemID);
		// v6.3.4 Ugly flag to make sure all scores written before exit
		//if (_global.ORCHID.commandLine.scorm) {
		//myTrace("set scoreDirty to true");
		_global.ORCHID.session.currentItem.scoreDirty = true;
		//}
		thisScore.writeOut();
		//Note: AND ALSO to the progress object please (in fact, you might not write to the db until a batch at the end??
		// v6.4.2.8 progress records now expect the userID in them
		thisScore.userID = _global.ORCHID.user.userID;
		// v6.5.5.0 Allow single inserts to be differentiated
		_global.ORCHID.course.scaffold.insertProgressRecord(thisScore, true);
		//trace("first time marking so save it");
	} else {
		myTrace("this exercise has been marked once, so don't save the score again");
	}
	_global.ORCHID.session.currentItem.marked = true;
}
mainMarking = function(justMarking) {
	myTrace("in mainMarking, (just marking=" + justMarking +")");
	// v6.3.5 Marking for countDown
	// This will require a pretty different routine.
	// 1) Score comes from a) any words you guessed that had 0 results
	//						b) the number of words you guessed RIGHT
	//						c) the number of words you did not guess
	// This means that you will need to make a merged list from all the twfs.
	// 2) Show the answers, you really need to show which ones you missed
	//	this might be done by each twf going through the words array and doing a replacement
	//	in a colour/underline of that word if the word not guessed (so you need to mark the words[i].guessed
	//	array when you guess a word)
	// 3) Feedback would be score based, this would be as normal
	// *****
	// SCORE writing section
	// *****
	// prepare a score object to hold this information and write it to the db (and progress)
	var thisScore = new ScoreObject({itemID:_global.ORCHID.session.currentItem.ID, unit:_global.ORCHID.session.currentItem.unit});
	//trace("created score record with duration=" + thisScore.duration);
	// look up in the exercise object to see what the scores are
	thisScore.skipped = thisScore.correct = thisScore.wrong = 0;
	var me = _global.ORCHID.LoadedExercises[0];
	//trace("in mM, ex.mode=" + me.mode);
	
	// v6.3.5 Countdown has radically different way to do the scoring
	// v6.4.2 As does a survey
	var allGroups = me.body.text.group;
	var allFields = me.body.text.field;
	if (me.settings.exercise.type == "Countdown") {
		myTrace("marking a countDown");
		var myPane = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP;
		var contentHolder = myPane.getScrollContent(); 
		var wordList = new Array();
		// first merge all the word lists
		for (var i in contentHolder) {
			// Again, this brings out all objects, not just twfs. Guess it doesn't matter too much
			// v6.4.2.7 yes it does matter. I also get something called endMarker with a 2 array wordList.
			if (i.indexOf("ExerciseBox")>=0) {
				//myTrace("look in twf " + contentHolder[i]);
				// v6.4.2.7 Simplfy to only get word, not word object. No
				wordList = wordList.concat(contentHolder[i].getWordList());
				//myTrace(i + " wordList.length=" + wordList.length);
			}
		}
		// then sort (and get rid of duplicates)
		// Need to do more work on this, make sure words don't contain any white space.
		// Capitalisation parameter should be significant here.
		//wordList.sortOn("word");
		var uniqueWordList = new Array();
		var lastWord = undefined;
		var thisWord = undefined;
		for (var i in wordList) {
			thisWord = wordList[i];
			//myTrace("full word list=" + thisWord.word);
			//myTrace("full word list=" + thisWord);
			if (thisWord.word != lastWord) {
			//if (thisWord != lastWord) {
				//// do nothing first time through
				//if (thisWord != undefined) {
				//	uniqueWordList.push(thisWord);
				//	myTrace("unique word list=" + thisWord.word);
				//}
				//thisWord = wordList[i];
				//lastWord = thisWord.word;
				// do nothing first time through
				uniqueWordList.push(thisWord);
				//myTrace("unique word list=" + thisWord.word);
				lastWord = thisWord.word;
				//lastWord = thisWord;
			} else {
				// if any duplicated words were true (can't see how this would happen)
				//if (wordList[i].guessed) {
				//	thisWord.guessed = true;
				//}
			}
		}
		//myTrace("unique word list=" + uniqueWordList.length);
		// then count how many you got, missed and got wrong
		// note that wrong guesses will be added up in the allGroups[0].incorrectClicks field
		// for want of anywhere better to put them. These are added in at the end.
		for (var i in uniqueWordList){
			if (uniqueWordList[i].guessed) {
				//myTrace("guessed " + uniqueWordList[i].word);
				thisScore.correct++;
			} else {
				//myTrace("skipped " + uniqueWordList[i].word);
				thisScore.skipped++;
			}
		}
		// to save time if they click on stats, save this word list
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.statsList = uniqueWordList;
		
	} else if (me.settings.exercise.type == "Survey") {
		//myTrace("survey marking");
		this.maxScore =0;
		for (var i in allGroups) {
			// read the selected field in each question, see what its value is, write to scoreDetail and accumulate
			if (allGroups[i].id > 0) {
				var groupScore=undefined;
				for (var j in allGroups[i].fieldsInGroup) {
					if (allFields[allGroups[i].fieldsInGroup[j]].attempt.score != undefined) {
						//myTrace("for group " + allGroups[i].ID + " add field " + allFields[allGroups[i].fieldsInGroup[j]].ID + ", score=" + allFields[allGroups[i].fieldsInGroup[j]].attempt.score);
						groupScore += allFields[allGroups[i].fieldsInGroup[j]].attempt.score;
					} else {
						//myTrace("for group " + allGroups[i].ID + " add field " + allFields[allGroups[i].fieldsInGroup[j]].ID + " with no score");
					}
				}
				allGroups[i].score = groupScore;
				//myTrace("question " + allGroups[i].id + " is " + groupScore + " out of " + allGroups[i].maxScore);
				// Either have a default value for a question that is ignored, or don't add in the total
				// otherwise the score of 0 would skew the result. Can use 0 as a score for n/a answer.
				if (groupScore > 0 && groupScore != undefined) {
					thisScore.correct += groupScore;
					thisScore.maxScore += allGroups[i].maxScore;
				} else {
					thisScore.skipped++;
				}
			}
		}
		// badly use F_ScoreWrong to hold the max score for this survey
		thisScore.wrong = thisScore.maxScore;
		myTrace("your total=" + thisScore.correct + " out of " + thisScore.maxScore);
		// manually set the % score to stop if being calculated in the normal way
		if (thisScore.maxScore <=0 ) {
			thisScore.score = 0;
		} else {
			thisScore.score = Math.round(100*(thisScore.correct/(thisScore.maxScore)));
		}
	} else {
		for (var i in allGroups) {
			// v6.3.4 drags and things are in special groups (zero or negative)
			if (allGroups[i].id > 0) {
				//v6.3.4 I need to merge all scores of fields within this group
				// If any score is undefined, then don't mess with it otherwise the group will not be undefined but 0
				var groupScore=undefined;
				for (var j in allGroups[i].fieldsInGroup) {
					if (allFields[allGroups[i].fieldsInGroup[j]].attempt.score != undefined) {
						//myTrace("for group " + allGroups[i].ID + " add field " + allFields[allGroups[i].fieldsInGroup[j]].ID + ", score=" + allFields[allGroups[i].fieldsInGroup[j]].attempt.score);
						groupScore += allFields[allGroups[i].fieldsInGroup[j]].attempt.score;
					} else {
						//myTrace("for group " + allGroups[i].ID + " add field " + allFields[allGroups[i].fieldsInGroup[j]].ID + " with no score");
					}
				}
				allGroups[i].score = groupScore;
				//myTrace("for group " + allGroups[i].ID + " score=" + groupScore + " maxScore=" + allGroups[i].maxScore);
				//var groupScore = allGroups[i].attempt.score;
				//trace("group " + allGroups[i].id + " has score [" + allGroups[i].attempt.score + "]");
				//if (groupScore == 0) {
				// v6.3.4 Need to change order as < catches undefined, but this will make it harder to read
				// the code, so add in an extra condition.
				if (groupScore < allGroups[i].maxScore && groupScore != undefined) {
					thisScore.wrong++;
				// v6.3.4 Allow compound scoring in a group
				//} else if (groupScore == 1) {
				} else if (groupScore >= allGroups[i].maxScore) {
					//myTrace("group " + allGroups[i].id + " has score 1");
					thisScore.correct++;
				} else if (groupScore == undefined) {
					//trace("group " + allGroups[i].id + " has score undefined");
					// You haven't answered this question/group, so it counts as skipped
					// except that if you weren't supposed to 'get' this field (such as a red-herring in 
					// a [hidden] target spotting) it hasn't been skipped
					
					// v6.2 This was causing bad marking in multiple choice - I guess because
					// I wasn't thinking about many targets - of course sometimes I will hit ones
					// with .correct=true and sometimes not with this first search.
					if (allGroups[i].singleField) {
						// v6.2 - actually I don't think this has anything to do with targets being hidden or not
						// it is simply the case of any targetSpotting having red-herrings that should be ignored
						// if you didn't click on them. So just change the outside condition
						//if (me.mode & _global.ORCHID.exMode.HiddenTargets) {
						// v6.2 - Note that the groupID doesn't necessarily equal the fieldID in that group
						// and the lookup only works if you know the fieldID not the other way round
						//var thisFieldIDX = lookupArrayItem(me.body.text.field, allGroups[i].id, "id"); 
						//trace("this field[" + thisFieldIDX +"]=" + me.body.text.field[thisFieldIDX].answer[0].value);
						var thisFieldIDX = undefined;
						for (var j in allFields) {
							if (allFields[j].group == allGroups[i].id) {
								thisFieldIDX = j;
								break;
							}
						}
						if (me.body.text.field[thisFieldIDX].type == "i:target") {
							// so we are in a hidden targets exercise
							// but if the field associated with this group (1:1 for target spotting)
							// was true then this still counts as skipped. If not, then ignore it.
							if(me.body.text.field[thisFieldIDX].answer[0].correct == "true") {
								//trace("count this one as skipped");
								thisScore.skipped++;
							} else {
								//trace("don't count this one as skipped");
							}
						// v6.3.4 Another type of red-herring in targetGaps will be correct without doing anything
						// or this might happen in dropInsert as well
						//} else if (me.body.text.field[thisFieldIDX].type == "i:targetGap" ||
						} else if (me.body.text.field[thisFieldIDX].type == "i:dropInsert") {
							//myTrace("targetGap you ignored");
							// so this is a targetGap that they didn't touch
							// and if the target is correct they are right
							if (me.body.text.field[thisFieldIDX].answer[0].correct == "true") {
								//myTrace("you ignored " + me.body.text.field[thisFieldIDX].answer[0].value + " so +1");
								thisScore.correct++;
								allGroups[i].score++;
							} else {
								//trace("count this one as skipped");
								thisScore.skipped++;
							}
						} else {
							thisScore.skipped++;
						}
					} else {
						// this is not a single field so there is NO excuse for not "doing" it
						thisScore.skipped++;
					}
		
				// this last category is included for completeness even though the
				// neutral field is not currently recorded.
				} else if (groupScore === null) {
					//trace("group " + allGroups[i].id + " has score null");
					thisScore.neutral++;
				} else {
					//trace("group " + allGroups[i].id + " has score ???");
				}
			}
		}
	}
	// some exercises count incorrect clicks, these are outside of any group, so (!) kept in group[0]
	// v6.4.2.7 Change where the incorrect ones are stored
	if (me.settings.exercise.type == "Countdown") {
		var cdController = _global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController;
		if (cdController.incorrectClicks > 0) {
			thisScore.wrong += cdController.incorrectClicks;
		}
	} else {
		//myTrace("wrong=" + allGroups[0].incorrectClicks);
		if (allGroups[0].incorrectClicks > 0) {
			thisScore.wrong += allGroups[0].incorrectClicks;
		}
	}
	// v6.4.2 Calculate the percentage ONLY if you haven't set it directly
	// now convert these parts into a %
	if (thisScore.score == undefined || thisScore.score == "") {
		thisScore.calcPercentage();
	}
	// v6.4.3 Add special marker to scores from 'test' exercises
	// How will we make 'submit and hide' tests from the test button then?
	if (_global.ORCHID.LoadedExercises[0].settings.marking.test) {
		myTrace("this is a test, so testUnits=*");
		thisScore.testUnits = "*";
	}
	
	// trace for return from the database
	thisScore.onReturnCode = function() {
		// display the score in a nice window once it has been written out
		myTrace("you got " + thisScore.score + "% in that exercise");
		//trace("now this exercise has been marked once");
		// Ahh, if you do this here (which is logically correct), then as this is asynchronous
		// you might actually be onto the next exercise by the time you come back!
		// So move it to the main body
		//_global.ORCHID.session.currentItem.marked = true;
		// v6.3.4 Ugly flag to make sure all scores written before exit
		//if (_global.ORCHID.commandLine.scorm) {
			//myTrace("set scoreDirty to false");
			_global.ORCHID.session.currentItem.scoreDirty = false;
		//}
	}
	// v6.2 - bug correction. Only save the score the first time that you click marking. You will still display
	// it for other times, but NOT save it.
	if (!_global.ORCHID.session.currentItem.marked) {
		// send the score record to the database 
		myTrace("write out score for unit=" + thisScore.unit + " itemID=" + thisScore.itemID);
		// v6.3.4 Ugly flag to make sure all scores are written before exit
		//myTrace("set scoreDirty to true");
		_global.ORCHID.session.currentItem.scoreDirty = true;
		thisScore.writeOut();
		//Note: AND ALSO to the progress object please (in fact, you might not write to the db until a batch at the end??
		// v6.4.2.8 progress records now expect the userID in them
		thisScore.userID = _global.ORCHID.user.userID;
		// v6.5.5.0 Allow single inserts to be differentiated
		_global.ORCHID.course.scaffold.insertProgressRecord(thisScore, true);
		//trace("first time marking so save it");
		
		// v6.5.5.0 If we need to save the exercise details for item analysis or portfolio, we can do it here
		if (me.settings.exercise.saveDetails) {
			myTrace("save details for this exercise");
			// build up an array of the details that we want to write out
			var buildItems = new Array();
			// Can we simply run through all fields, or should we do it by group and use fieldsInGroup?
			// We will have to do it by groups because we need to save null for unselected questions
			/*
			for (var i in allFields) {
				// was this field selected?
				if (allFields[i].attempt.score != undefined) {
					// what is the question number for this field?
					var thisGroup = allFields[i].group;
					var groupArrayIDX = lookupArrayItem(allGroups, thisGroup, "ID");
					var qNumber = allGroups[groupArrayIDX].questionNumber;
					buildItems.push({itemID:qNumber, detail:allFields[i].attempt.finalAnswer});
					myTrace("save field=" + allFields[i].id + " detail=" + allFields[i].attempt.finalAnswer + " group=" + thisGroup + " question=" + qNumber);
				} else {
					//myTrace("ignore field=" + allFields[i].id);
				}
			}
			*/
			for (var i in allGroups){
				// ignore special groups (drags etc)
				if (allGroups[i].id > 0) {
					var thisQuestionAnswered = false;
					// If this is a question based exercise we know the question number
					// Note (but what if we are using a starting question number, will the first one be 26?)
					// Perhaps what we really want is just the groupID anyway as that will work for text based too.
					//myTrace("questionNumber=" + allGroups[i].questionNumber + " groupID=" + allGroups[i].id); 
					//var qNumber = allGroups[i].questionNumber;
					var qNumber = allGroups[i].id;
					for (var j in allGroups[i].fieldsInGroup) {
						var thisField = allFields[allGroups[i].fieldsInGroup[j]];
						// was this field selected?
						if (thisField.attempt.score != undefined) {
							thisQuestionAnswered = true;
							// what is the question number for this group?
							buildItems.push({itemID:qNumber, detail:thisField.attempt.finalAnswer, score:thisField.attempt.score});
							myTrace("save detail=" + thisField.attempt.finalAnswer + " question=" + qNumber + " score=" + thisField.attempt.score);
							
							// you can't break out of this loop as you may have a multi-select question (its possible?)
						}
					}
					// Make sure that un-answered questions are recorded too
					if (!thisQuestionAnswered) {
						buildItems.push({itemID:qNumber});
					}
				}
			}
			// Now we have an array of items that we want to write to the details table. How do we pass that to the script?
			// and do we want to wait and confirm they have been written? Maybe not, just plough on.
			// Perhaps build a scoreDetail object to handle the writing
			thisScoreDetail = new ScoreDetailObject({exerciseID:_global.ORCHID.session.currentItem.ID, unitID:_global.ORCHID.session.currentItem.unit});
			thisScoreDetail.onReturnCode = function(records) {
				myTrace("wrote out " + records + " records");
			}
			thisScoreDetail.details = buildItems;
			thisScoreDetail.writeOut();
		}
		
	} else {
		//trace("this exercise has been marked once, so don't save it again");
	}
	_global.ORCHID.session.currentItem.marked = true;
	
	// attach the score record to the Ex Object in case anything else (like delayed fb) wants it
	me.score = thisScore;

	// v6.3.2 Sometimes you only want to do the marking part and no display stuff
	if (justMarking) {
		//myTrace("saved a full score, but no display");
	// v6.3.5 and other times you want to just mark and then keep going
	} else if (_global.ORCHID.LoadedExercises[0].settings.marking.test) {
		myTrace("testing mode");
		// give a visual clue that all is well and the score is being saved
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.exMarking_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("saving", "buttons"));
		this.delayedMove = function() {
			clearInterval(this.delayedInt);
			delete this.delayedMove;
			_global.ORCHID.viewObj.moveExercise("dummy", "forward");
		}
		this.delayedInt = setInterval(this, "delayedMove", 500);
	} else {
		myTrace("regular marking mode");
		// pass the record to the progress swf to let it display the score as it likes
		// this window will also hold a 'try again' 'see the answers' option for the user
		// which will impact what we do next. So in fact, we shouldn't do all the colouring
		// and switching off until they have come back from that.
		// is there anything to do once the record is written?
		// 6.0.2.0 remove connection
		//_root.progressHolder.myConnection.displayYourScore(thisScore, this.tryAgainCallback);
		//_root.progressHolder.progressNS.displayYourScore(thisScore, this.tryAgainCallback);
		// 6.0.4.0 display the score through view object
		_global.ORCHID.viewObj.displayYourScore(thisScore, this.tryAgainCallback);
	
		// v6.2 Since you have now recorded the score, you can do marking colouring and highlighting
		// (but this will NOT insert the correct answers)
		// v6.3.3 To get better tryAgain behaviour, don't change any colours until you know that you are
		// going to look at the correct answers. So do this bit in tryAgainCallback.
		// v6.3.4 Due to a clash in start again/try again between CUP and Clarity we need to react
		// differently here. CUP want to change colours and show ticks/crosses immediately
		// and since you can't try again this won't ruin anything that follows. But Clarity allows try again
		// so at this point you can't change anything on the screen.
		// v6.4.2.7 What if I want to see ticks and crosses for Clarity too?
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
			//myTrace("set colouring mode to " + _global.ORCHID.marking.showTicks);
			markingColouringAndInserting(_global.ORCHID.marking.showTicks);
			// v6.3.3 Move this function from markingColouringAndInsertingCallback
			afterMarkingFieldDisable();
		} else {
			// v6.4.2.7 If my setting is instantMarking, then I will already have ticks and crosses and I don't want
			// to overwrite them because I might be changing a field that I got wrong then right to a cross whilst
			// the wrong word is still in the field. Of course, I might have switched from instant to delayed then done marking
			// but that is just too bad.
			if (!_global.ORCHID.LoadedExercises[0].settings.marking.instant) {
				markingColouringAndInserting(_global.ORCHID.marking.showTicks);
			}
		}
	}	
	// v6.3.3 for SCORM, once you have marked an exercise, set the bookmark to the next one (if there is one)
	// Move from here to score.writeOut as you don't get into mainMarking for presentation exercises
	/*
	if (_global.ORCHID.commandLine.scorm) {
		if (_global.ORCHID.session.nextItem.ID != undefined) {
			myTrace("end of main marking, set bookmark");
			_root.scormHolder.scormNS.setBookmark(_global.ORCHID.session.nextItem.ID);
		} else {
			myTrace("end of main marking, but no nextItem, so don't set bookmark");
		}
	}
	*/
}
// v6.2 The score record is not passed around
//tryAgainCallback = function(event, thisScore) {
tryAgainCallback = function(event) {
	myTrace("in tryAgainCallback with " + event);
	// do the colouring of those fields that you have got right
	if (event == "startAgain") {
		// v6.2 For CUP (at least) try again means restart this exercise. So this will
		// involve clearing out some stuff and redisplaying the exercise.
		// rather than go through all the little bits, it is safer to completely refresh
		//reset the exercise score
		/*
		var me = _global.ORCHID.LoadedExercises[0];
		me.score = undefined;
		_global.ORCHID.session.currentItem.marked = false;
		_global.ORCHID.session.currentItem.clicks = 0;
		for (var i in me.body.text.group) {
			me.body.text.group[i].attempt.score = undefined;
			me.body.text.group[i].attempt.finalAnswer = undefined;
		}
		// v6.2 switch off the marked mode setting
		me.mode &= ~_global.ORCHID.exMode.MarkingDone;
		// also try setting drop zone to a fresh one - good idea??
		_root.exerciseHolder.dropZoneList = new Array();		
		_root.exerciseHolder.exerciseNS.displayExercise(0);
		//markingColouringAndInserting(thisScore, _global.ORCHID.marking.showWrong);
		*/
		// v6.3.5 You can't start a test again like this
		myTrace("start again from currentItem.unit=" + _global.ORCHID.session.currentItem.unit);
		if(_global.ORCHID.session.currentItem.unit < 0) { 
			// v6.4.2.7 This is no good because the number of questions and units are pulled only from the 
			// puw, which will have been cleared out. So save them in the following function.
			_global.ORCHID.viewObj.cmdRandomTest();
		} else {
			myTrace("regular repeat");
			_global.ORCHID.root.mainHolder.exerciseNS.clearExercise(0);
			// v6.3.6 Merge creation into main
			//_root.creationHolder.creationNS.createExercise(_global.ORCHID.session.currentItem);
			_global.ORCHID.root.mainHolder.creationNS.createExercise(_global.ORCHID.session.currentItem);
		}
		//v6.4.2 Going back to ex, reenable marking
		_global.ORCHID.viewObj.setMarking(true);

	} else if (event == "tryAgain") {
			// v6.3.3. See if doing nothing is the desired action for non CUP work
			// The action is basically OK, colour and answers are left, but the fields are no longer active
			// Somewhere we are switching them off.
			// in markingColouringAndInsertingCallback we call afterMarkingFieldDisable - how to stop this?
			// move the call from that function into this one, just when you want it
		
		// v6.4.2.7 You need to take off the ticks and crosses which you have just added
		markingRemoveHighlighting();
		//v6.4.2 GOing back to ex, reenable marking
		_global.ORCHID.viewObj.setMarking(true);
		
	// do everything associated with finishing the exercise
	} else if (event == "seeTheAnswers") {
		//trace("call to clear jukebox from feedback.as");
		//_root.jukeboxHolder.myJukeBox.clear();
		// v6.3.3 Move all marking stuff to currentItem
		//_global.ORCHID.LoadedExercises[0].mode |= _global.ORCHID.exMode.MarkingDone;
		_global.ORCHID.session.currentItem.afterMarking = true;
		//_global.ORCHID.root.buttonsHolder.buttonsNS.setMarking(false);
		//_global.ORCHID.root.buttonsHolder.buttonsNS.setFeedback(true);
		// 6.0.4.0, AM: I should not set the button state here.
		// Later, I should boardcast a event to view object only.
		//v6.4.2 Do this much earlier to stop double click
		//_global.ORCHID.viewObj.setMarking(false);
		_global.ORCHID.viewObj.setFeedback(true);
		// v6.4.2.4 Enable a start again button for after marking
		_global.ORCHID.viewObj.setStartAgain(true);
		
		markingRubricUpdate();
		// v6.2 the score record is not passed around
		// v6.2 You need to take off the ticks and crosses
		markingRemoveHighlighting();
		// v6.2 and the do inserting (no colour changes)
		// v6.4.2.4 Can the BC/IELTS get ticks and crosses?
		// v6.4.2.7 Can we add this to all programs?
		//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BC/IELTS") >= 0) { 
		// v6.4.2.7 Except that CUP only wants to show ticks and crosses before you show the answers
		// not when the answers are visible
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
			var markingMode = _global.ORCHID.marking.showAll;
		} else {
			myTrace("show ticks in marking");
			//_global.ORCHID.marking.showWrong = 2;
			// v6.4.2.7 But hide the crosses after you show the answers as it will confuse the issue
 			//var markingMode = _global.ORCHID.marking.showCorrect + _global.ORCHID.marking.showSkipped + _global.ORCHID.marking.showAnswers + _global.ORCHID.marking.showTicks;
 			var markingMode = _global.ORCHID.marking.showCorrect + _global.ORCHID.marking.showSkipped + _global.ORCHID.marking.showAnswers + 
								_global.ORCHID.marking.showTicks + _global.ORCHID.marking.hideCrosses;
		}		
		// v6.3.3 Put back in the colour change here to cope with tryAgain behaviour
		markingColouringAndInserting(markingMode);
		//myTrace("done markingAndInserting");
		//markingColouringAndInserting(_global.ORCHID.marking.showAnswers);
		markingMultimediaUpdate();
		// v6.3.3 Move this function from markingColouringAndInsertingCallback
		// v6.3.5 Why? Because thanks to tlc this will end up running BEFORE markingColouring etc
		// and this is causing problems with single click for feedback.
		//myTrace("start afterMarkingFieldDisable");
		afterMarkingFieldDisable();
		// v6.3.5 Countdown can now see the stats Button and hide the guess word thing
		// v6.5.6.5 Except that we don't like this anymore - the stats seem useless. So can we hide the whole thing?
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) { 
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController._visible = false;
			// But I will also need to hide the NoScroll region I think.
		} else {
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.cdStats_pb.setEnabled(true);
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.word_i.setEnabled(false);
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.cdGuess_lbl.setEnabled(false);
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.cdGuessWord_pb.setEnabled(false);
		}

	// they want to see feedback. For CUP this means NOT doing inserting 
	} else if (event == "feedback") {
		_global.ORCHID.viewObj.setMarking(false);
		_global.ORCHID.viewObj.setFeedback(true);
		markingRubricUpdate();
		markingMultimediaUpdate();
		afterMarkingFieldDisable();
		// simulate clicking the feedback button - but with different buttons to normal feedback window
		var setting = "fromScore"
		_global.ORCHID.viewObj.cmdFeedback(setting);
		// v6.3.5 Countdown can now see the stats Button
		_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.cdStats_pb.setEnabled(true);

	// see if they want feedback or to go to the next exercise
	} else if (event == "finish") {
		//myTrace("called finish");
		//_global.ORCHID.root.buttonsHolder.buttonsNS.moveExercise("dummy", "forward");
		_global.ORCHID.viewObj.moveExercise("dummy", "forward");
	} else {
		//v6.4.2 GOing back to ex, reenable marking - just in case
		_global.ORCHID.viewObj.setMarking(true);
		myTrace("called no event=" + event);
	}
}

markingRubricUpdate = function() {
	// use the textFormat of the first character of the title that they typed to
	// format the preset title
	// v6.2 Note that you cannot change the original title otherwise startAgain cannot
	// restore it. So make a new variable;
	/*
	var titleText = _global.ORCHID.LoadedExercises[0].title.text;
	// CUP/GIU change the messge (which should be from literals - goodness me!).
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		//titleText.paragraph[0].plainText = '<font face="Verdana" size="16" color="#' + _global.ORCHID.CorrectText.rawColor +'"><b>Look at the correct answers.</b></font>';
		titleText.paragraph[0].coordinates.y += 10;
		titleText.paragraph[0].plainText = '<font face="Verdana" size="12" color="#FFFFFF"><b>Look at the correct answers.</b></font>';
	} else {
		titleText.paragraph[0].plainText = '<font face="Arial" size="12"><b>Your answers: <font color="#' + _global.ORCHID.YouWereCorrectText.rawColor +'">correct</font>, ' + 
								'<font color="#' + _global.ORCHID.YouWereWrongText.rawColor +'">wrong</font>, ' +
								'<font color="#' + _global.ORCHID.CorrectText.rawColor +'">missed or corrected.</font></b></font>';
		titleText.paragraph[0].style = "headline";
	}
	*/
	var originalText = _global.ORCHID.LoadedExercises[0].title.text;
	var titleText = new Object();
	var newText = new Object();
	newText.coordinates = new Object();
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
		newText.coordinates.x = 0;
		newText.coordinates.y = 10;
		newText.coordinates.width = 506;
		newText.coordinates.height = 0;
		newText.plainText = '<font face="Verdana" size="12" color="#FFFFFF"><b>Look at the correct answers.</b></font>';
	} else {
		// v6.3.5 Can you take the coordinates from the original title?
		newText.coordinates = originalText.paragraph[0].coordinates;
		//newText.coordinates.x = 13;
		//newText.coordinates.y = 10;
		newText.coordinates.width = 600; // override the width, to try to always fit on one line??
		//newText.coordinates.height = 0;
		//myTrace("width=" + newText.coordinates.width);
		// v6.3 Proof reading uses a different rubric
		// v6.3.4 Unless it is an error correction version.
		// v6.3.3 change mode to settings
		//if (_global.ORCHID.LoadedExercises[0].mode. & _global.ORCHID.exMode.ProofReading) {
		var thisExType = _global.ORCHID.LoadedExercises[0].settings.exercise.type;
		// v6.4.2.7 In general we are now going to be using a tick system, so the rubric can be a lot easier. No need to explain all the colours.
		// In fact, who is not going to be in this system? NAS is.
		//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("Clarity") >= 0) { 
		// but leave the old code so that Road to IELTS stays the same
		// v6.4.3 An errorCorrection exercise will end up with a regular markedRubric as you will be looking at the correct answers
			if (_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading && !_global.ORCHID.LoadedExercises[0].settings.exercise.correctMistakes) {
				var useLit = "markedRubricProofReading";
			} else if (thisExType == "Countdown") {
				var useLit = "markedRubricCountdown";			
			} else {
				var useLit = "markedRubric";
			}
		/*
			} else {
			if (_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading && !_global.ORCHID.LoadedExercises[0].settings.exercise.correctMistakes) {
				var useLit = "markedRubricProofReading";
				// v6.4.2.4 make this bit common to all exercise types
				//newText.plainText = '<font face="Verdana" size="13" color="#' + _global.ORCHID.PRCorrectText.rawColor +'"><b>' + 
				//				_global.ORCHID.literalModelObj.getLiteral("markedRubricProofReading", "labels") +
				//				'</b></font>';
			} else if (_global.ORCHID.LoadedExercises[0].settings.marking.overwriteAnswers) {
				var useLit = "markedRubric";
				// v6.4.2.4 make this bit common to all exercise types
				//newText.plainText = '<font face="Verdana" size="13" color="#' + _global.ORCHID.NeutralText.rawColor +'"><b>' + 
				//				substTags(_global.ORCHID.literalModelObj.getLiteral(useLit, "labels"),substList) +
				//				'</b></font>';
			} else {
				if (thisExType == "Quiz" || thisExType == "MultipleChoice" || thisExType == "Analyze") {
					var useLit = "markedRubricOptions";
				} else if (thisExType == "Countdown") {
					var useLit = "markedRubricCountdown";
				} else {
					var useLit = "markedRubricGaps";
				}
				//myTrace("rubric for " + thisExType + " = " + newText.plainText);
			}
		}
		*/
		// Really the rubric literals should not have the colour but should have #correct#, #wrong# and #corrected#
		var substList = [{tag:"[blue]", text:"<font color='#" + _global.ORCHID.CorrectText.rawColor + "'>"}, 
						{tag:"[red]", text:"<font color='#" + _global.ORCHID.YouWereWrongText.rawColor + "'>"}, 
						{tag:"[green]", text:"<font color='#" + _global.ORCHID.YouWereCorrectText.rawColor + "'>"}, 
						{tag:"[/red]", text:"</font>"},
						{tag:"[/green]", text:"</font>"},
						{tag:"[/blue]", text:"</font>"}]
		// v6.42.7 bold text should be size=12
		//newText.plainText = '<font face="Verdana" size="13" color="#' + _global.ORCHID.NeutralText.rawColor +'"><b>' + 
		newText.plainText = '<font face="Verdana" size="12" color="#' + _global.ORCHID.NeutralText.rawColor +'"><b>' + 
						substTags(_global.ORCHID.literalModelObj.getLiteral(useLit, "labels"),substList) +
						'</b></font>';
		// v6.4.2.4 If you know if there is any feedback, you could tell them to click on each field
		if (	(_global.ORCHID.LoadedExercises[0].settings.buttons.feedback || !_global.ORCHID.LoadedExercises[0].settings.marking.delayed)
			&& (!_global.ORCHID.LoadedExercises[0].settings.feedback.scoreBased )
			&& (_global.ORCHID.LoadedExercises[0].feedback.length > 0)) {
			// v6.42.7 bold text should be size=12
			//newText.plainText += '<br><font face="Verdana" size="13" color="#' + _global.ORCHID.NeutralText.rawColor +'"><b>' + 
			newText.plainText += '<br><font face="Verdana" size="12" color="#' + _global.ORCHID.NeutralText.rawColor +'"><b>' + 
							_global.ORCHID.literalModelObj.getLiteral("clickForFeedback", "labels") +
							'</b></font>';		
		}
	}
	newText.style = "headline";
	newText.id = 0;
	titleText.paragraph = new Array(newText);

	//display the title information from the exercise object
	var paneType = "scroll pane";
	var paneName = "Title_SP";
	var substList = new Array();
	//myTrace("rubric=" + titleText.paragraph[0].plainText);
	_global.ORCHID.tlc = {proportion:0, startProportion:0};
	_global.ORCHID.root.objectHolder.putParagraphsOnTheScreen(titleText, paneType, paneName, substList);
}

// Note: originally this function just went through all the fields in the displayed holder
// changing their text and format. BUT each call to setFieldText also does a refresh of the whole
// component, so it is a huge amount of extra work. It will be better to do the text and format changes
// on the html text - either from the model or from the original
// For now I am choosing to call the setFieldText methods of the twfs as this is easiest, but the real
// speed improvement would probably come  from going back to the exercise object and recreating
// the paragraph text just as you did on first coming into the exercise (putting in answers) and not
// using any fields. 
// v6.2 Ahhh, but the fields are used for individual feedback after marking - so we need them.
// And in fact it would be good to recreate them as the sizes and coords are for pre-inserting of answers
// so they can be offset.
// v6.2 the score record is not passed around - not needed here
//markingColouringAndInserting = function(thisScore, mode) {
markingColouringAndInserting = function(mode) {
	//myTrace("colouring mode=" + mode + " so showTicks=" + (mode & _global.ORCHID.marking.showTicks));
	//var startTime = new Date().getTime();
	//myTrace("markingColouring with " + mode + " starts at " + startTime);
	// mode = correct; just colour those ones that you got right
	// mode = wrong; just colour those ones that you got wrong
	// mode = colour; colour everything
	// mode = all; colour and insert everything
	
	var me = _global.ORCHID.LoadedExercises[0].body.text;
	var allGroups = me.group;
	var allFields = me.field;

	// v6.3.5 Countdown has radically different way to show the answers
	//if (_global.ORCHID.LoadedExercises[0].settings.exercise.countDown) {
	if (_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Countdown") {
		// v6.4.2.7 But I don't know that I want to see the answers yet!
		if (mode & _global.ORCHID.marking.showAnswers) {
			var myPane = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP;
			var contentHolder = myPane.getScrollContent(); 
			//myTrace("show the countdown answers");
			var guessed = 0;
			var missedTF = new TextFormat();
			//missedTF.underline = true;
			missedTF.color = _global.ORCHID.CorrectText.color;
			for (var i in contentHolder) {
				//myTrace("look in twf " + contentHolder[i]);
				contentHolder[i].showFullText(missedTF);
			}
			// and that is all you have to do
		}
		return true;
	}
	
	// 2) Show the answers, you really need to show which ones you missed
	//	this might be done by each twf going through the words array and doing a replacement
	//	in a colour/underline of that word if the word not guessed (so you need to mark the words[i].guessed
	//	array when you guess a word)
	
	// *****
	// COLOURING AND INSERTING section
	// *****
	// for each field, show the correct answer and their answer status (if possible)
	// v6.2 Bad programming - for a long paragraph it will do insertField for each field in the TWF
	// which results in great duplication of the TWF formatting code. Instead, you should be just
	// building up the paragraph text and displaying it once. How?
	// What about the same kind of thing that you already do for printing the exercise?
	// createSubstForGapAnswers? But it has to be done selectively as gaps and drop downs
	// don't need (want?) this kind of thing as they are using covers.
	// As a temp solution you could put a tlc wrapper round this for loop so that you cannot
	// crash Flash even in the worst case.
	
	// ******
	// Change the tlc settings
	// ******
	_global.ORCHID.tlc = {timeLimit:1000, maxLoop:allFields.length, i:0, 
					proportion:100, startProportion:0,
					callback:markingColouringAndInsertingCallBack};
	var tlc = _global.ORCHID.tlc;
	tlc.controller = _global.ORCHID.root.tlcController;

	// ******
	// this is the data that is the core of the loop, change per use
	// ******
	tlc.mode = mode;
	
	// define the resumeLoop method
	tlc.resumeLoop = function (firstTime) {
		var me = _global.ORCHID.LoadedExercises[0].body.text;
		var allGroups = me.group;
		var allFields = me.field;
		
		//v6.4.2.4 Need to get dimensions of tick and cross so they can be positioned correctly
		// This will set it directly to the outside corner of the cover. If you want to merge a particular
		// tick or cross into the answer a bit, set the x and y at design time to -ve in buttons within the tick mc.
		// v6.4.2.7 moved to fieldReactions.setTicking
		//var tickWidth = _global.ORCHID.root.buttonsHolder.ExerciseScreen.tickHolder._width;
		//var tickHeight = _global.ORCHID.root.buttonsHolder.ExerciseScreen.tickHolder._height;
		//var crossWidth = _global.ORCHID.root.buttonsHolder.ExerciseScreen.crossHolder._width;
		//var crossHeight = _global.ORCHID.root.buttonsHolder.ExerciseScreen.crossHolder._height;
		
		var startTime = getTimer();
		var i = this.i;
		var max = this.maxLoop;
		var timeLimit = this.timeLimit;
		while (getTimer()-startTime <= timeLimit && i<max && !firstTime) {
			// ******
			// this is stuff in a loop that you want to do
			// ******
			//trace("loop for fields=" + i + " value=" + allFields[i].answer[0].value);
			var thisGroupID = allFields[i].group;
			var thisGroup = allGroups[lookupArrayItem(allGroups, thisGroupID, "id")]; //??
			//trace("colouring field " + allFields[i].id + " in group " + thisGroupID);
			if (allFields[i].type == "i:target") {
				// v6.4.2.4 For later reuse if not a target
				var answerIdx = 0;
				//myTrace("for this group, your final answer was " + allFields[i].attempt.finalAnswer);
				// if they selected this answer as their final attempt...
				// v6.3.4 Move attempt from group to field
				//if (allFields[i].answer[0].value == thisGroup.attempt.finalAnswer) {
				if (allFields[i].answer[answerIdx].value == allFields[i].attempt.finalAnswer) {
					//myTrace("you DID select target " + i);
					// ...and it is wrong, format with YouWereWrongText
					if (allFields[i].answer[answerIdx].correct == "false") {
						//myTrace("but you were wrong");
						// v6.2 For EGU - try [also?] adding in a cross behind wrong answers
						// but I don't know much about the field cover at this point do I?
						// v6.4.2.7 You might hide crosses and just have ticks
						//if (this.mode & _global.ORCHID.marking.showTicks) {
						if (	(this.mode & _global.ORCHID.marking.showTicks) &&
							!(this.mode & _global.ORCHID.marking.hideCrosses)) {
							// v6.4.2.7 Can you extract ticking to a function to make it easier to call?
							//var offsetX=crossWidth; var oneLine=true;
							//setTicking(allFields[i], "Cross", offsetX, oneLine)
							//myTrace("add a cross");
							setTicking(allFields[i], "Cross")
							//var contentHolder = getRegion(allFields[i]).getScrollContent();
							//var thisParaBox = contentHolder["ExerciseBox" + allFields[i].paraNum];
							//var markProps = {stretch:false, align:"right", offsetX:20, oneLine:true};
							//myTrace("try to add a cross to this fieldCover " + thisParaBox + " with stretch=" + markProps.stretch);						
							//thisParaBox.setFieldBackground(allFields[i].id, "Cross", markProps);
						}
						if (this.mode & _global.ORCHID.marking.showWrong) {
							// v6.3 Proof reading exercises should use different colours - except
							// that there is no such thing as targets in a proof reading that you are not
							// supposed to get. Mind you, perhaps there should be?! Keep the flexibility here.
							// v6.3 Proof reading exercises should use different colours
							// v6.3.3 change mode to settings
							//if (_global.ORCHID.LoadedExercises[0].mode. & _global.ORCHID.exMode.ProofReading) {
							if (_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading) {
								//myTrace("correctly found a target in proof-reading mode");
								changeFieldAppearance(allFields[i], _global.ORCHID.PRYouWereWrongText);
							} else {
								changeFieldAppearance(allFields[i], _global.ORCHID.YouWereWrongText);
							}
						}
					// ...and it is right, show YouWereCorrectText
					} else if (allFields[i].answer[answerIdx].correct == "true") {
						//myTrace("and you were right");
						// v6.2 For EGU - try [also?] adding in a tick behind wrong answers
						// but I don't know much about the field cover at this point do I?
						// v6.3.4 With multiPart questions, you should only tick the option if everything
						// is right otherwise it will be most confusing. This means checking the group stuff.
						// You don't need to worry with cross
						if (this.mode & _global.ORCHID.marking.showTicks) {
							if (_global.ORCHID.LoadedExercises[0].settings.exercise.multiPart) {
								if (thisGroup.score >= thisGroup.maxScore) {
									var showTick = true;
								} else {
									var showTick = false;
									//myTrace("no tick for correct option as whole question wrong");
								}
							} else {
								var showTick = true;
							}
							if (showTick) {
								//var offsetX=tickWidth; var oneLine=true;
								//setTicking(allFields[i], "Tick", offsetX, oneLine)
								//myTrace("add a tick");
								setTicking(allFields[i], "Tick")
								//var contentHolder = getRegion(allFields[i]).getScrollContent();
								//var thisParaBox = contentHolder["ExerciseBox" + allFields[i].paraNum];
								//var thisOffset = tickWidth;
								//myTrace("729:tick, offsetX=" + thisOffset); // This one used for targets you correctly hit
								//var markProps = {stretch:false, align:"right", offsetX:thisOffset, oneLine:true};
								//myTrace("try to add a tick to this fieldCover " + thisParaBox + " with stretch=" + markProps.stretch);						
								//thisParaBox.setFieldBackground(allFields[i].id, "Tick", markProps);
							}
						}
						if (this.mode & _global.ORCHID.marking.showCorrect) {
							// v6.3 Proof reading exercises should use different colours
							// v6.3.3 change mode to settings
							//if (_global.ORCHID.LoadedExercises[0].mode. & _global.ORCHID.exMode.ProofReading) {
							if (_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading) {
								//myTrace("correctly found a target in proof-reading mode");
								changeFieldAppearance(allFields[i], _global.ORCHID.PRYouWereCorrectText);
							} else {
								changeFieldAppearance(allFields[i], _global.ORCHID.YouWereCorrectText);
							}
						}
						// in this case, we want to record that any popup should NOT be changed
						// for this group as A correct answer was the last thing selected.
						// v6.3 Based on the 'overwrite answers' exmode setting, you MIGHT want to 
						// overwrite the alternative correct answer with the default one
						// v6.3.4 For multipart questions, the pop-up needs to hold all correct answers
						if (this.mode & _global.ORCHID.marking.showAnswers) {
							if (_global.ORCHID.LoadedExercises[0].settings.exercise.multiPart) {
								//myTrace("add " + i + " to useFields");
								thisGroup.popup.useFields.push(i);
							} else {
								myTrace("for field " + i + " set to dontOverwrite");
								thisGroup.popup.useField = i;
								thisGroup.popup.dontOverwrite = true;
							}
						}
					} // neutral fields don't get any reaction
				// if they didn't select this answer...
				} else {
					//myTrace("you did NOT select target " + i);
					// ...and it was correct, show CorrectText
					if (allFields[i].answer[answerIdx].correct == "true") {
						//myTrace("and you should have");
						// v6.2 If this group has a pop-up, then use the pop-up to hold the correct
						// answer and just leave this group item untouched
						if (thisGroup.popup.fieldID == undefined) {
							//trace("need to change format of correct option, just use popup for group " + thisGroup.id);
							if (this.mode & _global.ORCHID.marking.showSkipped) {
								// v6.3 Proof reading exercises should use different colours
								// v6.3.3 change mode to settings
								//if (_global.ORCHID.LoadedExercises[0].mode. & _global.ORCHID.exMode.ProofReading) {
								if (_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading) {
									//myTrace("missed a 'correct' target in proof-reading mode");
									changeFieldAppearance(allFields[i], _global.ORCHID.PRCorrectText);
								} else {
									changeFieldAppearance(allFields[i], _global.ORCHID.CorrectText);
								}
							}
						}
						// unless another field has set the popup correctly, use this field to show the correct answer
						if (this.mode & _global.ORCHID.marking.showAnswers) {
							if (_global.ORCHID.LoadedExercises[0].settings.exercise.multiPart) {
								//myTrace("add " + i + " to useFields");
								thisGroup.popup.useFields.push(i);
							} else {
								if (!thisGroup.popup.dontOverwrite) {
									thisGroup.popup.useField = i;
								}
							}
						}
					// v6.2 - they correctly skipped a red-herring so set the format of the red-herring
					// field so that it doesn't appear to be correct
					// v6.4.2.4 But surely it being a red-herring doesn't imply that it is wrong? If you were asked to find the present-perfect,
					// examples of past-simple would not be wrong. If correctly avoided they should just be left alone. 
					// I can't think of any example where you would want to higlight a red-herring that had been avoided.
					// So I am going to skip this section completely now.
					} else {
						/*
						// v6.2 regular mc have some fields that are incorrect and not to be chosen
						// but this doesn't make them red-herrings, this is only for single field groups
						//myTrace("and you were right")
						if (thisGroup.singleField) {
							if (this.mode & _global.ORCHID.marking.showTicks) {
								var contentHolder = getRegion(allFields[i]).getScrollContent();
								var thisParaBox = contentHolder["ExerciseBox" + allFields[i].paraNum];
								var markProps = {stretch:false, align:"right", offsetX:20, oneLine:true};
								//myTrace("try to add a tick to this fieldCover " + thisParaBox + " with stretch=" + markProps.stretch);						
								thisParaBox.setFieldBackground(allFields[i].id, "Tick", markProps);
							}
							if (this.mode & _global.ORCHID.marking.showCorrect) {
								//myTrace("avoided correctly " + allFields[i].answer[0].value);
								// v6.3.4 in a proof-reading/gapfill, avoiding red-herrings is better than
								// avoiding them in EGU like target spotting. So here you get a mark
								// and you should show it as correct
								if (_global.ORCHID.LoadedExercises[0].settings.exercise.correctMistakes) {
									changeFieldAppearance(allFields[i], _global.ORCHID.YouWereCorrectText);
								} else {
									changeFieldAppearance(allFields[i], _global.ORCHID.YouAvoidedCorrectly);
								}
							}
							// v6.2 which means that you don't want to see fb for it.
							//trace("suppressing fb for field " + i + " in group " + allFields[i].group);
							// v6.3.4 Again, proofReading/gapfills are treated differently
							if (this.mode & _global.ORCHID.exercise.correctMistakes) {
							} else {
								thisGroup.suppressFb = true;
							}
						}
						*/
					}
				}
				// v6.4.2.4 I am not saving the correct answer for ones that I get right. But with after marking
				// single question feedback, I need it.
				if (allFields[i].answer[answerIdx].correct == "true") {
					thisGroup.correctAnswer = allFields[i].answer[answerIdx].value;
				}
			// for fields where you cannot do this (gap, drop, list)
			} else if (allFields[i].type == "i:gap" || allFields[i].type == "i:drop" || allFields[i].type == "i:dropdown"
										|| allFields[i].type == "i:dropInsert"
										//|| allFields[i].type == "i:presetGap"
										|| allFields[i].type == "i:targetGap") {

				// v6.3.4 targetGaps and dropInsert might not have the correct answer as 0 (or 1)
				// v6.4.3 But in fact you will have changed targetGaps that you click on into regular gaps - so need to check them as well
				//if (allFields[i].type == "i:targetGap" || allFields[i].type == "i:presetGap" || allFields[i].type == "i:dropInsert") {
				//if (allFields[i].type == "i:targetGap" || allFields[i].type == "i:dropInsert") {
				if (allFields[i].type == "i:gap" || allFields[i].type == "i:targetGap" || allFields[i].type == "i:dropInsert") {
					var j=0;
					while (allFields[i].answer[j].correct == "false" &&
							j< allFields[i].answer.length) {
						j++;
					}
					var answerIdx = j;
				} else {
					var answerIdx = 0;
				}
				// Note: this is supposed to be based on MODE as you might want to overwrite all answers
				// v6.3.5 In which case, simply overwrite the answers and set all colours to neutral
				// it doesn't depend on whether you were right or wrong. If you were VERY clever you 
				// would still be able to work out which were right and wrong, or something like that
				// but it would probably be better to spend the time on some grouping thing which
				// wil remove the need for this setting altogether.
				// v6.4.2.4 But I do really need this now for Sweet Biscuits. I know that this answer is right or wrong
				// so all I have to do is find out where it is going to be displayed. 
				// v6.4.2.4 Recognise the flaw that you are matching against all questions in the exercise. So if you have two answers
				// that are the same for completely different questions, you are going to be in a mess.
				// v6.4.2.7 I am now in a mess for SSS! Reading, Hannahs' reasons for reading has the same answer correct for many questions.
				// I am avoiding this by not making it overwrite, but this is temporary.
				// Try this. There are two types of reasons for overwriteAnswers. 
				// Case one is where several different questions have the same
				// alt answer, but you want to show the originals after marking. See SSS-Reading-Hannah's reasons for reading
				// Case two is where you have a group of questions and you don't care which order they write the answers.
				// See Road to IELTS-Leisure and Entertainment-Listening 2.
				// In the first case, we want to tick the question that they got right.
				// In the second case, we want to move the tick to wherever the answer they typed is actually displayed.
				// I think the key is that you move the tick if the set of all answers for two questions is identical. It is still not perfect
				// (for which we need a group ID), but should cover most cases.
				if (_global.ORCHID.LoadedExercises[0].settings.marking.overwriteAnswers) {
					//myTrace("marking.overwriteAnswers");
					// This code puts a correct answer into this gap based on order. But the answer that I typed here - was that right?
					if (thisGroup.score === null || thisGroup.score == 0 || thisGroup.score === undefined) { 
						// no - so no ticks to show, so ignore
						//myTrace(i + ":got this one wrong with " + allFields[i].attempt.finalAnswer);
					} else {
						// v6.4.2.7 So this is correct. But do we need to worry about moving the tick to another location?
						// First, if this is the default answer for this question, then no.
						// But to complicate things even more, after marking but before seeTheAnswers, you should tick everything that is right
						// no need to move things around.
						if (	answerMatch(allFields[i].answer[0].value, allFields[i].attempt.finalAnswer) || 
							!(this.mode & _global.ORCHID.marking.showAnswers)) {
							//myTrace("got it right, no moving of answers");
							if (this.mode & _global.ORCHID.marking.showTicks) {
								setTicking(allFields[i], "Tick")
							}
						} else {
							myTrace("got it right, move the tick?");
							// yes - but as it will probably move, we need to move the tick with it
							var foundThisTick = false;
							for (var idx in allFields) {
								// v6.4.2.7 You have already checked the default answer, so don't try to match against yourself
								if (idx == i) continue;
								// v6.4.2.4 But you might have typed an alt correct answer, so try to match against the specially marked default answers
								// for each question.
								// Do this by avoiding any alt answer that is marked noOverwrite='true'. 
								// This means that you only have to edit exercise questions  which are multiPart with overwriting. Huh?
								// v6.4.2.7 I think the overwrite can be phased out, it is not used in SSS. Only in Road to IELTS
								// At this point you know you have a correct answer that needs to be moved. You are running with overwriteAnswers
								// so only the default answers need be checked as they are the ones that will display on screen. If you got an alt
								// answer right it will not be shown anyway so can't be ticked.
								//for (var altIdx in allFields[idx].answer) {
								altIdx=0;	
									if (allFields[idx].answer[altIdx].correct == "true" && (altIdx==0 || allFields[idx].answer[altIdx].noOverwrite != "true")) {
										//myTrace("check on " + altIdx + ":" + allFields[idx].answer[altIdx].value + " your answer=" + allFields[i].attempt.finalAnswer); 
										//if (answerMatch(allFields[idx].answer[answerIdx].value, allFields[i].attempt.finalAnswer)) {
										if (answerMatch(allFields[idx].answer[altIdx].value, allFields[i].attempt.finalAnswer)) {
											// v6.4.2.7 So, as per above diatribe, we will only tick this IF all the answers match this field and the one we answered
											if (allAnswersMatch(allFields[i].answer, allFields[idx].answer)) {
												//myTrace("all answers matched, so move tick to field " + idx);
												// This is right for ticks since they don't clash with 'corrected' ones, but to do the colouring 
												// I would need a loop at the end of the colouringAndInserting loop to set the colours
												// just for the fields that you got correct.
												// showTickOnField(allFields[idx]); - make this the function to save duplication of below
												if (this.mode & _global.ORCHID.marking.showTicks) {
													// v6.4.2.7 Can you extract ticking to a function to make it easier to call?
													//var offsetX=tickWidth; var oneLine=true;
													//setTicking(allFields[idx], "Tick", offsetX, oneLine)
													setTicking(allFields[idx], "Tick")
													//var contentHolder = getRegion(allFields[idx]).getScrollContent();
													//var thisParaBox = contentHolder["ExerciseBox" + allFields[idx].paraNum];
													//trace("try to add a cross to this fieldCover " + thisParaBox);
													//if (allFields[i].type == "i:gap" || allFields[i].type == "i:targetGap" || allFields[i].type == "i:presetGap") {
													// v6.4.2.4 Why do drops have tick on the left? Use a common setting
													//var thisOffset = tickWidth;
													//myTrace("879:tick, offsetX=" + thisOffset);
													//var markProps = {stretch:false, align:"right", offsetX:thisOffset, oneLine:true};
													/*
													if (allFields[idx].type == "i:gap" || allFields[i].type == "i:targetGap") {
														myTrace("tick, offsetX=-4");
														var markProps = {stretch:false, align:"right", offsetX:-4, oneLine:true};
													} else if (allFields[idx].type == "i:drop" || allFields[i].type == "i:dropInsert") {
														//var markProps = {stretch:false, align:"left", offsetX:-4, oneLine:true};
														myTrace("tick, offsetX=4");
														var markProps = {stretch:false, align:"right", offsetX:4, oneLine:true};
													} else {
														myTrace("tick, offsetX=4");
														var markProps = {stretch:false, align:"right", offsetX:4, oneLine:true};
													}
													*/
													//thisParaBox.setFieldBackground(allFields[idx].id, "Tick", markProps);
												}
												//changeFieldAppearance(allFields[idx], _global.ORCHID.YouWereCorrectText);
												//listOfCorrectFields.push(idx);
												foundThisTick = true;
											} else {
												//myTrace("found a matching answer, but from a different group");
											}
											break;
										} else {
											//myTrace("answerMatch failed");
										}
									}
								//}
								// jump out if you have found the place to tick already
								if (foundThisTick) break;
							}
						}
					}
					//myTrace("force overwriting of correct answers");
					// v6.4.2.7 You were doing this too early - before see the answers. So add the condition.
					if (this.mode & _global.ORCHID.marking.showAnswers) {
						// v6.4.3 If this is errorCorrection and this field is still a target it means it was not found, so we need
						// to replace the incorrect target with the correct answer (maybe longer or shorter)
						//if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown" || allFields[i].type == "i:targetGap"){
						if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown"){
							//myTrace("overwriteAnswers.insert answer for gap");
							insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, true);
						} else if (allFields[i].type == "i:targetGap") {
							//myTrace("overwriteAnswers.insert answer for targetGap");
							insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, false);
						} else if (allFields[i].type == "i:dropInsert") {
							insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, false);
						} else { 
							insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, false);
						}
						changeFieldAppearance(allFields[i], _global.ORCHID.CorrectText);
					}
				// v6.4.3 Add grouping exercise. We will leave answers that are correct where they are and fill in the 
				// others based on the grouping.
				// v6.5.5.1 We need to worry about the feedback as we are displaying correct answers in 'unexpected' places
				// and the feedback doesn't match up at the moment
				} else if (_global.ORCHID.LoadedExercises[0].settings.exercise.grouping) {
					//myTrace("grouping type answer display");
					// Start by ticking the ones you got right, as above, but no need to worry about moving ticks around
					if (thisGroup.score === null || thisGroup.score == 0 || thisGroup.score === undefined) { 
						// not right - so no ticks to show, so ignore
						//myTrace(i + ":got this one wrong with " + allFields[i].attempt.finalAnswer);
					} else {
						//if (	answerMatch(allFields[i].answer[0].value, allFields[i].attempt.finalAnswer) || 
						//	!(this.mode & _global.ORCHID.marking.showAnswers)) {
							myTrace(i+":got it right, no moving of answer " + allFields[i].attempt.finalAnswer);
							if (this.mode & _global.ORCHID.marking.showTicks) {
								setTicking(allFields[i], "Tick")
							}
						//}
					}
					// Then add the correct answers to ones that you didn't get right (or are skipped)
					if (this.mode & _global.ORCHID.marking.showAnswers) {
						if (thisGroup.score === null || thisGroup.score == 0 || thisGroup.score === undefined) { 
							// It was wrong, so which answer are we going to put in here?
							// First find which section this field is in
							var sections = me.section;
							var useThisField = i; // set as a default
							for (var s in sections) {
								if (sections[s].ID == allFields[i].section) {
									//myTrace("found matching section " + allFields[i].section);
									for (var f in sections[s].fieldsInSection) {
										// So, which answers in this section have not been marked correct or used for other inserting?
										var myFieldInSection = sections[s].fieldsInSection[f];
										if (myFieldInSection.usedInMarking || myFieldInSection.usedInInserting) {
										} else {
											useThisField = myFieldInSection.idx;
											myFieldInSection.usedInInserting = true;
											break;
										}
									}
									break; // can only match one section
								}
							}								
							var answerIdx=0;
							var thisAnswer = allFields[useThisField].answer[answerIdx].value;
							if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown"){
								insertAnswerIntoField(allFields[i], thisAnswer, true);
							} else if (allFields[i].type == "i:targetGap") {
								//myTrace("insert answer for targetGap");
								insertAnswerIntoField(allFields[i], thisAnswer, false);
							} else if (allFields[i].type == "i:dropInsert") {
								insertAnswerIntoField(allFields[i], thisAnswer, false);
							} else { 
								insertAnswerIntoField(allFields[i], thisAnswer, false);
							}
						}
						changeFieldAppearance(allFields[i], _global.ORCHID.CorrectText);
					}
					
				} else {
					//myTrace("standard answer display");
					// if the field was neutral, insert the default answer but don't change colouring
					//trace("checking score for field " + allFields[i].id + " type=" + allFields[i].type);
					// you must use === as null and undefined are sometimes the same
					//myTrace("final answer=" + thisGroup.finalAnswer + " score=" + thisGroup.score);
					// v6.3.4 Group score has been calculated at the start of main marking
					//if (thisGroup.attempt.score === null) {
					if (thisGroup.score === null) {
						//trace("which is neutral, as it has a null score");
						if (this.mode & _global.ORCHID.marking.showAnswers) {
							// v6.2 change for cover based gaps
							//myTrace("missed, so insert " + allFields[i].answer[answerIdx].value);
							//if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown" || allFields[i].type == "i:presetGap"){
							if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown" || allFields[i].type == "i:targetGap"){
								insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, true);
							//} else if (allFields[i].type == "i:targetGap" || allFields[i].type == "i:dropInsert") {
							} else if (allFields[i].type == "i:dropInsert") {
								insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, false);
							} else { 
								insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, false);
							}
						}
					// if the field was skipped or wrong, insert the default answer and set colouring
					//} else if (thisGroup.attempt.score == 0 || thisGroup.attempt.score === undefined) { 
					} else if (thisGroup.score == 0 || thisGroup.score === undefined) { 
						//myTrace("which you did NOT get right");
						// v6.4.2.4 Adding the cross (as they got this wrong) is independent of showing the answer
						// so move this block of code here, rather than in the conditional
						// v6.2 For EGU - try [also?] adding in a cross behind wrong answers
						// Only do it if they actually got it wrong rather than just skipping it??
						//if (thisGroup.attempt.score != undefined) {
						if (thisGroup.score != undefined) {
							// v6.4.2.7 You might hide crosses and just have ticks
							//if (this.mode & _global.ORCHID.marking.showTicks) {
							if (	(this.mode & _global.ORCHID.marking.showTicks) &&
								!(this.mode & _global.ORCHID.marking.hideCrosses)) {
								// v6.4.2.7 Can you extract ticking to a function to make it easier to call?
								//var offsetX=crossWidth; var oneLine=true;
								//setTicking(allFields[i], "Cross", offsetX, oneLine)
								//myTrace("1068.adding a cross");
								setTicking(allFields[i], "Cross")
								//var contentHolder = getRegion(allFields[i]).getScrollContent();
								//var thisParaBox = contentHolder["ExerciseBox" + allFields[i].paraNum];
								//trace("try to add a cross to this fieldCover " + thisParaBox);
								//if (allFields[i].type == "i:gap" || allFields[i].type == "i:targetGap" || allFields[i].type == "i:presetGap") {
								// v6.4.2.4 Why do drops have cross on the left? Use a common setting
								//var thisOffset = crossWidth;
								//myTrace("953:cross, offsetX=" + thisOffset); // used for gapfill
								//var markProps = {stretch:false, align:"right", offsetX:thisOffset, oneLine:true};
								/*
								if (allFields[i].type == "i:gap" || allFields[i].type == "i:targetGap") {
										myTrace("cross, offsetX=-4");
									var markProps = {stretch:false, align:"right", offsetX:-4, oneLine:true};
								} else if (allFields[i].type == "i:drop" || allFields[i].type == "i:dropInsert") {
									// v6.4.2.4 Why do drops have tick on the left?
									//var markProps = {stretch:false, align:"left", offsetX:-4, oneLine:true};
										myTrace("cross, offsetX=4");
									var markProps = {stretch:false, align:"right", offsetX:+4, oneLine:true};
								} else {
										myTrace("cross, offsetX=4");
									var markProps = {stretch:false, align:"right", offsetX:+4, oneLine:true};
								}
								*/
								//thisParaBox.setFieldBackground(allFields[i].id, "Cross", markProps);
							}
						}
						
						// if you are inserting the correct answer, then the colouring should go to correct
						if (this.mode & _global.ORCHID.marking.showAnswers) {
							//myTrace("correct answer for field " + i + " is " + allFields[i].answer[answerIdx].value);
							// v6.2 change for cover based gaps
							//myTrace("wrong, so insert " + allFields[i].answer[answerIdx].value);
							//if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown" || allFields[i].type == "i:presetGap") {
							//myTrace("insertAnswer");
							// v6.4.3 If this is errorCorrection and this field is still a target it means it was not found, so we need
							// to replace the incorrect target with the correct answer (maybe longer or shorter)
							//if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown" || allFields[i].type == "i:targetGap") {
							//myTrace("wrong " + allFields[i].type + ": insert correct answer=" + allFields[i].answer[answerIdx].value);
							
							// v6.5.4.2 Yiu, fixing 1210, just leave your answer in the field if your final attempt was a correct one
							if(!checkIfTheAnswerIsCorrect(allFields[i].attempt.finalAnswer, allFields[i])){
								if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown") {
								//if (allFields[i].type == "i:dropdown") {
									insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, true);
								//} else if (allFields[i].type == "i:targetGap") {
									// before you can insert the answer to a target they missed, you must lengthen
									// it into the appropriate gap (why??)
									//myTrace("insert correct answer=" + allFields[i].answer[1].value);
								//	insertAnswerIntoField(allFields[i], makeString(" ", allFields[i].info.gapChars+1));
								//	changeFieldAppearance(allFields[i], _global.ORCHID.UnderlineText);
								//	insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value);
								} else { // || allFields[i].type == "i:dropInsert"
									//myTrace("so non-gap insert correct answer=" + allFields[i].answer[answerIdx].value);
									insertAnswerIntoField(allFields[i], allfields[i].answer[answeridx].value, false);
								}

							}
							//myTrace("insertedAnswer");
							//myTrace("change to correct colour targetGap " + i);
							changeFieldAppearance(allFields[i], _global.ORCHID.CorrectText);
							//myTrace("changedFieldAppearance");
						// but if you are leaving it alone, then the colouring should go to wrong
						} else {
							//trace("change wrong answer colour");
							/* see above to where this block is moved
							// v6.2 For EGU - try [also?] adding in a cross behind wrong answers
							// but I don't know much about the field cover at this point do I?
							// Only do it if they actually got it wrong rather than just skipping it??
							//if (thisGroup.attempt.score != undefined) {
							if (thisGroup.score != undefined) {
								if (this.mode & _global.ORCHID.marking.showTicks) {
									var contentHolder = getRegion(allFields[i]).getScrollContent();
									var thisParaBox = contentHolder["ExerciseBox" + allFields[i].paraNum];
									//trace("try to add a cross to this fieldCover " + thisParaBox);
									//if (allFields[i].type == "i:gap" || allFields[i].type == "i:targetGap" || allFields[i].type == "i:presetGap") {
									if (allFields[i].type == "i:gap" || allFields[i].type == "i:targetGap") {
										var markProps = {stretch:false, align:"right", offsetX:-4, oneLine:true};
									} else if (allFields[i].type == "i:drop" || allFields[i].type == "i:dropInsert") {
										var markProps = {stretch:false, align:"left", offsetX:-4, oneLine:true};
									} else {
										var markProps = {stretch:false, align:"right", offsetX:+4, oneLine:true};
									}
									thisParaBox.setFieldBackground(allFields[i].id, "Cross", markProps);
								}
							}
							*/
							if (this.mode & _global.ORCHID.marking.showWrong) {
								//myTrace("change to wrong colour targetGap " + i);
								changeFieldAppearance(allFields[i], _global.ORCHID.YouWereWrongText);
							}
						}
					// if the field was correct, set the colouring
					} else {
						//myTrace("which you did get right");
						// v6.2 There is the possibility with instant marking of getting it right first time
						// and then changing it to wrong. I don't really how to detect this - so for now
						// just ALWAYS overwrite with the default correct answer.
						// v6.3.4 Not good behaviour. Better to NOT overwrite and risk leaving a wrong
						// answer there. But it would be good to find a way to know that although the score
						// is correct the current answer isn't.
						/*
						if (_global.ORCHID.LoadedExercises[0].settings.marking.overwriteAnswers) {
							myTrace("force overwriting of correct answers");
							// v6.2 change for cover based gaps
							if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown") {
								insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, true);
							} else { 
								insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, false);
							}
						}
						*/
						
						if (this.mode & _global.ORCHID.marking.showTicks) {
							// v6.4.2.7 Can you extract ticking to a function to make it easier to call?
							//var offsetX=crossWidth; var oneLine=true;
							//myTrace("1173.adding a tick");
							setTicking(allFields[i], "Tick")
							//var contentHolder = getRegion(allFields[i]).getScrollContent();
							//var thisParaBox = contentHolder["ExerciseBox" + allFields[i].paraNum];
							//trace("try to add a cross to this fieldCover " + thisParaBox);
							//if (allFields[i].type == "i:gap" || allFields[i].type == "i:targetGap" || allFields[i].type == "i:presetGap") {
							// v6.4.2.4 Why do drops have tick on the left? Use a common setting
							//var thisOffset = tickWidth;
							//myTrace("1054:tick, offsetX=" + thisOffset); // used for gapfill
							//var markProps = {stretch:false, align:"right", offsetX:thisOffset, oneLine:true};
							/*
							if (allFields[i].type == "i:gap" || allFields[i].type == "i:targetGap") {
										myTrace("tick, offsetX=-4");
								var markProps = {stretch:false, align:"right", offsetX:-4, oneLine:true};
							} else if (allFields[i].type == "i:drop" || allFields[i].type == "i:dropInsert") {
								// v6.4.2.4 Why do drops have tick on the left?
								//var markProps = {stretch:false, align:"left", offsetX:-4, oneLine:true};
										myTrace("tick, offsetX=4");
								var markProps = {stretch:false, align:"right", offsetX:+4, oneLine:true};
							} else {
										myTrace("tick, offsetX=4");
								var markProps = {stretch:false, align:"right", offsetX:+4, oneLine:true};
							}
							*/
							//thisParaBox.setFieldBackground(allFields[i].id, "Tick", markProps);
						}

						// 6.5.4.2 Yiu, just to make sure it show the right answer after the user pressed "show answers", BUg ID 1227
						// check if the finally answer is correct
						if(!checkIfTheAnswerIsCorrect(allFields[i].attempt.finalAnswer, allFields[i])){
							myTrace("final answer was not correct");
							// then check if the first answer was correct
 							if(!checkIfTheAnswerIsCorrect(allFields[i].attempt.firstAnswer, allFields[i])){
								myTrace("first answer was not correct");
								// not, so put the default answer into the field
								if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown") {
									insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, true);
								} else {
									insertAnswerIntoField(allFields[i], allFields[i].answer[answerIdx].value, false);
								}
							} else {
								myTrace("first answer was correct");
								// put the first answer into the field
								if (allFields[i].type == "i:gap" || allFields[i].type == "i:dropdown") {
									insertAnswerIntoField(allFields[i], allFields[i].attempt.firstAnswer, true);
								} else {
									insertAnswerIntoField(allFields[i], allFields[i].attempt.firstAnswer, false);
								}
							}
						}

						// End 6.5.4.2 Yiu, just to make sure it show the right answer after the user pressed "show answers", BUg ID 1227
						if (this.mode & _global.ORCHID.marking.showCorrect) {
							//myTrace("change to correct colour targetGap " + i);
							changeFieldAppearance(allFields[i], _global.ORCHID.YouWereCorrectText);
						}
					}
				}
				// v6.3.5 In order to make let you pass the correct answer to fb, save it in the 
				// group. This is not set for targets as that must be done in the pop-up bit.
				//myTrace("save correct answer=" + allFields[i].answer[answerIdx].value);
				thisGroup.correctAnswer = allFields[i].answer[answerIdx].value;
			}
			i++;
		}
		if (i < max) {
			this.controller.incPercentage((i/max) * this.proportion); 
			this.i = i;
		} else if (i >= max || max == undefined) {
			this.i = max; // just in case this is run beyond the limit
			//myTrace("marking: progress bar % to " + Number(this.startProportion + this.proportion));
			this.controller.setPercentage(this.proportion + this.startProportion); 
			// get rid of the resumeLoop as you have finished it
			//var stopTime = new Date().getTime();
			delete this.resumeLoop;
			this.controller.stopEnterFrame();
			this.callBack(this.mode);
			// if this is now at 100%, hide it
			if (this.controller.getPercentage() >= 100) {
				this.controller.setEnabled(false);
			}
		}
		
	}
	//tlc.controller.setLabel("marking");
	tlc.controller.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadMarking", "labels"));
	tlc.controller.setEnabled("true");
	tlc.controller.startEnterFrame();
	tlc.resumeLoop(true);
}
markingColouringAndInsertingCallBack = function(mode) {
	// get rid of the progress bar (it should do this itself)
	//_global.ORCHID.tlc.controller._visible = false;
	//myTrace("in pop up bit with mode=" + mode);
	
	var me = _global.ORCHID.LoadedExercises[0].body.text;
	var allGroups = me.group;
	var allFields = me.field;
	// Finally, go through each group again making sure the popups are fine (if you are showing the answers)
	if (mode & _global.ORCHID.marking.showAnswers) {
		for (var i in allGroups) {
			//myTrace("for group " + i + " useFieldForPopup=" + allGroups[i].popup.useField + " dontOverwritePopup=" +allGroups[i].popup.dontOverwrite);
			// v6.3.4 multiPart questions pop-up all correct answers
			var popupFieldID = lookupArrayItem(allFields, allGroups[i].popup.fieldID, "id"); //??
			if (_global.ORCHID.LoadedExercises[0].settings.exercise.multiPart) {
				//myTrace("multiPart popup construction for " + allGroups[i].popup.useFields.toString());
				//var popupFieldID = lookupArrayItem(allFields, allGroups[i].attempt.useFieldForPopup, "id"); //??
				var makePopupAnswer = new Array();
				for (var j in allGroups[i].popup.useFields) {
					// only pop up correct answers from this group
					if (allFields[allGroups[i].popup.useFields[j]].answer[0].correct=="true") {
						//myTrace("field=" + allGroups[i].popup.useFields[j] + "; answer=" + allFields[allGroups[i].popup.useFields[j]].answer[0].value + "; " + allFields[allGroups[i].popup.useFields[j]].answer[0].correct);
						makePopupAnswer.push(allFields[allGroups[i].popup.useFields[j]].answer[0].value);
					}
				}
				//myTrace("makes popup=" + makePopupAnswer.join("/"));
				//myTrace("add this to the popup["+allGroups[i].popupFieldID+"]: " + allFields[allGroups[i].attempt.useFieldForPopup].answer[0].value);
				var thisPopUpAnswer = makePopupAnswer.join("/");
				insertAnswerIntoField(allFields[popupFieldID], thisPopUpAnswer, false);
			} else {
				if (!allGroups[i].popup.dontOverwrite && allGroups[i].popup.useField != undefined) {
					//myTrace("so add a field to the popup");
					//var popupFieldID = lookupArrayItem(allFields, allGroups[i].attempt.useFieldForPopup, "id"); //??
					var popupFieldID = lookupArrayItem(allFields, allGroups[i].popup.fieldID, "id"); //??
					var thisPopUpAnswer = allFields[allGroups[i].popup.useField].answer[0].value;
					//myTrace("add this to the popup["+popupFieldID+"]: " + thisPopUpAnswer);
					insertAnswerIntoField(allFields[popupFieldID], thisPopUpAnswer, false);
				} else {
					// v6.5.1 At this point, I don't want to change the screen popup because it is already correct, but I do
					// need to update the field otherwise printing just shows the previous field's popup.
					//myTrace("reference this to the popup["+popupFieldID+"]: " + thisPopUpAnswer);
					var popupFieldID = lookupArrayItem(allFields, allGroups[i].popup.fieldID, "id"); //??
					var thisPopUpAnswer = allFields[allGroups[i].popup.useField].answer[0].value;
				}
			}
			// v6.3.5 Save the text of the pop-up to help with printing
			//myTrace("pop-up had answer[0].value=" + allFields[popupFieldID].answer[0].value);
			allFields[popupFieldID].answer[0].value = thisPopUpAnswer;
			//myTrace("but overwrote=" + allFields[popupFieldID].answer[0].value)
			// v6.3.5 In order to make let you pass the correct answer to fb, save it in the 
			// group. This is not set for targets as that must be done in the pop-up bit.
			if (thisPopUpAnswer == undefined || thisPopUpAnswer == "") {
			} else {
				//myTrace("save pop-up as correct answer=" + thisPopUpAnswer);
				allGroups[i].correctAnswer = thisPopUpAnswer;
			}
		}
	}
	/* for timing
	var stopTime = new Date().getTime();
	if (mode & _global.ORCHID.marking.showAnswers) {
		trace("inserting took " + (stopTime - startTime));
	} else {
		trace("just colouring took "  + (stopTime - startTime));
	}
	*/
	// finally stop fields from reacting any more
	// v6.3.3 It looks like this function is stopping the tryAgain rather than startAgain behaviour
	// Can I move it into tryAgainEvent rather than leaving it here?
	//afterMarkingFieldDisable();
}
// v6.2 Create a new form of marking activity which is to remove any graphics
// highlights fields after marking. In the CUP case this means tick and cross next 
// to ones that you did. Very inefficent function.
markingRemoveHighlighting = function() {
	var me = _global.ORCHID.LoadedExercises[0].body.text;
	var allFields = me.field;
	// for each field that they have answered, remove a graphic "next" to it,
	for (var i in allFields) {
		var contentHolder = getRegion(allFields[i]).getScrollContent();
		var thisParaBox = contentHolder["ExerciseBox" + allFields[i].paraNum];
		thisParaBox.clearFieldBackground(allFields[i].id);
		// v6.4.2.7 Also ticks and crosses
		//myTrace("clear tick/cross from " + allFields[i].id);
		thisParaBox.clearFieldTick(allFields[i].id);
	}
}

// disable fields in the exercise - used after marking to stop interaction
afterMarkingFieldDisable = function() {
	//myTrace("afterMarkingFieldDisable");
	// v6.3.3 move exercise panels to buttons holder
	//var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
	var contentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getScrollContent();
	// also use the height change event so that you can react to the answers going in
	// v6.4.2.7 Name changed
	//var eventNames = {controlClick:"_global.ORCHID.onControlClick",
	var eventNames = {controlClick:"_global.ORCHID.onGlossary",
					heightChange:"_global.ORCHID.heightChange"};
	// NOTE - yes, but what if there is NO individual feedback, then we should just disable everything
	// remember that the mode has kind of inverted the feedbackButton number 
	// (this has now been renamed for clarity)
	// v6.3.3 Change exercise.mode to settings
	//if (	!(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.NoFeedbackButton)
	//	&& (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.QuestionFeedback)
	// v6.4.2.4 This stops instant fb exercise (with no fb button) from seeing fb after marking. This is wrong.
	//if (	_global.ORCHID.LoadedExercises[0].settings.buttons.feedback 
	if (	(_global.ORCHID.LoadedExercises[0].settings.buttons.feedback || !_global.ORCHID.LoadedExercises[0].settings.marking.delayed)
		&& (!_global.ORCHID.LoadedExercises[0].settings.feedback.scoreBased )
		&& (_global.ORCHID.LoadedExercises[0].feedback.length > 0)) {
		//myTrace("there is feedback for this exercise, mode=" + _global.ORCHID.LoadedExercises[0].mode + ".length=" + _global.ORCHID.LoadedExercises[0].feedback.length);
		var noFeedback = false;
		// v6.3.5 With drag and drop, after getting one fieldFeedback, every other click repeats it. WHy?
		// this is the only place where the function is added. What is it added to?
		eventNames.mouseUp = "_global.ORCHID.fieldFeedback";
	} else {
		//myTrace("there is NO feedback for this exercise, mode=" + _global.ORCHID.LoadedExercises[0].mode + ".length=" + _global.ORCHID.LoadedExercises[0].feedback.length);
		var noFeedback = true;
	}
	for (var i in contentHolder) {
		// v6.2 Perhaps instead of just disabling fields we can change the
		// events so that clicking on ANY field displays individual fb for that field?
		if (contentHolder[i]._name.indexOf("ExerciseBox") >= 0) {
			var thisParaBox = contentHolder[i];
			//myTrace("paraBox=" + thisParaBox);
			// first set up the new events
			// v6.5.4.5 Since you do this for all twfs, then even if we only have i:url, it will still lose the event handling.
			// So make this conditional on finding other fields in the twf. This will mean that if we get a i:url in a separate
			// para it will still work. Better than nothing.
			// I think that you can set this after doing addCoverFunctions?
			//thisParaBox.setEvents(eventNames);
			var fieldInParaBox = false;
			
			//myTrace("add events for TWF=" + thisParaBox);
			// then tweak the field definitions
			// but lets disable drag fields (and highlights I guess)
			// and change everything else so it appears to be a target (this technique is guess work)
			// v6.3.3 If you have no feedback in a d&d, the drops don't get disabled so generate
			// no feedback boxes when clicked, which then causes ANY click in the movie to get such a warning!
			// I guess that drops have extra fields on top of them??
			// v6.3.5 With drag and drop, after getting one fieldFeedback, every other click repeats it. Why?
			// Well, its like this... 
			// Since markingColouringInserting is still going on (due to tlc), you will still be
			// doing insertAnswer functions which call setText which do FULL refresh of the twf. This is
			// VERY bad (inefficent). And since the fields.type etc is built from the htmlText, you cannot
			// override the field type. It will revert to drop. And thus onMouse events are NOT cancelled when
			// you rollOut of a cover. One temporary solution might be to put this bit of code into the 
			// tlcCallback of colouring and inserting. Or just switch of single click feedback for drags!
			// Either way, it is imperative to sort out seeTheAnswers processing to make it efficent.
			for (var j in thisParaBox.fields) {
				// v6.3.4 Don't remove field effect for simple urls or popup text
				//myTrace("field " + thisParaBox.fields[j].id + " is type=" + thisParaBox.fields[j].type);
				//if (thisParaBox.fields[j].type != "i:url") {
				if (thisParaBox.fields[j].type == "i:url" || thisParaBox.fields[j].type == "i:text") {
					// v6.5.4.5 It is not enough to avoid addCoverFunctions because you did thisParaBox.setEvents earlier
					//myTrace("this is just a url field, so don't clear the coverFunctions");
				} else {
					fieldInParaBox = true;
					// v6.4.2.7 But if there is no feedback, I disable the cover which means I can't get glossary for the answer
					//if (noFeedback || thisParaBox.fields[j].type == "i:drag" || thisParaBox.fields[j].type == "i:highlight") {
					if (thisParaBox.fields[j].type == "i:drag" || thisParaBox.fields[j].type == "i:highlight") {
						thisParaBox.disableField(thisParaBox.fields[j].id);
						//myTrace("removing field action");
					} else {
						// and finally reset the cover functions for the remaining fields
						for (var k in thisParaBox.fields[j].coords) {
							var thisCover = thisParaBox.fields[j].coords[k].coverMC;
							//myTrace("change cover functions for field " + i + " from type "+ thisCover.fieldType);
							//myTrace("cover fieldType=" + thisCover.fieldType + " field fieldType=" + thisParaBox.fields[j].type);
							// v6.4.2.7 Don't overwrite more field types than you need to. Doesn't help, so safer to leave as is.
							//if (thisParaBox.fields[j].type == "i:drag" || thisParaBox.fields[j].type == "i:drop") {
								thisCover.fieldType = "i:target"; // really this just needs to be NOT drag or drop
							//} else {
							//	thisCover.fieldType = thisParaBox.fields[j].type; 
							//}
							//v6.3.5 Now, since markingColouringInserting is still going on, you will still be
							// doing insertAnswer functions which call setText which do full refresh. This is
							// VERY bad (inefficent). AND it changes the fieldType back to what it was originally.
							//thisParaBox.fields[j].type = "i:target";
							//myTrace("to type " + thisCover.fieldType + " in twf.version=" + thisParaBox._version);
							thisParaBox.addCoverFunctions(thisCover);
						}
					}
				}
			}
			// v6.5.4.5 Change the events assuming you found a field in this paraBox
			if (fieldInParabox) {
				thisParaBox.setEvents(eventNames);
			} else {
				//myTrace("no need to reset events for this para");
			}
			//	thisParaBox.removeFieldCovers();
			//	thisParaBox.buildTextAndFields();
		}
	}
	// v6.2 Then clumsily repeat for the no_scroll region!
	// v6.3.3 Move exercise panels to buttons holder
	//contentHolder = _root.exerciseHolder.NoScroll_SP.getScrollContent();
	contentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.NoScroll_SP.getScrollContent();
	// remove all reaction
	// v6.4.2.7 No - still do glosssary stuff
	//eventNames = {};
	eventNames = {controlClick:"_global.ORCHID.onGlossary"};
	for (var i in contentHolder) {
		// v6.2 Perhaps instead of just disabling fields we can change the
		// events so that clicking on ANY field displays individual fb for that field?
		if (contentHolder[i]._name.indexOf("ExerciseBox") >= 0) {
			var thisParaBox = contentHolder[i];
			// first set up the new events
			thisParaBox.setEvents(eventNames);
			// lets disable drag fields (and highlights I guess) DO THEM ALL!
			for (var j in thisParaBox.fields) {
				//trace("field " + thisParaBox.fields[j].id + " is type=" + thisParaBox.fields[j].type);
				//if (thisParaBox.fields[j].type == "i:drag" || thisParaBox.fields[j].type == "i:highlight") {
					thisParaBox.disableField(thisParaBox.fields[j].id);
				//} 
			}
		}
	}
}
// is there any changes to multimedia after marking?
markingMultimediaUpdate = function() {
	var me = _global.ORCHID.LoadedExercises[0].body.text;
	//trace("in mMU ex.mode=" + _global.ORCHID.LoadedExercises[0].mode);
	// *****
	// MULTIMEDIA section
	// *****
	// if there were any embedded media items that were hidden until after marking, show them now
	var allMedia = me.media;
	// move exercise panels to buttons holder
	//var contentHolder = _root.exerciseHolder.Exercise_SP.getScrollContent();
	var contentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.Exercise_SP.getScrollContent();
	for (var i in allMedia) {
		// if this media was hidden AND embedded, show it now. 
		// If no coords (just after marking audio), leave it in jb list to be played
		if (allMedia[i].coordinates.x == undefined || allMedia[i].coordinates.y == undefined) {
		} else {
			//v6.4.2.1 use correct binary flag
			//if (allMedia[i].mode == _global.ORCHID.mediaMode.ShowAfterMarking) {
			if (allMedia[i].mode & _global.ORCHID.mediaMode.ShowAfterMarking) {
				//trace("now show " + allMedia[i].filename + " at x=" + allMedia[i].coordinates.x);
				showMediaItem(allMedia[i], contentHolder); 
			}
		}
	}
	// load the 'first' afterMarking floating resource item into the jukebox
	var myMediaController = _global.ORCHID.root.jukeboxHolder;
	for (var i=0; i<myMediaController.myJukeBox.mediaList.length; i++) {
		//trace("check mode for " + myMediaController.myJukeBox.mediaList[i].jbURL + "=" + myMediaController.myJukeBox.mediaList[i].jbPlayMode);
		if (myMediaController.myJukeBox.mediaList[i].jbPlayMode &_global.ORCHID.mediaMode.ShowAfterMarking) {
			// make sure that all media is now set to autoPlay (remember this is only floating. not embedded)
			myMediaController.myJukeBox.mediaList[i].jbAutoPlay=true;
			// AR v6.4.2.5 Add streaming audio - copied from display.as
			if (	myMediaController.myJukeBox.mediaList[i].jbMediaType.toLowerCase().indexOf("audio")>=0 && 
				myMediaController.myJukeBox.mediaList[i].jbMediaType.toLowerCase().indexOf("static")<0) {
				myTrace("streaming audio after marking");
					//for (var jj in myMediaController.myJukeBox.mediaList[i]) {
					//	myTrace(jj + "=" + myMediaController.myJukeBox.mediaList[i][jj])
					//}
				// v6.4.2.4 If you have autoplay streaming audio, it might look better to attach the mediaPlayer to the base screen
				// so that the streaming bar appears there instead on on the exercisepane. It goes on a layered mc so that it is
				// easy to remove in clearExercise
				// v6.4.2.5 What if it already exists? You will be unable to load the videoPlayer.swf if it is. This might cause problems
				// if you had two media with the same ID, but that probably causes other problems too.
				if (_global.ORCHID.root.buttonsHolder.ExerciseScreen.streamer == undefined) {
					var newContentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.createEmptyMovieClip("streamer", Number(_global.ORCHID.mediaDepth));
				} else {
					var newContentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.streamer;
				}
				//var newContentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen;
				//var newContentHolder = myMediaController;
				// position it, but ugly as you can't rely on screens.display.init to have run yet if this is the first exercise they do
				myMediaController.myJukeBox.mediaList[i].jbX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.jukeboxPlaceHolder._x;
				myMediaController.myJukeBox.mediaList[i].jbY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.jukeboxPlaceHolder._y + 15; // ugly hack as streamer is -25 above the videoPlayer
				// v6.5.6.4 New SSS we want the streamer to be on the background of the controller
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
					//myMediaController.myJukeBox.mediaList[i].jbY-=12;
					// v6.5.6.4 Bring it just slightly underneath so we can see it and make it the same width
					myMediaController.myJukeBox.mediaList[i].jbY+=4;
					myMediaController.myJukeBox.mediaList[i].jbWidth=120;
				}
				// v6.4.2.5 In fact, you don't want see this if you have the controller because it is behind and obscured.
				// v6.4.2.5 You won't want to see a streaming label and bar if this is a question based media item.
				// v6.5.4.3 I don't see a streamer for after marking media - why has this got anything to do with jbPlayTimes?
				// surely it should be based on anchoring or somesuch. In fact, since this has to be autoplay, it will never be question based.
				// The jbPlayTimes comes because RIELTS has no controller, jbPlayTimes=1 so it just needs the streamer.
				// That works, and it turns out that I do get a streamer, but it is hidden behind the controller. So, move the streamer DOWN
				// if you have the controller. Repeat in display.as
				//if (myMediaController.myJukeBox.mediaList[i].jbPlayTimes>0) {
					myMediaController.myJukeBox.mediaList[i].streamingLabel = _global.ORCHID.literalModelObj.getLiteral("streaming", "labels");
				//} else {
				//	myMediaController.myJukeBox.mediaList[i].streamingLabel = undefined;
				//}
				//myTrace("streamer jbY=" + myMediaController.myJukeBox.mediaList[i].jbY);
				if (myMediaController.myJukeBox.mediaList[i].jbPlayTimes==0) {
					myMediaController.myJukeBox.mediaList[i].jbY += 25;
				}
				//myTrace("streamer jbY=" + myMediaController.myJukeBox.mediaList[i].jbY);
				// bodge until createVideoPlayer is more sorted!
				var me = {id:myMediaController.myJukeBox.mediaList[i].jbID, playTimes:myMediaController.myJukeBox.mediaList[i].jbPlayTimes}
				createVideoPlayer(me, myMediaController.myJukeBox.mediaList[i], newContentHolder);
			} else {
				//myTrace("add and autoplay afterMarking media");
				myMediaController._visible = true;
				myMediaController.myJukeBox.setMedia(myMediaController.myJukeBox.mediaList[i]);
			}
			break;
		}
	}
}

// v6.2 use a setting to control feedback buttons
// v6.3.5 Add the ability to send #ca# for correctAnswer to feedback
//displayFeedback = function(thisFeedback, correct, stdAnswer, questionNumber, setting) {
displayFeedback = function(thisFeedback, correct, stdAnswer, correctAnswer, questionNumber, setting) {
	//myTrace("displayFeedback to ppotS");
	//trace("in displayFeedback with " + thisFeedback.paragraph[0].plainText);
	//trace("message["+correct+"]="+commentParagraph.plainText);
	if (thisFeedback == undefined) {
		var noFeedbackNote = {style:"normal", coordinates:{x:"+0", y:"+0", width:"360"}};
		// 6.0.4.0, take the no feedback message from literal model
		//noFeedbackNote.plainText = "Sorry, there is no feedback for this question.";
		// v6.3.5 Remove 'no feedback' note and make it just emphasise the right or wrongness
		// v6.4.2.4 Except that after marking it doesn't make sense to be so interactive, better to give them something bland
		if (_global.ORCHID.session.currentItem.afterMarking) {
			//myTrace("nofeedback after marking");
			var useLit="noFeedbackAfterMarking";
		} else {
			// v6.4.2.8 Since we now have tick and cross, then simply do nothing for instant marking, but no feedback, before main marking
			// This is already done before you come here, in fieldReaction
			//if (setting=="Instant") {
			//	myTrace("instant marking, but no feedback");
			//	return;
			//}
			//myTrace("nofeedback, correct=" + correct);
			if (correct == true || correct == "true") {
				var useLit="wellDoneNoFeedback";
			// v6.4.1.4 Alt for wrong AND neutral
			} else if (correct == false || correct == "false") {
				var useLit="sorryNoFeedback";
			} else {
				var useLit="neutralFeedback";
			}
		}
		var useLitText = _global.ORCHID.literalModelObj.getLiteral(useLit, "messages");
		//noFeedbackNote.plainText = '<font face="Verdana" size="12">' + _global.ORCHID.literalModelObj.getLiteral("noFeedback", "messages") + '</font>';
		noFeedbackNote.plainText = '<font face="Verdana" size="12">' + useLitText + '</font>';
		//noFeedbackNote.plainText = _global.ORCHID.literalModelObj.getLiteral("noFeedback", "messages");
		var thisFeedback = {paragraph:[noFeedbackNote]};
	}

	// v6.4.3 Can you pick up everyone else's average score for this exercise?
	// Or will this only go in score based?
	/*
	// Before you can tell the averages you need to update the scaffold;
	var xxx=_global.ORCHID.course.scaffold.getNonRandomProgressDetails(0);
	
	//myTrace("look up item id=" + _global.ORCHID.session.currentItem.ID);
	var thisScaffoldItem = _global.ORCHID.course.scaffold.getObjectByID(_global.ORCHID.session.currentItem.ID);
	myTrace("#ev#, " + thisScaffoldItem.progress.numExercisesDone[2] + ", " + thisScaffoldItem.progress.averageScore[2]);
	if (thisScaffoldItem.progress.averageScore[2]==undefined){
		var everyoneAverageMsg = "Nobody else has done this test yet."
	} else if (thisScaffoldItem.progress.averageScore[2]>=0){
		var everyoneAverage = Math.floor(thisScaffoldItem.progress.averageScore[2]);
		var numDone = thisScaffoldItem.progress.numExercisesDone[2];
		if (numDone==1) {
			var numWording = "once.";
		} else {
			var numWording = numDone + " times.";
		}
		var everyoneAverageMsg = "Everyone else has an average of " + everyoneAverage + "%, having completed this test " + numWording;
	}
	myTrace("#yv#, " + thisScaffoldItem.progress.numExercisesDone[0] + ", " + thisScaffoldItem.progress.averageScore[0]);
	if (thisScaffoldItem.progress.record.length<=1){
		var yourAverageMsg = "This was your first try at this test."
	} else if (thisScaffoldItem.progress.record.length>1){
		var yourAverage = Math.floor(thisScaffoldItem.progress.averageScore[0]);
		var numDone = thisScaffoldItem.progress.record.length;
		if (numDone==1) {
			var numWording = "once,";
		} else {
			var numWording = numDone + " times,";
		}
		var yourAverageMsg = "You've done it " + numWording + " and have an average of " + yourAverage + "%";
	}
	*/
	
	// send the contents of the feedback to the screen, along with a substitution list
	// Note: you cannot do this as it changes the original - so pass it to pPOTS
	var substList = new Array();
	substList[0] = {tag:"#ya#", text:stdAnswer};
	substList[1] = {tag:"#q", text:questionNumber};
	substList[2] = {tag:"#ca#", text:correctAnswer};
	substList[3] = {tag:"#br#", text:"<br>"};
	/*
	substList[4] = {tag:"#ev#", text:everyoneAverage};
	substList[5] = {tag:"#yv#", text:yourAverage};
	*/
	// can you also convert the question number?
	//substTags(thisFeedback, substList);

	// Send the correct tag on the feedback paras
	thisFeedback.correct = correct;
	// v6.5.5.8 With small feedback we can position it by the field (not by the mouse)
	// But I can't see that I know the current field at this point. So better save it in currentItem.thisGap.
	// Also, you should make sure that the fb window can fit - just like you do with menus to move up and left if this field is low and right.
	if (_global.ORCHID.LoadedExercises[0].settings.exercise.smallFeedbackWindow) {
		var thisCover = _global.ORCHID.session.currentItem.thisGap.cover;
		var thisPoint = {x:thisCover._x, y:thisCover._y};
		thisCover._parent.localToGlobal(thisPoint);
		// But these fb boxes want to go above the gap. Ideally we would make the x,y an anchor for the bottom left corner.
		// But for now it is quicker to just assume that the height is always the same
		thisPoint.y -= 60;
		var coords = thisPoint;
	} else {
		var coords = null;
	}
	//myTrace("displayFeedback");
	_global.ORCHID.tlc = {proportion:100, startProportion:0};
	//_global.ORCHID.root.tlcController.setLabel("feedback");
	_global.ORCHID.root.tlcController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadFeedback", "labels"));
	putParagraphsOnTheScreen(thisFeedback, "drag pane", "Feedback_SP", substList, coords, setting);
};

//function to collate text for delayed feedback
// you can do this be going through the group array rather than the field array
delayedFeedback = function(setting, toPrinter) {
	//trace("in delayed feedback");
	//_global.ORCHID.startTime = new Date().getTime();
	
	var me = _global.ORCHID.LoadedExercises[0];
	var delayedFeedback = new Object();
	delayedFeedback.paragraph = new Array();
	var thisFeedback = new Object();

	// Feedback can either be question or score based.
	//trace("in delayedFb ex.mode=" + me.mode + " against qfbMode=" + _global.ORCHID.exMode.QuestionFeedback + " = " + (me.mode & _global.ORCHID.exMode.QuestionFeedback));
	// v6.3.5 Change the no feedback note based on right or wrong
	var noFeedbackNote = {style:"normal", coordinates:{x:"+5", y:"+5", width:"360"}};
	//noFeedbackNote.plainText = '<font face="Verdana" size="12">' + _global.ORCHID.literalModelObj.getLiteral("noFeedback", "messages") + '</font>';
	//var noFeedbackPara = {paragraph:[noFeedbackNote]};
	//v6.3.3 change mode to settings
	if (me.settings.feedback.scoreBased) {
		//myTrace("score based feedback");
		// this will now deal with score based feedback
		var thisScore = me.score.score;
		// if feeback array was sorted by ID, then I could find the one just less than
		// my score quite easily - mind you there will be very few entries so going
		// through them all will not be painful
		// thisScore will be 75% and we want the fbID that is as close (but lower) to this as possible
		var closestIndex = {score:0, idx:0};
		for (var i in me.feedback) {
			//myTrace("check feedback[" + i + "]=" + me.feedback[i].ID + " against your score=" + thisScore);
			if (me.feedback[i].ID == thisScore) {
				// found the perfect match
				closestIndex.score = me.feedback[i].ID;
				closestIndex.idx = i;
				//myTrace("so set idx=" + i);
				break;
			} else if (me.feedback[i].ID < thisScore && me.feedback[i].ID >= closestIndex.score) {
				closestIndex.score = me.feedback[i].ID;
				closestIndex.idx = i;
			} 
		}
		//myTrace("looking up fb ID " + myGroups[k].correctFbID + " found it at " + feedbackArrayIDX + " your answer=" + stdAnswer);
		if (closestIndex.idx >= 0){
			thisFeedback = me.feedback[closestIndex.idx].text;
			//myTrace("found fb " + thisFeedback.paragraph[0].plainText);
		} else {
			//myTrace("no feedback for this score");
			// v6.3.5 This should not really happen, so OK to leave the old message, + it is only shown once
			noFeedbackNote.plainText = '<font face="Verdana" size="12">' + _global.ORCHID.literalModelObj.getLiteral("noFeedback", "messages") + '</font>';
			thisFeedback = {paragraph:[noFeedbackNote]};
		}
		// v6.4.3 Can you pick up everyone else's average score for this exercise?
		// Before you can tell your averages you need to update the scaffold;
		var xxx =new XML();
		xxx=_global.ORCHID.course.scaffold.summariseInformation(0);
		
		//myTrace("look up item id=" + _global.ORCHID.session.currentItem.ID);
		var thisScaffoldItem = _global.ORCHID.course.scaffold.getObjectByID(_global.ORCHID.session.currentItem.ID);
		//myTrace("#ev#, " + thisScaffoldItem.progress.numExercisesDone[2] + ", " + thisScaffoldItem.progress.averageScore[2]);
		if (thisScaffoldItem.progress.averageScore[2]==undefined){
			var everyoneAverageMsg = "Nobody else has done this test yet."
		} else if (thisScaffoldItem.progress.averageScore[2]>=0){
			var everyoneAverage = Math.floor(Number(thisScaffoldItem.progress.averageScore[2]));
			var numDone = thisScaffoldItem.progress.numExercisesDone[2];
			if (numDone==1) {
				var numWording = "once.";
			} else {
				var numWording = numDone + " times.";
			}
			var everyoneAverageMsg = "Everyone else has an average of " + everyoneAverage + "%, having completed this test " + numWording;
		}
		//myTrace("#yv#, " + thisScaffoldItem.progress.numExercisesDone[0] + ", " + Math.floor(Number(thisScaffoldItem.progress.averageScore[0])));
		if (thisScaffoldItem.progress.record.length<=1){
			var yourAverageMsg = "This was your first try at this test."
		} else if (thisScaffoldItem.progress.record.length>1){
			myTrace("raw=" + thisScaffoldItem.progress.averageScore[0] + " floor=" + Math.floor(Number(thisScaffoldItem.progress.averageScore[0])));
			var yourAverage = Math.floor(Number(thisScaffoldItem.progress.averageScore[0]));
			var numDone = thisScaffoldItem.progress.record.length;
			if (numDone==1) {
				var numWording = "once,";
			} else {
				var numWording = numDone + " times,";
			}
			var yourAverageMsg = "You've already done it " + numWording + " and have an average of " + yourAverage + "%.";
		}
		
		//trace("score fb is closest for " + closestIndex.score + "%="+ thisFeedback.paragraph[0].plainText);
		var substList = new Array();
		substList[0] = {tag:"#ya#", text:thisScore + "%"};
		substList[1] = {tag:"#br#", text:"<br>"};
		substList[2] = {tag:"#ev#", text:everyoneAverageMsg};
		substList[3] = {tag:"#yv#", text:yourAverageMsg};
			
		// Assume that only the paragraph array in the thisFeedback object contains useful info
		for (var i=0; i<thisFeedback.paragraph.length; i++) {
			// Note: is passing by reference getting itself looped up here?
			// I deliberately change the main structure. It will stop new substitution if they go back
			// and do instant marking afterwards, but that might not be a bad thing actually.
			thisFeedback.paragraph[i].plainText = substTags(thisFeedback.paragraph[i].plainText, substList);
			//trace("after subst I have " + thisFeedback.paragraph[i].plainText);
			delayedFeedback.paragraph.push(thisFeedback.paragraph[i]);
		}
	} else {
		//myTrace("question based feedback");
		//	Preset a "no feedback for this question" paragraph - cf Invective comment in instant feedback
		//var horizontalRuler = {style:"normal", coordinates:{x:"0", y:"+5", width:"360", height:"17"}};
		var horizontalRuler = {style:"ruler", coordinates:{x:"0", y:"+5", width:"360", height:"4"}};	// yiu temp commented
		//horizontalRuler.plainText = '===================================';
		var horizontalRulerPara = {paragraph:[horizontalRuler]};
	
		//for (var ii in me.feedback) { trace("got fb at "+ii+" which is ID "+me.feedback[ii].ID); }
		var myGroups = me.body.text.group;
		var myFields = me.body.text.field;
		//var totalPara = 0;
	
		// you want to check each group to see what feedback it is going to display
		// Note: you need to order this by question number to get sensible ordering of feedback
		// See note in XMLtoObject for explanation of why the ordering might be wrong
		//for (var k=myGroups.length-1; k>=0; k--) {
		//	myTrace("pre-sort " + myGroups[k].ID);
		//}
		myGroups.sort(groupOrdering);
		//for (var k=myGroups.length-1; k>=0; k--) {
		//	myTrace("post-sort " + myGroups[k].ID);
		//}
		for (var k=0; k<myGroups.length; k++) {
		//for (var k=myGroups.length-1; k>=0; k--) {
			//myTrace("build fb for group " + myGroups[k].ID + " correctFBid=" + myGroups[k].correctFbID);
			// v6.2 Check to see whether we want fb for all questions, or just those they got wrong
			// v6.3.3 change mode to settings
			//if (me.mode & _global.ORCHID.exMode.OnlyWrongFeedback) {
			if (me.settings.feedback.wrongOnly) {
				//myTrace("only show wrong feedback for this exercise");
				// v6.3.5 BUT you don't use attempt at group level anymore. Change to score and maxScore
				if (myGroups[k].score >= myGroups[k].maxScore && myGroups[k].score != undefined) {
				//if (myGroups[k].attempt.score > 0) {
					//myTrace("only show wrong, and group " + k + " has score=" + myGroups[k].score)
					//myTrace("right! so hide fb for q " + myGroups[k].questionNumber + "(" + k + ") " + myGroups[k].attempt.finalAnswer);
					myGroups[k].suppressFb = true;
				}
			}
			// v6.2 use the suppress feedback flag set in the marking section above to determine
			// whether to show this fb or not
			// Also suppress feedback for groups that are not real
			if (myGroups[k].suppressFb || Number(myGroups[k].ID) <= 0) {
				//myTrace("suppress feedback for question " + myGroups[k].questionNumber + "(" + k + ")");
			} else {
				//myTrace("feedback for group " + myGroups[k].ID + " = " + myGroups[k].correctFbID);
				feedbackArrayIDX = lookupArrayItem(me.feedback, myGroups[k].correctFbID, "ID");
				//v 6.3.4 You need to merge together finalAnswers from all fields in this group
				var stdAnswerArray = new Array();
				for (var field in myGroups[k].fieldsInGroup) {
					//myTrace("for group " + myGroups[k].ID + " add field " + myGroups[k].fieldsInGroup[field] + " stdAnswer=" + myFields[myGroups[k].fieldsInGroup[field]].attempt.finalAnswer);
					if (myFields[myGroups[k].fieldsInGroup[field]].attempt.finalAnswer != undefined) {
						stdAnswerArray.push(myFields[myGroups[k].fieldsInGroup[field]].attempt.finalAnswer);
					}
				}
				var stdAnswer = stdAnswerArray.join("/");
				//myTrace("so full stdAnswer=" + stdAnswer);
				//var stdAnswer = myGroups[k].attempt.finalAnswer;
				if (stdAnswer == null || stdAnswer == "") stdAnswer = "____";
				//myTrace("looking up fb ID " + myGroups[k].correctFbID + " found it at " + feedbackArrayIDX + " your answer=" + stdAnswer);
				if (feedbackArrayIDX >= 0){
					thisFeedback = me.feedback[feedbackArrayIDX].text;
					//myTrace("found fb " + thisFeedback.paragraph[0].plainText);
				} else {
					//myTrace("no feedback for group " + myGroups[k].ID);
					// v6.3.5 Remove 'no feedback' note and make it just emphasise the right or wrongness
					// Fine for instant, but for delayed, lets actually show nothing if they are wrong only
					// and no fb written for this item
					// v6.4.2.4 I am only in delayedFeedback, so if there is no fb, simply show nothing seems by far the best.
					// If not, then at least you should add a question number to help identify what you got right or wrong.
					thisFeedback = {}
					/*
					if (me.settings.feedback.wrongOnly) {
						thisFeedback = {}
					} else {
						// But what to write, not much point just writing well done or sorry.
						// Could do a #ya# and #ca#, or could leave it undefined so that the display skips it
						if (myGroups[k].score >= myGroups[k].maxScore && myGroups[k].score != undefined) {
							var useLit="wellDone";
						} else {
							var useLit="sorry";
						}
						//myTrace("score=" + myGroups[k].score + " useLit=" + useLit);
						//noFeedbackNote.plainText = '<font face="Verdana" size="12">' + _global.ORCHID.literalModelObj.getLiteral("noFeedback", "messages") + '</font>';
						// You need to make a copy of the noFeedback object since you are changing part of it each go through the loop
						var thisFeedbackNote = new Object();
						for (var prop in noFeedbackNote) {
							thisFeedbackNote[prop] = noFeedbackNote[prop];
						};
						thisFeedbackNote.plainText = '<font face="Verdana" size="12">' + _global.ORCHID.literalModelObj.getLiteral(useLit, "messages") + '</font>';
						thisFeedback = {paragraph:[thisFeedbackNote]}
					}
					*/
				}
				//trace("fb is " + thisFeedback.paragraph[0].plainText);
				var substList = new Array();
				substList[0] = {tag:"#ya#", text:stdAnswer};
				//substList[1] = {tag:"#q#", text:myGroups[k].questionNumber};
				substList[1] = {tag:"#q", text:myGroups[k].questionNumber}; // the older format for adding question numbers
				substList[2] = {tag:"#ca#", text:myGroups[k].correctAnswer};
				// trace("I want to swap #ya# to be " + stdAnswer);
				// I also need to swap in the question number here, perhaps it could be saved in the group
				
				// v6.4.2.4 If there is nothing in this feedback (after all the above), then don't add a ruler after it.
				if (thisFeedback.paragraph.length>0) {
					// v6.5.4.3 AR I think it looks better with no blank line 
					/*
					if(delayedFeedback.paragraph.length > 0){	// do not add a blank to the first feedback
						var noFeedbackNoteBlank = {style:"normal", coordinates:{x:"+0", y:"+0"}};
						noFeedbackNoteBlank.plainText = '<font face="Verdana" size="12"></font>';
						delayedfeedback.paragraph.push(noFeedbackNoteBlank);
                                        }
					*/

					// v6.5.4.2 Yiu, push a blank line and a question number before the feedback, Bug ID 1208
					if(me.settings.feedback.showQuestionNo){
						var qNumFeedbackNote 		= {style:"normal", coordinates:{x:"+0", y:"+0", width:"360"}};
						// v6.5.4.3 AR Need to use literals
						//qNumFeedbackNote.plainText 	= '<font face="Verdana" size="12">Question ' + (Number(myGroups[k].questionNumber)+1) + '</font>';
						var qSubstList = new Array();
						qSubstList[0] = {tag:"[x]", text:myGroups[k].questionNumber};
						var questionText = substTags(_global.ORCHID.literalModelObj.getLiteral("fbQuestionNumber", "labels"),qSubstList);
						qNumFeedbackNote.plainText = '<font face="Verdana" size="12">' + questionText + '</font>';
						delayedFeedback.paragraph.push(qNumFeedbackNote);
					}
					// End v6.5.4.2 Yiu, push a blank line and a question number before the feedback, Bug ID 1208

					// v6.5.4.2 Yiu, push a blank line and a question number before the feedback, Bug ID 1208
					//var qNumFeedbackNote 		= {style:"normal", coordinates:{x:"+0", y:"+0", width:"360"}};
					//qNumFeedbackNote.plainText 	= '<font face="Verdana" size="12">Question ' + (Number(myGroups[k].questionNumber)+1) + '</font>';
					//delayedFeedback.paragraph.push(qNumFeedbackNote);

					//delayedFeedback.paragraph.push(horizontalRuler);
					// End v6.5.4.2 Yiu, push a blank line and a question number before the feedback, Bug ID 1208

					// Assume that only the paragraph array in the thisFeedback object contains useful info
		
					for (var i=0; i<thisFeedback.paragraph.length; i++) {
						// Note: is passing by reference getting itself looped up here?
						// I deliberately change the main structure. It will stop new substitution if they go back
						// and do instant marking afterwards, but that might not be a bad thing actually.
						thisFeedback.paragraph[i].plainText = substTags(thisFeedback.paragraph[i].plainText, substList);
						//myTrace("after subst I have " + thisFeedback.paragraph[i].plainText);
						delayedFeedback.paragraph.push(thisFeedback.paragraph[i]);
					};
					//totalPara += thisFeedback.paragraph.length;
					// try to add a ruler between each block of feedback
					delayedFeedback.paragraph.push(horizontalRuler);	// temp yiu
				}
			}
		}		
	}
	// v6.2 Catch cases where they got everything right and onlyShowWrong mode is set
	// v6.3.5 Ideally you would like to catch this during screen display so you can hide the button
	//myTrace("fb has paragraphs=" + delayedFeedback.paragraph.length);
	if (delayedFeedback.paragraph.length == 0) {
		var allCorrectNote = {style:"normal", coordinates:{x:"+0", y:"+0", width:"360", height:"0"}};
		allCorrectNote.plainText = '<font face="Verdana" size="12">' + _global.ORCHID.literalModelObj.getLiteral("allCorrect", "messages") + '</font>';
		//noFeedbackNote.plainText = _global.ORCHID.literalModelObj.getLiteral("noFeedback", "messages");
		delayedFeedback.paragraph.push(allCorrectNote);
	}
	//for (var i in delayedFeedback.paragraph) {
	//	myTrace("show fb("+i+")=" + delayedFeedback.paragraph[i].plainText);
	//}
	// v6.3.4 Always override this - I wonder why I bother passing it then?
	setting = "Delayed";
	
	// you don't want this fb to come up near the mouse, so send some coordinates
	// and remember to add a null susbstList for that parameter
	//var coords = {x:100, y:100, width:500, height:300};
	//var stopTime = new Date().getTime();
	//myTrace("fb digging time = " + (stopTime - _global.ORCHID.startTime));
	_global.ORCHID.tlc = {proportion:100, startProportion:0};
	_global.ORCHID.root.tlcController.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadFeedback", "labels"));
	//_global.ORCHID.root.tlcController.setLabel("feedback");
	if (toPrinter) {
		_global.ORCHID.tlc.callback = feedbackReadyToPrint;
		//myTrace("ppotPrinter from pane=" + _root.ExerciseHolder.printPane + " fb=" + delayedFeedback.paragraph[0].plainText);
		// How do you know that this printPane exists - ah it is done when the print button is created
		// v6.3.3 move exercise panels to buttons holder
		putParagraphsOnThePrinter(_global.ORCHID.root.buttonsHolder.ExerciseScreen.printPane, delayedFeedback, "scroll pane", "Feedback_SP", null);
	} else {
		//myTrace("send delayed fb to screen, paragraphs=" + delayedFeedback.paragraph.length);
		putParagraphsOnTheScreen(delayedFeedback, "drag pane", "Feedback_SP", null, coords, setting);
	}
	//stopTime = new Date().getTime();
	//myTrace("total fb time = " + (stopTime - _global.ORCHID.startTime));
	//v6.4.2.4 At this point you can reenable the feedback button so it can be called again.
	myTrace("reenable feedback button");
	_global.ORCHID.viewObj.setFeedback(true);
}
// v6.3.4 Once the feedback is all formatted in the printPane, run this callback event
feedbackReadyToPrint = function() {
	var paneName = "Feedback_SP";
	var printPane = _global.ORCHID.root.buttonsHolder.ExerciseScreen.printPane;

	//myTrace("now you can try to print the pane");
	//myTrace("one feedback is: " + printPane.Feedback_SP.ExerciseBox0.holder.htmlText);
	printPane[paneName]._xscale = printPane[paneName]._yscale = 80;
	
	// finally send it to be printed
	printPane._x = printPane._y = 0;

	// v6.5 Since this code also prints feedback from a test - you won't always have namePath filled in.
	if (_global.ORCHID.session.currentItem.unit==-16){
		fullName = _global.ORCHID.session.currentItem.caption;
	} else {
		var namePath = _global.ORCHID.course.scaffold.getParentCaptions( _global.ORCHID.session.currentItem.ID);
		fullName = namePath[namePath.length-2] + "&nbsp;-&nbsp;" + namePath[namePath.length-1];
	}
	// v6.4.2.4 Change feedback header
	var thisHeader = _global.ORCHID.literalModelObj.getLiteral("feedbackFrom", "labels") + " " + fullName;
	// v6.4.2.7 Use literal for CUP as well
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
	//		var thisFooter = "English Grammar in Use CD-ROM ? Cambridge University Press 2004";
	//	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
	//		var thisFooter = "Advanced Grammar in Use CD-ROM ? Cambridge University Press 2005";
	//	} else {
	//		var thisFooter = "Essential Grammar in Use CD-ROM ? Cambridge University Press 2006";
	//	}
	//} else {
		var substList = [{tag:"[x]", text:_global.ORCHID.course.scaffold.caption}];
		var thisFooter = substTags(_global.ORCHID.literalModelObj.getLiteral("printedFrom", "labels"), substList);
	//}
	//_global.myTrace("header =" + thisHeader);
	//_global.myTrace("footer =" + thisFooter); 
	_global.ORCHID.root.printingHolder.printForMe(printPane, thisHeader, thisFooter);
}
// v6.5.4.2 Yiu for bug 1210
checkIfTheAnswerIsCorrect = function(objInput, objField){
	var strTarget:String;
	strTarget	= objInput.toString();
	var v:Number;
	for(v=0; v<objField.answer.length; ++v){
		// v6.5.4.3 AR This checks against all answers, not just correct ones!
		//if(strTarget == objField.answer[v].value){
		//myTrace("checking on " + strTarget + " against " + objField.answer[v].value + "(" + objField.answer[v].correct+ ")");
		if (answerMatch(strTarget,objField.answer[v].value) &&
			objField.answer[v].correct=="true") {
			//myTrace("match");
			return true;	
		}
	}
	return false;
}
