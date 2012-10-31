// AR: Note. This is not a well written app. if I run it in Flash it crashes Flash (the whole program) very regularly. But run on its own seems fine.
// **************************************************
// INIT
// **************************************************
this._alpha = 0;
this._visible = false;
//
import flash.filters.BlurFilter;
import caurina.transitions.Tweener;
import flash.geom.ColorTransform;
import flash.geom.Transform;
// --------------------------------------------------
// LOADED VARIABLES
// --------------------------------------------------
//AR simplify
var startNumber:Number = 0;
var endNumber:Number = 0;
//
var numbersMax:Number = 6; // the number of digits
var numberCurrent:Number = 1; // what is this?
var showCommas:Boolean = true;
//var commaGroupNum:Number = Number(data_xml.childNodes[0].attributes.commaGroupNum);
var commaGroupNum:Number = 3;
var decimalPlaces:Number = 0;
//
//var numberBgColor:Number = 0x0033FF;
var numberBgColor:Number = 0x5B5072;
var numberColor:Number = 0xFFFFFF;
var numberBorderInnerColor:Number = 0x282828;
var numberBorderOuterColor:Number = 0x141414;
var windowHiliteAlpha:Number = 75;
//
var fadeInTime:Number = 0.5;
//
var blurMax:Number = 10;
var speedMax:Number = 60;
var snapBack:Number = 2;
var accelTime:Number = 0.5;
var accelDelay:Number = 0.25;
var decelTime:Number = 1.25;
var decelDelay:Number = 0.25;
var animationTypeAccel:String = "easeInQuad";
var animationTypeDecel:String = "easeOutSine";
//
var soundFXon:Boolean = true;
var soundFXvolume:Number = 10;

