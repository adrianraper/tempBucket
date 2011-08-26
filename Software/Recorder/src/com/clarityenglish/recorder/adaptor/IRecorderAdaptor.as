package com.clarityenglish.recorder.adaptor {
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public interface IRecorderAdaptor extends IEventDispatcher  {
		
		function setContextMenuItems(contextMenu:*, menuItems:Array):void;
		function saveMp3Data(mp3Data:ByteArray, filename:String = null):void;
		
	}
	
}