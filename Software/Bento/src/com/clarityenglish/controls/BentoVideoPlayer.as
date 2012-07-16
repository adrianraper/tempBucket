package com.clarityenglish.controls
{	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.mx_internal;
	
	import org.osmf.media.MediaPlayerState;
	
	import spark.components.VideoPlayer;
	
	[Event(name="videoTimeout", type="com.clarityenglish.controls.BentoVideoPlayerEvent")]
	public class BentoVideoPlayer extends VideoPlayer {

		private var timer:Timer;
		
		public function BentoVideoPlayer() {			
			super();
			
			timer = new Timer(1000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
		}
		
		public function startTimer():void{
		    if (!timer.running) {
			    trace("start to timing");				
				timer.start();
			}
		}
		
		public function resetTimer():void{
			timer.reset();
		}
		
		protected function onTimerComplete(event:TimerEvent):void {
			if (videoDisplay.mx_internal::videoPlayer.state != MediaPlayerState.PLAYING) {
				trace("spot! Too Slow!");
				trace("The state of player now is "+ videoDisplay.mx_internal::videoPlayer.state);
				dispatchEvent(new BentoVideoPlayerEvent(BentoVideoPlayerEvent.VIDEO_TIMEOUT));
			}			
		}
	}
}