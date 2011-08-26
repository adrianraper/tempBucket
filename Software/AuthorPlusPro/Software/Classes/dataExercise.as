// AR v6.4.2.5a
// Note that this class is used for holding the exercise node in the menu.xml AND the actual exercise

import Classes.dataField;
import Classes.dataParagraph;
import Classes.dataFieldManager;
import mx.data.encoders.Num;

class Classes.dataExercise {
	
	var id:String = "";
	var caption:String = "";
	var exerciseType:String = "";
	var fileName:String = "";
	var action:String = "";
	var exerciseID:String = "";
	//var enabledFlag:String = "";
	var enabledFlag:Number;	// v6.4.2.5 AR
	var settings:Object = new Object();
	var title:Object = new Object();
	var text:Object = new Object();
	var question:Array = new Array();
	var fieldManager:dataFieldManager;
	var feedback:Array = new Array();
	var hint:Array = new Array();
	var image:Object = new Object();
	var audios:Array = new Array();
	var videos:Array = new Array();	// v0.16.1, DL: video
	// v6.4.2.7 Adding URLs
	var URLs:Array = new Array();
	var questionAudios:Array = new Array();	// v0.16.1, DL: question audio
	
	var scoreBasedFeedback = new Array();	// v0.16.0, DL: score-based feedback
	var differentFeedback = new Array();	// v0.16.0, DL: different feedback
	
	// v6.5.1 Yiu new default gap length check box and slider 
	var m_aryGapLength:Array;
	
	var questionAttr:Object;
	var feedbackAttr:Object;
	var hintAttr:Object;
	
	var fieldCount:Number;
	
	// v6.4.2.5 add some tab presents
	var tabPresets = "50,100,150,200,250,300,350,400";
	
	// v0.5.2, DL: exercise has just been created, not saved in the past (for error handling purpose)
	var newlyCreated:Boolean;
	// v0.5.2, DL: exercises not changed since loaded/saved
	var noChange:Boolean;
	
	// v6.5.5.10, WZ: For store the temporary quesitons
	var cQuestion:Array = new Array();
	var cFeedback:Array = new Array();
	var cHint:Array = new Array();
	var cQuestionAudios:Array = new Array();
	var cFields:Array = new Array();
	var c_aryGapLength:Array = new Array();

