package com.clarityenglish.ielts.view.zone.ui {
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.List;
	import spark.components.supportClasses.SkinnableComponent;
	
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
		
		// This is injected from the parent component
		public var exerciseSelect:Signal;
		
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
			exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, exerciseList.selectedItem.@href));
		}
		
	}
}
