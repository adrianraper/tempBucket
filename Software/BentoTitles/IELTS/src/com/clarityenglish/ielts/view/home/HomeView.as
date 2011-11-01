package com.clarityenglish.ielts.view.home {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Label;
	import spark.components.Button;
	import spark.components.TabBar;
	
	public class HomeView extends BentoView {

		[SkinPart(required="true")]
		public var userNameLabel:Label;

		[SkinPart(required="true")]
		public var readingCourse:Button;
		
		[SkinPart(required="true")]
		public var writingCourse:Button;
		
		[SkinPart(required="true")]
		public var speakingCourse:Button;
		
		[SkinPart(required="true")]
		public var listeningCourse:Button;
		
		[SkinPart(required="true")]
		public var examTipsCourse:Button;
		
		[Bindable]
		public var _user:User;
		
		public var courseSelect:Signal = new Signal(XML);
		
		public function set user(value:User):void {
			_user = value;
			// Also put some parts of this information into the skin
			//userNameLabel.text = _user.fullName;
		}
		
		// Just copied from ZoneView
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Populate the buttons with the course names
			//courseTabBar.dataProvider = new XMLListCollection(menu..course);
			
			// Get the coverage overview from the backside
			// This is probably a 'quick' call in usage stats mode rather than full progress
			
		}
		protected override function commitProperties():void {
			super.commitProperties();
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			//trace("partAdded in HomeView for " + partName);
			switch (instance) {
				case readingCourse:
				case writingCourse:
				case speakingCourse:
				case listeningCourse:
				case examTipsCourse:
					instance.addEventListener(MouseEvent.CLICK, onCourseClick);
					break;
			}
		}
		/**
		 * The user has clicked a course button
		 * 
		 * @param event
		 */
		protected function onCourseClick(event:MouseEvent):void {
			// Each button is a course, so get the id and send it as a signal
			switch (event.target) {
				case readingCourse:
					var id:Number = menu.course.(@caption == "Reading").@id;
					//var id:Number = menu.course.(@caption == event.target.caption).@id;
					break;
			}
			
			// Fire the courseSelect signal?
			// CourseSelect should display zone view and read menu.course(@id==id)
			// DK suggest sending the whole course node
			courseSelect.dispatch(course);
		}
	}
}