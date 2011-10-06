package com.clarityenglish.ielts.view.module {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.view.module.ui.ButtonItemRenderer;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	import mx.core.IDataRenderer;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.Label;
	import spark.components.TabBar;
	import spark.components.VideoPlayer;
	
	public class ModuleView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseTabBar:TabBar;
		
		[SkinPart(required="true")]
		public var courseTitleLabel:Label;
		
		[SkinPart(required="true")]
		public var courseDescriptionLabel:Label;
		
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
		public var practiceZoneDataGroup:DataGroup;
		
		[SkinPart(required="true")]
		public var adviceZoneVideoPlayer:VideoPlayer;
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
		public var exerciseSelect:Signal = new Signal(Href);
		
		public function set course(value:XML):void {
			_course = value;
			_courseChanged = true;
			invalidateProperties();
		}
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Populate the course tab bar with the course names
			courseTabBar.dataProvider = new XMLListCollection(menu..course);
			
			// Preselect the first course
			course = menu..course[0];
		}

		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_courseChanged) {
				courseTitleLabel.text = _course.@caption;
				courseDescriptionLabel.text = _course.@description;
				
				// class is a reserved keyword so have to use attribute("class") instead of @class
				examPractice1Button.label = _course.unit.(attribute("class") == "exam-practice").exercise[0].@caption;
				examPractice1Difficulty.data = _course.unit.(attribute("class") == "exam-practice").exercise[0].@difficulty;
				examPractice2Button.label = _course.unit.(attribute("class") == "exam-practice").exercise[1].@caption;
				examPractice2Difficulty.data = _course.unit.(attribute("class") == "exam-practice").exercise[1].@difficulty;
				
				practiceZoneDataGroup.dataProvider = new XMLListCollection(_course.unit.(attribute("class") == "practice-zone").exercise);
				
				var adviceZoneVideoUrl:String = _course.unit.(attribute("class") == "advice-zone").exercise[0].@href;
				adviceZoneVideoPlayer.source = href.createRelativeHref(null, adviceZoneVideoUrl).url;
								
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case courseTabBar:
					courseTabBar.requireSelection = true;
					courseTabBar.addEventListener(Event.CHANGE, onCourseTabBarIndexChange);
					break;
				case practiceZoneDataGroup:
					// Create a signal and listener for the button item renderer
					var exerciseClick:Signal = new Signal(XML);
					exerciseClick.add(function(xml:XML):void {
						// Fire the exerciseSelect signal
						exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, xml.@href));
					} );
					
					// Create the item renderer and inject the signal into it
					practiceZoneDataGroup.itemRenderer = new ClassFactory(ButtonItemRenderer);
					(practiceZoneDataGroup.itemRenderer as ClassFactory).properties = { exerciseClick: exerciseClick };
					break;
				case questionZoneButton:
				case examPractice1Button:
				case examPractice2Button:
					instance.addEventListener(MouseEvent.CLICK, onExerciseClick);
					break;
			}
		}
		
		/**
		 * The user has selected a course so update the module view
		 * 
		 * @param e
		 */
		protected function onCourseTabBarIndexChange(event:Event):void {
			course = event.target.selectedItem;
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
					hrefFilename = _course.unit.(attribute("class") == "question-zone").exercise[0].@href;
					break;
				case examPractice1Button:
					hrefFilename = _course.unit.(attribute("class") == "exam-practice").exercise[0].@href;
					break;
				case examPractice2Button:
					hrefFilename = _course.unit.(attribute("class") == "exam-practice").exercise[1].@href;
					break;
			}
			
			// Fire the exerciseSelect signal
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, hrefFilename));
		}
		
	}
	
}