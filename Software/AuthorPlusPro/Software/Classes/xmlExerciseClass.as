import Classes.xmlFunc;

class Classes.xmlExerciseClass extends Classes.xmlFunc {
	
	var textformatHead:String;
	var textformatTail:String;
	var fieldNodes:XMLNode;
	var questionAudioNodes:XMLNode;
	var mediaCnt:Number;
	// v6.4.2.7 Adding urls
	var urlCnt:Number;
	var photos:Object;
	// v6.4.3 Add id to paragraphs for handmaking
	var paraCnt:Number;
	// AR v6.4.2.5 Can we at least preset some tab positions?
	var tabPresets:String;
	
	function xmlExerciseClass() {
		XMLfile = "";
		textformatHead = "<TEXTFORMAT LEADING=\"0\"><P ALIGN=\"LEFT\"><FONT FACE=\"Verdana\" SIZE=\"12\">";
		textformatTail = "</FONT></P></TEXTFORMAT>";
		fieldNodes = this.createElement("fieldNodes");
		questionAudioNodes = this.createElement("questionAudioNodes");
		mediaCnt = 1000;
		urlCnt=0;
		tabPresets = "50,100,150,200,250,300,350,400";
	}
	
	function formURL(courseFolder:String, subFolder:String, filename:String) : Void {
		// v6.4.4, RL: Change the path into MGS Path
		// v6.4.3 Change name from paths.userPath to paths.content
		//XMLfile = _global.NNW.paths.userPath + "/" + courseFolder + "/" + subFolder + "/Exercises/" + filename;
		//XMLfile = _global.addSlash(_global.NNW.paths.content) + _global.addSlash(courseFolder) + _global.addSlash(subFolder) + _global.addSlash("Exercises") + filename;
		//myTrace("(xmlExerciseClass) - control._enableMGS = "+control._enableMGS);
		// check if it's an MGS exercise.
		// if have MGS, then set the enabledFlag into edited.
		
		//myTrace("(xmlExerciseClass) - is this edited? = "+isEdited());
		//myTrace("(xmlExerciseClass) - MGS enable? = "+_global.NNW.control._enableMGS);
		//XMLfile = _global.addSlash(_global.NNW.paths.MGSPath) + _global.addSlash(courseFolder) + _global.addSlash(subFolder) + _global.addSlash("Exercises") + filename;
		//myTrace("(xmlExerciseClass) - xml file from path : "+XMLfile);

		// AR v6.4.2.5 This will have been sorted out earlier, just use MGSPath as it will default to content
		// NO - this depends on whether this exercise has already been edited or not as to whether we should look in the MGS or the original folder
		// Since this function is used whether you are reading or writing, I'll need to change before I save. Which I do in saveExercise.
		//myTrace("xmlExerciseClass.data.currentExercise.enabledFlag = "+control.data.currentExercise.enabledFlag);
		if (_global.NNW.control.data.currentExercise.enabledFlag & _global.NNW.control.enabledFlag.MGS) {
			XMLfile = _global.addSlash(_global.NNW.paths.MGSPath) + _global.addSlash(courseFolder) + _global.addSlash(subFolder) + _global.addSlash("Exercises") + filename;
		} else {
			XMLfile = _global.addSlash(_global.NNW.paths.content) + _global.addSlash(courseFolder) + _global.addSlash(subFolder) + _global.addSlash("Exercises") + filename;
			_global.myTrace("load this exercise from original folder");
		} 
		//} else {
		//	myTrace("(xmlExerciseClass) - xml file from path : "+XMLfile);
		//}
		
		//myTrace("exercise.formURL." + XMLfile);
		if (_global.NNW.control.__server) {
			XMLfile = _global.replace(XMLfile, "\\", "/");
			XMLfile = _global.replace(XMLfile, "//", "/");
		}
		//myTrace("xmlExerciseClass.XMLfile:"+XMLfile);
	}

	// AR v6.4.2.5 This doesn't seem to be called anymore
	//function isEdited() : Boolean {
		// AR v6.4.2.5 use numbers
		/*
		var n:Number = int(control.data.currentUnit.enabledFlag);
		if (n>32) {n-=32};
		if (n>16) {
			return true;
		} else {
			return false;
		}
		//myTrace ("(xmlExercise) - _enableMGS = " + control._enableMGS);
		//return control._enableMGS;
		*/
		/*
		if (_global.NNW.control.data.currentUnit.enabledFlag & _global.NNW.control.enabledFlag.MGS) {
			return true;
		} else {
			return false;
		}
		*/
	//}

	function loadXML() : Void {
		super.loadXML("Exercise");
	}
	
	function onLoadingSuccess() : Void {
		myTrace("Exercise xml loaded, eF=" + _global.NNW.control.data.currentExercise.enabledFlag);
		
		var rootNode = this.firstChild;
		if (rootNode.nodeName=="exercise") {
			// exercise found, read it
			// v6.4.2.6 AR If this is an original exercise and the author is working in an MGS
			if (	!(_global.NNW.control.data.currentExercise.enabledFlag&_global.NNW.control.enabledFlag.MGS) 
				&& _global.NNW.control._enableMGS) {
				_global.myTrace("change all user media nodes to original");
				//_global.myTrace("from: " + rootNode.toString());
				changeMediaNodesLocation(rootNode);
				//_global.myTrace("to: " + rootNode.toString());
			}
			control.readExerciseXML();
		} else {
			// file corrupt or no exercises, go to onLoadingError
			onLoadingError();
		}
	}
	
	// v6.2.4.6 A function to change the media nodes that are not shared or a specific URL to be 'original' when an exercise
	// is copied from the original content into the MGS
	function changeMediaNodesLocation(rootNode) : Void {
		//_global.myTrace("cMNL nodeName=" + rootNode.nodeName);
		if (rootNode.nodeName == "media") {
			if (rootNode.attributes.location == "" || rootNode.attributes.location == undefined) {
				_global.myTrace("changed node for file " + rootNode.attributes.filename);
				rootNode.attributes.location = "original";
			}
		}
		for (var i in rootNode.childNodes) {
			if (rootNode.childNodes[i].hasChildNodes) {
				changeMediaNodesLocation(rootNode.childNodes[i]);
			}
		}
	}
	
	function onLoadingError() : Void {
		control.onLoadingError();
		// v0.3, DL: it's no point to generate a default exercise, if the file is corrupted, there's nothing we can do
		// no file found, so add exercise
		//addExerciseToXML();
		// set initial saving to true (to trigger reading the newly generated file)
		//initSave = true;
		// generate the xml file
		//control.generateExerciseXML();
	}
	
	function onSavingSuccess() : Void {
		myTrace("onSavingSuccess.Exercise xml saved.");
		if (initSave) {
			// v0.3, DL: this won't happen, but leave it here anyways
			// toggle initial saving to false
			initSave = false;
			/* update progress bar */
			control.view.setProgressOnPBar(2, 2);
			//_global.myTrace("*** setting 2/2 in xmlExercise");
			loadXML();
		} else {
			/* update progress bar */
			control.view.setProgressOnPBar(1, 2);
			//_global.myTrace("*** setting 1/2 in xmlExercise");
			
			// v6.4.0.1, DL: don't generate menu.xml just add/edit the node
			// this'll be handled in control.addExerciseToMenu() & control.onComparedXmlAddExercise()
			/* get data format them into XML */
			//control.addUnitsToXML();
			
			// v6.4.0.1, DL: after that we'll have to generate unit xml but not now
			// handled in control.onComparedXmlAddExercise()
			/* generate the XML file */
			//control.generateUnitXML();
			
			/* update progress bar */
			//control.view.setProgressOnPBar(2, 2);
			control.addExerciseToMenu();
		}
		var ex = control.data.currentExercise;
		// v0.5.2, DL: this is now a saved exercise, no longer newly created
		ex.newlyCreated = false;
		// v0.5.2, DL: this is now saved, reset noChange to true
		ex.noChange = true;
	}
	
	/* add root node (with the exercise name as name) */
	function addRootNode() : Void {
		var rootNode:XMLNode = this.createElement("exercise");
		rootNode.attributes.id = "0";	// this is always 0!
		this.appendChild(rootNode);
	}
	
