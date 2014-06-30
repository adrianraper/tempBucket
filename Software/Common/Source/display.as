//
// BIG DANGER - ppot[Screen][Printer] share so much code - yet it is duplicated
//
// You must remember to change both places if you make an alteration to practically any of this code
//
// this is used to take paragraphs from an object and display them on the screen
// v6.2 The premise of this set of routines is probably wrong. You should create the holder
// mc somewhere else, then call this JUST for the content. Here everything is rather entwined.
// v6.2 Add "setting" parameter to cope specifically with feedback buttons (due to above)
putParagraphsOnTheScreen = function(thisText, paneType, paneName, substList, coords, setting) {
	//myTrace("putParaOnTheScreen for " + paneName);
	// first, make the pane for the text to go into
	// then create all the TextFields that will hold the paragraphs and load the text into them
	// this will let you figure out the height of the next field down. This bit should be in a
	// refresh routine as well so that if something changes (width or content) you can reset easily.
	// Then you make the "fields" active
	// Then you add any pictures to the pane

	//TIMING: This huge function needs to be broken up due to the timing breaker
	// collect all variables that you need for the loop and stuffAfter into the an object
	// v6.3.4 some tlc settings were done in exercise.swf and some here. Do all here now (in the section specific bits)
	// v6.3.4 All tlc settings are done in the calling routines as this behaves differently at different times
	//trace("call ppots_stuffBefore");
	//myTrace("before ppotsBefore, para.len=" + thisText.paragraph.length);
	var ppotsVars = putParagraphsOnTheScreen_stuffBefore(thisText, paneType, paneName, substList, coords, setting);
	//trace("now know that ppotsVars.paneSymbol=" + ppotsVars.paneSymbol);
	
	// v6.3.4 Common settings for all display routines
	_global.ORCHID.tlc.stuffBeforeCallBack = putParagraphsOnTheScreen_stuffAfter;
	_global.ORCHID.tlc.timeLimit = 1000;
	_global.ORCHID.tlc.maxLoop = thisText.paragraph.length;
	_global.ORCHID.tlc.i = 0;
	_global.ORCHID.tlc.controller = _global.ORCHID.root.tlcController;
	//myTrace("max loop=" + _global.ORCHID.tlc.maxLoop + "(" + thisText.paragraph.length+")");
	
	putParagraphsOnTheScreen_mainLoop(ppotsVars);
}

// v6.5.4.2 Yiu, function to check if a html text contain text, Bug ID 1210 
IsContainStr	= function(objInput){
	var strInput:String;
	strInput	= objInput.toString();

	var strOpen:String
	strOpen = "<";
	var strClose:String
	strClose = ">";

	var nClosePos:Number
	nClosePos	= 0;
	var nOpenPos:Number
	nOpenPos       	= 0;

	var nStrLength:Number
	nStrLength	= strInput.length;

	if(nStrLength <= 0){
		return false;
	}
		
	while((nClosePos = strInput.indexOf(strClose, nOpenPos)) != -1){
		if((nClosePos + 1) >= nStrLength){
			return false;
		}
		
		if(	strInput.charAt(nClosePos + 1) != strOpen	&& 
			strInput.charAt(nClosePos + 1) != " "){
			return true;
		}
		
		nOpenPos	= strInput.indexOf(strOpen, nClosePos);
		
		if(nOpenPos == -1){
			return false;
		}
	}
	
	return false;
}
// end v6.5.4.2 Yiu, function to check if a html text contain text 

