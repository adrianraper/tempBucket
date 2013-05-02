package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.zone.courseselector.CourseSelector;
	
	import flash.events.Event;
	
	import mx.core.ISelectableList;
	import mx.formatters.DateFormatter;
	
	import org.osflash.signals.Signal;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	import spark.components.Label;
	import spark.components.NavigatorContent;
	import spark.components.ViewNavigator;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseSelector:CourseSelector;
		
		[SkinPart(required="true")]
		public var sectionNavigator:ISelectableList;
		
		[SkinPart(required="true")]
		public var questionZoneViewNavigator:ViewNavigator;
		
		[SkinPart(required="true")]
		public var adviceZoneViewNavigator:ViewNavigator;
		
		[SkinPart(required="true")]
		public var practiceZoneViewNavigator:ViewNavigator;
		
		[SkinPart(required="true")]
		public var testZoneViewNavigator:ViewNavigator;
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var dateFormatter:DateFormatter;
		
		// #486
		private static var lastSelectedSectionIdx:int = -1
		
		/**
		 * ZoneView specifically needs to know if it is mediated or not in order to implement #222.  This is not necessary for most views.
		 * gh#278 TitleView can no longer get at ZoneView (is this true?) so can't use this flag.
		 */
		public var isMediated:Boolean;
		
		private var _courseChanged:Boolean;
		private var _course:XML;
		
		// This is just horrible, but there is no easy way to get the current course into ZoneAccordianButtonBarSkin without this.
		// NOTHING ELSE SHOULD USE THIS VARIABLE!!!
		[Bindable]
		public static var horribleHackCourseClass:String;
		
		public var courseSelect:Signal = new Signal(XML);
		public var videoSelected:Signal = new Signal(Href, String);
		public var videoPlayerStateChange:Signal = new Signal(MediaPlayerStateChangeEvent);
		
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
		
		public function setCourseSelectorVisible(value:Boolean):void {
			courseSelector.visible = value;
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
			}
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
		
	}
	
}