package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.title.InforButton;
	import com.clarityenglish.ielts.view.zone.courseselector.CourseSelector;
import com.clarityenglish.ielts.view.zone.ui.ZoneTabbedViewNavigator;
import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.core.ISelectableList;
	import mx.formatters.DateFormatter;
	
	import org.osflash.signals.Signal;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.NavigatorContent;
import spark.components.TabbedViewNavigator;
import spark.components.ViewNavigator;
	import spark.utils.TextFlowUtil;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseSelector:CourseSelector;
		
		[SkinPart(required="true")]
		public var sectionNavigator:ZoneTabbedViewNavigator;
		
		[SkinPart(required="true")]
		public var questionZoneViewNavigator:ViewNavigator;
		
		[SkinPart(required="true")]
		public var adviceZoneViewNavigator:ViewNavigator;
		
		[SkinPart(required="true")]
		public var practiceZoneViewNavigator:ViewNavigator;
		
		[SkinPart(required="true")]
		public var testZoneViewNavigator:ViewNavigator;
		
		[SkinPart]
		public var shortRateButton:Button;
		
		[SkinPart]
		public var longRateButton:Button;
		
		[SkinPart]
		public var bottomInforButton:InforButton;
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var dateFormatter:DateFormatter;
		
		[Bindable]
		public var inforButtonTextFlow:TextFlow;

		// #486
		private static var lastSelectedSectionIdx:int = -1
		
		/**
		 * ZoneView specifically needs to know if it is mediated or not in order to implement #222.  This is not necessary for most views.
		 * gh#278 TitleView can no longer get at ZoneView (is this true?) so can't use this flag.
		 */
		public var isMediated:Boolean;
		
		private var _courseChanged:Boolean;
		private var _course:XML;
		private var _isPlatformTablet:Boolean;
		private var _isPlatformipad:Boolean;
		private var _isPlatformAndroid:Boolean;
		// gh#761
		private var _isCourseDirectLink:Boolean;
		private var _isDirectLinkStart:Boolean;
		
		// This is just horrible, but there is no easy way to get the current course into ZoneAccordianButtonBarSkin without this.
		// NOTHING ELSE SHOULD USE THIS VARIABLE!!!
		[Bindable]
		public static var horribleHackCourseClass:String;
		
		public var courseSelect:Signal = new Signal(XML);
		public var videoSelected:Signal = new Signal(Href, String);
		public var videoPlayerStateChange:Signal = new Signal(MediaPlayerStateChangeEvent);

		public var register:Signal = new Signal();
		public var upgrade:Signal = new Signal();
		public var buy:Signal = new Signal();

		/**
		 * This can be called from outside the view to make the view display a different course
		 * 
		 * @param XML A course node from the menu
		 * 
		 */
		public function set course(value:XML):void {
			_course = value;
			_courseChanged = true;
			
			horribleHackCourseClass = (_course) ? _course.@["class"].toString() : null;
			
			invalidateProperties();
			invalidateSkinState();
			
			dispatchEvent(new Event("courseChanged", true));
		}
		
		[Bindable(event="courseChanged")]
		public function get course():XML {
			return _course;
		}
		
		/**
		 * This is another way to do the same thing
		 */
		public override function set data(value:Object):void {
			super.data = value;	
			course = data as XML;
		}
		
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
		
		public function setSelectorInforButtonVisible(value:Boolean):void {
			courseSelector.visible = value;
			if (bottomInforButton)
				bottomInforButton.visible = value;
		}

		// gh#761
		[Bindable]
		public function get isCourseDirectLink():Boolean {
			return _isCourseDirectLink;
		}
		
		public function set isCourseDirectLink(value:Boolean):void {
			_isCourseDirectLink = value;
		}
		
		[Bindalbe]
		public function get isDirectLinkStart():Boolean {
			return _isDirectLinkStart;
		}
		
		public function set isDirectLinkStart(value:Boolean):void {
			_isDirectLinkStart = value;
		}
		
		// gh#761
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);

			for each (var menuCourse:XML in menu.course) {
				switch (menuCourse.@["class"].toString()) {
					case "reading":
						if (courseSelector.reading) courseSelector.reading.enabled = !(menuCourse.attribute("enabledFlag").length() > 0 && (Number(menuCourse.@enabledFlag.toString()) & 8));
						break;
					case "listening":
						if (courseSelector.listening) courseSelector.listening.enabled = !(menuCourse.attribute("enabledFlag").length() > 0 && (Number(menuCourse.@enabledFlag.toString()) & 8));
						break;
					case "speaking":
						if (courseSelector.speaking) courseSelector.speaking.enabled = !(menuCourse.attribute("enabledFlag").length() > 0 && (Number(menuCourse.@enabledFlag.toString()) & 8));
						break;
					case "writing":
						if (courseSelector.writing) courseSelector.writing.enabled = !(menuCourse.attribute("enabledFlag").length() > 0 && (Number(menuCourse.@enabledFlag.toString()) & 8));
						break;
				}
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case courseSelector:
					courseSelector.addEventListener("writingSelected", onCourseSelectorClick, false, 0, true);
					courseSelector.addEventListener("readingSelected", onCourseSelectorClick, false, 0, true);
					courseSelector.addEventListener("listeningSelected", onCourseSelectorClick, false, 0, true);
					courseSelector.addEventListener("speakingSelected", onCourseSelectorClick, false, 0, true);
					break;
				case sectionNavigator:
					// #486
					sectionNavigator.addEventListener(Event.CHANGE, onSectionNavigatorChange, false, 0, true);
					if (lastSelectedSectionIdx >= 0) sectionNavigator.selectedIndex = lastSelectedSectionIdx;
					// If the course is reading and it is in test drive the first selected tab in zone is exam practice.
					if(productVersion == IELTSApplication.TEST_DRIVE && course.@['class'] == "reading")
                        sectionNavigator.selectedIndex = 3;
					break;
				case questionZoneViewNavigator:
					instance.label = copyProvider.getCopyForId("questionZoneViewNavigator");
					break;
				case adviceZoneViewNavigator:
					instance.label = copyProvider.getCopyForId("adviceZoneViewNavigator");
					break;
				case practiceZoneViewNavigator:
					instance.label = copyProvider.getCopyForId("practiceZoneViewNavigator");
					break;
				case testZoneViewNavigator:
					instance.label = copyProvider.getCopyForId("testZoneViewNavigator");
					break;
				case shortRateButton:
					shortRateButton.label = copyProvider.getCopyForId("shortRateButton");
					shortRateButton.addEventListener(MouseEvent.CLICK, onRateButtonClick);
					break;
				case longRateButton:
					longRateButton.label = copyProvider.getCopyForId("longRateButton");
					longRateButton.addEventListener(MouseEvent.CLICK, onRateButtonClick);
					break;
				case bottomInforButton:
					instance.addEventListener(MouseEvent.CLICK, onRequestInfoClick);
					break;
			}
		}
		
		protected override function getCurrentSkinState():String {
			var platform:String = isPlatformTablet? "tablet" : "browser";
			switch (productVersion) {
				case BentoApplication.DEMO:
					return "demo_" + platform;
				case IELTSApplication.TEST_DRIVE:
					return "testDrive_" + platform;
				case IELTSApplication.FULL_VERSION:
					return "fullVersion_" + platform;
				case IELTSApplication.LAST_MINUTE:
					return "lastMinute_" + platform;
				case IELTSApplication.HOME_USER:
					return "homeUser_" + platform;
				default:
					return super.getCurrentSkinState();
			}
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			// gh#761
			if (_courseChanged && isDirectLinkStart) {
				if (!isCourseDirectLink) {
					for each (var unit:XML in course.unit) {
						switch (unit.@['class'].toString()) {
							case "question-zone":
								if (questionZoneViewNavigator) questionZoneViewNavigator.enabled = !(unit.attribute("enabledFlag").length() > 0 && (Number(unit.@enabledFlag.toString()) & 8));
								// set the first selected view navigator for direct start
								if (questionZoneViewNavigator.enabled) sectionNavigator.selectedIndex = 0;
								break;
							case "advice-zone":
								if (adviceZoneViewNavigator) adviceZoneViewNavigator.enabled = !(unit.attribute("enabledFlag").length() > 0 && (Number(unit.@enabledFlag.toString()) & 8));
								if (adviceZoneViewNavigator.enabled) sectionNavigator.selectedIndex = 1;
								break;
							case "practice-zone":
								if (practiceZoneViewNavigator) practiceZoneViewNavigator.enabled = !(unit.attribute("enabledFlag").length() > 0 && (Number(unit.@enabledFlag.toString()) & 8));
								if (practiceZoneViewNavigator.enabled) sectionNavigator.selectedIndex = 2;
								break;
							case "exam-practice":
								if (testZoneViewNavigator) testZoneViewNavigator.enabled = !(unit.attribute("enabledFlag").length() > 0 && (Number(unit.@enabledFlag.toString()) & 8));	
								if (testZoneViewNavigator.enabled) sectionNavigator.selectedIndex = 3;
								break;
						}
					}
					
					/* gh#1475
					if (course.@["class"] == "speaking" && isDirectLinkStart) {
						if (testZoneViewNavigator) testZoneViewNavigator.enabled = false;
					}*/
				}
			}

			if (_courseChanged) {
				sectionNavigator.selectedColor = getStyle(course.@['class'] + "ColorDark");
			}
			inforButtonTextFlow = TextFlowUtil.importFromString(copyProvider.getCopyForId("infoReadingText"));
		}
		
		protected function onCourseSelectorClick(event:Event):void {
			log.debug("Course selector event received - {0}", event.type);
			var matchingCourses:XMLList = menu.course.(@caption.toLowerCase() == event.type.toLowerCase());
			
			switch (event.type) {
				case "readingSelected":
					matchingCourses = menu.course.(@["class"] == "reading");
					break;
				case "writingSelected":
					matchingCourses = menu.course.(@["class"] == "writing");
					break;
				case "listeningSelected":
					matchingCourses = menu.course.(@["class"] == "listening");
					break;
				case "speakingSelected":
					matchingCourses = menu.course.(@["class"] == "speaking");
					break;
			}
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a matching course");
			} else {
				courseSelect.dispatch(matchingCourses[0] as XML);
			}
		}
		
		protected function onSectionNavigatorChange(event:Event):void {
			// #486
			lastSelectedSectionIdx = event.target.selectedIndex;
		}
		
		protected function onRateButtonClick(event:MouseEvent):void {
			var urlString:String;			
			if (this.isPlatformipad) {
				urlString = copyProvider.getCopyForId("ipadRateLink");
			} else if (this.isPlatformAndroid) {
				urlString = copyProvider.getCopyForId("androidRateLink");
			}
			
			var urlRequest:URLRequest = new URLRequest(urlString);
			navigateToURL(urlRequest, "_blank");
		}

		// #337
		private function onRequestInfoClick(event:MouseEvent):void {
			//upgrade.dispatch();
			var url:String = copyProvider.getCopyForId("TDBottomBlueBannerLink");
			navigateToURL(new URLRequest(url), "_blank");
		}
	}
	
}