putParagraphsOnTheScreen_stuffBefore = function(thisText, paneType, paneName, substList, coords, setting) {
	//myTrace("ok, i am in ppots_stuffBefore for " + ppotsVars.paneName);
	var startTime = new Date();

	// translate simple pane types into real ones
	// first set a default in case you don't recognise this pane name
	// v6.4.2.7 CUP merge
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
	//	var paneSymbol = "FScrollPaneSymbol";
	//} else {
	//	var paneSymbol = "FScrollPaneSymbol";
	//}
	// v6.2 Can you just use progressHolder for drag stuff?
	// v6.3.3 Change this to use the buttons holder for any interface stuff, not the exercise holder.
	//var paneHolder = _root.exerciseHolder;
	var paneHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen;
	if (paneType.indexOf("scroll")>=0) {
		paneSymbol = "FScrollPaneSymbol";
	} else if (paneType.indexOf("drag")>=0) {
		// v6.5.5.8 You can change this later for small feedback window if necessary
		paneSymbol = "FPopupWindowSymbol";
	}

	// TIMING: this function is [sometimes] timed, so collect variables that the later loop and stuff After want
	var ppotsVars = new Object();
	ppotsVars.paneSymbol = paneSymbol;
	ppotsVars.paneName = paneName;
	ppotsVars.thisText = thisText;
	ppotsVars.substList = substList;

	var myScroll = "auto";
	var myX = myY = myW = myH = myLeftMargin = myTitleBar = myBackgroundColour = undefined;
	
	if ((_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) ||
		(_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BC/IELTS") >= 0)){
		var myBorder = false;
	} else {
		var myBorder = true;
	}
	//myTrace("set myBorder " + myBorder); 

	// some variables for the pane are taken from a global style store
	//myTrace("ppots for " + paneName);
	//myTrace("pane=" + paneName);
	if (paneName == "Title_SP") {
		myDepth = _global.ORCHID.TitleDepth;		
		// v6.5.4.2 Yiu, check if the paragraph is empty, if it is, move the exercise box over the title, Bug ID 1210  
		if(!IsContainStr(thisText.paragraph[0].plainText)){
			// modify the position of the exercise place holder to make it bigger
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y		= _global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder._y;
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height	= _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder.const_default_height + _global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder._height;
		} else {
			// 6.5.4.2 Yiu, need to reset the place holder position and size now, Bug ID 1210
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y		= _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder.const_default_y;
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height	= _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder.const_default_height;
			// End 6.5.4.2 Yiu, need to reset the place holder position and size now
		}
		// end v6.5.4.2 Yiu, check if the paragraph is empty, if it is, invisible title text box
		if (coords != undefined) {
			//myTrace("using programmed coords");
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;

		} else {                                                                                     

			// CUP/GIU
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				// CUP noScroll code
				//myX = 168; myY = 63; myW = 620, myH = 57; // these are faked here for now (w=750)
				myX = 207; myY = 15; myW = 540, myH = 38; 
				//myBackgroundColour = 0xFFFFFF;
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
					myBackgroundColour = 0x0096c6; 
				} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("ESG") >= 0) {
					myBackgroundColour = 0xe35a24; 
				} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
					myBackgroundColour  = 0x339966;
				}
				myScroll = false;
			} else {
				// v6.3.3 It would be good to pick these coordinates up from buttons.ExerciseScreen
				// TB and APO
				//myX = 10; myY = 17; myW = 660, myH = 50; // these are faked here for now (w=750)
				myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder._x; 
				myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder._y; 
				myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder._width;
				myH = _global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder._height;
				//myTrace("titlePlaceHolder height=" + myH + " y=" + myY);
				// v6.3.3 It would be good to pick this colour up from buttons.ExerciseScreen.fakeTitle
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.titlePlaceHolder.titleColour);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
				// v6.4.3 It would be even better to be able to override it from the exercise.
				if (thisText.paragraph[0].style.toLowerCase() == "inverted") {
					myBackgroundColour = 0x000000;
				}
				//myTrace("use title background=" + myBackgroundColour);
				//var targetC = new Color("target");
				//targetC.setTransform(objC);
				//myBackgroundColour = 0xCCCCFF;
				// BC/IELTS
				//myTrace("title scroll, branding=" + _global.ORCHID.root.licenceHolder.licenceNS.branding); 
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BC/IELTS") >= 0 ||
					_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
					myScroll = false;
				} else {
					myScroll = true;
				}
			}
			// v6.5.6 To impact the border? But, again, how to get this from the placeholders? I can only think that you would
			// have to have a separate titlePlaceHolder.titleBorder item it you wanted a border. Much simpler to make it product dependent.
			// But what happens if you recompile the original SSS interface? Probably I won't.
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
				myBorder = false; 
				myScroll = false;
			}
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("bc/ila") >= 0) {
				myScroll = false;
			}
		}
		myLeftMargin = 0;  myTitleBar = "";
		
	// CUP example region
	} else if (paneName == "Example_SP") {
		//myTrace("set up example pane parameters");
		myDepth = _global.ORCHID.exampleDepth;		
		if (coords != undefined) {
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			// CUP/GIU
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myX = 168; myY = 126; myW = 620, myH = 50; 
				myX = 168; myY = 56; myW = 620, myH = 10; 
				myBackgroundColour = 0xFFFFFF; // test with a pale colour to see extent of region
			} else {
				//myX = 10; myY = 17; myW = 660, myH = 50; 
				//myBackgroundColour = 0xCCCCFF;
				myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width;
				myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x; 
				myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
				myH = 10;
				// v6.3.4 It would be good to pick this colour  up from a example fake panel
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder.exerciseColour);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
			}
		}
		myLeftMargin = 0;  myTitleBar = "";
		myScroll = "resize";
		
	// CUP noScroll code
	} else if (paneName == "NoScroll_SP") {
		//myTrace("set up noScroll pane parameters");
		myDepth = _global.ORCHID.noScrollDepth;		
		if (coords != undefined) {
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			var dependentRegions = ["Example_SP"];
			var nsDeep = 0
			for (var i in dependentRegions) {
				if (paneHolder[dependentRegions[i]]._name != undefined) {
					//myTrace("for " + paneName + ", region " + dependentRegions[i] + " deep=" + paneHolder[dependentRegions[i]].regionDepth);
					nsDeep += paneHolder[dependentRegions[i]].regionDepth;
				}
			}
			// CUP/GIU
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				myX = 168; myW = 620, myH = 50; 
				myY = 56 + nsDeep; 
				// v6.3.4 ESG and AGU colouring
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
					myBackgroundColour = 0xB5E3F7;
				} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("ESG") >= 0) {
					myBackgroundColour = 0xf9ded3; 
				} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
					myBackgroundColour  = 0xD6EbE0;
				}
			} else {
				//if (_global.ORCHID.LoadedExercises[0].regions & _global.ORCHID.regionMode.example) {
					// in this scenario, the noScroll box ALWAYS follows the example region, so
					// find out how deep it was and add that to the normal top of the noScroll region
				// take initial settings as the top of the exercise panel
				myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width;
				myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x; 
				myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
				myH = 10;
				//trace("push noScroll down " + nsDeep + " pixels");
				//}
				//myX = 168; myW = 620, myH = 10; 
				//myY = 56 + nsDeep;
				//myBackgroundColour = 0xFEE6A0; // test with a pale colour to see extent of region				
			//} else {
				myY = myY + nsDeep;
				//myBackgroundColour = 0xCCCCFF;
				// v6.3.4 It would be good to pick this colour  up from a noScroll fake panel
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.noScrollPlaceHolder.colourBlock);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
			}
			//}
		}
		// v6.5.6 See comment in Title_SP
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			myBorder = false; 
		}
		myLeftMargin = 0;  myTitleBar = "";
		myScroll = "resize";
	} else if (paneName == "Exercise_SP") {
		//myTrace("display: been marked=" + _global.ORCHID.session.currentItem.marked);
		myDepth = _global.ORCHID.ExerciseDepth;
		// handle split screen case
		//v 6.3.3 change mode to settings
		//if(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.SplitWindow) {
		//myTrace("splitScreen=" + _global.ORCHID.LoadedExercises[0].settings.misc.splitScreen);
		//myTrace("readingText=" + _global.ORCHID.LoadedExercises[0].readingText);
		// v6.3.4 the readingText isn't set yet?
		//if (	_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen &&
		//	_global.ORCHID.LoadedExercises[0].readingText != undefined) {
		
		// v6.5 Add for split screen drag and drop
		var dependentRegions = ["Example_SP", "NoScroll_SP"];
		var nsDeep = 0
		for (var i in dependentRegions) {
			if (paneHolder[dependentRegions[i]]._name != undefined) {
				//myTrace("for " + paneName + ", region " + dependentRegions[i] + " deep=" + paneHolder[dependentRegions[i]].regionDepth);
				nsDeep += paneHolder[dependentRegions[i]].regionDepth;
			}
		}
		
		if (_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen) {
			////trace("split screen exercise");
			//// CUP/GIU change settings
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				myX = 478; myY = 61; myW = 310; myH = 431;
				//myX = 478; myY = 61+nsDeep; myW = 310; myH = 431-nsDeep;
			} else {
			//	myX = 340; myY = 72; myW = 330; myH = 410;
				myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width / 2;
				myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x + myW; 
				myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
				myH = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height;
			}
			myY = myY + nsDeep;  myH = myH - nsDeep; // was myH=450 for 800x600 screen
			//myTrace("split screen, ex x=" + myX);
		} else {
			if (coords != undefined) {
				myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
			} else {
				// CUP/GIU
				// v6.3.4 This is no longer just for CUP
				//var dependentRegions = ["Example_SP", "NoScroll_SP"];
				//var nsDeep = 0
				//for (var i in dependentRegions) {
				//	if (paneHolder[dependentRegions[i]]._name != undefined) {
				//		//myTrace("for " + paneName + ", region " + dependentRegions[i] + " deep=" + paneHolder[dependentRegions[i]].regionDepth);
				//		nsDeep += paneHolder[dependentRegions[i]].regionDepth;
				//	}
				//}
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
					myY = 60 + nsDeep;  myH = 440 - nsDeep; // was myH=450 for 800x600 screen
					myX = 168; myW = 620; 
				} else {
					myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x; 
					myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
					myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width;
					myH = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height;
					// CUP noScroll code
					//myX = 168; myY = 126; myW = 620, myH = 385; // these are faked here for now (w=750)
					// the exercise y position now depends on the noScroll region (if any)
					//trace("regions=" + _global.ORCHID.LoadedExercises[0].regions);
					//if (_global.ORCHID.LoadedExercises[0].regions & _global.ORCHID.regionMode.noScroll) {
						// in this scenario, the exercise box ALWAYS follows the noScroll and example regions, so
						// find out how deep they were and add that to the normal top of the exercise region
						// and also reduce the total height
					myY = myY + nsDeep;  myH = myH - nsDeep; // was myH=450 for 800x600 screen
						//trace("push exercise down " + nsDeep + " pixels");
					//}
					//myY = 176 + nsDeep;  myH = 385 - nsDeep; 
					//myY = 60 + nsDeep;  myH = 440 - nsDeep; // was myH=450 for 800x600 screen
					// v6.2 I think this width has to match the authoring side ex width
					// Or at least the setting in the XML output of the authoring
					//myX = 168; myW = 620; 
				//} else {
					// v6.3.3 Pick up coordinates from buttons.ExerciseScreen
					// TB and APO
					//myX = 10; myY = 72; myW = 660, myH = 410; // these are faked here for now (w=750)
					// SSS
					//myTrace("exercise width=" + myW);
					//myX = 5; myY = 97; myW = 660, myH = 410; // these are faked here for now (w=750)
				//}
				}
			}
		}
		//myTrace("exercise y=" + myY + " h=" + myH);
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			myBackgroundColour = 0xFFFFFF;
		} else {
			// v6.3.3 It would be good to pick this colour  up from buttons.ExerciseScreen.fakeExercise
			var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder.exerciseColour);
			var cT = colourObj.getTransform();
			myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
		}
		//myTrace("use exercise background=" + myBackgroundColour);
		//myBackgroundColour = 0xFFFFFF;
		// v6.5.6.5 Possibly don't scroll if you have set that in <body noScrollBar='true'>...
		if (_global.ORCHID.LoadedExercises[0].body.noScrollBar==true) {
			myTrace("it's true, no scroll bar");
			myScroll = false;
		} else {
			myScroll = true;
		}
		myLeftMargin = 0;  myTitleBar = "";
		// v6.5.6 See comment in Title_SP
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
			myBorder = false; 
		}

	} else if (paneName == "Feedback_SP" || paneName == "Hint_SP" || paneName == "Related_SP") {
		myDepth = _global.ORCHID.FeedbackDepth;
		//myTrace("set paneName=" + paneName + " to depth=" + myDepth);
		if (coords != undefined) {
			//trace("sent coords are x=" + coords.x + " and the test is " + (coords!=undefined));
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			//myX = _parent._xmouse; myY = _parent._ymouse;
			// I would really like to try and match the window location to the mouse location
			// but with thoughtful care paid to the edges of the screen, but for now lets
			// just put it in the middle of the screen
			// CUP/GIU
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myX=290; myY=165; myW = 500; myH = 230; myMinW = 350; myMinH = 200;
				// v6.4.2.7 CUP merge
				//myX=290; myY=165; myW = 500; myH = 253; myMinW = 350; myMinH = 200;
				myX=290; myY=165; myW = 500; myH = 253; myMinW = 480; myMinH = 200;
				// Can you try making instant fb windows less deep when they start?
				if (setting == "Instant") {
					myH = 200;
				}

			} else {
				// v6.4.2.8 Fiddling with window widths
				//myX = 30; myY = 130; myW = 600; myH = 200;  
				// As SSS has icons on the left, shift the fixed position windows right a bit
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
					//myX = 110; myY = 110;
					myX = 100; myY = 140;
				// CP2 wants to move all boxes down a bit so under the countdown interface
				// No, fix it so that countdown fields are UNDER the relatedText box
				} else {
					myX = 30; myY = 130;	
				}
				myW = 500; myH = 200;  
				myMinW = 400; myMinH = 100;
				// v6.3.5
				//myMaxW = 700; myMaxH = 550;
				//RL: use fla to control the pane height
				myMaxW = 600; myMaxH = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 50;
				// v6.4.2.4 You might as well let the preferred size be bigger
				//myH = 275;
				myH = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 240;
			}
		}
		// CUP/GIU
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			myBackgroundColour = 0xFFFFFF;
			myLeftMargin = 0;
		} else {
			//myBackgroundColour = 0xFFFFCC;
			myBackgroundColour = 0xFFFFFF;
			myLeftMargin = 5;
		}
		myScroll = true;
		// v6.3.5 The border should not be on (how can this be made more brand specific?)
		// I could do like the colouring and size for the fakeTitlePlaceHolder - just have a model
		// popup box set up.
		myBorder = false;
		
		// v6.5.5.8 For small windows we will override lots of stuff
		//myTrace("smallFBWin=" + _global.ORCHID.LoadedExercises[0].settings.exercise.smallFeedbackWindow);
		if (_global.ORCHID.LoadedExercises[0].settings.exercise.smallFeedbackWindow &&
			setting=="Instant" &&
			(paneName == "Feedback_SP" || paneName == "Hint_SP" )) {
			myTrace("force to SPUW");
			paneSymbol = "FSmallPopupWindowSymbol";
			// I guess that this symbol will not care about many of the other parameters. But it will need to know about width.
			myMinW = 60; myMinH = 60;
			myW = 60; myH = 60;
			myScroll = false;
			myLeftMargin = 0;
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0) {
				myBackgroundColour = 0xFFD25E;
			} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
				myBackgroundColour = 0x31376d;
			}
		}
		//myTitleBar = paneName.substr(0, paneName.indexOf("_"));
		// 6.0.4.0, get the title bar name from literal model
		if (paneName == "Feedback_SP") {
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				myTitleBar = _global.ORCHID.literalModelObj.getLiteral("feedback", "labels");
				// v6.5.6.4 Need to reset this as you might have changed it for instant feedback
				myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColour;
			} else {
				// v6.2 - put the old literals for sorry and well done in the title
				if (setting == "Instant") {
					//if (thisText.correct == null || thisText.correct == "neutral") {
					//	myTitleBar = "";
					//} else if (thisText.correct == true || thisText.correct == "true") {
					// v6.5.6.4 New SSS wants different colours for right and wrong
					if (thisText.correct == true || thisText.correct == "true") {
						myTitleBar = _global.ORCHID.literalModelObj.getLiteral("wellDone", "labels");
						myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColourCorrect;
					} else if (thisText.correct == false || thisText.correct == "false") {
						myTitleBar = _global.ORCHID.literalModelObj.getLiteral("sorry", "labels");
						myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColourWrong;
					} else {
						// v6.4.2.4 Quite often you will not want anything if neutral feedback
						//myTitleBar = _global.ORCHID.literalModelObj.getLiteral("feedback", "labels");
						myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColour;
					}
					//myTrace("show title=" + myTitleBar + " for correct=" + thisText.correct);
				} else {
					myTitleBar = _global.ORCHID.literalModelObj.getLiteral("feedback", "labels");
					myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColour;
				}
			}
			myTrace("fb thinks correct=" + thisText.correct + " giving colour=" + myTitleColour);
			// v6.2 printing
			//paneHolder.removeMovieClip("printPane");
			//var printPane = paneHolder.createEmptyMovieClip("printPane", _global.ORCHID.printDepth);
			//myTrace("created a print pane for " + paneName + "=" + printPane);
			//printPane._visible = false;
		} else if (paneName == "Hint_SP") {
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				myTitleBar = "Dictionary look up";
			} else {
				myTitleBar = _global.ORCHID.literalModelObj.getLiteral("hint", "labels");
			}
			// v6.5.6.4 Need to reset this as you might have changed it for instant feedback
			myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColour;
		} else if (paneName == "Related_SP") {
			// v6.4.2.4 use literals (sweet biscuits takes this as exam tip)
			// v6.5.5.8 Different titles have different uses of the Related text
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/pro") >= 0 ||
				_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
				myTitleBar = _global.ORCHID.literalModelObj.getLiteral("related", "buttons");
			} else {
				myTitleBar = _global.ORCHID.literalModelObj.getLiteral("tip", "labels");
			}
			//myTitleBar = "IELTS Tie-in";
			// v6.5.6.4 Need to reset this as you might have changed it for instant feedback
			myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColour;

		}
		//trace("vars for Feedback_SP x=" + myX + ", y=" + myY + ", w=" + myW + ", myH=" + myH);
	} else if (paneName.indexOf("ReadingText_SP") == 0) {
		// CUP noScroll code, switch on this region for this exercise
		// I should probably set this when I detect that there is a reading text rather than now
		// as I might want to use it earlier. And I don't currently read me either!
		//me.regions |= _global.ORCHID.regionMode.readingText;
		
		// AM: for pop up reading text, paneName is ReadingText_SP + (reading text title).
		// So I use (paneName.indexOf("ReadingText_SP") == 0) for the if condition
		//trace("sent coords are x=" + coords.x + " and the test is " + (coords!=undefined));
		//trace("ppots reading text found");
		// v6.3.3 change mode to settings
		//if((_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.SplitWindow)
		if(	_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen &&
			paneSymbol == "FScrollPaneSymbol") {
			myDepth = _global.ORCHID.ReadingTextDepth;
			myTrace(paneName + ", fixed split screen so depth=" + myDepth);
				
			// v6.5 Add split screen drag and drop
			var dependentRegions = ["Example_SP", "NoScroll_SP"];
			var nsDeep = 0
			for (var i in dependentRegions) {
				if (paneHolder[dependentRegions[i]]._name != undefined) {
					//myTrace("for " + paneName + ", region " + dependentRegions[i] + " deep=" + paneHolder[dependentRegions[i]].regionDepth);
					nsDeep += paneHolder[dependentRegions[i]].regionDepth;
				}
			}
			//myTrace("format split screen reading text");
			// CUP/GIU change settings
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				myX = 163; myY =61; myW = 300; myH = 431;
			} else {
			//	myX = 10; myY =72; myW = 330; myH = 410;
				myW = Math.ceil(_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width / 2);
				myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x; 
				myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
				myH = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height;
			}
			// v6.5 Add split screen drag and drop
			myY = myY + nsDeep;  myH = myH - nsDeep; // was myH=450 for 800x600 screen
			//myTrace("display: split screen, text x=" + myX + ", y=" + myY);
			// v6.5.6.4 New SSS
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
				myBorder = false;
			}
			myScroll = true; myLeftMargin = 5; myTitleBar = "";
		} else {
			myTrace("format non split screen reading text, change depth");
			// v6.2 - why is this set at Feedback depth not reading Text depth?
			// v6.5.6 Good question. If I have a splitscreen (so using a ScrollPanePUW) AND a button that uses reading text
			//  I get my reading text spilling out of the puw. I guess this is a depth problem? No.
			// Or could it be a paneName issue? YES. You already have ReadingText_SP in this case. Use Related_SP, see below
			myDepth = _global.ORCHID.FeedbackDepth;
			if (coords != undefined) {
				myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
				//myTrace("use myH=" + myH + " myW=" + myW);
			} else {
				// v6.3.5 Change dimensions
				//myX = 30; myY = 70;
				myW = 600; myH = 300;
				myX = 16; myY = 127;
			}
			myLeftMargin = 5; 
			myBorder = false;
			//myTrace("set reading text border to " + myBorder);
			myTrace("reading text title=" + paneName);
			// the paneName contains the text as well as type
			myTitleBar = paneName.substr(paneName.indexOf("ReadingText_SP") + "ReadingText_SP".length);
			// v6.3.5 And then reduce the paneName back to type
			// v6.5.6.4 If this is a split screen and this Reading Text is going into a PUW, then you must rename the pane.
			// I can't see any clash using Related_SP as you can't have both of these onscreen at the same time.
			if (_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen) {
				paneName = "Related_SP";
			} else {
				paneName = "ReadingText_SP";
			}
			
			// v6.4.2.7 Set minimum size 
			// v6.4.2.7 base screen height on the fla
			var maxHeight = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 100;
			// v6.5.4.3 Allow special functions to pass their own max and min
			// If you don't explicitly make this a number, it doesn't really work, odd stuff happens
			// v6.5.6.4 I am not sure why these are so big. We know we are in a PUW, so why not let it get quite small?
			//(coords.minW != undefined) ? myMinW = Number(coords.minW) : myMinW = 470; 
			//(coords.minH != undefined) ? myMinH = Number(coords.minH) : myMinH = 250; 
			(coords.minW != undefined) ? myMinW = Number(coords.minW) : myMinW = 240; 
			(coords.minH != undefined) ? myMinH = Number(coords.minH) : myMinH = 120; 
			(coords.maxW != undefined) ? myMaxW = Number(coords.maxW) : myMaxW = 660; 
			(coords.maxH != undefined) ? myMaxH = Number(coords.maxH) : myMaxH = maxHeight; 
			//myTrace("maxH=" + myMaxH + ", minW=" + myMinW);
			// v6.4.3 I don't want to override myH, if you want it bigger have a bigger setting in the default above
			//myH = maxHeight - 100; // see if you can open as big as possible - or at least pretty big
		}
		// v6.5.6.4 Need to reset this as you might have changed it for instant feedback
		myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColour;
	} else if (paneName == "Rule_SP") {
		// 6.0.4.0, display rule text pane
		myDepth = _global.ORCHID.FeedbackDepth;
		if (coords != undefined) {
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			myX = 30; myY = 70;
			myW = 600; myH = 300;
		}
		myLeftMargin = 5; //myTitleBar = "Rule";
		// 6.0.4.0, get the title bar name from the literal model
		myTitleBar = _global.ORCHID.literalModelObj.getLiteral("rule", "labels");
		// v6.5.6.4 Need to reset this as you might have changed it for instant feedback
		myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColour;
		myScroll = true;
		// v6.4.2.7 Set minimum size 
		// v6.4.2.7 base screen height on the fla
		var maxHeight = _global.ORCHID.root.buttonsHolder.buttonsNS.interfaceDefault.usedScreenHeight - 100;
		myMinW = 470; myMinH = 250;
		myMaxW = 660; myMaxH = maxHeight;
		myH = maxHeight - 100; // see if you can open as big as possible - or at least pretty big
	} else {
		myDepth = _global.ORCHID.depth;
		if (coords != undefined) {
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			myX = _parent._xmouse; myY = _parent._ymouse;
			myW = 200; myH = 100;
		}
		myScroll = true;
		// v6.5.6.4 Need to reset this as you might have changed it for instant feedback
		myTitleColour = _global.ORCHID.root.buttonsHolder.buttonsNS.interface.titleFillColour;
	}
	
	// 6.4.2.7 This needs to be moved to later as you still have to set stuff for drag panes
	ppotsVars.myX = myX; ppotsVars.myY = myY; ppotsVars.myW = myW; ppotsVars.myH = myH;
	ppotsVars.myMinW = myMinW; ppotsVars.myMinH = myMinH;
	ppotsVars.myLeftMargin = myLeftMargin; ppotsVars.myTitleBar = myTitleBar;
	
	// make sure that there is no existing feedback window (this doesn't solve the weird problem of the text
	// not showing in html in the window on the second click)
	// Actually, you don't get any problems (that I can see) if you simply reuse what is on the screen
	// v6.5.6.4 New SSS If I want to pass in more parameters?
	//var initObj = {branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	var initObj = {branding:_global.ORCHID.root.licenceHolder.licenceNS.branding, titleFillColour:myTitleColour};
	// v6.2 Boldly remove this check as it interferes with the draggable pane thing
	// But I don't know if it will interfere with anything non-draggable?
	//if (paneHolder[paneName] == undefined) {
		// add a pane to the parent movie (as we are in .Scripts right now). This might need to change
		// if you move this code around.
	
	// v6.2 You get errors if you try to redisplay the drag pane and it is already there 
	// (get feedback up then click feedback button again).
	// Hmmm, the following will ALWAYS be true after you have displayed feedback once. So it seems
	// that the drag pane is just hanging around even though the .close is supposed to remove it.
	// Is it something to do with references to it that haven't been deleted?
	//if (paneSymbol.indexOf("Drag") >= 0 && paneHolder[paneName]._visible) {
		// just .removeMovieClip doesn't seem to help (because it is asynchrounous I think)
		// paneHolder[paneName].removeMovieClip();
		// delete paneHolder[paneName];
	// So finally add a function to the dragPane that lets you know if it is really a drag pane
	// and if it is, then just use what is currently there.
	if (paneHolder[paneName].isDragPane()) {
	} else {
		//myTrace("paneHolder=" + paneHolder + " paneSymbol=" + paneSymbol);
		// v6.5.5.8 Pane symbol names all sorted out right at the beginning
		// v6.3.5 Prepare for new CE PopupWindow instead of the old APDrag
		//if (paneName == "Hint_SP" || paneName == "Feedback_SP") {
		//	var myPane = paneHolder.attachMovie("FPopupWindowSymbol", paneName, myDepth, initObj); // For now, this is a reserved depth at root level
		//} else {
		var myPane = paneHolder.attachMovie(paneSymbol, paneName, myDepth, initObj); // For now, this is a reserved depth at root level
		//}
		myTrace("created " + paneSymbol + ":" + myPane + " at depth=" + myDepth);
	}
	
	ppotsVars.myPane = myPane; 
	ppotsVars.paneSymbol = paneSymbol; 
	// keep the pane hidden to avoid flashing
	myPane._visible = false;
	
	// v6.2 Trying to avoid tabbing errors
	myPane.tabChildren = false;
	myPane.tabEnabled = false;

	// v6.3.5 use setTitle not setPaneTitle
	//myTrace("set x=" + myX + " width=" + myWidth)
	myPane.setTitle(myTitleBar);
	myPane._x = myX; 
	myPane._y = myY;
	//if (paneSymbol != "APDraggablePaneSymbol") {
	// v6.3.5 hijack
	if (paneSymbol.toLowerCase().indexOf("drag") >= 0 || paneSymbol.toLowerCase().indexOf("popupwindow") >= 0) {
		// v6.3.5 hijack
		myPane.setCloseButton(true);
		// just for now remove resizing
		// v6.4.2.7 why? I want the fb window to resize
		//myPane.setResizeButton(false);
		myPane.setResizeButton(true);
		
		// create an onClose function to clear out the object when it is shut
		// without this, you will lose the FB window if it is shut properly
		// set up actions for the pane buttons (if any)
		myObj = new Object();
		// v6.2 Is your Flash player good enough to print? Use 6 for debugging in Flash
		if (_global.ORCHID.projector.FlashVersion.major < 7) {
			myObj.onPrint = function(scope) {
				_global.ORCHID.viewObj.displayMsgBox("noPrint");
			}
		} else {
			myObj.onPrint = function(scope) {
				//myTrace("onPrint");
				// v6.2 Brand new function for printing the exercise.
				// We need to create a new MC (invisible) that can be passed to the printing functions
				// v6.3.3 move exercise panels to buttons holder
				//var printPane = _root.exerciseHolder.createEmptyMovieClip("printPane", _global.ORCHID.printDepth);
				var printPane = _global.ORCHID.root.buttonsHolder.ExerciseScreen.createEmptyMovieClip("printPane", _global.ORCHID.printDepth);
				//trace("top print pane=" + printPane);
				printPane._visible = false;
				//printPane._visible = true;
				//printPane._x = printPane._y = -50;
				
				// seeTheAnswers uses the tlc and perhaps doesn't reset it properly
				// therefore do this here so that ppotP can work
				//_global.ORCHID.tlc.proportion = 0;
				
				// the title
				//trace("build up delayed feedback again, for the printer");
				delayedFeedback("", true);
				// v6.3.4 You can't keep going like this - the delayed feedback is asynchronous
				// so use a callback at the end of delayedFeedback - a bit messy
				/*
				myTrace("one feedback is: " + printPane.Feedback_SP.ExerciseBox0.holder.htmlText);
				printPane[paneName]._xscale = printPane[paneName]._yscale = 80;
				
				// finally send it to be printed
				printPane._x = printPane._y = 0;
				var namePath = _global.ORCHID.course.scaffold.getParentCaptions( _global.ORCHID.session.currentItem.id);
				fullName = namePath[namePath.length-2] + "&nbsp;&nbsp;" + namePath[namePath.length-1];
			
				var thisHeader = fullName;
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
					if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
						var thisFooter = "English Grammar in Use CD-ROM ? Cambridge University Press 2004";
					} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
						var thisFooter = "Advanced Grammar in Use CD-ROM ? Cambridge University Press 2005";
					}
				} else {
					var substList = [{tag:"[x]", text:_global.ORCHID.course.scaffold.caption}];
					var thisFooter = substTags(_global.ORCHID.literalModelObj.getLiteral("printedFrom", "labels"), substList);
				}
				_global.ORCHID.root.printingHolder.printForMe(printPane, thisHeader, thisFooter);
				*/
			}
		}
		// create an onClose function to clear out the object when it is shut
		// without this, you will lose the FB window if it is shut properly
		myObj.onClose = function(scope) {
			myTrace("please close myPane=" + scope);
			//this.removeMovieClip();
			// when you close a window, check to see if you need to set focus to a specific gap
			// (for gapfill and instant marking).
			if (_global.ORCHID.session.currentItem.nextGap != undefined) {
				//trace("start waiting for next typing box");
				// v6.4.2.8 What happens if I do it immediately? Seems it will not run at all.
				// How about making it really really fast. No. I can still get the looping interval.
				//myTrace("display.trigger makeNextTypingBox");
				// Make it an array
				//_global.ORCHID.session.currentItem.nextGap.interval = setInterval(makeNextTypingBox, 100);
				_global.ORCHID.session.currentItem.nextGap.interval.push(setInterval(makeNextTypingBox, 100));
				//_global.ORCHID.session.currentItem.nextGap.interval = setInterval(makeNextTypingBox, 10);
				//makeNextTypingBox;
			}
			//return true;
			// if the feedback button was disabled when you went into this pop-up
			// re-enable it now
		}
		//v6.4.1 Resize is passed coordinate object from PUW
		//myPane.onResize = function(w, h, justStarting) {
		myPane.onResize = function(dims) {
			//myTrace("resizing");
			var w = dims.width;
			var h = dims.height;
			//if (!justStarting) {
				// v6.4.2.7 Isn't getScrollContent the wrong function within PUW?
				//var contentHolder = this.getScrollContent();
				var contentHolder = this.getContent();
				myTrace("resize " + contentHolder + " to w=" + w);
				// loop through all the things in the contentHolder and setSize them IF
				// they are wider. It is then up to them if they are able to.
				for (var i in contentHolder) {
					// this check catches the user squeezing the pane, but what about expanding it again?
					// How to catch the growth back to the original size?
					//if (Number(contentHolder[i]._x + contentHolder[i]._width) > w) {
					// v6.4.2.7 was giving NaN - and then not enough reduction.
					var newWidth = Number(w) - Number(contentHolder[i]._x) - 30;
					//myTrace("ask " + contentHolder[i] + " to resize to w=" + newWidth);
					contentHolder[i].resetSize(newWidth);
					//}
				}
			//}
		}
		// v6.2 What happens if you want to add different buttons to the drag pane (feedback)?
		if (paneName == "Feedback_SP") {
			//myTrace("call feedback with setting=" + setting);
			if (setting == "Instant") {
				// v6.2 I can't cope with printing instant fb!
				//myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myObj.onPrint, noClose:true}]);
				// Note that ENTER is not used here to avoid picking up double from instant marking
				// (which may have been just an IDE thing).
				//myPane.setKeys([{key:["P".charCodeAt(0)], setReleaseAction:myObj.onPrint},{key:[KEY.ESCAPE], setReleaseAction:myObj.onClose}]);
				myPane.setKeys([{key:[KEY.ESCAPE], setReleaseAction:myObj.onClose}]);
				// v6.2 EGU - can I put a tick and cross on the feedback panel?
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
					if (thisText.correct == true || thisText.correct == "true") {
						//myTrace("add a tick");
						// v6.4.2.7 CUP merge
						//myPane.attachMovie("Tick","thisMark",myPane.level++, {_x:260, _y:17, _xscale:150, _yscale:150});
						myPane.attachMovie("Tick","thisMark",myPane.depth++, {_x:260, _y:17, _xscale:150, _yscale:150});
					} else if (thisText.correct == false || thisText.correct == "false") {
						//myTrace("add a cross");
						myPane.attachMovie("Cross","thisMark",myPane.depth++, {_x:260, _y:17, _xscale:150, _yscale:150});
					}
				}
			} else if (setting == "fromScore") {
				myObj.startAgain = function(scope) {
					//trace("fromScore: do try again from " + scope);
					_global.ORCHID.root.objectHolder.tryAgainCallback("startAgain");
				}
				myObj.seeTheAnswers = function(scope) {
					//this._parent.removeMovieClip();
					//trace("do see the answers from " + scope);
					_global.ORCHID.root.objectHolder.tryAgainCallback("seeTheAnswers");
				}
				// v6.3.4 mix up tryAgain and startAgain
				myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("startAgain", "buttons"), setReleaseAction:myObj.startAgain},
							{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myObj.onPrint, noClose:true},
							{caption:_global.ORCHID.literalModelObj.getLiteral("seeTheAnswer", "buttons"), setReleaseAction:myObj.seeTheAnswers}]);
				myPane.setKeys([{key:[KEY.ESCAPE, Key.ENTER], setReleaseAction:myObj.onClose},
							{key:["P".charCodeAt(0)], setReleaseAction:myObj.onPrint},
							{key:["S".charCodeAt(0)], setReleaseAction:myObj.seeTheAnswers}]);
			} else {
				// v6.3.4 Mix up startAgain and tryAgain
				//myObj.tryAgain = function(scope) {
				//	//trace("fromScore: do try again from " + scope);
				//	_global.ORCHID.root.objectHolder.tryAgainCallback("tryAgain");
				//}
				myObj.startAgain = function(scope) {
					//trace("fromScore: do try again from " + scope);
					_global.ORCHID.root.objectHolder.tryAgainCallback("startAgain");
				}
				// v6.3 Clarity programs want to have a 'finish' button on the feedback, or is it a 'forward' button? xxxx
				myObj.forward = function(scope) {
					_global.ORCHID.root.objectHolder.tryAgainCallback("finish", myPane.thisScore)
				}
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
					myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("startAgain", "buttons"), setReleaseAction:myObj.startAgain},
								{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myObj.onPrint, noClose:true}]);
					myPane.setKeys([{key:["P".charCodeAt(0)], setReleaseAction:myObj.onPrint},
								{key:["S".charCodeAt(0)], setReleaseAction:myObj.startAgain},
								{key:[KEY.ESCAPE, KEY.ENTER], setReleaseAction:myObj.onClose}]);
				} else {
					myPane.setButtons([{caption:_global.ORCHID.literalModelObj.getLiteral("startAgain", "buttons"), setReleaseAction:myObj.startAgain},
								{caption:_global.ORCHID.literalModelObj.getLiteral("forward", "buttons"), setReleaseAction:myObj.forward},
								{caption:_global.ORCHID.literalModelObj.getLiteral("print", "buttons"), setReleaseAction:myObj.onPrint, noClose:true}]);
					myPane.setKeys([{key:["P".charCodeAt(0)], setReleaseAction:myObj.onPrint},
								{key:["F".charCodeAt(0)], setReleaseAction:myObj.forward},
								{key:["S".charCodeAt(0)], setReleaseAction:myObj.tryAgain},
								{key:[KEY.ESCAPE, KEY.ENTER], setReleaseAction:myObj.onClose}]);
				}
			}
			myPane.setResizeHandler(myPane.onResize);
			//myPane.setPaneMaximumSize(700, 550);
		} else {
			myPane.setKeys([{key:[KEY.ESCAPE], setReleaseAction:myObj.onClose}]);
			// v6.3.4 Add to other windows as well
			myPane.setResizeHandler(myPane.onResize);
			//myTrace("non-feedback drag");
		}
		myPane.setCloseHandler(myObj.onClose);
		// v6.2 Try to make 'small' scrolling a bit more responsive by making it bigger
		// The component default is 5 units per click.
		// This doesn't seem to have any impact - but it does on the exercise pane.
		// Now that would be because the dragPane doesn't have setSmallScroll,
		// so add it in as a pass through to the embedded scrollPane.
		myPane.setSmallScroll(0,20);
		
		// this is done in 'after' section.
		//myPane.setMinSize(450, 250);
		//myPane.setMaxSize(660, maxHeight);
		
	} else {
		// This is for non-drag panes
		
		//v6.3.5 The no scroll region is used as a container for the countDown controller.
		// Except that if you do this, any dropdown list box will disappear behind the 
		// exercise panel. So either it must be self-contained, or it must be put on its own plane
		// and just use the noScroll region as a static background
		if (paneName == "NoScroll_SP") {
			if (_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Countdown") {
				myTrace("add the countDown controller");
				// Now it is added with screens, just visible it here
				//var cdController = _global.ORCHID.root.buttonsHolder.ExerciseScreen.attachMovie("countDownController", "cdController", _global.ORCHID.CountDownControllerDepth);
				var cdController = _global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController;
				// You need to bring the controller to the front, so use swap depth
				cdController.swapDepths(_global.ORCHID.CountDownControllerDepth);
				//myTrace("cdController=" + cdController);
				/// There is no point making this visible here, do it in screens.display as that comes later
				//cdController._visible = true;
				// use the same coordinates as the NoScroll pane
				cdController._x = myX; 
				cdController._y = myY;
				//myTrace("button is " + cdController.cdGuessWord_pb);
				// I want to set the release action here, but it doesn't take effect
				// try doing it in the movie clip itself
				//cdController.cdGuessWord_pb.setReleaseAction(_global.ORCHID.viewObj.cmdGuessWord);
				myH = cdController._height;
				// does it work to set the selection/focus here, or is it too soon?
				// It seems to be too soon
				Selection.setFocus(cdController.word_i);
			}
		}
		
		// CUP noScroll code - does the pane resize to fit the content, or use scrolling?
		if (myScroll == "resize") {
			myScroll = false;
			myPane.resize = true;
		} else {
			myPane.resize = false;
		}
		myPane.setHScroll(false);
		myPane.setVScroll(myScroll);
		// v6.2 Try to make 'small' scrolling a bit more responsive by making it bigger
		// The component default is 5 units per click.
		myPane.setSmallScroll(0,20);
		
		// v6.2 now set sizes much later - but still a good idea to do a basic sizing
		// straight away to avoid the use seeing a window that is default size
		// fill up and then get changed.
		if (myW > 0){
			myPane.setSize(myW, myH);
		} else {
			myPane.setSize(200,myH); // a default that will be resized once the content is in
		}
		//myTrace("initial set size to " + myW + ", " + myH);
		//trace("set the border to " + myBorder);
		//myPane.setContentBorder(myBorder);
	}
	//myTrace("title height = " + myPane._height);
	//v6.4.1.6 This could be a good place to put in a background to the exercise/feedback box
	// it could be dependent on something read from location.
	// v6.4.2.7 Branding comes from licence not buttons. But then, I am going to give My Canada its whole own interface
	//if (_global.ORCHID.root.buttonsHolder.buttonsNS.branding.indexOf("NAS/MyC") >= 0 &&
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("NAS/MyC") >= 0 &&
		paneName == "Exercise_SP") {
		myTrace("branded NAS/MyC from buttons");
		myPane.setScrollContent("exerciseBackground");
	} else {
		myPane.setScrollContent("blob");
	}
	var contentHolder = myPane.getScrollContent();
	// v6.4.2 Can I load up blob and THEN add an external .swf to it? No.
	//contentHolder.loadMovie(_global.ORCHID.paths.brandMovies + "exerciseBackground.swf");
	
	//myTrace("got contentHolder=" + contentHolder);
	ppotsVars.contentHolder = contentHolder; 
	//trace("created content holder " + contentHolder + " in " + myPane + " at x=" + contentHolder._x);
	//trace("background is " + myBackgroundColour);
	if (myBackgroundColour != undefined) {
		//trace("setting pane background to " + myBackgroundColour);
		myPane.setStyleProperty("background", myBackgroundColour);
	}
	//myTrace("set the content border to " + myBorder);
	// v6.4.2.4 It seems that FScrollPaneSymbol doesn't have a setContentBorder, just a setBorder method.
	// but FPopupWindow does have! Edit FScrollPane so that it aliases setBorder.
	// v6.4.2.7 CUP lets avoid editing FScrollPane anymore
	if (typeof myPane.setContentBorder == "function") {
		//myTrace("setContentBorder");
		myPane.setContentBorder(myBorder);
	} else {
		//myTrace("setBorder");
		myPane.setBorder(myBorder);
	}
	
	// v6.5.4.2 Yiu, try to fully initialize the textWithFields, Bug ID 1223
	// v6.5.4.3 AR is this necessary since the fix was wrong?
	//contentHolder.createTextField("list_txt", contentHolder.getNextHighestDepth());
	//contentHolder.list_txt	= thisText;
	//myPane.initTextFieldForDictionaryCheck();

	return ppotsVars;
}
putParagraphsOnTheScreen_mainLoop = function(ppotsVars) {
	// TIMING, if this ppots call uses the progress bar do this
	//myTrace("into ppots mainLoop for " + ppotsVars.paneName);
			
	var tlc = _global.ORCHID.tlc;
	tlc.ppots = ppotsVars;
	
	// v6.4.3 Can I add a starting point for this depth so that I can slip some layers behind the text if I need to?
	tlc.initialParaDepth = _global.ORCHID.initialParaDepth;
	
	// define the resumeLoop method
	myTrace("loop will go to max=" + tlc.maxLoop);
	tlc.resumeLoop = function(firstTime) {
		//myTrace("resumeLoop display.as:649 for " + this.ppots.paneName);
		var startTime = getTimer();
		var i = this.i;
		var max = this.maxLoop;
		var timeLimit = this.timeLimit;
		var myX = Math.round(this.ppots.myX); 
		var myY = Math.round(this.ppots.myY); 
		var myW = Math.round(this.ppots.myW); 
		var myH = Math.round(this.ppots.myH);
		var myLeftMargin = this.ppots.myLeftMargin;
		var thisText = this.ppots.thisText;
		var contentHolder = this.ppots.contentHolder;
		var paneName = this.ppots.paneName;
		var paneSymbol = this.ppots.paneSymbol;
		var myPane = this.ppots.myPane;			
		var substList = this.ppots.substList;
		// v6.4.3 Can I add a starting point for this depth so that I can slip some layers behind if I need to?
		var initialParaDepth = this.initialParaDepth;
		
		//myTrace("make tlc for pane=" + paneName + " maxLoops=" + this.maxLoop);
		//if (firstTime) {
			//myTrace("first time resume loop");
		//} else {
			//myTrace("resume loop, i=" + i + " of max=" + max + " timeLimit=" + timeLimit + " for " + paneName + " firstTime=" + firstTime);
		//}
		// The paragraphs are going to be added at depths from 0 to numParagraphs. Reverse the depth
		// order so that the first paragraphs are over the later ones - this should stop any problem with
		// the dropdown list being covered by the next para
		// tidy up the box and refresh it
		// v6.3.5 When using a non tlc resume loop, you are still checking against time, so 
		// you MUST reset the tlc.timeLimit before coming in. This is the cause of the example and
		// noscroll regions disappearing.
		// v6.4.3 Can I add a starting point for this depth so that I can slip some layers behind if I need to?
		//var paraDepth = thisText.paragraph.length - i; // starting point of depths for this run
		var paraDepth = thisText.paragraph.length - i + initialParaDepth; // starting point of depths for this run
		while (getTimer()-startTime <= timeLimit && i<max && !firstTime) {
			//myTrace("while loop, i=" + i);
			//if (paneName == "ReadingText_SP") {
			//	myTrace("resume loop i=" + i + " of " + max);
			//}
			//myTrace("internal of resumeLoop");
			//thisTime = new Date().getTime();
			//trace("starting paragraph " + i + " at " + (thisTime - _global.ORCHID.startTime));
			var myTop = "0";	var lastPara = 0;	var lastTop = 0;
			var lastBottom = 0;	var thisTop = 0;
			var myCoords = new Object();
			myCoords = thisText.paragraph[i].coordinates;
			var myPara = i; 	// don't use paragraph ID anymore // thisFeedback.paragraph[i].id;
						// but this variable is used for depths. Are depths used as indexes anywhere?
	
			// offset subsequent paragraphs
			var myTop = new String(myCoords.y);
			// if the first paragraph is actually relative treat it as absolute
			if (myTop.charAt(0) == "+" && i == 0) {
				myTop = Number(myTop.substr(1,4));
			// other paragraphs that are relative find the last paragraph bottom and add to it
			} else if (myTop.charAt(0) == "+" && i>0) {
				lastPara = i-1; //thisFeedback.paragraph[i-1].id;
				lastTop = Number(contentHolder["ExerciseBox"+lastPara]._y);
				//lastHeight = Number(contentHolder["ExerciseBox"+lastPara]._height);
				lastHeight = Number(contentHolder["ExerciseBox"+lastPara].getSize().height);
				//trace("last height=" + lastHeight);
				thisTop = Number(myTop.substr(1,4)); // why limit it to 4?
				//trace("this top="+myTop+" becomes "+thisTop);
				// but this doesn't lead to seamless paragraphs, try reducing it a smidgen
				myTop = Math.round(lastHeight + lastTop + thisTop - 4);
			// same height as last paragraph please
			} else if (myTop.charAt(0) == "=" && i>0) {
				lastPara = i-1;
				myTop = Math.round(Number(contentHolder["ExerciseBox"+lastPara]._y)); 
				//trace("found = so myTop will be " + myTop)
			} else {
				myTop = Number(myTop); // not sure what good this will do if the first character is NaN
			}
			//myTrace("last para (" + lastPara + ") top=" + lastTop + ", height=" + lastHeight + "(twfH=" + twfHeight + ") so this top=" + myTop);
			//trace("para " + lastPara + " bottom=" + Number(Number(contentHolder["ExerciseBox"+lastPara]._y) + Number(contentHolder["ExerciseBox"+lastPara]._height)));
			//if (paneName == "Example_SP") {
			//	myTrace("example para " + myPara + " top=" + myTop);
			//}
			adjustedX = Math.round(Number(myLeftMargin) + Number(myCoords.x));
			//trace("this para ("+i+") will start at " + adjustedX);
			// Note: if you want to debug field positions, set the _$coverAlpha parameter in initObj
			var myInitObject = {_x:adjustedX, _y:myTop, border_param:false, autosize_param:true}
			//var myInitObject = {_x:adjustedX, _y:myTop, border_param:false, autosize_param:true, _$coverAlpha:25};
			// add the field using reverse order depths so that dropdown selections aren't masked
			// NOTE that the name of this twf component is used in several places, so DONT CHANGE IT!
			// v6.2 Desperate attempt to speed up display of feedback, which can easily have
			// 66 paragraphs, but with no twf features needed at all. Except that this disables the glossary!
			if (paneName == "Feedback_SP") {
			//	myHolder = contentHolder.createEmptyMovieClip("ExerciseBox"+myPara, paraDepth--);
			//	myHolder._x = myInitObject._x;
			//	myHolder._y = myInitObject._y;
			//	myHolder.createTextField("holder", 0, 0, 0, myCoords.width, 4);
			//	var me = myHolder.holder;
			//	//trace("created textField=" + me + " width=" + myCoords.width);
			//	myHolder.getSize = function() {return {height:this._height};}
			//	thisFormat = _global.ORCHID[thisText.paragraph[i].style];
			//	thisFormat.tabStops = thisText.paragraph[i].tabArray;
			//	me.wordWrap = true;
			//	me.autosize = true;
			//	me.selectable = false;
			//	me.html = true;
			//	//me.border = false;
			//	me.setHtmlText(substTags(thisText.paragraph[i].plainText, substList), thisFormat); 
			//	//trace("with text=" + me.htmlText);
				
				// I can now pass a param to TWF that stops time consuming processing happening
				// so set this then use the normal TWF code
				// v6.5.4.3 But this stops glossary clicking - so remove it
				// But then it also introduces a problem with <tab> at the start of a line which you don't get if simple html
				// I have edited the ActRead exercise for now
				//myInitObject.noProcessing_param = true;
				
				//myInitObject.border_param = true;
				//myTrace("adding feedback to contentHolder="+ contentHolder);
			} // else {
			// Testing embedded fonts
/*			
				if (paneName == "Title_SP") {
					myTrace("from field " + _global.ORCHID.root.buttonsHolder.ExerciseScreen.fontTest);
					//var myFormat = _global.ORCHID.root.buttonsHolder.ExerciseScreen.fontTest.getTextFormat();
					var myFormat = new TextFormat();
					myFormat.font = "Verdant";
					myFormat.size=14;
					var myDepth = _global.ORCHID.root.buttonsHolder.ExerciseScreen.fontTest.getDepth();
					//contentHolder.createTextField("fonttest",85555,10,10,500,75);
					_global.ORCHID.root.buttonsHolder.ExerciseScreen.createTextField("fonttester",myDepth+1,680,170,100,75);
					//var myTextField = contentHolder.fonttest;
					var myTextField = _global.ORCHID.root.buttonsHolder.ExerciseScreen.fonttester;
					myTrace("to field " + myTextField);
					myTextField.embedFonts = true;
					myTextField.setNewTextFormat(myFormat);
					//myTextField.text = substTags(thisText.paragraph[i].plainText, substList);
					myTextField.text = "Gd_b@";
					myTrace("well, I tried with " + myFormat.font);
					_global.ORCHID.root.buttonsHolder.ExerciseScreen.fontTest.text = "Gd_b@";
					var myDepth = _global.ORCHID.root.buttonsHolder.ExerciseScreen.fontTest.getDepth();
					var newText = _global.ORCHID.root.buttonsHolder.ExerciseScreen.createTextField('text5',myDepth+1,680,190,100,75);
					//text5.embedFonts = false;
					_global.ORCHID.root.buttonsHolder.ExerciseScreen.text5.embedFonts = true;
					_global.ORCHID.root.buttonsHolder.ExerciseScreen.text5.html = true;
					//var myHtmlString = "<font face='Ipa-samd Uclphon1 SILDoulosL' size='18'>hAB_@CD</font>";
					var myHtmlString = "<font face='Verdana' size='18'>hAB_@CD</font>";
					//var myHtmlString = "<font face='Mathematica1' size='18'>_@ABC</font>";
					_global.ORCHID.root.buttonsHolder.ExerciseScreen.text5.htmlText = myHtmlString;
				}
*/
				var me = contentHolder.attachMovie("FTextWithFieldsSymbol","ExerciseBox"+myPara, paraDepth--, myInitObject)
				//myTrace("added twf to content, depth=" + paraDepth);
				//trace("added twf " + me);
				//trace("instanceof check: " + (me instanceof _root.exerciseHolder.TextWithFieldsClass));
				//trace("added a TwF component called " + me); 
				//myTrace("display:width of this twF is " + myCoords.width);
				me.setSize(myCoords.width, myCoords.height);
				// these events are defined in FieldReaction.as
				// set up the component with its properties
				// first see if the cursor should change when over a field (only happens in the exercise pane)
				// currently only set at the exercise level
				// v6.3.3 change mode to settings
				//    ((_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.HiddenTargets) ||
				//    (_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.ProofReading))) {
				if (paneName == "Exercise_SP" && 
					_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets) {
					//trace("hide the cursor for this exercise");
					me.setHideCursor(true);
					//v6.4.2.7 You do still want ctrl-clicking (glossary) for hidden target spotting. Hints will not happen
					//var eventNames = {mouseUp:"_global.ORCHID.fieldMouseUp", generalMouseUp:"_global.ORCHID.clickOutOfField"};
					var eventNames = {mouseUp:"_global.ORCHID.fieldMouseUp", 
								//controlClick:"_global.ORCHID.onControlClick", // v6.4.2.7 Name changed
								controlClick:"_global.ORCHID.onGlossary",
								// v6.4.3 And you want to check height changes because errorCorrection shifts stuff around
								heightChange:"_global.ORCHID.heightChange", 
								generalMouseUp:"_global.ORCHID.clickOutOfField"};
				} else {
					//trace("requesting heightChange event");
					// v6.3 It would be time saving to figure out if there is ANY glossary before setting
					// the controlClick event. If not, it will save quite a bit of word selectiong processing in the TWF.
					var eventNames = {rollOver:"_global.ORCHID.fieldRollOver", rollOut:"_global.ORCHID.fieldRollOut", 
								mouseDown:"_global.ORCHID.fieldMouseDown", mouseUp:"_global.ORCHID.fieldMouseUp", 
								drag:"_global.ORCHID.fieldDrag", drop:"_global.ORCHID.fieldDrop",
								//controlClick:"_global.ORCHID.onControlClick", // v6.4.2.7 Name changed
								controlClick:"_global.ORCHID.onGlossary",
								heightChange:"_global.ORCHID.heightChange"};
				}
				me.setEvents(eventNames);
				// v6.3.4 For multiLine gapfills
				if (_global.ORCHID.LoadedExercises[0].settings.exercise.splitGaps) {
					me.setSplitGaps(true);
				}
				var thisStyle = thisText.paragraph[i].style;
				//myTrace("pPOTS using style " + thisStyle + " and font " + _global.ORCHID[thisStyle].font);
				// add the tabs stops to the main text format for this paragraph?
				// Note: shouldn't add this to the global style, so make a copy of it
				//Note: You CANNOT do this with a TF as it will become just a normal object
				//var thisFormat = new TextFormat();
				//myTrace("write text in style=" + thisStyle);
				var thisFormat = _global.ORCHID[thisStyle];
				//myTrace(thisStyle + " font.bold=" + thisFormat.bold + " size=" + thisFormat.size);
				// v6.4.3 Check that this is actually set. But this has the unintended side effect of 'correcting' the way
				// that empty paragraphs are displayed. They now show properly, but this make the output for nonScroll
				// wrong. Either revert and do later, or fix APP to output what you want and take the hit now. or build
				// a compromise for APP that has been output already.
				//if (thisFormat == undefined) {
				//	thisFormat = _global.ORCHID.BasicText;
				//}
				thisFormat.tabStops = thisText.paragraph[i].tabArray;
				//Note: this is where we should make a copy of the text and do the susbstTags changing
				// so that the original does not get altered.
		
				// v6.3.5 You  have to treat countDown differently at the twf level
				if (paneName == "Exercise_SP" && (_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Countdown")) {
					//myTrace("call to set countDownText, version=" + me.getVersion());
					var thisSettingsBase = _global.ORCHID.LoadedExercises[0].settings.exercise;
					var settings = {matchCapitals:thisSettingsBase.matchCapitals, 
								replaceChar:thisSettingsBase.replaceChar,
								sameLengthGaps:thisSettingsBase.sameLengthGaps}
					me.setCountDownSettings(settings);
					//myTrace("add countDownText to me=" + me + "v=" + me.getVersion());
					me.setCountDownText(substTags(thisText.paragraph[i].plainText, substList), thisFormat); 
				} else {
					me.setHtmlText(substTags(thisText.paragraph[i].plainText, substList), thisFormat); 
				}
				// after adding the text, fiddle with it to try and synch word-wrapping with the way
				// that it should be. This works on first display, but after 1 scroll it all goes wrong again
				// until you actually do a gap.
				//me.shuffleLineBreaks();
				//if (paneName == "Example_SP") {
				//	myTrace("after setHtmlText")
				//}
				// UGLY MAN; have a global store for drop zones that you can 
				// run hit tests on.
				// v6.5.4.2 Yiu these 3 lines make the dictionary function works, ID 1223
				// v6.5.4.3 AR But this takes out ALL formatting in the feedback! Do not do it.
				/*
				if (paneName == "Feedback_SP") {
					// Variables that needed by refresh fucntion 
					me.original.text	= me.holder.text;
					me.original._visible	= false;
					me.maxLength		= me.holder.text.length;
					me.original.setTextFormat(me.holder.getTextFormat());
					me.refresh();
				}
				*/
				// End v6.5.4.2 Yiu these 3 lines make the dictionary function works, ID 1223
				me.addDropsForHitTest();

				// v6.4.2.8 If I want to have a graphical ruler, try picking up the style and using the TWF background
				//myTrace("display.twf.style=" + thisText.paragraph[i].style);
				if (thisText.paragraph[i].style=="ruler") {
					//myTrace("ruler height=" + myCoords.height);
					me.setBackground("horizontalRuler");
				}
				// show the pane once some content has been added;
				myPane._visible = true;
				//myTrace("text for twf=" + me.getHtmlText());
			//}			
			i++;
		}
		// v6.3.5 explains the example and no scroll disappearing - so in the short term increase the time
		// you have available for a non-tlc loop. But longer term it would be safer to put them within tlc
		//if (getTimer()-startTime >= timeLimit && (this.proportion <= 0)) {
		//	myTrace("out of time, but no tlc!!");
		//}
			
		//myTrace("finished this bit of display");
		if (i < max) {
			//myTrace("not finished display loop yet");
			this.i = i;
			//this.updateProgressBar((i/max) * this.proportion); // this part of the process is x% of the time consuming bit
			//myTrace("ppOP progress bar inc % by " + Number((i/max) * this.proportion));
			this.controller.incPercentage((i/max) * this.proportion);
		} else if (i >= max || max == undefined) {
			//myTrace("finished display loop");
			this.i = max+1; // just in case this is run beyond the limit
			//this.updateProgressBar(this.proportion); // this part of the process is 50% of the time consuming bit
			//myTrace("ppOS progress bar % to " + Number(this.startProportion + this.proportion));
			//myTrace("ppOS progress bar set % to " + Number(this.startProportion + this.proportion));
			this.controller.setPercentage(this.proportion + this.startProportion);
			//myTrace("kill resume loop");
			delete this.resumeLoop;
			this.controller.stopEnterFrame();
			//myTrace("% at end of this part of display " + this.controller.getPercentage());
			this.stuffBeforeCallBack(this.ppots);
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
	tlc.controller.setEnabled(true);
	if (tlc.proportion > 0) {
		//myTrace("start tlc loop");
		// v6.3.5 You were getting double stuff here as the frame event ALSO ran resumeLoop
		// so now try to start enter frame ONLY when you go through a resume loop for the first time
		//tlc.controller.startEnterFrame();
		//myTrace("start looper, i=" +tlc.i + " of max=" + tlc.maxLoop + " timeLimit=" + tlc.timeLimit + " for " + tlc.paneName);
		// v6.4.2.4 Should you overwrite the start proportion to the current real one, or use one set in the tlc?
		if (tlc.startProportion == undefined || tlc.startProportion < 0) {
			tlc.startProportion = tlc.controller.getPercentage();
		}
		tlc.resumeLoop(true);
	} else {
		// v6.3.5 See comment about timing problem - give them 10 seconds to display this bit!!
		// Or eventually make it a tlc based one, which means you need a callback and synchronicity
		tlc.timeLimit = 10000;
		tlc.startProportion = tlc.controller.getPercentage();
		// v6.4.2.4 Why isn't the proportion for this chunk set? Ahh, set in exercise where display for each section is called.
		//tlc.proportion = 75;
		//myTrace("ppoS: start the tlc loop from " + tlc.startProportion);
		//myTrace("non-looper,  max=" + tlc.maxLoop + " timeLimit=" + tlc.timeLimit + " for " + tlc.paneName);
		tlc.resumeLoop(false);
	}
}
putParagraphsOnTheScreen_stuffAfter = function(ppotsVars) {
	myTrace("ok, i am in ppots_stuffAfter for " + ppotsVars.paneName);
	var myX = ppotsVars.myX; myY = ppotsVars.myY; myW = ppotsVars.myW; myH = ppotsVars.myH;
	var myMinW = ppotsVars.myMinW; myMinH = ppotsVars.myMinH;
	var myLeftMargin = ppotsVars.myLeftMargin;
	var thisText = ppotsVars.thisText;
	var contentHolder = ppotsVars.contentHolder;
	var paneName = ppotsVars.paneName;
	var paneSymbol = ppotsVars.paneSymbol;
	var myPane = ppotsVars.myPane;			
	var susbstList = ppotsVars.substList;
	//trace("ppots with " + myPane + " adding " + thisText.paragraph.length + " paragraphs.");
	//var stopTime = new Date();
	//trace("ppots for " + paneName + " took " + (Number(stopTime.getTime()) - Number(startTime.getTime())));

	// v6.3.5 There are some types of fields that you need to preset with content
	// presetGap
	//myTrace("preset any fields for " + paneName);
	if (paneName == "Exercise_SP") {
		var myFields = _global.ORCHID.LoadedExercises[0].body.text.field;
		for (var idx in myFields) {
			//if (myFields[idx].type == "i:presetGap") {
			// v6.4.3 If this is an error correction, then the field will initially just be a target, it becomes a gap later.
			// This is skipped for exercises that are proofReading - which is all the error corrections! Seems to have no value anyway
			// Now I do use it because I put the spaces into the text and need to preset the covers here
			// More sensible to use hiddenTargets
			//if (myFields[idx].type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.proofReading) {
			if (myFields[idx].type == "i:targetGap" && !_global.ORCHID.LoadedExercises[0].settings.exercise.hiddenTargets) {
			//if (myFields[idx].type == "i:targetGap") {
				//myTrace("for field " + myFields[idx].id + " preset answer=" + myFields[idx].answer[0].value);
				insertAnswerIntoField(myFields[idx], myFields[idx].answer[0].value, true);
			}
			if (myFields[idx].type == "i:dropdown") {
				// v6.3.5 Add dropdown markers to each field before you start. They will later be cleared
				// and show up on mouseOver. Is this a very slow procedure? You do have to do lots of twf finding.
				var markProps = {stretch:false, align:"right", oneLine:true};
				//var thisField = _global.ORCHID.LoadedExercises[0].getFieldObject(myFields[idx]);
				var thisField = myFields[idx];
				var contentHolder = getRegion(thisField).getScrollContent();
				//myTrace("region=" + thisField.region + " or " + contentHolder);
				var thisParaBox = contentHolder["ExerciseBox" + thisField.paraNum];
				//myTrace("add dropMarker to twf=" + thisParaBox + " for field " +myFields[idx].id);
				thisParaBox.setFieldBackground(myFields[idx].id, "dropdownMarker", markProps);
			}
		}
	}
	//if (paneName == "NoScroll_SP") {
	//	myTrace("in stuffAfter")
	//}
// ************
// MULTIMEDIA
// ************
	
	// embedded multimedia fields have their own movies, but they use a shared controller
	// so this is always (if any media fields exist) created on the base 'media' depth for each content box
	// also some multimedia 'floats' so is exercise not field specific. They will use the controller to display
	// with some kind of selection box
	//trace("before media in pPOTS, ex.mode=" + _global.ORCHID.LoadedExercises[0].mode);
	
	// AM: if there are medias in reading text, when the reading text or the rule text is displayed,
	// the media list for that exercise will be overwritten.
	// So I copy the media list for that exercise to a temporary media list first.
	// After the media in the reading text or rule text is displayed,
	// the media list in the temporary media list will be copied back to media list.
	if (myPane._name.indexOf("ReadingText_SP") == 0 || myPane._name == "Rule_SP") {
		//trace("back up media list for exercise");
		var myMediaController = _global.ORCHID.root.jukeboxHolder;
		var tempMediaList = myMediaController.myJukeBox.mediaList;
	}
	//myTrace("media array.length=" + thisText.media.length);
	if (thisText.media.length > 0) {
		// the media controller will be an 'always-on' MC
		//var myMediaController = contentHolder.createEmptyMovieClip("mediaHolder", Number(_global.ORCHID.mediaDepth));
		var myMediaController = _global.ORCHID.root.jukeboxHolder;
		//var myMH = _root.createEmptyMovieClip("mediaHolder", 1);
		//myMediaController.loadMovie(_global.ORCHID.jukeBox);
		
		//myMediaController._x = myPane._x + myPane._width - myMediaController._width;
		//myMediaController._y = myPane._y;
		// fix the position of the media Controller to the bottom right of the screen
		// Note: surely this should only be done once for Orchid?
		//myMediaController._x = Number(Number(myPane._x) + Number(myW)); //myMediaController._width - 5;
		//myMediaController._y = Number(Number(myPane._y) + Number(myH)); //myMediaController._height - 5;
		//trace("media controller position: myPane=" + Number(Number(myPane._x) + Number(myPane._width)));

		myMediaController.myJukeBox.mediaList = new Array();
		//trace("mediaController at x,y = " + myMediaController._x + ", " + myMediaController._y);
		//myMH.loadMovie("jukeBox.swf");
		myMediaController.enabled = true;

		// now add in the individual multimedia fields
		// v6.4.3 I really need to add these in y coordinate order so that if I have to move stuff down, 
		// it will happen nicely. Any problem if I simply reorder the array? No, but any anchored items
		// don't have a y coordinate yet, so this doesn't work. How about by anchorPara num?
		//var mediaSorted = sortArrayOfObjects(thisText.media, "coordinates.y", "ascending");
		var mediaSorted = sortArrayOfObjects(thisText.media, "anchorPara", "ascending");
		//for (var i = 0; i < thisText.media.length; i++) {
		//	var me = thisText.media[i];
		for (var i = 0; i < mediaSorted.length; i++) {
			var me = mediaSorted[i];
			//myTrace("adding media  for id=" + me.id + " fileName=" + me.fileName + " type=" + me.type);
			// the following check differentiates between different types of media - presently
			// floating, embedded and anchored
			if (me.type.substr(0, 2) == "m:" || me.type.substr(0, 2) == "q:" || me.type.substr(0, 2) == "a:") {
				// deal with any floating media
				//trace("in media loop, ex.mode=" + _global.ORCHID.LoadedExercises[0].mode);
				//trace("media ID " + me.id + " has x,y " + me.coordinates.x + "," + me.coordinates.y);
				// floating media has no coordinates
				//v6.4.2.1. The only media that floats is audio with autoplay. We don't have m:text (unless it comes
				// from old TB I suppose) and m:url has never been used, I don't think.
				if (me.coordinates.x == undefined || me.coordinates.y == undefined) {
					//reading text xml files are in the exercises folder
					//myTrace("floating, me.location=" + me.location + " " + me.fileName); 
					if (me.type == "m:text") {
						// v6.3.4 Reading text will move from separate file to <texts> node soon. But for now (and maybe then)
						// use mode to show that this is a special kind of text and will be linked to the special button. We
						// might do a similar thing with IELTS tips actually.
						if (me.mode & _global.ORCHID.mediaMode.ReadingText) {
							//var myjbURL = _global.ORCHID.paths.root + _global.ORCHID.paths.exercises + me.fileName;
							var myjbURL = _global.ORCHID.paths.exercises + me.fileName;
							// v6.3 We also want to save the ReadingText fileName in the exercise object
							// For the current usage there will only be one
							// It may be better to take the reading text link out of  the media items and put
							// it as an attribute in the exercise xml object of the course, or a special item
							// in the exercise XML itself. 
							// v6.3.4 Move reading text to <texts> node
							// and this bit is done in XMLtoObject
							//_global.ORCHID.LoadedExercises[0].readingText = {file:me.fileName, name:me.name};
							//_global.ORCHID.LoadedExercises[0].readingText = {id:me.id, name:me.name};
							//myTrace("saved readingText fileName as " + me.id);
						} else {
							// v6.4.2.4 I think you should break out if you are using media in this odd way
							// At present I am getting another media added twice, second time wrongly
							myTrace("non reading-text m:text, don't add to jukebox");
							// v6.4.2.4 Except that SSS has media nodes used like this. So can I use continue instead?
							//break;
							continue;
						}
					} else if (me.type == "m:url") {
						myTrace("found floating url=" + me.fileName); // me.url);
						// v6.4.2.7 use the better attribute
						// This kind of floating url needs a special button (weblink) to be played. There is also an embedded url media type which has x, y
						//var myjbURL = me.fileName; // me.url;
						var myjbURL = me.url;
					} else {
						//var myjbURL = _global.ORCHID.paths.root + _global.ORCHID.paths.media + me.fileName;
						// v6.3.5 Allow for media to come from a shared location if desired
						if (me.location == "shared") {
							// also allow audio files to come from language sub folders
							// v6.4.1 New literal format
							//v6.4.2.4 Might also include streaming
							//if (me.type.substr(2) == "audio") {
							if (me.type.toLowerCase().indexOf("audio")>=0) {
								// v6.4.2 rootless
								//var subFolder = _global.ORCHID.functions.addSlash(_global.ORCHID.literalModelObj.getLiteralLanguage().mediaFolder); // this is a function in control
								var subFolder = _global.ORCHID.functions.addSlash(_global.ORCHID.literalModelObj.getLanguageDetails().mediaFolder); // this is a function in control
								//myTrace("subFolder=" + subFolder);
							} else {
								var subFolder = "";
							}
							var myjbURL = _global.ORCHID.paths.sharedMedia + subFolder + me.fileName;
							myTrace("shared floating media file= " + myjbURL)
						// v6.5.6 Allow for media to come from a streaming location
						} else if (me.location == "streaming") {
							// v6.5.5.5 Slight change to steaming media path name
							var myjbURL = _global.ORCHID.paths.streamingMediaFolder + me.fileName;
							myTrace("streaming floating media file= " + myjbURL)
						//v6.4.2 Allow for media to come from a fully specified location
						} else if (me.location == "URL") {
							var myjbURL = me.fileName;
							myTrace("URL media file= " + myjbURL)
						//v6.5.6.5 Allow media to come from a branding folder
						} else if (me.location == "brandMovies") {
							var myjbURL = _global.ORCHID.paths.brandMovies + me.fileName;
							myTrace("brand media file= " + myjbURL)
						// v6.4.2.6 New type of "original" for an exercise in an MGS, but with media in the original
						} else if (me.location == "original") {
							var myjbURL = _global.ORCHID.paths.media + me.fileName;
							myTrace("original media file= " + myjbURL)
						} else {
							//v6.4.2 AP editing ce
							if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
								var myjbURL = _global.ORCHID.paths.editedMedia + me.fileName;
							} else {
								var myjbURL = _global.ORCHID.paths.media + me.fileName;
							}
						}
					}
					//v6.4.1 Allow stretching
					var jbObj = {jbURL:myjbURL,
							jbAutoPlay:(_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)),
							jbPlayMode:me.mode,
							jbMediaType:me.type,
							jbStretch:me.stretch,
							jbWidth:me.coordinates.width, jbHeight:me.coordinates.height,
							jbTarget:"drag", // describes the panel the media is shown in, 'drag' is the default for Orchid
							jbName:me.name,
							// v6.4.2.4 Need to pass this as URLs don't get the loadVars test done?
							jbLocation:me.location, 
							// v6.4.2.4 And need to pass this as well as otherwise autoplay audio doesn't get it
							jbID:me.id, 
							jbPlayTimes:me.playTimes, 
							//jbDisplayX:myX + myW - 20, jbDisplayY:myY - 20, jbDisplayAnchor:"tr"// an absolute screen coordinate  anchor
							jbDisplayX:myX + myW - 16, jbDisplayY:myY - 29, jbDisplayAnchor:"tr"// an absolute screen coordinate  anchor
							};
					//myTrace("create floating media for " + jbObj.jbURL + " with autoplay=" + jbObj.jbAutoPlay);
					//trace("jukebox=" + myMediaController.myJukeBox); // Variable _level0.exerciseHolder.Exercise_SP.tmp_mc.mediaHolder.myJukeBox = 
					//trace("add " + me.fileName + " to jukebox mediaList")
					var idx=myMediaController.myJukeBox.mediaList.push(jbObj);
					//trace("just pushed item = " + idx); //myMediaController.myJukeBox.mediaList[idx-1].jbURL);
				} else {
					// this is for embedded media (at present it doesn't cope with autoPlay)
					// media has a mode that (amongst other things) lets you set it to only appear after marking
					//myTrace(me.fileName+" has mode="  + me.mode + " type=" + me.type);
					if (me.mode & _global.ORCHID.mediaMode.ShowAfterMarking) {
						//trace("embedded media " + me.fileName + " is only shown after marking");
						//trace("now, ex.mode=" + _global.ORCHID.LoadedExercises[0].mode);
					} else {
						// but in this case you want the media to be shown right away
						//myTrace("call showMediaItem=" + me.name);
						// v6.4.1 New popUp mode might mean you embed a marker not the real thing
						// v6.4.2.1 Both media types are handled in the same function now
						//if (me.mode & _global.ORCHID.mediaMode.PopUp) {
						//	//myTrace("popUp media item");
						//	showMediaPopUp(me, contentHolder);
						//} else {
						showMediaItem(me, contentHolder);
						//}
					}
				}
			// 6.0.3.0 Allow media to be anchored to a particular paragraph
			//} else if (me.type.substr(0, 2) == "a:") {
			}
		}
		//myTrace("after media loop");
		// only autoplay and adjust resources button for exercise pane
		// CUP noScroll - no problem now, but later this might limit what I can do with fields in 
		// other windows. I will want to autoplay sounds in the title for instance.
		if (myPane._name == "Exercise_SP") {
			// load the 'first' autoplay resource item into the jukebox
			for (var i=0; i<myMediaController.myJukeBox.mediaList.length; i++) {
				//myTrace("mediaList: " + myMediaController.myJukeBox.mediaList[i].jbURL);
				if (myMediaController.myJukeBox.mediaList[i].jbAutoPlay) {
					//myTrace("autoPlay " + myMediaController.myJukeBox.mediaList[i].jbMediaType + ": " + myMediaController.myJukeBox.mediaList[i].jbURL);					
					// v6.4.2.4 If your media is streamingAudio, then you want to run control through the videoPlayer, not the jukebox
					// v6.4.3 Switch to all audio streaming by default. To avoid it, use m:staticAudio
					//if (myMediaController.myJukeBox.mediaList[i].jbMediaType.indexOf("streaming")>=0) {
					if (	myMediaController.myJukeBox.mediaList[i].jbMediaType.toLowerCase().indexOf("audio")>=0 && 
						myMediaController.myJukeBox.mediaList[i].jbMediaType.toLowerCase().indexOf("static")<0) {
						myTrace("streaming audio for autoplay");
						// v6.4.2.4 If you have autoplay streaming audio, it might look better to attach the mediaPlayer to the base screen
						// so that the streaming bar appears there instead on on the exercisepane. It goes on a layered mc so that it is
						// easy to remove in clearExercise
						var newContentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.createEmptyMovieClip("streamer", Number(_global.ORCHID.mediaDepth));
						//var newContentHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen;
						//var newContentHolder = myMediaController;
						// position it, but ugly as you can't rely on screens.display.init to have run yet if this is the first exercise they do
						myMediaController.myJukeBox.mediaList[i].jbX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.jukeboxPlaceHolder._x;
						myMediaController.myJukeBox.mediaList[i].jbY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.jukeboxPlaceHolder._y + 15; // ugly hack as streamer is -25 above the videoPlayer
						// v6.5.6.4 New SSS we want the streamer to be on the background of the controller
						if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
							myMediaController.myJukeBox.mediaList[i].jbY-=12;
						}
						// v6.4.2.5 In fact, you don't want see this if you have the controller because it is behind and obscured.
						// v6.4.2.5 You won't want to see a streaming label and bar if this is a question based media item.
						// v6.5.4.3 I don't see a streamer for after marking media - why has this got anything to do with jbPlayTimes?
						// surely it should be based on anchoring or somesuch. In fact, since this has to be autoplay, it will never be question based.
						// The jbPlayTimes comes because RIELTS has no controller, jbPlayTimes=1 so it just needs the streamer.
						// That works, and it turns out that I do get a streamer, but it is hidden behind the controller. So, move the streamer DOWN
						// if you have the controller. Repeat in feedback.as
						//if (myMediaController.myJukeBox.mediaList[i].jbPlayTimes>0) {
							myMediaController.myJukeBox.mediaList[i].streamingLabel = _global.ORCHID.literalModelObj.getLiteral("streaming", "labels");
						//} else {
						//	myMediaController.myJukeBox.mediaList[i].streamingLabel = undefined;
						//}
						if (myMediaController.myJukeBox.mediaList[i].jbPlayTimes==0) {
							myMediaController.myJukeBox.mediaList[i].jbY += 25;
						}
						//myTrace("x=" + myMediaController.myJukeBox.mediaList[i].jbX + ", y=" + myMediaController.myJukeBox.mediaList[i].jbY);
						// bodge until createVideoPlayer is more sorted!
						var me = {id:myMediaController.myJukeBox.mediaList[i].jbID, playTimes:myMediaController.myJukeBox.mediaList[i].jbPlayTimes}
						createVideoPlayer(me, myMediaController.myJukeBox.mediaList[i], newContentHolder);
					} else {
						myTrace("got autoplay, but not normal audio");
						//myTrace("1236:make controller visible");
						myMediaController._visible = true;
						myMediaController.myJukeBox.setMedia(myMediaController.myJukeBox.mediaList[i]);
					}
					//trace("mediaList has " + myMediaController.myJukeBox.mediaList.length + " items");
					break;
				}
			}
			//trace("before adding resources button, ex.mode=" + _global.ORCHID.LoadedExercises[0].mode);
			// create a resources list for multiple entries
			//trace("mediaList has " + myMediaController.myJukeBox.mediaList.length + " items");
			// v6.3.3 change mode to settings
			//if (myMediaController.myJukeBox.mediaList.length >= 1) {
			//	// add a resources button request to the exercise mode
			//	// is this safe to do that here or might the buttons already have been displayed?
			//	// it might be better to do it as an event (except that that will not work if buttons are not yet displayed!)
			//	//trace("add resources button to mode, before=" + _global.ORCHID.LoadedExercises[0].mode);
			//	_global.ORCHID.LoadedExercises[0].mode |= _global.ORCHID.exMode.ResourcesButton;
			//	//trace("after=" + _global.ORCHID.LoadedExercises[0].mode);
			//	//for (var i=0; i<myMediaController.myJukeBox.mediaList.length; i++) {
			//	//}
			//} else {
			//	//trace("remove resources button to mode, before=" + _global.ORCHID.LoadedExercises[0].mode);
			//	_global.ORCHID.LoadedExercises[0].mode &= ~_global.ORCHID.exMode.ResourcesButton;
			//}
			// The default setting is to show the media button, so just switch that off if we find there is no media
			if (myMediaController.myJukeBox.mediaList.length < 1) {
				_global.ORCHID.LoadedExercises[0].settings.buttons.media = false;
			}
		}
	}
	// copy back the mediaList to jukebox, after reading text or rule text is loaded
	if (myPane._name.indexOf("ReadingText_SP") == 0 || myPane._name == "Rule_SP") {
		//trace("put back mediaList for exercise");
		myMediaController.myJukeBox.mediaList = tempMediaList;
	}
	//myTrace("towards end for " + myPane._name);
	
	// ******
	// set the size of the finished pane
	// ******
	// CUP noScroll code - for measuring region heights
	// v6.3.5 ERROR - if you have a noScroll box which contains a lot of lines with a couple having text+TAB
	// at the beginning of them, then you simply don't get this far, so regionDepth is invalid and the body
	// will overwrite the noScroll. I don't know what is wrong. LPQ-027-E2. It sometimes happens and sometimes not.
	// But I get this a lot on a slow computer, where it also can happen during the example. Must be related to
	// timing? Is it because only exercise_SP is done with the tlc? Are the others just firing off too early on the
	// next stage? Yes. See info on timeLimit above.
	// v6.4.3 If the content has no blank paras at the bottom, this can leave you too close for
	// comfort. But you wouldn't want to extend other regions, just exercise. APP clumsily gets round
	// this by adding 3 blank paragraphs. Clearly these get ignored by test templates.
	var max = ppotsVars.thisText.paragraph.length;
	myTrace("max=" + max);
	if (max>0) {
		myTrace("thing=" + ppotsVars.contentHolder["ExerciseBox"+(max-1)]);
		var lastTop = ppotsVars.contentHolder["ExerciseBox"+(max-1)]._y;
		var lastHeight = Number(ppotsVars.contentHolder["ExerciseBox"+(max-1)].getSize().height);
		myTrace("lastTop=" + lastTop + " lastHeight=" + lastHeight);
	} else {
		var lastTop = lastHeight = 0;
	}
	myPane.regionDepth = lastTop + lastHeight; // - 4; don't adjust for borders as you want them.
	myTrace("new " + myPane._name + ".regionDepth=" + myPane.regionDepth);
	//trace("same contentHeight=" + contentHolder._height);
	
	// noScroll code - does any media in the pane increase the height?
	for (var i in thisText.media) {
		var me = thisText.media[i].coordinates;
		// stuff apart from pictures/animations tends not to have a height so it won't
		// effect anything.
		var myHeight = Number(me.y) + Number(me.height);
		if (myHeight > myPane.regionDepth) {
			//myTrace("picture " + thisText.media[i].fileName + " is deeper at=" + myHeight);
			myPane.regionDepth = myHeight;
		}
	}
	
	var thisHeight = myH;
	// the scroll panes have fixed width, but the height of the title might change at some point
	// but the drag panes should try to resize up to the maximums set in myH and myW
	//myTrace("paneSymbol=" + paneSymbol);
	if (paneSymbol.toLowerCase().indexOf("drag") >= 0 || paneSymbol.toLowerCase().indexOf("popupwindow") >= 0) { 
	// if (paneSymbol == "APDraggablePaneSymbol") {
		//myTrace("for this pane, myW=" + myW + ", contentHolder.width=" + contentHolder._width + " myMaxW=" + myMaxW);
		// if it is deeper than needed, shorten it
		// does this pane want a minimum for resizing?
		if (myMinW > 0 && myMinH > 0) {
			myPane.setMinSize(myMinW, myMinH);
		}
		if (myMaxW > 0 && myMaxH > 0) {
			//myPane.setPaneMaximumSize(700, 550);
			myPane.setMaxSize(myMaxW, myMaxH);
			//myTrace("setMaxHeight to " + myMaxH);
		}
		// v6.3.5 the window now lets you request a preferred size for the content
		myTrace("contentHolder.height=" + contentHolder._height + ", width=" + contentHolder._width);
		//myTrace("contentHolder.height=" + contentHolder._height + ", myH=" + myH);
		// v6.4.3 But unfortunately the contentHolder doesn't include any graphics.
		// v6.5.5.8 For small feedback we ideally want the width to expand to fit the single-line feedback.
		if (myPane._name.indexOf("ReadingText_SP")>=0) {
			var thisWidth = Math.max(myW, contentHolder._width);
		} else if (_global.ORCHID.LoadedExercises[0].settings.exercise.smallFeedbackWindow) {
			// v6.5.5.8 We might have feedback that has purely images, it would be nice to make sure that the box gets the dimensions from them.
			var myImageWidth = contentHolder._width;
			var myImageHeight = contentHolder._height;
			var hSpacer = vSpacer = 12;
			for (var i in thisText.media) {
				var me = thisText.media[i].coordinates;
				myTrace("image is " + me.width)
				// stuff apart from pictures/animations tends not to have a height so it won't
				// effect anything.
				if (Number(me.width)>0) {
					myImageWidth = Math.max(myImageWidth, Number(me.width) + hSpacer);
					myImageHeight = Math.max(myImageHeight, Number(me.height));
					myTrace("image is bigger at " + myImageWidth + ", " + myImageHeight)
				}
			}
			//myTrace("for " + thisText.media[i].fileName + " bottom is at " + myHeight + " compare to " + contentHolder._height);
			if (myImageWidth > contentHolder._width) {
				// can I make it bigger just like this? NO, it stretches everything
				// so instead try adding in a dummy mc right at the bottom
				var safeDepth = thisText.paragraph.length+1; // starting point of depths for this run
				//myTrace("safedepth=" + safeDepth);
				var myInitObject = {_x:myImageWidth, _y:myImageHeight};
				var dummy = contentHolder.attachMovie("blob","endMarker", safeDepth, myInitObject)
				myTrace("widen contentHolder to " + myImageWidth);
			}
			var thisWidth = contentHolder._width;
		} else {
			var thisWidth = Math.min(myW, contentHolder._width);
		}
		var thisHeight = Math.min(myH, contentHolder._height);
		//trace("take min of " + myW + " and " + contentHolder._width);
		//myTrace("finally set the content size to " + thisWidth + ", " + thisHeight);
		// v6.5.6.4 If this is a ReadingText in a PUW, then minH and minW should be different
		
		//myTrace("and I have minHeight= " + myMinH);
		myPane.setContentSize(thisWidth, thisHeight);
		// v6.4.2.7 Copied from view - need to resize score feedback immediately
		// and get the scroll bar right by using resize routine
		myPane.onResize(myPane.getContentSize());
		//myPane.refreshScrollContent();
		//trace("pane can scroll " + myPane.getScrolling());
		// v6.3.5 hijack
		myTrace("and enable the pane");
		myPane.setEnabled(true);

	} else {
		// ???? is this enough code?
		//myPane.setSize(myW, myH);
		// EGU
		//myPane.setContentSize(thisWidth, thisHeight);
		//myPane.scrolling = true;
		// CUP noScroll code
		// v6.4.2.7 EGU noScroll has the depth too close to the bottom of the text. Add a fudge.
		if (myPane._name.indexOf("NoScroll_SP") == 0) {
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				ppotsVars.myPane.regionDepth+=4;
			}
		}
	
		if (myPane.resize) {
			var thisHeight = ppotsVars.myPane.regionDepth;
			//myTrace(myPane + " wants to be resized to " + thisHeight);
			myPane.setSize(myW, thisHeight);
		} else {
			//myTrace(myPane + " is happy at height " + myH);
			//var thisHeight = myH;
		}		
		// v6.4.2 If a picture is at the end of the content, the scroll bar will probably not let you go down enough
		// so see if you need to increase the content._height (not this is contentHolder not the pane)
		for (var i in thisText.media) {
			var me = thisText.media[i].coordinates;
			// stuff apart from pictures/animations tends not to have a height so it won't
			// effect anything.
			if (me.calculatedY != undefined) {
				var myHeight = Number(me.calculatedY) + Number(me.height);
			}else {
				var myHeight = Number(me.y) + Number(me.height);
			}
			var vSpacer = 20;
			//myTrace("for " + thisText.media[i].fileName + " bottom is at " + myHeight + " compare to " + contentHolder._height);
			if (myHeight > contentHolder._height) {
				// can I make it deeper just like this? NO, it stretches everything
				//contentHolder._height = myHeight + vSpacer;
				// so instead try adding in a dummy mc right at the bottom
				var safeDepth = thisText.paragraph.length+1; // starting point of depths for this run
				//myTrace("safedepth=" + safeDepth);
				var myInitObject = {_x:0, _y:myHeight};
				var dummy = contentHolder.attachMovie("blob","endMarker", safeDepth, myInitObject)
				//myTrace("deepen contentHolder to " + contentHolder._height);
			}
		}

		// v6.2 It is this line that causes the slight sideways lurch of the exercise pane
		// but without it the scroll bar will not be correctly set.
		myPane.refreshPane();
	}
	// did you want to set the width based on the content?
	//if (myW == 0) myW = contentHolder._width;
	// reset size (could do this if just the above two lines caused a change I suppose
	//trace("set size for " + myPane + " to " + myW + ", " + myH);
	//myPane.setSize(myW, myH)
	//if (paneSymbol == "FScrollPaneSymbol") {
		//trace("refresh " + myPane);
	//	myPane.refreshPane();
	//} else {
	//	myPane.refreshScrollContent(); // was attached to _root
	//}
	// CUP noScroll code
	// I want to know the depth of some key regions, so just record for all
	// for now I have done this at the end of paragraph adding - not sure why it is different
	//myPane.regionDepth = thisHeight;
	//trace("region " + myPane + " has region.depth " + myPane.regionDepth + " contentHeight=" + thisHeight);

	if (_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Countdown") {
	//if (_global.ORCHID.LoadedExercises[0].settings.exercise.countDown) {
		// does it work to set the selection/focus here, or is it too soon?
		Selection.setFocus(_global.ORCHID.root.buttonsHolder.ExerciseScreen.cdController.word_i);
	}
	
	//trace("at end of pPOTS, ex.mode=" + _global.ORCHID.LoadedExercises[0].mode);
	//TIMING: this is the end of the timed function, so perform the original callback
	//myTrace("do final callback from ppots");
	_global.ORCHID.tlc.callBack();
	// if you didn't want to use tlc, then remove the bits that got created to make the function work
	//if (_global.ORCHID.tlc.proportion <= 0) {
	//	myTrace("delete the whole _global.ORCHID.tlc");
	//	delete _global.ORCHID.tlc;
	//}
}
// v6.4.1 function for embedding popUp buttons for media
// v6.4.2.1 This is not just for video anymore, images can also be in pop-ups.
// v6.4.2.1 This code is now all in showMedia which covers embedded and popup
/*
showMediaPopUp = function(thisMediaItem, contentHolder) {
	//myTrace("showPopUpItem in "  + contentHolder);
	var me = thisMediaItem;
	// v6.3.5 Allow for media to come from a shared location if desired
	if (me.location == "shared") {
		var myFile = _global.ORCHID.paths.sharedMedia + me.fileName;
		//myTrace("showMediaItem file= " + myFile)
	//v6.4.2 Allow for media to come from a fully specified location
	} else if (me.location == "URL") {
		var myFile = me.fileName;
		myTrace("URL media file= " + myFile)
	} else {
		//v6.4.2 AP editing ce
		if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
			var myFile = _global.ORCHID.paths.editedMedia + me.fileName;
		} else {
			var myFile = _global.ORCHID.paths.media + me.fileName;
		}
	}
	// object to hold media details (anything in a puw is anchored top left)
	//v6.4.1 Allow stretching
	var mediaObj = {jbURL:myFile, _x:me.coordinates.x, _y:me.coordinates.y, jbMediaType:me.type, 
				jbName:me.name, 
				jbWidth:me.coordinates.width, jbHeight:me.coordinates.height, jbX:me.coordinates.x, jbY:me.coordinates.y, 
				jbStretch:me.stretch,
				jbDuration:me.duration, jbAnchor:"tl",
				jbID:me.id};
	//mediaObj.jbAutoPlay = (_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)); 
	mediaObj.jbAutoPlay = true; 
	//v6.4.1.5 For network video playing, you need the full path, not just a relative one
	// Surely not ALL popup media will be animation/video - some might be images at some point
	// so this code is not clever. 
	//v6.4.2.1 AND the myFile already has the full path name in it!
	v6.4.2.3 No, just not true. Unless the location.ini has full path for content, this will not be full
	if (_global.ORCHID.projector.name == "MDM") {
		mediaObj.jbURL = _global.ORCHID.paths.root + myFile;
	}
		
	// object to tell the button what to do
	var initObj = {_x:me.coordinates.x, _y:me.coordinates.y, xOffset:contentHolder._parent._x, yOffset:contentHolder._parent._y};
	//initObj.contentHolder = contentHolder;
	initObj.mediaObj = mediaObj;
	initObj.mediaItem = me;
	// insert a simple play button to show the media
	// v6.4.2.1 Different behaviour for different media types, sadly. It would be much better
	// to have one jukebox that could cope with all media types itself. At present we do have
	// this situation as the videoPlayer can display .jpgs, which is the only other thing we have.
	initObj.onRelease = function () {
		myTrace("create PUW (with videoPlayer) for " + this.mediaObj.jbURL);
		// code here to create a puw, then put the video player into it, with links to the controller
		//myTrace("showMediaItem for video, duration=" + me.duration);
		if (_global.ORCHID.root.buttonsHolder.MessageScreen.media_SP == undefined) {
			// object to tell the pane what to do
			var paneObj = {_x:this._x + this.xOffset, _y:this._y + this.yOffset};
			//myTrace("pane should be at x=" + this._x + ", y=" + this._y + ", yOffset=" + this.yOffset);
			var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "media_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, paneObj); 
		} else {
			// if the window already exists, simply make sure it is displayed.
			_global.ORCHID.root.buttonsHolder.MessageScreen.media_SP._visible = true; 
			return;
		}
		//myTrace("pane=" + myPane);
		myPane.setTitle(this.mediaObj.jbName);
		myPane.setContentBorder(false);
		myPane.setCloseButton(true);
		myPane.setResizeButton(true);
		myPane.setMinSize(100, 100);
		myPane.setMaxSize(700, 550);
		var contentHolder = myPane.getContent();
		// Call out to video player creation
		this.mediaObj.jbX = this.mediaObj.jbY = 0;
		// set up actions for the pane buttons (if any)
		myPane.onClose = function(pane) {
			return true;
		}
		myPane.setCloseHandler(myPane.onClose);
		myPane.onResize = function(dims) {
			//myTrace("pane onResize, so tell " + this.videoPlayer + " to go to w=" + dims.width);
			var w= dims.width;
			var h = dims.height;
			this.videoPlayer.setSize(w,h);
		}
		myPane.setResizeHandler(myPane.onResize);
		// to avoid the video starting out bigger than the window
		// v6.4.1.4 My problem is that I get a small little puw at first, then once the video knows how big
		// it is, it kicks in and resizes puw. But this goes off screen and looks crap. So can I hide my puw
		// until the video has done its resizing?
		//myPane.setSize(Number(this.mediaObj.jbWidth)+11, Number(this.mediaObj.jbHeight)+37);
		//myPane.setEnabled(true);
		
		// if the video tells you it has been resized (by magnify or initial loading)
		myPane.contentResized = function(dims) {
			var newW = Number(dims.width)+11;
			var newH = Number(dims.height)+37;
			myTrace("content resized to w=" + newW + " x=" + this._x);
			this.setSize(newW, newH);
			// v6.4.1.4 Initial loading will not have done this, leaving it to here as now we know size
			// This is fine for the puw, but the vid and streamer still display first.
			if (this._x + newW > Stage.width) {
				this._x = Stage.width - newW;
			}
			if (this._y + newH > Stage.height) {
				this._y = Stage.height - newH;
			}			
			this.setEnabled(true);
			//this.videoPlayer._visible = true;
			this.display();
		}
		// create the content player
		this.mediaObj.streamingLabel = ""; // no label as gets in the way of window border
		myPane.videoPlayer = createVideoPlayer(this.mediaItem, this.mediaObj, contentHolder);
		// v6.4.1.4 Try to keep this invisible at first as well as the puw. 
		// This doesn't work.
		//myPane.videoPlayer._visible = false;
		// so try a higher level - seems ok
		myPane._visible = false;
		
		//prime the sizing
		//myTrace("set size to width=" + this.mediaObj.jbWidth + ", height=" + this.mediaObj.jbHeight);
		// v6.4.1 You can't use setContentSize as (at present) it adds too much space since it assumes
		// the need for some border space.
		//myPane.setContentSize(this.mediaObj.jbWidth, this.mediaObj.jbHeight);
	}
	var mediaDepth = Number(_global.ORCHID.mediaDepth) + Number(me.id);
	//myTrace("add video play button at depth=" + mediaDepth);
	//v6.4.2.1 Add new icons for playing multimedia
	//var myPush = contentHolder.attachMovie("playAudio", "playAudio" + me.id, mediaDepth, initObj);
	// v6.2 The audio controls are actually buttons - so you cannot use initObj in attachMovie to set parameters
	// so set them now
	//for (var i in initObj) {
	//	myPush[i] = initObj[i];
	//}
	// To be consistent with other buttons in the library, you should add the button component
	// and then attach the particular graphics.
	if (me.type.substr(2) == "picture") {
		var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playPicture" + me.id, mediaDepth, initObj);
		myPush.setTarget("embedPicture");
	} else {
		var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playVideo" + me.id, mediaDepth, initObj);
		myPush.setTarget("embedVideo");
	}
}
*/
// v6.4.2.4 This function might be called from various places - or it might not. Never mind.
getFullMediaPath = function (me) {
	//myTrace("fullMediaPath, me.location=" + me.location + " " + me.fileName);
	if (me.location == "shared") {
		// v6.4.2.4 Also streamedAudio
		//if (me.type.substr(2) == "audio") {
		if (me.type.toLowerCase().indexOf("audio")>=0) {
			// v6.4.1 New literal format
			//var subFolder = _global.ORCHID.functions.addSlash(_global.ORCHID.literalModelObj.getLiteralLanguage().mediaFolder); // this is a function in control
			var subFolder = _global.ORCHID.functions.addSlash(_global.ORCHID.literalModelObj.getLanguageDetails().mediaFolder); // this is a function in control
			//myTrace("subFolder=" + subFolder);
		} else {
			var subFolder = "";
		}
		var myFile = _global.ORCHID.paths.sharedMedia + subFolder + me.fileName;
		//myTrace("showMediaItem file= " + myFile)
	// v6.5.6 Streaming media
	} else if (me.location == "streaming") {
		// v6.5.5.5 Slight change to steaming media path name
		var myFile = _global.ORCHID.paths.streamingMediaFolder + me.fileName;
		myTrace("full URL for streaming= " + myFile)
	// v6.5.6.5 Brand media
	} else if (me.location == "brandMovies") {
		var myFile = _global.ORCHID.paths.brandMovies + me.fileName;
		myTrace("location is brandMovies:" + myFile)
	//v6.4.2 Allow for media to come from a fully specified location
	} else if (me.location.toUpperCase() == "URL") {
		// v6.4.2.4 Allow our existing paths to be used here
		// Example: fileName=#brandMovies#certificate.swf
		//myTrace("fileName=" + me.fileName + " brandMovies=" + _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies));
		if (me.fileName.indexOf("#brandMovies#")>=0) {
			myTrace("replacing brandMovies");
			me.fileName = findReplace(me.fileName, "#brandMovies#", _global.ORCHID.functions.addSlash(_global.ORCHID.paths.brandMovies));
		} else if (me.fileName.indexOf("#mediaFolder#")>=0) {
			myTrace("replacing mediaFolder");
			if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
				var myFolder = _global.ORCHID.paths.editedMedia;
			} else {
				var myFolder = _global.ORCHID.paths.media;
			}
			me.fileName = findReplace(me.fileName, "#mediaFolder#", _global.ORCHID.functions.addSlash(myFolder));
		} else if (me.fileName.indexOf("#exerciseFolder#")>=0) {
			myTrace("replacing exerciseFolder");
			// v6.4.2.5 Media is always read from MGS (which defaults to content if none)
			//me.fileName = findReplace(me.fileName, "#contentFolder#", _global.ORCHID.functions.addSlash(_global.ORCHID.paths.content));
			if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
				var myFolder = _global.ORCHID.paths.editedExercises;
			} else {
				var myFolder = _global.ORCHID.paths.exercises;
			}
			me.fileName = findReplace(me.fileName, "#exerciseFolder#", _global.ORCHID.functions.addSlash(myFolder));
		} else if (me.fileName.indexOf("#sharedMedia#")>=0) {
			myTrace("replacing sharedMedia");
			me.fileName = findReplace(me.fileName, "#sharedMedia#", _global.ORCHID.functions.addSlash(_global.ORCHID.paths.sharedMedia));
		} else if (me.fileName.indexOf("#streamingMedia#")>=0) {
			myTrace("replacing streamingMedia");
			// v6.5.5.5 Slight change to steaming media path name
			me.fileName = findReplace(me.fileName, "#streamingMedia#", _global.ORCHID.functions.addSlash(_global.ORCHID.paths.streamingMediaFolder));
		}
		var myFile = me.fileName;
		myTrace("URL media file= " + myFile)
	// v6.4.2.6 New type of "original" for an exercise in an MGS, but with media in the original
	} else if (me.location == "original") {
		var myFile = _global.ORCHID.paths.media + me.fileName;
		myTrace("original media file= " + myFile)
	} else if ( Number(me.location) ) {
		// v6.5.5.7 the media file has been edited by AuthorPlusPro,
		// so need change the media path. The groupID was being put in the location attribute. But now this is all based on a courseID
		// v6.5.5.9 But this is the wrong path. WZ added UserObject.EditedContent object with paths in.
		//var MGSRoot = _global.ORCHID.paths.content.subString(0, _global.ORCHID.paths.content.indexOf("Content")) + "ap/";
		//var edMediaPath = MGSRoot + _global.ORCHID.commandLine.prefix + "/Courses/EditedContent-" + me.location + "/Media/";
		// Because in this case me.location is equals groupID, we can get the media path from editedContent array according
		// to me.location
		var _mediaPath = _global.ORCHID.paths.editedMedia // defalut value
		for (var i in _global.ORCHID.user.editedContent) {
			//myTrace("search me.location = " + me.location);
			if (me.location == _global.ORCHID.user.editedContent[i]._groupid) {
				_mediaPath = _global.ORCHID.user.editedContent[i]._mediaPath;
				break;
			}
		}
		var myFile = _mediaPath + me.fileName;
		//myTrace("myFile is " + myFile);
		//myTrace("editedMedia=" + _global.ORCHID.paths.editedMedia);
		
	} else {
		//myTrace("Edited path is " + _global.ORCHID.paths.content.subString(0, _global.ORCHID.paths.content.indexOf("Content")));
		//v6.4.2 AP editing ce
		if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
			var myFile = _global.ORCHID.paths.editedMedia + me.fileName;
			//myTrace("editedMedia = " + myFile);
		} else {
			var myFile = _global.ORCHID.paths.media + me.fileName;
			//myTrace("editedMedia = " + myFile);
		}
	}
	return myFile;
}
showMediaItem = function(thisMediaItem, contentHolder) {
	var me = thisMediaItem;
	//myTrace("showMediaItem.id " + me.id + " fileName=" + me.fileName + "," + me.filename);
	var mediaDepth = Number(_global.ORCHID.mediaDepth) + Number(me.id);
	//var myFile = _global.ORCHID.paths.root + _global.ORCHID.paths.media + me.fileName;
	// v6.3.5 Allow for media to come from a shared location if desired
	// v6.4.2.4 Pull out code to separate function
	var myFile = getFullMediaPath(me);
	var myCoords = new Object();
	// 6.0.3.0 The coordinates of an anchored media file need to be calculated
	// relative to the paragraph it is anchored to
	if (me.anchorPara != undefined) {
		// v6.3.4 For any CUP product, override the x and y offsets from the XML as sometimes they are going wrong
		// when coming out of Author Plus v6.4.11
		// we know that is should always be x=-35, y=+4
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP") >= 0) {
			me.coordinates.x = -35;
			me.coordinates.y = 4;
		}
		//myTrace("showing an anchored media item for para=" + me.anchorPara + " mode=" + me.mode);
		//myTrace("media.x=" + me.coordinates.x + " para.x=" + contentHolder["ExerciseBox" + me.anchorPara]._x);
		//v6.4.2 adding in the ability to have question based pictures as well as audio
		// if you are pushing text right, don't touch the x coordinate of the image
		if (me.mode & _global.ORCHID.mediaMode.PushTextRight) {
			myCoords.x = parseInt(me.coordinates.x);
		} else {
			myCoords.x = contentHolder["ExerciseBox"+me.anchorPara]._x + parseInt(me.coordinates.x);
		}
		myCoords.y = contentHolder["ExerciseBox"+me.anchorPara]._y + parseInt(me.coordinates.y);
		//myTrace("final x=" + myCoords.x + " y="+ myCoords.y);
		// v6.4.2 You are using local var for calculated coordinates here - which means that no-one else
		// knows what you have just done. If you were to simply edit me.coordinates it might cause
		// double counting if you come thorugh here again, so for ease just add a couple of new properties.
		me.coordinates.calculatedX = myCoords.x;
		me.coordinates.calculatedY = myCoords.y;
		
		myCoords.width = me.coordinates.width;
		myCoords.height = me.coordinates.height;
		//myCoords.x = contentHolder["ExerciseBox" + me.anChorPara]._x + parseInt(me.coordinates.x);
		//myCoords.y = contentHolder["ExerciseBox" + me.anchorPara]._y + parseInt(me.coordinates.y);

		//v6.4.2 adding in the ability to have question based pictures as well as audio
		// You can add the image easily just by using q:picture, but this just sits over the text.
		// So what we want to do is to use mode to say if the image overlays or pushes down
		// the text (maybe even pushes right?). This requires measuring the media and then
		// moving ALL the rest of the paragraphs down by this much (or all the paragraphs across
		// if their y is within the height of the image if you are being fancy).
		// v6.4.2.1 But you wouldn't move text if the media was in popup mode - check just in case
		// the seemingly incompatible modes are set!
		if (	me.mode & _global.ORCHID.mediaMode.PushTextDown && 
			!(me.mode & _global.ORCHID.mediaMode.PopUp)) {
			// what happens if the media has no coordinates? Well, can't cope with that so
			// simply assume it is 100 and add stretch to the properties
			if (myCoords.height < 1) {
				myCoords.height =100;
				me.stretch = true;
			}
			// v6.4.3 You have to get the y coordinate of the next para and then see how much that
			// needs to move down to be beneath the media - it is not simply the height of the media
			//var delta = parseInt(myCoords.height) + 0; // add a little vertical buffer
			var mediaTop = Number(myCoords.y);
			var vSpacer = 5;
			var mediaBottom = Number(myCoords.height) + mediaTop + vSpacer;
			var anchorParaY = contentHolder["ExerciseBox"+me.anchorPara]._y;
			var nextParaY = anchorParaY + 10; // safety margin
			//myTrace(me.fileName + " bottom " + mediaBottom + " anchorY " + anchorParaY);
			// vital to go through in y order so you can stop once you find the next para
			// that starts after the anchored one (or others on the same line).
			// In the end you might be able to find a way to let other paras in the same 'group'
			// not move down either - if that is what you want.
			for (var i in contentHolder) {
				//myTrace("testing para " + i + " y=" + contentHolder[i]._y);
				if (i.indexOf("ExerciseBox")==0 && contentHolder[i]._y > anchorParaY) {
					//myTrace("next para=" + i + " with y=" + contentHolder[i]._y);
					nextParaY = contentHolder[i]._y;
					break;
				}
			}
			var delta = mediaBottom - nextParaY;
			//myTrace("media pushes text down by " + delta + " from " + myCoords.y);
			for (var i in contentHolder) {
				//myTrace(i + "._y=" + contentHolder[i]._y)
				if (i.indexOf("ExerciseBox")==0 && contentHolder[i]._y >= myCoords.y) {
					//myTrace("so down it goes");
					contentHolder[i]._y += delta;
				}
			}
			// Unless you put all images before audio, you might need to move down any
			// audio that you have already anchored to a para that is now moving. but how on 
			// earth to know that? I suppose it is if earlier in media array and y > then move.
			// For now, simply make sure that all media images go before audio in exercise XML.
		}
					
	} else {
		myCoords = me.coordinates;
	}
	//trace("sMI file "+myFile+", it is type " + me.type + " into " + contentHolder);

	// debug - what have we got here then?
	//myTrace("media: type=" + me.type.substr(2) + " mode=" + me.mode + " playTimes=" + me.playTimes);
	// v6.4.2.1 Move popup functions into here as well as embed functions.
	// We will have forced all audio to have the popup mode at an earlier point
	if (me.mode & _global.ORCHID.mediaMode.PopUp) {
		// v6.4.2.4 See if you can do audio in the same way
		//if (me.type.substr(2) == "picture" || me.type.substr(2) == "video" || me.type.substr(2) == "animation") {
		// v6.4.2.5 You can't stream FLS through the video player - yes you can - no you can't.
		if (myFile.toLowerCase().indexOf(".fls")>0) {
			//_global.myTrace(me.type + " change type as " + myFile);
			me.type = me.type.substr(0,2) + "flashAudio";
		}
		// v6.4.3 Default audio is now streaming
		if (	me.type.substr(2) == "picture" || me.type.substr(2) == "video" || me.type.substr(2) == "animation" || 
			me.type.substr(2) == "streamingAudio" || me.type.substr(2) == "audio") {
			// object to hold media details (anything in a puw is anchored top left)
			//v6.4.1.5 For network video playing, you need the full path, not just a relative one
			//v6.4.2.1 according to comment for floating video this is not true - the path is already full
			//v6.4.2.3 No, just not true. Unless the location.ini has full path for content, this will not be full
			//v6.4.2.4 Since mdm will now certainly have full path in content (due to Win98 changes) you can skip this
			//if (_global.ORCHID.projector.name == "MDM") {
			//	myFile = _global.ORCHID.paths.root + myFile;
			//	//myTrace("MDM, so add root to content path=" + myFile);
			//}
			//v6.4.1 Allow stretching
			// v6.4.2.1 The move into showMedia means we have calculated myCoords
			var mediaObj = {jbURL:myFile, _x:myCoords.x, _y:myCoords.y, jbMediaType:me.type, 
						jbName:me.name, 
						jbWidth:myCoords.width, jbHeight:myCoords.height, jbX:myCoords.x, jbY:myCoords.y, 
						jbStretch:me.stretch,
						jbDuration:me.duration, jbAnchor:"tl",
						jbID:me.id};
			//mediaObj.jbAutoPlay = (_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)); 
			mediaObj.jbAutoPlay = true; 
				
			// object to tell the button what to do
			var initObj = {_x:myCoords.x, _y:myCoords.y, xOffset:contentHolder._parent._x, yOffset:contentHolder._parent._y};
			initObj.contentHolder = contentHolder;
			initObj.mediaObj = mediaObj;
			initObj.mediaItem = me;
			// insert a simple play button to show the media
			// v6.4.2.1 Different behaviour for different media types, sadly. It would be much better
			// to have one jukebox that could cope with all media types itself. At present we do have
			// this situation as the videoPlayer can display .jpgs, which is the only other thing we have.
			initObj.onRelease = function () {
				myTrace("create streamingPlayer for " + this.mediaObj.jbURL + " width=" + this.mediaObj.jbWidth);
				//	// if the window already exists, simply make sure it is displayed. Can you be sure that this window is playing/displaying the right media??
				// v6.4.2.4 If you have several pop up media items, they will all use the same PUW (at present). So always reset.
				// But this is NOT enough to then let you immediately start another player for another media. Don't know why.
				if (_global.ORCHID.root.buttonsHolder.MessageScreen.media_SP != undefined) {
					myTrace("running a PUW media already, so stop it");
					_global.ORCHID.root.buttonsHolder.MessageScreen.media_SP.closePane();						
					//_level0.buttonsHolder.MessageScreen.media_SP.content.MediaHolder1003.unloadMovie();
					//delete _global.ORCHID.root.buttonsHolder.MessageScreen.media_SP;
					//_global.ORCHID.root.buttonsHolder.MessageScreen.media_SP = undefined;
					// v6.4.2.4 If you are a picture, then all will be well. It is only video that cannot do it in one stage.
					if (this.mediaItem.type.indexOf("video")>=0) {
						return;
					}
				}
				// v6.5.5.7 Now that I have played one of the audio files, I should be able to use recorder compare if I want
				_global.ORCHID.viewObj.enableRecorderCompare(true);
				
				// v6.5.5.7 For compareWaveforms to work I need to know the fileName of the last audio that I clicked on.
				// Which will be this one. I could probably pick it up direct from the videoPlayer, but since this whole audio player
				// business is very messy, lets just save it in the currentItem Object for now.
				_global.ORCHID.session.currentItem.lastAudioFile=this.mediaObj.jbURL;
				// Also, if the compare waveforms is already open, I would like clicking this play button to call compareWaveforms
				if (_global.ORCHID.projector.lcLoaded) {
					myTrace("ask recorder if compare is open");
					_global.ORCHID.recorderConn.send("_clarityRecorder", "compareIfOpen");
				}
				
				// code here to create a puw, then put the video player into it, with links to the controller
				// v6.4.2.4 But audio doesn't want a PUW - can I just have an invisible videoPlayer like I do if embedded?
				//myTrace("??me=" + me.type + " or " + this.mediaItem.type);
				// v6.4.3 Audio will now stream by default (use staticAudio to stop it)
				if (this.mediaItem.type.substr(2) == "streamingAudio" || this.mediaItem.type.substr(2) == "audio") {
					// v6.4.2.7 If the audio is already playing, clicking again should stop it
					if (this.isPlaying) {
						// tell the videoPlayer to stop - but what is the video player?
						// I think it is 'me' as below, but calls to functions on it have no impact
						var me = this.contentHolder["MediaHolder" + this.mediaItem.id];
						//myTrace("try to stop " + this.mediaItem.type);
						// So just pretend you have finished and kill the clip
						this.contentHolder.onFinished(this.mediaItem.id);
						me.removeMovieClip();
					} else {
						// Call out to video player creation
						// v6.4.2.5 You won't want to see a streaming label and bar if this is a question based media item.
						// v6.4.3 Or if it is anchored
						//myTrace("mediaType=" + this.mediaItem.type);
						// if (this.mediaItem.type.substr(0,1) == "q") {
						// v6.5.6.5 But for CP2 we DO want to see a streaming bar whenever possible. 
						// I suppose we do for other titles too, but do we need to check whether that ends up overwriting anything?
						//if (this.mediaItem.type.substr(0,1) == "q" || this.mediaItem.type.substr(0,1) == "a") {
						//	this.mediaObj.streamingLabel == undefined;
						//} else {
							this.mediaObj.streamingLabel = _global.ORCHID.literalModelObj.getLiteral("streaming", "labels");
						//}
						// v6.4.2.7 Trying to change the audio button after play has finished
						this.contentHolder.onFinished = function(id) {
							// link to the button (based on the id)
							// how you can tell whether the button is called playAudio or playVideo?
							var me = this["playAudio" + id];
							
							// not playing anymore
							me.isPlaying = false;							
							_global.myTrace("finished so change audio icon for " + me);
							// v6.4.2.7 EGU will just leave them coloured once clicked
							// v6.4.2.8 Other programs will have a version that shows you have played this once
							if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") < 0) {
								if (me.mediaItem.anchorPara == undefined) {
									me.setTarget("embedPlayedAudio");
								} else {
									me.setTarget("embedSmallPlayedAudio");
								}
							}
						}
						// v6.5.6.4 Trying to change the audio button after play has been stopped, not finished
						// Either make a new 'started but not finished' icon, or just go back to the original
						this.contentHolder.onNotFinished = function(id) {
							var me = this["playAudio" + id];
							// This will be called for the last audio played, even if it had stopped. So only override the icon if it is playing.
							if (me.isPlaying) {
								_global.myTrace("not finished, yet isPlaying=" + me.isPlaying);
								_global.myTrace("not finished so change audio icon for " + me);
								// v6.4.2.7 EGU will just leave them coloured once clicked
								// v6.4.2.8 Other programs will have a version that shows you have played this once
								if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") < 0) {
									if (me.mediaItem.anchorPara == undefined) {
										me.setTarget("embedAudio");
									} else {
										me.setTarget("embedSmallAudio");
									}
								}
								me.isPlaying = false;
							}
						}
						
						//myTrace("mediaItem.id=" + this.mediaItem.id);
						createVideoPlayer(this.mediaItem, this.mediaObj, this.contentHolder);
						
						// v6.4.2.5 Add audio icon change for streaming audio too
						// v6.4.2.4 But which size icon are you clicking on??
						//_global.myTrace("change audio icon for " + this);
						// v6.4.2.7 EGU will just leave them coloured once clicked
						// This doesn't make sense - I do want to change them when I start playing...
						//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
							if (this.mediaItem.anchorPara == undefined) {
								this.setTarget("embedPlayingAudio");
							} else {
								this.setTarget("embedSmallPlayingAudio");
							}
						//}
						// v6.4.2.7 Set a flag to know we are now playing
						this.isPlaying = true;
						_global.myTrace("set isPlaying for " + this);

					}
				} else { 
					//myTrace("showMediaItem for video, duration=" + me.duration);
					// object to tell the pane what to do
					var paneObj = {_x:this._x + this.xOffset, _y:this._y + this.yOffset};
					//myTrace("pane should be at x=" + this._x + ", y=" + this._y + ", yOffset=" + this.yOffset);
					var myPane = _global.ORCHID.root.buttonsHolder.MessageScreen.attachMovie("FPopupWindowSymbol", "media_SP", _global.ORCHID.root.buttonsHolder.buttonsNS.depth++, paneObj); 
					//myTrace("pane=" + myPane);
					myPane.setTitle(this.mediaObj.jbName);
					myPane.setContentBorder(false);
					myPane.setCloseButton(true);
					// v6.4.2.4 The resize on the pane does NOT resize the content anymore, so just remove it for now.
					// v6.4.2.8 Is this still true? No it does resize, but it lets you change the PUW to any shape, although it doesn't ruin the video
					// it would be nicer if it snapped to keep the ratio.
					myPane.setResizeButton(true);
					//myPane.setResizeButton(false);
					myPane.setMinSize(100, 100);
					myPane.setMaxSize(700, 490);
					var puwContentHolder = myPane.getContent();
					//v6.4.2.4 To help you talk to the media content of the window
					myPane.videoID = this.mediaItem.id;

					// v6.5.6 How can I know if a jpg that won't call me back is loaded?
					// This is happening with cross domain loading, but I have no idea why. This is a very ugly hack.
					myPane.reluctantMedia = function() {
						var puwContentHolder = this.getContent();
						var myVideo = puwContentHolder["MediaHolder"+this.videoID];
						//myTrace("reluctant, loaded=" + myVideo.mediaHolder.picture._framesloaded);
						if ((myVideo.mediaHolder.picture._framesloaded >= myVideo.mediaHolder.picture._totalframes) &&
							(myVideo.mediaHolder.picture._width>0) ||
							this.doneItTooManyTimes>10) {
							myTrace("clear reluctant.int=" + this.setReluctantInt);
							this.doneItTooManyTimes++;
							clearInterval(this.setReluctantInt);
							myTrace("picture loaded, try resize to width=" + myVideo.mediaHolder.picture._width);
							//this.onResize({width:myVideo.mediaHolder.picture._width, height:myVideo.mediaHolder.picture._height});
							this.contentResized({width:myVideo.mediaHolder.picture._width, height:myVideo.mediaHolder.picture._height});
						}
						// And don't allow resizing. But this doesn't have any impact.
						this.setResizeButton(false);
					}
					myPane.setReluctantInt = setInterval(myPane, "reluctantMedia", 500);
					myPane.doneItTooManyTimes=0;
					//myTrace("int=" + myPane.setReluctantInt);

					// Call out to video player creation
					this.mediaObj.jbX = this.mediaObj.jbY = 0;
					// set up actions for the pane buttons (if any)
					myPane.onClose = function(pane) {
						return true;
					}
					myPane.setCloseHandler(myPane.onClose);
					myPane.onResize = function(dims) {
						// Only do this for real resizing, not for initial display
						if (!(dims.width==200 && dims.height==100)) {
							//myTrace("clear onresize reluctant int=" + this.setReluctantInt);
							clearInterval(this.setReluctantInt);
						}
						var puwContentHolder = this.getContent();
						var myVideo = puwContentHolder["MediaHolder"+this.videoID];
						myTrace("pane onResize, so tell " + myVideo + " to go to w=" + dims.width + " h=" + dims.height);
						//myTrace("pic width=" + myVideo.mediaHolder.picture._width);
						//myTrace("I am " + this);
						var w= dims.width;
						var h = dims.height;
						//this.videoPlayer.setSize(w,h);
						myVideo.setSize(w,h);
					}
					myPane.setResizeHandler(myPane.onResize);
					// to avoid the video starting out bigger than the window
					// v6.4.1.4 My problem is that I get a small little puw at first, then once the video knows how big
					// it is, it kicks in and resizes puw. But this goes off screen and looks crap. So can I hide my puw
					// until the video has done its resizing?
					//myPane.setSize(Number(this.mediaObj.jbWidth)+11, Number(this.mediaObj.jbHeight)+37);
					//myPane.setEnabled(true);
					
					// if the video tells you it has been resized (by magnify or initial loading)
					myPane.contentResized = function(dims) {
						// Only do this for real resizing, not for initial display
						if (!(dims.width==200 && dims.height==100)) {
							myTrace("clear contentResized reluctant int=" + this.setReluctantInt);
							clearInterval(this.setReluctantInt);
						}
						var newW = Number(dims.width)+11;
						var newH = Number(dims.height)+37;
						myTrace("content resized to w=" + newW + " h=" + newH + " myPane.width=" + this._width);
						this.setSize(newW, newH);
						// v6.4.1.4 Initial loading will not have done this, leaving it to here as now we know size
						// This is fine for the puw, but the vid and streamer still display first.
						if (this._x + newW > Stage.width) {
							this._x = Stage.width - newW;
						}
						if (this._y + newH > Stage.height) {
							this._y = Stage.height - newH;
						}			
						this.setEnabled(true);
						//this.videoPlayer._visible = true;
						this.display();
					}
					// create the content player
					// v6.4.2.4 Look, it's lovely to try and play everything through the video player (and it can)
					// but wouldn't we be better off putting pictures (the most common popup) though the simple
					// mediaHolder like we do for embedding? Doesn't seem to work as simply as I hoped.
					// Retry later...
					//if (this.mediaItem.type.substr(2) == "picture") {
					//	myTrace("use picture instead of video for " + this.mediaItem.id + " " + this.mediaObj.jbURL);
					//	var mediaDepth = Number(_global.ORCHID.mediaRelatedDepth) + Number(this.mediaItem.id);
					//	var myPicture = puwContentHolder.attachMovie("mediaHolder", "MediaHolder"+this.mediaItem.id, mediaDepth, this.mediaObj);
					//	//myTrace("created " + myPicture);
					//} else {
						// V6.4.2.4 No, the window border doesn't have writing anyway
						//this.mediaObj.streamingLabel = ""; // no label as gets in the way of window border
						this.mediaObj.streamingLabel = _global.ORCHID.literalModelObj.getLiteral("streaming", "labels");
						// v6.4.2.4 You can't get a return from cVP as asynch
						//myPane.videoPlayer = createVideoPlayer(this.mediaItem, this.mediaObj, puwContentHolder);
						createVideoPlayer(this.mediaItem, this.mediaObj, puwContentHolder);
						// v6.4.1.4 Try to keep this invisible at first as well as the puw. 
						// This doesn't work.
						//myPane.videoPlayer._visible = false;
						// so try a higher level - seems ok. 
						// v6.4.2.4 Or is this causing it to sometimes not display? Seems to be something else.
						// You will show it once the media has told you it is ready to go (with dimensions)
						myPane._visible = false;
						myPane.setEnabled(false);
						//myTrace("pane.videoPlayer=" + myPane.videoPlayer + " .visible=" + myPane._visible);
						
						//prime the sizing
						//myTrace("set size to width=" + this.mediaObj.jbWidth + ", height=" + this.mediaObj.jbHeight);
						// v6.4.1 You can't use setContentSize as (at present) it adds too much space since it assumes
						// the need for some border space.
						//myPane.setContentSize(this.mediaObj.jbWidth, this.mediaObj.jbHeight);					
					//}
				}
				// v6.4.2.4 If playTimes>0, then hide the button once it has been clicked (or disable with a "only play once msg")
				if (this.mediaItem.playTimes>0) {
					myTrace("hide the jb controller");
					this.setEnabled(false);
				}
			}
			var mediaDepth = Number(_global.ORCHID.mediaDepth) + Number(me.id);
			//myTrace("add video play button at depth=" + mediaDepth);
			//v6.4.2.1 Add new icons for playing multimedia
			// To be consistent with other buttons in the library, you should add the button component
			// and then attach the particular graphics.
			//myTrace("embed picture for " + me.type.substr(2));
			if (me.type.substr(2) == "picture") {
				var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playPicture" + me.id, mediaDepth, initObj);
				if (me.anchorPara == undefined) {
					myPush.setTarget("embedPicture");
					//myTrace("just added popup picture, large at x=" + myCoords.x);
				} else {
					myPush.setTarget("embedSmallPicture");
					//myTrace("just added popup picture, small at x=" + myCoords.x);
				}
			} else if (me.type.substr(2) == "video" || me.type.substr(2) == "animation") {
				var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playVideo" + me.id, mediaDepth, initObj);
				if (me.anchorPara == undefined) {
					myPush.setTarget("embedVideo");
					//myTrace("just added popup video, large at x=" + myCoords.x + " depth=" + mediaDepth);
				} else {
					myPush.setTarget("embedSmallVideo");
					//myTrace("just added popup video, small at x=" + myCoords.x);
				}
			} else {
				var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playAudio" + me.id, mediaDepth, initObj);
				if (me.anchorPara == undefined) {
					myPush.setTarget("embedAudio");
					//myTrace("just added audio, large at x=" + myCoords.x + " depth=" + mediaDepth);
				} else {
					myPush.setTarget("embedSmallAudio");
					//myTrace("1962:just added audio to " + myPush);
				}
			}
		// v6.4.3 Audio streams by default
		//} else if (me.type.substr(2) == "audio") {
		} else if (me.type.substr(2) == "staticAudio" || me.type.substr(2) == "flashAudio") {
			var initObj = {jbURL:myFile, _x:myCoords.x, _y:myCoords.y, jbMediaType:me.type, jbID:me.id};
			// v6.3.5 Code changed for proper switching on/off of embedded sounds. But this will not easily
			// let you switch the graphics correctly.
			// v6.4.2.4 Not nicely done. Tidy up.
			initObj.targetMedia = me;
			_global.ORCHID.root.jukeboxHolder.nowPlaying = {status:false}
			/*
			// following should be done elsewhere I guess, but no matter
			_global.ORCHID.root.jukeboxHolder.onPlayFinished = function() {
				myTrace("onPlayFinished for " + _root.jukeboxHolder.nowPlaying.target.fileName + " in " + _root.jukeboxHolder);
				_global.ORCHID.root.jukeboxHolder.nowPlaying.status = false;
			}
			*/
			
			//trace("showing "+myFile+" for media "+me.id + " at x=" + initObj._x + ", y=" + initObj._y);
			//initObj.jbURL = myFile; // try to make this more local rather than global
			//trace(" with mode="+me.mode);
			initObj.jbAutoPlay = (_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)); 
			//trace("audio="+myFile+" with mode="+me.mode + " and autoplay=" + initObj.jbAutoPlay);
			// insert a simple play button for the audio, give it properties that will be passed to the jukebox
			initObj.onRelease = function () {
				// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
				// so we should do it for it.
				// v6.3.4 No longer - correctly handled by the selection listener
				//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
				//	//trace("doing the last insert from cmdMarking");
				//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
				//	_global.ORCHID.session.currentItem.lastGap = undefined;
				//}
				//myTrace("clicked on " + this.endEventTarget.fileName + ", nowPlaying=" + _root.jukeboxHolder.nowPlaying.status);
				//initObj.callingMC = this;
				// this should enable the ONE media control panel for the exercise and pass in this media item's parameters
				// 6.0.2.0 setting jbTarget to this.picture should give an audio masquerading as a swf
				//	somewhere to live (this duplicates the set up in real animation mediaHolder mc)
				//	This linkage item is in the exercise.fla (playAudio)
				// v6.4.2.4 set this (the button) as the endEventTarget so that the controller can inform me when complete
				var myMediaController = _global.ORCHID.root.jukeboxHolder;
				var jbObj = {jbID:this.jbID, jbURL:this.jbURL, jbAutoPlay:this.jbAutoPlay, jbTarget:this.picture, jbMediaType:this.jbMediaType,
							jbEndEventTarget:this}; //, jbEndEventTarget:this.endEventTarget};
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
					myMediaController._visible = false;
				} else {
					//myTrace("1871:make controller visible");
					myMediaController._visible = true;
				}
				// v6.2 provide a toggle sound play and stop with the same sound icon
				// v6.3.4 Yes, but it doesn't seem to be done! So add it in (along with a graphic change)
				// Or you could just tell it to switch pictures
				//myTrace("currently playing " + myMediaController.nowPlaying.target.id + "=" + myMediaController.nowPlaying.status);
				//myTrace("this is " + this);
				if (myMediaController.nowPlaying.status && myMediaController.nowPlaying.target.id == this.targetMedia.id) {
					//myTrace("stop myself");
					//var graphic = "stopAudio";
					//var action = true;
					myMediaController.myJukeBox.stop();
					myMediaController.nowPlaying.status = false;
					//myTrace("stop myself " + myMediaController.nowPlaying.status);
					// v6.4.2.7 EGU will just leave them coloured once clicked
					if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") < 0) {
						// v6.4.2.4 But which size icon are you clicking on??
						if (this.targetMedia.anchorPara == undefined) {
							this.setTarget("embedAudio");
						} else {
							//myTrace("2005:just added audio to " + this);
							this.setTarget("embedSmallAudio");
						}
					}
				} else {
					// v6.4.2.7 If you are going to stop other audio, you need to change their icon as well
					if (myMediaController.nowPlaying.status) {
						//myTrace("stop the other guy " + myMediaController.nowPlaying.target.id);
						// v6.4.2.7 EGU will just leave them coloured once clicked
						if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") < 0) {
							// v6.4.2.4 But which size icon are you clicking on??
							if (myMediaController.nowPlaying.target.anchorPara == undefined) {
								myMediaController.nowPlaying.target.setTarget("embedAudio");
							} else {
								//myTrace("2005:just added audio to " + this);
								myMediaController.nowPlaying.target.setTarget("embedSmallAudio");
							}
						}
					}
					myMediaController.myJukeBox.setMedia(jbObj, true);
					myMediaController.nowPlaying.target = this.targetMedia;
					//var graphic = "playAudio";
					//var action = false;
					//myTrace("change to true from " + myMediaController.nowPlaying.status);
					myMediaController.nowPlaying.status = true;
					//myTrace("start me");
					// change the graphic to show this audio is active
					// v6.4.2.4 But which size icon are you clicking on??
					myTrace("change to embed[Small]PlayingAudio");
					if (this.targetMedia.anchorPara == undefined) {
						this.setTarget("embedPlayingAudio");
					} else {
						this.setTarget("embedSmallPlayingAudio");
					}
				}
				// v6.3.5 See earlier
				// v6.3.4 The trouble with this is that the nowPlaying is not cleared at the end of the Sound
				// or if another play button is clicked.
				//this.nowPlaying = !this.nowPlaying;
				//myTrace("ask " + this + " to show graphic " + graphic);
				//this.showIcon(graphic);
				// copy some properties from the current icon
				//var initObj = contentHolder.playAudio;
				//contentHolder.attachMovie(graphic, "playAudio" + me.id, Number(_global.ORCHID.mediaDepth) + Number(me.id), initObj);
				//myMediaController.myJukeBox.play();
			}
			// v6.4.2.4 Catch the audio finishing
			initObj.onFinishedPlaying = function () {
				//myTrace("2046:onFinishedPlaying in " + this);
				// change the graphic to show this audio is inactive
				// v6.4.2.7 EGU will just leave them coloured once clicked
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") < 0) {
					// v6.4.2.4 But which size icon are you clicking on??
					if (this.targetMedia.anchorPara == undefined) {
						this.setTarget("embedAudio");
					} else {
						this.setTarget("embedSmallAudio");
					}
				}
				_global.ORCHID.root.jukeboxHolder.nowPlaying.status = false;
			}

			// v6.3 (EGU 1.1) Try to see if the sound file is in the expected folder - if not search the CD.
			// But only do this once, whatever the outcome
			//if (_global.ORCHID.session.mediaOnCD == undefined) {
			//	whereAreSoundFiles(myFile);
			//}
			
			//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			//v6.4.2.1 Add new media icons
			//myTrace("add audio play button at depth=" + mediaDepth);
			//var myPush = contentHolder.attachMovie("playAudio", "playAudio" + me.id, mediaDepth, initObj);
			// v6.2 The audio controls are actually buttons - so you cannot use initObj in attachMovie to set parameters
			// so set them now
			//for (var i in initObj) {
			//	myPush[i] = initObj[i];
			//}
			// To be consistent with other buttons in the library, you should add the button component
			// and then attach the particular graphics.
			// The graphic that you use for audio depends on whether this audio is anchored (in which case we
			// assume that it is part of the text) or regular floating.
			var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playAudio" + me.id, mediaDepth, initObj);
			if (me.anchorPara == undefined) {
				myPush.setTarget("embedAudio");
				//myTrace("2093:just added audio, large at x=" + myCoords.x);
			} else {
				myPush.setTarget("embedSmallAudio");
				//myTrace("just added audio, small at x=" + myCoords.x);
				//myTrace("2074:just added audio to " + myPush);
			}
			//myTrace("added embedded sound " + myPush + " for " + myPush.jbURL + "in contentHolder=" + contentHolder);
			//trace("created playAudio=" + myPush._name + " at depth " + myPush.getDepth());
		}
	} else {
		// This is the code for inserting direct media into the exercise - of any type
		// but of course it doesn't make sense for audio to be here, it is treated as popup
		//v6.4.1 Add in video
		//myTrace("xxx");
		if (me.type.substr(2) == "video") {
			myTrace("showMediaItem for " + me.type.substr(2) + ", location=" + me.location);
			//v6.4.1 Allow stretching
			var initObj = {jbURL:myFile, jbWidth:myCoords.width, jbHeight:myCoords.height, jbX:myCoords.x, jbY:myCoords.y, 
						jbStretch:me.stretch,
						jbMediaType:me.type, jbDuration:me.duration, jbAnchor:me.anchor,
						jbLocation:me.location,
						jbID:me.id};
			initObj.jbAutoPlay = (_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)); 
	
			//v6.4.1.5 For network video playing, you need the full path, not just a relative one
			//v6.4.2.1 according to comment for floating video this is not true - the path is already full
			//v6.4.2.3 No, just not true. Unless the location.ini has full path for content, this will not be full
			//v6.4.2.4 Since mdm will now certainly have full path in content (due to Win98 changes) you can skip this
			//if (_global.ORCHID.projector.name == "MDM") {
			//	//myTrace("MDM, so add root to content path");
			//	initObj.jbURL = _global.ORCHID.paths.root + myFile;
			//}
			
			// Call out to video player creation
			initObj.streamingLabel = _global.ORCHID.literalModelObj.getLiteral("streaming", "labels");
			// Try to help with loading videoPlayer.swf into same mc problems by making separate MCs
			var extraHolder = contentHolder.createEmptyMovieClip("extraHolder"+me.id, mediaDepth);
			//var myVideo = createVideoPlayer(me, initObj, contentHolder);
			// v6.4.2.4 You can't get a return from cVP as asynch
			//var myVideo = createVideoPlayer(me, initObj, extraHolder);
			createVideoPlayer(me, initObj, extraHolder);
		
		} else if (me.type.substr(2) == "picture") {
			//myTrace("for image " + myFile);
			//trace("add at depth " + (Number(_global.ORCHID.mediaDepth) + Number(me.id)));
			// can you get anywhere by changing coords within the mediaHolder? No
			//myCoords.y = 10;
			//myTrace("adding picture");
			//v6.4.1 Allow stretching
			var initObj = {jbURL:myFile, jbWidth:myCoords.width, jbHeight:myCoords.height, jbX:myCoords.x, jbY:myCoords.y, 
						jbStretch:me.stretch,
						jbMediaType:me.type};
			initObj.jbAutoPlay = (_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)); 
			// if this media is also a field, add mouse awareness to it
			// based on the mode (perhaps) the interaction can either be a field or another media item (audio)
			// but then you will have to have another type of floating audio so that it doesn't appear in the media List
			// and a way to link them together. Sort this out when you think about authoring this type of thing.
			if (me.fieldID != undefined) {
				//trace("I will add onRelease to the picture");
				initObj.fieldID = me.fieldID;
				initObj.onRelease = function() {
					// trigger field reaction if this media is clicked as it is a field
					var fieldID = this.fieldID;
					var mainEx = _global.ORCHID.LoadedExercises[0];
					var thisField = mainEx.getField(fieldID);
					//trace("you clicked on "+thisField.id+" which is mode/type "+thisField.mode+"/"+thisField.type);
					singleMarking(thisField);
				}
			}
			//trace("sMI width=" + initObj.jbWidth);
			//v 6.3.5 How to avoid the picture overlapping the top border of the scrollpane?
			// It is fine at the bottom, and changing _y had no effect. I fear it is something complex
			// to do with the mask. v6.4.1 Fixed in FScrollPane component.
			//myTrace("adding " + me.fileName + " to contentHolder=" + contentHolder);
			//var mediaDepth = Number(_global.ORCHID.mediaDepth) + Number(me.id);
			//myTrace("add picture at depth=" + mediaDepth);
			//v6.4.1 Whilst you can use an event from mediaHolder onClipEvent(data) which lets you
			// keep the resizing code here, it would require duplication, so for now, leave it in buttons
			// (where I suppose it is duplicated amongst the many buttonsxxx.swf, oh well)
			//initObj.onPictureLoad = function(dims) {
			//	myTrace("I see you, picture width=" + dims.width);
			//	this._width = 100;
			//}
			//myTrace("embedded picture");
			
			// v6.4.3 Is it possible to put the picture under the text?
			if (_global.ORCHID.mediaMode.DisplayUnder == (me.mode & _global.ORCHID.mediaMode.DisplayUnder)) {
				mediaDepth = _global.ORCHID.initialParaDepth - (me.id-1000); // hardcode the media starting number created by AP
				//myTrace("underlay image, so depth=" + mediaDepth);
				// v6.5.6.4 New SSS and can we stop the loading bar showing in this case?
				initObj.jbShowProgress = false;
			}
			// v6.5.5 For certificates I would like to use cache control, at least during development.
			if (initObj.jbURL.indexOf("certificate.swf")>0) {
				initObj.jbURL+="?cacheVersion=" + new Date().getTime();
			}
			//myTrace("be nice - file=" + initObj.jbURL);
			var myPicture = contentHolder.attachMovie("mediaHolder", "MediaHolder"+me.id, mediaDepth, initObj);
			//myTrace("after attach mediaHolder");
			//myTrace("added picture=" + me.id + " x=" + initObj.jbX + " depth=" + (Number(_global.ORCHID.mediaDepth) + Number(me.id)));

		} else if (me.type.substr(2) == "record") {
			//myTrace("showMediaItem for recorder");
			var initObj = {_x:myCoords.x, _y:myCoords.y};
			// insert a simple button set for the recorder
			// but you have to find someother way to do the last typing box fill in as an onRelease will
			// stop the internal buttons from working.
			/*
			initObj.onRelease = function () {
				// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
				// so we should do it for it.
				myTrace("onRelease for the recorder")
				if (_global.ORCHID.session.currentItem.lastGap != undefined) {
					//trace("doing the last insert from cmdMarking");
					insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
					_global.ORCHID.session.currentItem.lastGap = undefined;
				}F
			}
			*/
			//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			//} else {
			var myRecorder = contentHolder.attachMovie("recorderControl", "recordAudio" + me.id, mediaDepth, initObj);
			myTrace("link to audio recorder " + myRecorder + " at x=" + initObj._x);
			//}
			// you can't run the functions in this MC until you are sure it has loaded
			// use a timer as a cheap and cheerful way of doing this!
			// But when I run on the network these functions are clearly STILL not present.
			// So cheap and cheerful is downright dangerous!
			var setActions = function() {
				clearInterval(setActionInt);
				myTrace("set record audio actions now");
				//myRecorder.setPlayAction(_global.ORCHID.viewObj.cmdPlay);
				//myRecorder.setRecordAction(_global.ORCHID.viewObj.cmdRecord);
				//myRecorder.setStopAction(_global.ORCHID.viewObj.cmdStop);
				// v6.4.3 Also set labels and icons
				myRecorder.play_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("play", "buttons"));
				myRecorder.record_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("record", "buttons"));
				myRecorder.stop_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("stop", "buttons"));
				// v6.5.1 yiu new buttons for recorder 
				//myRecorder.pause_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("pause", "buttons"));
				myRecorder.save_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("save", "buttons"));
				myRecorder.compare_pb.setLabel(_global.ORCHID.literalModelObj.getLiteral("compareWaveforms", "buttons"));
				
				myRecorder.play_pb.setReleaseAction(_global.ORCHID.viewObj.cmdPlay);
				myRecorder.record_pb.setReleaseAction(_global.ORCHID.viewObj.cmdRecord);
				myRecorder.stop_pb.setReleaseAction(_global.ORCHID.viewObj.cmdStop);
				
				// v6.5.1 yiu new buttons for recorder 
				//myRecorder.pause_pb.setReleaseAction(_global.ORCHID.viewObj.cmdPause);
				myRecorder.save_pb.setReleaseAction(_global.ORCHID.viewObj.cmdSave);
				myRecorder.compare_pb.setReleaseAction(_global.ORCHID.viewObj.cmdCompareWaveforms);
				
				myRecorder.onPlayFinished = function() {
					//myTrace("in onPlayFinished for this=" + this);
					this.stop_pb.onRelease();
				}
				// initial settings
				// v6.5.1 Yiu set it to invisible instead of enable
				/* have pause button version
				//myRecorder.play_pb.setEnabled(false);
				myRecorder.play_pb.setVisible(false);
				myRecorder.pause_pb.setVisible(true);
				myRecorder.pause_pb.setEnabled(true); 
				 * */
				myRecorder.play_pb.setEnabled(false);
				myRecorder.pause_pb.setVisible(false);
				
				myRecorder.recording_pb.setVisible(false);
				myRecorder.stop_pb.setEnabled(false);
				myRecorder.record_pb.setEnabled(true);
				// v6.5.1 yiu new buttons for recorder 
				//myRecorder.pause_pb.setVisible(false);
				myRecorder.save_pb.setEnabled(false);
				myRecorder.compare_pb.setEnabled(false);
			}
			var setActionInt = setInterval(setActions, 500);
			// v6.3.4 You will get confused with exercise and embedded recording, so if you find embedded
			// force exercise record button to be off
			_global.ORCHID.LoadedExercises[0].settings.buttons.recording = false;
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.record_pb.setEnabled(false);
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.stop_pb.setEnabled(false);
			
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.recording_pb.setVisible(false);
						
			// v6.5.1 Yiu set it to invisible instead of enable
			//_global.ORCHID.root.buttonsHolder.ExerciseScreen.play_pb.setEnabled(false);
			_global.ORCHID.root.buttonsHolder.ExerciseScreen.play_pb.setVisible(false);
			
			// v6.5.1 yiu new buttons for recorder 
			//_global.ORCHID.root.buttonsHolder.ExerciseScreen.pause_pb.setEnabled(false);
			//_global.ORCHID.root.buttonsHolder.ExerciseScreen.save_pb.setEnabled(false);
			
			// v6.2 The audio controls are actually buttons - so you cannot use initObj in attachMovie to set parameters
			// so set them now
			//for (var i in initObj) {
			//	myRecorder[i] = initObj[i];
			//}
			// v6.3.4 See if you have already made the link from recording to ocx or LocalConnection		
			// Do this every time as the record controller might have changed. It won't do anything
			// if it hasn't
			if (!_global.ORCHID.projector.ocxLoaded) {
				myTrace("going to display record button, so check if lc is ok to use with " + myRecorder);
				_global.ORCHID.root.controlNS.testClarityRecorder(myRecorder);
			}
			
		// this looks like it could be merged with picture (as could audio eventually I would think)
		// but keep it separate for now just in case. It means that a click on a picture is interpreted
		// as if it were a field, but a click on an animation (which looks identical) will play it. Maybe you
		// should put a play button overlay on the animation - use the audio one?
		// This would also be better as currently clicks on the animation are NOT passed through to the Flash
		// animation, which is bad if the animation is supposed to interactive.
		} else if (me.type.substr(2) == "animation") {
			//v6.4.1 Allow stretching
			var initObj = {jbURL:myFile, jbWidth:myCoords.width, jbHeight:myCoords.height, jbX:myCoords.x, jbY:myCoords.y, 
						jbStretch:me.stretch,
						jbMediaType:me.type};
			initObj.jbAutoPlay = (_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)); 
			// I want to add a 'play' icon overlay on (or next to) the animation so that it can be started, 
			// yet people can also interact with the Flash when it is running
			initObj.onRelease = function() {
				// this should enable the ONE media control panel for the exercise and pass in this media item's parameters
				// yet still play the media in this external window
				//trace("play " + this.jbURL);
				var jbObj = {jbURL:this.jbURL, jbAutoPlay:this.jbAutoPlay, jbTarget:this.picture, jbMediaType:this.jbMediaType};
				var myMediaController = _global.ORCHID.root.jukeboxHolder;
				myTrace("2093:make controller visible");
				myMediaController._visible = true;
				myMediaController.myJukeBox.setMedia(jbObj, true);
				//myMediaController.myJukeBox.play();
			}
			var myPicture = contentHolder.attachMovie("mediaHolder", "MediaHolder"+me.id, mediaDepth, initObj);
			// the animation will actually be put in a level 1 lower than this (.picture)
			// see the mediaHolder MC in the exercise library for details (just onLoad functions)
			//trace("added animation to " + myPicture);
			
		// v6.3 Add in the url type (ready for when authoring supports it).
		// v6.4.2.7 Is any content actually using this already? I don't think so.
		} else if (me.type.substr(2) == "url") {
			myTrace("found an embedded url " + me.url + " " + me.name);
			// v6.4.2.7 use a better attribute name
			//var initObj = {jbURL:me.fileName, _x:myCoords.x, _y:myCoords.y, jbMediaType:me.type};
			var initObj = {jbURL:me.url, _x:myCoords.x, _y:myCoords.y, jbMediaType:me.type};
			// v6.4.2.7 Rather than click a button to get a URL, I want to put an underlined caption that acts as a link
			// v6.5.0.1 It would be nice to have split screen weblinks at the bottom of the texts side. Author can't know
			// where that is, so we could do it here if y="bottom"?
			if (_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen) {
				// This would work, except that you don't calculate regionDepth until after showMediaItem
				//var paneHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen.ReadingText_SP;
				// var thisRegionDepth = paneHolder.regionDepth;
				// So do it manually - but I don't know anything about thisText!
				//var max = thisText.paragraph.length;
				//var lastTop = contentHolder["ExerciseBox"+(max-1)]._y;
				//var lastHeight = Number(contentHolder["ExerciseBox"+(max-1)].getSize().height);
				//var thisRegionDepth = lastTop + lastHeight;
				// Since you have a +50 blank line at the end of the reading text, the weblink needs to be a bit higher than the box would indicate
				var thisRegionDepth = Number(contentHolder._height)-56;
				//myTrace("reading text is deep=" + Number(thisRegionDepth));
				myCoords.y = Number(myCoords.y) + Number(thisRegionDepth);
				// And hardcode the x coordinate to align with the text.
				myCoords.x = 20;
			}
			/*
			initObj.jbAutoPlay = (_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)); 
			// insert a simple play button for the url, give it properties that will be passed to the jukebox
			initObj.onRelease = function () {
				//myTrace("pass the url to the jukebox now");
				// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
				// so we should do it for it.
				// v6.3.4 No longer - correctly handled by the selection listener
				//if (_global.ORCHID.session.currentItem.lastGap != undefined) {
				//	//trace("doing the last insert from cmdMarking");
				//	insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
				//	_global.ORCHID.session.currentItem.lastGap = undefined;
				//}
				var jbObj = {jbURL:this.jbURL, jbAutoPlay:this.jbAutoPlay, jbTarget:this.picture, jbMediaType:this.jbMediaType};
				var myMediaController = _global.ORCHID.root.jukeboxHolder;
				myMediaController._visible = false;
				myMediaController.myJukeBox.setMedia(jbObj, true);
			}
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				var myPush = contentHolder.attachMovie("urlEGU", "playURL" + me.id, mediaDepth, initObj);
			} else {
				var myPush = contentHolder.attachMovie("urlAPO", "playURL" + me.id, mediaDepth, initObj);
			}
			// v6.2 The icon is a button - so you cannot use initObj in attachMovie to set parameters
			// so set them now
			for (var i in initObj) {
				myPush[i] = initObj[i];
			}
			*/
			// v6.4.2.8 And what about making this link look really nice? Add a highlighter behind it?
			// v6.4.3 In fact it would be much much better to have a single MC that does this, containing the text and the background
			initObj = {_x:Number(myCoords.x)-3, _y:Number(myCoords.y)+2};
			// Can't just use this nice depth as it clashes with exercise text. How about mediaDepth + the id?
			var myDepth = Number(_global.ORCHID.mediaDepth) + Number(me.id);
			//myTrace("weblink depth=" + myDepth);
			//var myMarker = contentHolder.attachMovie("markerAPO", "Weblink-" + me.id, myDepth++, initObj);			
			var myWeblink = contentHolder.attachMovie("weblinkMC", "Weblink-" + me.id, myDepth++, initObj);			
			// How about adding the textfield to the marker, it will save depth clashes
			//contentHolder.createTextField("url" + me.id, myDepth, myCoords.x, myCoords.y, 100, 10);
			//var thisURL = contentHolder["url" + me.id];
			var thisURL = myWeblink.caption;
			thisURL.autoSize = true;
			thisURL.html = true;
			// v6.4.2.7 Check that this is a good url
			var thisMedia = _global.ORCHID.viewObj.checkWeblink(me.url)
			//thisURL.htmlText = "<a href='" + me.url + "' target='_blank'><u>" + me.name + "</u></a>";
			//thisURL.htmlText = "<a href='" + thisMedia + "' target='_blank'><u>" + me.name + "</u></a>";
			thisURL.htmlText = "<a href='" + thisMedia + "' target='_blank'>" + me.name + "</a>";
			// v6.5 No,  let it be from the fla
			//thisURL.setTextFormat(_global.ORCHID.headline);
			thisURL.selectable = false;
			//myTrace("caption width=" +  thisURL.textWidth);
			//trace("added marker=" + myMarker);
			// for some bizarre reason, I can set _x, _xscale in the initObj, but not _width or _height

			// set the width
			//myWeblink._width = thisURL.textWidth+8; 
			//myWeblink._height = thisURL.textHeight+2;
			//myWeblink.resetSize();
				myWeblink.backdrop._width = thisURL.textWidth+9;
				myWeblink.backdrop._height = thisURL.textHeight+2;
			//}
			myTrace("added caption at x=" + myCoords.x + " y=" + myCoords.y + " width=" + thisURL.textWidth + " of " + thisURL.htmlText);

		}
	}
}
// v6.4.2.4 The line between me and initObj isn't always clear. They both seem to do much the same and in some cases are the same!
// The only attributes you need from me are id and playTimes. Both are on initObj too (but with jb prefix)
createVideoPlayer = function(me, initObj, contentHolder) {
	var myPlayerVersionNum = new versionNumber(_global.ORCHID.projector.FlashVersion);
	// v6.4.2.4 But the buttons for starting the media are already added at this depth! When you click audio it duly disappears (WRONG)
	// but for some reason video doesn't. Wonder why. Ahh, probably due to video being in puw as content holder.
	// So use relatedDepth here, then if video loses the play button, switch to media
	var mediaDepth = Number(_global.ORCHID.mediaRelatedDepth) + Number(me.id);
	//v6.4.1 Put video on top of text
	//var mediaDepth = Number(_global.ORCHID.mediaDepth) + Number(me.id);
	if (myPlayerVersionNum.lessThan("7.0")) {
		//myTrace("not enough Flash, just got " + myPlayerVersionNum.toString());
		initObj.jbMediaType = "m:picture";
		// is an alt image supplied?
		if (me.altImage != undefined) {
			//v6.4.2 AP editing ce
			if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
				initObj.jbURL = _global.ORCHID.paths.editedMedia + me.altImage;
			} else {
				initObj.jbURL = _global.ORCHID.paths.media + me.altImage;
			}
		} else {
			initObj.jbURL = _global.ORCHID.paths.sharedMedia + "noFlashVideo.jpg";
			initObj.jbStretch = false; 
		}
		//v6.4.1 Put video on top of text
		//var myVideo = contentHolder.attachMovie("mediaHolder", "MediaHolder"+me.id, contentHolder.depth++, initObj);
		var myVideo = contentHolder.attachMovie("mediaHolder", "MediaHolder"+me.id, mediaDepth, initObj);
	} else {
		//myTrace("Flash power is yours");
		//v6.4.1 Put video on top of text
		//var myVideo = contentHolder.createEmptyMovieClip("MediaHolder"+me.id, contentHolder.depth++);
		var myVideo = contentHolder.createEmptyMovieClip("MediaHolder"+me.id, mediaDepth);
		
		// v6.5.5.2 Try to create a new video player that simply uses its own controls, doesn't relate to the jukebox controller at all
		// So everything should be handled within that player.
		if (initObj.jbLocation=="streaming" && initObj.jbURL.toLowerCase().indexOf(".flv") > 0) {
			// load the newVideoPlayer.swf instead of videoPlayer.swf
			// Then that will create the playback and controller components and point it at the specific video
			// We don't need any information or events back to here as it will be self-contained.
			// v6.5.5.2 need a new video module to cope with RTMP streaming. Not just yet though!
			// First make a video player with its own controller.
			contentHolder.vPlayerMC = _global.ORCHID.paths.movie + "newVideoPlayer.swf";
			//contentHolder.vPlayerMC = _global.ORCHID.paths.movie + "videoPlayer.swf";
		} else {
			contentHolder.vPlayerMC = _global.ORCHID.paths.movie + "videoPlayer.swf";
		}
		myTrace("use video player= " + contentHolder.vPlayerMC);
		//myTrace("playTimes=" + me.playTimes + ", autoPlay=" + initObj.jbAutoPlay);
		//v6.4.2 Video player is now loaded like the jukebox (it doesn't yet use videoNS, bad)
		// Hmm, this doesn't work smoothly as the videoplayer ends up part of root and not the content
		// so reverse out these changes.
		//myTrace("videoPlayer=" + myVideo);
		//v6.4.2 I am now going to preload the videoPlayer in control, but then load again when needed
		// Hopefully this will mean the right version is already in the cache
		// v6.4.2.4 Getting problems loading this twice in one exercise. It might be due to cache control, but equally
		// it seems so silly to not include it in buttons.swf. Except that videoPlayer is Flash 8 and buttons MUST be Flash 6.
		// So why can't I load it twice??
		//if (_global.ORCHID.online){
		//	var cacheVersion = "?version=" + _global.ORCHID.versionTable.getVersionString("videoPlayer");
		//}else{
		//	var cacheVersion = "";
		//}
		//myTrace("load up " + _global.ORCHID.paths.interfaceMovies + "videoPlayer.swf" + cacheVersion,1)
		//v6.4.1.5 But it is silly to have this in interfaceMovies when it never changes! So switch back to main
		//myVideo.loadMovie(_global.ORCHID.paths.interfaceMovies + "videoPlayer.swf" + cacheVersion);
		//for (var i in myVideo){
		//	myTrace("xx:" + i + ":" + myVideo[i]);
		//}
		// v6.4.2.4 The following all goes wrong if you load two media to one contentHolder.
		contentHolder.videoObj = undefined; // make sure it is empty
		contentHolder.videoObj = initObj;
		contentHolder.requestedAutoPlay = initObj.jbAutoPlay;
		contentHolder.videoID = me.id;
		contentHolder.playTimes = me.playTimes;
		//contentHolder.controller = jbController;
		// create some little asynch number to load up the parameters once the swf is loaded
		contentHolder.videoSetup = function() {
			//myTrace("videoSetup");
			var myVideo = this["MediaHolder"+this.videoID];
			//myTrace("ask to load video file=" + this.videoObj.jbURL);
			myVideo.id = this.videoID; // save yet another copy of the ID for the horrible functions in videoPlayer.
			myVideo._x = this.videoObj.jbX; 
			myVideo._y = this.videoObj.jbY;
			
			//myTrace("set player x=" + myVideo._x + " y=" + myVideo._y);
			// hard code this type for now
			// v6.4.1.4 Now allow Flash animations as well as FLV
			//myTrace(this.videoObj.jbURL + " .flv at " + this.videoObj.jbURL.indexOf(".flv"));
			// v6.4.2.4 Allow mp3 to be played through videoPlayer
			// preset anything that might not tell you its duration correctly
			// v6.4.3 Allow file extensions to be uppercase
			if (this.videoObj.jbURL.toLowerCase().indexOf(".flv") > 0) {
				this.videoObj.jbType = "FLV";
			// v6.4.2.5 Can I treat fls like mp3? No, you can't
			} else if (this.videoObj.jbURL.toLowerCase().indexOf(".fls") > 0) {
				this.videoObj.jbType = "FLS";
			} else if (this.videoObj.jbURL.toLowerCase().indexOf(".mp3") > 0) {
				this.videoObj.jbType = "MP3";
			} else if (this.videoObj.jbURL.toLowerCase().indexOf(".jpg") > 0) {
				this.videoObj.jbType = "JPG";
			// v6.4.2.5 have a broad catch all
			//} else if (this.videoObj.jbURL.indexOf(".swf") > 0) {
			} else { 
				this.videoObj.jbType = "SWF";
				// default duration is in seconds, assume 12 framerate, but this will be overwritten later with real
				this.videoObj.jbDuration = 12 * this.videoObj.jbDuration;
			}
			myTrace("this is a " +this.videoObj.jbType + " width=" + this.videoObj.jbWidth + " at x=" + this.videoObj.jbX);
			//myTrace("create video, width=" + this.videoObj.jbWidth);
			// v6.4.2.4 Autoplay starts audio before the image is ready. So force it to false.
			// Then, once you have resized your content, just play
			// Save it so that the video player can pick it up
			myVideo.autoPlay = this.requestedAutoPlay;
			//_global.myTrace("set myVideo.autoPlay to " + myVideo.autoPlay);
			if (this.videoObj.jbType == "FLV") {
				this.videoObj.jbAutoPlay = false;
			}
			// v6.5.5.2 All these events are unnecessary for new video
			if (initObj.jbLocation=="streaming" && initObj.jbURL.toLowerCase().indexOf(".flv") > 0) {
				// v6.5.5.8 Click anywhere on the video to play/pause it
				//myVideo.useHandCursor = false; 
				// Trouble is that just doing this overrides the video controls. So I want to either just do this for a small section in the middle of teh video
				// where the controls are most unlikely to ever be - or I have to only have it active on the first frame then kill it.
				//myVideo.onRelease = function() {
				//	myTrace("click on video player=" + this);
				//	this.togglePlayPause(this.id);
				//}

			} else {
				// v6.4.2.4 Move this to after the events are setup
				//myVideo.setMedia(this.videoObj);
				//myTrace("ask to visible it");				
				// Done within the component
				//myVideo.setEnabled(true);
				myVideo.onFinishedPlaying = function() {
					///myTrace("2403:onFinishedPlaying, show btn=" + this._parent.playVideo);
					//v6.4.1 You could either leave fake play button hidden (as the controller still works)
					// or you could show it again in case they don't want to use the controller.
					this._parent.playVideo._visible = true;
					// But which screen button are you? How is this linked to the video? It isn't at present
					//myTrace("wish you could switch audio icons for " + this._parent); 
					// v6.4.2.7 Added an onFinished event to the contentHolder (that contains the button that triggered this audio)
					this._parent.onFinished(this.id);
					
					// v6.4.2.4 But which size icon are you clicking on??
					//if (this.targetMedia.anchorPara == undefined) {
					//	this.setTarget("embedAudio");
					//} else {
					//	this._parent.setTarget("embedSmallAudio");
					//}
				}
				myVideo.onFinishedLoading = function() {
					//myTrace("onFinishedLoading in " + this);
				}
				myVideo.lostFocus = function() {
					myTrace("lost focus so add back play button")
					this._parent.playVideo._visible = true;
					this.stop();
				}
				// useful?
				myVideo.onInformation = function(infoObj) {
					//myTrace("preferred width=" + infoObj.width + ", height=" + infoObj.height + ", autosize=" + infoObj.autosize)
					if (infoObj.width != undefined) this.preferredWidth = infoObj.width;
					if (infoObj.height != undefined) this.preferredHeight = infoObj.height;
					//this.presetDuration = infoObj.duration;
					// cope with video that has no width and height set
					//if (infoObj.autosize) {
						//myTrace("was no width, so should be perfect");
					//	this.setSize(this.preferredWidth, this.preferredWidth);
					//	this.onResize(infoObj, "perfect");
					//}
					//v6.4.1.4 I need a new event to trigger a change of slider properties once I really know duration
					//myTrace("got real duration of " + infoObj.duration + " send to " + this.associatedController);
					// but you haven't associated the controller with the video yet, how to change the root properties?
					//this.associatedController.setSliderDuration(infoObj.duration)
					// v6.4.2.4 It seems that until you get this duration, the play button etc don't do the right thing.
					// So can you disable them then reenable here?
					if (infoObj.duration != undefined && infoObj.duration > 0) {
						//_global.myTrace("onInfo with duration=" + infoObj.duration);
						this._parent.videoObj.jbDuration = infoObj.duration;
						// v6.4.2.4 copied from videoHarness - needed? How to send this KEY info to the slider??
						//this.associatedController.jbSlider.setSliderProperties(0,infoObj.duration);
						this.associatedController.setSliderDuration(infoObj.duration);
					}
					//myTrace("reset duration to " + this._parent.videoObj.jbDuration);
				}
				myVideo.onPlaying = function(at) {
					//myTrace("onPlaying:" + at);
					// Note: hmm. A couple of times it seems that the slider doesn't control the player
					// until I uncomment this comment. Then ok after comment back out for a while??
					//v6.4.1 Ahhh, I think it might be that FSlider in jukebox was customised with startEvent
					// and there is a copy in buttons that was not the same.
					this.associatedController.onPlaying(at);
				}
				//myTrace("cursorGrow=" + myVideo.cursorGrow);
				//myTrace("set mouse functions");
				// replaced by one onResize function
				// to allow the video to tell you it has been resized, and to what
				myVideo.onResize = function(dims, state) {
					_global.myTrace("display.myVideo.onResize " + state);
					if (state == "original") {
						this.canMagnify = true;
						this._parent.cursor.setPlus(true);
					} else if (state == "preferred") {
						this.canMagnify = false;
						this._parent.cursor.setPlus(false);
					} else if (state == "perfect") {
						myTrace("clear our magnification functions");
						delete this.onRollOver;
						delete this.onRollOut;
						delete this.onRelease;
						delete this.onPreferredSize;
						delete this.onOriginalSize;
						// this might happen after a rollOver, so reset back to plain old mouse
						Mouse.show();
						this.cursor.removeMovieClip();
						delete this.cursor;
						// v6.4.2.4 For regular video, clicking on one should let us get control. One step is to see the play btn
						this.onRelease = function() {
							//myTrace("release, so show button " + this._parent.playVideo);
							this._parent.playVideo._visible = true;
						}					
					}
					//myTrace("video resize command, w=" + dims.width);
					// This code is irrelevant for embedded media, but no need to resize anyway
					//myTrace("width of holder=" + this._width + ", " + this._height + ", magnify=" + this.canMagnify);
					// v6.4.2.4 To avoid the close and resize buttons displaying on an invisible PUW, only visible it here?
					this._parent._parent.contentResized(dims);
					//myTrace("I think the parent is " + this._parent._parent);
					this._parent._parent._visible = true;
					this._parent._parent.setEnabled(true);
					_global.myTrace("now ask stream to play = " + this._parent.requestedAutoPlay);
					// v6.4.2.4 But what happens if you are already playing and just resized the video??
					if (this._parent.requestedAutoPlay) this.play();
				}
				//myVideo.onOriginalSize = function() {
				//	//myTrace("onOriginalSize for " + this + " at depth=" + this._parent.cursorDepth);
				//	this.canMagnify = true;
				//	this._parent.cursor.setPlus(true);
				//}
				//myVideo.onPreferredSize = function() {
				//	//myTrace("onPreferredSize for " + this);
				//	this.canMagnify = false;
				//	this._parent.cursor.setPlus(false);
				//}
				//myVideo.canMagnify = true;
				myVideo.onRelease = function() {
					// v6.4.2.4 Get back the play button
					//myTrace("release, so show button " + this._parent.playVideo);
					//this._parent.playVideo._visible = true;
					if (this.canMagnify) {
						var delta=100;
					} else {
						var delta = -100;
					}
					this.magnify(delta);
				}
				myVideo.useHandCursor = false;
				myVideo.onRollOver = function() {
					//myTrace("cursor is " + this.cursor);
					Mouse.hide();
					//this.cursor._visible = true;
					this.cursor.onEnterFrame = function() {
						this._x = this._parent._xmouse;
						this._y = this._parent._ymouse;
						this._visible = true;
						updateAfterEvent();
					}					
				}
				myVideo.onRollOut = function() {
					this.cursor._visible = false;
					delete this.cursor.onEnterFrame;
					Mouse.show();
				}
				// Prime it
				this.cursorDepth = _global.ORCHID.cursorDepth;
				//myTrace("cursor depth=" + this.cursorDepth);
				myVideo.cursor = this.attachMovie("cursorMagnify","cursor",this.cursorDepth,{_visible:false});
				// I don't think you need to do this as the videoPlayer does itself if it can.
				//myVideo.onOriginalSize();
			}
			
			// v6.4.2.4 Move this to after the events are setup
			myVideo.setMedia(this.videoObj);
			// v6.5.5.8 Just for testing
			myVideo.togglePlayPause();

			//v6.4.1 If this has been called to run inside a popup, then no need for a fake play Button
			// simply load and play, I would say. But what about an autoPlay video that you later stop?
			//_global.myTrace("autoPlay " + this.requestedAutoPlay); 
			if (this.requestedAutoPlay) {
				// v6.4.2.4 Some media is forced to play x times only - so no controller.
				// But if playTimes >1 you need something to loop it (onPlayingFinished event I would think);
				// Currently we can only do playTimes=1
				// You also need to make sure that the media is stopped if anything else starts, or if you go on to something else.
				//_global.myTrace("play " + this.playTimes + " times");
				if (this.playTimes>0) {
					var myMediaController = _global.ORCHID.root.jukeboxHolder;
					// v6.4.2.4 But if you have x times audio it would be nice to see some indication that audio is playing.
					// Can you disable mediaController instead of hiding it?
					//myTrace("hide the controller as playTimes="  +this.playTimes);
					myMediaController._visible = false;
					//myMediaController.myJukeBox.setEnabled(false);
				} else { 
					// v6.5.5.2 Cope with different players
					if (initObj.jbLocation=="streaming" && initObj.jbURL.toLowerCase().indexOf(".flv") > 0) {
					} else {
						// v6.4.2.4 Since I don't want to interfere with the controller at all if this is a picture, can I skip this part?
						if (this.videoObj.jbType == "JPG") {
							myTrace("skip linking controller and player");
						} else {
							// v6.4.2.4 due to multiplayers you have to go down one more layer
							this.videoObj.jbTarget = myVideo[this.videoObj.jbID];
							var myMediaController = _global.ORCHID.root.jukeboxHolder;
							//myTrace("2386:make controller visible, playTimes=" + this.playTimes);
							myMediaController._visible = true;
							this.videoObj.associatedPlayer = this.videoObj.jbTarget;
							// v6.4.2.4 more multiplayer confusion
							myVideo.associatedController = myMediaController.myJukeBox;
							//this.videoObj.jbTarget.associatedController = myMediaController.myJukeBox;
							//var jbObj = {jbURL:this.jbURL, jbTarget:this.jbTarget, jbMediaType:this.jbMediaType, jbDuration:this.jbDuration };
							//myTrace("autolink controller=" + myMediaController + " and player=" + this.videoObj.associatedPlayer);
							// v6.4.2.4 This line is somehow getting the audio to be played by the jukebox internals.
							// Now I am altering jukebox so that it doesn't attempt to play streaming media, just gives you the controls
							myMediaController.myJukeBox.setMedia(this.videoObj, true);
						}
					}
				}
			} else {
				// v6.5.5.2 Cope with different players
				if (initObj.jbLocation=="streaming" && initObj.jbURL.toLowerCase().indexOf(".flv") > 0) {
				} else {
					// link the player and controller when a button is clicked to start the video
					var playObj = {jbURL:this.videoObj.jbURL, jbMediaType:this.videoObj.jbMediaType, 
								jbDuration:this.videoObj.jbDuration, 
								_x:myVideo._x, _y:myVideo._y, jbTarget:myVideo, 
								jbID:this.videoObj.jbID};
					//var myPush = this.attachMovie("playAudio", "playVideo" + this.videoObj.id, Number(_global.ORCHID.mediaDepth) + Number(this.videoObj.id), playObj);
					//v6.4.1 You can't just add at video depth plus 1 as other media might be there.
					// So either it should be added not to contentHolder, but to the video itself
					// or you need a better depth scheme. 
					//var thisDepth = Number(_global.ORCHID.mediaDepth) + Number(this.videoObj.jbID);
					var thisDepth = Number(8501) + Number(this.videoObj.jbID);
					// v6.4.2.1 new name for media buttons
					//var myPush = this.attachMovie("playAudio", "playVideo", thisDepth, playObj);
					var myPush = this.attachMovie("startVideo", "playVideo", thisDepth, playObj);
					myTrace("add play button for video " + myPush);
					//myTrace("request to add play button at x=" + playObj._x);
					myPush.onRelease = function() {
						// read duration as you need it - it might have been updated
						this.jbDuration = this._parent.videoObj.jbDuration;
						//myTrace("connecting video and controller, duration=" + this.jbDuration);
						var myMediaController = _global.ORCHID.root.jukeboxHolder;
						//myTrace("2419:make controller visible");
						myMediaController._visible = true;
						this.jbTarget.associatedController = myMediaController.myJukeBox;
						var jbObj = {jbURL:this.jbURL, jbTarget:this.jbTarget, jbMediaType:this.jbMediaType, jbDuration:this.jbDuration,
									jbID:this.jbID};
						// v6.4.2.4 due to multiplayers you have to go down one more layer
						jbObj.associatedPlayer = this.jbTarget[this.jbID];
						//myTrace("link controller=" + myMediaController + " and player=" + jbObj.associatedPlayer);
						myMediaController.myJukeBox.setMedia(jbObj, true);
						// v6.4.2.4 And actually start it
						myMediaController.myJukeBox.play();
						// After starting the video, remove this Button
						this._visible = false;
					}
					// copy all properties (as playAudio is button not mc)
					for (var i in playObj) {
						myPush[i] = playObj[i];
					}
				}
				// v6.5.4.3 New button for video script - should only be present if a reading text exists
				if (_global.ORCHID.LoadedExercises[0].readingText != undefined) {
					var videoX = Number(myVideo._x) + Number(202);
					var videoY = Number(myVideo._y) + Number(310);
					myTrace("add a video script button at x=" + videoX + ", y=" + videoY);
					var scriptObj = {_x:videoX, _y:videoY};
					thisDepth++;
					// v6.5.4.3 Use a std Orchid button
					//var myScript = this.attachMovie("videoScript", "videoScript", thisDepth, scriptObj);
					//myTrace("add script button for video " + myScript);
					//myScript.onRelease = function() {
					//	_global.ORCHID.viewObj.displayVideoScript();
					//}
					// Need to get this above the new video player.
					//var myScript = contentHolder.attachMovie("FGraphicButtonSymbol", "videoScript", thisDepth, scriptObj);
					var myScript = contentHolder.attachMovie("FGraphicButtonSymbol", "videoScript", (mediaDepth+1), scriptObj);
					myScript.setTarget("videoScript");
					myScript.setReleaseAction(_global.ORCHID.viewObj.displayVideoScript);
					myScript.setLabel(_global.ORCHID.literalModelObj.getLiteral("videoScript", "buttons"));

					// copy all properties (as playAudio is button not mc)
					for (var i in scriptObj) {
						myScript[i] = scriptObj[i];
					}
				}
			}
		}
		//myController.jbSlider.setSliderProperties(0,contentHolder.videoObj.jbDuration);

		// v6.4.2.4 You need to know once the .swf is loaded.
		// This all appeared fine until running over the network on an IE6, F8.0.24, the 'fully loaded' trace came way before the
		// 'videoModule line 1' trace, and therefore nothing happened as the videoSetup happens on a non-existent object.
		// So far this not repeatable on Firefox or IE7 or another computer.
		// Can you replace this loaded then with an event that gets fired by the videoPlayer when it is truly ready?
		// Or do both? So you have an event to run the setup and the loader to do a time based check.
		contentHolder.videoPlayerLoader = function(){
			var myVideo = this["MediaHolder"+this.videoID];
			//var myVideo = _root.videoHolder;
			//myTrace("checking " + myVideo + " count=" + this.videoLoaderCount + " bytes loaded=" + myVideo.getBytesLoaded());
			if (myVideo.getBytesLoaded() > 4 && myVideo.getBytesLoaded() >= myVideo.getBytesTotal()) {
				//myTrace("player fully loaded, bytes=" + myVideo.getBytesTotal());
				clearInterval(this.videoLoaderInt);
				//this.videoSetup();
			} else if (this.videoLoaderCount>10){
				// how to show that the video cannot load? Should be impossible since you loaded it in the first loading
				// set in control.swf. But strange things happen.
				myTrace("cannot load file " + this.vPlayerMC,1);
				clearInterval(this.videoLoaderInt);
				// why would I try to set it up anyway - just in case the bytes count is crap??
				//this.videoSetup();
			} else {
				this.videoLoaderCount++;
			}
		}
		contentHolder.videoLoaderInt = setInterval(contentHolder, "videoPlayerLoader", 500);
		// This event fired from within the loaded .swf
		contentHolder.videoPlayerLoadedEvent = function(){
			// clear the interval running the above check
			//myTrace("videoPlayerLoadedEvent");
			clearInterval(this.videoLoaderInt);
			this.videoSetup();
		}
	}
	// v6.4.2.4 Move this to after the functions are defined
	//_global.myTrace("loading video.swf to " + myVideo);
	myVideo.loadMovie(contentHolder.vPlayerMC); // + cacheVersion);
	//return myVideo;
}	

