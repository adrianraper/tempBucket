package com.clarityenglish.recorder.adaptor {
	import flash.net.FileReference;
	import flash.ui.ContextMenu;
	import flash.utils.ByteArray;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class WebRecorderAdaptor extends EventDispatcher implements IRecorderAdaptor {
		
		public function setContextMenuItems(contextMenu:*, menuItems:Array):void {
			(contextMenu as ContextMenu).customItems = menuItems;
		}
		
		public function saveMp3Data(mp3Data:ByteArray, filename:String = null):void {
			if (!filename) {
				// If no filename is specified then open a browser
				var fileReference:FileReference = new FileReference();
				fileReference.save(mp3Data);
			} else {
				throw new Error("This is not implemented as present (in fact this will save to a remote PHP script rather than the local machine)");
			}
			
		}
		
	}

}