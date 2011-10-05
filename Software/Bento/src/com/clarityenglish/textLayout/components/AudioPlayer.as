package com.clarityenglish.textLayout.components {
	import mx.events.FlexEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	[SkinState("stopped")]
	[SkinState("playing")]
	[SkinState("played")]
	public class AudioPlayer extends SkinnableComponent {
		
		public function AudioPlayer() {
			addEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
		}
		
		protected function onPreInitialize(event:FlexEvent):void {
			removeEventListener(FlexEvent.PREINITIALIZE, onPreInitialize);
			
			setStyle("skinClass", getStyle("compactSkinClass"));
		}
		
		protected override function measure():void {
			super.measure();
			
			trace("Measuring audio");
		}
		
		protected override function getCurrentSkinState():String {
			return "stopped";
		}
		
	}
	
}