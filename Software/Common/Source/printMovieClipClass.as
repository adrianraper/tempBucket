
class printMovieClipClass extends MovieClip {
// *** define properties used in printMovieClipClass ***
	// Define widths & heights (can be set by user)
	var MAX_WIDTH:Number;		// width of the paper
	var MAX_HEIGHT:Number;		// height (length) of the paper
	var leftMargin:Number;		// left margin
	var topMargin:Number;		// top margin
	var bottomMargin:Number;	// bottom margin
	var headHeight:Number;		// height of the header
	var footHeight:Number;		// height of the footer
	// Define physical properties of the paper (cannot be set by user)
	var contentHeight:Number;	// height of the content
	var pageCount:Number;		// number of paper
	var extraPages:Number;		// v6.4.2.4 if you add pages due to shifting paras around
	var printedNo:Number;		// number of lines printed
	// Define depth for this movie clip (increment for MCs added into this clip)
	var depth:Number;			// depth of this movie clip
	// Define header & footer movie clips
	var topMC:MovieClip;		// top movie clip in the place of header
	var bottomMC:MovieClip;		// bottom movie clip in the place of footer
	var headerStr:String;
	var footerStr:String;
	// Define print type
	var printType : Number;
	// Define an array to hold the objects (children MCs) to move around in sourceMC
	var objectArray:Array;
	var yOffset:Number;
	// Define an array to hold Reading Text objects
	var RTobjectArray:Array;	// v6.3.4
	var RTyOffset:Number;		// v6.3.4
	var RTprintedNo:Number;	// v6.3.4
// *** end of defining properties ***

// *** initialize properties (for A4 paper) ***
	function printMovieClipClass() {
		_visible = false;
		MAX_WIDTH = 8.26*72/0.8;
		MAX_HEIGHT = 11.68*72/0.8;
		//leftMargin = 0.5*72/0.8;
		leftMargin = 0.2*75;
		topMargin = 0.5*72;
		bottomMargin = 0.4*72;
		headHeight = 30;
		footHeight = 30;
		contentHeight = MAX_HEIGHT*0.8-bottomMargin-footHeight-20;
		headerStr = "";
		footerStr = "";
		resetPrintParameters();
	}

	private function resetPrintParameters() {
		pageCount = 1;
		extraPages=0;
		printType = 0;		// default 0 as nothing chosen
		printedNo = -1;
		yOffset = 0;
		
		RTprintedNo = -1;	// v6.3.4
		RTyOffset = 0;		// v6.3.4
	}

	private function clearContent(sourceMC) {
		// reset all movieclips/textfields
		switch (printType) {
			case 1:	// movieclip (feedback)
				sourceMC.header_txt.htmlText = " ";
				sourceMC.footer_txt.htmlText = " ";
				sourceMC.header.removeMovieClip();
				sourceMC.footer.removeMovieClip();
				sourceMC._visible = false;
				sourceMC.removeMovieClip();
				break;
			case 2:	// textfield
				this["d_txt"].htmlText = "";
				topMC.removeMovieClip();
				bottomMC.removeMovieClip();
				break;
			case 3:	// movieclip (exercise)
				sourceMC.header_txt.htmlText = " ";
				sourceMC.footer_txt.htmlText = " ";
				sourceMC.header.removeMovieClip();
				sourceMC.footer.removeMovieClip();
				sourceMC._visible = false;
				sourceMC.removeMovieClip();
				break;
			default:
				break;
		}
		resetPrintParameters();
	}
// *** end of initialization ***

// *** set widths & heights in pixels (by user) ***
	private function setValue(valueName:String, valueInput:Number):Void {
		this[valueName] = valueInput;
		setContentHeight();
	}
	private function setContentHeight(Void):Void {
		contentHeight = MAX_HEIGHT*0.8-bottomMargin-footHeight-20;
	}
	function set setPaperWidth(n:Number):Void {setValue("MAX_WIDTH", n);}
	function set setPaperHeight(n:Number):Void {setValue("MAX_HEIGHT", n);}
	function set setLeftMargin(n:Number):Void {setValue("leftMargin", n);}
	function set setTopMargin(n:Number):Void {setValue("topMargin", n);}
	function set setBottomMargin(n:Number):Void {setValue("bottomMargin", n);}
	function set setHeaderHeight(n:Number):Void {setValue("headHeight", n);}
	function set setFooterHeight(n:Number):Void {setValue("footHeight", n);}
// *** end of setting widths & heights ***

// *** set content, header & footer by user ***
	function set setHeader(s:String):Void {headerStr = s;}
	function set setFooter(s:String):Void {footerStr = s;}

