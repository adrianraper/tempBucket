package com.clarityenglish.ielts.view.zone.ui {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.view.zone.ExerciseEvent;
	
	import flash.events.MouseEvent;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.List;
	import spark.components.supportClasses.SkinnableComponent;
	
	[Event(name="exerciseSelected", type="com.clarityenglish.ielts.view.zone.ExerciseEvent")]
	public class PopoutExerciseSelector extends SkinnableComponent {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
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
		
		[Bindable]
		public var courseClass:String;
		
		public function PopoutExerciseSelector() {
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case exerciseList:
					exerciseList.addEventListener(MouseEvent.CLICK, onExerciseClick);
					break;
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			
			switch (instance) {
				case exerciseList:
					exerciseList.addEventListener(MouseEvent.CLICK, onExerciseClick);
					break;
			}
		}
		
		protected function onExerciseClick(event:MouseEvent):void {
			if (exerciseList.selectedItem) {
				dispatchEvent(new ExerciseEvent(ExerciseEvent.EXERCISE_SELECTED, exerciseList.selectedItem.@href));
			} else {
				log.error("Reached onExerciseClick with null value in exerciseList.selectedItem");
			}
		}
		
	}
}
