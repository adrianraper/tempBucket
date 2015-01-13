// convert a string into a number, if possible
function CNumber(me) {
	var testing = String(me);
	for (i=testing.length;i>0;i--) {
		if (Number(testing.substr(0,i)) != NaN) {
			return testing.substr(0,i);
		};
	};
};

// for formatting numbers into date/time strings
function make2digitString(num, extraDigits) {
	// just make it effective now, not pretty
	if (extraDigits >= 4) {
		if (num < 10) {
			return "000" + String(Math.round(num));
		} else if (num < 100) {
			return "00" + String(Math.round(num));
		} else if (num < 1000) {
			return "0" + String(Math.round(num));
		} else {
			return String(Math.round(num));
		}
	}
	if (num < 10) {
		return "0" + String(Math.round(num));
	} else {
		return String(Math.round(num));
	}
}

// Add a find and replace method to all strings (or this overkill?)
//String.prototype.findReplace = function(find, replace, occurence) {
// Guess so, so just have a nice function
function findReplace(myString, find, replace, occurence) {
//	trace("looking for " + find);
	if (!occurence) {
		return myString.split(find).join(replace);
	} else {
		n = myString.split(find);
		for (j in n) {
			if (j == occurence-1) {
				n[j] += replace;
			} else if (j!=n) {
				n[j] += find;
			}
		}
		return n.join("");
	}
};
// insert text into a string, perhaps replacing a number of characters
// usage
//insertReplaceAt("Hello Adrian Raper", "Dr. ", 6, 7); returns "Hello Dr. Raper"
//insertReplaceAt("Hello Adrian Raper", "Dr. ", 6); returns "Hello Dr. Adrian Raper"
function insertReplaceAt(text, insert, at, remove) {
	var s = new String();
	return s.concat(text.substr(0,at),insert,text.substr(at+remove));
};

// return the (first) index of an array that contains an item in field
// usage: lookupArrayItem(myArray, "10", "id"); 
// returns the array index that contains id=10;
/* find a more efficent loop - see below
function lookupArrayItem(myArray, key, field) {
	for (var i=0; i<myArray.length; i++) {
		//trace("looking for "+key+" in "+myArray[i].id);
		if (myArray[i][field] eq key) {
			return i;
		}
	}
	return -1; // it wasn't found, but -1 = true so is this a good thing to return?
}
*/
// Note: this is duplicated in the twf component at the moment so that the component
// is portable and doesn't need to refer to _global.ORCHID.root.objectHolder.lookupArrayItem
function lookupArrayItem(myArray, key, field) {
	var i = myArray.length;
	while(i--) {
		if (myArray[i][field] == key) {
			return i;
		}
	}
	return -1; // it wasn't found
}

// an array shuffle (from Tatsuo Kato)
function shuffle(a) {
    var i = a.length;
    while (i) {
        var p = Math.floor(Math.random() * i);
        var t = a[--i];
        a[i] = a[p];
        a[p] = t;
    }
}

// a common function to return an array of unique random integers
// probably very inefficent!
function getRandomNumbers(min, max, num) {
	// first make an array of all numbers
	allNums = new Array();
	for (var i=min;i<=max;i++) {
		allNums.push(i);
	}
	// now cut out items from this array until you have enough
	selectedNums = new Array();
	for (var i=0;i<num;i++) {
		cutIdx = Math.round((allNums.length-1)*Math.random());
		//trace("cut at " + cutIdx);		
		selectedNums.push(allNums[cutIdx]);
		allNums.splice(cutIdx,1);
	}
	//trace("random returns " + selectedNums);
	return selectedNums;
}
// v6.3.4 A common function for comparing object IDs (used in array sort)
function groupOrdering(ele1, ele2) {
	var ele1ID = Number(ele1.id);
	var ele2ID = Number(ele2.id);
	if (ele1ID < ele2ID) {
		//myTrace(ele1.id + " < " + ele2.id);
		return -1;
	} else if (ele1ID > ele2ID) {
		//myTrace(ele1.id + " > " + ele2.id);
		return 1;
	} else {
		return 0;
	}
}

