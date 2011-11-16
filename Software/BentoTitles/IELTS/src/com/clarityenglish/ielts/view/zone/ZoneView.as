package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.view.zone.ui.ImageItemRenderer;
	import com.clarityenglish.ielts.view.zone.ui.PopoutExerciseSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	import mx.core.IDataRenderer;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.List;
	import spark.components.VideoPlayer;
	import spark.core.IDisplayText;
	import spark.events.IndexChangeEvent;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseTitleLabel:IDisplayText;
		
		[SkinPart(required="true")]
		public var courseDescriptionLabel:IDisplayText;
		
		[SkinPart(required="true")]
		public var questionZoneButton:Button;
		
		[SkinPart(required="true")]
		public var examPractice1Button:Button;
		
		[SkinPart(required="true")]
		public var examPractice1Difficulty:IDataRenderer;
		
		[SkinPart(required="true")]
		public var examPractice2Button:Button;
		
		[SkinPart(required="true")]
		public var examPractice2Difficulty:IDataRenderer;
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var popoutExerciseSelector:PopoutExerciseSelector;
		
		[SkinPart(required="true")]
		public var adviceZoneVideoPlayer:VideoPlayer;
		
		[SkinPart(required="true")]
		public var courseSelectorWidget:CourseSelectorWidget;
		
		[SkinPart]
		public var readingCourse:Button;
		
		[SkinPart]
		public var writingCourse:Button;
		
		[SkinPart]
		public var speakingCourse:Button;
		
		[SkinPart]
		public var listeningCourse:Button;
		
		[SkinPart]
		public var examTipsCourse:Button;		
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
		public var exerciseSelect:Signal = new Signal(Href);
		public var courseSelect:Signal = new Signal(XML);
		
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
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// All data is actually being used from course rather than this main document
		}

		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {
				courseTitleLabel.text = _course.@caption;
				courseDescriptionLabel.text = _course.@description;
				
				// class is a reserved keyword so have to use @["class"] instead of @class
				examPractice1Button.label = _course.unit.(@["class"] == "exam-practice").exercise[0].@caption;
				examPractice1Difficulty.data = _course.unit.(@["class"] == "exam-practice").exercise[0].@difficulty;
				examPractice2Button.label = _course.unit.(@["class"] == "exam-practice").exercise[1].@caption;
				examPractice2Difficulty.data = _course.unit.(@["class"] == "exam-practice").exercise[1].@difficulty;
				
				// Give groups as the dataprovider to the unit list
				unitList.dataProvider = new XMLListCollection(_course.groups.group);
				
				var adviceZoneVideoUrl:String = _course.unit.(@["class"] == "advice-zone").exercise[0].@href;
				adviceZoneVideoPlayer.source = href.createRelativeHref(null, adviceZoneVideoUrl).url;
				
				// Change the course selector
				courseSelectorWidget.setCourse(_course.@caption.toLowerCase());
				
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case unitList:
					unitList.addEventListener(IndexChangeEvent.CHANGE, function(e:IndexChangeEvent):void {
						var groupXML:XML = unitList.selectedItem;
						
						popoutExerciseSelector.group = groupXML;
						popoutExerciseSelector.exercises = _course..exercise.(hasOwnProperty("@group") && @group == groupXML.@id);
					} );
					break;
				case popoutExerciseSelector:
					popoutExerciseSelector.exerciseSelect = exerciseSelect;
					break;
				case questionZoneButton:
				case examPractice1Button:
				case examPractice2Button:
					instance.addEventListener(MouseEvent.CLICK, onExerciseClick);
					break;
				case courseSelectorWidget:
					courseSelectorWidget.addEventListener("writingSelected", onCourseSelectorClick);
					courseSelectorWidget.addEventListener("readingSelected", onCourseSelectorClick);
					courseSelectorWidget.addEventListener("listeningSelected", onCourseSelectorClick);
					courseSelectorWidget.addEventListener("speakingSelected", onCourseSelectorClick);
					break;
				// Fake buttons until course selector is ready
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
		 * The user has selected a course using the course selector widget
		 * 
		 * @param event
		 */
		protected function onCourseSelectorClick(event:Event):void {
			log.debug("Course selector event received - {0}", event.type);
			var matchingCourses:XMLList = menu.course.(@caption.toLowerCase() == event.type.toLowerCase());
			
			switch (event.type) {
				case "readingSelected":
					matchingCourses = menu.course.(@caption == "Reading");
					break;
				case "writingSelected":
					matchingCourses = menu.course.(@caption == "Writing");
					break;
				case "listeningSelected":
					matchingCourses = menu.course.(@caption == "Listening");
					break;
				case "speakingSelected":
					matchingCourses = menu.course.(@caption == "Speaking");
					break;
			}
			
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a matching course");
			} else {
				courseSelect.dispatch(matchingCourses[0] as XML);
			}
		}
		
		
		/**
		 * The user has selected an exercise
		 * 
		 * @param event
		 */
		protected function onExerciseClick(event:MouseEvent):void {
			// Get the appropriate href based on which button was pressed
			var hrefFilename:String;
			switch (event.target) {
				case questionZoneButton:
					hrefFilename = _course.unit.(@["class"] == "question-zone").exercise[0].@href;
					break;
				case examPractice1Button:
					hrefFilename = _course.unit.(@["class"] == "exam-practice").exercise[0].@href;
					break;
				case examPractice2Button:
					hrefFilename = _course.unit.(@["class"] == "exam-practice").exercise[1].@href;
					break;
			}
			
			// Fire the exerciseSelect signal
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, hrefFilename));
		}
		
		/**
		 * The user has clicked a course button in the course selector control
		 * 
		 * @param event
		 */
		protected function onCourseClick(event:MouseEvent):void {
			// Whilst we are using fake buttons
			var matchingCourses:XMLList = menu.course.(@caption == event.target.label);
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a course with caption {0}", event.target.label);
			} else {
				courseSelect.dispatch(matchingCourses[0] as XML);
			}
		}
		
	}
	
}