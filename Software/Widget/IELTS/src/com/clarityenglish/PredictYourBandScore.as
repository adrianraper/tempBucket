package com.clarityenglish
{
	/**
	 * ...
	 * @author Adrian Raper
	 */
	import com.clarityenglish.utils.TraceUtils;
	import com.clarityenglish.utils.Literals;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.LoaderInfo;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.net.*;
	
	public class PredictYourBandScore extends MovieClip
	{
		var literals:Literals;
		var title_txt:TextField;
		var websiteLanguage:String = "EN";
		var websiteCountry:String = "none";
		var websiteWantsBCLogo:Boolean = true;
		var BCWebsite:Boolean = false;
		var websiteReferrer:String = "";
		var thisWidget:String;
		var titleHeight:uint = 48;
		var headerVerticalPadding:uint = 12;
		var headerHorizontalPadding:uint = 5;
		var horizontalPadding:uint = 5;
		var titleTF:TextFormat;
		var detailsTF:TextFormat;
		var originalTitleTextY:uint;
		
		public function PredictYourBandScore() {
			//TraceUtils.myTrace("in the class " + new Date().getTime());
			
			// Are there any variables to pick up from the URL that control the layout?
			this.root.loaderInfo.addEventListener(Event.COMPLETE, loadedHandler);
			
		}
		private function loadedHandler(e:Event):void {
			
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			
			//var paramObj:Object = this.root.loaderInfo.parameters;
			var paramObj:Object = loaderInfo.parameters;
			//TraceUtils.myTrace("running from " + this.root.loaderInfo.loaderURL);
			//var rootArray:Array = this.root.loaderInfo.loaderURL.split("/");
			var rootArray:Array = loaderInfo.loaderURL.split("/");
			// drop the filename
			rootArray.pop();
			var applicationRoot:String = rootArray.join("/");
			TraceUtils.myTrace("running from " + applicationRoot);
			
			for (var parameter:String in paramObj) {
				TraceUtils.myTrace("config." + parameter + "=" + paramObj[parameter]);
			}
			// Find the width and height. These are not passed but set as flash parameters.
			if (paramObj['widgetdatawidth']) {
				TraceUtils.myTrace("width=" + paramObj['widgetdatawidth']);
				//TraceUtils.myTrace("we know the stageWidth=" + this.stage.stageWidth);
			}
			if (paramObj['widgetdataheight']) {
				TraceUtils.myTrace("height=" + paramObj['widgetdataheight']);
				//TraceUtils.myTrace("we know the stageHeight=" + this.stage.stageHeight);
			}
			// The language used
			if (paramObj['widgetdatalanguage']) {
				TraceUtils.myTrace("language=" + paramObj['widgetdatalanguage']);
				websiteLanguage = paramObj['widgetdatalanguage'];
			}
			// The country that the widget is being used for (will be used in choosing target for more info URLs)
			if (paramObj['widgetdatacountry']) {
				TraceUtils.myTrace("country=" + paramObj['widgetdatacountry']);
				websiteCountry = paramObj['widgetdatacountry'];
			}
			// Does the website want to see the BC logo on the widget?
			if (paramObj['widgetdatabclogo']==false || paramObj['widgetdatabclogo']=='false') {
				websiteWantsBCLogo=false;
			}
			TraceUtils.myTrace("logo=" + websiteWantsBCLogo);
			
			// Any theme customisations? not currently used
			if (paramObj['widgetdatabackgroundcolor']) {
				TraceUtils.myTrace("backgroundColor=" + paramObj['widgetdatabackgroundcolor']);
				this.stage.opaqueBackground = Number(paramObj['widgetdatabackgroundcolor']);
			}
			// Is this being used on a BC website?
			// Turns out that we don't need this, it is all based on whether the BC Logo is used or not.
			//if (paramObj['widgetdataBCWebsite']==true || paramObj['widgetdataBCWebsite']=='true') {
			//	TraceUtils.myTrace("widgetdataBCWebsite=" + paramObj['widgetdataBCWebsite']);
			//	BCWebsite = true;
			//}
			
			// For logging of usage
			if (paramObj['widgetdatareferrer']) {
				websiteReferrer=paramObj['widgetdatareferrer'];
				TraceUtils.myTrace("referrer=" + paramObj['widgetdatareferrer']);
			}
			
			// So use these parameters to set the stage size and call literals and style
			// Actually we can set the Flash width and height from swfobject, so all we need to do here is read the stage.
			//this.stage.width = Number(paramObj['widgetdatawidth']);
			//this.stage.height = Number(paramObj['widgetdataheight']);
			
			// Instantiate the literals class and start loading.
			thisWidget = 'PredictYourBandScore';
			this.literals =  new Literals(websiteLanguage, thisWidget);
			this.literals.loadXMLFile(applicationRoot);
			this.literals.addEventListener(Literals.LOADED, initLiterals);

			// Layout the widget - but what is the real width?
			//loaderInfo.width gives me the Flash file width of the 'document'
			// stage.width gives me the Flash file width based on the objects
			// stage.stageWidth gives me the Flash file width based on the objects
			//TraceUtils.myTrace("loaderInfo.width=" + loaderInfo.width);
			//TraceUtils.myTrace("stage.width=" + this.stage.width);
			//TraceUtils.myTrace("stage.stageWidth=" + this.stage.stageWidth);
			//TraceUtils.myTrace("screen.width=" + this.stage.fullScreenWidth);
			//TraceUtils.myTrace("displayObject.width=" + this.width);
			if (paramObj['widgetdatawidth']>0 && paramObj['widgetdataheight']>0) {
				this.widgetLayout(paramObj['widgetdatawidth'], paramObj['widgetdataheight']);
			} else {
				this.widgetLayout(this.stage.stageWidth, this.stage.stageHeight);
			}
			
			// And we need to make the origin in the top left corner
			// If you publish the flash with width 160, changing that with the Flash options means that the
			// origin is NOT top left. How to sort that out? Quickest option is different swfs for different widths.
			// This code doesn't need to be different, just the fla document size.
			
			// set events for buttons clicks
			this.calculatorFields.actionBtn.addEventListener(MouseEvent.CLICK, onCalculate);
			this.resultFields.actionBtn.addEventListener(MouseEvent.CLICK, onRestart);
			this.resultFields.moreInfoBtn.addEventListener(MouseEvent.CLICK, onMoreInfo);
		}
		
		private function widgetLayout(width:uint, height:uint) {
			TraceUtils.myTrace("layout for width=" + width + " height=" + height);
			
			// Draw a border. GS wants to switch to IELTS Red and BC blue.
			//var borderColor:Number = 0xFF820033;
			var borderColor:Number = 0xFFD52039;
			var fillColor:Number = 0xFFD52039;
			var mB:Sprite = new Sprite();
			mB.graphics.lineStyle(1, borderColor, 100);
			mB.graphics.moveTo(0,0);
			mB.graphics.lineTo(width-1,0);
			mB.graphics.lineTo(width-1,height-1);
			mB.graphics.lineTo(0,height-1);
			mB.graphics.lineTo(0,0);
			this.addChild(mB);

			// The choice of header depends on width and BClogo or not
			/*
			if (websiteWantsBCLogo) {
				this.header.withoutBCLogo.visible = false;
			} else {
				this.header.withBCLogo.visible = false;
			}
			// Position the header
			var headerVerticalPadding:uint = 5;
			this.header.x = (width - this.header.width)/2 ;
			this.header.y = headerVerticalPadding;
			*/
			// Try just using separate logos
			// Position the header across the top
			//var headerVerticalPadding:uint = 5;
			//var headerVerticalPadding:uint = 10;
			this.header.x = 0 ;
			this.header.y = headerVerticalPadding;
			//this.header.width = width;
			
			if (websiteWantsBCLogo) {
				if (width<200) {
					headerHorizontalPadding = 5;
				} else {
					headerHorizontalPadding = 10;
				}
				this.header.BClogo.x = headerHorizontalPadding;
				this.header.IELTSlogo.x = width - this.header.IELTSlogo.width - headerHorizontalPadding;
			} else {
				this.header.BClogo.visible = false;
				this.header.IELTSlogo.x = (width - this.header.IELTSlogo.width)/2 ;
			}			
			
			// Position the footer
			// Or is it easier to create it?
			this.footer.width = width;
			//this.footer.height = 30;
			this.footer.y = height - this.footer.height;
			this.footer.x = 0 ;
			
			// Position the title, with a background
			//var titleHeight:uint = 58;
			//var titleHeight:uint = 48;
			//this.title.y = this.header.height + (headerVerticalPadding * 2);
			//this.title.width = width;
			var mT:Sprite = new Sprite();
			mT.x = 0;
			mT.y = this.header.height + (headerVerticalPadding * 2);
			mT.graphics.lineStyle(1, borderColor);
			mT.graphics.beginFill(fillColor)
			mT.graphics.moveTo(0,0);
			//mT.graphics.lineTo(width-1,this.header.height + (headerVerticalPadding * 2));
			//mT.graphics.lineTo(width-1,this.header.height + (headerVerticalPadding * 2)+titleHeight-1);
			//mT.graphics.lineTo(0,this.header.height + (headerVerticalPadding * 2)+titleHeight-1);
			//mT.graphics.lineTo(0,this.header.height + (headerVerticalPadding * 2));
			mT.graphics.lineTo(width-1,0);
			mT.graphics.lineTo(width-1,titleHeight-1);
			mT.graphics.lineTo(0,titleHeight-1);
			mT.graphics.lineTo(0,0);
			this.addChild(mT);
			
			// Put the text field on it
			title_txt = new TextField();
			title_txt.x = horizontalPadding;
			title_txt.y = mT.y + headerVerticalPadding/2;
			originalTitleTextY = title_txt.y;
			title_txt.autoSize = TextFieldAutoSize.LEFT;
			title_txt.multiline = true;
			title_txt.wordWrap = true;
			title_txt.width = width - horizontalPadding * 2;
			titleTF = new TextFormat();
			titleTF.font = "Helvetica";
			titleTF.color = "0xFFFFFFFF";
			titleTF.size = 13;
			titleTF.align = TextFormatAlign.CENTER;
			titleTF.bold = true;
			titleTF.leftMargin = .6;
			title_txt.defaultTextFormat = titleTF;
			addChild(title_txt);			
			detailsTF = new TextFormat();
			if (width>160) {
				detailsTF.size = 11;
			} else {
				detailsTF.size = 10;
			}
			
			// What size should fonts be in the other fields?
			var textTF:TextFormat = new TextFormat();
			textTF.font = "Helvetica";
			textTF.color = "0xFF000000";
			// it could be a little bigger if you want and have more space
			if (width>160) {
				textTF.size = 12;
			} else {
				textTF.size = 11;
			}
			if (websiteLanguage=='ZH') textTF.size+=1;
			// Do we need to squish up the text?
			textTF.leading = -1;
			// Need this to stop a W getting its first stroke chopped.
			// http://bryanlangdon.com/blog/2008/12/15/w-arial-text-cut-off-fix-for-as2-and-as3/
			textTF.leftMargin = .6;
			
			textTF.align = TextFormatAlign.LEFT;
			calculatorFields.intro_ltl.defaultTextFormat = textTF;
			
			// And the comboboxes
			//calculatorFields.listeningQ.setStyle("textFormat", textTF);
			calculatorFields.listeningQ.editable = false;
			
			// You can't use defaultTextFormat for htmlText - has to be a style sheet
			//resultFields.moreinfo_txt.defaultTextFormat = textTF;
			resultFields.descriptor_txt.defaultTextFormat = textTF;
			//resultFields.moreinfo_txt.defaultTextFormat = textTF;
			resultFields.disclaimer_txt.defaultTextFormat = textTF;
			resultFields.disclaimer_txt.addEventListener(MouseEvent.MOUSE_OVER, onDisclaimer);
			// You lose the field, so mouseOff that is no good.
			disclaimer.disclaimer_txt.addEventListener(MouseEvent.MOUSE_OUT, offDisclaimer);
			
			// And text on the Button
			var buttonTF:TextFormat = new TextFormat();
			buttonTF.font = "Helvetica";
			buttonTF.color = "0xFFFFFFFF";
			buttonTF.align = TextFormatAlign.CENTER;
			//buttonTF.bold = true;
			calculatorFields.actionBtn.setStyle("textFormat", buttonTF);
			resultFields.actionBtn.setStyle("textFormat", buttonTF);
			resultFields.moreInfoBtn.setStyle("textFormat", buttonTF);
			resultFields.moreInfoBtn.textField.multiline = true;
			resultFields.moreInfoBtn.textField.autoSize = TextFieldAutoSize.CENTER;
			//resultFields.moreInfoBtn.textField.wordWrap = true;
			resultFields.moreInfoBtn.textField.width = resultFields.moreInfoBtn.width-20;
			
			// But then override alignment for next two (this changes the original too)
			var overrideFormat:TextFormat = textTF;
			overrideFormat.align = TextFormatAlign.RIGHT;
			calculatorFields.preReading_ltl.defaultTextFormat = overrideFormat;
			calculatorFields.preListening_ltl.defaultTextFormat = overrideFormat;
			calculatorFields.preWriting_ltl.defaultTextFormat = overrideFormat;
			calculatorFields.preSpeaking_ltl.defaultTextFormat = overrideFormat;

			// If the vertical spacing is too much, push down the fields
			if (headerVerticalPadding>10) {
				calculatorFields.y+=(headerVerticalPadding/2);
				resultFields.y+=(headerVerticalPadding/2);
			}
			// make any fields wider?
			calculatorFields.intro_ltl.width = width-(2*horizontalPadding);
			//resultFields.moreinfo_txt.width = width-(2*horizontalPadding);
			resultFields.descriptor_txt.width = width-(2*horizontalPadding);
			resultFields.disclaimer_txt.width = width-(2*horizontalPadding);
			
			// center anything?
			disclaimer.x = (width-disclaimer.width)/2;
			//if (width>160) {
			//}
			
			// align buttons
			calculatorFields.actionBtn.x = resultFields.actionBtn.x = (width - calculatorFields.actionBtn.width)/2;
			resultFields.moreInfoBtn.x = (width - resultFields.moreInfoBtn.width)/2;
			
			// Then display the calculator screen and hide the result screen
			this.calculatorFields.visible = true;
			this.resultFields.visible = false;
			this.disclaimer.visible = false;
			
		}
		
		private function initLiterals(e:Event):void {
			TraceUtils.myTrace("can get literal as " + this.literals.getLiteral('applicationName'));
			var replaceObj:Object = {newline:'\n'};
			title_txt.text = this.literals.getLiteral('applicationName', replaceObj);
			calculatorFields.intro_ltl.text = this.literals.getLiteral('intro');
			with(calculatorFields.listeningQ) {
				addItem({label:'4.0'});
				addItem({label:'4.5'});
				addItem({label:'5.0'});
				addItem({label:'5.5'});
				addItem({label:'6.0'});
				addItem({label:'6.5'});
				addItem({label:'7.0'});
				addItem({label:'7.5'});
				addItem({label:'8.0'});
				addItem({label:'8.5'});
				addItem({label:'9.0'});
			}
			with(calculatorFields.readingQ) {
				addItem({label:'4.0'});
				addItem({label:'4.5'});
				addItem({label:'5.0'});
				addItem({label:'5.5'});
				addItem({label:'6.0'});
				addItem({label:'6.5'});
				addItem({label:'7.0'});
				addItem({label:'7.5'});
				addItem({label:'8.0'});
				addItem({label:'8.5'});
				addItem({label:'9.0'});
			}
			with(calculatorFields.writingQ) {
				addItem({label:'4.0'});
				addItem({label:'4.5'});
				addItem({label:'5.0'});
				addItem({label:'5.5'});
				addItem({label:'6.0'});
				addItem({label:'6.5'});
				addItem({label:'7.0'});
				addItem({label:'7.5'});
				addItem({label:'8.0'});
				addItem({label:'8.5'});
				addItem({label:'9.0'});
			}
			with(calculatorFields.speakingQ) {
				addItem({label:'4.0'});
				addItem({label:'4.5'});
				addItem({label:'5.0'});
				addItem({label:'5.5'});
				addItem({label:'6.0'});
				addItem({label:'6.5'});
				addItem({label:'7.0'});
				addItem({label:'7.5'});
				addItem({label:'8.0'});
				addItem({label:'8.5'});
				addItem({label:'9.0'});
			}
			calculatorFields.preReading_ltl.text = this.literals.getLiteral('preReading');
			calculatorFields.preListening_ltl.text = this.literals.getLiteral('preListening');
			calculatorFields.preWriting_ltl.text = this.literals.getLiteral('preWriting');
			calculatorFields.preSpeaking_ltl.text = this.literals.getLiteral('preSpeaking');
			
			calculatorFields.actionBtn.label =  this.literals.getLiteral('btnCalculate');
			resultFields.actionBtn.label =  this.literals.getLiteral('btnTryAgain');
			replaceObj = {newline:'\n'};
			//if (BCWebsite) {
			if (websiteWantsBCLogo) {
				resultFields.moreInfoBtn.label =  this.literals.getLiteral('btnRegister', replaceObj);
			} else {
				resultFields.moreInfoBtn.label =  this.literals.getLiteral('btnMoreInfo', replaceObj);
			}
			// We need to know if the passed country exists, if not switch to Global
			var countryLiteral:String = 'register' + websiteCountry;
			if (!this.literals.literalExists(countryLiteral)) {
				TraceUtils.myTrace(countryLiteral + " not there so go global");
				websiteCountry = 'Global';
			}
			//resultFields.moreinfo_txt.htmlText =  this.literals.getLiteral('moreInfo');
			disclaimer.disclaimer_txt.htmlText =  this.literals.getLiteral('disclaimerFull');
			// Vertically centre the title now that you have the text
			var titleY:uint = this.header.height + (headerVerticalPadding * 2);
			//TraceUtils.myTrace("title text height=" + title_txt.height + " box height=" + titleHeight)
			title_txt.y = titleY + (titleHeight - title_txt.height)/2;
		}
		
		private function onRestart(e:MouseEvent):void {
			//this.calculatorFields.status_txt.text = "Type new numbers";
			this.calculatorFields.status_txt.text =  this.literals.getLiteral('statusRestart');
			this.calculatorFields.visible = true;
			this.resultFields.visible = false;
			this.disclaimer.visible = false;
		}
		private function resetTitle(e:MouseEvent):void {
			title_txt.y = originalTitleTextY;
			title_txt.defaultTextFormat = titleTF;
			var replaceObj:Object = {newline:'\n'};
			title_txt.text = this.literals.getLiteral('applicationName', replaceObj);
		}
		
		private function onDisclaimer(e:MouseEvent) {
			//TraceUtils.myTrace("mouse over disclaimer");
			this.disclaimer.visible = true;
		}
		private function offDisclaimer(e:MouseEvent) {
			//TraceUtils.myTrace("mouse over disclaimer");
			this.disclaimer.visible = false;
		}
		private function onMoreInfo(e:MouseEvent) {
			//if (BCWebsite) {
			if (websiteWantsBCLogo) {
				var countryTargetURL:String = this.literals.getLiteral('register' + websiteCountry);
			} else {
				countryTargetURL = this.literals.getLiteral('moreInfo' + websiteCountry);
			}
			TraceUtils.myTrace("countryTargetURL=" + countryTargetURL);
			//var replaceObj:Object = {targetURL: countryTargetURL};
			//var url:String = this.literals.getLiteral('moreInfoURL', replaceObj);
			var url:String = countryTargetURL;
			var request:URLRequest = new URLRequest(url);
			try {
				navigateToURL(request, '_blank'); // second argument is target
			} catch (e:Error) {
				trace("Error occurred!");
			}
		}
		
		private function onCalculate(e:MouseEvent) {

			TraceUtils.myTrace("you clicked");
			var errorStyle:TextFormat = new TextFormat();
			errorStyle.color = 0xFF0000;
			errorStyle.font = "Helvetica";
			errorStyle.size = 12;
			var normalStyle:TextFormat = new TextFormat();
			normalStyle.color = 0x000000;
			normalStyle.font = "Helvetica";
			normalStyle.size = 12;
			var formHasError:Boolean = false;
			
			// Pick up the numbers typed. Check validity and then do the band score calculation.
			var listeningBand:Number = parseFloat(calculatorFields.listeningQ.selectedItem.label);
			var readingBand:Number = parseFloat(calculatorFields.readingQ.selectedItem.label);
			var writingBand:Number = parseFloat(calculatorFields.writingQ.selectedItem.label);
			var speakingBand:Number = parseFloat(calculatorFields.speakingQ.selectedItem.label);
				
			// Then average to get band score
			var bandScoreNumber:Number = (readingBand + listeningBand + writingBand + speakingBand) / 4;
			TraceUtils.myTrace("bandScoreNumber=" + bandScoreNumber.toString());
			// First round to nearest .5 (multiply by 2, round, then halve)
			bandScoreNumber = Math.round(2 * bandScoreNumber) / 2;
			TraceUtils.myTrace("bandScoreNumber=" + bandScoreNumber.toString());
			// Then format with one decimal point
			var bandScore:String = bandScoreNumber.toFixed(1);
			TraceUtils.myTrace("band score is " + bandScore);
			
			// Create the descriptor
			//this.resultFields.descriptor_txt.text = "If you are right you will score " + bandScore + " in the reading and listening sections of the test.";
			var replaceObj:Object = {bandScore: bandScore};
			this.resultFields.descriptor_txt.htmlText = this.literals.getLiteral('bandScoreDescriptor', replaceObj);
			
			// Work out the destination of the more info/action link based on the country
			//TraceUtils.myTrace("country=" + websiteCountry);
			//var countryTargetURL:String = this.literals.getLiteral('moreInfo' + websiteCountry);
			//TraceUtils.myTrace("countryTargetURL=" + countryTargetURL);
			//replaceObj = {targetURL: countryTargetURL};
			//this.resultFields.moreinfo_txt.htmlText = this.literals.getLiteral('moreInfo', replaceObj);
			this.resultFields.disclaimer_txt.htmlText = this.literals.getLiteral('disclaimer');
			
			// Switch screens
			this.calculatorFields.visible = false;
			this.resultFields.visible = true;
			this.disclaimer.visible = false;
			
			if (websiteReferrer!="") {
				TraceUtils.myTrace("log to " + websiteReferrer);
				// Since you are running on many domains, this must be a full URL
				//var url:String = "http://www.ClarityEnglish/Software/Common/lib/php/writeLog.php";
				//var url:String = "http://dock.fixbench/Software/Common/lib/php/writeLog.php";
				var url:String = "http://p1.ClarityEnglish.com/Software/Common/lib/php/writeLog.php";
				var request:URLRequest = new URLRequest(url);
				var variables:URLVariables = new URLVariables();
				variables.referrer = websiteReferrer;
				//variables.thisWidget = thisWidget;
				variables.thisWidget = this.literals.getLiteral('shortName');
				variables.stageWidth = this.stage.stageWidth;
				variables.referrer = websiteReferrer;
				request.data = variables;
				request.method = URLRequestMethod.POST;
				var urlLoader:URLLoader = new URLLoader();
				try {
					//navigateToURL(request);
					urlLoader.load(request);
				} catch (e:Error) {
					TraceUtils.myTrace("Couldn't log this widget use.");
				}
				
			} else {
				TraceUtils.myTrace("don't log as we don't know referrer");
			}
		}
	}

}