//v6.4.3 A function to do a specialised sort on an array of objects
// It currently ONLY works for coordinates.y
sortArrayOfObjects = function(myArray, sortField, sortType) {
	var buildArray = new Array();
	var eleAdded;
	for (var i in myArray) {
		eleAdded = false;
		for (var j=0; j<buildArray.length; j++){
			switch (sortField) {
			// There must be a better way to do this with eval or some such
			case "coordinates.y":
				var testField = myArray[i].coordinates.y;
				var refField = buildArray[j].coordinates.y;
				break;
			case "anchorPara":
				var testField = myArray[i].anchorPara;
				var refField = buildArray[j].anchorPara;
				break;
			}
			if (isNaN(testField)) testField = 0;
			if (testField <= refField) {
				//trace("add " + myArray[i].id + "<=" + buildArray[j].id + "?");
				buildArray.splice(j,0,myArray[i]);
				eleAdded = true;
				break;
			}
		}
		if (!eleAdded) {
			buildArray.push(myArray[i]);	
		}
	}
	return buildArray;
}
// a function to return a string made up of n characters or blocks of character
function makeString(textBlock, num) {
	var myBuild = "";
	for (var i=0; i<num; i++) {
		myBuild += textBlock;
	}
	return myBuild;
	// from Bokel
	//return new Array(++num).join(textBlock);
}
String.prototype.repeat = function(count){
	return new Array(++count).join(this);
}
// a function to trim a string of leading and/or trailling spaces
String.prototype.trim = function(sides) {
	var build = this;
	if (sides == "left" || sides == "both") {
		for (var i=0; i<build.length; i++) {
			if (build.charAt(i) != " ") {
				build = build.substring(i);
				break;
			}
		}
	}
	if (sides == "right" || sides == "both") {
		var endChar = build.length;
		while (endChar--) {
			if (build.charAt(endChar) != " ") {
				build = build.substring(0,endChar+1);
				break;
			}
		}
	}
	if (sides == "middle") {
		var doubleChar = build.indexOf("  ");
		while (doubleChar >=0 ) {
			build = findReplace(build, "  ", " ")
			var doubleChar = build.indexOf("  ");
		}
	}
	return build;
}
convertCurlyQuote = function(myString) {
	var build = myString;
	// list all types of odd quotes and apostrophes and the straight version they should be converted to.
	// Alt+0145, 146, 180, 96, 147, 148 turned into unicode mappings are...
	var replaceArray = [{f:8216, r:39}, {f:8217, r:39}, {f:180, r:39}, {f:96, r:39}, {f:8220, r:34}, {f:8221, r:34}];
	for (var i in replaceArray) {
		build = findReplace(build, String.fromCharCode(replaceArray[i].f), String.fromCharCode(replaceArray[i].r));
	}
	return build;
}
// v6.5.4.7 Make strings safe for passing to PHP
// This is pointless as these characters get passed exactly the same.
// v6.5.5.5 Not pointless at all - very essential
safeQuotes = function(text){
	// Hello - 27 (dec) is escape. 27 (hex) is apostrophe. I think you mean String.fromCharCode(39)!
	// But don't change this until you can test it!
	var part1 = findReplace(text, String.fromCharCode(27), "&apos;");
	//var part1 = findReplace(text, String.fromCharCode(39), "&apos;");
	var part2 = findReplace(part1, String.fromCharCode(43), "&#043;");
	var part3 = findReplace(part2, String.fromCharCode(60), "&lt;");
	var part4 = findReplace(part3, String.fromCharCode(62), "&gt;");
	return findReplace(part4, String.fromCharCode(34), "&quot;");
}

