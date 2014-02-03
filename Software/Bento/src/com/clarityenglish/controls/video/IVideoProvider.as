package com.clarityenglish.controls.video {
	
	public interface IVideoProvider {
		
		/**
		 * If this provider is capable of handling this source then this will return true.
		 * 
		 * @param source
		 * @return 
		 */
		function canHandleSource(source:Object):Boolean;
		
		/**
		 * (HTML)  Return the HTML required to display this video source.  This can actually be either HTML or a URL which is loaded directly into the StageWebView.
		 * 
		 * @param source
		 * @return 
		 */
		function getHtml(source:Object):String;
		
		function create(source:Object):void;
		
		function resize():void;
		
		/**
		 * (Flash) If supported, start playing the video.
		 */
		function play():void;
		
		/**
		 * (Flash) If supported, stop playing the video.
		 */
		function stop():void;
		
		/**
		 * This is called before a provider is changed and gives it an opportunity to clean up
		 */
		function destroy():void;
		
	}
	
}