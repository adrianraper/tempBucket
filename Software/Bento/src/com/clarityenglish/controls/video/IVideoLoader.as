package com.clarityenglish.controls.video {
	import com.clarityenglish.common.vo.config.ChannelObject;

	public interface IVideoLoader {
		
		function load(source:Object, channelObject:ChannelObject = null):void;
		
	}
}