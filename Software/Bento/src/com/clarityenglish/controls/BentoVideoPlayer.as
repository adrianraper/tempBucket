package com.clarityenglish.controls
{	
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.core.mx_internal;
	
	import org.osmf.events.TimeEvent;
	
	import spark.components.VideoPlayer;
	
	[Event(name="videoTimeout", type="com.clarityenglish.controls.BentoVideoPlayerEvent")]
	
	public class BentoVideoPlayer extends VideoPlayer
	{

		private var myTimer:Timer=new Timer(1000, 1);
		public var timerFlag:Boolean=false;
		
		public function BentoVideoPlayer()
		{			
			super();
		}
		
		public function startTimer():void{
		    if(timerFlag){
			    trace("start to timing");				
				myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeOut);
				myTimer.start();
				timerFlag=false;
			}
		}
		
		protected function onTimeOut(event:TimerEvent):void{
			if(super.videoDisplay.mx_internal::videoPlayer.state!="playing"){
				trace("spot! Too Slow!");
				trace("The state of player now is "+ super.videoDisplay.mx_internal::videoPlayer.state);
				dispatchEvent(new BentoVideoPlayerEvent(BentoVideoPlayerEvent.VIDEO_TIMEOUT));
			}			
		}
		
		public function resetTimer():void{
			myTimer.reset();
		}
	}
}