	function setContent(theSource):String {
		if (typeof theSource == "movieclip") {
			setContentByClip(theSource);
			return typeof theSource;
		} else if (theSource != undefined) {
			setContentByTextField(theSource);
			return typeof theSource;
		} else {
			return "no content set";
		}
	}

	private function setContentByClip(sourceMC:MovieClip):Void {
		depth = sourceMC.getDepth() + 1000;
		contentHeight += 20;
		// see if it's an exercise or a feedback
		var isExercise = false;
		if (sourceMC.Exercise_SP != undefined) {
			isExercise = true;
		}
		if (isExercise) {
			printType = 3;
			setLeftMargin = 0.175 * 75;
			setExerciseMC(sourceMC);
		} else {
			printType = 1;
			setLeftMargin = 0.175*75;
			var objBounds = sourceMC.Feedback_SP.getBounds(sourceMC);
			sourceMC.Feedback_SP._x -= objBounds.xMin;
			sourceMC.Feedback_SP._x += leftMargin;
			sourceMC.Feedback_SP._y -= objBounds.yMin;
			contentHeight = MAX_HEIGHT-bottomMargin-footHeight-20;
			setContentMC(sourceMC.Feedback_SP);
		}
		sourceMC.createTextField("header_txt", depth++, leftMargin, topMargin, MAX_WIDTH*0.8-leftMargin-leftMargin, headHeight);
		sourceMC.header_txt.html = true;
		sourceMC.header_txt.htmlText = "<P ALIGN=\"center\"><FONT FACE=\"Verdana\" SIZE=\"12\" COLOR=\"#000000\">" + headerStr + "</FONT></P>";
		sourceMC.createTextField("footer_txt", depth++, leftMargin, MAX_HEIGHT*0.8-bottomMargin-footHeight, MAX_WIDTH*0.8-leftMargin-leftMargin, footHeight);
		sourceMC.footer_txt.html = true;
		sourceMC.footer_txt.htmlText = "<P ALIGN=\"center\"><FONT FACE=\"Verdana\" SIZE=\"12\" COLOR=\"#000000\">" + footerStr + "</FONT></P>";
		sendPrintJob(sourceMC);
	}