/* not really sorted out
whereAreSoundFiles = function(thisFile) {
	_global.ORCHID.session.mediaOnCD = false;
	//myTrace("check out sound file=" + thisFile);
	if (_global.ORCHID.projector.name == "FlashStudioPro") {
		_root.FSPFileName = thisFile;
		_root.FSPReturnCode = undefined;
		fscommand("flashstudio.fileexists", "FSPFileName,FSPReturnCode");
		testFileExists = function() {
			FSPCounter++;
			if (FSPCounter > 10) {
				// only run this interval test 10 times, if no response within
				// that time, just give up on this testing as you probably won't be
				// able to find it on the CD either.
				clearInterval(FSPAppInt);
				delete FSPCounter;
			} else {
				// not out of time, but have we got a response?
				if (FSPReturnCode != undefined) {
					clearInterval(FSPAppInt);
					delete FSPfileExistsCounter;
					if (FSPReturnCode == "false") {
						// Hmmm, but paths.media is just the last bit of the full path
						// And all media is read from there, not just sound files
						// Stop this line of reasoning for now until split media folders
						// is better thought out.
						_global.ORCHID.session.mediaOnCD = true;
					} else {
						myTrace("file exists");
					}
					// if true, no need to do anything as the sound file was found
				}
			}
		}
		FSPAppInt = setInterval(testFileExists, 250);	
	}
}
*/
substTags = function(thisText, substList) {
	// just in case you come here with null stuff
	if (substList == null || substList == undefined) return thisText;
	
	// make sure you don't change the original text
	// Note: See ASDG for guidance on pass by reference vs pass by value and how to make copies
	var buildText = thisText;
	// if substList is empty, you will just send back text unadulterated, but still a copy NOT the original
	for (var i in substList) {		
		//trace("looking to replace " + substList[i].tag + " with " + substList[i].text + " in " + buildText);
		buildText = findReplace(buildText, substList[i].tag, substList[i].text, 0);
	}
	return buildText;
}

