package com.clarityenglish.ieltsair.view.zone {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.List;
	import spark.core.IDisplayText;
	
	public class PracticeZonePopoutView extends BentoView {
		
		[SkinPart]
		public var captionLabel:IDisplayText;
		
		[SkinPart]
		public var exerciseList:List;
		
		private var _caption:String;
		private var _exercises:XMLList;
		
		public var exerciseSelect:Signal = new Signal(Href);
		
		public function set caption(value:String):void {
			_caption = value;
			invalidateProperties();
		}
		
		public function set exercises(value:XMLList):void {
			_exercises = value;
			invalidateProperties();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			captionLabel.text = _caption;
			exerciseList.dataProvider = new XMLListCollection(_exercises);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case exerciseList:
					exerciseList.addEventListener(MouseEvent.CLICK, onExerciseSelected);
					break;
			}
		}
		
		/**
		 * The user has selected an exercise
		 * 
		 * @param event
		 */
		protected function onExerciseSelected(event:Event):void {
			// Fire the exerciseSelect signal
			if (exerciseList.selectedItem) {
				exerciseSelect.dispatch(href.createRelativeHref(Href.EXERCISE, exerciseList.selectedItem.@href.toString()));
			} else {
				log.error("Reached onExerciseClick with null value in exerciseList.selectedItem");
			}
			
		}
		
	}
}
