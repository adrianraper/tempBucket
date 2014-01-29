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
		 * Return the HTML required to display this video source.  This can actually be either HTML or a URL which is loaded directly into the StageWebView.
		 * 
		 * @param source
		 * @return 
		 */
		function getHtml(source:Object):String;
		
	}
	
}