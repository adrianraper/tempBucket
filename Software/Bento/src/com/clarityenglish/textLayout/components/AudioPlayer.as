package com.clarityenglish.textLayout.components {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	
	import spark.components.Image;
	import spark.components.supportClasses.SkinnableComponent;
	
	[SkinState("hidden")]
	[SkinState("stopped_compact")]
	[SkinState("playing_compact")]
	[SkinState("played_compact")]
	public class AudioPlayer extends SkinnableComponent {
		
		private static const PLAYING:String = "playing";
		private static const STOPPED:String = "stopped";
		private static const PLAYED:String = "played";
		
		[SkinPart(required="true")]
		public var compactUIComponent:UIComponent;
		
		public var src:String;
		
		public var controls:String;
		
		/**
		 * One of the 3 constants STOPPED, PLAYING or PLAYED defined above
		 */
		private var soundStatus:String = STOPPED;
		
		/**
		 * A flag that records whether the sound has been played at least once (to distinguish between STOPPED and PLAYED)
		 */
		private var played:Boolean;
		
		/**
		 * The sound channel used for playback is static and hence is shared between all AudioPlayer instances  
		 */
		private static var soundChannel:SoundChannel;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case compactUIComponent:
					compactUIComponent.addEventListener(MouseEvent.CLICK, onCompactUIComponentClick);
					break;
			}
		}
		
		/**
		 * This deals with a click on the compact player, where everything happens on a single clickable image
		 * 
		 * @param event
		 */
		protected function onCompactUIComponentClick(event:MouseEvent):void {
			switch (soundStatus) {
				case STOPPED:
				case PLAYED:
					play();
					break;
				case PLAYING:
					stop();
					break;
			}
		}
		
		protected override function getCurrentSkinState():String {
			var mainState:String = (controls) ? controls : "hidden";
			
			return soundStatus + "_" + mainState;
		}
		
		/**
		 * Play the sound (stopping any previously playing sound) and set the appropriate state on the skin
		 */
		protected function play():void {
			// Stop any previously playing sound and play the new one
			stop();
			var sound:Sound = new Sound(new URLRequest(src));
			soundChannel = sound.play();
			soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
			played = true;
			
			// Change the status and invalidate the skin state
			soundStatus = PLAYING;
			invalidateSkinState();
		}
		
		/**
		 * Stop the sound (stopping any previously playing sound) and set the appropriate state on the skin
		 */
		protected function stop():void {
			if (soundChannel)
				soundChannel.stop();
			
			// Change the status and invalidate the skin state
			soundStatus = (played) ? PLAYED : STOPPED;
			invalidateSkinState();
		}
		
		protected function onSoundComplete(event:Event):void {
			// When a sound finishes playing just call stop anyway to set the skin (and stopping a finished sound does no harm)
			stop();
		}
		
	}
	
}