package com.clarityenglish.bento.model.adaptor {
	import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.ui.ContextMenu;
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author Dave Keen
	 */
	public class WebRecorderAdaptor extends EventDispatcher implements IRecorderAdaptor {
		
		public function setContextMenuItems(contextMenu:*, menuItems:Array):void {
			//(contextMenu as ContextMenu).customItems = menuItems;
		}
		
		public function saveMp3Data(mp3Data:ByteArray, filename:String = null):void {
			if (!filename) {
				// If no filename is specified then open a browser
				var fileReference:FileReference = new FileReference();
				fileReference.save(mp3Data, "my recording.mp3");
				// gh#456
				fileReference.addEventListener(Event.COMPLETE, onComplete);
			} else {
				throw new Error("This is not implemented as present (in fact this will save to a remote PHP script rather than the local machine)");
			}
			
		}
		
		private function onComplete(event:Event):void {
			dispatchEvent(new RecorderEvent(RecorderEvent.SAVE_COMPLETE, null, true));
		}
		
	}

}