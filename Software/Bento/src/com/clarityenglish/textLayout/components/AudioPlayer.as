package com.clarityenglish.textLayout.components {
	import com.clarityenglish.textLayout.events.AudioPlayerEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.osmf.events.AudioEvent;
	
	import spark.components.mediaClasses.ScrubBar;
	import spark.components.supportClasses.SkinnableComponent;
	
	[SkinState("hidden")]
	[SkinState("stopped_compact")]
	[SkinState("playing_compact")]
	[SkinState("paused_compact")]
	[SkinState("played_compact")]
	
	[SkinState("stopped_full")]
	[SkinState("playing_full")]
	[SkinState("paused_full")]
	[SkinState("played_full")]
	public class AudioPlayer extends SkinnableComponent {
		
		private static const STOPPED:String = "stopped";
		private static const PLAYING:String = "playing";
		private static const PAUSED:String = "paused";
		private static const PLAYED:String = "played";
		
		[SkinPart(required="true")]
		public var compactComponent:UIComponent;
		
		[SkinPart(required="true")]
		public var playComponent:UIComponent;
		
		[SkinPart(required="true")]
		public var pauseComponent:UIComponent;
		
		[SkinPart(required="true")]
		public var scrubBar:ScrubBar;
		
		public var src:String;
		
		public var controls:String;
		
		public var autoplay:Boolean;
		
		[Bindable]
		public var playComponentEnable:Boolean;
		
		/**
		 * A timer for updating the scrub bar as the sound plays 
		 */
		private var scrubBarTimer:Timer;
		
		/**
		 * One of the 3 constants STOPPED, PLAYING or PLAYED defined above
		 */
		private var soundStatus:String = STOPPED;
		
		/**
		 * A flag that records whether the sound has been played at least once (to distinguish between STOPPED and PLAYED)
		 */
		private var played:Boolean;
		
		/**
		 * The position that the audio should restart from if paused
		 */
		private var pausePosition:Number;
		
		/**
		 * The sound for the player
		 */
		private var sound:Sound;
		
		/**
		 * The sound channel used for playback is static and hence is shared between all AudioPlayer instances  
		 */
		private static var soundChannel:SoundChannel;
		
		public function AudioPlayer() {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			scrubBarTimer = new Timer(500, 0);
			scrubBarTimer.addEventListener(TimerEvent.TIMER, onScrubBarTimer);
		}
		
		protected function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			if (autoplay) play();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case compactComponent:
					compactComponent.addEventListener(MouseEvent.CLICK, onCompactUIComponentClick);
					break;
				case playComponent:
					playComponent.addEventListener(MouseEvent.CLICK, function(e:Event):void { play(); } );
					break;
				case pauseComponent:
					pauseComponent.addEventListener(MouseEvent.CLICK, function(e:Event):void { pause(); } );
					break;
				case scrubBar:
					scrubBar.addEventListener(Event.CHANGE, function(e:Event):void { seek(scrubBar.value); } );
					break;
			}
		}
		
		public static function stopAllAudio():void {
			if (soundChannel) {
				// Stop any currently playing sound, and dispatch a SOUND_COMPLETE event so that the previous audio player changes from PLAYING to the appropriate state
				soundChannel.stop();
				soundChannel.dispatchEvent(new Event(Event.SOUND_COMPLETE));
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
			return (mainState == "hidden") ? "hidden" : soundStatus + "_" + mainState;
		}
		
		
		protected function onScrubBarTimer(event:Event):void {
			var scrubBarPos:Number = soundChannel.position / 1000;
			if (scrubBar && scrubBarPos < scrubBar.maximum)
				scrubBar.value = scrubBarPos;
		}
		
		/**
		 * Whilst the sound loads estimate the duration
		 * 
		 * @param event
		 */
		protected function onSoundLoadProgress(event:ProgressEvent):void {
			if (scrubBar && sound && sound.length > 0) {
				var duration:Number = (sound.bytesTotal / (sound.bytesLoaded / sound.length)) / 1000;
				scrubBar.maximum = duration;
			}
		}
		
		/**
		 * When the sound has loaded we can get the actual duration 
		 * 
		 * @param event
		 */
		protected function onSoundLoadComplete(event:Event):void {
			if (scrubBar && sound)
				scrubBar.maximum = sound.length / 1000;
		}
		
		/**
		 * Play the sound (stopping any previously playing sound) and set the appropriate state on the skin
		 */
		protected function play():void {
			// Work out the start position (based on whether we are paused or not)
			var startTime:Number = (soundStatus == PAUSED) ? pausePosition : null;
			
			// Stop any previously playing sound and play the new one
			stop();
			sound = new Sound(new URLRequest(src));
			
			// Attach listeners to update the scrub bar maximum as the sound loads
			sound.addEventListener(ProgressEvent.PROGRESS, onSoundLoadProgress, false, 0, true);
			sound.addEventListener(Event.COMPLETE, onSoundLoadComplete, false, 0, true);
			
			soundChannel = sound.play(startTime);
			soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
			played = true;
			
			scrubBarTimer.reset();
			scrubBarTimer.start();
			
			// Change the status and invalidate the skin state
			soundStatus = PLAYING;
			invalidateSkinState();
			
			dispatchEvent(new AudioPlayerEvent(AudioPlayerEvent.PLAY, src, true));
		}
		
		protected function seek(time:Number):void {
			// Set the pause position to the seek time
			pausePosition = time * 1000;
			
			// If we are currently playing then keep playing at the new position, otherwise
			if (soundStatus == PLAYING) {
				soundStatus = PAUSED;
				play();
			} else {
				soundStatus = PAUSED;
			}
		}
		
		protected function pause():void {
			pausePosition = soundChannel.position;
			soundChannel.stop();
			
			scrubBarTimer.stop();
			
			// Change the status and invalidate the skin state
			soundStatus = PAUSED;
			invalidateSkinState();
		}
		
		/**
		 * Stop the sound (stopping any previously playing sound) and set the appropriate state on the skin
		 */
		protected function stop():void {
			if (soundChannel) {
				// Stop any currently playing sound, and dispatch a SOUND_COMPLETE event so that the previous audio player changes from PLAYING to the appropriate state
				soundChannel.stop();
				soundChannel.dispatchEvent(new Event(Event.SOUND_COMPLETE));
			}
			
			scrubBarTimer.stop();
			
			// Change the status and invalidate the skin state
			soundStatus = (played) ? PLAYED : STOPPED;
			invalidateSkinState();
		}
		
		protected function onSoundComplete(event:Event):void {
			// Change the status and invalidate the skin state
			soundStatus = (played) ? PLAYED : STOPPED;
			invalidateSkinState();
		}
		
	}
	
}