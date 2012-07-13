package com.clarityenglish.controls
{
	import flash.events.Event;
	
	public class BentoVideoPlayerEvent extends Event
	{
		public static const VIDEO_TIMEOUT:String = "videoTimeout";
		public function BentoVideoPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}