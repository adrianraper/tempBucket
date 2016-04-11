package com.clarityenglish.ielts.view.home {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.home.ui.CourseBarRenderer;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.controls.SWFLoader;
	import mx.formatters.DateFormatter;
	
	import org.davekeen.util.DateUtil;
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import skins.ielts.home.CourseButtonSkin;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.utils.TextFlowUtil;
	
	public class HomeView extends BentoView {
		
		[SkinPart(required="true")]
		public var readingCourseButton:Button;
		
		[SkinPart(required="true")]
		public var writingCourseButton:Button;
		
		[SkinPart(required="true")]
		public var speakingCourseButton:Button;
		
		[SkinPart(required="true")]
		public var listeningCourseButton:Button;
		
		[SkinPart]
		public var registerInfoButton:Button;
		
		[SkinPart]
		public var examTipsCourseButton:Button;
		
		[SkinPart]
		public var noProgressText:Label;
		
		[SkinPart]
		public var colorBarIntroLabel:Label;

		[SkinPart(required="true")]
		public var readingCoverageBar:CourseBarRenderer;
		
		[SkinPart(required="true")]
		public var listeningCoverageBar:CourseBarRenderer;
		
		[SkinPart(required="true")]
		public var speakingCoverageBar:CourseBarRenderer;
		
		[SkinPart(required="true")]
		public var writingCoverageBar:CourseBarRenderer;
		
		[SkinPart(required="true")]
		public var welcomeLabel:Label;
	
		[SkinPart(required="true")]
		public var noticeLabel:Label;
		
		// gh#383
		[SkinPart]
		public var findMoreButton:Button;
		
		[SkinPart]
		public var promoteWording1:Label;
		
		[SkinPart]
		public var promoteWording2:Label;
		
		[SkinPart]
		public var promoteWording3:Label;
		
		[SkinPart]
		public var promoteWording4:Label;
		
		[SkinPart]
		public var longRateButton:Button;

		[SkinPart]
		public var studyPlannerCaptionLabel:Label;

		[SkinPart]
		public var studyPalnnerDescriptionLabel:Label;

		[SkinPart]
		public var studyPlannerDownloadButton:Button;
		
		[Bindable]
		public var dataProvider:XML;
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var dateFormatter:DateFormatter;
		
		private var _accountName:String;
		
		[Bindable]
		public var noProgressData:Boolean;
		
		public var courseSelect:Signal = new Signal(XML);
		public var info:Signal = new Signal();
		// gh#383
		public var findMore:Signal = new Signal();
		
		private var _isPlatformTablet:Boolean;
		private var _isPlatformipad:Boolean;
		private var _isPlatformAndroid:Boolean;
		
		[Bindable]
		public function get isPlatformTablet():Boolean {
			return _isPlatformTablet;
		}
		
		public function set isPlatformTablet(value:Boolean):void {
			_isPlatformTablet = value;
		}
		
		[Bindable]
		public function get isPlatformipad():Boolean {
			return _isPlatformipad;
		}
		
		public function set isPlatformipad(value:Boolean):void {
			_isPlatformipad = value;
		}
		
		[Bindable]
		public function get isPlatformAndroid():Boolean {
			return _isPlatformAndroid;
		}
		
		public function set isPlatformAndroid(value:Boolean):void {
			_isPlatformAndroid = value;
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// #338 You might need to hide some courses. The courses could be a list in the skin
			// with an item renderer to do each one - but so much of the skins is tied up with these 4 courses
			// that you might as well just hardcode it here too.
			// BUG. Neither of the following contains the changes I made to bentoProxy.menuXHTML earlier
			// for each (var course:XML in _xhtml.head.script.(@id == "model" && @type == "application/xml").menu[0].course) {
			for each (var course:XML in menu.course) {
				switch (course.@["class"].toString()) {
					case "reading":
						if (readingCourseButton) readingCourseButton.enabled = !(course.attribute("enabledFlag").length() > 0 && (Number(course.@enabledFlag.toString()) & 8));
						break;
					case "listening":
						if (listeningCourseButton) listeningCourseButton.enabled = !(course.attribute("enabledFlag").length() > 0 && (Number(course.@enabledFlag.toString()) & 8));
						break;
					case "speaking":
						if (speakingCourseButton) speakingCourseButton.enabled = !(course.attribute("enabledFlag").length() > 0 && (Number(course.@enabledFlag.toString()) & 8));
						break;
					case "writing":
						if (writingCourseButton) writingCourseButton.enabled = !(course.attribute("enabledFlag").length() > 0 && (Number(course.@enabledFlag.toString()) & 8));
						break;
				}
			}
		}
		
		protected override function onViewCreationComplete():void {
			super.onViewCreationComplete();
			
			if (readingCourseButton) readingCourseButton.label = copyProvider.getCopyForId("Reading");
			if (writingCourseButton) writingCourseButton.label = copyProvider.getCopyForId("Writing");
			if (speakingCourseButton) speakingCourseButton.label = copyProvider.getCopyForId("Speaking");
			if (listeningCourseButton) listeningCourseButton.label = copyProvider.getCopyForId("Listening");
			
			if (registerInfoButton) registerInfoButton.label = copyProvider.getCopyForId("registerInfoButton");
			
			if (readingCoverageBar) readingCoverageBar.courseCaption = copyProvider.getCopyForId("Reading");
			if (writingCoverageBar) writingCoverageBar.courseCaption = copyProvider.getCopyForId("Writing");
			if (speakingCoverageBar) speakingCoverageBar.courseCaption = copyProvider.getCopyForId("Speaking");
			if (listeningCoverageBar) listeningCoverageBar.courseCaption = copyProvider.getCopyForId("Listening");
			
			if (noProgressText) noProgressText.text = copyProvider.getCopyForId("noProgressText");
			if (colorBarIntroLabel) colorBarIntroLabel.text = copyProvider.getCopyForId("colorBarIntroLabel");

			// gh#100 CT
			if (welcomeLabel) {
				if ((licenceType == Title.LICENCE_TYPE_AA) || 
					((licenceType == Title.LICENCE_TYPE_NETWORK) && (Number(user.id) < 1)) ||
					((licenceType == Title.LICENCE_TYPE_CT) && (Number(user.id) < 1))) {
					if (productVersion == BentoApplication.DEMO) {
						welcomeLabel.text = copyProvider.getCopyForId("demoWelcomeLabel");
					} else {
						welcomeLabel.text = "";
					}
				} else {
					welcomeLabel.text = copyProvider.getCopyForId("welcomeLabel" , { fullname:user.fullName });					
				}
			}
			
			if (noticeLabel) {
				// TODO. Network licence doesn't want the note about test date, but CT licence does
				if ((licenceType == Title.LICENCE_TYPE_AA) || 
					((licenceType == Title.LICENCE_TYPE_NETWORK) && (Number(user.id) < 1)) ||
					((licenceType == Title.LICENCE_TYPE_CT) && (Number(user.id) < 1))) {
					noticeLabel.text = "Licenced to " + accountName + ".";
				} else {
					if (user.examDate) {
						var daysLeft:Number = DateUtil.dateDiff(new Date(), user.examDate, "d");
						
						var daysUnit:String = (daysLeft == 1) ? copyProvider.getCopyForId("day") : copyProvider.getCopyForId("days");
						if (daysLeft > 0) {
							noticeLabel.text = copyProvider.getCopyForId("leftTestDate1") + " " + daysLeft.toString() + " " + daysUnit + " " + copyProvider.getCopyForId("leftTestDate2");
						} else if (daysLeft == 0) {
							noticeLabel.text = copyProvider.getCopyForId("goodLuck");
						} else {
							noticeLabel.text = copyProvider.getCopyForId("hopeTestWell");;
						}
					} else {
						noticeLabel.text = copyProvider.getCopyForId("confirmTestDate");
					}
				}
			}
			
			// for update the skin sate in skin
			this.invalidateSkinState();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case readingCourseButton:
				case writingCourseButton:
				case speakingCourseButton:
				case listeningCourseButton:
				case examTipsCourseButton:
					instance.addEventListener(MouseEvent.CLICK, onCourseClick);
					break;
				case registerInfoButton:
					instance.addEventListener(MouseEvent.CLICK, onRequestInfoClick);
					break;
				case readingCoverageBar:
				case listeningCoverageBar:
				case speakingCoverageBar:
				case writingCoverageBar:
					instance.copyProvider = copyProvider;
					break;
				// gh#383
				case findMoreButton:
					findMoreButton.addEventListener(MouseEvent.CLICK, onFindMoreClicked);
					break;
				case promoteWording1:
					promoteWording1.text = copyProvider.getCopyForId("promoteWording1");
					break;
				case promoteWording2:
					promoteWording2.text = copyProvider.getCopyForId("promoteWording2");
					break;
				case promoteWording3:
					promoteWording3.text = copyProvider.getCopyForId("promoteWording3");
					break;
				case promoteWording4:
					promoteWording4.text = copyProvider.getCopyForId("promoteWording4");
					break;
				case longRateButton:
					longRateButton.label = copyProvider.getCopyForId("longRateButton");
					longRateButton.addEventListener(MouseEvent.CLICK, onLongRateButtonClick);
					break;
				case studyPlannerDownloadButton:
					studyPlannerDownloadButton.label = copyProvider.getCopyForId("studyPlannerDownloadButton");
					studyPlannerDownloadButton.addEventListener(MouseEvent.CLICK, onStudyPlannerDownloadButtonClick);
					break;
				case studyPalnnerDescriptionLabel:
					studyPalnnerDescriptionLabel.text = copyProvider.getCopyForId("studyPalnnerDescriptionLabel");
					break;
				case studyPlannerCaptionLabel:
					studyPlannerCaptionLabel.text = copyProvider.getCopyForId("studyPlannerCaptionLabel");
					break;
			}
		}
				
		// gh#11 Language Code, read pictures from the folder base on the LanguageCode you set
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
		}
		
		public function get accountName():String {
			return _accountName;
		}
		
		public function set accountName(value:String):void {
			_accountName = value;
		}
		
		// #299
		public function isFullVersion():Boolean {
			return (productVersion == IELTSApplication.FULL_VERSION);
		}
		
		public function isDemo():Boolean {
			return (productVersion == BentoApplication.DEMO);
		}
		
		protected override function getCurrentSkinState():String {
			switch (productVersion) {
				case BentoApplication.DEMO:
					return "demo";
				case IELTSApplication.TEST_DRIVE:
					return "testDrive";
				case IELTSApplication.FULL_VERSION:
					return "fullVersion";
				case IELTSApplication.LAST_MINUTE:
					return "lastMinute";
				case IELTSApplication.HOME_USER:
					return "homeUser";
				default:
					return super.getCurrentSkinState();
			}
		}
		
		/**
		 * The user has clicked a course button
		 * 
		 * @param event
		 */
		protected function onCourseClick(event:MouseEvent):void {
			var matchingCourses:XMLList = menu.course.(@["class"] == event.target.getStyle("title").toLowerCase());
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a course with class {0}", event.target.getStyle("title").toLowerCase());
			} else {
				courseSelect.dispatch(matchingCourses[0] as XML);
			}
		} 
		
		private function onRequestInfoClick(event:MouseEvent):void {
			info.dispatch();
		}
		
		// gh#383
		protected function onFindMoreClicked(event:MouseEvent):void {
			findMore.dispatch();
		}
		
		protected function onLongRateButtonClick(event:MouseEvent):void {
			var urlString:String;			
			if (this.isPlatformipad) {
				urlString = copyProvider.getCopyForId("ipadRateLink");
			} else if (this.isPlatformAndroid) {
				urlString = copyProvider.getCopyForId("androidRateLink");
			}
			
			var urlRequest:URLRequest = new URLRequest(urlString);
			navigateToURL(urlRequest, "_blank");
		}

		protected function onStudyPlannerDownloadButtonClick(event:MouseEvent):void {
			var url:String = copyProvider.getCopyForId("studyPlannerDownloadLink");
			navigateToURL(new URLRequest(url), "_blank");
		}

	}
}