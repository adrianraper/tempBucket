package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.bento.vo.content.Exercise;
	import com.clarityenglish.ielts.view.zone.ui.PopoutExerciseSelector;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.elements.BreakElement;
	
	import mx.collections.XMLListCollection;
	import mx.core.IDataRenderer;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.List;
	import spark.components.NavigatorContent;
	import spark.components.VideoPlayer;
	import spark.core.IDisplayText;
	import spark.events.IndexChangeEvent;
	
	import ws.tink.spark.containers.Accordion;
	
	public class ZoneView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseTitleLabel:IDisplayText;
		
		[SkinPart(required="true")]
		public var courseDescriptionLabel:IDisplayText;
		
		[SkinPart]
		public var accordian:Accordion;
		
		[SkinPart(required="true")]
		public var practiceZoneNavigatorContent:NavigatorContent;
		
		[SkinPart(required="true")]
		public var adviceZoneNavigatorContent:NavigatorContent;
		
		[SkinPart(required="true")]
		public var examPracticeNavigatorContent:NavigatorContent;
		
		[SkinPart(required="true")]
		public var questionZoneNavigatorContent:NavigatorContent;
		
		[SkinPart(required="true")]
		public var examPracticeDataGroup:DataGroup;
		
		[SkinPart(required="true")]
		public var questionZoneViewButton:Button;
		
		[SkinPart(required="true")]
		public var questionZoneDownloadButton:Button;
		
		[SkinPart(required="true")]
		public var unitList:List;
		
		[SkinPart(required="true")]
		public var popoutExerciseSelector:PopoutExerciseSelector;
		
		[SkinPart(required="true")]
		public var adviceZoneVideoPlayer:VideoPlayer;
		
		[SkinPart(required="true")]
		public var adviceZoneVideoList:List;
		
		[SkinPart(required="true")]
		public var courseSelectorWidget:CourseSelectorWidget;
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
		private var _exerciseSelectorPoppedOut:Boolean;
		
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
			invalidateSkinState();
			
			dispatchEvent(new Event("courseChanged"));
		}
		
		[Bindable(event="courseChanged")]
		public function get courseClass():String {
			return _course.@["class"].toString();
		}
		
		[Bindable(event="courseChanged")]
		public function hasUnit(unitClass:String):Boolean {
			return (_course) ? _course.unit.(@["class"] == unitClass).length() > 0 : false;
		}
		
		public function set exerciseSelectorPoppedOut(value:Object):void {
			_exerciseSelectorPoppedOut = value;
			
			invalidateSkinState();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {
				courseTitleLabel.text = _course.@caption;
				courseDescriptionLabel.text = _course.@description;
				
				// Only display units with content in the XML - #51 - but this isn't working with Tink's Accordian right now
				/*practiceZoneNavigatorContent.visible = practiceZoneNavigatorContent.includeInLayout = hasUnit("practice-zone");
				adviceZoneNavigatorContent.visible = adviceZoneNavigatorContent.includeInLayout = hasUnit("advice-zone");
				examPracticeNavigatorContent.visible = examPracticeNavigatorContent.includeInLayout = hasUnit("exam-practice");
				questionZoneNavigatorContent.visible = questionZoneNavigatorContent.includeInLayout = hasUnit("question-zone");*/
				
				// Give groups as the dataprovider to the unit list
				unitList.dataProvider = new XMLListCollection(_course.groups.group);
				
				// Give the advice zone videos as a dataprovider to the advice zone video list
				adviceZoneVideoList.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "advice-zone").exercise);
				
				// Give the exam practice exercises as a dataprovider to the exam practice data group
				examPracticeDataGroup.dataProvider = new XMLListCollection(_course.unit.(@["class"] == "exam-practice").exercise);
				
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
						
						// Build up a list of exercises we can show (includes disabled ones)
						var exercises:XMLList = new XMLList();
						for each (var exerciseNode:XML in _course..exercise.(hasOwnProperty("@group") && @group == groupXML.@id))
							if (Exercise.showExerciseInMenu(exerciseNode)) {
								//trace("show " + exerciseNode.@caption + " in menu");
								exercises += exerciseNode;
							//} else {
								//trace("block " + exerciseNode.@caption + " from menu");
							}
						
						popoutExerciseSelector.exercises = exercises;
					} );
					break;
				case popoutExerciseSelector:
				case examPracticeDataGroup:
					instance.addEventListener(ExerciseEvent.EXERCISE_SELECTED, onExerciseSelected);
					break;
				case questionZoneViewButton:
					questionZoneViewButton.addEventListener(MouseEvent.CLICK, onQuestionZoneViewButtonClick);
					break;
				case questionZoneDownloadButton:
					questionZoneDownloadButton.addEventListener(MouseEvent.CLICK, onQuestionZoneDownloadButtonClick);
					break;
				case courseSelectorWidget:
					courseSelectorWidget.addEventListener("writingSelected", onCourseSelectorClick, false, 0, true);
					courseSelectorWidget.addEventListener("readingSelected", onCourseSelectorClick, false, 0, true);
					courseSelectorWidget.addEventListener("listeningSelected", onCourseSelectorClick, false, 0, true);
					courseSelectorWidget.addEventListener("speakingSelected", onCourseSelectorClick, false, 0, true);
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
		
		/**
		 * The user has selected an exercise
		 * 
		 * @param event
		 */
		protected function onExerciseSelected(event:ExerciseEvent):void {
			// Fire the exerciseSelect signal
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, event.hrefFilename));
		}
		
		protected function onQuestionZoneViewButtonClick(event:MouseEvent):void {
			var questionZoneExerciseNode:XML =  _course.unit.(@["class"] == "question-zone").exercise[0];
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, questionZoneExerciseNode.@href));
		}
		
		protected function onQuestionZoneDownloadButtonClick(event:MouseEvent):void {
			var questionZoneExerciseNode:XML =  _course.unit.(@["class"] == "question-zone").exercise[0];
			trace("DOWNLOAD");
		}
		
		protected override function getCurrentSkinState():String {
			return (_course) ? courseClass + "_" + (_exerciseSelectorPoppedOut ? "popped" : "normal") : super.getCurrentSkinState();
		}
		
	}
	
}