// --------------------------------------------------  
// VARIABLES
// --------------------------------------------------
//frameLabel_str = "functions";
//stopped_bool = false;
var decimalFactor = 1;
var commaCurrent:Number = 1;
//var commasMax:Number = Math.ceil(numbersMax / commaGroupNum) - 1;
// ------------------------------
// HEIGHT, WIDTH
// ------------------------------
var numberCompWidth_num:Number = numberComp_mc.windowBorderOuter_mc._width;
var numberCompHeight_num:Number = numberComp_mc.windowBorderOuter_mc._height;
var commaCompWidth_num:Number = commaComp_mc._width;
var commaCompHeight_num:Number = commaComp_mc._height;
var decimalCompWidth_num:Number = 0;
// ------------------------------
// Y POSITION
// ------------------------------
var numbersYstart_num:Number = 0;
var numbersYmoveUnit_num:Number = 34;
var numbersYmoveTotal_num:Number = 10 * numbersYmoveUnit_num;
var numbersYmoveTarget_num:Number = 0;
var speedMin_num:Number = 0;
var speedMax_num:Number = speedMax;
// ------------------------------
// X POSITION
// ------------------------------
//var XposCurrent_num:Number = (numbersMax * numberCompWidth_num) + (commasMax * commaCompWidth_num) + (decimalPlaces * numberCompWidth_num) + decimalCompWidth_num;
//var widthMax_num:Number = XposCurrent_num;
// ------------------------------
// STRINGS
// ------------------------------
var charctersOld_str:String = "";
var charctersNew_str:String = "";
var charctersTemp_str:String = "";
// ------------------------------
// SOUND FX OBJECT
// ------------------------------
var click_sound:Sound = new Sound(numberComp_mc);
click_sound.attachSound("click");
click_sound.setVolume(soundFXvolume);
// **************************************************
// INIT DISPLAY FUNCTION
// **************************************************
function fncInitDisplay(numberOfDigits:Number):Void {
	
	// Clear out any existing numbers, commas mc that we have already built
	for (var i:Number=1;i<=10;i++) {
		this["numberComp_" + i + "_mc"].removeMovieClip();
		this["commaComp_" + i + "_mc"].removeMovieClip();
	}
	// AR to allow number of digits to be dynamic
	numbersMax = numberOfDigits;
	var commasMax:Number = Math.ceil(numbersMax / commaGroupNum) - 1;
	var XposCurrent_num:Number = (numbersMax * numberCompWidth_num) + (commasMax * commaCompWidth_num) + (decimalPlaces * numberCompWidth_num) + decimalCompWidth_num;
	var widthMax_num:Number = XposCurrent_num;
	spinButton_mc._width = widthMax_num;

	decimalComp_mc._visible = false;
	// NUMBERS:
	for (var j:Number = (decimalPlaces + 1); j <= (numbersMax + decimalPlaces); j++) {
		var target_number = "numberComp_" + j + "_mc";
		numberComp_mc.duplicateMovieClip(target_number,j);
		// WINDOW BG:
		Tweener.addTween(this[target_number].windowBg_mc,{_color:numberBgColor, time:0, transition:"linear"});
		// NUMBERS:
		Tweener.addTween(this[target_number].numberTileComp_mc,{_color:numberColor, time:0, transition:"linear"});
		// WINDOW INNER BORDER:
		Tweener.addTween(this[target_number].windowBorderInner_mc,{_color:numberBorderInnerColor, time:0, transition:"linear"});
		// WINDOW OUTER BORDER:
		Tweener.addTween(this[target_number].windowBorderOuter_mc,{_color:numberBorderOuterColor, time:0, transition:"linear"});
		// WINDOW HILITE:
		this[target_number]["hilite_mc"]._alpha = windowHiliteAlpha;
		// X POSITION:
		XposCurrent_num -= numberCompWidth_num;
		this[target_number]._x = XposCurrent_num;
		// BLUR
		if (blurMax > 0) {
			var blurX:Number = 0;
			var blurY:Number = 0;
			var quality:Number = 1;
			var filter:BlurFilter = new BlurFilter(blurX, blurY, quality);
			var filterArray:Array = new Array();
			filterArray.push(filter);
			this[target_number]["numberTileComp_mc"].filters = filterArray;
		}
		// VARIABLES:                                   
		this[target_number].whichNumberMC_num = j;
		this[target_number]["numberTileComp_mc"].charCurrent_num = undefined;
		this[target_number]["numberTileComp_mc"].charNew_num = undefined;
		this[target_number]["numberTileComp_mc"].speedCurrent_num = speedMin_num;
		this[target_number]["numberTileComp_mc"].yPosStart_num = this[target_number]["numberTileComp_mc"]._y;
		this[target_number]["numberTileComp_mc"].yPosEnd_num = this.yPosStart_num + numbersYmoveTotal_num;
		this[target_number]["numberTileComp_mc"].yPosCurrent_num = this.yPosStart_num;
		this[target_number]["numberTileComp_mc"].stopflag_bool = false;
		// COMMAS:
		if (showCommas == true && j < (numbersMax + decimalPlaces)) {
			if (((j - decimalPlaces) % commaGroupNum) == 0) {
				var target_comma = "commaComp_" + ((j - decimalPlaces) / commaGroupNum) + "_mc";
				//trace("comma mc=" + target_comma);
				commaComp_mc.duplicateMovieClip(target_comma,j * 1000);
				// WINDOW BG:
				Tweener.addTween(this[target_comma].windowBg_mc,{_color:numberBgColor, time:0, transition:"linear"});
				// NUMBERS:
				Tweener.addTween(this[target_comma].comma_mc,{_color:numberColor, time:0, transition:"linear"});
				// WINDOW INNER BORDER:
				Tweener.addTween(this[target_comma].windowBorderInner_mc,{_color:numberBorderInnerColor, time:0, transition:"linear"});
				// WINDOW OUTER BORDER:
				Tweener.addTween(this[target_comma].windowBorderOuter_mc,{_color:numberBorderOuterColor, time:0, transition:"linear"});
				// WINDOW HILITE:
				this[target_comma]["hilite_mc"]._alpha = windowHiliteAlpha;
				// X POSITION:
				XposCurrent_num -= commaCompWidth_num;
				this[target_comma]._x = XposCurrent_num;
			}
		}
	}
	numberComp_mc._visible = false;
	commaComp_mc._visible = false;
	// ------------------------------
	// INIT NUMBER POSITIONS
	// ------------------------------
	var startDigits_num:Number = startNumber * decimalFactor;
	charctersTemp_str = String(startDigits_num);
	var charcterLength_num:Number = charctersTemp_str.length;
	//
	// ADD ZEROS TO START OF STRING IF LESS THAN MAXIMUM DIGITS:
	if (charcterLength_num < (numbersMax + decimalPlaces)) {
		for (var k:Number = 1; k <= ((numbersMax + decimalPlaces) - charcterLength_num); k++) {
			charctersTemp_str = "0" + charctersTemp_str;
		}
	}
	charctersOld_str = charctersTemp_str;
	charctersTemp_str = "";
	//
	// LOOP
	for (var n:Number = 1; n <= (numbersMax + decimalPlaces); n++) {
		// ------------------------------
		// WHICH NUMBER MOVIECLIP
		// ------------------------------
		var target_numberTile:MovieClip = this["numberComp_" + n + "_mc"]["numberTileComp_mc"];
		// ------------------------------
		// WHICH CHARACTER
		// ------------------------------
		var targetCharOld_str:String = charctersOld_str.charAt((charctersOld_str.length) - n);
		// ------------------------------
		// TWEEN
		// ------------------------------
		this[target_numberTile].charCurrent_num = Number(targetCharOld_str);
		var yMoveTarget_num:Number = Number(targetCharOld_str) * numbersYmoveUnit_num;
		Tweener.addTween(target_numberTile,{_y:yMoveTarget_num, time:0, transition:"linear"});
	}
}
// **************************************************
// SPIN FUNCTIONS
// **************************************************
function fncSpinNumbers():Void {
	// ------------------------------
	// GET END NUMBER
	// ------------------------------
	var endDigits_num:Number = endNumber * decimalFactor;
	charctersTemp_str = String(endDigits_num);
	var charcterLength_num:Number = charctersTemp_str.length;
	//
	// ADD ZEROS TO START OF STRING IF LESS THAN MAXIMUM DIGITS:
	if (charcterLength_num < (numbersMax + decimalPlaces)) {
		for (var i:Number = 1; i <= ((numbersMax + decimalPlaces) - charcterLength_num); i++) {
			charctersTemp_str = "0" + charctersTemp_str;
		}
	}
	charctersNew_str = charctersTemp_str;
	charctersTemp_str = "";
	myTrace("starting to spin " + (numbersMax + decimalPlaces) + " digits");
	// LOOP
	for (var i:Number = 1; i <= (numbersMax + decimalPlaces); i++) {
		// ------------------------------
		// WHICH NUMBER MOVIECLIP
		// ------------------------------
		var target_numberTile:MovieClip = this["numberComp_" + i + "_mc"]["numberTileComp_mc"];
		// ------------------------------
		// WHICH CHARACTER
		// ------------------------------
		var targetCharNew_str:String = charctersNew_str.charAt((charctersNew_str.length) - i);
		target_numberTile.charNew_num = Number(charctersNew_str.charAt((charctersNew_str.length) - i));
		// SPIN
		//fncSpinEm(i);
		target_numberTile.speedCurrent_num = speedMin_num;
		target_numberTile.yPosStart_num = target_numberTile._y;
		target_numberTile.yPosEnd_num = numbersYmoveTotal_num + (numbersYmoveUnit_num * (target_numberTile.charNew_num));
		target_numberTile.yPosCurrent_num = target_numberTile.yPosStart_num;
		target_numberTile.stopflag_bool = false;
		// MOVE ACCLERATE
		myTrace("starting to spin tile " + target_numberTile + " go to " + target_numberTile.charNew_num);
		// AR I don't think you should set it like this. addTween returns true or false;
		//target_numberTile.speedCurrent_num = Tweener.addTween(target_numberTile, {speedCurrent_num:speedMax_num, transition:animationTypeAccel, _blur_blurX:0, _blur_blurY:blurMax, time:accelTime, delay:(i - 1) * accelDelay});
		//Tweener.addTween(target_numberTile, {speedCurrent_num:speedMax_num, transition:animationTypeAccel, _blur_blurX:0, _blur_blurY:blurMax, time:accelTime, delay:(i - 1) * accelDelay});
		// This is just a blur
		Tweener.addTween(target_numberTile, {speedCurrent_num:speedMax_num, transition:animationTypeAccel, _blur_blurX:0, _blur_blurY:blurMax, time:accelTime, delay:(i - 1) * accelDelay});
		// This gets the addEnterFrame going, and starts moving the animations
		Tweener.addTween(this,{time:(i - 1) * accelDelay, onComplete:fncAddEnterFrame, onCompleteParams:[i]});
		// STOP TWEEN
		//Tweener.addTween(this,{time:(accelDelay + decelDelay) * i, onComplete:fncStopSpin, onCompleteParams:[i]});
		Tweener.addTween(this,{time:(accelDelay + decelDelay) * i, onComplete:fncStopSpin, onCompleteParams:[i]});
	}
}
/*
fncSpinEm = function (whichNumberTile:Number):Void {
	this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"].speedCurrent_num = speedMin_num;
	this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"].yPosStart_num = this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"]._y;
	this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"].yPosEnd_num = numbersYmoveTotal_num + (numbersYmoveUnit_num * (this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"].charNew_num));
	this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"].yPosCurrent_num = this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"].yPosStart_num;
	this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"].stopflag_bool = false;
	// MOVE ACCLERATE
	// AR I don't think you should set it like this. addTween returns true or false;
	//this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"].speedCurrent_num = Tweener.addTween(this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"], {speedCurrent_num:speedMax_num, transition:animationTypeAccel, _blur_blurX:0, _blur_blurY:blurMax, time:accelTime, delay:(whichNumberTile - 1) * accelDelay});
	Tweener.addTween(this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"], {speedCurrent_num:speedMax_num, transition:animationTypeAccel, _blur_blurX:0, _blur_blurY:blurMax, time:accelTime, delay:(whichNumberTile - 1) * accelDelay});
	Tweener.addTween(this,{time:(whichNumberTile - 1) * accelDelay, onComplete:fncAddEnterFrame, onCompleteParams:[whichNumberTile]});
};
*/
fncAddEnterFrame = function (whichNumberTile:Number):Void {
	this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"].onEnterFrame = function() {
		//myTrace("enterFrame for " + this + ", " + numbersYmoveTotal_num + ", " + this.speedCurrent_num + ", " + this._y);
		//myTrace("ready to stop " + this + " " + this.stopflag_bool);
		/*
		if (this._y < numbersYmoveTotal_num - this.speedCurrent_num) {
			this._y += this.speedCurrent_num;
			this.yPosCurrent_num = this._y;
		} else {
			if (this.stopflag_bool == true) {
				myTrace("yes, start decelerate");
				delete this.onEnterFrame;
				this.speedCurrent_num = 0;
				this._y = 0;
				// MOVE DECCLERATE
				Tweener.addTween(this,{_y:this.yPosEnd_num + snapBack, _blur_blurX:0, _blur_blurY:0, time:decelTime + (this.charNew_num * 0.05), transition:animationTypeDecel, onComplete:fncEndSpin, onCompleteParams:[whichNumberTile]});
			} else {
				// AR Is this setting my whole thing off again?
				//this._y = 0;
			}
		}
		*/
		if (this.stopflag_bool == true) {
			//myTrace("yes, start decelerate");
			delete this.onEnterFrame;
			this.speedCurrent_num = 0;
			this._y = 0;
			// MOVE DECCLERATE
			Tweener.addTween(this,{_y:this.yPosEnd_num + snapBack, _blur_blurX:0, _blur_blurY:0, time:decelTime + (this.charNew_num * 0.05), transition:animationTypeDecel, onComplete:fncEndSpin, onCompleteParams:[whichNumberTile]});
		} else {
			if (this._y < numbersYmoveTotal_num - this.speedCurrent_num) {
				this._y += this.speedCurrent_num;
				this.yPosCurrent_num = this._y;
			} else {
				this._y = 0;
			}
		}
	};
};
fncStopSpin = function (whichNumberTile:Number):Void {
	myTrace("stopSpin for " + whichNumberTile);
	var target_number:MovieClip = this["numberComp_" + whichNumberTile + "_mc"]["numberTileComp_mc"];
	target_number.stopflag_bool = true;
};
fncEndSpin = function (whichNumberTile:Number):Void {
	myTrace("finished spinning tile " + whichNumberTile);
	if (numberCurrent < numbersMax + decimalPlaces) {
		numberCurrent++;
		fncStopSpin(numberCurrent);
	} else {
		// BUTTON ENABLE  
		fncButtonEnable(spinButton_mc);
		numberCurrent = 1;
	}
	var target_number:MovieClip = eval("numberComp_" + whichNumberTile + "_mc.numberTileComp_mc");
	// REMOVE TWEENS
	Tweener.removeTweens(target_number);
	target_number._y = numbersYmoveUnit_num * target_number.charNew_num;
	target_number.yPosStart_num = numbersYmoveUnit_num * target_number.charNew_num;
	target_number.charCurrent_num = target_number.charNew_num;
	//target_number.charNew_num = undefined;
	target_number.charNew_num = 0;
	// SOUND FX
	if (soundFXon == true) {
		click_sound.start(0);
	}
};
// **************************************************
// BUTTONS
// **************************************************
fncButtonDisable = function (whichButton):Void {
	if (whichButton.enabled != false) {
		whichButton.enabled = false;
	}
	if (whichButton.useHandCursor != false) {
		whichButton.useHandCursor = false;
	}
};
fncButtonEnable = function (whichButton):Void {
	if (whichButton.enabled != true) {
		whichButton.enabled = true;
	}
	if (whichButton.useHandCursor != true) {
		whichButton.useHandCursor = true;
	}
};
// --------------------------------------------------
// SPIN BUTTON
// --------------------------------------------------
spinButton_mc.swapDepths(100000);
spinButton_mc._alpha = 0;
//spinButton_mc._width = widthMax_num;
spinButton_mc._height = numberCompHeight_num;
//
spinButton_mc.onRollOver = function():Void  {
	//
};
spinButton_mc.onPress = function():Void  {
	//
};
spinButton_mc.onRelease = function():Void  {
	fncButtonDisable(spinButton_mc);
	//
	//AR simplify
	fncSpinNumbers();
};
spinButton_mc.onRollOut = function():Void  {
	//
};
spinButton_mc.onDragOut = function():Void  {
	this.onRollOut();
};
spinButton_mc.onReleaseOutside = function():Void  {
	this.onRollOut();
};
// **************************************************
// CALLBACK FUNCTIONS
// **************************************************
// AR simplify
/*
_global.fncPlayMainTimeline = function():Void  {
	if (_level0.stopped_bool = true) {
		_level0.stopped_bool = false;
		_level0.play();
	}
};

MovieClip.prototype.fncPlayParentTimeline = function():Void  {
	if (this._parent.stopped_bool == true) {
		this._parent.stopped_bool = false;
		this._parent.play();
	}
};

MovieClip.prototype.fncPlayTimeline = function():Void  {
	if (this.stopped_bool == true) {
		this.stopped_bool = false;
		this.play();
	}
};
*/
// **************************************************
// PAUSE
// **************************************************
// AR simplify
/*
MovieClip.prototype.pauseMe = function(seconds):Void  {
	clearInterval(this.pause_interval);
	this.pause_interval = setInterval(fncPauseMe, 1, seconds, this);
	this.timerMark_num = getTimer();
	this.stopped_bool = true;
	this.stop();
};
_global.fncPauseMe = function(seconds, pauseObject):Void  {
	if ((getTimer() - eval(pauseObject).timerMark_num) < (seconds * 1000)) {
		//--> Stay paused
	} else {
		clearInterval(eval(pauseObject).pause_interval);
		eval(pauseObject).stopped_bool = false;
		eval(pauseObject).play();
	}
};
*/
fncSetValue = function(endValue):Void {
	myTrace("1.fncSetValue to " + endValue);
	endNumber = endValue;
	//myTrace("2.fncSetValue to " + endValue);
	var numberOfDigits:Number = 0;
	var tempNumber:Number = endValue;
	//myTrace("3.fncSetValue to " + endValue);
	while (tempNumber>=1) {
		numberOfDigits++;
		tempNumber=tempNumber/10;
		//myTrace("numberOfDigits=" + numberOfDigits);
	}
	myTrace("numberOfDigits=" + numberOfDigits);
	if (numberOfDigits != maxNumbers) {
		fncInitDisplay(numberOfDigits);
	}
	//myTrace("go to spin");
	fncSpinNumbers();
};

// **************************************************
// FUNCTION CALLS
// **************************************************
fncButtonDisable(spinButton_mc);
fncInitDisplay(3);
this._visible = true;
pretendRemote = function() {
	this.fncSetValue(125);
}
//fncSetValue(765);
//Tweener.addTween(this,{_alpha:100, time:fadeInTime, transition:"linear", onComplete:fncSpinNumbers});
//Tweener.addTween(this,{_alpha:100, time:fadeInTime, transition:"linear", onComplete:pretendRemote});
Tweener.addTween(this,{_alpha:100, time:fadeInTime, transition:"linear"});
// **************************************************