// v6.2 a function that will take an event from one twf that its height has changed
// so that you can then change the _y of all other twfs
// [this] is one of the twfs
_global.ORCHID.heightChange = function(delta) {
	//myTrace("start heightchange");
	//myTrace("the height of " + this + " has changed by " + delta + " it started at " + this._y + " with height=" + this.holder._height);
	//myTrace("this.holder= " + this.holder + " textHeight = " + this.holder.textheight);
	// so which twfs come after this in this pane?
	// v6.3.5 This fails to move some fields that are smack below. Try using textHeight instead to get rid
	// of any margins that are being picked up by _height
	//var thisY = this._y + this.holder._height - delta; //remember that this._height is the NEW height
	var thisY = this._y + this.holder.textHeight - delta; //remember that this._height is the NEW height
	//myTrace("move anything below>=" + thisY);
	// note: is it sensible to loop through everything in this pane, there might be heaps of unrelated stuff!
	// AR v6.5.4.3 Bug 1404. Don't move weblinks. It would be much better to have this mode based.
	// So sometime get an anchor or something from the media node passed to this object.
	// But for now, just don't move weblinks!
	for (var i in this._parent) {
		//myTrace(this._parent[i]._name + " starts at " + this._parent[i]._y + ":" + this._parent[i]._name.indexOf("Weblink-"));
		//if (this._parent[i]._y >= thisY) {
		if (this._parent[i]._y >= thisY && this._parent[i]._name.indexOf("Weblink-")<0) {
			//myTrace("so moving down " + this._parent[i]);
			this._parent[i]._y += delta;
		}
	}
	// then you need to refresh the screen - NO you don't! Oh yes you do...
	// except that the contentHolder doesn't reflect to the scroll bar - so can you just add/subtract
	// delta to the scroll bar maximum somehow?
	// is there a nice way to get back to the SP rather than _parent._parent?
	this._parent._parent.refreshPane();
	//myTrace("finish heightchange");
}
//#include "putParagraphsOnPrinter.as"
// Duplicate the setup features of the above to let you create content for printing
// this is used to take paragraphs from an object and display them on the screen
putParagraphsOnThePrinter = function(paneHolder, thisText, paneType, paneName, substList, coords, setting) {
	// first, make the mc for the text to go into
	// then create all the TextFields that will hold the paragraphs and load the text into them
	// this will let you figure out the height of the next field down. This bit should be in a
	// refresh routine as well so that if something changes (width or content) you can reset easily.
	// Then you make the "fields" active
	// Then you add any pictures to the pane
	//trace("printing paneHolder = " + paneHolder);
	
	//TIMING: This huge function needs to be broken up due to the timing breaker
	// collect all variables that you need for the loop and stuffAfter into the an object
	// v6.3.4 Common settings for all display routines
	_global.ORCHID.tlc.stuffBeforeCallBack = putParagraphsOnThePrinter_stuffAfter;
	_global.ORCHID.tlc.timeLimit = 1000;
	_global.ORCHID.tlc.maxLoop = thisText.paragraph.length;
	_global.ORCHID.tlc.i = 0;
	_global.ORCHID.tlc.controller = _global.ORCHID.root.tlcController;
	//trace("call ppots_stuffBefore");
	var ppotsVars = putParagraphsOnThePrinter_stuffBefore(paneHolder, thisText, paneType, paneName, substList, coords, setting);
	//trace("now know that ppotsVars.paneSymbol=" + ppotsVars.paneSymbol);
	
	putParagraphsOnThePrinter_mainLoop(ppotsVars);
}
putParagraphsOnThePrinter_stuffBefore = function(paneHolder, thisText, paneType, paneName, substList, coords, setting) {
	myTrace("print for pane=" + paneName);
	var startTime = new Date().getTime();

	// first set a default in case you don't recognise this pane name
	// v6.4.2.7 CUP merge
	//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
		var paneSymbol = "FScrollPaneSymbol";
	//} else {
	//	var paneSymbol = "FScrollPaneSymbol";
	//}
	// TIMING: this function is [sometimes] timed, so collect variables that the later loop and stuff After want
	var ppotsVars = new Object();
	ppotsVars.paneSymbol = paneSymbol;
	ppotsVars.paneName = paneName;
	ppotsVars.thisText = thisText;
	ppotsVars.substList = substList;

	var myX = undefined; var myY = undefined; var myW = undefined; var myH = undefined;
	var myLeftMargin = undefined; var myTitleBar = undefined; var myBackgroundColour = 0xFFFFFF;
	
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0 ||
		_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BC/IELTS") >= 0) {
		var myBorder = false;
	} else {
		var myBorder = true;
	}

	// some variables for the pane are taken from a global style store
	//trace("ppots for " + paneName);
	if (paneName == "Title_SP") {
		myDepth = _global.ORCHID.TitleDepth;		
		if (coords != undefined) {
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			// CUP/GIU
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				// CUP noScroll code
				//myX = 207; myY = 15; myW = 540, myH = 38; 
				// v6.3.5 Make it a little wider
				// v6.4.2.7 Why is it 207 - that is half way across the page! I have removed 100 from all myX for each pane.
				//myX = 207; myY = 15; myW = 560, myH = 38; 
				myX = 107; myY = 15; myW = 560, myH = 38; 
				//myBackgroundColour = 0xFFFFFF;
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
					myBackgroundColour = 0x0096c6; 
				} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("ESG") >= 0) {
					myBackgroundColour = 0xe35a24; 
				} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
					myBackgroundColour  = 0x339966;
				}
				myScroll = false;
			} else {
				myX = 10; myY = 17; myW = 660, myH = 50; // these are faked here for now (w=750)
				// v6.5.2 AR not getting title printed - is it the backgroundColor? No
				myBackgroundColour = 0xCCCCFF;
				//myBackgroundColour = 0xFFFFFF;
				// BC/IELTS
				//myTrace("title scroll, branding=" + _global.ORCHID.root.licenceHolder.licenceNS.branding); 
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("BC/IELTS") >= 0) {
					myScroll = false;
				} else {
					myScroll = true;
				}
			}
		}
		myTrace("print title x=" + myX + " width=" + myW);
		myLeftMargin = 0;  myTitleBar = "";
	// CUP example region
	} else if (paneName == "Example_SP") {
		//myTrace("set up example_SP x=" + myX);
		myDepth = _global.ORCHID.exampleDepth;		
		if (coords != undefined) {
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			// CUP/GIU
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myX = 168; myY = 126; myW = 620, myH = 50; 
				//myX = 168; myY = 56; myW = 620, myH = 10; 
				myX = 68; myY = 56; myW = 620, myH = 10; 
				myBackgroundColour = 0xFFFFFF; // test with a pale colour to see extent of region
			} else {
				// v6.4.2.7 updates
				//myX = 10; myY = 72; myW = 660, myH = 410; 
				//myX = 10; myY = 17; myW = 660, myH = 50; 
				//myBackgroundColour = 0xCCCCFF;
				myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width;
				// v6.5.6.4 New SSS. Since the icons are on the left, exercisePlaceHolder is shifted right, so you don't want it when printing
				// In fact, I don't suppose I ever want it, but for now just do it for SSS
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
					myX = 10; 
				} else {
					myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x; 
				}
				myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
				myH = 10;
				// v6.3.4 It would be good to pick this colour  up from a example fake panel
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder.exerciseColour);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
			}
		}
		myLeftMargin = 0;  myTitleBar = "";
		myScroll = "resize";
	// CUP noScroll code
	} else if (paneName == "NoScroll_SP") {
		//trace("set up noScroll pane parameters");
		myDepth = _global.ORCHID.noScrollDepth;		
		if (coords != undefined) {
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			// CUP/GIU
			var dependentRegions = ["Example_SP"];
			var nsDeep = 0
			for (var i in dependentRegions) {
				if (paneHolder[dependentRegions[i]]._name != undefined) {
					nsDeep += paneHolder[dependentRegions[i]].regionDepth;
				}
			}
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myX = 168; myY = 126; myW = 620, myH = 50; 
				//if (_global.ORCHID.LoadedExercises[0].regions & _global.ORCHID.regionMode.example) {
					// in this scenario, the noScroll box ALWAYS follows the example region, so
					// find out how deep it was and add that to the normal top of the noScroll region
					//trace("push noScroll down " + nsDeep + " pixels");
				//}
				//myX = 168; myW = 620, myH = 10; 
				myX = 68; myW = 620, myH = 10; 
				myY = 56 + nsDeep;
				// v6.3.4 ESG and AGU colouring
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
					myBackgroundColour = 0xB5E3F7;
				} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("ESG") >= 0) {
					myBackgroundColour = 0xf9ded3; 
				} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
					myBackgroundColour  = 0xD6EbE0;
				}
			} else {
				// v6.4.2.7 Updates
				//myX = 10; myW = 660, myH = 410; 
				//myY = 72 + nsDeep; 
				//myX = 10; myY = 17; myW = 660, myH = 50; 
				//myBackgroundColour = 0xCCCCFF;
				myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width;
				// v6.5.6.4 New SSS. Since the icons are on the left, exercisePlaceHolder is shifted right, so you don't want it when printing
				// In fact, I don't suppose I ever want it, but for now just do it for SSS
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
					myX = 10; 
				} else {
					myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x; 
				}
				myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
				myH = 10;
				myY = myY + nsDeep;
				var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.noScrollPlaceHolder.colourBlock);
				var cT = colourObj.getTransform();
				myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
			}
		}
		myLeftMargin = 0;  myTitleBar = "";
		myScroll = "resize";
	} else if (paneName == "Exercise_SP") {
		myDepth = _global.ORCHID.ExerciseDepth;
		// handle split screen case
		//v 6.3.3 change mode to settings
		//if(_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.SplitWindow) {
		// v6.5 Split screen for dragging too
		var nsDeep = 0;
		var dependentRegions = ["Example_SP", "NoScroll_SP"];
		var nsDeep = 0
		for (var i in dependentRegions) {
			if (paneHolder[dependentRegions[i]]._name != undefined) {
				nsDeep += paneHolder[dependentRegions[i]].regionDepth;
			}
		}
		if (_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen) {
			////trace("split screen exercise");
			//// CUP/GIU change settings
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myX = 478; myY = 61; myW = 310; myH = 431;
				myX = 378; myY = 61; myW = 310; myH = 431;
			} else {
			//	myX = 340; myY = 72; myW = 330; myH = 410;
				myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width / 2;
				// v6.5.6.4 New SSS. Since the icons are on the left, exercisePlaceHolder is shifted right, so you don't want it when printing
				// In fact, I don't suppose I ever want it, but for now just do it for SSS
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
					myX = 10 + myW; 
				} else {
					myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x + myW; 
				}
				myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
				myH = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height;
			}
			myY = myY + nsDeep;  myH = myH - nsDeep; // was myH=450 for 800x600 screen
			//myTrace("print:split screen, ex x=" + myX);
		} else {
			if (coords != undefined) {
				myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
			} else {
				// CUP/GIU
				//var nsDeep = 0;
				//var dependentRegions = ["Example_SP", "NoScroll_SP"];
				//var nsDeep = 0
				//for (var i in dependentRegions) {
				//	if (paneHolder[dependentRegions[i]]._name != undefined) {
				//		nsDeep += paneHolder[dependentRegions[i]].regionDepth;
				//	}
				//}
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
					// CUP noScroll code
					//myX = 168; myY = 126; myW = 620, myH = 385; // these are faked here for now (w=750)
					// the exercise y position now depends on the noScroll region (if any)
					//trace("regions=" + _global.ORCHID.LoadedExercises[0].regions);
					//if (_global.ORCHID.LoadedExercises[0].regions & _global.ORCHID.regionMode.noScroll) {
						// in this scenario, the exercise box ALWAYS follows the noScroll and example regions, so
						// find out how deep they were and add that to the normal top of the exercise region
						// and also reduce the total height
						//trace("push exercise down " + nsDeep + " pixels");
					//}
					//myY = 176 + nsDeep;  myH = 385 - nsDeep; 
					myY = 60 + nsDeep;  myH = 440 - nsDeep; // was myH=450 for 800x600 screen
					// v6.2 I think this width has to match the authoring side ex width
					// Or at least the setting in the XML output of the authoring
					//myX = 168; myW = 620; 
					myX = 68; myW = 620; 
				} else {
					// v6.4.2.7 Updates
					//myX = 10; myY = 72 + nsDeep;
					//myW = 660, myH = 410;
					// v6.5.6.4 New SSS. Since the icons are on the left, exercisePlaceHolder is shifted right, so you don't want it when printing
					// In fact, I don't suppose I ever want it, but for now just do it for SSS
					if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
						myX = 10; 
					} else {
						myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x; 
					}
					myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
					myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width;
					myH = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height;
					myY = myY + nsDeep;  myH = myH - nsDeep; // was myH=450 for 800x600 screen
				}
			}
		}
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			myBackgroundColour = 0xFFFFFF;
		} else {
			// v6.3.3 It would be good to pick this colour  up from buttons.ExerciseScreen.fakeExercise
			// v6.5.4.2 Probably you should always print onto a blank background.
			//var colourObj = new Color(_global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder.exerciseColour);
			//var cT = colourObj.getTransform();
			//myBackgroundColour = (cT.rb<<16) | (cT.gb<<8) | cT.bb;
			myBackgroundColour = 0xFFFFFF;
		}
		myScroll = true;
		myLeftMargin = 0;  myTitleBar = "";
	} else if (paneName == "Feedback_SP" || paneName == "Hint_SP") {
		//myTrace("ppotp " + paneName);
		myDepth = _global.ORCHID.FeedbackDepth;
		if (coords != undefined) {
			//trace("sent coords are x=" + coords.x + " and the test is " + (coords!=undefined));
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			//myX = _parent._xmouse; myY = _parent._ymouse;
			// I would really like to try and match the window location to the mouse location
			// but with thoughtful care paid to the edges of the screen, but for now lets
			// just put it in the middle of the screen
			// CUP/GIU
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myX=290; myY=165; myW = 500; myH = 230; myMinW = 350; myMinH = 200;
				myX=190; myY=165; myW = 500; myH = 230; myMinW = 350; myMinH = 200;
			} else {
				myX = 30; myY = 130;	myW = 600; myH = 200;
			}
		}
		// CUP/GIU
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			myBackgroundColour = 0xFFFFFF;
			myLeftMargin = 0;
		} else {
			// v6.4.2.4 Why print with a yellow background? Change to white
			//myBackgroundColour = 0xFFFFCC;
			myBackgroundColour = 0xFFFFFF;
			myLeftMargin = 5;
		}
		myScroll = true;
		//trace("vars for Feedback_SP x=" + myX + ", y=" + myY + ", w=" + myW + ", myH=" + myH);
	} else if (paneName.indexOf("ReadingText_SP") == 0) {
		// CUP noScroll code, switch on this region for this exercise
		// I should probably set this when I detect that there is a reading text rather than now
		// as I might want to use it earlier. And I don't currently read me either!
		//me.regions |= _global.ORCHID.regionMode.readingText;
		
		// AM: for pop up reading text, paneName is ReadingText_SP + (reading text title).
		// So I use (paneName.indexOf("ReadingText_SP") == 0) for the if condition
		//trace("sent coords are x=" + coords.x + " and the test is " + (coords!=undefined));
		//trace("ppots reading text found");
		// v6.3.3 change mode to settings
		//if((_global.ORCHID.LoadedExercises[0].mode & _global.ORCHID.exMode.SplitWindow)
			//myTrace("format split screen reading text");
			// CUP/GIU change settings
			/*
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				myX = 163; myY =127; myW = 300; myH = 385;
			} else {
				myX = 10; myY =72; myW = 330; myH = 410;
			}
			*/		
		if (_global.ORCHID.LoadedExercises[0].settings.misc.splitScreen &&
			paneSymbol == "FScrollPaneSymbol") {
			myDepth = _global.ORCHID.ReadingTextDepth;
			//myTrace("format split screen reading text");
			// CUP/GIU change settings
			// v6.5 Add split screen drag and drop
			var dependentRegions = ["Example_SP", "NoScroll_SP"];
			var nsDeep = 0
			for (var i in dependentRegions) {
				if (paneHolder[dependentRegions[i]]._name != undefined) {
					//myTrace("for " + paneName + ", region " + dependentRegions[i] + " deep=" + paneHolder[dependentRegions[i]].regionDepth);
					nsDeep += paneHolder[dependentRegions[i]].regionDepth;
				}
			}
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				//myX = 163; myY =61; myW = 300; myH = 431;
				myX = 63; myY =61; myW = 300; myH = 431;
			} else {
			//	myX = 10; myY =72; myW = 330; myH = 410;
				myW = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._width / 2;
				// v6.5.6.4 New SSS. Since the icons are on the left, exercisePlaceHolder is shifted right, so you don't want it when printing
				// In fact, I don't suppose I ever want it, but for now just do it for SSS
				if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
					myX = 10; 
				} else {
					myX = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._x; 
				}
				myY = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._y; 
				myH = _global.ORCHID.root.buttonsHolder.ExerciseScreen.exercisePlaceHolder._height;
			}
			// v6.5 Add split screen drag and drop
			myY = myY + nsDeep;  myH = myH - nsDeep; // was myH=450 for 800x600 screen
			//myTrace("split screen, split x=" + myX);
			//myTrace("print:split screen, text x=" + myX);
			myScroll = true; myLeftMargin = 5; myTitleBar = "";
		} else {
			//myTrace("format non split screen reading text");
			// v6.2 - why is this set at Feedback depth not reading Text depth?
			myDepth = _global.ORCHID.FeedbackDepth;
			if (coords != undefined) {
				myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
			} else {
				// v6.3.5 Change dimensions
				//myX = 30; myY = 70;
				myW = 600; myH = 300;
				myX = 16; myY = 127;
			}
			myLeftMargin = 5; 
			// v6.2 What is this?! The name of the reading text should come from the media list nice name
			// actually - it does if the reading text has a nice name!
			myTitleBar = paneName.substr(paneName.indexOf("ReadingText_SP") + 14);
		}
	} else if (paneName == "Rule_SP") {
		// 6.0.4.0, display rule text pane
		myDepth = _global.ORCHID.FeedbackDepth;
		if (coords != undefined) {
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			myX = 30; myY = 70;
			myW = 600; myH = 300;
		}
		myLeftMargin = 5; //myTitleBar = "Rule";
		// 6.0.4.0, get the title bar name from the literal model
		myTitleBar = _global.ORCHID.literalModelObj.getLiteral("rule", "labels");
		myScroll = true;
	} else {
		myDepth = _global.ORCHID.depth;
		if (coords != undefined) {
			myX = coords.x; myY = coords.y; myW = coords.width; myH = coords.height;
		} else {
			myX = _parent._xmouse; myY = _parent._ymouse;
			myW = 200; myH = 100;
		}
		myScroll = true;
	}
	
	// v6.2 I want to reduce the printing size by 80% so the x and y change accordingly
	myX = Math.round(myX * 0.8); myY = Math.round(myY * 0.8);
	
	ppotsVars.myX = myX; ppotsVars.myY = myY; ppotsVars.myW = myW; ppotsVars.myH = myH;
	ppotsVars.myMinW = myMinW; ppotsVars.myMinH = myMinH;
	ppotsVars.myLeftMargin = myLeftMargin; ppotsVars.myTitleBar = myTitleBar;
	//myTrace("pane has x=" + myX + ", width=" + myW + ", height=" + myH);
	// make sure that there is no existing feedback window (this doesn't solve the weird problem of the text
	// not showing in html in the window on the second click)
	// Actually, you don't get any problems (that I can see) if you simply reuse what is on the screen
	var initObj = {branding:_global.ORCHID.root.licenceHolder.licenceNS.branding};
	//var myPane = paneHolder.attachMovie(paneSymbol, paneName, myDepth, initObj); // For now, this is a reserved depth at root level
	var myPane = paneHolder.attachMovie("blob", paneName, myDepth, initObj); // For now, this is a reserved depth at root level
	//trace("created a printing pane=" + myPane);
	ppotsVars.myPane = myPane; 
	
	myPane._x = myX;
	myPane._y = myY;
	// set background colour
	if (myBackgroundColour != 0xFFFFFF) {
		// v6.3.5 Not sure why you cannot use the background style, but you cannot.
		//myPane.setStyleProperty("background", myBackgroundColour);
		//myTrace("set back colour for " + myPane + " to " + myBackgroundColour);
		var filler = myPane.attachMovie("printBackground", "filler", -16384);
		//myTrace("filler created=" + filler);
		var backColour = new Color(filler);
		backColour.setRGB(myBackgroundColour);
		//filler._x = filler._y = 100;
		// for EGU/GIU/CUP balance out the blue background a bit
		filler._x-=20;
	}
	// The screen version has an extra level here - not sure why - something to do with not scrolling?
	//myPane.setScrollContent("blob");
	//var contentHolder = myPane.getScrollContent(); //
	var contentHolder = myPane;
	ppotsVars.contentHolder = contentHolder; 

	return ppotsVars;
}
putParagraphsOnThePrinter_mainLoop = function(ppotsVars) {
	// TIMING, if this ppots call uses the progress bar do this
	//trace("into ppots mainLoop for " + ppotsVars.paneName);
			
	var tlc = _global.ORCHID.tlc;
	tlc.ppots = ppotsVars;

	// v6.5 Copy from screen display version
	// v6.4.3 Can I add a starting point for this depth so that I can slip some layers behind the text if I need to?
	tlc.initialParaDepth = _global.ORCHID.initialParaDepth;
	
	// define the resumeLoop method
	//myTrace("loop for "+ tlc.ppots.paneName + " will go to max=" + tlc.maxLoop);
	tlc.resumeLoop = function(firstTime) {
		var startTime = getTimer();
		var i = this.i;
		var max = this.maxLoop;
		var timeLimit = this.timeLimit;
		var myX = Math.round(this.ppots.myX); 
		var myY = Math.round(this.ppots.myY); 
		var myW = Math.round(this.ppots.myW); 
		var myH = Math.round(this.ppots.myH);
		var myLeftMargin = this.ppots.myLeftMargin;
		var thisText = this.ppots.thisText;
		var contentHolder = this.ppots.contentHolder;
		var paneName = this.ppots.paneName;
		var paneSymbol = this.ppots.paneSymbol;
		var myPane = this.ppots.myPane;			
		var substList = this.ppots.substList;
		
		// v6.5.4.3 Printing by copying the screen exercise content - reference this as a mirror
		var mirrorPaneHolder = _global.ORCHID.root.buttonsHolder.ExerciseScreen;
		var mirrorPane = mirrorPaneHolder[paneName];
		var mirrorContentHolder = mirrorPane.getScrollContent();

		// v6.4.3 Can I add a starting point for this depth so that I can slip some layers behind if I need to?
		var initialParaDepth = this.initialParaDepth;
		//myTrace("start looper, i=" + i + " of max=" + max + " for " + paneName + " pane.x=");
		// The paragraphs are going to be added at depths from 0 to numParagraphs. Reverse the depth
		// order so that the first paragraphs are over the later ones - this should stop any problem with
		// the dropdown list being covered by the next para
		// tidy up the box and refresh it
		// v6.4.3 Can I add a starting point for this depth so that I can slip some layers behind if I need to?
		//var paraDepth = thisText.paragraph.length - i; // starting point of depths for this run
		var paraDepth = thisText.paragraph.length - i + initialParaDepth; // starting point of depths for this run
		while (getTimer()-startTime <= timeLimit && i<max && !firstTime) {
			//myTrace("into timed loop i=" + i);
			var myTop = "0";	var lastPara = 0;	var lastTop = 0;
			var lastBottom = 0;	var thisTop = 0;
			var myCoords = new Object();
			myCoords = thisText.paragraph[i].coordinates;
			var myPara = i; 	// don't use paragraph ID anymore // thisFeedback.paragraph[i].id;
						// but this variable is used for depths. Are depths used as indexes anywhere?
	
			// offset subsequent paragraphs
			var myTop = new String(myCoords.y);
			// if the first paragraph is actually relative treat it as absolute
			if (myTop.charAt(0) == "+" && i == 0) {
				myTop = Number(myTop.substr(1,4));
			// other paragraphs that are relative find the last paragraph bottom and add to it
			} else if (myTop.charAt(0) == "+" && i>0) {
				lastPara = i-1; //thisFeedback.paragraph[i-1].id;
				lastTop = Number(contentHolder["ExerciseBox"+lastPara]._y);
				//lastHeight = Number(contentHolder["ExerciseBox"+lastPara]._height);
				lastHeight = Number(contentHolder["ExerciseBox"+lastPara].getSize().height);
				thisTop = Number(myTop.substr(1,4)); // why limit it to 4?
				//trace("this top="+myTop+" becomes "+thisTop);
				// but this doesn't lead to seamless paragraphs, try reducing it a smidgen
				myTop = Math.round(lastHeight + lastTop + thisTop - 4);
			// same height as last paragraph please
			} else if (myTop.charAt(0) == "=" && i>0) {
				lastPara = i-1;
				myTop = Math.round(Number(contentHolder["ExerciseBox"+lastPara]._y)); 
				//trace("found = so myTop will be " + myTop)
			} else {
				myTop = Number(myTop); // not sure what good this will do if the first character is NaN
			}
			//trace("last para (" + lastPara + ") top=" + lastTop + ", height=" + lastHeight + "(twfH=" + twfHeight + ") so this top=" + myTop);
			//trace("para " + lastPara + " bottom=" + Number(Number(contentHolder["ExerciseBox"+lastPara]._y) + Number(contentHolder["ExerciseBox"+lastPara]._height)));
			//myTrace("ppotP:para " + myPara + " top=" + myTop);
			adjustedX = Math.round(Number(myLeftMargin) + Number(myCoords.x));
			//myTrace("this para ("+i+") will start at " + adjustedX + " for " + paneName);
			// Note: if you want to debug field positions, set the _$coverAlpha parameter in initObj
			var myInitObject = {_x:adjustedX, _y:myTop, border_param:false, autosize_param:true};//, _$coverAlpha:25};
			// add the field using reverse order depths so that dropdown selections aren't masked
			// NOTE that the name of this twf component is used in several places, so DONT CHANGE IT!
			if (paneName == "Feedback_SP") {
				// Very difficult for printing to cope if we use text fields instead of TWF - so copy below
				/*
				myHolder = contentHolder.createEmptyMovieClip("ExerciseBox"+myPara, paraDepth--);
				myHolder._x = myInitObject._x;
				myHolder._y = myInitObject._y;
				myHolder.createTextField("holder", 0, 0, 0, myCoords.width, 4);
				var me = myHolder.holder;
				//trace("created textField=" + me + " width=" + myCoords.width);
				myHolder.getSize = function() {return {height:this._height};}
				thisFormat = _global.ORCHID[thisText.paragraph[i].style];
				thisFormat.tabStops = thisText.paragraph[i].tabArray;
				me.wordWrap = true;
				me.autosize = true;
				me.selectable = false;
				me.html = true;
				//me.border = false;
				me.setHtmlText(thisText.paragraph[i].plainText, thisFormat); 
				*/
				//myInitObject.border_param = true;
				myInitObject.noProcessing_param = true;
				//myTrace("add text=" + thisText.paragraph[i].plainText);
				/* v6.4.2.4 The following differs from screen display, not sure why, so mimic screen display
				var me = contentHolder.attachMovie("FTextWithFieldsSymbol","ExerciseBox"+myPara, paraDepth--, myInitObject)
				me.setSize(myCoords.width, myCoords.height);
		
				var thisStyle = thisText.paragraph[i].style;
				var thisFormat = _global.ORCHID[thisStyle];
				thisFormat.tabStops = thisText.paragraph[i].tabArray;
				me.setHtmlText(thisText.paragraph[i].plainText, thisFormat); 
				//myTrace("twf for printing=" + me);
			} else {
				*/
				//myTrace("fb para coords.width=" + myCoords.width + ", height=" + myCoords.height);
			}
				// v6.5.4.3 Printing selected options - see below
				var me = contentHolder.attachMovie("FTextWithFieldsSymbol","ExerciseBox"+myPara, paraDepth--, myInitObject)
				var myMirror = mirrorContentHolder["ExerciseBox"+myPara];
				//myTrace("print in " + me);
				//myTrace("print from " + myMirror);
				// v6.3.5 When the text is shrunk 80%, the font changes a bit so something that fitted in one line
				// on the screen doesn't on the printer. Can I simply edit the width a bit? This will only work
				// for those AGU exercises where the title is rigorously formatted (most)
				// v6.4.2.4 It particularly doesn't work for bold text where line widths are very different
				//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU/AGU") >= 0) {
				//	if (paneName == "Title_SP") {
				//		myCoords.width = Number(myCoords.width) + 10;
				//		//myTrace("print title para width=" + myCoords.width);
				//	}
				//}
				// v6.5.4.3 We still have a general problem with printing that once you shrink the printing to 80% the fonts don't
				// quite shrink the same, so quite a lot of words no longer fit on the same line, so you get bad breaking.
				// It would be good to be able to add x% to all <paragraph width> figures. Especially for bold (titles).
				myCoords.width *= 1.05; // Try 10%. That is a bit too much. Try 5. That looks good.
				me.setSize(myCoords.width, myCoords.height);
		
				var thisStyle = thisText.paragraph[i].style;
				//trace("pPOTS using style " + thisStyle + " and font " + _global.ORCHID[thisStyle].font);
				// add the tabs stops to the main text format for this paragraph?
				// Note: shouldn't add this to the global style, so make a copy of it
				//Note: You CANNOT do this with a TF as it will become just a normal object
				//var thisFormat = new TextFormat();
				var thisFormat = _global.ORCHID[thisStyle];
				thisFormat.tabStops = thisText.paragraph[i].tabArray;
				//Note: this is where we should make a copy of the text and do the susbstTags changing
				// so that the original does not get altered.
				// we are expecting gapText to contain fields in their original [1] type form
				//if (paneName == "Exercise_SP") {
				//	myTrace("text for printing twf[" + i + "]=" + thisText.paragraph[i].gapText);
				//}
				//myTrace("style=" + thisFormat.font);
				if ((paneName == "Exercise_SP") && 
					(_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Countdown") &&
					!_global.ORCHID.session.currentItem.afterMarking) {
					var thisSettingsBase = _global.ORCHID.LoadedExercises[0].settings.exercise;
					var settings = {matchCapitals:thisSettingsBase.matchCapitals, 
								replaceChar:thisSettingsBase.replaceChar,
								sameLengthGaps:thisSettingsBase.sameLengthGaps}
					me.setCountDownSettings(settings);
					me.setCountDownText(thisText.paragraph[i].plainText, thisFormat); 
				// v6.4.2.7 CUP merge. Feedback text will already have done the substTags for #q and #ya# from 
				// gapText to plainText - so we should stick with that
				}  else if (paneName == "Feedback_SP") {
					me.setHtmlText(substTags(thisText.paragraph[i].plainText, substList), thisFormat); 
				} else {
					//myTrace("ppotP:gap[" + i +"]Text=" + thisText.paragraph[i].gapText);
					//myTrace("substList[0].tag=" + substList[0].tag + "=" + substList[0].text);
					// v6.4.2.4 Change - why was it gapText? Ahh, because otherwise you don't see their answers or the correct ones
					//me.setHtmlText(substTags(thisText.paragraph[i].plainText, substList), thisFormat); 
					
					// v6.5.4.3 I don't see the student's selections for mc options, either before or after marking.
					// One option is to put fields into the gapText so that I can subst them here. That's quite big.
					// This would be better off in view where similar stuff is already done, except that this means I have to change gapText
					// which I don't like to do.
					// Is it not possible to simply read the paragraphs from the screen? I can keep the position and 
					// anything the before loop did, but why do anything different from the screen?
					//var allFieldText = _global.ORCHID.viewObj.showSelectedOptions(thisText);
					//me.setHtmlText(substTags(allFieldText, substList), thisFormat); 
					// For gaps etc you still need to do the substTags because the TWF doesn't hold the answer
					// But for targets you need to do this. This will, of course, ignore any special targets you have added to a gapfill.				
					//}

					if (_global.ORCHID.LoadedExercises[0].settings.exercise.type == "MultipleChoice" ||
					_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Analyze" ||
					_global.ORCHID.LoadedExercises[0].settings.exercise.type == "Quiz" ||
					_global.ORCHID.LoadedExercises[0].settings.exercise.type == "TargetSpotting" ||
					_global.ORCHID.LoadedExercises[0].settings.exercise.type == "ProofReading") {
						// v6.5.4.3 Tabs between fields don't print (especially a Quiz). They are in the text as chr(9) - but work if you replace with a real <tab>
						// This might be better done within TWF. It clearly should be a very common thing.
						var mirroredHtmlText = myMirror.getHtmlText();
						mirroredHtmlText = findReplace(mirroredHtmlText, String.fromCharCode(9), "<tab>");
						//myTrace("mirror=" + mirroredHtmlText);
						me.setHtmlText(mirroredHtmlText);
					} else {
						me.setHtmlText(substTags(thisText.paragraph[i].gapText, substList), thisFormat); 
					}
				}				
			//}	
			i++;
		}
		if (i < max) {
			//myTrace("not finished display loop yet");
			this.i = i;
			//this.updateProgressBar((i/max) * this.proportion); // this part of the process is x% of the time consuming bit
			this.controller.incPercentage((i/max) * this.proportion);
		} else if (i >= max || max == undefined) {
			//myTrace("finished display loop");
			this.i = max+1; // just in case this is run beyond the limit
			//this.updateProgressBar(this.proportion); // this part of the process is 50% of the time consuming bit
			this.controller.setPercentage(this.proportion + this.startProportion);
			//myTrace("kill resume loop");
			delete this.resumeLoop;
			this.controller.stopEnterFrame();
			//myTrace("% at end of this part of display " + this.controller.getPercentage());
			this.stuffBeforeCallBack(this.ppots);
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
	tlc.controller.setEnabled(true);
	if (tlc.proportion > 0) {
		//myTrace("start tlc loop");
		// v6.3.5 You were getting double stuff here as the frame event ALSO ran resumeLoop
		// so now try to start enter frame ONLY when you go through a resume loop for the first time
		//tlc.controller.startEnterFrame();
		//myTrace("start looper, i=" +tlc.i + " of max=" + tlc.maxLoop + " timeLimit=" + tlc.timeLimit + " for " + tlc.paneName);
		tlc.resumeLoop(true);
	} else {
		// v6.3.5 See comment about timing problem - give them 10 seconds to display this bit!!
		// Or eventually make it a tlc based one, which means you need a callback and synchronicity
		_global.ORCHID.tlc.timeLimit = 10000;
		tlc.startProportion = tlc.controller.getPercentage();
		//myTrace("non tlc resumeLoop");
		//myTrace("non-looper,  max=" + tlc.maxLoop + " timeLimit=" + tlc.timeLimit + " for " + tlc.paneName);
		tlc.resumeLoop();
	}
	/* This is the end of the old 
	tlc.controller.setEnabled(true);
	if (tlc.proportion > 0) {
		//myTrace("start tlc loop");
		tlc.controller.startEnterFrame();
		tlc.resumeLoop(true);
	} else {
		// v6.3.5 see comment about timing 
		_global.ORCHID.tlc.timeLimit = 10000;
		tlc.startProportion = tlc.controller.getPercentage();
		//myTrace("non tlc loop");
		tlc.resumeLoop();
	}
	*/
}
putParagraphsOnThePrinter_stuffAfter = function(ppotsVars) {
	//trace("ok, i am in ppots_stuffAfter for " + ppotsVars.paneName);
	var myX = ppotsVars.myX; myY = ppotsVars.myY; myW = ppotsVars.myW; myH = ppotsVars.myH;
	var myMinW = ppotsVars.myMinW; myMinH = ppotsVars.myMinH;
	var myLeftMargin = ppotsVars.myLeftMargin;
	var thisText = ppotsVars.thisText;
	var contentHolder = ppotsVars.contentHolder;
	var paneName = ppotsVars.paneName;
	var paneSymbol = ppotsVars.paneSymbol;
	var myPane = ppotsVars.myPane;			
	var susbstList = ppotsVars.substList;

// ************
// MULTIMEDIA
// ************
	//myTrace("media items=" + thisText.media.length);
	if (thisText.media.length > 0) {

		for (var i = 0; i < thisText.media.length; i++) {
			var me = thisText.media[i];
			// the following check differentiates between different types of media - presently
			// floating, embedded and anchored
			if (me.type.substr(0, 2) == "m:" || me.type.substr(0, 2) == "q:" || me.type.substr(0, 2) == "a:") {
				// floating media has no coordinates
				if (me.coordinates.x == undefined || me.coordinates.y == undefined) {
				} else {
					// this is for embedded media (at present it doesn't cope with autoPlay)
					// media has a mode that (amongst other things) lets you set it to only appear after marking
					if (me.mode & _global.ORCHID.mediaMode.ShowAfterMarking) {
					// v6.4.3 Also don't print pictures that go under the text
					} else if (me.mode & _global.ORCHID.mediaMode.DisplayUnder) {
						myTrace("ignoring displayUnder for " + me.fileName);
					} else {
						//myTrace("adding print media=" + me.fileName + " type=" + me.type);
						// but in this case you want the media to be shown right away
						//showMediaItem(me, contentHolder);
						/*
							use a function like showMediaItem to display media for printing
							so remove a block of code
						
						//var me = thisMediaItem;
						//var myFile = _global.ORCHID.paths.root + _global.ORCHID.paths.media + me.fileName;
						// v6.3.5 Allow for media to come from a shared location if desired
						if (me.location == "shared") {
							// also allow audio files to come from language sub folders
							// not much point for the printer!
							//if (me.type.substr(2) == "audio") {
							//	var subFolder = _global.ORCHID.functions.addSlash(_global.ORCHID.literalModelObj.getLiteralLanguage()); // this is a function in control
							//} else {
								var subFolder = "";
							//}
							var myFile = _global.ORCHID.paths.sharedMedia + subFolder + me.fileName;
							//myTrace("shared media, so read file= " + myFile)
						//v6.4.2 Allow for media to come from a fully specified location
						} else if (me.location == "URL") {
							var myFile = me.fileName;
							myTrace("URL media file= " + myFile)
						} else {
							//v6.4.2 AP editing ce
							if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
								var myFile = _global.ORCHID.paths.editedMedia + me.fileName;
							} else {
								var myFile = _global.ORCHID.paths.media + me.fileName;
							}
						}
						var myCoords = new Object();
						// 6.0.3.0 The coordinates of an anchored media file need to be calculated
						// relative to the paragraph it is anchored to
						if (me.anchorPara != undefined) {
							//myTrace("showing an anchored media item for para=" + me.anchorPara);
							//myTrace("media.x=" + me.coordinates.x + " para.x=" + contentHolder["ExerciseBox" + me.anchorPara]._x);
							myCoords.x = contentHolder["ExerciseBox"+me.anchorPara]._x + parseInt(me.coordinates.x);
							myCoords.y = contentHolder["ExerciseBox"+me.anchorPara]._y + parseInt(me.coordinates.y);
							//myTrace("final x=" + myCoords.x + " y="+ myCoords.y);
							myCoords.width = me.coordinates.width;
							myCoords.height = me.coordinates.height;
							myCoords.height = me.coordinates.height;
							myCoords.width = me.coordinates.width
							//myCoords.x = contentHolder["ExerciseBox" + me.anChorPara]._x + parseInt(me.coordinates.x);
							//myCoords.y = contentHolder["ExerciseBox" + me.anchorPara]._y + parseInt(me.coordinates.y);
						} else {
							myCoords = me.coordinates;
						}
						//myTrace("sMI file "+myFile+", it is type " + me.type + " into " + contentHolder);
						if (me.type.substr(2) == "picture") {
							//trace("add at depth " + (Number(_global.ORCHID.mediaDepth) + Number(me.id)));
							//v6.4.1 Allow stretching
							var initObj = {jbURL:myFile, jbWidth:myCoords.width, jbHeight:myCoords.height, jbX:myCoords.x, jbY:myCoords.y, 
										jbStretch:me.stretch,
										jbMediaType:me.type};
							//trace("sMI width=" + initObj.jbWidth);
							var myPicture = contentHolder.attachMovie("mediaHolder", "MediaHolder"+me.id, Number(_global.ORCHID.mediaDepth) + Number(me.id), initObj);
							//var myPicture = contentHolder.createEmptyMovieClip("MediaHolder"+me.id, Number(_global.ORCHID.mediaDepth) + Number(me.id));
							// v6.3.3 Printing isn't including pictures as they are not loaded in time. I guess they are being loaded
							// by the jukebox later. So why not load them now and forget the jukebox?
							// Good idea in theory, but simply using the code here does not load the picture
							// Easier to keep with the mediaHolder stuff but just build in a delay on the final print command
							//myPicture.loadMovie(myFile);
							//myTrace("added print picture=" +myFile);
						
						} else if (me.type.substr(2) == "audio") {
							// v6.3.5 Remove audio buttons from printed copies? Hmm, this seems a shame
							// as teachers might be printing copies to show students what to do. But with 
							// printing of splitScreens, the audio from the first page appears on every
							// page.
							var initObj = {jbURL:myFile, _x:myCoords.x, _y:myCoords.y, jbMediaType:me.type};
							//myTrace("showing audio button at x=" + initObj._x + ", y=" + initObj._y);
							//initObj.jbURL = myFile; // try to make this more local rather than global
							//trace(" with mode="+me.mode);
							//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
							//v6.4.2.1 New media icons
							//var myPush = contentHolder.attachMovie("playAudio", "playAudio" + me.id, Number(_global.ORCHID.mediaDepth) + Number(me.id), initObj);
							var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playAudio" + me.id, Number(_global.ORCHID.mediaDepth) + Number(me.id), initObj);
							myPush.setTarget("embedSmallAudio");
							//} else {
							//	var myPush = contentHolder.attachMovie("audioAPO", "playAudio" + me.id, Number(_global.ORCHID.mediaDepth) + Number(me.id), initObj);
							//}
							// v6.2 The audio controls are actually buttons - so you cannot use initObj in attachMovie to set parameters
							// so set them now
							//for (var j in initObj) {
							//	myPush[j] = initObj[j];
							//}
						
						//myTrace("sMI file "+myFile+", it is type " + me.type + " into " + contentHolder);
						} else if (me.type.substr(2) == "record") {
							var initObj = {_x:myCoords.x, _y:myCoords.y};
							//myTrace("add a recorder at x=" + myCoords.x);
							var myRecorder = contentHolder.attachMovie("recorderControl", "recordAudio"+me.id, Number(_global.ORCHID.mediaDepth) + Number(me.id), initObj);
							// v6.2 The audio controls are actually buttons - so you cannot use initObj in attachMovie to set parameters
							// so set them now
							for (var j in initObj) {
								myRecorder[j] = initObj[j];
							}
						}
						*/
						printMediaItem(me, contentHolder);
					}
				}
			}
		}
	}
	
	// ******
	// set the size of the finished pane
	// ******
	// CUP noScroll code - for measuring region heights
	var max = ppotsVars.thisText.paragraph.length;
	var lastTop = ppotsVars.contentHolder["ExerciseBox"+(max-1)]._y;
	var lastHeight = Number(ppotsVars.contentHolder["ExerciseBox"+(max-1)].getSize().height);
	myPane.regionDepth = lastTop + lastHeight; // - 4; don't adjust for borders as you want them.
	//trace(myPane + ".regionDepth=" + Number(lastTop + lastHeight));
	//trace("same contentHeight=" + contentHolder._height);
	
	// CUP noScroll code - does any media in the pane increase the height?
	for (var i in thisText.media) {
		var me = thisText.media[i].coordinates;
		// stuff apart from pictures/animations tends not to have a height so it won't
		// effect anything.
		var myHeight = Number(me.y) + Number(me.height);
		if (myHeight > myPane.regionDepth) {
			//trace("picture " + thisText.media[i].fileName + " is deeper at=" + myHeight);
			myPane.regionDepth = myHeight;
		}
	}
	// v6.4.2 If a picture is at the end of the content, the scroll bar will probably not let you go down enough
	// so see if you need to increase the content._height (not this is contentHolder not the pane)
	for (var i in thisText.media) {
		var me = thisText.media[i].coordinates;
		// stuff apart from pictures/animations tends not to have a height so it won't
		// effect anything.
		if (me.calculatedY != undefined) {
			var myHeight = Number(me.calculatedY) + Number(me.height);
		}else {
			var myHeight = Number(me.y) + Number(me.height);
		}
		var vSpacer = 20;
		//myTrace("for " + thisText.media[i].fileName + " bottom is at " + myHeight + " compare to " + contentHolder._height);
		if (myHeight > contentHolder._height) {
			// can I make it deeper just like this? NO, it stretches everything
			//contentHolder._height = myHeight + vSpacer;
			// so instead try adding in a dummy mc right at the bottom
			var safeDepth = thisText.paragraph.length+1; // starting point of depths for this run
			//myTrace("safedepth=" + safeDepth);
			var myInitObject = {_x:0, _y:myHeight};
			var dummy = contentHolder.attachMovie("blob","endMarker", safeDepth, myInitObject)
			//myTrace("deepen contentHolder to " + contentHolder._height);
		}
	}
	
//	var thisHeight = myH;
//	if (myPane.resize) {
	var thisHeight = ppotsVars.myPane.regionDepth;
	//myTrace("region height for " + paneName + "=" + thisHeight);
//	}
	// the only size you care about is the background, everything else will autosize
	myPane.filler._width = myW;
	myPane.filler._height = thisHeight;
	
	//trace("at end of pPOTS, ex.mode=" + _global.ORCHID.LoadedExercises[0].mode);
	//TIMING: this is the end of the timed function, so perform the original callback
	_global.ORCHID.tlc.callback();
}
// 6.4.2.4. new function, pulls out code from ppoPrinter
// this function is based on showMediaItem, but with all interactive stuff removed
printMediaItem = function(thisMediaItem, contentHolder) {
	var me = thisMediaItem;
	var mediaDepth = Number(_global.ORCHID.mediaDepth) + Number(me.id);
	//myTrace("printMediaItem.id " + me.id + " at depth="+ mediaDepth + " to " + contentHolder);
	//var myFile = _global.ORCHID.paths.root + _global.ORCHID.paths.media + me.fileName;
	// v6.3.5 Allow for media to come from a shared location if desired
	if (me.location == "shared") {
		// v6.4.2.4 Also streamedAudio
		//if (me.type.substr(2) == "audio") {
		if (me.type.toLowerCase().indexOf("audio")>=0) {
			// v6.4.1 New literal format
			//var subFolder = _global.ORCHID.functions.addSlash(_global.ORCHID.literalModelObj.getLiteralLanguage().mediaFolder); // this is a function in control
			var subFolder = _global.ORCHID.functions.addSlash(_global.ORCHID.literalModelObj.getLanguageDetails().mediaFolder); // this is a function in control
			//myTrace("subFolder=" + subFolder);
		} else {
			var subFolder = "";
		}
		var myFile = _global.ORCHID.paths.sharedMedia + subFolder + me.fileName;
	// v6.5.6 Streaming
	} else if (me.location == "streaming") {
		// v6.5.5.5 Slight change to steaming media path name
		var myFile = _global.ORCHID.paths.streamingMediaFolder + me.fileName;
		//myTrace("showMediaItem file= " + myFile)
	// v6.5.6.5 Brand
	} else if (me.location == "brandMovies") {
		var myFile = _global.ORCHID.paths.brandMovies + me.fileName;
	//v6.4.2 Allow for media to come from a fully specified location
	} else if (me.location == "URL") {
		var myFile = me.fileName;
		//myTrace("URL media file= " + myFile)
	//v6.4.2.6 Media comes from original location
	} else if (me.location == "original") {
		var myFile = _global.ORCHID.paths.media + me.fileName;
		//myTrace("original media file= " + myFile)
	} else {
		//v6.4.2 AP editing ce
		if (_global.ORCHID.session.currentItem.enabledFlag & _global.ORCHID.enabledFlag.edited){
			var myFile = _global.ORCHID.paths.editedMedia + me.fileName;
			//myTrace("editedMedia = " + myFile);
		} else {
			var myFile = _global.ORCHID.paths.media + me.fileName;
			//myTrace("editedMedia = " + myFile);
		}
	}
	var myCoords = new Object();
	// 6.0.3.0 The coordinates of an anchored media file need to be calculated
	// relative to the paragraph it is anchored to
	if (me.anchorPara != undefined) {
		// v6.3.4 For any CUP product, override the x and y offsets from the XML as sometimes they are going wrong
		// when coming out of Author Plus v6.4.11
		// we know that is should always be x=-35, y=+4
		if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP") >= 0) {
			me.coordinates.x = -35;
			me.coordinates.y = 4;
		}
		//myTrace("showing an anchored media item for para=" + me.anchorPara + " mode=" + me.mode);
		//myTrace("media.x=" + me.coordinates.x + " para.x=" + contentHolder["ExerciseBox" + me.anchorPara]._x);
		//v6.4.2 adding in the ability to have question based pictures as well as audio
		// if you are pushing text right, don't touch the x coordinate of the image
		if (me.mode & _global.ORCHID.mediaMode.PushTextRight) {
			myCoords.x = parseInt(me.coordinates.x);
		} else {
			myCoords.x = contentHolder["ExerciseBox"+me.anchorPara]._x + parseInt(me.coordinates.x);
		}
		myCoords.y = contentHolder["ExerciseBox"+me.anchorPara]._y + parseInt(me.coordinates.y);
		myTrace("anchor calc final x=" + myCoords.x + " y="+ myCoords.y);
		// v6.4.2 You are using local var for calculated coordinates here - which means that no-one else
		// knows what you have just done. If you were to simply edit me.coordinates it might cause
		// double counting if you come thorugh here again, so for ease just add a couple of new properties.
		me.coordinates.calculatedX = myCoords.x;
		me.coordinates.calculatedY = myCoords.y;
		
		myCoords.width = me.coordinates.width;
		myCoords.height = me.coordinates.height;
		//myCoords.x = contentHolder["ExerciseBox" + me.anChorPara]._x + parseInt(me.coordinates.x);
		//myCoords.y = contentHolder["ExerciseBox" + me.anchorPara]._y + parseInt(me.coordinates.y);

		//v6.4.2 adding in the ability to have question based pictures as well as audio
		// You can add the image easily just by using q:picture, but this just sits over the text.
		// So what we want to do is to use mode to say if the image overlays or pushes down
		// the text (maybe even pushes right?). This requires measuring the media and then
		// moving ALL the rest of the paragraphs down by this much (or all the paragraphs across
		// if their y is within the height of the image if you are being fancy).
		// v6.4.2.1 But you wouldn't move text if the media was in popup mode - check just in case
		// the seemingly incompatible modes are set!
		if (	me.mode & _global.ORCHID.mediaMode.PushTextDown && 
			!(me.mode & _global.ORCHID.mediaMode.PopUp)) {
			// what happens if the media has no coordinates? Well, can't cope with that so
			// simply assume it is 100 and add stretch to the properties
			if (myCoords.height < 1) {
				myCoords.height =100;
				me.stretch = true;
			}
			var delta = parseInt(myCoords.height) + 0; // add a little vertical buffer
			//myTrace("media pushes text down by " + delta + " from " + myCoords.y);
			for (var i in contentHolder) {
				//myTrace(i + "._y=" + contentHolder[i]._y)
				if (i.indexOf("ExerciseBox")==0 && contentHolder[i]._y >= myCoords.y) {
					//myTrace("so down it goes");
					contentHolder[i]._y += delta;
				}
			}
			// Unless you put all images before audio, you might need to move down any
			// audio that you have already anchored to a para that is now moving. but how on 
			// earth to know that? I suppose it is if earlier in media array and y > then move.
			// For now, simply make sure that all media images go before audio in exercise XML.
		}
					
	} else {
		myCoords = me.coordinates;
	}
	//trace("sMI file "+myFile+", it is type " + me.type + " into " + contentHolder);

	// debug - what have we got here then?
	myTrace("print.media: type=" + me.type.substr(2) + " mode=" + me.mode + " playTimes=" + me.playTimes);
	// v6.4.2.1 Move popup functions into here as well as embed functions.
	// We will have forced all audio to have the popup mode at an earlier point
	if (me.mode & _global.ORCHID.mediaMode.PopUp) {
		// v6.4.2.4 See if you can do audio in the same way
		//if (me.type.substr(2) == "picture" || me.type.substr(2) == "video" || me.type.substr(2) == "animation") {
		// v6.4.3 Audio streams by default now
		if (	me.type.substr(2) == "picture" || me.type.substr(2) == "video" || me.type.substr(2) == "animation" || 
			me.type.substr(2) == "streamingAudio" || me.type.substr(2) == "audio") {
			// object to hold media details (anything in a puw is anchored top left)
			//v6.4.1.5 For network video playing, you need the full path, not just a relative one
			//v6.4.2.1 according to comment for floating video this is not true - the path is already full
			//v6.4.2.3 No, just not true. Unless the location.ini has full path for content, this will not be full
			//v6.4.2.4 Since mdm will now certainly have full path in content (due to Win98 changes) you can skip this
			//if (_global.ORCHID.projector.name == "MDM") {
			//	myFile = _global.ORCHID.paths.root + myFile;
			//	//myTrace("MDM, so add root to content path=" + myFile);
			//}
		
			// v6.2 I want to reduce the printing size by 80% so the x and y change accordingly
			// v6.4.2.4 Except that this doesn't really seem to add up. On some exercises, y=90% and x=100%, on others they are both 100%
			myCoords.x = Math.round(myCoords.x * 1); myCoords.y = Math.round(myCoords.y * 1);
		
			//v6.4.1 Allow stretching
			// v6.4.2.1 The move into showMedia means we have calculated myCoords
			var mediaObj = {jbURL:myFile, _x:myCoords.x, _y:myCoords.y, jbMediaType:me.type, 
						jbName:me.name, 
						jbWidth:myCoords.width, jbHeight:myCoords.height, jbX:myCoords.x, jbY:myCoords.y, 
						jbStretch:me.stretch,
						jbDuration:me.duration, jbAnchor:"tl",
						jbID:me.id};
			//mediaObj.jbAutoPlay = (_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)); 
			mediaObj.jbAutoPlay = true; 
			/*
				removed stuff
			*/
			var initObj = {_x:myCoords.x, _y:myCoords.y};
			var mediaDepth = Number(_global.ORCHID.mediaDepth) + Number(me.id);
			//myTrace("add video play button at depth=" + mediaDepth);
			//v6.4.2.1 Add new icons for playing multimedia
			// To be consistent with other buttons in the library, you should add the button component
			// and then attach the particular graphics.
			//myTrace("embed icon for " + me.type.substr(2));
			if (me.type.substr(2) == "picture") {
				var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playPicture" + me.id, mediaDepth, initObj);
				if (me.anchorPara == undefined) {
					myPush.setTarget("embedPicture");
					//myTrace("just added popup picture, large at x=" + myCoords.x);
				} else {
					myPush.setTarget("embedSmallPicture");
					//myTrace("just added popup picture, small at x=" + myCoords.x);
				}
			} else if (me.type.substr(2) == "video" || me.type.substr(2) == "animation") {
				var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playVideo" + me.id, mediaDepth, initObj);
				if (me.anchorPara == undefined) {
					myPush.setTarget("embedVideo");
					//myTrace("just added popup video, large at x=" + myCoords.x + " depth=" + mediaDepth);
				} else {
					myPush.setTarget("embedSmallVideo");
					//myTrace("just added popup video, small at x=" + myCoords.x);
				}
			} else {
				var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playAudio" + me.id, mediaDepth, initObj);
				if (me.anchorPara == undefined) {
					myPush.setTarget("embedAudio");
					//myTrace("just added audio, large at x=" + myCoords.x + " depth=" + mediaDepth);
				} else {
					myPush.setTarget("embedSmallAudio");
					//myTrace("just added audio, small at x=" + myCoords.x);
					myTrace("3641:just added audio to " + myPush);
				}
			}
		// v6.4.3 Audio streams by default
		//} else if (me.type.substr(2) == "audio") {
		} else if (me.type.substr(2) == "staticAudio" || me.type.substr(2) == "flashAudio") {
			var initObj = {jbURL:myFile, _x:myCoords.x, _y:myCoords.y, jbMediaType:me.type};
			// v6.3.5 Code changed for proper switching on/off of embedded sounds. But this will not easily
			// let you switch the graphics correctly.
			/*
				removed stuff
			*/
			// To be consistent with other buttons in the library, you should add the button component
			// and then attach the particular graphics.
			// The graphic that you use for audio depends on whether this audio is anchored (in which case we
			// assume that it is part of the text) or regular floating.
			var myPush = contentHolder.attachMovie("FGraphicButtonSymbol", "playAudio" + me.id, mediaDepth, initObj);
			if (me.anchorPara == undefined) {
				myPush.setTarget("embedAudio");
				//myTrace("just added audio, large at x=" + myCoords.x);
			} else {
				myPush.setTarget("embedSmallAudio");
				//myTrace("just added audio, small at x=" + myCoords.x);
				myTrace("3664:just added audio to " + myPush);
			}
			//myTrace("added embedded sound " + myPush + " for " + myPush.jbURL + "in contentHolder=" + contentHolder);
			//trace("created playAudio=" + myPush._name + " at depth " + myPush.getDepth());
		}
	} else {
		// This is the code for inserting direct media into the exercise - of any type
		// but of course it doesn't make sense for audio to be here, it is treated as popup
		//v6.4.1 Add in video
		//myTrace("xxx");
		if (me.type.substr(2) == "video") {
		// v6.4.2.4 Avoid printing video as it screws things up.
		/*
			//myTrace("showMediaItem for " + me.type.substr(2) + ", duration=" + me.duration);
			//v6.4.1 Allow stretching
			var initObj = {jbURL:myFile, jbWidth:myCoords.width, jbHeight:myCoords.height, jbX:myCoords.x, jbY:myCoords.y, 
						jbStretch:me.stretch,
						jbMediaType:me.type, jbDuration:me.duration, jbAnchor:me.anchor,
						jbID:me.id};
			initObj.jbAutoPlay = (_global.ORCHID.mediaMode.AutoPlay == (me.mode & _global.ORCHID.mediaMode.AutoPlay)); 
	
			//v6.4.1.5 For network video playing, you need the full path, not just a relative one
			//v6.4.2.1 according to comment for floating video this is not true - the path is already full
			//v6.4.2.3 No, just not true. Unless the location.ini has full path for content, this will not be full
			//v6.4.2.4 Since mdm will now certainly have full path in content (due to Win98 changes) you can skip this
			//if (_global.ORCHID.projector.name == "MDM") {
			//	//myTrace("MDM, so add root to content path");
			//	initObj.jbURL = _global.ORCHID.paths.root + myFile;
			//}
			
			// Call out to video player creation
			initObj.streamingLabel = _global.ORCHID.literalModelObj.getLiteral("streaming", "labels");
			// Try to help with loading videoPlayer.swf into same mc problems by making separate MCs
			var extraHolder = contentHolder.createEmptyMovieClip("extraHolder"+me.id, mediaDepth);
			//var myVideo = createVideoPlayer(me, initObj, contentHolder);
			// v6.4.2.4 You can't get a return from cVP as asynch
			//var myVideo = createVideoPlayer(me, initObj, extraHolder);
			createVideoPlayer(me, initObj, extraHolder);
		*/		
		} else if (me.type.substr(2) == "picture") {
			//myTrace("for image " + me.id+ " stretch=" + me.stretch);
			//trace("add at depth " + (Number(_global.ORCHID.mediaDepth) + Number(me.id)));
			// can you get anywhere by changing coords within the mediaHolder? No
			//myCoords.y = 10;
			//myTrace("adding picture");
			//v6.4.1 Allow stretching
			var initObj = {jbURL:myFile, jbWidth:myCoords.width, jbHeight:myCoords.height, jbX:myCoords.x, jbY:myCoords.y, 
						jbStretch:me.stretch,
						jbMediaType:me.type};
			/*
				removed stuff
			*/
			myTrace("embedded picture id=" + me.id + " depth=" + mediaDepth + " file=" + initObj.jbURL);
			var myPicture = contentHolder.attachMovie("mediaHolder", "MediaHolder"+me.id, mediaDepth, initObj);
			//myTrace("after attach mediaHolder");
			//myTrace("added picture=" + me.id + " x=" + initObj.jbX + " depth=" + (Number(_global.ORCHID.mediaDepth) + Number(me.id)));

		} else if (me.type.substr(2) == "record") {
			//myTrace("showMediaItem for recorder");
			var initObj = {_x:myCoords.x, _y:myCoords.y};
			// insert a simple button set for the recorder
			// but you have to find someother way to do the last typing box fill in as an onRelease will
			// stop the internal buttons from working.
			/*
			initObj.onRelease = function () {
				// v6.2 Now, it is possible/likely/certain that the last typing box didn't insert it's answer into it's field
				// so we should do it for it.
				myTrace("onRelease for the recorder")
				if (_global.ORCHID.session.currentItem.lastGap != undefined) {
					//trace("doing the last insert from cmdMarking");
					insertAnswerIntoField(_global.ORCHID.session.currentItem.lastGap.field, _global.ORCHID.session.currentItem.lastGap.text, true);
					_global.ORCHID.session.currentItem.lastGap = undefined;
				}
			}
			*/
			//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
			//} else {
			var myRecorder = contentHolder.attachMovie("recorderControl", "recordAudio" + me.id, mediaDepth, initObj);
			//myTrace("link to audio recorder " + myRecorder + " at x=" + initObj._x);
			//}
			// you can't run the functions in this MC until you are sure it has loaded
			// use a timer as a cheap and cheerful way of doing this!
			// But when I run on the network these functions are clearly STILL not present.
			// So cheap and cheerful is downright dangerous!
			/*
				removed stuff
			*/
			
		// this looks like it could be merged with picture (as could audio eventually I would think)
		// but keep it separate for now just in case. It means that a click on a picture is interpreted
		// as if it were a field, but a click on an animation (which looks identical) will play it. Maybe you
		// should put a play button overlay on the animation - use the audio one?
		// This would also be better as currently clicks on the animation are NOT passed through to the Flash
		// animation, which is bad if the animation is supposed to interactive.
		} else if (me.type.substr(2) == "animation") {
			//v6.4.1 Allow stretching
			var initObj = {jbURL:myFile, jbWidth:myCoords.width, jbHeight:myCoords.height, jbX:myCoords.x, jbY:myCoords.y, 
						jbStretch:me.stretch,
						jbMediaType:me.type};
			/*
				removed stuff
			*/
			var myPicture = contentHolder.attachMovie("mediaHolder", "MediaHolder"+me.id, mediaDepth, initObj);
			// the animation will actually be put in a level 1 lower than this (.picture)
			// see the mediaHolder MC in the exercise library for details (just onLoad functions)
			//trace("added animation to " + myPicture);
			
		// v6.3 Add in the url type (ready for when authoring supports it).
		} else if (me.type.substr(2) == "url") {
			myTrace("found an embedded url " + me.fileName);
			var initObj = {jbURL:me.fileName, _x:myCoords.x, _y:myCoords.y, jbMediaType:me.type};
			/*
				removed stuff
			*/
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("CUP/GIU") >= 0) {
				var myPush = contentHolder.attachMovie("urlEGU", "playURL" + me.id, mediaDepth, initObj);
			} else {
				var myPush = contentHolder.attachMovie("urlAPO", "playURL" + me.id, mediaDepth, initObj);
			}
			// v6.2 The icon is a button - so you cannot use initObj in attachMovie to set parameters
			// so set them now
			for (var i in initObj) {
				myPush[i] = initObj[i];
			}
		}
	}
}


