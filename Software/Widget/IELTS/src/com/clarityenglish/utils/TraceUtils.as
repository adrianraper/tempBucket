package com.clarityenglish.utils 
{
	import flash.net.LocalConnection;
	import flash.events.StatusEvent;

	/**
	 * ...
	 * @author Adrian Raper, Clarity Language Consultants Ltd
	 */
	public class TraceUtils
	{
		
		/**
		 * Uses local connection to link with the standard Clarity trace tool
		 * 
		 * @param	message The text to display
		 * @param	level Security option
		 * @return
		 */
		private static function onStatus(event:StatusEvent):void {
			switch (event.level) {
			case "status":
				//trace("LocalConnection.send() succeeded");
				break;
			case "error":
				trace("LocalConnection.send() failed");
				break;
			}
		}
		public static function myTrace(message:String, level:Number=0):void {
			var sendConn:LocalConnection = new LocalConnection();
			sendConn.addEventListener(StatusEvent.STATUS, onStatus);
			sendConn.send("_trace", "myTrace", message, level);
			trace(message);
		}

	}
	
}