// a date formatting function - actually it is in 
//function formatDate(theDate) {
//	var months=["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//	var days=["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//	var minutes = theDate.getMinutes();
//	if (minutes <10) minutes = "0" + minutes; 
//	var dateString = theDate.getHours() + ":" + minutes + " " + days[theDate.getDay()] + " " + theDate.getDate() + " " + months[theDate.getMonth()] + " " + theDate.getFullYear();
//	return dateString;
//}
// v6.5.4.7 New functions for hiddenContent - but I might need this before course is created. Put in common then
//Course.prototype.buildUID = function(pID, cID, uID, eID) {
buildUID = function(pID, cID, uID, eID) {
	var idArray = new Array();
	if (pID) idArray.push(pID);
	if (cID) idArray.push(cID);
	if (uID) idArray.push(uID);
	if (eID) idArray.push(eID);
	return idArray.join("."); 
}
getEnabledFlagForUID = function(UID, hiddenContentArray) {
	//myTrace("matching " + UID);
	if (hiddenContentArray[UID]!=undefined) {
		//myTrace("matched")
		return hiddenContentArray[UID];
	} else {
		var breakUID = UID.split(".");
		if (breakUID.length>1) {
			breakUID.pop();
			return getEnabledFlagForUID(breakUID.join("."), hiddenContentArray);
		} else {
			return 0;
		}
	}
}
getEnabledFlagUnderUID = function(UID, hiddenContentArray) {
	// We have confirmed that at the course or product level we have switched off this course
	// We now want to see if there is anything under it that will specifically switch it back on.
	// The default is to leave it off if you find nothing
	var underUID = UID + "."; // to make sure we match stuff under the course, not the course itself
	for (var i in hiddenContentArray) {
		trace("matching under " + i);
		if (i.indexOf(underUID)==0) {
			trace("matched " + hiddenContentArray[i]);
			if (hiddenContentArray[i] & _global.ORCHID.enabledFlag.disabled) {
			} else {
				return 0;
			}
		}
	}
	return _global.ORCHID.enabledFlag.disabled;
}
getEditedContentPathForUID = function(UID, editedContentArray) {
	var reItem = null;
	for(var i in editedContentArray){
		if(UID == editedContentArray[i]._id){
			reItem = editedContentArray[i];
			break;
		}
	}
	return reItem;	
}
function formatDateForProgress(dateString) {
// dateString is always YYYY-MM-DD HH:MM:SS
// target for this function is
//	12:34 - 17 Jul 2003
	var myDT = dateString.trim("both").split(" ");
	var myD = myDT[0].split("-");
	var myT = myDT[1].split(":");
	
	// remember that months in Flash are 0 based
	var theDate = new Date(myD[0], myD[1]-1, myD[2], myT[0], myT[1], myT[2]);
	// since you might be calling this in a big loop - save it once
	if (_global.ORCHID.literalModelObj.months == undefined) {
		_global.ORCHID.literalModelObj.months = _global.ORCHID.literalModelObj.getLiteral("months", "messages").split(", ");
	}
	//var months=["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"];
	// Don't use days anymore - saves space and doesn't lose any info
	//var days=["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var minutes = theDate.getMinutes();
	if (theDate.getMinutes() < 10) { minutes = "0" + minutes; }
//	return theDate.getHours() + ":" + minutes + " - " + days[theDate.getDay()] + " " + theDate.getDate() + " " + months[theDate.getMonth()] + " " + theDate.getFullYear();
	return theDate.getHours() + ":" + minutes + " - " + theDate.getDate() + " " + _global.ORCHID.literalModelObj.months[theDate.getMonth()] + " " + theDate.getFullYear();
}
//v6.4.2 Moved from OrchidObjects into common.as
// formatting function to turn actionscript dates into Orchid datestrings
// YYYY-MM-DD HH:MM:SS - assume hours are 1-24 and that numbers are zero padded
dateFormat = function(thisDate) {
	//var dateString = "2007" + "-" + zeroPad(thisDate.getMonth()+1) + "-" + zeroPad(thisDate.getDate()) + " " + zeroPad(thisDate.getHours()) + ":" + zeroPad(thisDate.getMinutes()) + ":" + zeroPad(thisDate.getSeconds());
	var dateString = thisDate.getFullYear() + "-" + zeroPad(thisDate.getMonth()+1) + "-" + zeroPad(thisDate.getDate()) + " " + zeroPad(thisDate.getHours()) + ":" + zeroPad(thisDate.getMinutes()) + ":" + zeroPad(thisDate.getSeconds());
	return dateString;
}
dateFromString = function(dateString) { 
	// v6.5.4.6 Lazily I will assume that all our date strings are YYYY-MM-DD HH:MM:SS
	// But some are just dates!
	var myDT = dateString.trim("both").split(" ");
	var myD = myDT[0].split("-");
	// remember that months in Flash are 0 based
	var theDate = new Date(myD[0], myD[1]-1, myD[2], 0,0,0);
	if (dateFormat(theDate) == (dateString + " 00:00:00")) {
		return theDate;
	} else {
		return undefined; // or null?
	}
}
isValidDate = function(dateString) {
	if (dateFromString(dateString) == undefined) {
		return false;
	}
	return true;
}
zeroPad = function(num) {
	if (num < 10) {
		return "0" + num;
	} else {
		return num;
	}
}

