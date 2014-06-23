//output a XML object including numOfQuestion random questions from QuestionXML which is also a XML object
//The output XML object is looked like the following
//<exercise>
//	<body>
//		<question>
//		<field>
//	</body>
//	<feedback>
//<exercise>
//The field id and group id will be adjust according to _global.ORCHID.randomGroupIDStart
//and _global.ORCHID.randomFieldIDStart.
// This function is called with all the questions from one exercise, plus the num of questions that
// we have decided we want from this exercise.
getRandomQuestion = function(QuestionXML, numOfQuestions) {
	// no point doing anything if numOfQuestions is zero!
	if (numOfQuestions == 0) return new XML();
		
	var currNode = QuestionXML.firstChild;
	
	for(var i = 0; i < currNode.childNodes.length; i++) {
		if(currNode.childNodes[i].nodeName == "body") {
			var bodyIndex = i;
			break;
		}
	}
	currNode = currNode.childNodes[bodyIndex];
	for(var i = 0; i < currNode.childNodes.length; i++) {
		if(currNode.childNodes[i].nodeName == "question") {
			var questionStartIndex = i;
			break;
		}
	}
	for(var i = questionStartIndex; i < currNode.childNodes.length; i++) {
		if(currNode.childNodes[i].nodeName <> "question") {
			var questionEndIndex = i - 1;
			break;
		}
	}
	var randomIndex = new Array();
	if(currNode.childNodes.length > numOfQuestions) {
		randomIndex = getRandomNumbers(questionStartIndex, questionEndIndex, numOfQuestions);
	} else {
		for(var i = questionStartIndex; i <= questionEndIndex; i++) {
			randomIndex.push(i);
			// v6.2 If there aren't enough questions, at least randomise the order
			shuffle(randomIndex);
		}
	}
	//myTrace("random questions " + randomIndex.toString() + " from exercise " + QuestionXML.attributes.name);
	//for (var i = 0; i < randomIndex.length; i++) {
		//trace("random question no. : " + randomIndex[i]);
	//}
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
	for(i = 0; i < randomIndex.length; i++) {
		newNode = currNode.childNodes[randomIndex[i]].cloneNode(true);
		tempStringArray.push(newNode.toString());
	}
	var fieldArray = new Array();
	for(i = 0; i < tempStringArray.length; i++) {
		var myNode = tempStringArray[i];
		index1 = 0;
		index2 = 0;
		found = true;
		while(found) {
			index1 = myNode.indexOf("[", index2);
			index2 = myNode.indexOf("]", index1);
			// I found a field in this question
			if(index1 > -1 && index2 > -1) {
				//trace("found field: " + myNode.substring(index1-2, index2+2));
				tempFieldID = myNode.substring(index1 + 1, index2);
				// doing a findReplace will change several occurences is old and new fields are at a crossover point!
				//tempStringArray[i] = findReplace(tempStringArray[i], "[" + tempFieldID + "]", "[" + _global.ORCHID.randomFieldIDStart + "]");
				myNode = myNode.substring(0,index1+1) + _global.ORCHID.randomFieldIDStart + myNode.substring(index2);
				fieldArray.push( {oldID:tempFieldID, newID:_global.ORCHID.randomFieldIDStart++} );
				//trace(" changed to: " + myNode.substring(index1-2, index2+2));
				//index1++;
			} else {
				found = false;
			}
		}
		newNode = new XML(myNode);
		//trace("new question node=" + myNode);
		//newNode = new XML();
		//newNode.parseXML(tempStringArray[i]);
		returnCurrNode.appendChild(newNode.firstChild);
	}
	//for(i = 0; i < fieldArray.length; i++) {
	//	trace("Old field id=" + fieldArray[i].oldID + " new field id=" + fieldArray[i].newID);
	//}
	currNode = QuestionXML.firstChild.childNodes[bodyIndex];
	returnCurrNode = returnXML.firstChild.firstChild;
	var groupArray = new Array();
	previousGroupID = -1;
	// v6.2 The order of loops here causes the question and group to get the wrong
	// way round as you are going through the current XML first, so if the questions
	// had their order swapped (6, 2), then the fields in 2 would still be found first
	// and therefore get the lower group number.
	//for(i = 0; i < currNode.childNodes.length; i++) {
	//	if(currNode.childNodes[i].nodeName == "field") {
	//		for(j = 0; j < fieldArray.length; j++) {
	//			if(currNode.childNodes[i].attributes.id == fieldArray[j].oldID) {
	for (j = 0; j < fieldArray.length; j++) {
		for (i = 0; i < currNode.childNodes.length; i++) {
			if (currNode.childNodes[i].nodeName == "field" && currNode.childNodes[i].attributes.id == fieldArray[j].oldID) {
				var idIndex = lookupArrayItem(groupArray, currNode.childNodes[i].attributes.group, "oldID");
				if(idIndex == -1) {
					//if we use returnCurrNode.appendChild(currNode.childNodes[i]),
					//the whole node childNodes[i] will be removed from currNode.
					//So we have to clone the node first.
					newNode = currNode.childNodes[i].cloneNode(true);
					newNode.attributes.group = _global.ORCHID.randomGroupIDStart;
					newNode.attributes.id = fieldArray[j].newID;
					groupArray.push({oldID: currNode.childNodes[i].attributes.group,
								newID: _global.ORCHID.randomGroupIDStart++});
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
		
	//for(i = 0; i < groupArray.length; i++) {
	//	trace("Old group id : " + groupArray[i].oldID + " New group id: " + groupArray[i].newID);
	//}
	currNode = QuestionXML.firstChild;
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

getRandomExercise = function(validExerciseIDs, validUnitIDs, numOfQuestions) {
	// Note: howls - this is called from creationHolder where it does the loading
	// for one exercise but leaves this to do the loading for many. So we will
	// have to duplicate a lot of the code. Streuth.
	// Actually, it is not that bad as this ends up calling creationHolder once we have in the exercise XML
	//trace("in getRandomExercise");
	var randomExercise;
	// v6.4.2.7 This will be an object now, even if only 1 item
	//if(typeof validExerciseIDs == "object") {
	if(validExerciseIDs.length>0) { 
		var xmlArray = new Array();
		var randomXMLArray = new Array();
		// For each valid exercise, load it...
		for(var i = 0; i < validExerciseIDs.length; i++) {
			//var fileName = _global.ORCHID.paths.root + _global.ORCHID.paths.exercises + validExerciseIDs[i] + ".xml";
			// v6.4.2.7 CUP merge. Use filename rather than action. This already has the full filename.
			// We need to know the enabledFlag to be able to get the right folder for the xml. But that isn't part of validExerciseIDs!
			// *****
			// This will not work with authored random question banks.
			// It is now passing the whole scaffoldItem
			// *****
			//var fileName = _global.ORCHID.paths.exercises + validExerciseIDs[i] + ".xml";
			if (validExerciseIDs[i].enabledFlag & _global.ORCHID.enabledFlag.edited){
				//myTrace("which & with " + _global.ORCHID.enabledFlag.edited);
				// gh#869 case sensitive
				var fileName = _global.ORCHID.paths.editedExercises + validExerciseIDs[i].fileName;
			} else {
				var fileName = _global.ORCHID.paths.exercises + validExerciseIDs[i].fileName;
			}
			myTrace("load file=" + fileName);
			//myTrace("try to read file=" + fileName);
			var ExerciseStructure = new XML();
			ExerciseStructure.fileName = fileName
			ExerciseStructure.ignoreWhite = true;
			ExerciseStructure.onLoad = function(success) {
				if (success) {
					xmlArray.push(this);
					// then once all exercises are loaded, choose which questions to use
					if(xmlArray.length == validExerciseIDs.length) {
						//trace("All random XMLs loaded successfully!");
						var allocatedNum = allocateNumOfRandomQuestion(xmlArray, numOfQuestions);
						for(i = 0; i < xmlArray.length; i++) {
							randomXMLArray.push(getRandomQuestion(xmlArray[i], allocatedNum[i]));
						}
						var templateXML = getTemplate(xmlArray[0]);
						var thisRandomExerciseXML = combineRandomQuestion(randomXMLArray, templateXML,  validUnitIDs);
						
						//_global.ORCHID.randomExerciseXML = combineRandomQuestion(randomXMLArray, templateXML,  validUnitIDs);
						//trace(_global.ORCHID.randomExerciseXML);
						// AM: Sometimes calling the function processExerciseXML by LocalConnection does not work.
						// so I call processExerciseXML directly
						// 6.0.2.0 remove connection
						//_global.ORCHID.root.creationHolder.myConnection.processExerciseXML(thisRandomExerciseXML);
						// v6.3.6 Merge creation into main
						//_global.ORCHID.root.creationHolder.creationNS.processExerciseXML(thisRandomExerciseXML);
						_global.ORCHID.root.mainHolder.creationNS.processExerciseXML(thisRandomExerciseXML);
						//sender = new LocalConnection();
						//sender.send("creationModule", "processExerciseXML", thisRandomExerciseXML);
						//sender.send("creationModule", "processExerciseXML");
						//delete sender;
					}
				} else {
					myTrace("Sorry, the XML load failed with code " + this.status + " for file " + this.fileName);
				}
			}
			// v6.3.4 Use anti-cache for the random tests too
			if(_global.ORCHID.online){
			   var cacheVersion = "?version=" + new Date().getTime();
			}else{
			   var cacheVersion = ""
			}
			//myTrace("load question bank: " + fileName + cacheVersion);
			ExerciseStructure.load (fileName + cacheVersion);
			//ExerciseStructure.load (fileName);
		}
	} else {
		//var fileName = _global.ORCHID.paths.root + _global.ORCHID.paths.exercise + validExerciseIDs + ".xml";
		// v6.4.2.7 CUP merge. Use filename rather than action. This already has the full filename.
		// We need to know the enabledFlag to be able to get the right folder for the xml. But that isn't part of validExerciseIDs!
		// *****
		// This will not work with authored random question banks.
		// *****
		//var fileName = _global.ORCHID.paths.exercises + validExerciseIDs[i] + ".xml";
		if (validExerciseIDs.enabledFlag & _global.ORCHID.enabledFlag.edited){
			//myTrace("which & with " + _global.ORCHID.enabledFlag.edited);
			// gh#869 case sensitive
			var fileName = _global.ORCHID.paths.editedExercises + validExerciseIDs.fileName;
		} else {
			var fileName = _global.ORCHID.paths.exercises + validExerciseIDs.fileName;
		}
		var ExerciseStructure = new XML();
		ExerciseStructure.ignoreWhite = true;
		ExerciseStructure.onLoad = function(success) {
			if(success) {
				//trace("random XML loaded successfully!");
				var tempXML = getRandomQuestion(this, numOfQuestions);
				//trace(tempXML);
				xmlArray = new Array(tempXML);
				 var thisRandomExerciseXML = combineRandomQuestion(xmlArray, this, validUnitIDs);
				//_global.ORCHID.randomExerciseXML = combineRandomQuestion(xmlArray, this, validUnitIDs);
				//trace(_global.ORCHID.randomExerciseXML);
				// AM: Sometimes calling the function processExerciseXML by LocalConnection does not work.
				// so I call processExerciseXML directly
				// 6.0.2.0 remove connection
				//_global.ORCHID.root.creationHolder.myConnection.processExerciseXML(thisRandomExerciseXML);
				// v6.3.6 Merge creation into main
				//_global.ORCHID.root.creationHolder.creationNS.processExerciseXML(thisRandomExerciseXML);
				_global.ORCHID.root.mainHolder.creationNS.processExerciseXML(thisRandomExerciseXML);
				//sender = new LocalConnection();
				//sender.send("creationModule", "processExerciseXML", thisRandomExerciseXML);
				//sender.send("creationModule", "processExerciseXML");
				//delete sender;
			} else {
				myTrace("Sorry, the XML load failed with code " + this.status);
			}
		}
		if(_global.ORCHID.online){
		   var cacheVersion = "?version=" + new Date().getTime();
		}else{
		   var cacheVersion = ""
		}
		//myTrace("load question bank: " + fileName + cacheVersion);
		ExerciseStructure.load (fileName + cacheVersion);
	}	
}

//Allocate the number of questions to be chosen from each exercise XML object.
//The input parameters are an Array containing the exercise XML objects and the total number of questions to be chosen.
//The function will return an Array containing the number of questions to be chosen from each exercise XML object.
allocateNumOfRandomQuestion = function(xmlArray, numOfQuestion) {
	//trace("numOfQuestions: " + numOfQuestion);
	//totalQuestion = 0;
	questionCount = new Array();
	allocatedNum = new Array();
	for(var i = 0; i < xmlArray.length; i++) {
		var tempNum = countNumOfQuestion(xmlArray[i]);
		questionCount.push(tempNum);
		//trace("questionCount " + i + " = " + tempNum);
		//totalQuestion += tempNum;
	}
	averageInt = Math.floor(numOfQuestion / xmlArray.length);
	//trace("average: " + averageInt);
	numLeft = numOfQuestion % xmlArray.length;
	//trace("left: " + numLeft);
	// first try to take the average number from each exercise, if there are enough
	for(i = 0; i < questionCount.length; i++) {
		if(averageInt > questionCount[i]) {
			allocatedNum.push(questionCount[i]);
			numLeft += averageInt - questionCount[i];
		} else {
			allocatedNum.push(averageInt);
		}
	}
	// then take the number left over sequentially from the exercises (one each)
	// until all used up
	while (numLeft > 0) {
		//trace("numLeft = " + numLeft);
		var numOfEmpty = 0;
		for(i = 0; i < questionCount.length; i++) {
			if(questionCount[i] > allocatedNum[i]) {
				allocatedNum[i]++;
				numLeft--;
				if(numLeft == 0) {
					break;
				}
			} else {
				numOfEmpty++;
			}
		}
		if(numOfEmpty == questionCount.length) {
			break;
		}
	}
	return allocatedNum;
}

//count the total number of quesitons in a XML object
countNumOfQuestion = function(ExerciseXML) {
	var currNode = ExerciseXML.firstChild;
	var numOfQuestion = 0;
	
	for(var i = 0; i < currNode.childNodes.length; i++) {
		if(currNode.childNodes[i].nodeName == "body") {
			var bodyIndex = i;
			break;
		}
	}
	currNode = currNode.childNodes[bodyIndex];
	for(var i = 0; i < currNode.childNodes.length; i++) {
		if(currNode.childNodes[i].nodeName == "question") {
			numOfQuestion++;
		}
	}
	return numOfQuestion;
}

//combine the question xml object in xmlArray and the template object in templateXML
//output a complete random exercise object
combineRandomQuestion = function(xmlArray, templateXML, validUnitIDs) {
	// EGU - valid unitIDs is now an array of itemIDs of the parents (language areas)
	/*
	var caption = new Array();
	for (i = 0; i < validUnitIDs.length; i++) {
		var item = _global.ORCHID.course.scaffold.getObjectByID(validUnitIDs[i]);
		trace("look up the caption for item " + validUnitIDs[i] + " it is " + item.caption);
		caption.push(item.caption);
	}
	*/
	/*
	validUnitIDs.sort();
	sortedUnitIDs = new Array();
	for(i = 0; i < validUnitIDs.length; i++) {
		if(i != 0) {
			if(validUnitIDs[i] != validUnitIDs[i - 1]) {
				sortedUnitIDs.push(validUnitIDs[i]);
			}
		} else {
			sortedUnitIDs.push(validUnitIDs[i]);
		}
	}
	*/
	returnXML = new XML();
	var newNode = returnXML.createElement("exercise");
	returnXML.appendChild(newNode);
	returnCurrNode = returnXML.firstChild;
	returnCurrNode.attributes.id = 0;
	//v6.3.5 Need to use the new settings node rather than (or as well as) the old mode
	returnCurrNode.attributes.mode = 48; // marking+feedback buttons + delayed question based feedback + 
								// only show wrong feedback
	// EGU change the title
	//returnCurrNode.attributes.name = "Questions from unit(s) " + sortedUnitIDs.join(", ");
	// But this might be very long so truncate it(mind you, the text field might be no word wrap
	// in which case don't worry).
	// No point setting the exercise name here as everything else uses the scaffold (menu) to get it!
	// So move this bit of code over to creation.fla where you put together the fake scaffold entry
	// that goes with this XML
	//returnCurrNode.attributes.name = "Test from " + caption.join(", ");
	returnCurrNode.attributes.name = "Test";

	//v6.3.5 Need to use the new settings node rather than (or as well as) the old mode
	// Also note that a little further down you hard code the node number for body - now changed from 1 to 2
	// AGU wants all tests to be multiPart
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU/AGU") >= 0) { 
		var settingsXML = new XML('<settings><marking/><feedback groupBased="true"/><buttons/><exercise multiPart="true"/><misc/></settings>');
	} else {
		var settingsXML = new XML('<settings><marking/><feedback groupBased="true"/><buttons/><exercise/><misc/></settings>');
	}
	returnCurrNode.appendChild(settingsXML.firstChild);
	
	//trace("attr.name=" + returnCurrNode.attributes.name);
	//var newNode = returnXML.createElement("title");
	//returnCurrNode.appendChild(newNode);
	
	// Note: where do we add something to the title?
	// change this (it should come from literals)
	//myTrace("rurbric=" + _global.ORCHID.literalModelObj.getLiteral("testRubric", "labels"));
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) { 
		var titleXML = new XML('<title><paragraph x="0" y="+6" width="500" height="0" style="headline">' +
						   '<![CDATA[<TEXTFORMAT leading="0">'+
						   '<font face="Verdana" size="13" color="#FFFFFF"><b>' + 
						   _global.ORCHID.literalModelObj.getLiteral("testRubric", "labels") +
						   '</b></font></TEXTFORMAT>]]></paragraph></title>');
	} else {
		var titleXML = new XML('<title><paragraph x="13" y="+6" width="500" height="0" style="headline">' +
						   '<![CDATA[<TEXTFORMAT leading="0">'+
						   '<font face="Verdana" size="13" color="#' + _global.ORCHID.CorrectText.rawColor +'"><b>' + 
						   _global.ORCHID.literalModelObj.getLiteral("testRubric", "labels") +
						   '</b></font></TEXTFORMAT>]]></paragraph></title>');
						   //'Please select or type the correct answer.' +
		//myTrace("rubric should be " + _global.ORCHID.literalModelObj.getLiteral("testRubric", "labels"));
	}
	returnCurrNode.appendChild(titleXML.firstChild);
	//myTrace(returnCurrNode.toString());
	// Perhaps we could create a QuestionBankTitle.xml document and read that in?
	//var myTitle = new XML();
	//myTitle.load(_global.ORCHID.paths.exercises + "QuestionBankTitle.xml");
	
	var newNode = returnXML.createElement("body");
	returnCurrNode.appendChild(newNode);
	//v6.3.5 Had to change hard coded node number, see above comment about settings node
	returnCurrNode = returnCurrNode.childNodes[2];
	for(i = 0; i < xmlArray.length; i++) {
		var currNode = xmlArray[i].firstChild;
		for(var j = 0; j < currNode.childNodes.length; j++) {
			if(currNode.childNodes[j].nodeName == "body") {
				var bodyIndex = j;
				break;
			}
		}
		currNode = currNode.childNodes[bodyIndex];
		//As returnCurrNode.appendChild(currNode.childNodes[0] will remove the node from currNode,
		//we have to store the nodeLength first and use "0" as the index in the for loop.
		var nodeLength = currNode.childNodes.length;
		for(var j = 0; j < nodeLength; j++) {
			if(currNode.childNodes[0].nodeName == "question") {
				returnCurrNode.appendChild(currNode.childNodes[0]);
				//myTrace("question=" + currNode.childNodes[0].toString());
			} else {
				break;
			}
		}
	}
	for(i = 0; i < xmlArray.length; i++) {
		currNode = xmlArray[i].firstChild;
		currNode = currNode.childNodes[bodyIndex];
		nodeLength = currNode.childNodes.length;
		for(var j = 0; j < nodeLength; j++) {
			if(currNode.childNodes[0].nodeName == "field") {
				returnCurrNode.appendChild(currNode.childNodes[0]);
			} else {
				break;
			}
		}
	}
	returnCurrNode = returnXML.firstChild;
	for(i = 0; i < xmlArray.length; i++) {
		currNode = xmlArray[i].firstChild;
		nodeLength = currNode.childNodes.length;
		for(var j = 0; j < nodeLength; j++) {
			if(currNode.childNodes[0].nodeName == "feedback") {
				//trace("feedback found " + currNode.childNodes[0].attributes.id);
				returnCurrNode.appendChild(currNode.childNodes[0]);
			} else {
				currNode.childNodes[0].removeNode();
			}
		}
	}
	returnCurrNode = returnXML.firstChild;
	returnCurrNode.appendChild(templateXML.firstChild);
	returnXML.xmlDecl = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
	return returnXML;
}

//get the template object from an exercise xml object
getTemplate = function(xmlObj) {
	var currNode = xmlObj.firstChild;
	var returnXML = new XML();
	for(var i = 0; i < currNode.childNodes.length; i++) {
		if(currNode.childNodes[i].nodeName == "template") {
			trace("template found");
			var newNode = currNode.childNodes[i].cloneNode(true);
			returnXML.appendChild(newNode);
			return returnXML;
		}
	}
}
