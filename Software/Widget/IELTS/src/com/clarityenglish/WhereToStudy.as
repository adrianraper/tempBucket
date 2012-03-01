package com.clarityenglish
{
	/**
	 * ...
	 * @author Adrian Raper
	 */
	import com.clarityenglish.utils.TraceUtils;
	import com.clarityenglish.utils.Literals;
	import com.clarityenglish.XMLDatabase;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.LoaderInfo;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import fl.events.ListEvent;
	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import fl.data.DataProvider;
	import fl.controls.List;
	import flash.net.*;
	
	public class WhereToStudy extends MovieClip
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
		var institutions:XMLDatabase;
		var titleTF:TextFormat;
		var detailsTF:TextFormat;
		var originalTitleTextY:uint;
		
		public function WhereToStudy() {
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
			thisWidget = 'WhereToStudy';
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
			this.widgetLayout(this.stage.stageWidth, this.stage.stageHeight);
			// Load the XML database now so you can search more quickly later, and even do type-ahead if possible
			
			this.institutions = new XMLDatabase('USInstitutions.xml', applicationRoot);
			
			// And we need to make the origin in the top left corner
			// If you publish the flash with width 160, changing that with the Flash options means that the
			// origin is NOT top left. How to sort that out? Quickest option is different swfs for different widths.
			// This code doesn't need to be different, just the fla document size.
			
			// set events for buttons clicks
			this.calculatorFields.actionBtn.addEventListener(MouseEvent.CLICK, onSearch);
			this.calculatorFields.search_txt.addEventListener(KeyboardEvent.KEY_DOWN, onEnter);
			this.resultFields.actionBtn.addEventListener(MouseEvent.CLICK, onRestart);
			this.resultFields.moreInfoBtn.addEventListener(MouseEvent.CLICK, onMoreInfo);
			//this.resultFields.descriptor_txt.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.resultFields.list_txt.addEventListener(ListEvent.ITEM_ROLL_OVER, showFullDetails);
			this.resultFields.list_txt.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, goToInstitution);
			//this.resultFields.list_txt.addEventListener(ListEvent.ITEM_CLICK, goToInstitution);
			this.resultFields.list_txt.addEventListener(flash.events.MouseEvent.MOUSE_OUT, resetTitle);
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
			calculatorFields.explanation_ltl.defaultTextFormat = textTF;
			//resultFields.action_txt.defaultTextFormat = textTF;
			
			// You can't use defaultTextFormat for htmlText - has to be a style sheet
			//resultFields.moreinfo_txt.defaultTextFormat = textTF;
			resultFields.descriptor_txt.defaultTextFormat = textTF;
			//resultFields.moreinfo_txt.defaultTextFormat = textTF;
			resultFields.disclaimer_txt.defaultTextFormat = textTF;
			resultFields.disclaimer_txt.addEventListener(MouseEvent.MOUSE_OVER, onDisclaimer);
			// You lose the field, so mouseOff that is no good.
			disclaimer.disclaimer_txt.addEventListener(MouseEvent.MOUSE_OUT, offDisclaimer);

			// Text format for the list box and search box (just to cure the cut-off W)
			//resultFields.list_txt.defaultTextFormat = textTF;
			var listTextFormat:TextFormat = new TextFormat();
			listTextFormat.font = "Helvetica";
			listTextFormat.color = "0xFF000000";
			listTextFormat.leftMargin = 0.6;
			resultFields.list_txt.setRendererStyle("textFormat", listTextFormat);
			calculatorFields.search_txt.setStyle("textFormat", listTextFormat);
			
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
			// If the vertical spacing is too much, push down the fields
			if (headerVerticalPadding>10) {
				calculatorFields.y+=(headerVerticalPadding/2);
				resultFields.y+=(headerVerticalPadding/2);
			}
			// make any fields wider?
			calculatorFields.explanation_ltl.width = width-(2*horizontalPadding);
			calculatorFields.search_txt.width = width-(2*horizontalPadding);
			calculatorFields.status_txt.width = width-(2*horizontalPadding);
			//resultFields.moreinfo_txt.width = width-(2*horizontalPadding);
			resultFields.list_txt.width = width-(2*horizontalPadding);
			resultFields.descriptor_txt.width = width-(2*horizontalPadding);
			resultFields.disclaimer_txt.width = width-(2*horizontalPadding);
			//resultFields.action_txt.width = width-(2*horizontalPadding);
			
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
			calculatorFields.explanation_ltl.text = this.literals.getLiteral('intro');
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
			//resultFields.action_txt.text =  this.literals.getLiteral('whatToDo');
			// Vertically centre the title now that you have the text
			var titleY:uint = this.header.height + (headerVerticalPadding * 2);
			//TraceUtils.myTrace("title text height=" + title_txt.height + " box height=" + titleHeight)
			title_txt.y = titleY + (titleHeight - title_txt.height)/2;
		}
		
		private function onRestart(e:MouseEvent):void {
			//this.calculatorFields.explanation_ltl.text = this.literals.getLiteral('explanation');
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
		
		private function onSearch(e:MouseEvent) {
			doSearch();
		}
		private function doSearch() {
			var searchString:String = this.calculatorFields.search_txt.text;
			TraceUtils.myTrace("search for " + searchString);
			
			var matchingInstitutions:XMLList = this.institutions.getInstitution(searchString);
			var results:String = new String();
			var link:String;
			var item:XML;
			var myDataProvider:DataProvider = new DataProvider();
			if(matchingInstitutions.length() == 0){
				//results += "<p>" + "Sorry, we don't search anything, please input institutions again ang check the spell" + "</p>";
				this.resultFields.descriptor_txt.text = this.literals.getLiteral('noResults');
				this.resultFields.descriptor_txt.visible = true;
				this.resultFields.list_txt.visible = false;
			}else{
				this.resultFields.descriptor_txt.visible = false;
				this.resultFields.list_txt.visible = true;
				// SInce we found at least one item, lets put a note about it in the first space
				myDataProvider.addItem({id:undefined, name:this.literals.getLiteral('whatToDo')});
				for each(item in matchingInstitutions){
					//results += item.name.toString() + "<br>";
					//link = "<a href=\"http://www.google.com/search?q=" + spaceToPlus(item.name.toString()) + " IELTS \">" + item.name.toString() + "</a>";
					//results += "<p><u>" + link + "</u></p>";
					// Add to a list item
					//myDataProvider.addItem({name:item.name.toString(), score:item.score, city:item.city, state:item.state});
					myDataProvider.addItem({id:item.id, name:item.name.toString(), state:item.state});
				}
				//this.resultFields.descriptor_txt.wordWrap = false;
				this.resultFields.list_txt.dataProvider = myDataProvider;
				this.resultFields.list_txt.labelFunction = institutionNiceName;
				// highlight the first (special) one
				this.resultFields.list_txt.selectedIndex=0;
			}
			
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
				var url:String = "http://www.ClarityEnglish.com/Software/Common/lib/php/writeLog.php";
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
		private function institutionNiceName(item:Object):String {
			//return item.score + "-" + item.name;
			return item.name;
		}
		private function showFullDetails(e:ListEvent):void {
			var list:List = e.target as List;
			var item:Object = e.item;
			//TraceUtils.myTrace("you are over " + list.itemToLabel(item));
			//var titleTF:TextFormat = new TextFormat();
			//titleTF.font = "Helvetica";
			//titleTF.color = "0xFFFFFFFF";
			//titleTF.size = 11;
			//titleTF.align = TextFormatAlign.CENTER;
			//titleTF.bold = false;
			title_txt.defaultTextFormat = detailsTF;
			// tidy up wording
			//if (item.score == undefined || item.score == 'undefined' || parseFloat(item.score) > 9 || parseFloat(item.score) < 3) {
			//	var itemScoreText:String = "unknown";
			//} else {
			//	itemScoreText = item.score.toString();
			//}
			//title_txt.text = "Minimum IELTS is " + itemScoreText + " at " + list.itemToLabel(item);
			// Special case
			if (item.id==undefined) {
				title_txt.text = this.literals.getLiteral('whatToDoFull');
			} else {
				title_txt.text = list.itemToLabel(item);
				// If the name is not too long, add state to it. But you can only really measure once you have added the state!
				title_txt.appendText(", " + item.state);
			}
			// So if there is no space left, go back to the stateless name
			//TraceUtils.myTrace("space left=" + (Number(titleHeight) - Number(title_txt.height)));
			if (titleHeight - title_txt.height<-4) {
				title_txt.text = list.itemToLabel(item);
			}
			// Centre it vertically
			title_txt.y = this.header.height + (headerVerticalPadding * 2) + (titleHeight - title_txt.height)/2;
		}

		private function goToInstitution(e:ListEvent):void {
			var list:List = e.target as List;
			var item:Object = e.item;
			if (item.id==undefined) return;
			TraceUtils.myTrace("go to " + list.itemToLabel(item));
			//var url:String = "http://www.google.com/search?q=" + spaceToPlus(item.name.toString()) + " IELTS";
			var url:String = "http://bandscore.ielts.org/course_info.aspx?OrgId=" + spaceToPlus(item.id.toString());
			var request:URLRequest = new URLRequest(url);
			try {
				navigateToURL(request, '_blank'); // second argument is target
			} catch (e:Error) {
				trace("Error occurred!");
			}

		}
		private function onEnter(event:KeyboardEvent){
			// if the key is ENTER
			if(event.charCode == 13){
				doSearch();
			}
		}
		
		private function onMouseOver(event:MouseEvent){
			
		}
		
		public function spaceToPlus(s:String) : String {
			s = s.replace("/ /", "+");
			return s;
		}
	}
}