//v6.3.6 Use version numbers more extensively
versionNumber = function(verString) {
	// v6.4.1 and allow the Flash version to be made easily
	//myTrace("make ver out of " + (typeof verString) + "=" + verString.toString());
	if ((typeof verString) == "object") {
		this.platform = verString.platform;
		this.major = verString.major;
		this.minor = verString.minor;
		this.build = verString.build;
		this.patch = verString.patch;
	} else {
		this.init(verString)
	}
	return this;
}
versionNumber.prototype.init = function(verString) {
	if (verString == undefined) verString = "0.0.0.0";
	var myVersion = verString.split(".");
	for (var i=0; i<4;i++) {
		if (isNaN(parseInt(myVersion[i]))) myVersion[i]=0;
	}
	this.major = parseInt(myVersion[0]);
	this.minor = parseInt(myVersion[1]);
	this.build = parseInt(myVersion[2]);
	this.patch = parseInt(myVersion[3]);
}
versionNumber.prototype.toString = function() {
	return this.major + "." + this.minor + "." + this.build + "." + this.patch;
}
versionNumber.prototype.atLeast = function(benchmark) {
	var benchmarkObj = new versionNumber(benchmark);
	if (this.major < benchmarkObj.major) return false;
	if (this.major > benchmarkObj.major) return true;
	if (this.minor < benchmarkObj.minor) return false;
	if (this.minor > benchmarkObj.minor) return true;
	if (this.build < benchmarkObj.build) return false;
	if (this.build > benchmarkObj.build) return true;
	if (this.patch < benchmarkObj.patch) return false;
	return true;
}
// a function just to make the code read cleanly
versionNumber.prototype.lessThan = function(benchmark) {
	return !this.atLeast(benchmark);
}

// Thanks to Robert Penner for the easing equations and method
// quadratic easing in - accelerating from zero velocity?
_global.ORCHID.easeInQuad = function (t, b, c, d) {
	return c*(t/=d)*t + b;
};
// quadratic easing out - decelerating to zero velocity
_global.ORCHID.easeOutQuad = function (t, b, c, d) {
	return -c *(t/=d)*(t-2) + b;
};
_global.ORCHID.easeInOutQuad = function (t, b, c, d) {
	if ((t/=d/2) < 1) return c/2*t*t + b;
	return -c/2 * ((--t)*(t-2) - 1) + b;
};
// back easing in - backtracking slightly, then reversing direction and moving to target
// t: current time, b: beginning value, c: change in value, d: duration, s: overshoot amount (optional)
// t and d can be in frames or seconds/milliseconds
// s controls the amount of overshoot: higher s means greater overshoot
// s has a default value of 1.70158, which produces an overshoot of 10 percent
// s==0 produces cubic easing with no overshoot
_global.ORCHID.easeInBack = function (t, b, c, d, s) {
	if (s == undefined) s = 1.70158;
	return c*(t/=d)*t*((s+1)*t - s) + b;
};
// back easing out - moving towards target, overshooting it slightly, then reversing and coming back to target
_global.ORCHID.easeOutBack = function (t, b, c, d, s) {
	if (s == undefined) s = 1.70158;
	return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
};
// exponential easing in/out - accelerating until halfway, then decelerating
_global.ORCHID.easeInOutExpo = function (t, b, c, d) {
	if (t==0) return b;
	if (t==d) return b+c;
	if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;
	return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
};


// Taken from the TWF component - after all why do it so many times?

// If you want to set a default text format to a textField before adding html text, it has to be 
// done this way as setNewTextFormat does not influence a .htmlText = statement.
// Also, if you do txt.htmlText = textString; txt.setTextFormat(thisTF); you will overwrite
// any conflicting text formatting that the textString contained.
// Pass the html/plain string to be added and the TextFormat object that describes the default style
TextField.prototype.setHtmlText = function(myText, myTF) {
//myTrace("[common.as]entering setHtmlText");
	// add a head and tail around the text that sets the style that we want to use
	//myTrace("common.sHT with " + myText);
	// v6.3.6 If an italic 'p' is the first character in a line, the tail disappears. You can solve this
	// by setting a left margin of 1. Try doing it here to see if it ruins anything else?
	// v6.4.2.7 This is causing a left shift of multiple choice options when you click one (as other TF has leftMargin=0)
	//if (myTF.leftMargin == undefined || myTF.leftMargin <= 0) {myTF.leftMargin = 1}
	this.htmlText = "<TEXTFORMAT " + 

					(myTF.leading != undefined ? "LEADING=\"" + myTF.leading + "\" " : "") + 
					(myTF.leftMargin != undefined ? "LEFTMARGIN=\"" + myTF.leftMargin + "\" " : "") + 
					(myTF.rightMargin != undefined ? "RIGHTMARGIN=\"" + myTF.rightMargin + "\" " : "") + 
					(myTF.indent != undefined ? "INDENT=\"" + myTF.indent + "\" " : "") + 
					(myTF.blockIndent!= undefined ? "BLOCKINDENT=\"" + myTF.blockIndent + "\"" : "") + 
					(myTF.tabStops != undefined ? "TABSTOPS=\"" + myTF.tabStops + "\" " : "") + 
					"><P " +
					(myTF.align != undefined ? "ALIGN=\"" + myTF.align + "\"" : "") + 
					"><FONT "+
					(myTF.font != undefined ? "face=\"" + myTF.font + "\" " : "") + 
					(myTF.size != undefined ? "size=\"" + myTF.size + "\" " : "") + 
					(myTF.color != undefined ? "color=\"#" + myTF.color.toString(16) + "\" " : "") + 
					">" +
					(myTF.bullet ? "<li>" : "") + 
					(myTF.bold ? "<b>" : "") + 
					(myTF.italic ? "<i>" : "") + 
					(myTF.underline ? "<u>" : "") + 
					myText + 
					(myTF.underline ? "</u>" : "") + 
					(myTF.italic ? "</i>" : "") + 
					(myTF.bold ? "</b>" : "") + 
					(myTF.bullet ? "</li>" : "") + 
					"</FONT></P></TEXTFORMAT>";
					

//					if (myTF.tabStops.length>0) trace("tabstops at " + myTF.tabStops.toString());
}

