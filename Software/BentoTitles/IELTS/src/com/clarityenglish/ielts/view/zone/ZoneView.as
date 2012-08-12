package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.IELTSApplication;
	import com.clarityenglish.ielts.view.home.HomeView;
	
	import flash.events.Event;
	
	import mx.formatters.DateFormatter;
	
	import org.osflash.signals.Signal;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseSelector:CourseSelector;
		
		[Bindable]
		public var user:User;
		
		[Bindable]
		public var dateFormatter:DateFormatter;
		
		/**
		 * ZoneView specifically needs to know if it is mediated or not in order to implement #222.  This is not necessary for most views.
		 */
		public var isMediated:Boolean;
		
		private var _courseChanged:Boolean;
		private var _course:XML;
		
		// This is just horrible, but there is no easy way to get the current course into ZoneAccordianButtonBarSkin without this.
		// NOTHING ELSE SHOULD USE THIS VARIABLE!!!
		[Bindable]
		public static var horribleHackCourseClass:String;
		
		public var exerciseSelect:Signal = new Signal(Href);
		public var courseSelect:Signal = new Signal(XML);
		public var videoSelected:Signal = new Signal(Href, String);
		public var videoPlayerStateChange:Signal = new Signal(MediaPlayerStateChangeEvent);
		
		// #299
		public function isFullVersion():Boolean {
			return (productVersion == IELTSApplication.FULL_VERSION);
		}
		
		public function isDemo():Boolean {
			return (productVersion == IELTSApplication.DEMO);
		}
		
		/**
		 * This can be called from outside the view to make the view display a different course
		 * 
		 * @param XML A course node from the menu
		 * 
		 */
		public function set course(value:XML):void {
			_course = value;
			_courseChanged = true;
			
			invalidateProperties();
			invalidateSkinState();
			
			dispatchEvent(new Event("courseChanged", true));
			
			horribleHackCourseClass = courseClass;
		}
		
		[Bindable(event="courseChanged")]
		public function get course():XML {
			// TODO: In the long run we might not need this - its just so I can set it in firstViewData for the moment
			return _course;
		}
		
		/**
		 * This is another way to do the same thing
		 */
		public override function set data(value:Object):void {
			super.data = value;	
			course = data as XML;
		}
		
		[Bindable(event="courseChanged")]
		public function get courseClass():String {
			return (_course) ? _course.@["class"].toString() : null;
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
		
	}
	
}