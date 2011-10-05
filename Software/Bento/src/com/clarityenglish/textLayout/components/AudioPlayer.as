package com.clarityenglish.textLayout.components {
	import mx.events.FlexEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	[SkinState("hidden")]
	[SkinState("stopped_compact")]
	[SkinState("playing_compact")]
	[SkinState("played_compact")]
	public class AudioPlayer extends SkinnableComponent {
		
		public var src:String;
		
		public var controls:String;
		
		public function AudioPlayer() {
			
		}
		
		protected override function getCurrentSkinState():String {
			var mainState:String = (controls) ? controls : "hidden";
			
			return "stopped_" + mainState;
		}
		
	}
	
}