// This method will copy part of a formatted textField to another textField
// preserving all formatting. It does it by copying character by character and
// setting the textFormat for each one.
TextField.prototype.copyFormattedText = function(target_txt, start, end) {
	//trace("in cFT with " + target_txt);
	// if start and end are not specified, take the whole string
	// if the target is not a textField, give up!
	//ray disable instanceof
	//if (target_txt instanceof TextField) {

		// v6.2 Added a clearing stmt so you don't get unintentional appending of text
		target_txt.text = ""; 
		var thisTF = new TextFormat();
		var thisChar = "";
		var tabCount=0;
		var myString = new String(this.text);
		//trace("copy " + myString.substring(start, end));
		if (end == undefined) {
			end = this.length;
		}
		if (start < 0) start = 0;
		for (var i=start;i<end; i++) {
			// what is the next character to add and what is it's format?
			thisTF = this.getTextFormat(i);
			thisChar = myString.charAt(i);
			// slightly OT I am going to count how many tabs are included 
			// in this bit of text I am measuring - seems useful!
			if (thisChar == String.fromCharCode(9)) {
				tabCount++;
			}
			// we want to find out about the character we are about to add
			target_txt.setNewTextFormat(thisTF);
			// add the character to the holding textField (a time consuming process)
			// but this is the only way to do it without losing earlier formatting
			//Selection.setSelection(i);
			target_txt.replaceSel(thisChar);
		
		}
		return tabCount; // return number of tabs copied
	//}
	//disable instanceof
}
// this method returns the width and height of a portion of the textField
// (plus a count of any tab characters that were included in the portion)
TextField.prototype.getTextDimensions = function(calculator, start, end) {
	//trace("width of " + this + " between " + start + " and " + end);
	// if the calculator is not a textField, give up!
	//ray disable instanceof
	//if (calculator instanceof TextField) {
		calculator.text = "";
		var myTabCount = this.copyFormattedText(calculator, start, end);
		// v6.2 It would be nice to know if the height included line spacing as well as the
		// actual space taken by the letters.
		var myWidth = calculator.textWidth;
		var myHeight = calculator.textHeight;
		// So having measured the actual text height, force the text field to zero leading
		// and check it again. The difference (if any) is due to line spacing only.
		var singleLine = new TextFormat();
		singleLine.leading = 0;
		calculator.setTextFormat(singleLine);
		var myLineSpacing = myHeight - calculator.textHeight;
		return {width:myWidth, height:myHeight, tabCount:myTabCount, lineSpacing:myLineSpacing};
	//}
}
/* Not sure that this is needed. It is used in control, but it seems that this might
// have been loaded by then as it doesn't seem to get called
// v6.3 A function for turning a Clarity standard date into a Flash date object
formatDateForFlash = function (dateString) {
// assume YYYY-MM-DD HH:MM:SS
	var mainParts = dateString.trim("both").split(" ");
	var datePart = mainParts[0].split("-");
	var timePart = mainParts[1].split(":");
	var thisDate = new Date(datePart[0], datePart[1]-1, datePart[2], timePart[0], timePart[1], timePart[2]);
	//myTrace("the date I made was " + thisDate.toString();
	return thisDate;
}
*/
