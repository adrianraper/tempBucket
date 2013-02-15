// ActionScript Document
_global.ORCHID.BasicText = new TextFormat();
with (_global.ORCHID.BasicText) {
	font = "Verdana";
	size = 10;
	indent = 0;
	leading = 0;
	align = "left";
	color = 0x000066;
}
_global.ORCHID.ruler = new TextFormat();
_global.ORCHID.ruler.font = "Verdana";
_global.ORCHID.ruler.size = 10;

_global.ORCHID.setBrandStyles = function(branding) {
	myTrace("now setting styles for " + branding);

	// v6.4.2.4 Set a default first, then overwrite with title specific changes
	_global.ORCHID.HighlightedText = new TextFormat();
	//_global.ORCHID.HighlightedText.color = 0xff0000;
	_global.ORCHID.HighlightedText.underline = true;
	//_global.ORCHID.HighlightedText.bold = true;
	
	// hold the colours as a new rawColor property so that you can add them to html
	// (which needs them in the "#ff0099" format rather than "0xff0099"
	_global.ORCHID.YouWereCorrectText = new TextFormat();
	_global.ORCHID.YouWereCorrectText.rawColor = "339933"; // green
	_global.ORCHID.YouWereCorrectText.underline = true;
	_global.ORCHID.YouWereCorrectText.color = "0x" + _global.ORCHID.YouWereCorrectText.rawColor; 
	
	_global.ORCHID.YouWereWrongText = new TextFormat();
	_global.ORCHID.YouWereWrongText.rawColor = "ff0000"; // red
	_global.ORCHID.YouWereWrongText.underline = true;
	_global.ORCHID.YouWereWrongText.color = "0x" + _global.ORCHID.YouWereWrongText.rawColor; 
	
	// 6.4.2.4 Do nothing is better
	_global.ORCHID.YouAvoidedCorrectly = new TextFormat(); 
	//_global.ORCHID.YouAvoidedCorrectly.rawColor = "ff0000"; // red
	//_global.ORCHID.YouAvoidedCorrectly.underline = false;
	//_global.ORCHID.YouAvoidedCorrectly.color = "0x" + _global.ORCHID.YouAvoidedCorrectly.rawColor; 
	
	// v6.3 new format for proof reading - mistakes that they found
	_global.ORCHID.PRYouWereCorrectText = new TextFormat();
	_global.ORCHID.PRYouWereCorrectText.rawColor = "ff0000"; // red
	//_global.ORCHID.PRYouWereCorrectText.underline = true;
	_global.ORCHID.PRYouWereCorrectText.color = "0x" + _global.ORCHID.PRYouWereCorrectText.rawColor; 
	
	// v6.3 new format for proof reading - things that were not mistakes that they got - not used at present
	_global.ORCHID.PRYouWereWrongText = new TextFormat();
	_global.ORCHID.PRYouWereWrongText.rawColor = "339933"; // green
	_global.ORCHID.PRYouWereWrongText.underline = true;
	_global.ORCHID.PRYouWereWrongText.color = "0x" + _global.ORCHID.PRYouWereWrongText.rawColor; 
	
	// v6.3 new format for proof reading - mistakes that they missed
	_global.ORCHID.PRCorrectText = new TextFormat();
	_global.ORCHID.PRCorrectText.rawColor = "ff0000"; // red
	//_global.ORCHID.PRCorrectText.underline = true;
	_global.ORCHID.PRCorrectText.color = "0x" + _global.ORCHID.PRCorrectText.rawColor; 
	
	_global.ORCHID.CorrectText = new TextFormat();
	// v6.4.2.7 new marking scheme doesn't differentiate between you were correct and correct
	//_global.ORCHID.CorrectText.rawColor = "000099"; // blue
	_global.ORCHID.CorrectText.rawColor = _global.ORCHID.YouWereCorrectText.rawColor;
	_global.ORCHID.CorrectText.underline = true;
	_global.ORCHID.CorrectText.color = "0x" + _global.ORCHID.CorrectText.rawColor; 
	
	_global.ORCHID.WrongText = new TextFormat();
	_global.ORCHID.WrongText.rawColor = "ff0000"; // red
	_global.ORCHID.WrongText.underline = true;
	_global.ORCHID.WrongText.color = "0x" + _global.ORCHID.WrongText.rawColor; 
	
	_global.ORCHID.NeutralText = new TextFormat();
	_global.ORCHID.NeutralText.rawColor = "000000"; // black
	_global.ORCHID.NeutralText.color = "0x" + _global.ORCHID.NeutralText.rawColor; 
	
	_global.ORCHID.BoldText = new TextFormat();
	_global.ORCHID.BoldText.bold = true;
	
	_global.ORCHID.UnderlineText = new TextFormat();
	_global.ORCHID.UnderlineText.underline = true;
	
	_global.ORCHID.ItalicText = new TextFormat();
	_global.ORCHID.ItalicText.italic = true;
	
	// v6.2 text format for disabled fields
	_global.ORCHID.DisabledText = new TextFormat();
	_global.ORCHID.DisabledText.color = 0xCCCCCC;

	// hardcode the style used in the rubric until the setExerciseStyles is working
	_global.ORCHID.headline = new TextFormat();
	_global.ORCHID.headline.font = "Verdana";
	_global.ORCHID.headline.size = 10;
	_global.ORCHID.headline.bold = true;

	// copyright information for printing - is this the right place?
	_global.ORCHID.copyright = new Object();
	_global.ORCHID.copyright.footer = "printed from Author Plus"
	
	// now specific titles changes to the default
	if (branding.indexOf("CUP/GIU") >= 0) {
		
		// v6.1.2 ESG and AGU colouring
		//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
		if (branding.indexOf("EGU") >= 0) {
			var cupText = "00719C";
		} else if (branding.indexOf("ESG") >= 0) {
			var cupText = "BE4718";
		} else if (branding.indexOf("AGU") >= 0) {
			var cupText = "006633";
		} else {
			var cupText = "339933";
		}	
		//myTrace("correct cupText=" + cupText);
		// hold the colours as a new rawColor property so that you can add them to html
		// (which needs them in the "#ff0099" format rather than "0xff0099"
		_global.ORCHID.YouWereCorrectText.rawColor = cupText; // EGU blue
		_global.ORCHID.YouWereCorrectText.underline = true;
		_global.ORCHID.YouWereCorrectText.color = "0x" + _global.ORCHID.YouWereCorrectText.rawColor; 
		
		_global.ORCHID.YouWereWrongText.rawColor = "000000"; // black for EGU
		//_global.ORCHID.YouWereWrongText.rawColor = "00719C"; // EGU blue
		_global.ORCHID.YouWereWrongText.underline = true;
		_global.ORCHID.YouWereWrongText.color = "0x" + _global.ORCHID.YouWereWrongText.rawColor; 
		
		// EGU - a new style used by target spotting to set format of red herrings you correctly skipped
		_global.ORCHID.YouAvoidedCorrectly.rawColor = "000000"; // black for EGU
		_global.ORCHID.YouAvoidedCorrectly.underline = false;
		_global.ORCHID.YouAvoidedCorrectly.color = "0x" + _global.ORCHID.YouAvoidedCorrectly.rawColor; 
		
		_global.ORCHID.CorrectText.rawColor = cupText; // EGU blue
		_global.ORCHID.CorrectText.underline = true;
		_global.ORCHID.CorrectText.color = "0x" + _global.ORCHID.CorrectText.rawColor; 
		
		_global.ORCHID.WrongText.rawColor = "000000"; // black for EGU
		//_global.ORCHID.WrongText.rawColor = "00719C"; // EGU blue
		_global.ORCHID.WrongText.underline = true;
		_global.ORCHID.WrongText.color = "0x" + _global.ORCHID.WrongText.rawColor; 
		
		// v6.2 text format for disabled fields
		_global.ORCHID.DisabledText.color = 0x999999; // darker for EGU as (if?) on a blue background
	
		// v6.1.2 ESG and AGU text
		//if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
		if (branding.indexOf("EGU") >= 0) {
			_global.ORCHID.copyright.footer = "English Grammar in Use CD ROM © Cambridge University Press 2004"
		} else if (branding.indexOf("ESG") >= 0) {
			_global.ORCHID.copyright.footer = "Essential Grammar in Use CD ROM © Cambridge University Press 2004"
		} else if (branding.indexOf("AGU") >= 0) {
			_global.ORCHID.copyright.footer = "Advanced Grammar in Use CD ROM © Cambridge University Press 2005"
		}
		
	// v6.4.2.4 Sweet biscuits branding. The key is that after marking all you really want to see are the correct answers
	// and use the parallel tick/cross mechanism to show which they got right or wrong. You won't underline
	// anything they didn't select
	} else if (branding.indexOf("BC/IELTS") >= 0) {
		
		_global.ORCHID.YouWereCorrectText.rawColor = "339933"; // green
		_global.ORCHID.YouWereCorrectText.underline = undefined; // don't alter the underlining at all
		_global.ORCHID.YouWereCorrectText.color = "0x" + _global.ORCHID.YouWereCorrectText.rawColor; 
		
		_global.ORCHID.YouWereWrongText.rawColor = "ff0000"; // red
		_global.ORCHID.YouWereWrongText.underline = undefined;
		_global.ORCHID.YouWereWrongText.color = "0x" + _global.ORCHID.YouWereWrongText.rawColor; 
		
		_global.ORCHID.PRYouWereCorrectText.rawColor = "ff0000"; // red
		_global.ORCHID.PRYouWereCorrectText.underline = undefined;
		_global.ORCHID.PRYouWereCorrectText.color = "0x" + _global.ORCHID.PRYouWereCorrectText.rawColor; 
		
		// v6.3 new format for proof reading - things that were not mistakes that they got - not used at present
		_global.ORCHID.PRYouWereWrongText.rawColor = "339933"; // green
		_global.ORCHID.PRYouWereWrongText.underline = undefined;
		_global.ORCHID.PRYouWereWrongText.color = "0x" + _global.ORCHID.PRYouWereWrongText.rawColor; 
		
		// v6.3 new format for proof reading - mistakes that they missed
		_global.ORCHID.PRCorrectText.rawColor = "ff0000"; // red
		_global.ORCHID.PRCorrectText.underline = undefined;
		_global.ORCHID.PRCorrectText.color = "0x" + _global.ORCHID.PRCorrectText.rawColor; 

		// v6.4.2.4 CorrectText means that it has been corrected, either due to skipping or wrong answering
		//_global.ORCHID.CorrectText.rawColor = "000099"; // blue
		_global.ORCHID.CorrectText.rawColor = "339933"; // green
		_global.ORCHID.CorrectText.underline = undefined;
		_global.ORCHID.CorrectText.color = "0x" + _global.ORCHID.CorrectText.rawColor; 
		
		_global.ORCHID.WrongText.rawColor = "ff0000"; // red
		_global.ORCHID.WrongText.underline = undefined;
		_global.ORCHID.WrongText.color = "0x" + _global.ORCHID.WrongText.rawColor; 
		
		_global.ORCHID.NeutralText.rawColor = "000000"; // black
		_global.ORCHID.NeutralText.color = "0x" + _global.ORCHID.NeutralText.rawColor; 		
	}		
	// v6.3.6 New branding styles to be used by buttons to remove changes in the code
	var me = _global.ORCHID.root.buttonsHolder.buttonsNS.interface;
	myTrace("in sssv9 branding screen with " + branding);
	if (branding.toLowerCase().indexOf("clarity/ro") >= 0) {
		me.tileColour = 0x10494A;
		me.lineColour = 0xACB088;
		me.lineThickness = 2;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
		//myTrace("tile colour is " + _global.ORCHID.root.buttonsHolder.buttonsNS.interface.tileColour);
	} else if (branding.toLowerCase().indexOf("clarity/tb") >= 0) {
		me.tileColour = 0xEC1C24;
		//me.lineColour = 0xE7EBB5;
		me.lineColour = 0xFF6666;
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xEEEEEE;
	// v6.5.4.1 Active Reading title
	} else if (branding.toLowerCase().indexOf("clarity/ar") >= 0) {
		// v6.5.4.3 change to a green
		//me.tileColour = 0xA11015;
		//me.lineColour = 0xE7EBB5;
		me.tileColour = 0x2F5455; 
		me.lineColour = 0xCEE3E2;
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		//me.fillColour = 0xEEEEEE;
		me.fillColour = 0xEFF5F4; // Just a hint in the background of the PUW
	} else if (branding.toLowerCase().indexOf("clarity/sssv9") >= 0) {
		//me.tileColour = 0x7559A9;
		//me.lineColour = 0x340B80;
		//me.lineThickness = 2;
		// v6.5.6.4 New SSS
		/*
		me.tileColour = 0xCC0033;
		me.lineColour = 0x993333;
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
		*/
		me.tileColour = 0x504F53; // grey
		me.lineColour = 0x504F53;
		me.lineThickness = 0;
		me.titleFontColour = 0xFFFFFF;
		//me.titleFillColour = 0x4E2D94; // purple
		me.titleFillColour = 0x886BE8; // purple; overridden in FPopUpWindow!
		// Ideally this would be a gradient
		me.titleFillColourCorrect = 0x6AA940;
		me.titleFillColourWrong = 0xCE0018;
		me.fillColour = 0xFFFFFF;
	// v6.5.6.4 Remember that this more general case must be after the specific V9 case!
	} else if (branding.toLowerCase().indexOf("clarity/sss") >= 0) {
		me.tileColour = 0x7559A9;
		me.lineColour = 0x340B80;
		me.lineThickness = 2;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	} else if (branding.toLowerCase().indexOf("clarity/bw") >= 0) {
		me.tileColour = 0xF15622;
		me.lineColour = 0xF15622;
		me.lineThickness = 0;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	} else if (branding.toLowerCase().indexOf("clarity/ces") >= 0) {
		me.tileColour = 0x323536;
		me.lineColour = 0x323536; 
		me.lineThickness = 0;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	} else if (branding.toLowerCase().indexOf("bc/ielts") >= 0) {
		me.tileColour = 0x000000;
		me.lineColour = 0x000000;
		me.lineThickness = 2;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	} else if (branding.indexOf("MGM/Readers") >= 0) {
		me.tileColour = 0xBF003D;
		me.lineColour = 0x000000;
		me.lineThickness = 2;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	} else if (branding.indexOf("CUP/GIU/AGU") >= 0) {
		me.tileColour = 0xBF003D;
		me.lineColour = 0x006633;
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	} else if (branding.indexOf("CUP/GIU/EGU") >= 0) {
		me.tileColour = 0xBF003D;
		me.lineColour = 0x40AFD4;
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	} else if (branding.toLowerCase().indexOf("futureperfect/cccs") >= 0) {
		me.tileColour = 0xE31E25;
		me.lineColour = 0xE31E25;
		me.lineThickness = 0;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	} else if (branding.toLowerCase().indexOf("languagekey/presentingideas") >= 0) {
		me.tileColour = 0xE31E25;
		me.lineColour = 0xE31E25;
		me.lineThickness = 0;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	} else if (branding.toLowerCase().indexOf("winhoe/soj") >= 0) {
		me.tileColour = 0x80BADA;
		me.lineColour = 0x1F292E;
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF; 
	} else if (branding.toLowerCase().indexOf("clarity/pro") >= 0) {
		//me.tileColour = 0x305455;
		me.tileColour = 0x346D73;
		me.lineColour = 0x346D73; 
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF; 
	} else if (branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
		//me.tileColour = 0x305455;
		//me.tileColour = 0x31376D; // This is the body of the popup
		//me.lineColour = 0x31376D; 
		me.tileColour = 0x504F53; // grey
		me.lineColour = 0x504F53;
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF; 
		
		//me.titleFillColour = 0x4E2D94; // purple
		me.titleFillColour = 0x31376D; // purple; overridden in FPopUpWindow!
		// Ideally this would be a gradient
		me.titleFillColourCorrect = 0x6AA940;
		me.titleFillColourWrong = 0xCE0018; 
		
	} else if (branding.toLowerCase().indexOf("winhoe/gept") >= 0) {
		me.tileColour = 0x474DDE; // blue
		me.lineColour = 0x5E8FFF;
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF; 		
		me.titleFillColour = 0x31376D; // purple; overridden in FPopUpWindow!
		// Ideally this would be a gradient
		me.titleFillColourCorrect = 0x6AA940;
		me.titleFillColourWrong = 0xCE0018; 
		
	} else if (branding.toLowerCase().indexOf("sky/efhs") >= 0) {
		me.tileColour = 0x303030;
		me.lineColour = 0x303030; 
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF; 
	} else if (branding.toLowerCase().indexOf("york/auk") >= 0) {
		me.tileColour = 0x515737;
		me.lineColour = 0x383838;
		me.lineThickness = 1;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF; 
	} else {
		// default is for AP
		me.tileColour = 0x08147B;
		me.lineColour = 0x0E24C0;
		me.lineThickness = 2;
		me.titleFontColour = 0xFFFFFF;
		me.fillColour = 0xFFFFFF;
	}
	_global.ORCHID.root.printingHolder.setFooter = _global.ORCHID.copyright.footer;
}
//Note: this function does not properly set the textFormat object
setExerciseStyles = function() {
	var me = _global.ORCHID.LoadedExercises[0];
	for (i in me.style) {
		myTrace("in sES with " + me.style[i].name);
		var thisStyle = me.style[i].name;
		// are we overriding an existing style, or creating a new one?
		if (_global.ORCHID[thisStyle] == undefined) {
			_global.ORCHID[thisStyle] = new TextFormat();
		}
		for (j in _global.ORCHID[thisStyle]) { // copy all the TextFormat properties (but not any others)
			_global.ORCHID[thisStyle][j] = me.style[i][j];
		}
		//trace("style="+thisStyle+ " has bold " + _global.ORCHID[thisStyle].bold);
	}
}
_global.ORCHID.fontLookUp = function(id) {
	var me = _global.ORCHID.LoadedExercises[0];
	var i = 0;
	for (i in me.fontTable) {
		if (me.fontTable[i].id == id) {
			//trace("found font id="+id+ ", it is "+me.fontTable[i].name);
			return me.fontTable[i].name;
		};
	};
};
