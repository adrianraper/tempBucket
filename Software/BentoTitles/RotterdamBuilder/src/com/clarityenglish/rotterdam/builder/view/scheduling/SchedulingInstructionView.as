package com.clarityenglish.rotterdam.builder.view.scheduling
{
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.SWFLoader;
	import mx.events.CloseEvent;
	
	import spark.components.Button;
	
	public class SchedulingInstructionView extends BentoView {
		
		[SkinPart]
		public var iKnowButton:spark.components.Button;
		
		[SkinPart]
		public var helpPublishView:SWFLoader;
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case iKnowButton:
					iKnowButton.addEventListener(MouseEvent.CLICK, onIKnow);
					break;
			}
		}
		
		protected function onIKnow(event:Event):void {
			//gh #225
			config.illustrationCloseFlag = false;
			
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
			
		}
	}
}