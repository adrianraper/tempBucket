package com.clarityenglish.textLayout.rendering {
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	
	import flash.events.Event;
	
	import spark.core.SpriteVisualElement;
	
	public class RenderFlow extends SpriteVisualElement {
		
		public var node:XML;
		
		public var textFlow:FloatableTextFlow;
		
		public function RenderFlow() {
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}

		private function onRemovedFromStage(event:Event):void {
			textFlow.flowComposer.removeAllControllers();
			textFlow.formatResolver = null;
			textFlow = null;
		}
		
	}
}