	private function setContentByTextField(theText:TextField):Void {
		printType = 2;
		depth = this.getDepth();
		this.createEmptyMovieClip("topMC", depth++);
		this.createEmptyMovieClip("bottomMC", depth++);
		setContentLineByLine(theText);
		setHeaderAndFooter();
		sendPrintJob();
	}
// *** end of setting content, header & footer ***

// *** moving things in sourceMC ***
	private function setExerciseMC(sourceMC:MovieClip):Void {
		// now the TextField "ExDetails.exerciseCaption" is hided
		sourceMC.ExDetails._visible = false;
		// there are 4 MCs that need to show:
		// 1. Title_SP, 2. Example_SP, 3. NoScroll_SP
		// 4. Exercise_SP (remember to clear the mask)
		// move them to appropriate xPos
		for (var i in sourceMC) {
			if (typeof sourceMC[i] == "movieclip") {
				// v6.5.4.2 AR Why measure the bounds and then not use it?
				// For now I am leaving this debug info in
				var objBounds = sourceMC[i].getBounds(sourceMC);
				_global.myTrace(i + ".objBounds.yMax=" + objBounds.yMax);
				//sourceMC[i]._x -= objBounds.xMin;
				sourceMC[i]._x += leftMargin;
				sourceMC[i]._y += topMargin + headHeight;
			}
		}
		
		var tmpRef = sourceMC.Title_SP;
		for (var i in tmpRef) {
			//_global.myTrace("printing in " + tmpRef);
			if (typeof tmpRef[i]=="movieclip" && tmpRef[i].holder!=undefined) {
				// resize textfield size for larger font size during printing
				tmpRef[i].holder.autoSize = false;
				tmpRef[i].holder._height += 20;
			}
		}
		var tmpRef = sourceMC.Example_SP;
		for (var i in tmpRef) {
			//_global.myTrace("printing in " + tmpRef);
			if (typeof tmpRef[i]=="movieclip" && tmpRef[i].holder!=undefined) {
				// resize textfield size for larger font size during printing
				tmpRef[i].holder.autoSize = false;
				tmpRef[i].holder._height += 20;
			}
		}
		var tmpRef = sourceMC.NoScroll_SP;
		for (var i in tmpRef) {
			//_global.myTrace("printing in " + tmpRef);
			if (typeof tmpRef[i]=="movieclip" && tmpRef[i].holder!=undefined) {
				// resize textfield size for larger font size during printing
				tmpRef[i].holder.autoSize = false;
				tmpRef[i].holder._height += 20;
			}
		}
		// clear the mask of Exercise_SP
		//sourceMC.Exercise_SP.setMask(null);
		// push things in Exercise_SP into Array
		objectArray = new Array();
		for (var i in sourceMC.Exercise_SP) {
			var iRef = sourceMC.Exercise_SP[i];
			if (typeof iRef=="movieclip") {
				//iRef._x += leftMargin; iRef._y += topMargin + headHeight;
				// resize textfield size for larger font size during printing
				iRef.holder.autoSize = false;
				iRef.holder._height += 30;
				objectArray.push(iRef);
			}
		}
		objectArray.sort(compareFunction);
		var arrLength = objectArray.length;
		var objBounds = sourceMC.Exercise_SP[objectArray[arrLength-1]._name].getBounds(sourceMC);
		var maxHeight = objBounds.yMax;
		if (maxHeight!=undefined && maxHeight>0) {
			pageCount = Math.ceil(maxHeight/contentHeight);
		} else {
			pageCount = 1;
		}
		_global.myTrace("exercise objBounds.yMax=" + objBounds.yMax);
		//_global.myTrace("after exerciseSP, pageCount=" + pageCount);
		
		// v6.3.4
		RTobjectArray = new Array();
		for (var i in sourceMC.ReadingText_SP) {
			var iRef = sourceMC.ReadingText_SP[i];
			if (typeof iRef=="movieclip") {
				//iRef._x += leftMargin; iRef._y += topMargin + headHeight;
				// resize textfield size for larger font size during printing
				iRef.holder.autoSize = false;
				iRef.holder._height += 30;
				RTobjectArray.push(iRef);
			}
		}
		RTobjectArray.sort(compareFunction);
		var arrLength = RTobjectArray.length;
		var objBounds = sourceMC.ReadingText_SP[RTobjectArray[arrLength-1]._name].getBounds(sourceMC);
		var maxHeight = objBounds.yMax;
		if (maxHeight!=undefined && maxHeight>0) {
			if (Math.ceil(maxHeight/contentHeight)>pageCount) {
				pageCount = Math.ceil(maxHeight/contentHeight);
			}
		} else {
			if (1 > pageCount) {
				pageCount = 1;
			}
		}
		//_global.myTrace("after ReadingTextSP, pageCount=" + pageCount);
		// v6.4.2.4 To make adding extra pages a bit safer.
		extraPages=0;
	}

	private function setContentMC(sourceMC:MovieClip):Void {
		objectArray = new Array();
		//var c = 0;
		for (var i in sourceMC) {
			var iRef = sourceMC[i];
			if (typeof iRef=="movieclip") {
				var objB = iRef.getBounds(sourceMC);
				if (objB.xMin != undefined) {
					//iRef._x += leftMargin;
					iRef._y += topMargin + headHeight + 20;
					iRef.holder.autoSize = false;
					iRef.holder._height += 20;
					objectArray.push(iRef);
				}
			}
		}
		objectArray.sort(compareFunction);
		var arrLength = objectArray.length;
		var objBounds = sourceMC[objectArray[arrLength-1]._name].getBounds(sourceMC);
		var maxHeight = objBounds.yMax;
		if (maxHeight!=undefined && maxHeight>0) {
			pageCount = Math.ceil(maxHeight/contentHeight);
		} else {
			pageCount = 1;
		}
	}
	// used for sorting the y-coordinates of objects
	private function compareFunction(a, b):Number {
		var aBounds = a.getBounds(a._parent);
		var bBounds = b.getBounds(b._parent);
		if (a._y != b._y) {
			// if y-coordinates are not the same, sort as usual
			return (aBounds.yMax - bBounds.yMax);
		} else {
			// if y-coordinates are the same, reverse the sorting
			// so that they appear on the same page
			return (bBounds.yMax - aBounds.yMax);
		}
	}
// *** end of moving things in sourceMC ***

// *** copy text from textfield to this movieclip line by line ***
	private function setContentLineByLine(theText:TextField):Void {
		// makes theText be HTMLtext because it's much faster to copy formats from HTML
		if (!theText.html) { theText.html = true; }
		// create a TextField d_txt to hold the HTMLtext
		createTextField("d_txt", depth++, leftMargin, topMargin+headHeight+12, theText._width, contentHeight-topMargin-headHeight-12);
		var dRef = this["d_txt"];
		dRef.autoSize = false;
		dRef.wordWrap = true;
		dRef.multiline = true;
		dRef.html = true;
		dRef.htmlText = theText.htmlText;
		var linesOnPage = dRef.bottomScroll + 1;
		dRef.scroll = dRef.maxscroll;
		var totalLines = dRef.bottomScroll;
		pageCount = Math.ceil(totalLines/linesOnPage);
		var blankLines = (pageCount*linesOnPage) - totalLines;
		for (var i=0; i<=blankLines; i++) {
			dRef.htmlText += "<BR>";
		}
		dRef.scroll = 1;
	}
// *** end of copying text from textfield to this movieclip line by line ***

// *** set header & footer (SWF filename passed by user) ***
	private function addHeaderIntoMC(sourceMC:MovieClip, sourceSWF:String):Void {
		sourceMC.createEmptyMovieClip("header", depth++);
		sourceMC.header._x = leftMargin;
		sourceMC.header._y = topMargin;
		sourceMC.header.loadMovie(sourceSWF);
	}

