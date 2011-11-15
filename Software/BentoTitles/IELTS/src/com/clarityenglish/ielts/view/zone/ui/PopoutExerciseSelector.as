package com.clarityenglish.ielts.view.zone.ui {
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.Event;
	
	import spark.components.List;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	
	public class PopoutExerciseSelector extends SkinnableComponent {
		
		[SkinPart]
		public var exerciseList:List;
		
		[SkinPart]
		public var imageItemRenderer:ImageItemRenderer;
		
		[SkinPart]
		public var difficultyRenderer:DifficultyRenderer;
		
		[Bindable]
		public var group:XML;
		
		[Bindable]
		public var href:Href;
		
		[Bindable]
		public var exercises:XMLList;
		
		public function PopoutExerciseSelector() {
			super();
		}
		
	}
}