	/* add exercise to this from dataExercise object */
	function addExerciseToXML(ex:Object) : Void { 
		resetDoc();			/* reset rootNode */
		ex.parseOutput();		/* parse the output in text & questions */
		mediaCnt = 1000;		/* reset media count */
		paraCnt = 1;		// para id reset
		urlCnt = 0;		// para id reset
		var p = this.firstChild;	/* get reference to rootNode (p) */
		
		/* add caption */
		// v6.4.2 Allow apostrophe and ampersand in exercise name
		//v6.4.2.1 Try escaping the name instead of changing characters.
		//ex.caption = _global.replace(ex.caption, '"', " ");
		//ex.caption = _global.replace(ex.caption, "'", " ");
		//ex.caption = _global.replace(ex.caption, "<", " ");
		//ex.caption = _global.replace(ex.caption, ">", " ");
		//ex.caption = _global.replace(ex.caption, "&", " ");
		p.attributes.name = escape(ex.caption);
		
		p.attributes.type = ex.exerciseType;
		p.attributes.version = "6.5.0.1";	// v0.12.0, DL: version no. of exercise xml files are now v6.4
		var n:XMLNode;
		
		/* v0.16.1, DL: set the embedded video position to image position */
		if (ex.image.filename=="" && ex.videos[0].filename!="" && ex.videos[0].mode=="1") {
			ex.image.position = ex.videos[0].position;
		}
		
		/* v0.16.1, DL: clear up quesitonAudioNodes */
		/* v6.4.2.1 AR: Later we will allow any media to be question based, not just audio */
		if (questionAudioNodes.hasChildNodes()) {
			for (var i in questionAudioNodes.childNodes) {
				questionAudioNodes.childNodes[i].removeNode();
			}
		}
		questionAudioNodes = this.createElement("questionAudioNodes");
		
		/* add fields in fieldNodes */
		if (fieldNodes.hasChildNodes()) {
			for (var i in fieldNodes.childNodes) {
				fieldNodes.childNodes[i].removeNode();
			}
		}
		fieldNodes = this.createElement("fieldNodes");
		addFieldNode(ex);
		/* add settings node */
		n = addNodeWithName(p, "settings");
		addSettingsAttr(n, ex.settings);
		/* add title node */
		n = addNodeWithName(p, "title");
		
		// v6.5.0.1 Yiu fixing the new line disappear on student side problem
		_global.NNW.screens.txts.txtTitle2.html	= true;
		//addNodeWithAttr(n, "paragraph", ex.title.attr, ex.title.value);
		addNodeWithAttr(n, "paragraph", ex.title.attr, _global.NNW.screens.txts.txtTitle2.text);
		_global.NNW.screens.txts.txtTitle2.html	= false;
		// End v6.5.0.1 Yiu fixing the new line disappear on student side problem
		
		/* add noscroll node for drag and drop exercises */
		if (ex.exerciseType=="DragOn"||ex.exerciseType=="DragAndDrop") {
			n = addNodeWithName(p, "noscroll");
			addDragFields(n, ex);
		} else if (ex.exerciseType=="Countdown") {
			n = addNodeWithName(p, "noscroll");
			addStoryboardNoscrollSection(n, ex);
		}
		/* add body node */
		n = addNodeWithName(p, "body");
		
		/* v0.6.0, DL: for split screen, show picture on top */
		if (ex.settings.misc.splitScreen) {
			addPictureNode(n, ex, "250x165");
			// v6.4.1.4, DL: DEBUG - if split-screen, embed video should be added first
			if (ex.videos.length>0) {
				for (var i=0; i<ex.videos.length; i++) {
					if (ex.videos[i].mode=="1") {
						addVideoNode(n, ex.videos[i], ex.image.position, ex.settings.misc.splitScreen);
					}
				}
			}
		}
		
		/* add paragraphs in body */
		/* add drag fields into paragraphs before questions/text */
		switch (ex.exerciseType) {
		case "MultipleChoice" :
		case "Quiz" :
		case "Stopgap" :
		case "DragAndDrop" :
		case "Analyze" :
		// v6.4.3 Add new exercise type, item based drop-down
		case "Stopdrop" :
		case _global.g_strQuestionSpotterID:	// v6.5.1 Yiu add bew exercise type question spotter
		case _global.g_strBulletID:	// v6.5.1 Yiu add bew exercise type question spotter
			var qBased = true;
			
			/* add paragraphs in body & then put back fields into body */
			addQuestionNode(n, ex);
			break;
		case "Dropdown" :
		case "Cloze" :
		case "DragOn" :
		case "Countdown" :
		case "TargetSpotting" :	// v0.16.0, DL: new exercise type
		case "Proofreading" :	// v0.16.0, DL: new exercise type
		case "Presentation" :
		case _global.g_strErrorCorrection:	// v6.5.1 Yiu 6-5-2008 New exercise type error correction
		default :
			var qBased = false;
			
			/* v0.16.0, DL: image position */
			// Yiu v6.5.1 Remove Banner
			if (!ex.settings.misc.splitScreen) {
				if (ex.image.position=="top-left") {
					ex.text.attr.x = "223";
				} /* else if (ex.image.position=="banner") {
					ex.text.attr.x = "118";
				} */ else {	// default, top-right
					ex.text.attr.x = "12";
				}
			}
			// End Yiu v6.5.1 Remove Banner
			
			/* v0.15.0, DL: split text into paragraphs for better performance in student side */
			//addNodeWithAttr(n, "paragraph", ex.text.attr, ex.text.value);
			// v6.4.2.5 AR This no longer works as we have added tabstops, which are in the TEXTFORMAT node
			//_global.myTrace("xmlEx.ex.text " + ex.text.value);
			//var pArray = ex.text.value.split("<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\">");
			var pArray = ex.text.value.split("<TEXTFORMAT");
			var pAttr = ex.text.attr;
			for (var i=1; i<pArray.length; i++) {
				var pValue = pArray[i];
				//pValue = _global.replace(pValue, "</P></TEXTFORMAT>", "");
				if (pValue!=undefined) {
					// v6.4.2.5 Do you really need to add &nbsp if the paragraph is otherwise empty?
					// Try not doing this.
					//if (_global.NNW.screens.extractTextFromCDATA(pValue).length>0) {
					//	pValue = "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\">"+pValue+"</P></TEXTFORMAT>";
					//} else {
					//	pValue = "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\">&nbsp;</P></TEXTFORMAT>";
					//}
					pValue = "<TEXTFORMAT"+pValue;
					
					// if it's not the 1st paragraph, do not increment the y-pos
					// if it's the 1st paragraph, set y-pos to +16
					if (i>1) { pAttr.y = "+0"; } else {
						// v0.16.1, DL: for banner, move down the y-pos to +102
						// Yiu v6.5.1 Remove Banner
						/* if (ex.image.position=="banner") {
							pAttr.y = "+102";
						} else { */
							pAttr.y = "+16";
						//}
						// End Yiu v6.5.1 Remove Banner
					}
					
					// add the paragraph as a paragraph node
					addNodeWithAttr(n, "paragraph", pAttr, pValue);
				}
			}
			
			/* v0.12.0, DL: add some blank lines at the end of the body */
			// v6.4.2.5 AR - just add one with space before
			//for (var i=0; i<3; i++) {
				// v6.4.2.7 Why is the leading set for an empty paragraph?
				//addNodeWithAttr(n, "paragraph", {x:"12", y:"+50", width:"400", height:"0"}, "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\"><FONT SIZE=\"2\"></FONT></P></TEXTFORMAT>");

				addNodeWithAttr(n, "paragraph", {x:"12", y:"+50", width:"400", height:"0"}, "<TEXTFORMAT LEADING=\"0\"><P ALIGN=\"LEFT\"><FONT SIZE=\"2\"></FONT></P></TEXTFORMAT>");
			//}
			
			for (var i=0; i<fieldNodes.childNodes.length; i++) {
				if (fieldNodes.childNodes[i].attributes.type!="i:drag") {
					n.appendChild(fieldNodes.childNodes[i].cloneNode(true));
				}
			}
			break;
		}
		//_global.myTrace("xmlEx.addExtoXML " + n.toString());
		
		/* add medias in body */
		if (!ex.settings.misc.splitScreen) {
			addPictureNode(n, ex, "165x250");
		}
		
		if (ex.audios.length>0) {
			for (var i=0; i<ex.audios.length; i++) {
				addAudioNode(n, ex.audios[i], ex.settings.misc.splitScreen, ex.image.position);
			}
		}
		
		// v6.4.1.4, DL: DEBUG - if split-screen, embed video should be added first
		// v0.16.1, DL: add video
		if (ex.videos.length>0) {
			for (var i=0; i<ex.videos.length; i++) {
				if (!ex.settings.misc.splitScreen || ex.videos[i].mode!="1") {
					addVideoNode(n, ex.videos[i], ex.image.position, ex.settings.misc.splitScreen);
				}
			}
		}
		
		// v6.4.2.7 Adding URLs
		// v6.5.1 Yiu fixing split screen URL wrong placement
		if (!ex.settings.misc.splitScreen) {
			if (ex.URLs.length>0) {
				for (var i=0; i<ex.URLs.length; i++) {
				//for (var i in ex.URLs) {
					_global.myTrace("xmlEx.addExtoXML url=" + ex.URLs[i].url);
					addURLNode(n, ex.URLs[i], ex.image.position, ex.settings.misc.splitScreen);
				}
			}
		}
		
		// v0.16.0, DL: add score-based feedback according to settings
		if (ex.settings.feedback.scoreBased) {
			addFeedbackHintNode("feedback", ex.scoreBasedFeedback, false);
		// v6.5.4.1 This is the only setting that uses different fb within a question
		} else if (!ex.settings.feedback.groupBased && ex.exerciseType=="Quiz") {
			addFeedbackHintNode("feedback", ex.differentFeedback, false);
		} else {
			/* add feedback nodes */
			// v6.4.1.6, DL: DEBUG - pass also questions for checking whether it is empty
			addFeedbackHintNode("feedback", ex.feedback, true, qBased, ex.question);
		}
		
		/* add hint nodes */
		// v6.4.1.6, DL: DEBUG - pass also questions for checking whether it is empty
		addFeedbackHintNode("hint", ex.hint, true, qBased, ex.question);
		
		/* v0.6.0, DL: for splitting screen, text is outside body */
		if (ex.settings.misc.splitScreen) {
			n = addNodeWithName(p, "texts");
			
			/* v0.15.0, DL: split text into paragraphs for better performance in student side */
			//addNodeWithAttr(n, "paragraph", ex.text.attr, ex.text.value);
			// v6.4.2.5 AR This no longer works as we have added tabstops, which are in the TEXTFORMAT node
			//_global.myTrace("xmlEx.ex.text " + ex.text.value);
			//var pArray = ex.text.value.split("<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\">");
			var pArray = ex.text.value.split("<TEXTFORMAT");
			// v0.16.1, DL: now not only Analyze has split-screen text, so we have to set attributes here
			// AR v6.4.2.5 tab presets
			var pAttr = {type:"text", x:"12", y:"+8", width:"282", height:"0", style:"normal", tabs:tabPresets, indent:"0"};	//ex.text.attr;
			for (var i=1; i<pArray.length; i++) {
				var pValue = pArray[i];
				//pValue = _global.replace(pValue, "</P></TEXTFORMAT>", "");
				if (pValue!=undefined) {
					// v6.4.2.5 Do you really need to add &nbsp if the paragraph is otherwise empty?
					// Try not doing this.
					//if (_global.NNW.screens.extractTextFromCDATA(pValue).length>0) {
					//	pValue = "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\">"+pValue+"</P></TEXTFORMAT>";
					//} else {
					//	pValue = "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\">&nbsp;</P></TEXTFORMAT>";
					//}
					pValue = "<TEXTFORMAT"+pValue;
					
					// if it's not the 1st paragraph, do not increment the y-pos
					// if it's the 1st paragraph, set y-pos to +16
					if (i>1) { pAttr.y = "+0"; } else { pAttr.y = "+16"; }
					
					// add the paragraph as a paragraph node
					addNodeWithAttr(n, "paragraph", pAttr, pValue);
				}
			}
			
			// v6.4.2.5 AR - just add one with space before
			//for (var i=0; i<3; i++) {
				// v6.4.2.7 Why is the leading set for an empty paragraph?
				//addNodeWithAttr(n, "paragraph", {x:"12", y:"+50", width:"282", height:"0"}, "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\"><FONT SIZE=\"2\"></FONT></P></TEXTFORMAT>");
				addNodeWithAttr(n, "paragraph", {x:"12", y:"+50", width:"282", height:"0"}, "<TEXTFORMAT LEADING=\"0\"><P ALIGN=\"LEFT\"><FONT SIZE=\"2\"></FONT></P></TEXTFORMAT>");
			//}
			
			/* v0.14.0, DL: if it's split screen then the fields in the text side should go to the text node instead of body node*/
			for (var i=0; i<fieldNodes.childNodes.length; i++) {
				if (fieldNodes.childNodes[i].attributes.type!="i:drag") {
					if (ex.text.value.indexOf("["+fieldNodes.childNodes[i].attributes.id+"]", 0)>-1) {
						n.appendChild(fieldNodes.childNodes[i].cloneNode(true));
					}
				}
			}
		}
		
		// v6.5.1 Yiu fixing split screen URL wrong placement
		if (ex.settings.misc.splitScreen) {
			if (ex.URLs.length>0) {
				for (var i=0; i<ex.URLs.length; i++) {
					_global.myTrace("xmlEx.addExtoXML url=" + ex.URLs[i].url);
					addURLNode(n, ex.URLs[i], ex.image.position, ex.settings.misc.splitScreen);
				}
			}
		}
		
		/* default template node */
		n = addNodeWithName(p, "template");
		addNodeWithAttr(n, "style", {name:"normal", font:"Verdana", size:"13", bold:"false", color:"0x000000", align:"left"});
		addNodeWithAttr(n, "style", {name:"headline", font:"Verdana", size:"13", bold:"true", color:"0x000000", align:"left"})
		ex.parseStringsBackToAtag();
	}
	function addNodeWithName(p:XMLNode, n:String) : XMLNode {
		var node:XMLNode = this.createElement(n);
		p.appendChild(node);
		return node;
	}
	function addNodeWithAttr(p:XMLNode, n:String, a:Object, v:String) : Void {
		var node:XMLNode = this.createElement(n);
		/* add nodeValue */
		if (v!=undefined && v.length>0) {
			if (n=="paragraph") {
				
				var cd:XMLNode = this.createElement("CDATA");
				node.appendChild(cd);
				var boldHead = (a.style=="headline") ? "<B>" : "";
				var boldTail = (a.style=="headline") ? "</B>" : "";
				v = _global.fixTags(v);
				var formattingHead = (v.substr(0, 1)=="<") ? "" : textformatHead;
				var formattingTail = (v.substr(0, 1)=="<") ? "" : textformatTail;
				var nv:XMLNode = this.createTextNode(formattingHead+boldHead+v+boldTail+formattingTail);
				cd.appendChild(nv);
				// v6.4.3 Add an id to each paragraph
				a.id = paraCnt++;
			} else {
				var nv:XMLNode = this.createTextNode(v);
				node.appendChild(nv);
			}
		}
		/* add attributes */
		for (var i in a) {
			node.attributes[i] = a[i];
		}
		/* append the node */
		p.appendChild(node);
	}
	function addSettingsAttr(n:XMLNode, s:Object) {
		/* create sub settings nodes */
		var markingNode:XMLNode = this.createElement("marking");
		var feedbackNode:XMLNode = this.createElement("feedback");
		var buttonsNode:XMLNode = this.createElement("buttons");
		var exerciseNode:XMLNode = this.createElement("exercise");
		var miscNode:XMLNode = this.createElement("misc");
		/* set attributes */
		// marking
		if (s.marking.instant==true) {markingNode.attributes.instant="true";}
		if (s.marking.overwriteAnswers==true) {markingNode.attributes.overwriteAnswers="true";}	// v0.16.0, DL: overwrite main answers for drags & gaps
		if (s.marking.noScore == true) { markingNode.attributes.noScore = "true"; }
		if (s.marking.test == true) // v6.4.1.2, DL: test mode in exercise
		{
			markingNode.attributes.test = "true";
			
			buttonsNode.attributes.progress="false";
			buttonsNode.attributes.scratchPad="false";
			buttonsNode.attributes.print="false";
			buttonsNode.attributes.hints="false";
		} else {
			markingNode.attributes.test = "false";
			
			buttonsNode.attributes.progress="true";
			buttonsNode.attributes.scratchPad="true";
			buttonsNode.attributes.print="true";
			buttonsNode.attributes.hints="true";
		}
		// feedback
		if (s.feedback.scoreBased==true) {feedbackNode.attributes.scoreBased="true";}
		if (s.feedback.neutral==true) {feedbackNode.attributes.neutral="true";}
		if (s.marking.instant!=true) {feedbackNode.attributes.wrongOnly="true";}
		if (s.feedback.groupBased==true) {feedbackNode.attributes.groupBased="true";}
		// buttons
		if (s.buttons.marking==false) {buttonsNode.attributes.marking="false";}
		if (s.buttons.feedback==false) {buttonsNode.attributes.feedback="false";}
		if (s.buttons.media==false) {buttonsNode.attributes.media="false";}
		if (s.buttons.rule==true) {buttonsNode.attributes.rule="true";}
		if (s.buttons.readingText==false) {buttonsNode.attributes.readingText="false";}
		if (s.buttons.showAnswer==false) {buttonsNode.attributes.showAnswer="false";}
		if (s.buttons.chooseInstant==true) {buttonsNode.attributes.chooseInstant="true";}
		if (s.buttons.recording==true) {buttonsNode.attributes.recording="true";}
					
		// v6.5.1 Yiu hidden progress, scratchPad, print and hints button when the exercise is a test
		
		/*
		if (	s.buttons.progress == false	&&
				s.buttons.progress != undefined){
			buttonsNode.attributes.progress="false";
		} else {
			buttonsNode.attributes.progress="true";
		} 
		if (	s.buttons.scratchPad == false	&&
				s.buttons.scratchPad != undefined){
			buttonsNode.attributes.scratchPad="false";
		} else {
			buttonsNode.attributes.scratchPad="true";
		}
		if (	s.buttons.print == false	&&
				s.buttons.print != undefined){
			buttonsNode.attributes.print="false";
		} else {
			buttonsNode.attributes.print="true";
		} 
		if (	s.buttons.hints == false	&&
				s.buttons.hints != undefined){
			buttonsNode.attributes.hints="false";
		} else {
			buttonsNode.attributes.hints="true";
		}  
		*/
		// End v6.5.1 Yiu hidden progress, scratchPad, print and hints button when the exercise is a test
		
		// exercise
		if (s.exercise.proofreading==true) {exerciseNode.attributes.proofreading="true";}
		if (s.exercise.hiddenTargets==true) {exerciseNode.attributes.hiddenTargets="true";}
		if (s.exercise.correctMistakes==true)	{exerciseNode.attributes.correctMistakes="true";}
		if (s.exercise.dragTimes==1) {exerciseNode.attributes.dragTimes=s.exercise.dragTimes.toString();}
		if (s.exercise.multipleTargets==true) {exerciseNode.attributes.multipleTargets="true";}
		if (s.exercise.countDown == true) { exerciseNode.attributes.countDown = "true"; }
		// v6.5.1 Yiu get rip of the same length gap slider which is not used
		//if (s.exercise.sameLengthGaps == "true") { exerciseNode.attributes.sameLengthGaps = "true"; } else if (Number(s.exercise.sameLengthGaps) > 0) { exerciseNode.attributes.sameLengthGaps = s.exercise.sameLengthGaps; }
		if (s.exercise.sameLengthGaps > 0){
			exerciseNode.attributes.sameLengthGaps = s.exercise.sameLengthGaps; 
		} else if (_global.NNW.screens.chbs.getChecked("chbSameLengthGaps") == true){ 
			exerciseNode.attributes.sameLengthGaps 	= "true"; 
		}
		// v6.5.1 Yiu new default gap length check box and slider 
		if (s.exercise.defaultLengthGaps == "true") { exerciseNode.attributes.defaultLengthGaps = "true"; } else if (Number(s.exercise.defaultLengthGaps) > 0) { exerciseNode.attributes.defaultLengthGaps = s.exercise.defaultLengthGaps; }
		// End v6.5.1 Yiu new default gap length check box and slider 
		if (s.exercise.matchCapitals==true) {exerciseNode.attributes.matchCapitals="true";}
		if (s.exercise.preview==true) {exerciseNode.attributes.preview="true";}	// v0.12.0, DL: show text before countdown
		if (s.exercise.proofreading==true) {exerciseNode.attributes.proofreading="true";}	// v0.16.0, DL: for proofreading
		// misc
		if (s.misc.timed>0) {miscNode.attributes.timed=s.misc.timed*60;}
		if (s.misc.splitScreen==true) {miscNode.attributes.splitScreen="true";}
		// v6.4.2.5 sound effects
		if (s.misc.soundEffects==true) {
			miscNode.attributes.soundEffects="true"
		} else {
			miscNode.attributes.soundEffects="false"
		}
		/* append nodes to settingsNode*/
		n.appendChild(markingNode);
		n.appendChild(feedbackNode);
		n.appendChild(buttonsNode);
		n.appendChild(exerciseNode);
		n.appendChild(miscNode);
	}
	function addDragFields(noscrollNode:XMLNode, ex:Object) {
		// get id's for drag fields only
		var maxLength = 0;
		var shuffleArray = new Array();
		for (var i=0; i<fieldNodes.childNodes.length; i++) {
			var attr = fieldNodes.childNodes[i].attributes;
			if (attr.type=="i:drag") {
				shuffleArray.push(attr.id);
				var ans = fieldNodes.childNodes[i].firstChild.firstChild.nodeValue;
				maxLength = (ans.length > maxLength) ? ans.length : maxLength;
			}
		}
		// shuffle the id positions to generate a random order
		for (var i=0; i<shuffleArray.length; i++) {
			var randomPos = random(shuffleArray.length);
			var temp = shuffleArray[i];
			shuffleArray[i] = shuffleArray[randomPos];
			shuffleArray[randomPos] = temp;
		}
		// calculate the no. of cells of the "virtual table"
		maxLength *= 7;
		maxLength += 50;
		var cellCount = Math.ceil(622/maxLength);
		if ((cellCount*maxLength - 50) > 572) { cellCount--; }
		if (cellCount==0) {cellCount = 1;}	// v0.12.1, DL - debug: if the cellCount is 0 (i.e. there's a very long drag which occpuies the whole line), we need to set it back to 1
		// write out the id's
		for (var i=0; i<Math.ceil(shuffleArray.length/cellCount); i++) {
			// v0.15.0, DL: no need a paragraph at the beginning
			/*if (i==0) {
				addNodeWithAttr(noscrollNode, "paragraph", {x:"12", y:"+0", width:"605", height:"0"}, "<FONT SIZE=\"2\"> &nbsp; </FONT>");
			}*/
			var drags:Object = new Object();
			drags.tabs = "";
			drags.value = "";
			var base = i*cellCount;
			var baseTab = 25;
			for (var j=0; j<cellCount; j++) {
				if (shuffleArray[base+j]!=undefined) { drags.value += "<tab><FONT COLOR=\"#0000FF\">["+shuffleArray[base+j]+"]</FONT>"; }
				var tabValue = baseTab + j*maxLength;
				drags.tabs += (drags.tabs=="") ? tabValue : ","+tabValue;
				if (j==cellCount-1) {
					drags.attr = {x:"12", y:"+0", width:"605", height:"0", style:"normal", tabs:drags.tabs, indent:"0"};
					drags.value = "<TEXTFORMAT LEADING=\"0\"><P ALIGN=\"LEFT\"><FONT SIZE=\"13\" FACE=\"Verdana\">"+drags.value+"</FONT></P></TEXTFORMAT>";
					addNodeWithAttr(noscrollNode, "paragraph", drags.attr, drags.value);
				}
			}
		}
		// add a little blank line at the bottom of noscroll
		if (noscrollNode.hasChildNodes()) {
			// v6.4.2.7 Why is the leading set for an empty paragraph?
			//addNodeWithAttr(noscrollNode, "paragraph", {x:"12", y:"+0", width:"605", height:"0"}, "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\"><FONT SIZE=\"2\"></FONT></P></TEXTFORMAT>");
			addNodeWithAttr(noscrollNode, "paragraph", {x:"12", y:"+0", width:"605", height:"0"}, "<TEXTFORMAT LEADING=\"0\"><P ALIGN=\"LEFT\"><FONT SIZE=\"2\"></FONT></P></TEXTFORMAT>");
		}
		// add the drag fields to the noscroll node
		for (var i=0; i<fieldNodes.childNodes.length; i++) {
			if (fieldNodes.childNodes[i].attributes.type=="i:drag") {
				noscrollNode.appendChild(fieldNodes.childNodes[i].cloneNode(true));
			}
		}
	}
	function addStoryboardNoscrollSection(noscrollNode:XMLNode, ex:Object) {
		var storyboard:Object = new Object();
		storyboard.attr = {x:"16", y:"16", width:"100", height:"0", style:"normal", indent:"0"};
		storyboard.text = "<TEXTFORMAT LEADING=\"0\"><P ALIGN=\"LEFT\"><FONT SIZE=\"13\" FACE=\"VERDANA\">&nbsp;</FONT></P></TEXTFORMAT>";
		addNodeWithAttr(noscrollNode, "paragraph", storyboard.attr, storyboard.text);
	}
	function addQuestionNode(bodyNode:XMLNode, ex:Object) {
		var question:Object = ex.question;
		var questionAudios = ex.questionAudios;	// v0.16.1, DL: add question audio
		for (var i=0; i<question.length; i++) {
			/* v.12.0 checking is now done in errorCheckClass */
			if (question[i]!=undefined && question[i].value.length>0) {
				
				// v0.16.1, DL: add question audio
				if (questionAudios[i]!=undefined && questionAudios[i].filename!=undefined && questionAudios[i].filename!="") {
					var qaNode:XMLNode = this.createElement("media");
					for (var a in questionAudios[i]) {
						qaNode.attributes[a] = questionAudios[i][a];
					}
					qaNode.attributes["type"] = "q:audio";
					qaNode.attributes["id"] = (i+1).toString();
					qaNode.attributes["mode"] = (questionAudios[i]["mode"]=="2") ? "2" : "1";
					if (!ex.settings.misc.splitScreen) {
						// for full-screen, with top-left image
						if (ex.image.position=="top-left") {
							qaNode.attributes["x"] = "0";
							qaNode.attributes["y"] = "3";
						// for full-screen, with top-right image
						} else if (ex.image.position=="top-right") {
							qaNode.attributes["x"] = "0";
							qaNode.attributes["y"] = "3";
						// for full-screen, with banner
						
						// Yiu v6.5.1 Remove Banner
						} /*else {
							qaNode.attributes["x"] = "0";
							qaNode.attributes["y"] = "3";
						}*/
						// End Yiu v6.5.1 Remove Banner
					} else {
						// for split-screen, with an image
						if (bodyNode.lastChild.nodeName=="media") {
							qaNode.attributes["x"] = "0";
							qaNode.attributes["y"] = "3";
						// for split-screen, without an image
						} else {
							qaNode.attributes["x"] = "0";
							qaNode.attributes["y"] = "3";
						}
					}
					questionAudioNodes.appendChild(qaNode);
				}
				
				// set id & attributes
				var id:Number = i+1;
				// This is the audio icon and the question number
				var tab:Object = new Object();
				if (ex.settings.misc.splitScreen) {
					/* for split screen, move down the questions for 296 pixels ('coz the picture is on top of them) */
					if (bodyNode.lastChild.nodeName=="media") {
						var h = Number(bodyNode.lastChild.attributes.height) + 20;
						// v0.16.1, DL: change width and remove spaces per request by AR
						// v6.4.2.7 tweaking spacing
						//tab.attr = {x:"7", y:"+"+h.toString(), width:"44", height:"0", style:"normal", tabs:"19", indent:"0"};
						tab.attr = {x:"5", y:"+"+h.toString(), width:"44", height:"0", style:"normal", tabs:"16", indent:"0"};
					} else {
						// v0.16.1, DL: change width and remove spaces per request by AR
						tab.attr = {x:"5", y:"+16", width:"44", height:"0", style:"normal", tabs:"16", indent:"0"};
					}
				} else {
					// v0.16.1, DL: change width and remove spaces per request by AR
					tab.attr = {x:"7", y:"+16", width:"49", height:"0", style:"normal", tabs:"19", indent:"0"};
					
					/* v0.16.0, DL: image position */
					// Yiu v6.5.1 Remove Banner
					if (ex.image.position=="top-left") {
						tab.attr.x = "203";
					}/* else if (ex.image.position=="banner") {
						tab.attr.x = "118";
						if (i==0) {
							tab.attr.y = "+102";
						}
					} */else {	// default, top-right
						tab.attr.x = "7";
					}
					// End Yiu v6.5.1 Remove Banner
				}
				// v0.16.1, DL: change width and remove spaces per request by AR
				//tab.value = "<B> &nbsp; &nbsp; "+id.toString()+"</B>";
				// v6.4.2.1 AR For question based exercises, don't add fixed q number, use #q instead
				//tab.value = "<tab><B>"+id.toString()+"</B>";
				// v6.4.2.7 Can you right-align the question number?
				tab.value = "<tab><B>#q</B>";
				
				// add question
				// v0.16.1, DL: add question paragraphs under question node
				// with the question node added, the question audios will be automatically aligned
				var questionNode = addNodeWithName(bodyNode, "question"); 
				addNodeWithAttr(questionNode, "paragraph", tab.attr, tab.value);
				/*var v = question[i].value;
				_global.myTrace(v);
				var startIndex = v.indexOf("<u", 0);
				if (startIndex>-1) {
					//var idStartIndex = v.indexOf("id='", startIndex);
					var idEndIndex = v.indexOf("'>", startIndex);
					var endIndex = v.indexOf("/u>", startIndex);
					if (endIndex>-1) {
						//var id = v.substring(idStartIndex+startIndex+7, idEndIndex);
						//_global.myTrace(id);
						_global.myTrace(v.substring(startIndex, endIndex+5));
						if (Number(id)>0) {
							v = _global.replace(v, v.substring(startIndex, endIndex+5), "["+id+"]");
						}
					}
				}*/
				
				// v0.16.1, DL: change x-coor for questions in split-screen
				if (ex.settings.misc.splitScreen) {
					// v0.16.1, DL: change width and position per request by AR
					// AR v6.4.2.5 tab presets

					//question[i].attr = {type:"question", x:"45", y:"=", width:"256", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
					question[i].attr = {type:"question", x:"45", y:"=", width:"256", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
				} else {
					// v0.16.1, DL: change width and position per request by AR
					question[i].attr = {type:"question", x:"55", y:"=", width:"365", height:"0", style:"normal", tabs:tabPresets, indent:"0"};

					
					/* v0.16.0, DL: question position varies with image position */
					// Yiu v6.5.1 Remove Banner
					if (ex.image.position=="top-left") {
						question[i].attr.x = "254";
					} /*else if (ex.image.position=="banner") {
						question[i].attr.x = "167";
					} */else {	// default, top-right
						question[i].attr.x = "55";
					}
					// End Yiu v6.5.1 Remove Banner
				}
				
				/* v0.12.0, DL: there may be no question, so need to check to prevent student side from hanging */
				if (question[i]!=undefined && question[i].value.length>0) {
					// v0.16.1, DL: add question paragraphs under question node
					// v6.4.2.1 AR: Is this where the text of the question is written? Yes.
					//myTrace("ex:615:" + question[i].attr + ":" + question[i].value);
					addNodeWithAttr(questionNode, "paragraph", question[i].attr, question[i].value);
				} else {
					// v0.16.1, DL: add question paragraphs under question node
					// v6.4.2.7 Why is the leading set for an empty paragraph?
					//addNodeWithAttr(questionNode, "paragraph", question[i].attr, "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\"></P></TEXTFORMAT>");
					addNodeWithAttr(questionNode, "paragraph", question[i].attr, "<TEXTFORMAT LEADING=\"0\"><P ALIGN=\"LEFT\"></P></TEXTFORMAT>");
				}
				
				// v6.4.2.7 Set the details for the actual option, moved from above
				var ans:Object = new Object();
				if (ex.settings.misc.splitScreen) {
					// v0.16.1, DL: change width and position per request by AR
					// v6.4.2.7 Alignment and width
					//ans.attr = {x:"60", y:"=", width:"250", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
					ans.attr = {x:"65", y:"=", width:"245", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
				} else {
					// v0.16.1, DL: change width and position  per request by AR

					ans.attr = {x:"100", y:"=", width:"269", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
					
					/* v0.16.0, DL: image position */
					// Yiu v6.5.1 Remove Banner
					if (ex.image.position=="top-left") {
						ans.attr.x = "361";
					} /* else if (ex.image.position=="banner") {
						ans.attr.x = "261";
					} */else {	// default, top-right
						ans.attr.x = "100";
					}
					// End Yiu v6.5.1 Remove Banner
				}
				/* add options under the question for multiple choice & true/false */
				// This is just the a, b, c - not the text of the option
				switch(ex.exerciseType) {
				case "MultipleChoice" :
				case "Analyze" :
					// add options
					var ansCnt = 0;
					for (var j=0; j<fieldNodes.childNodes.length; j++) {
						var f = fieldNodes.childNodes[j];
						if (Number(f.attributes.group)==i+1) {
							if (f.attributes.type=="i:target") {
								ansCnt++;
								if (ex.settings.misc.splitScreen) {
									// v0.16.1, DL: change width and position per request by AR
									// v6.4.2.7 A little extra spacing between options
									//tab.attr = {x:"35", y:"+0", width:"25", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
									// v6.4.2.7 Align to question

									tab.attr = {x:"45", y:"+4", width:"25", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
								} else {

									// v6.4.2.7 A little extra spacing between options
									//tab.attr = {x:"130", y:"+0", width:"25", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
									tab.attr = {x:"80", y:"+4", width:"25", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
									
									/* v0.16.0, DL: image position */
									// Yiu v6.5.1 Remove Banner
									if (ex.image.position=="top-left") {
										tab.attr.x = "341";
									} /* else if (ex.image.position=="banner") {
										tab.attr.x = "241";
									} */else {	// default, top-right
										tab.attr.x = "80";
									}
									// End Yiu v6.5.1 Remove Banner
								}
								tab.value = String.fromCharCode(96+ansCnt)+".";
								// v0.16.1, DL: add question paragraphs under question node
								addNodeWithAttr(questionNode, "paragraph", tab.attr, tab.value);
								// v6.4.2.7 We are not writing the TEXTFORMAT info here, so leading=0 which causes a jump
								//addNodeWithAttr(questionNode, "paragraph", ans.attr, "<FONT FACE=\"Verdana\" SIZE=\"13\" COLOR=\"#0000FF\">["+f.attributes.id.toString()+"]</FONT>");
								addNodeWithAttr(questionNode, "paragraph", ans.attr, "<TEXTFORMAT LEADING=\"0\"><P ALIGN=\"LEFT\">" + "<FONT FACE=\"Verdana\" SIZE=\"13\" COLOR=\"#0000FF\">["+f.attributes.id.toString()+"]</FONT>" + "</P></TEXTFORMAT>");
							}
						}
					}
					break;
				case "Quiz" :	// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311, suspicious
					var tfOptions = new Array();
					for (var j=0; j<fieldNodes.childNodes.length; j++) {
						var f = fieldNodes.childNodes[j];
						if (Number(f.attributes.group)==i+1) {
							if (f.attributes.type=="i:target") {
								tfOptions.push("["+f.attributes.id.toString()+"]");
							}
						}
					}
					if (tfOptions.length>0) {
						var ex 		= _global.NNW.control.data.currentExercise;
						var splitScreen = ex.settings.misc.splitScreen;

						var strOptionXPos:String;
						var strOptionWidth:String;

						if(splitScreen){	
							strOptionXPos 	= "45";
							strOptionWidth	= "210";
						} else {
							strOptionXPos = "55";
							strOptionWidth	= "319";
						}

						ans.attr = {x:strOptionXPos, y:"+0", width:strOptionWidth, height:"0", style:"normal", tabs:"2,143", indent:"0"};
						/* v0.16.0, DL: image position */
						// Yiu v6.5.1 Remove Banner
						if (ex.image.position=="top-left") {
							ans.attr.x = "291";
						} /*else if (ex.image.position=="banner") {
							ans.attr.x = "191";
						} */else {	// default, top-right
							ans.attr.x = strOptionXPos;
						}
						// End Yiu v6.5.1 Remove Banner

						////////////////////////////////////////////////////////////////
						// v6.5.4.2 Yiu, seperate into two lines if the size excess the screen's width, bug 1311

						// make the space even, between words
						var aTabSize:Array;
						
						// Get the text restriction area by split screen or not
						var const_nSplitScreenTextSizeRestriction:Number;
						var const_nNonSplitScreenTextSizeRestriction:Number;
						var nTextSizeRestriction:Number;
						
						// The size of the content holder movieclip in the screen.fla		
						const_nSplitScreenTextSizeRestriction	= 210;
						const_nNonSplitScreenTextSizeRestriction= 319;
					 	nTextSizeRestriction	= splitScreen? const_nSplitScreenTextSizeRestriction : const_nNonSplitScreenTextSizeRestriction;

						// Get the tab size array from word array
						var aOptionWordsArray:Array;
						aOptionWordsArray	= getAllOptionWords(tfOptions.join(","));

						var aTabArray:Array;
						aTabArray	= getTabSizeFromWordArray(aOptionWordsArray, nTextSizeRestriction);
						ans.attr.tabs	= aTabArray.join(",");

						// v6.5.4.2 Yiu, check if one of the option text width is larger than the tab size

						var bOneOfTheOptionsWidthIsBiggerThanTab:Boolean;
						bOneOfTheOptionsWidthIsBiggerThanTab	= checkIfOptionsBiggerThanTabs(tfOptions, aTabArray[0]);
						// end v6.5.4.2 Yiu, check if one of the option text width is larger than the tab size

						// Try to get the length of the string
						var strInXmlString:String;
						var strInXmlStringOrigin:String;

						strInXmlStringOrigin	= "<FONT FACE=\"Verdana\" SIZE=\"13\" COLOR=\"#0F157A\"><B>"+tfOptions.join("<tab>")+"</B></FONT>"; 
						strInXmlString		= strInXmlStringOrigin;
						strInXmlString		= replaceTheBracketToRealWords(strInXmlString);

						var txt_for_length:TextField;
						txt_for_length		= _root.createTextField("txt_for_length", 10, 0, 0, 0, 100);
						txt_for_length.html	= true;
						txt_for_length.autoSize	= true;
						
						txt_for_length._width	= 0;
						txt_for_length.htmlText	= strInXmlString;

					var nIndexYiu:Number;
					for(nIndexYiu=0; nIndexYiu<tfOptions.length; ++nIndexYiu){
					}	
						if(	(txt_for_length._width > (const_nSplitScreenTextSizeRestriction) && splitScreen) || 
							(txt_for_length._width > const_nNonSplitScreenTextSizeRestriction && !splitScreen) ||
							bOneOfTheOptionsWidthIsBiggerThanTab){
							strInXmlStringOrigin	= "<FONT FACE=\"Verdana\" SIZE=\"13\" COLOR=\"#0F157A\"><B>"+tfOptions.join("<br><br>")+"</B></FONT>"; 
							addNodeWithAttr(questionNode, "paragraph", ans.attr, "<FONT FACE=\"Verdana\" SIZE=\"13\" COLOR=\"#0F157A\"><B>" + strInXmlStringOrigin + "</B></FONT>");
						} else {
							// v0.16.1, DL: add question paragraphs under question node
							addNodeWithAttr(questionNode, "paragraph", ans.attr, "<FONT FACE=\"Verdana\" SIZE=\"13\" COLOR=\"#0F157A\"><B>"+tfOptions.join("<tab>")+"</B></FONT>");
						}

						// release resource
						txt_for_length.removeTextField();
						
						// end v6.5.4.2 Yiu, seperate into two Attr if the size excess the screen's width, bug 1311
						////////////////////////////////////////////////////////////////
					}
					break;
				}
			}
			
			// v6.5.1 Yiu new default gap length check box and slider 
			// putting gap length into xml file
			var nMyGapLength:Number;
			nMyGapLength	= ex.m_aryGapLength[i];
			addNodeWithAttr(questionNode, "gapLength", null, nMyGapLength.toString());
			// End v6.5.1 Yiu new default gap length check box and slider 
		}
		
		/* v0.12.0, DL: add some blank lines at the end of the body after the questions */
		// v6.4.2.5 AR - just add one with space before
		//for (var i=0; i<3; i++) {
			// v6.4.2.7 Why is the leading set for an empty paragraph?
			//addNodeWithAttr(bodyNode, "paragraph", {x:"12", y:"+50", width:"400", height:"0"}, "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"LEFT\"><FONT SIZE=\"2\"></FONT></P></TEXTFORMAT>");

			addNodeWithAttr(bodyNode, "paragraph", {x:"12", y:"+50", width:"400", height:"0"}, "<TEXTFORMAT LEADING=\"0\"><P ALIGN=\"LEFT\"><FONT SIZE=\"2\"></FONT></P></TEXTFORMAT>");
		//}
		
		if (fieldNodes.hasChildNodes()) {
			for (var i=0; i<fieldNodes.childNodes.length; i++) {
				if (fieldNodes.childNodes[i].attributes.type!="i:drag") {
					/* v0.14.0, DL: if it's split screen then the fields in the text side should go to the text node instead of body node*/
					if (!ex.settings.misc.splitScreen) {
						bodyNode.appendChild(fieldNodes.childNodes[i].cloneNode(true));
					} else if (ex.text.value.indexOf("["+fieldNodes.childNodes[i].attributes.id+"]", 0)==-1) {
						bodyNode.appendChild(fieldNodes.childNodes[i].cloneNode(true));
					}
				}
			}
		}
		
		// add question audio nodes to body
		for (var i=0; i<questionAudioNodes.childNodes.length; i++) {
			bodyNode.appendChild(questionAudioNodes.childNodes[i].cloneNode(true));
		}
	}
	function addFieldNode(ex:Object) {
		//_global.myTrace("add field nodes");
		var question:Object = ex.question;
		var field:Object = ex.fieldManager.outputFields;
		//var id = 1;
		var maxGpID = 0;
		var maxID = 0; // for getting max. id to add new fields in drag and drop
		switch (ex.exerciseType) {
		case "MultipleChoice" :
		case "Quiz" :
		case "Stopgap" :
		case "DragAndDrop" :
		case "Analyze" :
		// v6.4.3 Add new exercise type, item based drop-down
		case "Stopdrop" :
		case _global.g_strQuestionSpotterID:	// v6.5.1 Yiu add bew exercise type question spotter
			
			// v6.4.1.4, DL: DEBUG - add true/false labels for quiz
			var quizFlag = true;
			
			/* add fields to fieldNode */
			for(var i=0; i<field.length; i++) {
				//_global.myTrace("group = "+field[i].attr.group);
				var thisGpID = Number(field[i].attr.group);
				if (field[i]!=undefined && field[i].attr.type!="i:url") {
					/* v6.4.0.1, DL: debug - add a pair of quiz options even if there is no question */
					if (question[thisGpID-1].value.length>0 || (ex.exerciseType=="Quiz" && thisGpID==1)) {
						//_global.myTrace("add field node = "+field[i].answers[0].value);
						var fieldNode:XMLNode = this.createElement("field");
						for (var a in field[i].attr) {
							fieldNode.attributes[a] = field[i].attr[a];
						}
						maxGpID = (thisGpID > maxGpID) ? thisGpID : maxGpID;
						var ans = field[i].answers;
						for (var j=0; j<ans.length; j++) {
							if (ans[j]!=undefined && ans[j].value.length>0) {
								var answerNode:XMLNode = this.createElement("answer");
								if (ans[j].correct!=undefined && ans[j].correct!="undefined") {
									answerNode.attributes.correct = ans[j].correct;
									
									// v6.4.1.4, DL: DEBUG - add true/false option labels for quiz
									if (ex.exerciseType=="Quiz") {
										if (quizFlag) {
											var answerValue:XMLNode = this.createTextNode(ex.fieldManager.quizFieldTrue);
										} else {
											var answerValue:XMLNode = this.createTextNode(ex.fieldManager.quizFieldFalse);
										}
										answerNode.appendChild(answerValue);
										quizFlag = !quizFlag;
									}
									
								}
								
								// v6.4.1.4, DL: DEBUG - keep on adding field labels for exercise types other than quiz
								if (ex.exerciseType!="Quiz") {	
									var answerValue:XMLNode = this.createTextNode(ans[j].value);
									answerNode.appendChild(answerValue);
								}
								
								fieldNode.appendChild(answerNode);
							}
						}
						if (fieldNode.hasChildNodes()) {
							//id++;
							//fieldNode.attributes.id = id;
							maxID = (Number(fieldNode.attributes.id) > maxID) ? Number(fieldNode.attributes.id) : maxID;
							fieldNodes.appendChild(fieldNode);
						}
					}
				}
			}
			
			/* add url to fieldNode */
			for (var i=0; i<field.length; i++) {
				if (field[i]!=undefined && field[i].attr.type=="i:url") {
					//_global.myTrace("add url node = "+field[i].answers[0].value);
					var fieldNode:XMLNode = this.createElement("field");
					for (var a in field[i].attr) {
						/* v0.11.0, DL: skip group attribute for url */
						if (a!="group") {
							fieldNode.attributes[a] = field[i].attr[a];
						}
					}
					var ans = field[i].answers[0];
					if (ans!=undefined && ans.value.length>0) {
						var answerNode:XMLNode = this.createElement("answer");
						if (ans[j].correct!=undefined && ans[j].correct!="undefined") {
							answerNode.attributes.correct = ans[j].correct;
						}
						var answerValue:XMLNode = this.createTextNode(ans.value);
						answerNode.appendChild(answerValue);
						fieldNode.appendChild(answerNode);
					}
					if (fieldNode.hasChildNodes()) {
						//id++;
						//maxGpID++;	/* v0.11.0, DL: skip group attribute for url */
						//fieldNode.attributes.id = id;
						//fieldNode.attributes.group = maxGpID;	/* v0.11.0, DL: skip group attribute for url */
						maxID++;	// v0.12.0, DL: weblink is added, need to skip their field id's as well (for drags only)
						fieldNodes.appendChild(fieldNode);
					}
				}
			}
			break;
		default :
			/* v0.13.0, DL: eliminate duplicated options in dropdown */
			if (ex.exerciseType=="Dropdown") {
				for (var i=0; i<field.length; i++) {
					if (field[i]!=undefined && field[i].attr.type!="i:url") {
						var ans = field[i].answers;
						for (var j=0; j<ans.length; j++) {
							//myTrace("xmlEx:addFieldNode.ans=" + ans[k].value)
							for (var k=ans.length-1; k>j; k--) {
								if (ans[j].value==ans[k].value) {
									ans[j].correct = (Boolean(ans[j].correct) || Boolean(ans[k].correct)) ? "true" : "false";
									ans[k].value = "";
									ans[k].correct = "";
								}
							}
						}
					}
				}
			}
			
			/* add fields to fieldNode */
			for (var i=0; i<field.length; i++) {
				if (field[i]!=undefined && field[i].attr.type!="i:url") {
					//_global.myTrace("add field node = "+field[i].answers[0].value);
					var fieldNode:XMLNode = this.createElement("field");
					for (var a in field[i].attr) {
						fieldNode.attributes[a] = field[i].attr[a];
					}
					maxGpID = (Number(field[i].attr.group) > maxGpID) ? Number(field[i].attr.group) : maxGpID;
					var ans = field[i].answers;
					for (var j=0; j<ans.length; j++) {
						if (ans[j]!=undefined && ans[j].value.length>0) {
							var answerNode:XMLNode = this.createElement("answer");
							if (ans[j].correct!=undefined && ans[j].correct!="undefined") {
								answerNode.attributes.correct = ans[j].correct;
							}
							var answerValue:XMLNode = this.createTextNode(ans[j].value);
							answerNode.appendChild(answerValue);
							fieldNode.appendChild(answerNode);
						}
					}
					if (fieldNode.hasChildNodes()) {
						maxID = (Number(fieldNode.attributes.id) > maxID) ? Number(fieldNode.attributes.id) : maxID;
						fieldNodes.appendChild(fieldNode);
					}
				}
			}
			/* add url to fieldNode */
			for (var i=0; i<field.length; i++) {
				if (field[i]!=undefined && field[i].attr.type=="i:url") {
					//_global.myTrace("add url node = "+field[i].answers[0].value);
					var fieldNode:XMLNode = this.createElement("field");
					for (var a in field[i].attr) {
						/* v0.11.0, DL: skip group attribute for url */
						if (a!="group") {
							fieldNode.attributes[a] = field[i].attr[a];
						}
					}
					var ans = field[i].answers[0];
					if (ans!=undefined && ans.value.length>0) {
						var answerNode:XMLNode = this.createElement("answer");
						if (ans[j].correct!=undefined && ans[j].correct!="undefined") {
							answerNode.attributes.correct = ans[j].correct;
						}
						var answerValue:XMLNode = this.createTextNode(ans.value);
						answerNode.appendChild(answerValue);
						fieldNode.appendChild(answerNode);
					}
					if (fieldNode.hasChildNodes()) {
						//maxGpID++;	/* v0.11.0, DL: skip group attribute for url */
						//fieldNode.attributes.group = maxGpID;	/* v0.11.0, DL: skip group attribute for url */
						maxID++;	// v0.12.0, DL: weblink is added, need to skip their field id's as well (for drags only)
						fieldNodes.appendChild(fieldNode);
					}
				}
			}
			break;
		}
		/* add the field nodes for each drag in DragAndDropQuestions */
		if (ex.exerciseType=="DragOn"||ex.exerciseType=="DragAndDrop") {
			//myTrace("ex.settings.exercise.dragTimes="+ex.settings.exercise.dragTimes); 
			// Keep all drags, even duplicates, so you only drag each one once
			// v6.4.2.5 AR it would make more sense to merge the two parts of this conditional and skip or not the
			// bit in the middle where you check for duplicates. Do it later.
			if (ex.settings.exercise.dragTimes!=0) { 									
				//var arr = new Array();
				for (var i=0; i<field.length; i++) {
					if (field[i].attr.type=="i:drop") {
						var ans = field[i].answers;
						// v6.4.2.5 AR add in alternative answers too
						for (var j=0; j<ans.length; j++) {
							//myTrace("  j = "+j+"    ans["+j+"].value=" + ans[j].value);	 //debug msg
							if (ans[j]!=undefined && ans[j].value.length>0) {
								//myTrace("drag " + ans[j].value + " is correct=" + ans[j].correct);
								var fieldNode:XMLNode = this.createElement("field");
								var answerNode:XMLNode = this.createElement("answer");
								// This is the drag, so there is no relevance to correct or false for the answer
								answerNode.attributes.correct = false;
								var answerValue:XMLNode = this.createTextNode(ans[j].value);
								answerNode.appendChild(answerValue);
								fieldNode.appendChild(answerNode);
								if (fieldNode.hasChildNodes()) {
									maxID++;
									fieldNode.attributes.mode = "0";
									fieldNode.attributes.type = "i:drag";
									fieldNode.attributes.group = "1";
									fieldNode.attributes.id = maxID;
									fieldNodes.appendChild(fieldNode);
								}
							}
						}
						//arr.push(ans[0]);
						//myTrace(ans[0].value+" is put in the XML.");
					}
				}
				/*
				for (var i=0; i<arr.length; i++) { // 2nd checking if there's any more alternative answers.
					myTrace("i = "+i); //debug msg
					for (var j in fieldNodes.childNodes) {
						myTrace("  j = "+fieldNodes.childNodes[j].firstChild.firstChild.nodeValue);
					}
				}*/
			} else { 																	// Remove duplicate drags
				for (var i=0; i<field.length; i++) {
					if (field[i].attr.type=="i:drop") {
						var ans = field[i].answers;
						//myTrace("i = "+i); //debug msg
						for (var j=0; j<ans.length; j++) {
							//myTrace("  j = "+j+"    ans["+j+"].value=" + ans[j].value);	 //debug msg
							if (ans[j]!=undefined && ans[j].value.length>0) {
								// v6.4.1.5, DL: no, we should not get rid of duplicated drags
								// v6.4.0.1, DL: get rid of duplicated drags
								var notRepeated:Boolean = true;
								for (var k in fieldNodes.childNodes) {
									if (	fieldNodes.childNodes[k].firstChild.firstChild.nodeValue==ans[j].value&&
										fieldNodes.childNodes[k].attributes.type=="i:drag") {
										notRepeated = false;
										// v6.4.2.5 if it is duplicated once, that is enough
										break;
									}
								}
								if (notRepeated) {
									//myTrace("drag " + ans[j].value + " is correct=" + ans[j].correct);
									var fieldNode:XMLNode = this.createElement("field");
									var answerNode:XMLNode = this.createElement("answer");
									// This is the drag, so there is no relevance to correct or false for the answer
									answerNode.attributes.correct = false;
									var answerValue:XMLNode = this.createTextNode(ans[j].value);
									answerNode.appendChild(answerValue);
									fieldNode.appendChild(answerNode);
									if (fieldNode.hasChildNodes()) {
										maxID++;
										fieldNode.attributes.mode = "0";
										fieldNode.attributes.type = "i:drag";
										fieldNode.attributes.group = "1";
										fieldNode.attributes.id = maxID;
										fieldNodes.appendChild(fieldNode);
									}
									//myTrace(ans[j].value+" is put in the XML.")
								}
							}
						}						
					}
				}
			}
			//myTrace(fieldNodes.toString());
		}
		delete ex;
		//_global.myTrace("xmlEx.fieldNodes " + fieldNodes.toString());
	}
	// v0.16.0, DL: added parameter inc for question based feedback (incrementing id by 1)
	// v6.4.1.4, DL: add qBased setting to check question as well
	function addFeedbackHintNode(nName:String, obj:Object, inc:Boolean, qBased:Boolean, question:Object) : Void {
		var p = this.firstChild;	/* get reference to rootNode (p) */
		var n:XMLNode;
		for (var i=0; i<obj.length; i++) {
			//_global.myTrace(obj[i].value);
			if (obj[i]!=undefined && obj[i].value.length>0) {
				//_global.myTrace(question[i].value);
				if (!qBased || (question[i]!=undefined && question[i].value.length>0)) {
					n = addNodeWithName(p, nName);
					n.attributes["id"] = (inc) ? i+1 : i;
					n.attributes["mode"] = 101;
					addNodeWithAttr(n, "paragraph", obj[i].attr, obj[i].value);
				}
			}
		}
	}
	/* v0.16.0, DL: generalize the addPictureNode function */
	function addPictureNode(n:XMLNode, ex:Object, dim:String) : Void {
		if (ex.image.filename!="") {
			if (ex.image.category=="YourGraphic") {
				addUserPictureNode(n, ex.image, ex.settings.misc.splitScreen);
			} else if (ex.image.category!="NoGraphic") {
				addSharedPictureNode(n, {path:"", name:ex.image.filename}, ex.image, ex.settings.misc.splitScreen);
			}
		} else {
			ex.image.width = "";
			ex.image.height = "";
			
			/* v0.16.0, DL: add the NoGraphic & YourGraphic options */
			if (ex.image.category=="NoGraphic" || ex.image.category=="YourGraphic") {
				// no filename, no need add node
			} else {
				addSharedPictureNode(n, _global.NNW.photos.randFileFromCategory(dim, ex.image.category), ex.image, ex.settings.misc.splitScreen);
			}
			
		}
	}
	function  addUserPictureNode(bodyNode:XMLNode, img:Object, splitScreen:Boolean) : Void {
		mediaCnt++;
		var n:XMLNode = this.createElement("media");
		n.attributes["type"] = "m:picture";
		// v6.4.2.6 Can have location for all media types
		//n.attributes["location"] = "";
		n.attributes["location"] = img.location;
		n.attributes["category"] = "YourGraphic";
		n.attributes["id"] = mediaCnt;
		n.attributes["mode"] = "1";
		n.attributes["stretch"] = "false";	// v6.4.0.1, DL
				
		if (splitScreen) {
			n.attributes["width"] = (img.width=="") ? "250" : img.width;
			n.attributes["height"] = (img.height=="") ? "165" : img.height;
			n.attributes["x"] = (n.attributes["width"]=="250") ? "31.5" : "74" ;
			n.attributes["y"] = "9";
		} else {
			// v6.5.1 Yiu allow long picture if there is no url
			// if there is no url, enable height = 0			
			var ex = _global.NNW.control.data.currentExercise;
			var bHaveURL:Boolean;
			bHaveURL	= false
			
			for (var v1:Number = 0; v1 < ex.URLs.length; ++v1)
			{
				if (ex.URLs[v1].url != "")
				{
					bHaveURL	= true;
					break;
				}
			}
			
			var nImageHeight:Number;
			if (img.height == "")
			{
				nImageHeight	= 250;
			}
			else
			{
				nImageHeight	= img.height;
			}
			
			if (!bHaveURL)
			{
				nImageHeight	= 0;
			}
			
			// End v6.5.1 Yiu allow long picture if there is no url
			
			n.attributes["width"] = (img.width=="") ? "165" : img.width;
			//n.attributes["height"] = (img.height=="") ? "250" : img.height;
			n.attributes["height"] = nImageHeight;	// changed by Yiu v6.5.1
			
			/* v0.16.0, DL: set image position */
			// Yiu v6.5.1 Remove Banner
			/*if (img.position=="banner") {
				n.attributes["x"] = "118";
				n.attributes["y"] = "16";
			} else*/ if (img.position=="top-left") {
				n.attributes["x"] = "30";
				//v6.4.2.1 AR align to top of text
				// NOTE, if you change these, then you HAVE to change fillIn in dataExercise.as as well
				// otherwise you will not match back the position name. Reverted until done properly.
				n.attributes["y"] = "32";
				//n.attributes["y"] = "24";
			} else {	// top-right
				n.attributes["x"] = "448";
				//v6.4.2.1 AR align to top of text
				n.attributes["y"] = "32";
				//n.attributes["y"] = "24";
			}
			// End Yiu v6.5.1 Remove Banner
			
		}
		n.attributes["filename"] = img.filename;
		bodyNode.appendChild(n);
	}
	function  addSharedPictureNode(bodyNode:XMLNode, pic:Object, img:Object, splitScreen:Boolean) : Void {
		mediaCnt++;
		var n:XMLNode = this.createElement("media");
		n.attributes["type"] = "m:picture";
		n.attributes["location"] = "shared";
		n.attributes["category"] = (img.category!=undefined) ? img.category : "";
		n.attributes["id"] = mediaCnt;
		n.attributes["mode"] = "1";
		n.attributes["stretch"] = "false";	// v6.4.0.1, DL
		if (splitScreen) {
			n.attributes["width"] = (img.width=="") ? "250" : img.width;
			n.attributes["height"] = (img.height=="") ? "165" : img.height;
			n.attributes["x"] = (n.attributes["width"]=="250") ? "31.5" : "74" ;
			n.attributes["y"] = "9";
		} else {
			n.attributes["width"] = (img.width=="") ? "165" : img.width;
			n.attributes["height"] = (img.height=="") ? "250" : img.height;
			
			/* v0.16.0, DL: set image position */
			// Yiu v6.5.1 Remove Banner
			/*if (img.position=="banner") {
				n.attributes["x"] = "118";
				n.attributes["y"] = "16";
			} else*/ if (img.position=="top-left") {
				n.attributes["x"] = "30";
				//v6.4.2.1 AR align to top of text
				n.attributes["y"] = "32";
				//n.attributes["y"] = "24";
			} else {	// top-right
				n.attributes["x"] = "448";
				//v6.4.2.1 AR align to top of text
				n.attributes["y"] = "32";
				//n.attributes["y"] = "24";
			}
			// End Yiu v6.5.1 Remove Banner
			
		}
		n.attributes["filename"] = (pic.path!=undefined && pic.path.length>0) ? pic.path+"/"+pic.name : pic.name;
		bodyNode.appendChild(n);
	}
	function addAudioNode(bodyNode:XMLNode, audio:Object, splitScreen:Boolean, imgPos:String) {
		if (audio.filename!=undefined && audio.filename!="") {
			mediaCnt++;
			//<media type="m:audio" id="1002" mode="4" filename="el-aia-pr1-i.fls" /> 
			var n:XMLNode = this.createElement("media");
			n.attributes["type"] = "m:audio";
			n.attributes["id"] = mediaCnt;
			// v6.4.2.6 Can have location for all media types
			//if (audio.location=="shared") { n.attributes["location"] = "shared"; }
			n.attributes["location"] = audio.location;
			n.attributes["mode"] = audio.mode;	// 1 for click, 2 for after marking, 4 for autoplay
			
			// v0.16.1, DL: for embed audio, add x & y attributes
			if (n.attributes["mode"]=="1") {
				if (!splitScreen) {
					/* v0.16.0, DL: set position according to image position */
					// Yiu v6.5.1 Remove Banner
					/*if (imgPos=="banner") {
						n.attributes["x"] = "95";
						n.attributes["y"] = "16";
					} else*/ if (imgPos=="top-left") {
						n.attributes["x"] = "154";
						// v6.4.2.6 Move embedded icons up a little
						//n.attributes["y"] = "10";
						n.attributes["y"] = "4";
					} else {	// top right
						n.attributes["x"] = "448";
						// v6.4.2.6 Move embedded icons up a little
						//n.attributes["y"] = "10";
						// v 6.4.2.7 But not that far - at least not for intefaces with small icons
						if (_global.NNW.interfaces.getInterface()=="AuthorPlus") {
							n.attributes["y"] = "6";
						} else {
							n.attributes["y"] = "9";
						}
					}
					// End Yiu v6.5.1 Remove Banner
				} else {
					n.attributes["x"] = "9";
					n.attributes["y"] = "9";
				}
			}
			
			n.attributes["filename"] = audio.filename;
			bodyNode.appendChild(n);
		}
	}
	function addVideoNode(bodyNode:XMLNode, video:Object, imgPos:String, splitScreen:Boolean) {
		if (video.filename!=undefined && video.filename!="") {
			mediaCnt++;
			var n:XMLNode = this.createElement("media");
			n.attributes["type"] = "m:video";
			n.attributes["id"] = mediaCnt;
			n.attributes["mode"] = video.mode;	// 1 for click, 16 for floating
			n.attributes["duration"] = "60";
			n.attributes["stretch"] = "false";	// v6.4.0.1, DL
			// v6.4.2.6 Can have location for all media types
			n.attributes["location"] = video.location;
			
			if (video.mode=="1") {
				if (splitScreen) {
					//n.attributes["width"] = (video.width==undefined || video.width=="") ? "250" : video.width;
					//n.attributes["height"] = (video.height==undefined || video.height=="") ? "165" : video.height;
					//n.attributes["x"] = (n.attributes["width"]=="250") ? "31.5" : "74" ;
					n.attributes["width"] = "250";
					n.attributes["height"] = "165";
					n.attributes["x"] = "31.5";
					n.attributes["y"] = "9";
					// v0.16.1, DL: add anchor (the corner that should not move if it is expanded)
					n.attributes["anchor"] = "tr";
				} else {
					n.attributes["width"] = (video.width==undefined || video.width=="") ? "165" : video.width;
					n.attributes["height"] = (video.height==undefined || video.height=="") ? "250" : video.height;
					
					/* v0.16.0, DL: set video position */
					// Yiu v6.5.1 Remove Banner
					/*if (video.position=="banner") {
						// v6.4.1.4, DL: DEBUG - banner video should have a different size
						n.attributes["width"] = "405";
						n.attributes["height"] = "70";
						n.attributes["x"] = "118";
						n.attributes["y"] = "16";
						// v0.16.1, DL: add anchor (the corner that should not move if it is expanded)
						n.attributes["anchor"] = "tl";
					} else*/ if (video.position=="top-left") {
						n.attributes["x"] = "30";
						n.attributes["y"] = "32";
						// v0.16.1, DL: add anchor (the corner that should not move if it is expanded)
						n.attributes["anchor"] = "tl";
					} else {	// top-right
						n.attributes["x"] = "448";
						n.attributes["y"] = "32";
						// v0.16.1, DL: add anchor (the corner that should not move if it is expanded)
						n.attributes["anchor"] = "tr";
					}
					// End Yiu v6.5.1 Remove Banner
				}
			} else {	// video mode = 16 (floating)
				if (!splitScreen) {
					/* v0.16.0, DL: set position according to image position */
					// Yiu v6.5.1 Remove Banner
					/*if (imgPos=="banner") {
						n.attributes["x"] = "95";
						n.attributes["y"] = "41";
					} else*/ if (imgPos=="top-left") {
						n.attributes["x"] = "179";
						//n.attributes["y"] = "10";
						n.attributes["y"] = "4";
					} else {	// top-right
						n.attributes["x"] = "473";
						//n.attributes["y"] = "4";
						// v 6.4.2.7 But not that far - at least not for intefaces with small icons
						if (_global.NNW.interfaces.getInterface()=="AuthorPlus") {
							n.attributes["y"] = "6";
						} else {
							n.attributes["y"] = "9";
						}
					}
					// End Yiu v6.5.1 Remove Banner
				} else {
					n.attributes["x"] = "9";
					n.attributes["y"] = "34";
				}
			}
			
			n.attributes["filename"] = video.filename;
			bodyNode.appendChild(n);
		}
	}
	// v6.4.2.7 Adding URLs
	function addURLNode(bodyNode:XMLNode, urlObj:Object, imgPos:String, splitScreen:Boolean) {
		_global.myTrace("addURLNode, imgPos=" + imgPos + ", split=" + splitScreen);
		if (urlObj.url!=undefined && urlObj.url!="") {
			mediaCnt++;
			var n:XMLNode = this.createElement("media");
			n.attributes["type"] = "m:url";
			n.attributes["id"] = mediaCnt;
			//n.attributes["mode"] = urlObj.mode;	// 1 for toolbar, 2 for embedded under picture. NO can't do this as Orchid uses different mode
			n.attributes["mode"] = 1;	// 1 for regular
			// force a protocol to stop Orchid thinking it is relative
			// v6.5.5.9 by WZ, url name with folder or file name or start with # which means from share folder
			// should not add http:// prefix.
			if ((urlObj.url.indexOf("://") > 0) || (urlObj.url.indexOf("/") == 0) 
				(urlObj.url.indexOf("/") == -1) || (urlObj.url.indexOf("#")== 0)) {
				n.attributes["url"] = urlObj.url;
			} else {
				n.attributes["url"] = "http://" + urlObj.url;
			}
			n.attributes["name"] = urlObj.caption;
			
			// Preserve customised fields - those that are not directly controlled by author
			if (urlObj.customised) {
				n.attributes["x"] = urlObj.x;
				n.attributes["y"] = urlObj.y;
				n.attributes["customised"] = urlObj.customised;
			} else {
				if (urlObj.floating) {
					// no coordinates necessary for floating url
				} else {
					// If the caption is blank for an embedded link, try to use the domain
					if (n.attributes["name"]==undefined || n.attributes["name"]=="") {
						var domainStart = n.attributes["url"].indexOf("://");
						if (domainStart<0) {
							domainStart=0;
						} else {
							domainStart+=3;
						}
						var domainEnd = n.attributes["url"].indexOf("/", domainStart+1);
						if (domainEnd<0) {
							domainEnd=n.attributes["url"].length;
						}
						n.attributes["name"] = n.attributes["url"].substring(domainStart, domainEnd);
						//_global.myTrace("blank caption so try " + n.attributes["name"]);
					}
					// Setting the coordinates for the list of embedded weblinks
					var myX; var myY; var topMargin; var pictureHeight; var verticalBuffer; var captionHeight;
					verticalBuffer = 10;
					captionHeight = 22;
					// i) For a split screen put the list under the image and shift down the text. x is left aligned with the picture
					if (splitScreen) {
						myX = 31.5;
						// If there is no picture we will be at the top
						if (imgPos!="") {
							topMargin = 9;
							myY = topMargin + (captionHeight*urlCnt);
						// otherwise we want to be under the picture
						} else {
							//v6.4.2.7, RL: let it be more flexible
							//pictureHeight=165;
							var ex = _global.NNW.control.data.currentExercise;
							pictureHeight= ex.image.height == "" ? 0 : Number(ex.image.height);
							myTrace("picture's height="+pictureHeight);
							myY = topMargin + pictureHeight + verticalBuffer  + (captionHeight*urlCnt);
						}
					} else {						
						topMargin = 32;
						//v6.4.2.7, RL: let it be more flexible
						//pictureHeight=250;
						var ex = _global.NNW.control.data.currentExercise;
						pictureHeight= ex.image.height == "" ? 0 : Number(ex.image.height);
						myTrace("picture's height="+pictureHeight);
						// Yiu v6.5.1 Remove Banner
						/*if (imgPos=="banner") {
							//n.attributes["x"] = "118";
							//n.attributes["y"] = "101"; // 16 + 70 + 15
							//v6.4.2.7, RL: a temp solution to put the link on top-right.
							myX = 448;
							myY = topMargin + (captionHeight*urlCnt);
						} else*/ if (imgPos=="top-left") {
							//n.attributes["x"] = "30";
							//n.attributes["y"] = "297"; // 32 + 250 + 15
							//v6.4.2.7, RL: top-left URL y-postion not fixed.
							
							myX = 30;
							myY = topMargin + pictureHeight + verticalBuffer  + (captionHeight*urlCnt);
						// iv) For a top right image, put the list under the image. x is left aligned with the picture.
						//	you can only get the depth for a customised image that has height attribute set
						} else if (imgPos=="top-right") {
							_global.myTrace("top-right picture");
							myX = 448;
							myY = topMargin + pictureHeight + verticalBuffer  + (captionHeight*urlCnt);
						// there is no picture, so put top-right
						// v) For no image, put the list top right. x is left aligned with where the picture would be.
						} else {
							_global.myTrace("no picture");
							myX = 448;
							myY = topMargin + (captionHeight*urlCnt);
						}
						// End Yiu v6.5.1 Remove Banner
					}
					_global.myTrace("url at x=" + myX + " y=" + myY);
					n.attributes["x"] = myX;
					n.attributes["y"] = myY;
					// Finally, update the counter for the list length
					urlCnt++;
				}
			}			
			bodyNode.appendChild(n);
		}
	}

	function getAllOptionWords(objInput)
	{
		var strInput:String;
		strInput	= objInput.toString();
	
		var ex = _global.NNW.control.data.currentExercise;
		var aOutputArray:Array;
		aOutputArray	= new Array();

		// search for some brackets	
		var i:Number;
		var nGotID:Number; 
		var strGotWords:String;
		
		var strOpenBracket:String;
		var strCloseBracket:String;
		strOpenBracket	= "[";
		strCloseBracket	= "]";
		
		var nOpenBracketIndex:Number;
		var nCloseBracketIndex:Number;
		nOpenBracketIndex	= 0;	
		nCloseBracketIndex	= 0;	

		while((nOpenBracketIndex= strInput.indexOf(strOpenBracket, nCloseBracketIndex))!= -1){
			if((nCloseBracketIndex= strInput.indexOf(strCloseBracket, nOpenBracketIndex)) == -1)
				break;

			// get the id within bracket [?] or [??] or [???] or ...
			nGotID	= Number(strInput.substring(nOpenBracketIndex+1, nCloseBracketIndex))

			// get the options
			strGotWords = ex.getOptionWithID(nGotID).value;
			aOutputArray.push(strGotWords);
		}
		
		return aOutputArray;
	}

	// v6.5.4.2 Yiu, replace option [i] with the actually string
	function replaceTheBracketToRealWords(objInput)
	{
		var strInput:String;
		strInput	= objInput.toString();
		
		var ex = _global.NNW.control.data.currentExercise;
		
		// search for some brackets	
		var i:Number;
		var nGotID:Number; 
		var strGotWords:String;
		
		var strOpenBracket:String;
		var strCloseBracket:String;
		strOpenBracket	= "[";
		strCloseBracket	= "]";
		
		var strWholeStringFirstPart:String;
		var strWholeStringSecondPart:String;

		var nOpenBracketIndex:Number;
		var nCloseBracketIndex:Number;
		nOpenBracketIndex	= 0;	
		nCloseBracketIndex	= 0;	

		while((nOpenBracketIndex= strInput.indexOf(strOpenBracket, nCloseBracketIndex))!= -1){
			if((nCloseBracketIndex= strInput.indexOf(strCloseBracket, nOpenBracketIndex)) == -1)
				break;

			// get the id within bracket [?] or [??] or [???] or ...
			nGotID	= Number(strInput.substring(nOpenBracketIndex+1, nCloseBracketIndex))

			// get the options
			strGotWords = ex.getOptionWithID(nGotID).value;

			// put it back
			strWholeStringFirstPart = strInput.substring(0, nOpenBracketIndex);
			strWholeStringSecondPart = strInput.substring(nCloseBracketIndex + 1, strInput.length);
				
			// make it merge with the orginal string
			strInput	= strWholeStringFirstPart + strGotWords + strWholeStringSecondPart;
			
			// the close bracket index is changed because you merge the words already 
			nCloseBracketIndex	+= strGotWords.length;			
		}
		
		return strInput;
	}

	// v6.5.4.2 Yiu, get the tab size, put it in xml attribute, ex: <tabs:100,150> something like that
	function getTabSizeFromWordArray(aInputWordArray:Array, nRestriction:Number):Array
	{
		var aOutputTabArray:Array	= new Array();
		if(aInputWordArray.length <= 0){
			aOutputTabArray.push(0);
			return aOutputTabArray;
		}

		var const_nSpaceForEachWord:Number;
		const_nSpaceForEachWord	= nRestriction / aInputWordArray.length;

		var i:Number;
		var j:Number;
		var nFinalTabSize:Number;

		for(i=0; i<aInputWordArray.length; ++i){
			nFinalTabSize	= const_nSpaceForEachWord;
			for(j=0; j<aOutputTabArray; ++j){
				nFinalTabSize	+= aOutputTabArray[j];
			}
			aOutputTabArray.push(nFinalTabSize);
		}

		return aOutputTabArray;
	}

	// v6.5.4.2 Yiu, check if the options width length is bigger than the tab width
	function checkIfOptionsBiggerThanTabs(aOptions:Array, nTabSize:Number):Boolean
	{
		var strInXmlString:String;
		var strInXmlStringOrigin:String;
	
		var txt_length:TextField;
		txt_length		= _root.createTextField("txt_length", 10, 0, 0, 0, 100);

		var nIndex:Number;
		for(nIndex=0; nIndex<aOptions.length; ++nIndex){
			strInXmlStringOrigin	= "<FONT FACE=\"Verdana\" SIZE=\"13\" COLOR=\"#0F157A\"><B>"+aOptions[nIndex]+"</B></FONT>"; 
			strInXmlString		= strInXmlStringOrigin;
			strInXmlString		= replaceTheBracketToRealWords(strInXmlString);

			txt_length.html	= true;
			txt_length.autoSize	= true;
			txt_length._width	= 0;
			txt_length.htmlText	= strInXmlString;

			if(txt_length._width > nTabSize){
				return true;
			}
		}
	
		return false;
	}
}