	private function addFooterIntoMC(sourceMC:MovieClip, sourceSWF:String):Void {
		sourceMC.createEmptyMovieClip("footer", depth++);
		sourceMC.footer._x = leftMargin;
		sourceMC.footer._y = MAX_HEIGHT*0.8-bottomMargin-footHeight;
		sourceMC.footer.loadMovie(sourceSWF);
		//_global.printingInterval = setInterval(waitingForMC, 200, this, sourceMC);
	}

	private function waitingForMC(t, s:MovieClip):Void {
		if ((s.footer.getBytesLoaded() > 0) && (s.footer.getBytesTotal() == s.footer.getBytesLoaded())) {
			clearInterval(_global.printingInterval);
			t.sendPrintJob(s);
		}
	}

	private function setHeaderAndFooter() {
		topMC._x = leftMargin;
		topMC._y = topMargin;
		bottomMC._x = leftMargin;
		bottomMC._y = MAX_HEIGHT*0.8-bottomMargin-footHeight;
		topMC.createTextField("header_txt", depth++, 0, 0, MAX_WIDTH*0.8-leftMargin-leftMargin, headHeight);
		topMC.header_txt.html = true;
		topMC.header_txt.htmlText = "<P ALIGN=\"center\"><FONT FACE=\"Verdana\" SIZE=\"12\" COLOR=\"#000000\">" + headerStr + "</FONT></P>";
		bottomMC.createTextField("footer_txt", depth++, 0, 0, MAX_WIDTH*0.8-leftMargin-leftMargin, footHeight);
		bottomMC.footer_txt.html = true;
		bottomMC.footer_txt.htmlText = "<P ALIGN=\"center\"><FONT FACE=\"Verdana\" SIZE=\"12\" COLOR=\"#000000\">" + footerStr + "</FONT></P>";
		//topMC.loadMovie(headerURL); 
		//bottomMC.loadMovie(footerURL);
		//_global.printingInterval = setInterval(waitingForTF, 200, this);
	}
	private function waitingForTF(t):Void {
		var bot = t.bottomMC;
		if ((bot.getBytesLoaded() > 0) && (bot.getBytesTotal() == bot.getBytesLoaded())) {
			clearInterval(_global.printingInterval);
			t.sendPrintJob();
		}
	}
// *** end of setting header & footer ***

// *** set content movie clip page by page (cannot be used outside the class) ***
	private function refreshContent(sourceMC:MovieClip):Void {
		for (var i=0; i<=printedNo; i++) {
			// set all printed objects to be invisible
			sourceMC[objectArray[i]._name]._visible = false;
		}
		var arrLength = objectArray.length;
		var startNo = printedNo + 1;
		for (var i=startNo; i<arrLength; i++) {
			// put all the unprinted objects into the page
			putObjectIntoPage(sourceMC, i, objectArray[i]._name);
		}
		
		// v6.3.4
		for (var i=0; i<=RTprintedNo; i++) {
			sourceMC[RTobjectArray[i]._name]._visible = false;
		}
		var arrLength = RTobjectArray.length;
		var startNo = RTprintedNo + 1;
		for (var i=startNo; i<arrLength; i++) {
			putRTObjectIntoPage(sourceMC, i, RTobjectArray[i]._name);
		}
		
		/*sourceMC.header._x = leftMargin;
		sourceMC.header._y = topMargin;
		sourceMC.footer._x = leftMargin;
		sourceMC.footer._y = MAX_HEIGHT*0.8-bottomMargin-footHeight;
		sourceMC.header._visible = true;
		sourceMC.footer._visible = true;*/
	}
	private function putObjectIntoPage(sourceMC:MovieClip, objNo:Number, objName:String):Void {
		var objBounds = sourceMC[objName].getBounds(sourceMC);
		// if the object should be shown on this page
		if ((printedNo==(objNo - 1)) && (objBounds.yMax<=contentHeight)) {
			// set the object to be visible
			sourceMC[objName]._visible = true;
			printedNo = objNo;
		} else {
			// the object should not be shown on this page, so set the object to be invisible
			sourceMC[objName]._visible = false;
			// if it's the 1st object in next page, get the object's yMin for setting yOffset
			if (objNo == (printedNo+1)) {
				var lastBounds = sourceMC[objName].getBounds(sourceMC);
				yOffset = lastBounds.yMin - topMargin - headHeight - 20;
			}
			// move the object up by yOffset
			sourceMC[objName]._y -= yOffset;
		}
	}