	function dataExercise() {
		init();
	}
	function init() {
		settings = new Object();
		settings.marking = new Object();
		settings.feedback = new Object();
		settings.buttons = new Object();
		settings.exercise = new Object();
		settings.misc = new Object();
		settings.nnw = new Object();	// v0.16.1, DL: NNW internal settings node
		
		title = new dataParagraph();
		title.setAttributes({x:"12", y:"+4", width:"605", height:"0", style:"headline", tabs:"0", indent:"0"});
		text = new dataParagraph();
		// v6.4.2.5 add some tab presents
		//text.setAttributes({type:"text", x:"12", y:"+8", width:"407", height:"0", style:"normal", tabs:"", indent:"0"});
		text.setAttributes({type:"text", x:"12", y:"+8", width:"407", height:"0", style:"normal", tabs:tabPresets, indent:"0"});
		question = new Array();
		//questionAttr = {type:"question", x:"50", y:"=", width:"382", height:"0", style:"normal", tabs:"", indent:"0"};
		questionAttr = {type:"question", x:"50", y:"=", width:"382", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
		fieldManager = new dataFieldManager();
		fieldManager.setRefToExercise(this);
		feedback = new Array();
		//feedbackAttr = {x:"0", y:"+0", width:"407", height:"0", style:"normal", tabs:"", indent:"0"};	// v0.15.0, DL: x:"0" instead of x:"12"
		feedbackAttr = {x:"0", y:"+0", width:"407", height:"0", style:"normal", tabs:tabPresets, indent:"0"};	// v0.15.0, DL: x:"0" instead of x:"12"
		hint = new Array();
		//hintAttr = {x:"0", y:"+0", width:"407", height:"0", style:"normal", tabs:"", indent:"0"};	// v0.15.0, DL: x:"0" instead of x:"12"
		hintAttr = {x:"0", y:"+0", width:"407", height:"0", style:"normal", tabs:tabPresets, indent:"0"};	// v0.15.0, DL: x:"0" instead of x:"12"
		image = new Object();
		image.filename = "";
		//v6.4.2.1 Education might be a better default for new exercises
		
		// v6.5.1 Yiu fixing URL wrong placement in noraml screen
		image.category = "Education";
		//image.category = "No graphic";
		//image.category = "Animals";
		image.width = "";
		image.height = "";
		image.position = "top-right";	// v0.16.0, DL: image position
		audios = new Array();
		videos = new Array();	// v0.16.1, DL: video
		// v6.4.2.7 Adding URLs
		URLs = new Array();
		questionAudios = new Array();	// v0.16.1, DL: question audio
		
		scoreBasedFeedback = new Array();	// v0.16.0, DL: score-based feedback
		differentFeedback = new Array();	// v0.16.0, DL: different feedback
		
		// v6.5.1 Yiu new default gap length check box and slider 
		m_aryGapLength	= new Array();
		
		fieldCount = 0;
		newlyCreated = false;
		noChange = true;
		// v6.4.2.5, AR
		//enabledFlag="3";
		enabledFlag = _global.NNW.control.enabledFlag.menuOn + _global.NNW.control.enabledFlag.navigateOn;	
	}
	
	/* extract text from CDATA makes use of 2 dummy textfields to get rid of all formatting information */
	function extractTextFromCDATA(s:String) : String {
		return _global.NNW.screens.extractTextFromCDATA(s);
	}
	/* parse the input string, get rid of [id] and fill in fields/urls */
	function replaceEverySpaceToHtmlEncode(strInput:String):String
	{
		// find everything exclude the tag...
		if (strInput.length <= 0)
			return strInput;
		
		var strTargetText:String	= strInput;
		var strSegment:String;
		var strTargetTextPart1:String;
		var strTargetTextPart2:String;
		var nTagStartIndex:Number;
		var nTagEndIndex:Number;
		
		nTagStartIndex	= strTargetText.indexOf("<");
		
		while (nTagStartIndex != -1)
		{
			nTagEndIndex	= strTargetText.indexOf(">", nTagStartIndex + 1);		
			nTagStartIndex	= strTargetText.indexOf("<", nTagEndIndex + 1);
			
			if (nTagStartIndex != -1)
			{
				strTargetTextPart1	= strTargetText.substring(0, nTagEndIndex + 1);
				strTargetTextPart2	= strTargetText.substring(nTagStartIndex, strTargetText.length);
				
				strSegment	= strTargetText.substring(nTagEndIndex + 1, nTagStartIndex);
				strSegment	= _global.replace(strSegment, " ", "&#32;");
				
				strTargetText	= strTargetTextPart1 + strSegment + strTargetTextPart2;
			}
		}
		
		return strTargetText;
	}
	
	function parseInputString(v:String) : String {
		v	= replaceEverySpaceToHtmlEncode(v);
		v = _global.fixTags(v);
		v = _global.htmlSpaceFix(v);	// v0.8.1, DL: included the htmlSpaceFix function as workaround
		var startIndex = v.indexOf("[", 0);
		var strAddBetweenWords:String;
		
		while (startIndex > -1) {
			strAddBetweenWords	= "";
			var endIndex = v.indexOf("]", startIndex);
			if (endIndex>-1) {
				var id = v.substring(startIndex+1, endIndex);
				if (Number(id) > 0) {
					var opt = getFieldWithID(id);
					var idTag = v.substring(startIndex, endIndex + 1);
					var aTag:String;
					if (opt.attr.type=="i:url") {
						aTag = "<A HREF='asfunction:_global.urlClick,"+id+"' target='_blank'>"+opt.answers[0].value+"</A>";
					} else {
						aTag = "<A HREF='asfunction:_global.fieldClick,"+id+"' target='_blank'><U>"+opt.answers[0].value+"</U></A>";
					}
					v = _global.replace(v, idTag, aTag);
					startIndex = v.indexOf("[", 0);
				} else {
					startIndex = v.indexOf("[", endIndex+1);
				}
			} else {
				break;
			}
		}
		return v;
	}
	
	// v6.5.1 Yiu replace all _sans to Verdana
	// v6.5 AR are we sure that the case is always SIZE= ??
	function replaceSansToVerdana(s:String):String{
		var nTarPos:Number			= 0;
		var nTarPos2:Number			= 0;
		var strTarget:String 		= "_sans";
		var strChangeTo:String 		= "Verdana";
		var strSizeTarget:String	= "SIZE=";
		var strChangeToSize:String	= "13";
		
		var strPart1:String 		= "";
		var strPart2:String 		= "";

		nTarPos	= s.indexOf(strTarget);
		while(nTarPos != -1){
			strPart1	= s.slice(0, nTarPos);
			strPart2	= s.slice(nTarPos + strTarget.length, s.length);
			s			= strPart1 + strChangeTo + strPart2;
			nTarPos		= s.indexOf(strTarget);
		}
		
		// Make sure all the font size is 13
		nTarPos	= s.indexOf(strSizeTarget);
		while(nTarPos != -1){
			nTarPos		= s.indexOf("\"", nTarPos);
			strPart1	= s.slice(0, nTarPos + 1);
			nTarPos2	= s.indexOf("\"", nTarPos + 1);
			strPart2	= s.slice(nTarPos2, s.length);
			s			= strPart1 + strChangeToSize + strPart2;
			nTarPos		= s.indexOf(strSizeTarget, nTarPos2);
		}
		
		return s;
	}
	// End v6.5.1 Yiu replace all _sans to Verdana
	
	/* parse the output string, get rid of <A HREF>...</A> and fill in [id] */
	/* match [id] and field id accordingly, also sort out group id's */
	function parseOutputString(s:String, qNo:Number) : String {
		//_global.myTrace("dataEx:parseOutputString for "+exerciseType);
		s	= replaceSansToVerdana(s);
		
		// v0.15.0, DL: debug - change "[" to "(", "]" to ")"
		s = _global.replace(s, "[", "(");
		s = _global.replace(s, "]", ")");
		
		// v0.12.0, DL: for rearranging feedback & hint
		fieldManager.outputFeedback = new Array();
		fieldManager.outputHint = new Array();
		
		var field = _global.NNW.screens.d1_txt;
		
		/* v0.5.2, DL: discovery of the html consecutive tag bug */
		/* v0.8.1, DL: included the htmlSpaceFix function as workaround */
		// v0.5.2, DL: before putting into the TextField, everything is fine
		//_global.myTrace("before putting:");
		//_global.myTrace(s);
		field.htmlText = _global.htmlSpaceFix(s);
		// v0.15.0, DL: debug - seems the htmlSpaceFix can't solve the problem as well
		field.htmlText = _global.replace(field.htmlText, "> <", ">&nbsp;<");
		// v0.5.2, DL: after putting into the TextField, spaces between 2 tags disappeared!
		//_global.myTrace("after putting:");
		//_global.myTrace(field.htmlText);
		
		var startFormat = new TextFormat();
		var format = new TextFormat();
		var foundField = -1;
		
		/* do searching twice, find field first, then find url */
		for (var i=0; i<2; i++) {
			var clickStr = (i == 0) ? "fieldClick" : "urlClick";
			var startSearchIndex = 0;
			var startIndex = 0;
			var endIndex = 0;
			var foundField = 0;
			
			while (startSearchIndex < field.text.length) {
				startFormat = field.getTextFormat(startSearchIndex);
				foundField = startFormat.url.indexOf(clickStr);
				// if found there's a field, find its end
				if (foundField > -1) {
					startIndex = startSearchIndex;
					endIndex = startIndex;
					while (endIndex+1 < field.text.length) {
						endIndex++;
						format = field.getTextFormat(endIndex);
						if (format.url != startFormat.url) {
							break;
						}
					}
					
					/* v0.10.0, DL: debug - when i get rid of the <A HREF> tag textfield closes the previous tag like </font> before the field */
					/* why did it occurred? 'coz the textformat is lost after replaceText, and flash closes up the previous tag */
					// v0.10.0, DL: get the original format of the field
					var tf = new TextFormat();
					tf = field.getTextFormat(startIndex, endIndex);
					/* v0.11.0, DL: to capture changes in the field, better set option when parsing the output string */
					/* retrieve the value first */
					var value = field.text.substring(startIndex, endIndex);
					// replace the field with [id]
					fieldCount++;
					field.replaceText(startIndex, endIndex, "["+fieldCount+"]");
					
					// v0.10.0, DL: update the endindex to reset format
					endIndex = startIndex +fieldCount.toString().length + 2;
					
					// get rid of the <A HREF></A> tag
					var funcStr = startFormat.url;
					var oldID = funcStr.substr(20+clickStr.length);
					//var replaceStr = '<A HREF="'+funcStr+'" TARGET="_blank">';
					//field.htmlText = _global.replace(field.htmlText, replaceStr, "");
					// v0.10.0, DL: instead of getting rid of the <A HREF> tag, set the textformat to url="" and underline=false
					tf.url = "";
					if (clickStr=="fieldClick") {
						tf.underline = false;
					}
					field.setTextFormat(startIndex, endIndex, tf);
					
					/* v0.11.0, DL: now set the value to the option (of oldID) */
					fieldManager.setOptionWithID(oldID, value);
					
					// copy the appropriate field to outputFields[]
					//_global.myTrace("dataEx:oldID: "+oldID+" ; newID:"+fieldCount.toString());
					// v6.5.0.1 pass the question number
					//fieldManager.addToOutputFields(oldID, fieldCount.toString());
					fieldManager.addToOutputFields(oldID, fieldCount.toString(), qNo);
				} else {
					// increment start search index by 1
					//_global.myTrace("no fields");
					startSearchIndex++;
				}
				
				/* v0.10.0, DL: discovery of another textfield bug - when i get rid of the <A HREF> tag textfield closes the previous tag like </font> before the field */
				//_global.myTrace("after each parsing a field:");
				//_global.myTrace(field.htmlText);
			}
		}
		fieldManager.rearrangeFeedbackHint();
		
		return field.htmlText;
	}
	/* parse output in text & questions using parseOutputString */
	function parseOutput() : Void {
		fieldCount = 0;
		fieldManager.clearOutputFields();
		switch (exerciseType) {
		case "MultipleChoice" :
		//case "Quiz" :	// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311, commented
			for (var i=0; i<question.length; i++) {
				// v6.5.0.1 I want to send the question number to this routine to help with groupID setting
				// var v = parseOutputString(question[i].value);	// this function does not reorganize feedback/hint for question-based exercises
				var v = parseOutputString(question[i].value, i+1);	// this function does not reorganize feedback/hint for question-based exercises
				question[i].setValue(v);
			}
			fieldManager.copyStaticFields(fieldCount);
			break;
		case _global.g_strQuestionSpotterID:		// v6.5.1 Yiu add bew exercise type question spotter
		case _global.g_strBulletID:	// v6.5.1 Yiu add bew exercise type Bullet
		case "DragAndDrop" :
		case "Stopgap" :
		// v6.4.3 Add new exercise type, item based drop-down
		case "Stopdrop" :
			for (var i = 0; i < question.length; i++) {
				_global.myTrace("Start parseOut");
				_global.myTrace(question[i].value);
				// v6.5.0.1 I want to send the question number to this routine to help with groupID setting
				var v = parseOutputString(question[i].value, i + 1);	// this function does not reorganize feedback/hint for question-based exercises
				_global.myTrace("parse out string is:" + v);
				question[i].setValue(v);
				_global.myTrace("End parseOut");
				_global.myTrace(question[i].value);
			}
			break;
		case "Quiz":	// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311,, parseOutput the splitscreen text also
		case "Analyze" :
			/* v0.14.0, DL: debug - parse the text first because it's easier to assign field nos. to the text first (only url's) */
			// v6.5.0.1 I want to send the question number to this routine to help with groupID setting
			//var v = parseOutputString(text.value);
			var v = parseOutputString(text.value, -1);
			text.setValue(v);
			
			for (var i=0; i<question.length; i++) {
				// v6.5.0.1 I want to send the question number to this routine to help with groupID setting
				// var v = parseOutputString(question[i].value);	// this function does not reorganize feedback/hint for question-based exercises
				var v = parseOutputString(question[i].value, i+1);	// this function does not reorganize feedback/hint for question-based exercises
				question[i].setValue(v);
			}
			fieldManager.copyStaticFields(fieldCount);
			break;
		default :
			// v6.5.0.1 I want to send the question number to this routine to help with groupID setting
			//var v = parseOutputString(text.value);
			var v = parseOutputString(text.value, -1);
			text.setValue(v);
			break;
		}
	}
	function parseStringsBackToAtag() : Void {
		/* v0.11.0, DL: before we can parse the file, we have to reset the fields */
		fieldManager.copyOutputFieldsToFields();
		/* v0.12.0, DL: for text, we've to reload them now */
		switch (exerciseType) {
		case _global.g_strQuestionSpotterID:	// v6.5.1 Yiu add bew exercise type question spotter\
		case _global.g_strBulletID:	// v6.5.1 Yiu add bew exercise type Bullet
		case "MultipleChoice" :
		//case "Quiz" :	// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311,, commented
		case "DragAndDrop" :
		case "Stopgap" :
		// v6.4.3 Add new exercise type, item based drop-down
		case "Stopdrop" :
			for (var i=0; i<question.length; i++) {
				var v = parseInputString(question[i].value);
				question[i].setValue(v);
			}
			break;
		case "Quiz" :	// v6.5.4.2 Yiu add split screen for Quiz, bug ID 1311, backToAtag, the splitscreen text also
		case "Analyze" :
			for (var i=0; i<question.length; i++) {
				var v = parseInputString(question[i].value);
				question[i].setValue(v);
			}
			
			/* v0.14.0, DL: debug - have to reload the question as well because the text might have fields that affect the field nos. in the questions */
			var qNo = (!settings.misc.splitScreen) ? Number(_global.NNW.screens.txts.txtQuestionNo.text) : Number(_global.NNW.screens.txts.txtSplitScreenQuestionNo.text);
			
			_global.NNW.screens.fillInQuestion(question[qNo-1].value);
			
			var v = parseInputString(text.value);
			text.setValue(v);
			_global.NNW.screens.fillInText(v);
			break;
		default :
			var v = parseInputString(text.value);
			text.setValue(v);
			_global.NNW.screens.fillInText(v);
			break;
		}
	}
	
	/* fill in details to this data object */
	function fillInDetails(node:XMLNode) : Void {
		init();
		//v6.4.2.1 Unescape attributes
		renameExercise(unescape(node.attributes.name));
		// v0.12.0, DL: to cope with the swapping of "DragOn" and "DragAndDrop"
		// now the version no. of exercise xml files is 6.4
		if (node.attributes.version==undefined || Number(node.attributes.version)<6.4 || node.attributes.version=="") {
			if (node.attributes.exerciseType=="DragOn"||node.attributes.type=="DragOn") {
				node.attributes.exerciseType = "DragAndDrop";
				node.attributes.type = "DragAndDrop";
			} else if (node.attributes.exerciseType=="DragAndDrop"||node.attributes.type=="DragAndDrop") {
				node.attributes.exerciseType = "DragOn";
				node.attributes.type = "DragOn";
			}
		}
		// v0.11.0, DL: to cope with the change of attribute name from exerciseType to type
		if (node.attributes.exerciseType!=undefined) {
			setExerciseType(node.attributes.exerciseType);
		} else {
			setExerciseType(node.attributes.type);
		}
		
		// initialize tlc
		_root.tlc =  {timeLimit:1000,  maxLoop:node.childNodes.length-1, c:0};
		_root.tlc.controller = _root.tlcController;	// then point to a movie clip that you expect to exist
											// that contains the progress bar and onEnterFrame code
		if (typeof _root.tlc.controller == "movieclip") {
			_global.myTrace("controller already running");
		} else {
			var myController = _root.createEmptyMovieClip("tlcController", _root.getNextHighestDepth());
			myController.loadMovie("onEnterFrame.swf");
			_root.tlc.controller = myController;
		}
		
		// passes data to tlc
		_root.tlc.data = this;
		
		// write report for each unit
		_root.tlc.resumeLoop = function(firstTime) {
			// tlc loop settings
			var c = this.c;
			var startTime = getTimer();
			var maxLoop = this.maxLoop;
			var timeLimit = this.timeLimit;
			
			while (getTimer()-startTime <= timeLimit && c<maxLoop && !firstTime) {
				var n = node.childNodes[c];
				//_global.myTrace("node "+n.nodeName+" found.");
				//_global.myTrace(n.firstChild.firstChild.toString());
				switch (n.nodeName) {
				case "settings" :
					this.data.fillInSettingsDetails(n);
					break;
				case "title" :
					//var v = extractTextFromCDATA(n.firstChild.firstChild.toString());
					var v = this.data.parseInputString(n.firstChild.firstChild.toString());
					this.data.title.setValue(v);
					break;
				case "body" :
					this.data.fillInBodyDetails(n); 
					break;
				case "feedback" :
					this.data.fillInFeedbackDetails(n);
					break;
				case "hint" :
					this.data.fillInHintDetails(n);
					break;
				/* v0.6.0, DL: for reading multiple choice */
				case "texts" :
					this.data.fillInTextsDetails(n);
					break;
				case "template" :
					break;
				case "handmaker" :	// v0.15.0, DL: this exercise has been handmade by Handmaker program
					if (n.attributes.made=="true") {
						this.data.settings.handmade = true;
					}
					break;
				}
				c++;
			} // closes while
			
			// finish one loop, check tlcCnt against maxLoop
			if (c < maxLoop) {
				_root.tlc.updateProgressBar((c/maxLoop) * _root.tlc.proportion);
				this.c = c;
			} else if (c==maxLoop || maxLoop==undefined) {
				_root.tlc.updateProgressBar(_root.tlc.proportion);
				this.c = maxLoop-1;
				// get rid of the resumeLoop as you have finished it
				delete _root.tlc.resumeLoop;
				// do after fill in details
				this.data.afterFillInDetails();
				// if this is now at 100%, get rid of the tlc
				if (Number(_root.tlc.proportion + _root.tlc.startProportion) >= 100) {
					_root.tlc.controller.removeMovieClip();
				}
			}
		} // closes resumeLoop
		if (_root.tlc.proportion > 0) {
			_root.tlc.resumeLoop(true);
		} else {
			_root.tlc.resumeLoop();
		}
		
		// v6.5.1 Yiu new default gap length check box and slider 
		//m_aryGapLength.reverse();
	}
	
	// v6.5.1 Yiu new default gap length check box and slider 
	function initExerciseScreenGapLength(nQuestionNumber:Number):Void
	{
		// update the the txtQuestion.text to prevent bug in the changeGapLength function
		var strOfTheQuestion:String;
		strOfTheQuestion	= question[nQuestionNumber - 1].value;
		_global.NNW.screens.txts.txtQuestion.text	= strOfTheQuestion == undefined? "" : strOfTheQuestion;
		_global.NNW.screens.checkAndSetlblShowDefaultVisible();
			
		var nTarget:Number;
		var nFirstGapLength:Number;
		
		nTarget			= nQuestionNumber - 1;
		nFirstGapLength	= m_aryGapLength[nTarget];
		
		if (nFirstGapLength == undefined || isNaN(nFirstGapLength))
		{
			if (isNaN(m_aryGapLength[nTarget]) || m_aryGapLength[nTarget] == undefined) {
				if (_global.NNW.screens.chbs.getChecked("chbDefaultLengthGaps"))
				{
					nFirstGapLength	= Number(_global.NNW.screens.sliderDefaultLengthGap.getValue().toString());
					
					if(_global.NNW.screens.textFormatting.getCurrentExerciseType() == "Cloze")
						_global.NNW.screens.setlblShowDefaultVisible(true);
				} else {
					nFirstGapLength	= 1;
				}
			}
		}
		_global.NNW.screens.slider.setValue(nFirstGapLength);
	}
	// End v6.5.1 Yiu new default gap length check box and slider 
	
	function fillInSettingsDetails(n:XMLNode) : Void {
		//_global.myTrace("fillInSettingsDetails");
		var l = n.childNodes.length;
		for(var j=0; j<l; j++) {
			var s = n.childNodes[j];
			if (s.nodeName=="marking") {
				if (s.attributes.instant=="true") {
					settings.marking.instant = true;
				}
				if (s.attributes.overwriteAnswers=="true") {	// v0.16.0, DL: overwrite main answers for drags & gaps
					settings.marking.overwriteAnswers = true;
				}
				if (s.attributes.test == "false"		||
					s.attributes.test == undefined){	// v6.4.1.2, DL: test mode in exercise
					settings.marking.test = false;
					
					settings.buttons.progress	= true; 
					settings.buttons.scratchPad = true;
					settings.buttons.print 		= true;
					settings.buttons.hints 		= true;
												
					_global.NNW.control.updateExerciseSettings("buttons", "progress", true);
					_global.NNW.control.updateExerciseSettings("buttons", "scratchPad", true);
					_global.NNW.control.updateExerciseSettings("buttons", "print", true);
					_global.NNW.control.updateExerciseSettings("buttons", "hints", true);
				} else {
					settings.marking.test = true;
					
					settings.buttons.progress	= false;
					settings.buttons.scratchPad = false;
					settings.buttons.print 		= false;
					settings.buttons.hints 		= false;	
					
					_global.NNW.control.updateExerciseSettings("buttons", "progress", false);
					_global.NNW.control.updateExerciseSettings("buttons", "scratchPad", false);
					_global.NNW.control.updateExerciseSettings("buttons", "print", false);
					_global.NNW.control.updateExerciseSettings("buttons", "hints", false);
				}
			} else if (s.nodeName=="feedback") {
				if (s.attributes.groupBased=="true") {
					settings.feedback.groupBased = true;
				}
				if (s.attributes.neutral=="true") {	// v0.16.0, DL: neutral feedback
					settings.feedback.neutral = true;
				}
				if (s.attributes.scoreBased=="true") {	// v0.16.0, DL: score-based feedback
					settings.feedback.scoreBased = true;
				}
			} else if (s.nodeName=="buttons") {
				if (s.attributes.chooseInstant=="true") {
					settings.buttons.chooseInstant = true;
				}
				if (s.attributes.marking=="false") {
					settings.buttons.marking = false;
				}
				if (s.attributes.feedback=="false") {
					settings.buttons.feedback = false;
				}
				// v6.4.2.8 For tb rules, default is off
				if (s.attributes.rule=="true") {
					settings.buttons.rule = true;
				}
				
				// v6.5.1 Yiu hidden progress, scratchPad, print and hints button when the exercise is a test
				
				//				s.attributes.scratchPad + ", s.attributes.print: " + 
				//				s.attributes.print + ", s.attributes.hints: " +
				//				s.attributes.hints);
				
				/*
				if (s.attributes.progress == "true"	||
					s.attributes.progress == undefined){
					settings.buttons.progress = true;
				} else {
					settings.buttons.progress = false;
				}
				if (s.attributes.scratchPad =="true"	||
					s.attributes.scratchPad == undefined){
					settings.buttons.scratchPad = true;
				} else {
					settings.buttons.scratchPad = false;
				}
				if (s.attributes.print == "true"	||
					s.attributes.print == undefined){
					settings.buttons.print = true;
				} else {
					settings.buttons.print = false;
				}
				if (s.attributes.hints == "true"	||
					s.attributes.hints == undefined){
					settings.buttons.hints = true;
				} else {
					settings.buttons.hints = false;
				} 
				 * */
				// End v6.5.1 Yiu hidden progress, scratchPad, print and hints button when the exercise is a test
				
			} else if (s.nodeName=="exercise") {
				// v6.4.1, DL: same length gaps is available to Countdown and gaps
				// for countdown, it is a number that specifies the length of gaps
				// for gaps, it is only a true/false setting
				if (s.attributes.sameLengthGaps=="true") {
					settings.exercise.sameLengthGaps = "true";
					// v6.5.1 Yiu get rip of the same length gap slider which is not used
				} else if (Number(s.attributes.sameLengthGaps)>0) {
					settings.exercise.sameLengthGaps = s.attributes.sameLengthGaps;
				}
				// v6.5.1 Yiu new default gap length check box and slider 
				if (s.attributes.defaultLengthGaps=="true") {
					settings.exercise.defaultLengthGaps = "true";
				} else if (Number(s.attributes.defaultLengthGaps)>0) {
					settings.exercise.defaultLengthGaps = s.attributes.defaultLengthGaps;
				}
				// End v6.5.1 Yiu new default gap length check box and slider 
				if (s.attributes.matchCapitals=="true") {
					settings.exercise.matchCapitals = true;
				}
				if (s.attributes.preview=="true") {	// v0.12.0, DL: show text before countdown
					settings.exercise.preview = true;
				}
				if (s.attributes.hiddenTargets=="true") {
					settings.exercise.hiddenTargets = true;
				}
				if (s.attributes.dragTimes!="1") {	// v0.16.1, DL: drag times for drags
					settings.exercise.dragTimes = 0;	// it means nothing in XML file - only 1 means once
				}
			} else if (s.nodeName=="misc") {
				if (s.attributes.timed!=undefined && Number(s.attributes.timed)>0) {	// v0.16.0, DL: time limit
					settings.misc.timed = Number(s.attributes.timed)/60;
				} else {
					settings.misc.timed = 0;
				}
				if (s.attributes.splitScreen=="true") {	// v0.16.1, DL: split-screen exercise
					settings.misc.splitScreen = true;
				}
				// v6.4.2.5 sound effects, if nothing in the file assume it is true (backwards compatability)
				if (s.attributes.soundEffects==undefined || s.attributes.soundEffects=="true") {	
					settings.misc.soundEffects = true;
				}
			}
		}
	}
	
	function fillInBodyDetails(n:XMLNode) : Void {
		//_global.myTrace("dataEx.fillInBodyDetails " + n.toString());
		var l = n.childNodes.length-1;
		for (var j=l; j>=0; j--) {
			var b = n.childNodes[j];
			/* paragraph */
			if (b.nodeName=="paragraph") {
				// v6.4.3 Add new exercise type, item based drop-down
				//if (exerciseType=="MultipleChoice"||exerciseType=="Quiz"||exerciseType=="Stopgap"||exerciseType=="DragAndDrop"||exerciseType=="Analyze") {
				if (exerciseType=="MultipleChoice" || exerciseType=="Quiz" || exerciseType=="Stopgap" ||
					exerciseType=="DragAndDrop" || exerciseType=="Analyze" || exerciseType=="Stopdrop" ||
					exerciseType==_global.g_strQuestionSpotterID  || // v6.5.1 Yiu add bew exercise type question spotter
					exerciseType==_global.g_strBulletID	// v6.5.1 Yiu add bew exercise type Bullet
					) {
					//_global.myTrace("this is a question-based paragraph");
					if (b.attributes.type=="question") {
						var v = parseInputString(b.firstChild.toString());
						addQuestion(v);
					}
				} else {
					//_global.myTrace("this is a text-based paragraph");
					if (b.attributes.type=="text") {
						var v = parseInputString(b.firstChild.toString());
						// v0.15.0, DL: split paragraphs into paragraph nodes for better performance in student side
						//_global.myTrace("text=" + v);
						//text.setValue(v);
						text.addParagraphToBeginning(v);
					}
				}
				
			/* v0.16.1, DL: question */
			} else if (b.nodeName == "question") { 
				for (var k=(b.childNodes.length-1); k>=0; k--) {
					if (b.childNodes[k].nodeName=="paragraph") {
						// v6.4.3 Add new exercise type, item based drop-down
						if (exerciseType=="MultipleChoice" || exerciseType=="Quiz" || exerciseType=="Stopgap" || 
							exerciseType=="DragAndDrop" || exerciseType=="Analyze" || exerciseType=="Stopdrop" ||
							exerciseType==_global.g_strQuestionSpotterID ||// v6.5.1 Yiu add bew exercise type question spotter
							exerciseType==_global.g_strBulletID	 // v6.5.1 Yiu add bew exercise type Bullet
							) {
							//_global.myTrace("this is a question-based paragraph");
							if (b.childNodes[k].attributes.type=="question") {
								var v = parseInputString(b.childNodes[k].firstChild.toString());
								addQuestion(v);
							}
						} else {
							//_global.myTrace("this is a text-based paragraph (within a question!!)");
							if (b.childNodes[k].attributes.type=="text") {
								var v = parseInputString(b.childNodes[k].firstChild.toString());
								// v0.16.1, DL: split paragraphs into paragraph nodes for better performance in student side
								//text.setValue(v);
								text.addParagraphToBeginning(v);
							}
						}
					} else if (b.childNodes[k].nodeName == "gapLength") { // v6.5.1 Yiu new default gap length check box and slider 
						// Changed by WZ
						// Array.reverse() method can't execute correct with object element in array,
						// so we use unshift instead of pop, and not use reverse method.
						m_aryGapLength.unshift(Number(b.childNodes[k].firstChild.toString()));
					}
					// End v6.5.1 Yiu new default gap length check box and slider  
				}
				
			/* field */
			} else if (b.nodeName=="field") {
				fieldManager.addFieldFromXML(b.attributes, b.childNodes); 
			/* media */
			} else if (b.nodeName=="media") {
				if (b.attributes.type=="m:picture") {
					image.filename = (b.attributes.filename!=undefined) ? b.attributes.filename : "";
					//v6.4.2.1 Education might be a better default for new exercises
					//image.category = (b.attributes.category!=undefined) ? b.attributes.category : "Animals";
					image.category = (b.attributes.category!=undefined) ? b.attributes.category : "Education";
					image.width = (b.attributes.width!=undefined) ? b.attributes.width : "";
					image.height = (b.attributes.height!=undefined) ? b.attributes.height : "";
					// Ar v6.4.2.6 I can have 'location' for all media
					if (b.attributes.location!=undefined && b.attributes.location!="undefined") {image.location = b.attributes.location;}
					
					// v0.16.0, DL: image position
					// v6.4.2.1 AR moving the image around. Revert until done properly
					if (b.attributes.x=="448" && b.attributes.y=="32") {
					//if (b.attributes.x=="448" && b.attributes.y=="24") {
						image.position = "top-right";
					} else if (b.attributes.x=="30" && b.attributes.y=="32") {
					//} else if (b.attributes.x=="30" && b.attributes.y=="24") {
						image.position = "top-left";
					} else {
						// v6.4.1, DL: debug - it's not correct to say the split-screen image is a banner
						// Yiu v6.5.1 Remove Banner
						if (settings.misc.splitScreen) {
							image.position = "top-right";
						} /* else {
							image.position = "banner";
						} */
						// Yiu v6.5.1 Remove Banner
					}
					
				} else if (b.attributes.type=="m:audio") {
					var audioObj:Object = new Object();
					if (b.attributes.filename!=undefined && b.attributes.filename!="undefined") {audioObj.filename = b.attributes.filename;}
					if (b.attributes.mode!=undefined && b.attributes.mode!="undefined") {audioObj.mode = b.attributes.mode;}
					if (b.attributes.location!=undefined && b.attributes.location!="undefined") {audioObj.location = b.attributes.location;}
					
					// v0.16.1, DL: debug - misc.instructionsAudio isn't a setting!
					//settings.misc.instructionsAudio = (audioObj.location=="shared" && audioObj.mode=="4")  ? true : false;
					// v0.16.1, DL: reminder - audio settings: 1 - click, 2 - after marking, 4 - autoplay
					if (audioObj.mode=="4") {
						if (audioObj.location=="shared") {
							settings.nnw.instructionsAudioDefault = true;
						} else {
							settings.nnw.instructionsAudioUpload = true;
						}
					} else if (audioObj.mode=="1") {
						settings.nnw.embedAudio = true;
					} else if (audioObj.mode=="2") {
						settings.nnw.afterMarkingAudio = true;
					}
					
					//_global.myTrace(audioObj.filename);
					//_global.myTrace(audioObj.mode);
					//_global.myTrace(audioObj.location);
					//_global.myTrace(settings.misc.instructionsAudio);
					audios.push(audioObj);
					
				// v0.16.1, DL: video in exercise
				} else if (b.attributes.type=="m:video") {
					var videoObj:Object = new Object();
					if (b.attributes.filename!=undefined && b.attributes.filename!="undefined") {videoObj.filename = b.attributes.filename;}
					if (b.attributes.mode!=undefined && b.attributes.mode!="undefined") {videoObj.mode = b.attributes.mode;}
					if (b.attributes.location!=undefined && b.attributes.location!="undefined") {videoObj.location = b.attributes.location;}
					
					if (videoObj.mode=="1") {
						settings.nnw.embedVideo = true;
						
						// v0.16.1, DL: video position
						if (b.attributes.x=="448" && b.attributes.y=="32") {
							videoObj.position = "top-right";
						} else if (b.attributes.x=="30" && b.attributes.y=="32") {
							videoObj.position = "top-left";
						} else {
							// v6.4.1, DL: debug - it's not correct to say the split-screen image is a banner
							// Yiu v6.5.1 Remove Banner
							if (settings.misc.splitScreen) {
								videoObj.position = "top-right";
							} /*else {
								videoObj.position = "banner";
							}*/
							// End Yiu v6.5.1 Remove Banner
						}
						
					} else {
						settings.nnw.floatingVideo = true;
					}
					
					videos.push(videoObj);
					
				// v6.4.2.7 Adding URLs
				// This will be called in reverse order of the nodes in the XML.
				} else if (b.attributes.type=="m:url") {
					_global.myTrace("dataEx.fillInBodyDetails m:url=" + b.attributes.url);
					var urlObj:Object = new Object();
					if (b.attributes.url!=undefined && b.attributes.url!="undefined") {
						urlObj.url = b.attributes.url;
					} else {
						urlObj.url = "";
					}
					if (b.attributes.name!=undefined && b.attributes.name!="undefined") {
						urlObj.caption = b.attributes.name;
					} else {
						urlObj.caption = "";
					}
					// Not used, so should come under customised protection
					//if (b.attributes.mode!=undefined && b.attributes.mode!="undefined") {
					//	urlObj.mode = b.attributes.mode;
					//} else {
					//	urlObj.mode = 1;
					//}
					// We base the floating attribute on whether the x and y are set.
					if ((b.attributes.x==undefined || b.attributes.x=="") && (b.attributes.y==undefined || b.attributes.y=="")) {
						urlObj.floating = true;
					} else {
						urlObj.floating = false;
					}
					
					// You don't read the x and y because you will calculate them when writing out
					// But it would be nice to respect a "customised" media node and leave its x and y alone.
					// This would apply to images as well, so do it all then.
					if (urlObj.customised=="true") {
						// url position
						urlObj.x = b.attributes.x;
						urlObj.y = b.attributes.y;
					}					
					// and what is the index of this one? (index is 1, 2 etc for fields on the screen)
					//urlObj.idx = URLs.length+1;
					urlObj.idx = 1;
					// and change those that are already there
					for (var i=0; i<URLs.length;i++) {
						URLs[i].idx++;
					}
					//URLs.push(urlObj);
					URLs.unshift(urlObj);
					
				// v0.16.1, DL: question audio
				} else if (b.attributes.type=="q:audio") {
					var audioObj:Object = new Object();
					if (b.attributes.filename!=undefined && b.attributes.filename!="undefined") {audioObj.filename = b.attributes.filename;}
					if (b.attributes.mode!=undefined && b.attributes.mode!="undefined") {audioObj.mode = b.attributes.mode;}
					// if have id then add to question audio array
					if (b.attributes.id!=undefined && b.attributes.id!="undefined") {
						questionAudios[Number(b.attributes.id)-1] = audioObj;
					}
					// Ar v6.4.2.6 I can have 'location' for all media
					if (b.attributes.location!=undefined && b.attributes.location!="undefined") {audioObj.location = b.attributes.location;}
				}
			}
		}
	}
	
	function fillInFeedbackDetails(n:XMLNode) : Void {
		//var v = extractTextFromCDATA(n.firstChild.firstChild.toString());
		var v = parseInputString(n.firstChild.firstChild.toString());
		
		// v0.16.0, DL: set score-based feedback according to settings
		if (settings.feedback.scoreBased) {
			var fbid = Number(n.attributes.id);
			setScoreBasedFeedback(fbid, v);
		} else if (!settings.feedback.groupBased && exerciseType=="Quiz") {
			var fbid = Number(n.attributes.id);
			setDifferentFeedbackWithFieldID(fbid, v);
		} else {
			var fbid = Number(n.attributes.id) - 1;	// v0.16.0, DL: debug - use setFeedback(v) needs id
			setFeedback(fbid, v);	// v0.16.0, DL: debug - this will mix up feedback if there's some empty ones - addFeedback(v);
		}
	}
	
	function fillInHintDetails(n:XMLNode) : Void {
		//var v = extractTextFromCDATA(n.firstChild.firstChild.toString());
		var v = parseInputString(n.firstChild.firstChild.toString());
		
		var hid = Number(n.attributes.id) - 1;	// v0.16.0, DL: debug - use setHint(v) needs id
		setHint(hid, v);	// v0.16.0, DL: debug - this will mix up feedback if there's some empty ones - addHint(v);
	}
	
	function fillInTextsDetails(n:XMLNode) : Void {
		var l = n.childNodes.length-1;
		for (var j=l; j>=0; j--) {
			var b = n.childNodes[j];
			/* paragraph */
			if (b.nodeName=="paragraph" && b.attributes.type=="text") {
				var v = parseInputString(b.firstChild.toString());
				// v0.15.0, DL: split paragraphs into paragraph nodes for better performance in student side
				//text.setValue(v);
				text.addParagraphToBeginning(v);
			
			/* v0.14.0, DL: text in split screen can also have fields */
			} else if (b.nodeName=="field") {
				fieldManager.addFieldFromXML(b.attributes, b.childNodes);
			} else if (b.nodeName=="media") {
				if (b.attributes.type=="m:url") {
					_global.myTrace("dataEx.fillInBodyDetails m:url=" + b.attributes.url);
					var urlObj:Object = new Object();
					if (b.attributes.url!=undefined && b.attributes.url!="undefined") {
						urlObj.url = b.attributes.url;
					} else {
						urlObj.url = "";
					}
					if (b.attributes.name!=undefined && b.attributes.name!="undefined") {
						urlObj.caption = b.attributes.name;
					} else {
						urlObj.caption = "";
					}
					// Not used, so should come under customised protection
					//if (b.attributes.mode!=undefined && b.attributes.mode!="undefined") {
					//	urlObj.mode = b.attributes.mode;
					//} else {
					//	urlObj.mode = 1;
					//}
					// We base the floating attribute on whether the x and y are set.
					if ((b.attributes.x==undefined || b.attributes.x=="") && (b.attributes.y==undefined || b.attributes.y=="")) {
						urlObj.floating = true;
					} else {
						urlObj.floating = false;
					}
					
					// You don't read the x and y because you will calculate them when writing out
					// But it would be nice to respect a "customised" media node and leave its x and y alone.
					// This would apply to images as well, so do it all then.
					if (urlObj.customised=="true") {
						// url position
						urlObj.x = b.attributes.x;
						urlObj.y = b.attributes.y;
					}					
					// and what is the index of this one? (index is 1, 2 etc for fields on the screen)
					//urlObj.idx = URLs.length+1;
					urlObj.idx = 1;
					// and change those that are already there
					for (var i=0; i<URLs.length;i++) {
						URLs[i].idx++;
					}
					//URLs.push(urlObj);
					URLs.unshift(urlObj);
					
				// v0.16.1, DL: question audio
				}
			}
		}
	}
	
	function afterFillInDetails() : Void {
		//question.reverse();
		fieldManager.onFinishedLoading();
		
		/* v0.16.0, DL: on finished loading, check whether there's picture node, if not, set to NoGraphic */
		if (image.filename=="") {
			image.category = "NoGraphic";
		}
	}
	
	/* fill in exercise attributes */
	// AR v6.4.2.5a This saves attributes of the exercise node in the menu.xml
	function fillInAttributes(attr:Object) : Void {
		for (var i in attr) {
			// AR v6.4.2.5 not all attributes are strings!
			if (i=="enabledFlag") {
				this["enabledFlag"] = Number(attr[i]);
			} else if (typeof this[i] == "string") {
				// v6.4.2.1 If you have escaped attributes, you should unescape too
				//this[i] = (attr[i]!=undefined) ? attr[i] : this[i];
				this[i] = (attr[i]!=undefined) ? unescape(attr[i]) : this[i];
			} else {
				this[i] = attr[i];
			}
		}
		//_global.myTrace("data.Exercise.caption=" + this.caption + " enabledFlag=" + this.enabledFlag);
	}
	function fillInObjects(obj:Object, attr:Object) : Void {
		for (var i in attr) {
			if (attr[i]!=undefined) {
				obj[i] = attr[i];
			}
		}
	}
	function addQuestion(s:String) : Void {
		var obj:Object = new dataParagraph();
		obj.setAttributes(questionAttr);
		// we should convert < and > first
		obj.setValue(s);
		// Since Array.reverse() method had some problem, we can't push element into array
		// And reverse them at the ending process, so we use unshift method instead of push.
		//question.push(obj);
		question.unshift(obj);
	}
	// v6.5.5.10, WZ: insert questions into specified place	
	function insertQuestion(i:Number, s:String) : Void {
		var obj:Object = new dataParagraph();
		obj.setAttributes(questionAttr);
		obj.setValue(s);
		question.splice(i, 0, obj);
	}
	
	/* functions for instructions audio */
	function addInstructionsAudio(shared:Boolean, n:String) : Void {
		var included = false;
		var mode = "4";
		var location = (shared) ? "shared" : "";
		
		// Start from ResultsManager, we need set the location to the author's group
		if(_global.NNW._previewMode){
			location = _global.NNW.groupID;
		}
		
		// v0.5.2, DL: language is not passed
		//var filename = _global.NNW.literals.SelectedLanguage+"/"+_global.NNW.audios.getFilename(exerciseType);
		var filename:String = (shared) ? _global.NNW.audios.getFilename(exerciseType) : "";
		
		
		//_global.myTrace("shared?"+shared);
		//_global.myTrace("exerciseType?"+exerciseType);
		//_global.myTrace("preview?"+settings.exercise.preview);
		//_global.myTrace("hidden?"+settings.exercise.hiddenTargets);
		
		// v6.4.1, DL: for some exercise types, filename is determined by some other settings as well
		if (shared) {
			switch (exerciseType) {
			case "Countdown" :
				if (settings.exercise.preview) {
					filename = _global.NNW.audios.getFilename("Countdown-preview");
				}
				break;
			case "TargetSpotting" :
				if (settings.exercise.hiddenTargets) {
					filename = _global.NNW.audios.getFilename("TargetSpotting-hidden");
				}
				break;
			case _global.g_strQuestionSpotterID :		// v6.5.1 Yiu Added new type Quetion spotter
				if (settings.exercise.hiddenTargets) {
					filename = _global.NNW.audios.getFilename(_global.g_strQuestionSpotterID + "-hidden");
				}
				break;
			}
		}
		
		if (audios.length>0) {
			for (var i in audios) {
				var audioObj:Object = audios[i];
				// v0.16.1, DL: debug - if mode is the same then change the filename
				//if (audios[i].location==location && audios[i].mode==mode) {
				if (audioObj.mode==mode) {
					audioObj.filename = filename;
					audioObj.location = location;
					included = true;
					break;
				}
			}
		}
		if (!included) {
			var audioObj:Object = new Object();
			audioObj.mode = mode;
			audioObj.filename = filename;
			audioObj.location = location;
			audios.push(audioObj);
		}
	}
	function deleteInstructionsAudio(shared:Boolean) : Void {
		var mode = "4";
		//var location = (shared) ? "shared" : "";
		if (audios.length>0) {
			/*for (var i=audios.length-1; i>-1; i--) {
				if (audios[i].location==location && audios[i].mode==mode) {
					var t1 = audios[i];
					var t2 = audios[audios.length-1];
					audios[audios.length-1] = t1;
					audios[i] = t2;
					audios.pop();
					break;
				}
			}*/
			// v0.16.1, DL: no need to remove the audio instance just set filname to ""
			for (var i in audios) {
				if ((shared && audios[i].location=="shared" && audios[i].mode==mode) || (!shared && audios[i].location!="shared" && audios[i].mode==mode)) {
					audios[i].filename = "";
				}
			}
		}
	}
	// v0.16.1, DL: edit instructions audio filename (for uploading)
	function editInstructionsAudio(n:String) : Void {
		var included = false;
		var mode = "4";
		var location = "";
		var filename = (n==undefined) ? "" : n;
		
		// Start from ResultsManager, we need set the location to the author's group
		if(_global.NNW._previewMode){
			location = _global.NNW.groupID;
		}		
		if (audios.length>0) {
			for (var i in audios) {
				var audioObj:Object = audios[i];
				// v0.16.1, DL: debug - if mode is the same then change the filename
				//if (audios[i].mode==mode && audios[i].filename==filename) {
				if (audioObj.mode==mode) {
					audioObj.filename = filename;
					audioObj.location = location;
					included = true;
					break;
				}
			}
		}
		if (!included) {
			var audioObj:Object = new Object();
			audioObj.mode = mode;
			audioObj.filename = filename;
			audioObj.location = location;
			audios.push(audioObj);
		}
	}
	/* end of functions for instructions audio */
	
	/* v0.16.1, DL: functions for embed & after marking audio */
	function addEmbedAudio(n:String) : Void {
		var hasEmbedAudio = false;
		var mode = "1";
		var location = "";
		var filename = n;
		// Start from ResultsManager, we need set the location to the author's group
		if(_global.NNW._previewMode){
			location = _global.NNW.groupID;
		}
		if (audios.length>0) {
			for (var i in audios) {
				if (audios[i].mode==mode) {
					hasEmbedAudio = true;
					audios[i].filename = filename;
					break;
				}
			}
		}
		if (!hasEmbedAudio) {
			var audioObj:Object = new Object();
			audioObj.mode = mode;
			audioObj.filename = filename;
			audioObj.location = location;
			audios.push(audioObj);
		}
	}
	function addAfterMarkingAudio(n:String) : Void {
		var hasAfterMarkingAudio = false;
		var mode = "2";
		var location = "";
		var filename = n;
		// Start from ResultsManager, we need set the location to the author's group
		if(_global.NNW._previewMode){
			location = _global.NNW.groupID;
		}
		if (audios.length>0) {
			for (var i in audios) {
				if (audios[i].mode==mode) {
					hasAfterMarkingAudio = true;
					audios[i].filename = filename;
					break;
				}
			}
		}
		if (!hasAfterMarkingAudio) {
			var audioObj:Object = new Object();
			audioObj.mode = mode;
			audioObj.filename = filename;
			audioObj.location = location;
			audios.push(audioObj);
		}
	}
	/* end of functions for embed & after marking audio*/
	
	/* v0.16.1, DL: functions for question audio */
	function addQuestionAudio(n:String, mode:String, qNo:Number) : Void {
		var audioObj:Object = new Object();
		if (n!=undefined) {
			audioObj.filename = n;
			audioObj.mode = mode;
			questionAudios[qNo-1] = audioObj;
		} else {
			questionAudios[qNo-1].mode = mode;
		}
	}
	/* end of question audio */
	
	/* v0.16.1, DL: functions for video */
	function addVideo(n:String, mode:String, pos:String) : Void {
		/*var hasVideoOfThisMode = false;
		var filename = n;
		if (videos.length>0) {
			for (var i in videos) {
				if (videos[i].mode==mode) {
					hasVideoOfThisMode = true;
					videos[i].filename = filename;
					break;
				}
			}
		}
		if (!hasVideoOfThisMode) {
			var videoObj:Object = new Object();
			videoObj.mode = mode;
			videoObj.filename = filename;
			videos.push(videoObj);
		}*/
		for (var i in videos) {
			videos.pop();
		}
		var videoObj:Object = new Object();
		videoObj.mode = mode;
		videoObj.filename = n;
		videoObj.position = (mode=="1") ? pos : "";
		videos.push(videoObj);
	}
	/* end of functions for video */

	// v6.4.2.7 Adding URLs
	function addURL(urlObj:Object) : Void {
		// make sure that undefined attributes in urlObj don't get this far
		var thisURL = new Object();
		for (var j in urlObj) {
			if (urlObj[j] != undefined) {
				thisURL[j] = urlObj[j];
			}
		}
		// Go through existing URLs to see if this is new or edited
		//_global.myTrace("dataEx.addURL");
		var updatedURL = false;
		for (var i in URLs) {
			if (URLs[i].idx == thisURL.idx) {
				//_global.myTrace("dataEx.addURL["+thisURL.idx+"].update url=" + thisURL.url);
				// don't just overwrite the whole object in case the original was customised
				// Just add/update any attributes in the new object - ignore anything undefined
				for (var j in thisURL) {
					URLs[i][j] = thisURL[j];
				}
				updatedURL = true;
				break;
			}
		}
		if (!updatedURL) {
			// If you have a totally empty url, except for the floating, then ignore it
			if ((thisURL.url=="undefined" || thisURL.url==undefined) && (thisURL.caption=="undefined" || thisURL.caption==undefined)) {
			} else {
				if (thisURL.url==undefined) thisURL.url="";
				if (thisURL.caption==undefined) thisURL.caption="";
				if (thisURL.floating==undefined) thisURL.floating=false;
				//_global.myTrace("dataEx.addURL["+thisURL.idx+"].new url=" + thisURL.url + " caption=" + thisURL.caption);
				URLs.push(thisURL);
			}
		}
	}
	
	/* rename this exercise */
	function renameExercise(n:String) : Void {
		caption = (n!=undefined) ? n : "";
	}
	
	/* set exercise type */
	function setExerciseType(n:String) : Void {
		//_global.myTrace("dataExercise:setExType to " + n);
		
		// v0.8.1, DL: to cope with the change of exercise types names
		if (n=="TrueOrFalse") { n = "Quiz"; }
		if (n=="GapfillQuestions") { n = "Stopgap"; }
		if (n=="GapfillText") { n = "Cloze"; }
		if (n=="DragAndDropQuestions") { n = "DragAndDrop"; }
		if (n=="DragAndDropText") { n = "DragOn"; }
		if (n=="DropDown") { n = "Dropdown"; }
		if (n=="Storyboard") { n = "Countdown"; }
		if (n=="ReadingMC") { n = "Analyze"; }
		if (n=="TextOnly") { n = "Presentation"; }
		
		// v6.5.0.1 Yiu 4-6-08 new exercise type added
		// simply change exercise type name and set them to split screen
		if (n == _global.g_strSplitDropdown)
		{
			n 							= "Stopdrop";
			settings.misc.splitScreen 	= true;
		}
		else if (n == _global.g_strSplitGapfill)
		{
			n 							= "Stopgap";
			settings.misc.splitScreen 	= true;
		}
		// End v6.5.0.1 Yiu 4-6-08 new exercise type added

		// v6.5.4 AR Make groupBased the default for all new qbased exercises
		exerciseType = (n!=undefined) ? n : "Presentation";
		fieldManager.setExerciseType(exerciseType);
		switch (n) {
		case "MultipleChoice" :
		case "Quiz" :
			settings.feedback.groupBased = true;	// v0.16.0, DL: user settings
			break;
		case "Stopgap" :
		// v6.4.3 Add new exercise type, item based drop-down
		case "Stopdrop" :
			settings.feedback.groupBased = true;
			break;
		case "DragAndDrop" :
			settings.exercise.dragTimes = 1;
			settings.feedback.groupBased = true;
			break;
		case "Cloze" :
		case "Dropdown" :
			break;
		case "DragOn" :
			settings.exercise.dragTimes = 1;
			break;
		case "Countdown" :
			settings.exercise.countDown = true;
			settings.buttons.feedback = false;
			settings.marking.instant = false;	// v0.13.0, DL: marking must be delayed
			break;
		case "Analyze" :
			//settings.feedback.groupBased = true;	// v0.16.0, DL: user settings
			settings.misc.splitScreen = true;
			image.position = "top-right";
			// v6.4.2.5 add some tab presents
			//text.setAttributes({type:"text", x:"12", y:"+8", width:"282", height:"0", style:"normal", tabs:"", indent:"0"});
			//questionAttr = {type:"question", x:"50", y:"=", width:"258", height:"0", style:"normal", tabs:"", indent:"0"};
			text.setAttributes({type:"text", x:"12", y:"+8", width:"282", height:"0", style:"normal", tabs:tabPresets, indent:"0"});
			questionAttr = {type:"question", x:"50", y:"=", width:"258", height:"0", style:"normal", tabs:tabPresets, indent:"0"};
			break;
		case "Presentation" :
		case _global.g_strBulletID:		// Yiu v6.5.1 added new type Bullet
			settings.buttons.marking = false;
			settings.buttons.feedback = false;
			break;
		case _global.g_strQuestionSpotterID: // v6.5.1 Yiu add new exercise type question spotter
			// v6.5.4 AR Make groupBased the default for all new qbased exercises
			settings.feedback.groupBased = true;
		case "TargetSpotting" :	// v0.16.0, DL: new exercise type
			// v6.4.1.3, DL: DEBUG - neutral feedback is default
			// then no marking button, no feedback button, instant marking
			//v6.4.2.1 AR I think this is overriding the user's choice
			//if (settings.feedback.neutral!=false) {
			if (settings.feedback.neutral==true) {
				//_global.myTrace("TS:neutral so on instant etc");
				settings.marking.instant = true;
				settings.buttons.marking = false;
				settings.buttons.feedback = false;
			} else {
				//_global.myTrace("TS:do nothing");
				//settings.marking.instant = true;
				//settings.buttons.marking = true;	// v6.4.0.1, DL: debug - should be true as default
			}
			break;
		case "Proofreading" :	// v0.16.0, DL: new exercise type
			settings.marking.instant = true;
			settings.exercise.hiddenTargets = true;
			settings.exercise.proofreading = true;
			break;
		// v6.5.1 Yiu 6-5-2008 New exercise type error correction
		case _global.g_strErrorCorrection:
			settings.exercise.hiddenTargets 	= true;
			settings.exercise.correctMistakes 	= true;
			break;
		// End v6.5.1 Yiu 6-5-2008 New exercise type error correction
		}
		// v6.4.2.8 Is this defaults before you read actual XML? Seems to be.
		//_global.myTrace("setExType");
		settings.buttons.rule = false;
		
		//settings.buttons.progress 	= true;
		//settings.buttons.scratchPad = true;
		//settings.buttons.print 		= true;
		//settings.buttons.hints 		= true;
	}
	
	/* initialize this exercise after being assigned an id */
	function initWithID(eid:String) : Void {
		// v0.16.1, DL: use ClarityUniqueID (YYYYMMDDHHMMSSnnn)
		exerciseID = eid;
		//id = "e"+eid;
		id = eid;
		//caption = "New Exercise";
		caption = "";
		fileName = id+".xml";
		action = id;
		// AR v6.4.2.5
		//enabledFlag = "3";
		enabledFlag = _global.NNW.control.enabledFlag.menuOn + _global.NNW.control.enabledFlag.navigateOn;	
	}

	// AR v6.4.2.5 Change to numbers
	// v6.4.4, RL: this function set the enabledFlag status
	//function setEnabledFlag(s:String, v:Boolean) : Void {
	function setEnabledFlag(flag:Number, v:Boolean) : Void {
		if (v) {	
			enabledFlag|=flag;
			//_global.myTrace("dataExercise.setEnabledFlag +" + flag +" = "+enabledFlag);
		}
		else {
			enabledFlag &=~flag;
			//_global.myTrace("dataExercise.setEnabledFlag -" + flag +" = "+enabledFlag);
		}
		_global.myTrace("dataExercise.setEnabledFlag to "+enabledFlag);
	}


	/* v0.9.0, DL: set default title (instructions) for a newly created exercise */
	function setDefaultTitle() : Void {
		title.setValue(_global.NNW.literals.getLiteral("ins"+exerciseType));
	}
	
	/* v0.16.0, DL: set default settings for a newly created exercise */
	function setDefaultSettings() : Void {
		// v6.4.2.8 for tb rule
		settings.buttons.rule = false;
		
		if (exerciseType=="TargetSpotting"	||
			exerciseType==_global.g_strQuestionSpotterID // v6.5.1 Yiu add bew exercise type question spotter
			) {	// v0.16.0, DL: default target spotting to be neutral
			settings.feedback.neutral = true;
			// v6.4.1.3, DL: DEBUG - since neutral marking is default setting
			// no marking button, no feedback button, only instant marking is allowed
			settings.buttons.marking = false;
			settings.buttons.feedback = false;
			settings.marking.instant = true;
		}
		// v6.5.1 AR I don't see why groupBased is not the default for everything. A Quiz with different answers will be the
		// only thing that takes it away from this. At least make it default for all question based exercises.
		if (exerciseType=="MultipleChoice"||
			exerciseType=="Quiz"||
			exerciseType=="DragAndDrop"||
			exerciseType=="Analyze"||
			exerciseType==_global.g_strQuestionSpotterID||
			exerciseType=="Stopdrop") {
			settings.feedback.groupBased = true;
		}
		// v0.16.1, DL: random a picture for newly created exercise
		//v6.4.2.1 Education might be a better default for new exercises
		//if (image.category=="Animals"&&image.filename=="") {
		if (image.category=="Education" && image.filename=="") {
			if (!settings.misc.splitScreen) {
				//var pic = _global.NNW.photos.randFileFromCategory("165x250", "Animals");
				var pic = _global.NNW.photos.randFileFromCategory("165x250", "Education");
			} else {
				//var pic = _global.NNW.photos.randFileFromCategory("250x165", "Animals");
				var pic = _global.NNW.photos.randFileFromCategory("250x165", "Education");
			}
			image.filename = (pic.path!=undefined && pic.path.length>0) ? pic.path+"/"+pic.name : pic.name;
		}
		// v6.4.2.5 sound effects
		settings.misc.soundEffects = false;

		//v6.4.2.2 Instructions audio defaults to on
		//_global.myTrace("default audio on");
		settings.nnw.instructionsAudioDefault = true;
		addInstructionsAudio(true);
		_global.NNW.control.updateExerciseImage("category", image.category);
	}
	
	/* get options for MC, T/F & Reading MC */
	function getOptions(g:Number) : Array {
		return fieldManager.getTargetsOfSameGroup(g);
	}
	/* v0.16.1, DL: debug - getOtherOptions() is identical to getAnswers() */
	/* get other options for drop down */
	function getOtherOptions(g:Number) : Array {
		return fieldManager.getOtherOptionsWithGroup(g);
	}
	/* get a particular option with its [id] */
	function getOptionWithID(id:String) : Object {
		return fieldManager.getOptionWithID(id);
	}
	/* v0.11.0, DL: debug - get option with [id] is good, but cannot provide type & url information */
	/* now switch to use getFieldWithID(id) */
	function getFieldWithID(id:String) : Object {
		return fieldManager.getFieldWithID(id);
	}
	/* get answers with group */
	function getAnswers(g:Number) : Array {
		return fieldManager.getAnswers(g);
	}
	/* set options with group for MC, T/F & Reading MC */
	function setOption(g:Number, n:Number, v:String, c:Boolean) : Void {
		fieldManager.setTargetForGroup(g, n, v, c);
	}
	// v6.4.1.6, DL: set quiz options labels
	function setQuizOption(b:Boolean, v:String) : Void {
		if (b) {
			fieldManager.quizFieldTrue = v;
		} else {
			fieldManager.quizFieldFalse = v;
		}
	}
	/* set (other) answer with group & option no. */
	function setAnswer(g:Number, n:Number, v:String, c:Boolean) : Void {
		fieldManager.setAnswer(g, n, v, c);
	}
	/* set question */
	function setQuestion(i:Number, v:String) : Void {
		if (question[i]!=undefined) {
			question[i].setValue(v);
		} else {
			var obj:Object = new dataParagraph();
			obj.setAttributes(questionAttr);
			obj.setValue(v);
			question[i] = obj;
		}
	}
	function cutQuestion(i:Number):Void {
		copyQuestion(i);
		delQuestion(i);
	}
	/* delete question */
	function delQuestion(i:Number) : Void {
		var group : Number = i + 1;
		// delete fields from array
		fieldManager.deleteFieldsWithGroupNos(group);
		question.splice(i, 1);
		// we need change the fieldClick id after the deleting point
		for (var k = i; k < question.length; k++) {
			question[k].value = setFieldClick(question[k].value, String(k + 1));
		}
		questionAudios.splice(i, 1);
		hint.splice(i, 1);
		feedback.splice(i, 1);
		m_aryGapLength.splice(i, 1);
	}

	/* copy the question */
	function copyQuestion(i:Number) : Void {
		var group : Number = i + 1;

		// Clear temporary array first
		clearArray(cQuestion);
		clearArray(cQuestionAudios);
		clearArray(cHint);
		clearArray(cFeedback);
		clearArray(cFields);
		clearArray(c_aryGapLength);
		
		// Copy the quesiton main content
		cQuestion[0] = dataParagraph.duplicate(question[i]);
		cHint[0] = dataParagraph.duplicate(hint[i]);
		cFeedback[0] = dataParagraph.duplicate(feedback[i]);
		cFields = fieldManager.getCloneFields( String(group) );
		cQuestionAudios[0] = duplicate(questionAudios[i], true);
		c_aryGapLength[0] = m_aryGapLength[i];
	}
	
	/* paste the question */
	function pasteQuestion(i:Number) : Void {
		var insertField : Object = new dataField();
		var islast : Boolean = false;

		if (question[i] == undefined) {
			islast = true;
		}
		// insert quesiton main content to the specify place
		question.splice(i, 0, dataParagraph.duplicate(cQuestion[0]));
		
		// we need change the fieldClick id after the inserting point
		for (var k = i; k < question.length; k++) {
			question[k].value = setFieldClick(question[k].value, String(k + 1));
		}
		
		questionAudios.splice(i, 0, duplicate(cQuestionAudios[0],true));
		hint.splice(i, 0, dataParagraph.duplicate(cHint[0]));
		feedback.splice(i, 0, dataParagraph.duplicate(cFeedback[0]));

		// insert fields
		fieldManager.insertFieldsWithGroupNos(i + 1, cFields);
		m_aryGapLength.splice(i, 0, c_aryGapLength[0]);
	}
	
	/* Duplicate the Array or Object */
	function duplicate(obj:Object, bRecursive:Boolean):Object {
		if (typeof obj !== 'object' || obj === null) {
			return obj;
		}
		var c = obj instanceof Array ? [] : {};
		for (var i in obj) {
			if (obj.hasOwnProperty(i)) {
				c[i] = duplicate(obj[i]);
			}
		}
		return c;
	}

	/* set feedback */
	function setFeedback(i:Number, v:String) : Void {
		if (feedback[i]!=undefined) {
			feedback[i].setValue(v);
		} else {
			var obj:Object = new dataParagraph();
			obj.setAttributes(feedbackAttr);
			obj.setValue(v);
			feedback[i] = obj;
		}
	}
	/* set hint */
	function setHint(i:Number, v:String) : Void {
		if (hint[i]!=undefined) {
			hint[i].setValue(v);
		} else {
			var obj:Object = new dataParagraph();
			obj.setAttributes(hintAttr);
			obj.setValue(v);
			hint[i] = obj;
		}
	}
	/* v0.16.0, DL: set score-based feedback */
	function setScoreBasedFeedback(i:Number, v:String) : Void {
		if (scoreBasedFeedback[i]!=undefined) {
			scoreBasedFeedback[i].setValue(v); 
		} else {
			var obj:Object = new dataParagraph();
			obj.setAttributes(feedbackAttr);
			obj.setValue(v);
			scoreBasedFeedback[i] = obj;
		}
	}
	/* v0.16.0, DL: set different feedback */
	function setDifferentFeedback(i:Number, n:Number, v:String) : Void {
		var fid = Number(fieldManager.getFieldIDWithGroupAndOptionNos(i, n));
		if (differentFeedback[fid]!=undefined) {
			differentFeedback[fid].setValue(v);
		} else {
			var obj:Object = new dataParagraph();
			obj.setAttributes(feedbackAttr);
			obj.setValue(v);
			differentFeedback[fid] = obj;
		}
	}
	function setDifferentFeedbackWithFieldID(i:Number, v:String) : Void {
		if (differentFeedback[i]!=undefined) {
			differentFeedback[i].setValue(v);
		} else {
			var obj:Object = new dataParagraph();
			obj.setAttributes(feedbackAttr);
			obj.setValue(v);
			differentFeedback[i] = obj;
		}
	}
	
	// v6.5.1 Yiu new default gap length check box and slider 
	function setGapLength(i:Number, nGapLength:Number) : Void {
		m_aryGapLength[i] = nGapLength;
	}
	
	function getGapLength(i:Number) : Number{
		return m_aryGapLength[i];
	}
	// End v6.5.1 Yiu new default gap length check box and slider 
	
	/* v0.16.0, DL: get different feedback */
	function getDifferentFeedback(i:Number, n:Number) : String {
		var v = "";	// default as empty
		var fid = Number(fieldManager.getFieldIDWithGroupAndOptionNos(i, n));
		if (fid!="") {
			if (differentFeedback[fid].value!=undefined) {
				v = differentFeedback[fid].value;
			}
		}
		return v;
	}
	
	/* v0.16.0, DL: change targets correctness to true/neutral (for target spotting) */
	function changeTargetsCorrectness(s:String) : Void {
		fieldManager.changeTargetsCorrectness(s);
	}

	/* String replace function */
	function str_replace(string:String, searchStr:String, replaceStr:String) : String {	
		var arr:Array = string.split(searchStr);
		return arr.join(replaceStr);
	}

	/*
	 * Clear array
	 * Can we just simply delete the reference to the elements?
	 */
	function clearArray(arr:Array) {
		for (var i in arr) {
			delete arr[i];
		}
		arr.length = 0;
	}
	
	function setFieldClick(str:String, clickId:String) : String {
		// First get the index of fieldClick
		var index = str.indexOf("asfunction:_global.fieldClick,");
		if( index > 0){
			// Search id's index from asfunction:_global.fieldClick
			var idIndex = str.indexOf(",", index) + 1;
			// Use split to replace the id
			var commaIndex = str.indexOf("'", index);
			var newStr = str.slice(0, idIndex) + clickId + str.slice(commaIndex);
			
			return newStr;
		}else {
			// if do not search the fieldClick, return the original string
			return str;
		}
	}
}
