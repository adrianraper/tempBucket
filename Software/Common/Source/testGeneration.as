// v6.4.3 This is the TGM - Test Generation Module
// Reads a template and from there reads the relevant question banks
// and uses the selection criteria to choose questions and build them into
// a regular exercise XML that Orchid can use (or can be saved)

//testNS.debug = "Adrian";

/*
// Notes
First read all the question banks (regular exercise XML) listed in the template body node
Then, for each one, grab all the XML and save in qbHolder
Next, for each read the body node and all question nodes and check them against the tags
If a question should not be included, the node is directly removed.
Once that is all done, go to selectQuestions. This starts by checking to see if we can get the number of questions requested from the specific question banks or the total. For each qbHolder[i].requestedQuestions is the number we will use.
Then look to see if there are dependencies and sequencing set.
Now we know how many questions from each qb, choose them and get them. Do this for each qb then combine them.
So, getRandomQuestions(qbHolder[i]) and
create an array of random numbers long enough for requestedQuestions like 7,2,4,9 etc (questionNumbers(1-based))
Using this array, add the question nodes at these indexes as strings to an array.
Then get field information out of this string, change to a new contiguous fieldID and record old and new.
Add the question node to a new XML and link to questionArray (old and new fields ids)
Then look through all the field nodes and if one matches the old id, give it a new groupID, contiguous, and replace the new id. If several fields in one group, make sure they keep one groupID.
Then if any question based media, see if their anchor matches a chosen question number. If it does, give the media a new contiguous id and set the anchor to the new question id.
Then for feedback nodes, if the id matches an old group id, add the node and replace with the new groupID.
At the end of this, the XML for each qbHolder will just contain questions, fields, media and feedback that we want, with unique ids  that are sequential through all the qbHolders that we have.
CombineQuestions.
Put all the question nodes from all qbHolders in one array, then shuffle by matching against a shuffled set of indexes (this is so you could repeat the shuffling if you wanted).
*/
testNS.testGenerator = function(templateXML, callback) {
	// init stuff
	this.templateInfo = new Object();
	this.templateInfo.questionBanks = new Array();
	this.templateInfo.selectionCriteria = new Object();
	// v6.4.3 Pass through exercise based media from the template
	this.templateInfo.mediaNodes = new Array();
	
	this.randomFieldIDStart = 1;
	this.randomGroupIDStart = 1;
	this.randomMediaIDStart = 1041;
	this.questionIDStart = 1;

	//myTrace("testGenerator for " + this.debug);
	// v6.5.3 For those times we need to protect a loop - common settings
	_global.ORCHID.tlc.timeLimit = 1000;
	_global.ORCHID.tlc.controller = _global.ORCHID.root.tlcController;
	_global.ORCHID.tlc.controller.setLabel(_global.ORCHID.literalModelObj.getLiteral("loadingTest", "labels"));
	_global.ORCHID.tlc.controller.setEnabled(true);
	_global.ORCHID.tlc.controller.setPercentage(0);
	//_global.ORCHID.tlc.loadingCallback = checkQBloading;
	
	// key the passed information into the class so you can send it back
	this.ExerciseStructure = templateXML;
	this.callback = callback;
	
	// What nodes have we got? Some get passed straight through, some are dropped
	for (var i in templateXML.firstChild.childNodes) {
		//myTrace("template node=" + this.firstChild.childNodes[i].nodeName);
		if (templateXML.firstChild.childNodes[i].nodeName == "settings") {
			// save some info from this node
			var thisNode = templateXML.firstChild.childNodes[i];
			for (var j in thisNode.childNodes) {
				if (thisNode.childNodes[j].nodeName == "misc") {
					this.templateInfo.requestedQuestions = Number(thisNode.childNodes[j].attributes["questions"]);
				} else if (thisNode.childNodes[j].nodeName == "feedback") {
					this.templateInfo.scoreBasedFeedback = (thisNode.childNodes[j].attributes["scoreBased"] == "true" ? true: false);
					//myTrace("this template has feedback, score based=" + thisNode.childNodes[j].attributes["scoreBased"] + ", =" + this.templateInfo.scoreBasedFeedback);
					myTrace("this template has score based feedback");
				}
			}
		}
		if (templateXML.firstChild.childNodes[i].nodeName == "body") {
			// save the info in the node
			var thisNode = templateXML.firstChild.childNodes[i];
			for (var j in thisNode.childNodes) {
				//myTrace("testNode=" + thisNode.childNodes[j].nodeName);
				if (thisNode.childNodes[j].nodeName == "questionBank") {
					this.templateInfo.questionBanks.push(thisNode.childNodes[j].attributes);
					//myTrace("use qb=" + thisNode.childNodes[j].attributes["id"]);
				} else if (thisNode.childNodes[j].nodeName == "description") {
					//myTrace("save " + thisNode.childNodes[j].nodeName +  "=" + thisNode.childNodes[j].firstChild.nodeValue);
					this.templateInfo.selectionCriteria[thisNode.childNodes[j].nodeName] = thisNode.childNodes[j].firstChild.nodeValue;
				// v6.4.3 If there are any media nodes, they must be exercise based so let's keep them to pass to the final XML
				} else if (thisNode.childNodes[j].nodeName == "media") {
					myTrace("save node " + thisNode.childNodes[j].nodeName + " for " + thisNode.childNodes[j].attributes.filename);
					this.templateInfo.mediaNodes.push(thisNode.childNodes[j]);
				// Otherwise pass through any other node (but why in the selectionCriteria object??)
				} else {
					//myTrace("saving sc:" + thisNode.childNodes[j].nodeName + " as " + (typeof thisNode.childNodes[j].attributes));
					this.templateInfo.selectionCriteria[thisNode.childNodes[j].nodeName] = thisNode.childNodes[j].attributes;
				}
			}
			
			// drop this node now you have got the information you want
			templateXML.firstChild.childNodes[i].removeNode();
		}
		// v6.4.3 I want to copy the feedback node (if this score based) straight through to the output
		// No, this happens automatically
		//if (templateXML.firstChild.childNodes[i].nodeName == "feedback") {
		//	// make it easy to find this node again
		//	this.templateInfo.feedbackIndex = i;
		//	myTrace("so save xml index=" + this.templateInfo.feedbackIndex);
		//}
		
	}
	// Then change the exercise type from template to ? test
	templateXML.firstChild.attributes.type = "Test";

	// What does the basic skeleton look like?
	//myTrace("testGen.start, xml=" + templateXML.toString())
	// Trigger the callback to show that the template is loaded
	// and initial processing complete
	this.readQuestionBanks();

}

