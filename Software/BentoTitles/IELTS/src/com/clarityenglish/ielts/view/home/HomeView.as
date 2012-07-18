package com.clarityenglish.ielts.view.home {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.home.ui.CourseBarRenderer;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import mx.formatters.DateFormatter;
	
	import org.davekeen.util.DateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	
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
		
		[Bindable]
		public var dataProvider:XML;
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var dateFormatter:DateFormatter;
		
		private var _productVersion:String;
		private var _productCode:uint;
		private var _licenceType:uint;
		private var _accountName:String;
		
		[Bindable]
		public var noProgressData:Boolean;
		
		public var courseSelect:Signal = new Signal(XML);
		public var info:Signal = new Signal();
		
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
						if (readingCourseButton) readingCourseButton.enabled = !(course.hasOwnProperty("@enabledFlag") && (Number(course.@enabledFlag.toString()) & 8));
						break;
					case "listening":
						if (listeningCourseButton) listeningCourseButton.enabled = !(course.hasOwnProperty("@enabledFlag") && (Number(course.@enabledFlag.toString()) & 8));
						break;
					case "speaking":
						if (speakingCourseButton) speakingCourseButton.enabled = !(course.hasOwnProperty("@enabledFlag") && (Number(course.@enabledFlag.toString()) & 8));
						break;
					case "writing":
						if (writingCourseButton) writingCourseButton.enabled = !(course.hasOwnProperty("@enabledFlag") && (Number(course.@enabledFlag.toString()) & 8));
						break;
				}
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			//trace("partAdded in HomeView for " + partName);
			switch (instance) {
				case readingCourseButton:
				case writingCourseButton:
				case speakingCourseButton:
				case listeningCourseButton:
				case examTipsCourseButton:
					instance.addEventListener(MouseEvent.CLICK, onCourseClick);
					break;
				
				case welcomeLabel:
					if ((licenceType == Title.LICENCE_TYPE_AA) || 
						((licenceType == Title.LICENCE_TYPE_NETWORK) && (Number(user.id) < 1))) {
						if (productVersion == IELTSApplication.DEMO) {
							instance.text = "Welcome to the Road to IELTS demo.";
						} else {
							instance.text = "";
						}
					} else {
						instance.text = "Welcome, " + user.fullName + ".";
					}
					break;
				
				case noticeLabel:
					// TODO. Network licence doesn't want the note about test date, but CT licence does
					if (licenceType == Title.LICENCE_TYPE_AA || 
						licenceType == Title.LICENCE_TYPE_NETWORK) {
						instance.text = "Licenced to " + accountName + ".";
						
					} else {
						if (user.examDate) {
							var daysLeft:Number = DateUtil.dateDiff(new Date(), user.examDate, "d");
							var daysUnit:String = (daysLeft == 1) ? "day" : "days";
							if (daysLeft > 0) {
								instance.text = "You have fewer than " + daysLeft.toString() + " " + daysUnit + " until your test.";
							} else if (daysLeft == 0) {
								instance.text = "Good luck with your test!";
							} else {
								instance.text = "Hope your test went well...";
							}
						} else {
							instance.text = "Please confirm your test date on the My Profile page."
						}
					}
					break;
				
				case registerInfoButton:
					instance.addEventListener(MouseEvent.CLICK, onRequestInfoClick);
					break;

			}
		}
		public function get assetFolder():String {
			return config.remoteDomain + '/Software/ResultsManager/web/resources/assets/';
		}
		
		public function set productVersion(value:String):void {
			_productVersion = value;
		}
		public function get productVersion():String {
			return _productVersion;
		}
		
		public function set productCode(value:uint):void {
			_productCode = value;
		}
		public function get productCode():uint {
			return _productCode;
		}
		
		public function set licenceType(value:uint):void {
			_licenceType = value;
		}
		public function get licenceType():uint {
			return _licenceType;
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
			return (productVersion == IELTSApplication.DEMO);
		}
		
		protected override function getCurrentSkinState():String {
			switch (productVersion) {
				case IELTSApplication.DEMO:
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

	}
}