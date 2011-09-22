package com.clarityenglish.ielts.view.module {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.module.ui.ButtonItemRenderer;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.DataRenderer;
	import spark.components.Label;
	import spark.components.TabBar;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	public class ModuleView extends BentoView {
		
		[SkinPart(required="true")]
		public var courseTabBar:TabBar;
		
		[SkinPart(required="true")]
		public var courseTitleLabel:Label;
		
		[SkinPart(required="true")]
		public var courseDescriptionLabel:Label;
		
		[SkinPart(required="true")]
		public var examPractice1Button:Button;
		
		[SkinPart(required="true")]
		public var examPractice1Difficulty:DataRenderer;
		
		[SkinPart(required="true")]
		public var examPractice2Button:Button;
		
		[SkinPart(required="true")]
		public var examPractice2Difficulty:DataRenderer;
		
		[SkinPart(required="true")]
		public var practiceZoneDataGroup:DataGroup;
		
		private var _course:XML;
		private var _courseChanged:Boolean;
		
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
				
				// Class is a reserved word so have to use attribute(name)
				examPractice1Button.label = _course.unit.(attribute("class") == "exam-practice").exercise[0].@caption;
				examPractice1Difficulty.data = _course.unit.(attribute("class") == "exam-practice").exercise[0].@difficulty;
				examPractice2Button.label = _course.unit.(attribute("class") == "exam-practice").exercise[1].@caption;
				examPractice2Difficulty.data = _course.unit.(attribute("class") == "exam-practice").exercise[1].@difficulty;
				
				practiceZoneDataGroup.dataProvider = new XMLListCollection(_course.unit.(attribute("class") == "practice-zone").exercise);
				
				_courseChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName,instance);
			
			switch (instance) {
				case courseTabBar:
					courseTabBar.requireSelection = true;
					courseTabBar.addEventListener(Event.CHANGE, onCourseTabBarIndexChange);
					break;
				case practiceZoneDataGroup:
					practiceZoneDataGroup.itemRenderer = new ClassFactory(ButtonItemRenderer);
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
		
	}
	
}