	// v6.3.4
	private function putRTObjectIntoPage(sourceMC:MovieClip, objNo:Number, objName:String):Void {
		var objBounds = sourceMC[objName].getBounds(sourceMC);
		// if the object should be shown on this page
		if ((RTprintedNo==(objNo - 1)) && (objBounds.yMax<=contentHeight)) {
			// set the object to be visible
			sourceMC[objName]._visible = true;
			RTprintedNo = objNo;
		} else {
			// the object should not be shown on this page, so set the object to be invisible
			sourceMC[objName]._visible = false;
			// if it's the 1st object in next page, get the object's yMin for setting yOffset
			if (objNo == (RTprintedNo+1)) {
				var lastBounds = sourceMC[objName].getBounds(sourceMC);
				RTyOffset = lastBounds.yMin - topMargin - headHeight - 20;
			}
			// move the object up by yOffset
			sourceMC[objName]._y -= RTyOffset;
		}
	}

	
	private function refreshExercise(sourceMC:MovieClip, pageNo:Number):Void {
		if (pageNo != 1) {
			_global.myTrace("pageNo=" + pageNo + " so hide title etc");
			sourceMC.Title_SP._visible = false;
			sourceMC.Example_SP._visible = false;
			sourceMC.NoScroll_SP._visible = false;
		}
		
		for (var i=0; i<=printedNo; i++) {
			// set all printed objects to be invisible
			sourceMC.Exercise_SP[objectArray[i]._name]._visible = false;
		}
		var arrLength = objectArray.length;
		var startNo = printedNo + 1;
		for (var i=startNo; i<arrLength; i++) {
			// put all the unprinted objects into the page
			putExerciseIntoPage(sourceMC, i, objectArray[i]._name);
		}
		/*sourceMC.header._x = leftMargin;
		sourceMC.header._y = topMargin;
		sourceMC.footer._x = leftMargin;
		sourceMC.footer._y = MAX_HEIGHT*0.8-bottomMargin-footHeight;
		sourceMC.header._visible = true;
		sourceMC.footer._visible = true;*/
		
		// v6.3.4
		for (var i=0; i<=RTprintedNo; i++) {
			// set all printed objects to be invisible
			sourceMC.ReadingText_SP[RTobjectArray[i]._name]._visible = false;
		}
		var arrLength = RTobjectArray.length;
		var startNo = RTprintedNo + 1;
		for (var i=startNo; i<arrLength; i++) {
			// put all the unprinted objects into the page
			putReadingTextIntoPage(sourceMC, i, RTobjectArray[i]._name);
		}
		// v6.4.2.4 Can i tell if there are still some un printed items left so that I can add an extra page?
		// This is quite a dangerous thing as an  infinite loop could develop. Can you, clumsily, limit the extra pages to x?
		// And what happens if your exercise is longer than your Reading Text?
		//_global.myTrace("end of page " + pageNo + " RTprintedNo=" + RTprintedNo + " arrLength=" + arrLength);
		if (pageCount == pageNo && RTprintedNo < arrLength-1 && extraPages<5) {
			_global.myTrace("missing some paras, so add an extra page");
			pageCount++;
			extraPages++;
		}
	}
	private function putExerciseIntoPage(sourceMC:MovieClip, objNo:Number, objName:String):Void {
		var objBounds = sourceMC.Exercise_SP[objName].getBounds(sourceMC);
		// if the object should be shown on this page
		if ((printedNo==(objNo - 1)) && (objBounds.yMax<=contentHeight)) {
			// set the object to be visible
			sourceMC.Exercise_SP[objName]._visible = true;
			printedNo = objNo;
		} else {
			// the object should not be shown on this page, so set the object to be invisible
			sourceMC.Exercise_SP[objName]._visible = false;
			// if it's the 1st object in next page, get the object's yMin for setting yOffset
			if (objNo == (printedNo+1)) {
				var lastBounds = sourceMC.Exercise_SP[objName].getBounds(sourceMC);
				yOffset = lastBounds.yMin+topMargin+headHeight;
			}
			// move the object up by yOffset
			sourceMC.Exercise_SP[objName]._y -= yOffset;
		}
	}
	
	
	// v6.3.4
	private function putReadingTextIntoPage(sourceMC:MovieClip, objNo:Number, objName:String):Void {
		var objBounds = sourceMC.ReadingText_SP[objName].getBounds(sourceMC);
		// if the object should be shown on this page
		//_global.myTrace("RTtopage: objNo=" + objNo + " RTprintedNo=" + RTprintedNo + " yMin=" + objBounds.yMin + " yMax=" + objBounds.yMax);
		if ((RTprintedNo==(objNo - 1)) && (objBounds.yMax<=contentHeight)) {
			// set the object to be visible
			sourceMC.ReadingText_SP[objName]._visible = true;
			RTprintedNo = objNo;
		} else {
			// the object should not be shown on this page, so set the object to be invisible
			sourceMC.ReadingText_SP[objName]._visible = false;
			// if it's the 1st object in next page, get the object's yMin for setting yOffset
			if (objNo == (RTprintedNo+1)) {
				var lastBounds = sourceMC.ReadingText_SP[objName].getBounds(sourceMC);
				RTyOffset = lastBounds.yMin+topMargin+headHeight;
			}
			// move the object up by yOffset
			sourceMC.ReadingText_SP[objName]._y -= RTyOffset;
		}
	}
	
	
// *** end of setting sourceMC page by page ***

// *** refresh content (for textfield) ***
	private function scrollContent(pageNo:Number):Void {
		var dRef = this["d_txt"];
		var lastLine = dRef.bottomScroll;
		if (pageNo > 1) {
			dRef.scroll = lastLine + 1;
		}
	}
// *** end of refreshing content line by line ***

// *** send print job ***
	function sendPrintJob(sourceMC):Void {
		if (printType != 0) {
			// v6.5.2 AR printing problem on IE7 with Vista. Throws a few blank pages.
			// Adobe docs suggest doing nothing between .start and .send (apart from .addPage)
			// so move this lot of code outside. It didn't help and stopped title/noscroll printing!
			var myResult="";
			var my_pj = new PrintJob();
			my_pj.orientation = "Portrait";
			my_pj.paperHeight = MAX_HEIGHT;
			my_pj.paperWidth = MAX_WIDTH;
			var myResult = my_pj.start();
			if (myResult) {
				for (var i=1; i<=pageCount; i++) {
					_global.myTrace("print page " + i + " of " + pageCount + " paperHeight=" + my_pj.paperHeight);
					// refresh the content & add page
					switch (printType) {
						case 1:	// movieclip (feedback)
							refreshContent(sourceMC.Feedback_SP);
							myResult = my_pj.addPage(sourceMC, {xMin:0, xMax:MAX_WIDTH, yMin:0, yMax:MAX_HEIGHT});
							break;
						case 2:	// textfield
							scrollContent(i);
							myResult = my_pj.addPage(this, {xMin:0, xMax:MAX_WIDTH, yMin:0, yMax:MAX_HEIGHT});
							break;
						case 3:	// movieclip (exercise)
							refreshExercise(sourceMC, i);
							myResult = my_pj.addPage(sourceMC, {xMin:0, xMax:MAX_WIDTH, yMin:0, yMax:MAX_HEIGHT});
						default:
							break;
					}
					_global.myTrace("to spooler success=" + myResult);
				}
				if (pageCount>=1) {
					my_pj.send();
					//_global.myTrace("to printer success=" + myResult);
				}
			}
			delete my_pj;
		}
		clearContent(sourceMC);
	}
// ** end of sending print job ***
}