// Just for debugging
testNS.showSelection = function() {
	for (var i in this.templateInfo.selectionCriteria) {
		if ((typeof this.templateInfo.selectionCriteria[i]) == "object") {
			for (var j in this.templateInfo.selectionCriteria[i]) {
				myTrace("selection:" + j + "=" + this.templateInfo.selectionCriteria[i][j]);
			}
		} else {
			myTrace("selection:" + i + "=" + this.templateInfo.selectionCriteria[i]);
		}
	}
	for (var i in this.templateInfo.questionBanks){
		myTrace("qb:" + this.templateInfo.questionBanks[i].id + "=" + this.templateInfo.questionBanks[i].questions);
	}
}
// Once you know them you can load each question bank - full XML is saved
testNS.readQuestionBanks = function() {
	// Just prove you have read the template successfully
	//this.showSelection(); //return;
	
	// v6.5.3 This loop needs to be protected by the progress bar and tlc loop otherwise too easy to crash the app
	// Mind you, it might be that the slower bit happens once the files are loaded in the onLoad.
	// Look at timings to see which is most intensive
	_global.ORCHID.startTime = new Date().getTime();
	
	// Create an array to hold all the XML from the question banks
	this.qbHolder = new Array();
	
	// for displaying progress
	this.pbTotal = this.templateInfo.questionBanks.length;
	//this.pbInc = 0;

	// Read a question bank to get the body
	for (var i=0; i<this.templateInfo.questionBanks.length; i++){
		var idx = this.qbHolder.push(new XML());
		var thisQB = this.qbHolder[idx-1];
		thisQB.ignoreWhite = true;
		thisQB.master = this;
		thisQB.idx = idx-1;
		//myTrace("qbid=" + this.templateInfo.questionBanks[i].id + " qbHolder.idx=" + thisQB.idx);
		thisQB.onLoad = function(success) {			
			if (success) {
				//myTrace("success with " + this.fileName);
				// What nodes have we got? Some get passed straight through, some are dropped
				//for (var i in this.firstChild.childNodes) {
				//	myTrace("qb node=" + this.firstChild.childNodes[i].nodeName);
				//}
				// Trigger callback to say that this qb is loaded
				this.master.qbLoaded(this.idx);
				// But I can use the progress bar - make loading the qbs half of the total
				//this.master.pbInc++;
				var incPercentage = 50 / this.master.pbTotal;
				_global.ORCHID.tlc.controller.incPercentage(incPercentage);
				//myTrace("test progress bar set to " + _global.ORCHID.tlc.controller.getPercentage());
			} else {
				myTrace("Sorry, " + this.id + ".xml load failed with code " + this.status);
			}
		}
		thisQB.id = this.templateInfo.questionBanks[i].id;
		thisQB.requestedQuestions = Number(this.templateInfo.questionBanks[i].questions);
		// You could read the scaffold to see whether this item is from edited or regular exercise folder
		// v6.4.3 Yes, you should. 
		var scaffold = _global.ORCHID.course.scaffold;
		var scaffoldItem = scaffold.getObjectByID(thisQB.id);
		//myTrace(thisQB.id + " has eF=" + scaffoldItem.enabledFlag);
		if (scaffoldItem.enabledFlag & _global.ORCHID.enabledFlag.edited) {
			var thisRoot = _global.ORCHID.paths.editedExercises;
		} else {
			//myTrace("this qb is from MGS");
			var thisRoot = _global.ORCHID.paths.exercises;
		}
		var fileName = thisRoot + thisQB.id + ".xml";
		myTrace("load file=" + fileName);
		
		// v6.4.3 You must use cache killer - why? Doesn't this invalidate Akamai network for the XML files.
		// I can see that you would want to do this for files in /ap or the MGS, but the main ones are surely very static.
		// (and the ones in /ap are not covered by Akamai anyway)
		if (_global.ORCHID.online){
			var cacheVersion = "?version=" + new Date().getTime();
		} else {
			var cacheVersion = ""
		}
		thisQB.load(fileName + cacheVersion);
	}	
}
// Once a question bank is loaded, start filtering the questions it contains against the tags
testNS.qbLoaded = function(idx) {
	var thisQB = this.qbHolder[idx];
	thisQB.loaded = true;
	
	// Note that picking up attributes from XML gives an empty object if no attributes
	// But I get some very funny behaviour where matchingTags==undefined when it has
	// stuff in it as an object!
	var matchingTags = this.templateInfo.selectionCriteria.matchingTags;
	var exclusionTags = this.templateInfo.selectionCriteria.exclusionTags;
	if ((typeof matchingTags) == "object") {
		if (matchingTags == new Object()) {
			matchingTags = false;
		}
	} else if (matchingTags == undefined) {
		matchingTags = false;
	}
	if ((typeof exclusionTags) == "object") {
		if (exclusionTags == new Object()) {
			exclusionTags = false;
		}
	} else if (exclusionTags == undefined) {
		exclusionTags = false;
	}
	//myTrace("matching=" + matchingTags.language);
	//myTrace("exclu=" + exclusionTags.status);
	
	for (var i in thisQB.firstChild.childNodes) {
		//myTrace("qb node=" + thisQB.firstChild.childNodes[i].nodeName);
		if (thisQB.firstChild.childNodes[i].nodeName == "body") {
			// save the node idx as you need it later
			thisQB.bodyNodeIDX = i;
			var bodyNode = thisQB.firstChild.childNodes[i];
			// Count questions and get rid of ones that don't match or are excluded
			var numOfQuestions = 0;
			// Also record any clusters that questions are part of
			thisQB.clusters = new Object();

			// v6.5.3 Put a tlc protection around this loop
			// I can't do this because I am running this function many times as the qb banks get loaded
			// and tlc is global. Hmmm. Either load one-by-one or don't protect this bit. 
			// Whilst this is the longest section, I guess that because it is asynch, you won't get the Flash script timeout due
			// to a cumulative time, just individually is unlikely to happen.

			/*
			var tlc = _global.ORCHID.tlc;
			tlc.j = 0;
			tlc.proportion = 10;
			tlc.thisQB = thisQB;
			//tlc.bodyNode = bodyNode;
			tlc.numOfQuestions = numOfQuestions;
			tlc.exclusionTags = exclusionTags;
			tlc.matchingTags = matchingTags;
			//tlc.clusters = thisQB.clusters;
			tlc.maxLoop = bodyNode.childNodes.length;
			tlc.loadingCallback = checkQBloading;
			
			tlc.resumeLoop = function (firstTime) {
				var startTime = new Date().getTime();
				var j = this.j;
				var max = this.maxLoop;
				var timeLimit = this.timeLimit;
				var thisQB = this.thisQB;
				var bodyNode = thisQB.firstChild.childNodes[i];
				var numOfQuestions = this.numOfQuestions;
				var exclusionTags = this.exclusionTags;
				var matchingTags = this.matchingTags;
				myTrace("resumeLoop " + j + " of " + max);

				while (new Date().getTime()-startTime <= timeLimit && j<max && !firstTime) {
			*/
			for (var j in bodyNode.childNodes) {
				//myTrace("node=" + bodyNode.childNodes[j].nodeName);
				if (bodyNode.childNodes[j].nodeName == "question") {
					var questionNode = bodyNode.childNodes[j];
					var acceptQuestion = false;
					// First see if the tags in the question match any from selection criteria
					if (matchingTags == false) {
						//myTrace("no matching");
						// If no matching tags set, then all questions match
						acceptQuestion = true;
					} else {
						//myTrace("tags " + matchingTags.language);
						var theseTags = new Object();
						for (var k in questionNode.childNodes) {
							if (questionNode.childNodes[k].nodeName == "tags") {
								var theseTags = questionNode.childNodes[k].attributes;
								break;
							}
						}
						//myTrace("this question tagged with lang=" + theseTags.language);
						if (theseTags != new Object()) {
							for (var k in matchingTags) {
								//myTrace("looking to match " + k + "=" + matchingTags[k]);
								for (var m in theseTags) {
									//myTrace("against " + m + "=" + theseTags[m]);
									// Later you will want to allow pattern matching
									if ((k.toLowerCase() == m.toLowerCase()) && 
										(matchingTags[k].toLowerCase() == theseTags[m].toLowerCase())) {
										//myTrace("matched!");
										acceptQuestion = true;
										break;
									}
								}
								// Success matching any tag is enough
								if (acceptQuestion) break;
							}
						}
					}
					//myTrace("accept=" + acceptQuestion);
					// Next see if the tags in the question match any from exclusion criteria
					if (exclusionTags == false) {
						//myTrace("nothing to exclude");
					} else {
						//myTrace("tags " + exclusionTags.status);
						var theseTags = new Object();
						for (var k in questionNode.childNodes) {
							if (questionNode.childNodes[k].nodeName == "tags") {
								var theseTags = questionNode.childNodes[k].attributes;
								break;
							}
						}
						//myTrace("this question tagged with status=" + theseTags.status);
						if (theseTags != new Object()) {
							for (var k in exclusionTags) {
								for (var m in theseTags) {
									if (k.toLowerCase() == m.toLowerCase() &&
										exclusionTags[k].toLowerCase() == theseTags[m].toLowerCase()) {
										//myTrace("excluded!");
										acceptQuestion = false;
										break;
									}
								}
								// Success matching any tag is enough
								if (!acceptQuestion) break;
							}
						}
					}
					//myTrace("accept=" + acceptQuestion);
					if (!acceptQuestion) {
						// Now, we remove the question node, but what about related fields etc?
						myTrace("remove question");
						questionNode.removeNode();
					} else {
						numOfQuestions++;
						// Once you have accepted this question, see if it is using
						// clusters.
						if (questionNode.attributes["cluster"] != undefined) {
							thisQB.clusters[numOfQuestions]=questionNode.attributes["cluster"];
						}
					}
				}
			//	j++;
			}
				/*
				if (j < max) {
					myTrace("not finished qb load loop yet");
					this.j = j;
					//this.updateProgressBar((j/max) * this.proportion); // this part of the process is x% of the time consuming bit
					//myTrace("ppOP progress bar inc % by " + Number((j/max) * this.proportion));
					this.controller.incPercentage((j/max) * this.proportion);
				} else if (j >= max || max == undefined) {
					myTrace("finished qb load loop");
					this.j = max+1; // just in case this is run beyond the limit
					//this.updateProgressBar(this.proportion); // this part of the process is 50% of the time consuming bit
					//myTrace("ppOS progress bar % to " + Number(this.startProportion + this.proportion));
					//myTrace("ppOS progress bar set % to " + Number(this.startProportion + this.proportion));
					this.controller.setPercentage(this.proportion + this.startProportion);
					//myTrace("kill resume loop");
					delete this.resumeLoop;
					this.controller.stopEnterFrame();
					//myTrace("% at end of this part of display " + this.controller.getPercentage());
					
					// Anything you didn't filter out is left in the body at this point
					thisQB.numOfQuestions = numOfQuestions;
					myTrace("got " + numOfQuestions + " questions from qb " + idx);
				
					this.loadingCallBack();
					if (this.controller.getPercentage() >= 100) {
						this.controller.setEnabled(false);
					}
				}		
				// v6.3.5 Slight change to where the onEnterFrame is started from
				// firstTime is only set if you come into the loop manually rather than from the tlc
				if (firstTime) {
					//myTrace("kick off enterFrame");
					this.controller.startEnterFrame();
				}
			}
			// finally start off the looping (with a firstTime flag if using tlc)
			myTrace("call to resumeLoop, proportion=" + tlc.proportion);
			//tlc.controller.setLabel("display");
			tlc.controller.setEnabled(true);
			if (tlc.proportion > 0) {
				myTrace("start tlc loop");
				// v6.4.2.4 Should you overwrite the start proportion to the current real one, or use one set in the tlc?
				if (tlc.startProportion == undefined || tlc.startProportion < 0) {
					tlc.startProportion = tlc.controller.getPercentage();
				}
				tlc.resumeLoop(true);
			} else {
				// v6.3.5 See comment about timing problem - give them 10 seconds to display this bit!!
				// Or eventually make it a tlc based one, which means you need a callback and synchronicity
				//tlc.timeLimit = 10000;
				tlc.startProportion = tlc.controller.getPercentage();
				tlc.resumeLoop();
			}
			*/
			// Anything you didn't filter out is left in the body at this point
			thisQB.numOfQuestions = numOfQuestions;
			myTrace("can use " + numOfQuestions + " questions from qb " + idx);
			
			// Since there can only be one body, once you found it skip out
			// May have to skip this due to the tlc loop - not critical.
			break;			
		}		
	}
	// Trigger an event to see if all qbanks have been loaded
	// This is now run as the tlc callback
	this.checkQBloading();
}
// Simply check to see if all qbanks have reported that they are loaded.
// Once they are, trigger an event to select questions.
testNS.checkQBloading = function() {
	//myTrace("QBLoading");
	for (var i in this.qbHolder) {
		if (!this.qbHolder[i].loaded) {
			return;
		}
	}
	var nowTime = new Date().getTime();
	myTrace("loading took " + Number(nowTime - _global.ORCHID.startTime));
	_global.ORCHID.startTime = nowTime;
	// If you have not kicked out, then all qb are loaded.
	// So time to select the questions that we will use
	this.selectQuestions();
}
// This is the function that randomly chooses questions from those available
testNS.selectQuestions = function() {
	//myTrace("selectQuestions");
	// How many do we want in total?
	var reallocate = 0;
	var qbRequested = 0;
	var totalRequested = this.templateInfo.requestedQuestions;
	// v6.4.2.8 In an ideal world, you would merge all qb from one unit together so that you can allocate the questions
	// chosen evenly across units, rather than across all qbs. At present, if one unit has twice as many qb files (irrespective
	// of the number of questions in them), then this unit will get proportionally more questions allocated to it.
	
	// If there were no requests for individual numbers from particular qbanks, split the total between them
	// the later reallocation will cope with spare numbers.
	// v6.5.3 If you have 10 qb and want 5 questions, this numPerQB will be 0
	for (var i in this.qbHolder) {
		var thisQB = this.qbHolder[i];
		//myTrace("qb[" + i + "].requestedQuestions=" + thisQB.requestedQuestions);
		if (thisQB.requestedQuestions <= 0) {
			thisQB.requestedQuestions = Math.floor(totalRequested / this.qbHolder.length);
		}
		//myTrace("qb[" + i + "].requestedQuestions=" + thisQB.requestedQuestions);
	}
	
	// Go through each qb to see if there are enough to satisfy initial request
	for (var i in this.qbHolder) {
		// count all requested ones
		var thisQB = this.qbHolder[i];
		qbRequested += thisQB.requestedQuestions;
		thisQB.excess = thisQB.numOfQuestions - thisQB.requestedQuestions;
		//myTrace(thisQB.id + ": excess=" + thisQB.excess);
		if (thisQB.excess < 0) {
			reallocate+= -thisQB.excess;
		}
	}
	// Are there more in the overall number than the subtotals?
	//myTrace("totalRequested=" + totalRequested + " qbRequested=" + qbRequested);
	reallocate += totalRequested - qbRequested;
	myTrace("reallocate=" + reallocate);
	// Any that need to be reallocated?
	if (reallocate > 0) {
		var numFromEachQB = Math.floor(reallocate / this.qbHolder.length);
		//myTrace("numFromEach=" + numFromEachQB);
		for (var i in this.qbHolder) {
			var thisQB = this.qbHolder[i];
			if (thisQB.excess >= numFromEachQB) {
				thisQB.requestedQuestions += numFromEachQB;
				thisQB.excess -= numFromEachQB;
				reallocate -= numFromEachQB;
			} else {
				thisQB.requestedQuestions += thisQB.excess;
				thisQB.excess = 0;
				reallocate -= thisQB.excess;
			}
		}
		// Then the rest - if any. If your total number of q was less than the qbs, you will have not set any yet.
		// So this will randomly pull them now - which is why you can get 3 from 1 qb and none from others.
		// To solve this we could build a list of the qb and take from that until we have enough;
		// We can't assume that every qb will have the excess left to soak up a question, so build the list for all.
		var leftOverSelected = _global.ORCHID.root.objectHolder.getRandomNumbers(1, this.qbHolder.length, this.qbHolder.length);
		var leftOverChoice = 0;
		//myTrace("excess list=" + leftOverSelected.toString());
		while (reallocate > 0 && leftOverChoice<this.qbHolder.length) {
			//myTrace("left over=" + reallocate + " take from " + leftOverChoice);
			//var randomChoice = Math.round((this.qbHolder.length-1) * Math.random());
			var randomChoice = leftOverSelected[leftOverChoice];
			var thisQB = this.qbHolder[randomChoice];
			if (thisQB.excess > 0) {
				leftOverSelected.push(randomChoice);
				thisQB.requestedQuestions++;
				thisQB.excess--;
				reallocate--;
			}
			leftOverChoice++;
		}
	} else {
		// Need to think about how to reduce if requested numbers don't add up.
	}
	
	// Are there any dependency factors to take into account? The rules are that
	// filtering takes place before dependencies are taken into account. And then
	// the number of questions will not be altered.
	var dependencies = this.templateInfo.selectionCriteria.dependencies;
	var keepClustersTogether = (dependencies.keepClustersTogether=="true") ? true : false;	
	var keepSequencing = (dependencies.keepSequencing=="true") ? true : false;	
	var keepQBTogether = (dependencies.keepQBanksTogether=="true") ? true : false;	

	// v6.5.3 This is a longish loop, so protect it with tlc
	// So now we know how many questions to take from each question bank, work out
	// which ones and then go and get them.
	var tlc = _global.ORCHID.tlc;
	tlc.proportion = 50;
	tlc.startProportion = tlc.getPercentage();
	tlc.qbHolder = this.qbHolder;
	tlc.maxLoop = this.qbHolder.length;
	// v6.5.3 Ahhh, switch to tlc and loop goes from i=0 to max, but the original was max to 0!
	// So change the while loop on i to go max to 0
	//tlc.i = 0;
	tlc.i = tlc.maxLoop-1;
	// Whilst you can pass this, you seem to lose your scope when it runs if called from tlc
	tlc.selectionCallBack = this.combineQuestions;
	tlc.scope = this;
	tlc.dependencies = dependencies;
	tlc.keepClustersTogether = keepClustersTogether;	
	tlc.keepSequencing = keepSequencing;	
	tlc.keepQBTogether = keepQBanksTogether;	
	
	tlc.resumeLoop = function (firstTime) {
		var startTime = new Date().getTime();
		var i = this.i;
		var max = this.maxLoop;
		var timeLimit = this.timeLimit;
		var dependencies = this.dependencies;
		var keepClustersTogether = this.keepClustersTogether;	
		var keepSequencing = this.keepSequencing;	
		var keepQBTogether = this.keepQBanksTogether;	
		//var thisQB = this.thisQB;
		//myTrace("resumeLoop " + i + " of " + max);

		// v6.5.3 Ahhh, switch to tlc and loop goes from i=0 to max, but the original was max to 0!
		// So change the while loop on i to go max to 0
		//while (new Date().getTime()-startTime <= timeLimit && i<max && !firstTime) {
		while (new Date().getTime()-startTime <= timeLimit && i>=0 && !firstTime) {
	
		//for (var i in this.qbHolder) {
			var thisQB = this.qbHolder[i];
			//myTrace("pick questions, requested=" + thisQB.requestedQuestions + " from " + thisQB.numOfQuestions);
			var questionNumbers = _global.ORCHID.root.objectHolder.getRandomNumbers(0,thisQB.numOfQuestions-1,thisQB.requestedQuestions);
			// v6.5.3 Debug by fixing the questions to be chosen (only works if choosing one question per qb)
			// questionNumbers = [2];
			// v6.5.3 If you don't want any questions from this qb, just skip this bit
			if (questionNumbers.length==0) {
				thisQB.questionXML = new XML();
			} else {
				// v6.4.3 If you want keepSequencing or keepClustersTogether, you should order this list of questionNumbers now.
				myTrace("from " + thisQB.id + " take " + questionNumbers);
				
				// modify this list if any questions in it are part of groups
				// This could get very complex trying to ensure that you don't skew the randomness
				// too much by the clustering. And if all your questions are in clusters, it could be 
				// very difficult trying to fit them all in. 
				// So, for GEPT, let simply try to group clusters together IF they have been selected.
				// But then what is the point in that, unless you are going to remove the picture from
				// the second one!
				/*
				for (var j in questionNumbers) {
					var thisNum = questionNumbers[j];
					var thisClusterNum = thisQB.clusters[thisNum];
					if (thisClusterNum) {
						// You have found the first question from a cluster, start a new list
						var newQuestionNumbers = [thisNum];
						for (var k in thisQB.clusters) {
							if (thisQB.clusters[k] == thisClusterNum) {
								newQuestionNumbers.push(k);
							}
						}
						// So that now has all this cluster together at the front
						// Fill up the rest with non-clustered questions.
						var k=0;
						while (newQuestionNumbers.length <= thisQB.requestedQuestions &&
							   k<questionNumbers.length) {
							if (thisQB.clusters[questionNumbers[k]]==undefined) {
								newQuestionNumbers.push(questionNumbers[k]);
							}
						}
					}
				}
				*/
				// routine to read the question bank XML and extract each question
				// v6.5.3 Make sure you keep scope due to tlc
				//myTrace("bodynodeidx=" + thisQB.bodyNodeIDX);
				thisQB.questionXML = this.scope.getRandomQuestions(i, questionNumbers);
				//myTrace("tlc:" + thisQB.questionXML.toString());
				// v6.5.3 Ahhh, switch to tlc and loop goes from i=0 to max, but the original was max to 0!
				// So change the while loop on i to go max to 0
				//i++
			}
			i--;
		}
		//if (i < max) {
		if (i >= 0) {
			//myTrace("not finished qb load loop yet");
			this.i = i;
			//this.updateProgressBar((j/max) * this.proportion); // this part of the process is x% of the time consuming bit
			//myTrace("test progress bar inc % by " + Number((i/max) * this.proportion));
			this.controller.incPercentage(((max-i)/max) * this.proportion);
		//} else if (i >= max || max == undefined) {
		} else if (i < 0 || i == undefined) {
			//myTrace("finished selection loop");
			//this.i = max+1; // just in case this is run beyond the limit
			this.i = -1; // just in case this is run beyond the limit
			//this.updateProgressBar(this.proportion); // this part of the process is 50% of the time consuming bit
			//myTrace("ppOS progress bar % to " + Number(this.startProportion + this.proportion));
			//myTrace("test progress bar set % to " + Number(this.startProportion + this.proportion));
			this.controller.setPercentage(this.proportion + this.startProportion);
			//myTrace("kill resume loop");
			delete this.resumeLoop;
			this.controller.stopEnterFrame();
			//myTrace("% at end of this part of display " + this.controller.getPercentage());
			
			this.selectionCallBack(this.scope);
			if (this.controller.getPercentage() >= 100) {
				this.controller.setEnabled(false);
			}
		}		
		// v6.3.5 Slight change to where the onEnterFrame is started from
		// firstTime is only set if you come into the loop manually rather than from the tlc
		if (firstTime) {
			//myTrace("kick off enterFrame");
			this.controller.startEnterFrame();
		}
	}
	// finally start off the looping (with a firstTime flag if using tlc)
	//myTrace("call to resumeLoop, proportion=" + tlc.proportion);
	//tlc.controller.setLabel("display");
	//tlc.controller.setLabel("build test");
	//tlc.controller.setEnabled(true);
	if (tlc.proportion > 0) {
		//myTrace("start tlc loop,controller.visible=" + tlc.controller._visible);
		// v6.4.2.4 Should you overwrite the start proportion to the current real one, or use one set in the tlc?
		if (tlc.startProportion == undefined || tlc.startProportion < 0) {
			tlc.startProportion = tlc.controller.getPercentage();
		}
		tlc.resumeLoop(true);
	} else {
		// v6.3.5 See comment about timing problem - give them 10 seconds to display this bit!!
		// Or eventually make it a tlc based one, which means you need a callback and synchronicity
		//tlc.timeLimit = 10000;
		tlc.startProportion = tlc.controller.getPercentage();
		tlc.resumeLoop();
	}
	
	//var nowTime = new Date().getTime();
	//myTrace("select took " + Number(nowTime - _global.ORCHID.startTime));
	//_global.ORCHID.startTime = nowTime;
	// Finally you can combine the information from each question bank
	// now done by callback
	//this.combineQuestions();
}
// This function takes one qb and builds an XML object with questions
// (and related stuffs) from that qb. 
// questionNumbers is 0 based to match XML nodes
// v6.5.3 Since this is now called from tlc, scope is lost. So call it from tlc.scope
testNS.getRandomQuestions = function(idx, questionNumbers) {
	var thisQB = this.qbHolder[idx];
	//myTrace("gRQ for idx=" + thisQB.bodyNodeIDX);
	var bodyNode = thisQB.firstChild.childNodes[thisQB.bodyNodeIDX];
	// Figure out where the question nodes are (just in case not contiguous)
	// But this is most likely to simply be 0 to 19 (or however many questions)
	//myTrace("getRandomQuestions qidStart=" + this.questionIDStart + " mediaidStart=" + this.randomMediaIDStart);
	var questionNodes = new Array();
	for (var j=0; j<bodyNode.childNodes.length; j++) {
		if (bodyNode.childNodes[j].nodeName == "question") {
			questionNodes.push(j);
		}
	}
	// To get them matching up, reverse the order of questionNodes
	//questionNodes.reverse();
	
	// Now match chosen questions with their respective nodes
	// Following code copied from RandomExercise.as (v6.4.2 code)	
	var returnXML = new XML();
	var newNode = returnXML.createElement("exercise");
	returnXML.appendChild(newNode);
	returnCurrNode = returnXML.firstChild;
	var newNode = returnXML.createElement("body");
	returnCurrNode.appendChild(newNode);
	returnCurrNode = returnCurrNode.firstChild;
	tempStringArray = new Array();
	//Flash treat a node containing CDATA in XML as an element, so such node should be converted to string first.
	//After that, the fields are searched in the string.
	for (var j=0; j<questionNumbers.length; j++) {
		newNode = bodyNode.childNodes[questionNodes[questionNumbers[j]]].cloneNode(true);
		tempStringArray.push(newNode.toString());
		myTrace("pull question " + questionNumbers[j]);
	}
	var fieldArray = new Array();
	var questionArray = new Array();
	for(j = 0; j < tempStringArray.length; j++) {
		var myNode = tempStringArray[j];
		index1 = 0;
		index2 = 0;
		found = true;
		while(found) {
			index1 = myNode.indexOf("[", index2);
			index2 = myNode.indexOf("]", index1);
			// I found a field in this question
			if(index1 > -1 && index2 > -1) {
				//myTrace("found field: " + myNode.substring(index1, index2+2));
				tempFieldID = myNode.substring(index1 + 1, index2);
				// doing a findReplace will change several occurences is old and new fields are at a crossover point!
				//tempStringArray[i] = findReplace(tempStringArray[i], "[" + tempFieldID + "]", "[" + _global.ORCHID.randomFieldIDStart + "]");
				myNode = myNode.substring(0,index1+1) + this.randomFieldIDStart + myNode.substring(index2);
				fieldArray.push( {oldID:tempFieldID, newID:this.randomFieldIDStart++} );
				//myTrace(" changed to: " + myNode.substring(index1-2, index2+2));
				//index1++;
			} else {
				found = false;
			}
		}
		newNode = new XML(myNode);
		//myTrace("new question node=" + myNode);
		//newNode = new XML();
		//newNode.parseXML(tempStringArray[i]);
		//v6.4.3 Add/overwrite questionIDs and link up the old ID with the new one
		newNode.firstChild.attributes.id = this.questionIDStart;
		//myTrace("questionID=" + newNode.firstChild.attributes.questionID + " is j=" + j);
		questionArray.push({oldID:j, newID:this.questionIDStart++})
		returnCurrNode.appendChild(newNode.firstChild);
		//myTrace("q=" + newNode.firstChild.toString());
	}
	// Following line just to let variables copied from old code match up
	var currNode = bodyNode;
	returnCurrNode = returnXML.firstChild.firstChild;
	var groupArray = new Array();
	previousGroupID = -1;
	for (j = 0; j < fieldArray.length; j++) {
		for (i = 0; i < currNode.childNodes.length; i++) {
			if (currNode.childNodes[i].nodeName == "field" && currNode.childNodes[i].attributes.id == fieldArray[j].oldID) {
				var idIndex = _global.ORCHID.root.objectHolder.lookupArrayItem(groupArray, currNode.childNodes[i].attributes.group, "oldID");
				if (idIndex == -1) {
					//if we use returnCurrNode.appendChild(currNode.childNodes[i]),
					//the whole node childNodes[i] will be removed from currNode.
					//So we have to clone the node first.
					newNode = currNode.childNodes[i].cloneNode(true);
					newNode.attributes.group = this.randomGroupIDStart;
					newNode.attributes.id = fieldArray[j].newID;
					groupArray.push({oldID: currNode.childNodes[i].attributes.group,
								newID: this.randomGroupIDStart++});
					//myTrace("set oldID=" + currNode.childNodes[i].attributes.group);
					returnCurrNode.appendChild(newNode);
				} else {
					newNode = currNode.childNodes[i].cloneNode(true);
					newNode.attributes.group = groupArray[idIndex].newID;
					newNode.attributes.id = fieldArray[j].newID
					returnCurrNode.appendChild(newNode);
				}
				break;
			}
		}			
	}
	// Also take the media nodes if relevant (meaning question based)
	for (i = 0; i < currNode.childNodes.length; i++ ) {
		if (	currNode.childNodes[i].nodeName == "media" &&
			currNode.childNodes[i].attributes.type.indexOf("q:")==0) {
			// v6.4.3 In 6.4.1.5 APP outputs question based audio with id=question number
			// But if I also want to add question based images, it will clash to have them both
			// with the same ID. So I should use unique IDs and have an anchor attribute. For
			// now if it is not there, use the ID (which will apply to all APP generated exercises)
			if (currNode.childNodes[i].attributes.anchor == undefined) currNode.childNodes[i].attributes.anchor = currNode.childNodes[i].attributes.id;
			for (var j=0; j<questionNumbers.length; j++) {
				// question based media should shift to using anchor to set question ID
				// rather than using regular id. But presently it points to question
				// numbers being 1 based.
				//if (currNode.childNodes[i].attributes.id == questionNumbers[j]+1) {
				if (currNode.childNodes[i].attributes.anchor == questionNumbers[j]+1) {
					//myTrace("old q#=" + currNode.childNodes[i].attributes.anchor + " media.id=" + currNode.childNodes[i].attributes.id);
					newNode = currNode.childNodes[i].cloneNode(true);
					// get groups as renumbered from above
					var idIndex = _global.ORCHID.root.objectHolder.lookupArrayItem(questionArray, j, "oldID");
					//myTrace("lookup oldid=" + currNode.childNodes[i].attributes.id + " gives newID=" + groupArray[idIndex].newID);
					// Media IDs just need to be unique amongst themselves
					//newNode.attributes.id = groupArray[idIndex].newID;
					newNode.attributes.id = this.randomMediaIDStart++;					
					// overwrite anchor as an attribute (we should really be leaving id alone)
					newNode.attributes.anchor = questionArray[idIndex].newID;
					returnCurrNode.appendChild(newNode);
					//myTrace("in qb; media id=" + newNode.attributes.id + " j=" + j + " anchor=" + newNode.attributes.anchor + " file=" + newNode.attributes.filename);
					//myTrace("media=" + newNode.toString());
					break;
				}
			}
		}
	}
	//currNode = QuestionXML.firstChild;
	currNode = thisQB.firstChild;
	returnCurrNode = returnXML.firstChild;
	for(i = 0; i < currNode.childNodes.length; i++ ) {
		if(currNode.childNodes[i].nodeName == "feedback") {
			for(j = 0; j < groupArray.length; j++) {
				if(currNode.childNodes[i].attributes.id == groupArray[j].oldID) {
					newNode = currNode.childNodes[i].cloneNode(true);
					newNode.attributes.id = groupArray[j].newID;
					returnCurrNode.appendChild(newNode);
					break;
				}
			}
		}
	}
	
	return returnXML;
}

