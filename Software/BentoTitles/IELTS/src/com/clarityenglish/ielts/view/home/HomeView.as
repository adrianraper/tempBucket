package com.clarityenglish.ielts.view.home {
	import com.anychart.AnyChartFlex;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.ielts.view.home.ui.CourseBarRenderer;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.formatters.DateFormatter;
	
	import org.davekeen.util.DateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TabBar;
	
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
		
		[Bindable]
		public var noProgressData:Boolean;
		
		public var courseSelect:Signal = new Signal(XML);
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// TODO: GO STRAIGHT TO THE READING COURSE SINCE I AM WORKING ON THE ZONE PAGE
			//if (Config.DEVELOPER.name == "AR") {
			//	readingCourse.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			//}
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
					instance.text="Welcome, " + user.fullName + ".";
					break;
				case noticeLabel:
					if (user.examDate) {
						var daysLeft:Number = DateUtil.dateDiff(new Date(), user.examDate, "d");
						var daysUnit:String = (daysLeft==1) ? "day" : "days";
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
					break;
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
	}
}