// v6.5.3 Pass the scope just in case you have been called from tlc
//testNS.combineQuestions = function() {
testNS.combineQuestions = function(scope) {
	//myTrace("combineQuestions");
	// v6.5.3 Use scope or default if it wasn't passed
	if (scope == undefined) scope = this;
	// You already have the main skeleton of the exercise which came from the template
	// So add in a body node, and then add questions within that
	var returnXML = scope.ExerciseStructure;
	//myTrace("returnXML looks like: " + returnXML.toString());
	var returnCurrNode = returnXML.firstChild;
	var newNode = returnXML.createElement("body");
	returnCurrNode.appendChild(newNode);
	returnCurrNode = returnCurrNode.lastChild;

	// Note: I think that at this point you could just mix up the order of the question
	// nodes in order to randomise delivery from different qbanks. You need
	// to use questionID rather than implied question number to link question based
	// media to the right place. Fields and feedback should be fine.
	var dependencies = scope.templateInfo.selectionCriteria.dependencies;
	var keepClustersTogether = (dependencies.keepClustersTogether=="true") ? true : false;	
	var keepSequencing = (dependencies.keepSequencing=="true") ? true : false;	
	var keepQBTogether = (dependencies.keepQBanksTogether=="true") ? true : false;	
	// v6.4.3 Make a shuffled array of index numbers that we can use to reorder the questions and reset numbers/groups etc
	var shuffledIndex = new Array();
	var totalAvailable=0;
	// Count up how many we have actually tried to get (better to measure dimensions of each questionNodes array)
	for (i in scope.qbHolder) {
		totalAvailable+=scope.qbHolder[i].requestedQuestions;
	}
	for (var i=0; i<totalAvailable; i++) {
		shuffledIndex.push(i);
	}
	// Are you going to shuffle the order?
	if (keepQBTogether || keepSequencing || keepClustersTogether) {
	} else {
		//_global.ORCHID.root.objectHolder.shuffle(holdQuestionNodes);
		_global.ORCHID.root.objectHolder.shuffle(shuffledIndex);
		//myTrace("shuffled=" + shuffledIndex.toString());
	}

	var holdQuestionNodes = new Array();
	// Read through all the qbanks to get the questions, according to the shuffled order
	for (i in scope.qbHolder) {
		var currNode = scope.qbHolder[i].questionXML.firstChild;
		//myTrace("cQ" + i + ":" + currNode.toString());
		for (var j in currNode.childNodes) {
			if (currNode.childNodes[j].nodeName == "body") {
				var bodyIndex = j;
				break;
			}
		}
		// What about a whole new way of doing it? See below.
		/*
		currNode = currNode.childNodes[bodyIndex];
		//As returnCurrNode.appendChild(currNode.childNodes[0] will remove the node from currNode,
		//we have to store the nodeLength first and use "0" as the index in the for loop.
		var nodeLength = currNode.childNodes.length;
		for (var j = 0; j < nodeLength; j++) {
			if (currNode.childNodes[0].nodeName == "question") {
				returnCurrNode.appendChild(currNode.childNodes[0]);
				//myTrace("question=" + currNode.childNodes[0].toString());
			} else {
				break;
			}
		}
		*/
		var bodyNode = currNode.childNodes[bodyIndex];
		for (var j=0; j < bodyNode.childNodes.length; j++) {
			if (bodyNode.childNodes[j].nodeName == "question") {
				// So hold this node in an array to make it easy to randomise if desired before
				// adding to the XML you are creating
				holdQuestionNodes.push(bodyNode.childNodes[j]);
				//myTrace("question=" + bodyNode.childNodes[j].toString());
			}
		}
	}
	var nowTime = new Date().getTime();
	myTrace("combine took " + Number(nowTime - _global.ORCHID.startTime));
	_global.ORCHID.startTime = nowTime;
	
	//for (var i=0; i<holdQuestionNodes.length; i++){
	//	returnCurrNode.appendChild(holdQuestionNodes[i]);
	//}
	if (shuffledIndex.length != holdQuestionNodes.length) {
		// panic!
		myTrace("XXX question numbers don't match up");
	}
	// After shuffling, create a lookup table to see the new positions
	var shuffledLookup = new Array([0]);
	for (var i=0; i<shuffledIndex.length; i++){
		//myTrace("add qnode=" + shuffledIndex[i]);
		// update the question id for this node that you are rearranging
		var newQuestionID = Number(i)+1;
		holdQuestionNodes[shuffledIndex[i]].attributes.id=newQuestionID;
		shuffledLookup[Number(shuffledIndex[i])+1] = newQuestionID;
		returnCurrNode.appendChild(holdQuestionNodes[shuffledIndex[i]]);
	}
	//myTrace("shuffled index=" + shuffledIndex.toString());
	//myTrace("shuffled lookup=" + shuffledLookup.toString());

	// This is the end of the question nodes - so add an empty paragraph to get space at the bottom
	//var emptyParagraph = new XML('<paragraph style="normal" type="text" x="0" y="+12" width="400" height="12"><![CDATA[<p>oooo</p></TEXTFORMAT>]]></paragraph>');
	var emptyParagraph = new XML('<paragraph style="normal" height="12" width="400" y="+24" x="12" ><![CDATA[<TEXTFORMAT LEADING="0"><P></P></TEXTFORMAT>]]></paragraph>');
	returnCurrNode.appendChild(emptyParagraph.firstChild); 

	// add fields
	var holdFieldNodes = new Array();
	for (i in scope.qbHolder) {
		currNode = scope.qbHolder[i].questionXML.firstChild;
		for (var j in currNode.childNodes) {
			if (currNode.childNodes[j].nodeName == "body") {
				var bodyIndex = j;
				break;
			}
		}
		currNode = currNode.childNodes[bodyIndex];
		nodeLength = currNode.childNodes.length;
		//ar - I don't quite understand why we break here. Nor really how the appendChild 
		// alters the currNode at all! But it does appear to work fine. I suppose it is pulling
		// them from the original and changing the stack as it goes. And the break will only
		// work if we are sure that all field nodes are together. ????
		// v6.5.3 Why is this looping on j, but using [0] in the loop?
		for (var j = 0; j < nodeLength; j++) {
			if (currNode.childNodes[0].nodeName == "field") {
				// Change the group ID in the field
				//myTrace("group found " + currNode.childNodes[0].attributes.group + " change to " + shuffledLookup[Number(currNode.childNodes[0].attributes.group)]);
				currNode.childNodes[0].attributes.group = shuffledLookup[Number(currNode.childNodes[0].attributes.group)];
				//myTrace("TGM:combineQuestions tabOrder=" + currNode.childNodes[0].attributes.group);
				currNode.childNodes[0].attributes.tabOrder = currNode.childNodes[0].attributes.group;
				//myTrace("field:" + currNode.childNodes[0].toString());
				returnCurrNode.appendChild(currNode.childNodes[0]);
			} else {
				break;
			}
		}
	}
	var nowTime = new Date().getTime();
	myTrace("shuffle took " + Number(nowTime - _global.ORCHID.startTime));
	_global.ORCHID.startTime = nowTime;
	
	// add media
	for (i in scope.qbHolder) {
		currNode = scope.qbHolder[i].questionXML.firstChild;
		for (var j in currNode.childNodes) {
			if (currNode.childNodes[j].nodeName == "body") {
				var bodyIndex = j;
				break;
			}
		}
		currNode = currNode.childNodes[bodyIndex];
		nodeLength = currNode.childNodes.length;
		for (var j = 0; j < nodeLength; j++) {
			if (currNode.childNodes[0].nodeName == "media") {
				//myTrace("xml:media anchor=" + currNode.childNodes[0].attributes.anchor + " id=" + currNode.childNodes[0].attributes.id);
				//myTrace("media found anchor " + currNode.childNodes[0].attributes.anchor + " change to " + shuffledLookup[currNode.childNodes[0].attributes.anchor]);
				currNode.childNodes[0].attributes.anchor = shuffledLookup[currNode.childNodes[0].attributes.anchor];
				//myTrace("media:" + currNode.childNodes[0].toString());
				returnCurrNode.appendChild(currNode.childNodes[0]);
			} else {
				break;
			}
		}
	}
	// v6.4.3 Maybe here we would take exercise based media (from the template, not the qbs)
	for (var i in scope.templateInfo.mediaNodes) {
		returnCurrNode.appendChild(scope.templateInfo.mediaNodes[i]);
	}
	//myTrace("after media:" + returnCurrNode.toString());
	returnCurrNode = returnXML.firstChild;	

	//var nowTime = new Date().getTime();
	//myTrace("media took " + Number(nowTime - _global.ORCHID.startTime));
	//_global.ORCHID.startTime = nowTime;
	// add feedback
	// Unfortunately, if you shuffled between banks, the order here will be out.
	// It doesn't matter for individual question feedback, but it does for delayed then whole window feedback
	// You should not shuffle the original questionNodes, but get an array of numbers and use that to 
	// reorder the questionNodes and this feedbackNodes in the same way.
	// No - this is not the problem. The display will order by groupID before doing delayed feedback.
	// v6.4.3 If the template says we want score based feedback, then don't worry about any question based feedback,
	// just copy from the template.
	if (scope.templateInfo.scoreBasedFeedback) {
		myTrace("combineQuestions for scoreBasedFB");
		// No need to do anything as the feedback node is automatically copied from the template
		//var copyNode = this.ExerciseStructure.firstChild.childNodes[this.templateInfo.feedbackIndex];
		//returnCurrNode.appendChild(copyNode);
	} else {
		myTrace("combineQuestions.check for qbased fb");
		for (i in scope.qbHolder) {
			currNode = scope.qbHolder[i].questionXML.firstChild;
			nodeLength = currNode.childNodes.length;
			for (var j = 0; j < nodeLength; j++) {
				if (currNode.childNodes[0].nodeName == "feedback") {
					//myTrace("feedback found " + currNode.childNodes[0].attributes.id + " change to " + shuffledLookup[currNode.childNodes[0].attributes.id]);
					currNode.childNodes[0].attributes.id = shuffledLookup[currNode.childNodes[0].attributes.id];
					returnCurrNode.appendChild(currNode.childNodes[0]);
				} else {
					currNode.childNodes[0].removeNode();
				}
			}
		}
	}
	
	// Clear up all memory that has been used
	scope.qbHolder = undefined;
	
	// Send the XML to the callback function
	//myTrace(returnXML);
	var nowTime = new Date().getTime();
	myTrace("finally took " + Number(nowTime - _global.ORCHID.startTime));
	_global.ORCHID.startTime = nowTime;
	scope.callback(returnXML);
	
}
