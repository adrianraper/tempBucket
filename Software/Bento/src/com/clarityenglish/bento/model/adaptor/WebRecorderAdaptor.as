package com.clarityenglish.bento.model.adaptor {
import com.clarityenglish.bento.model.AudioProxy;
import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
import com.clarityenglish.common.CommonNotifications;
import com.clarityenglish.common.vo.config.BentoError;

import flash.events.Event;
	import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.FileReference;
	import flash.ui.ContextMenu;
	import flash.utils.ByteArray;

import mx.controls.Alert;

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
                try {
                    fileReference.save(mp3Data, "recording.mp3");
                } catch (e:Error) {
                    Alert.show('There was an error saving the file: ' + e.toString(), 'Error');
                }
				// gh#456
				fileReference.addEventListener(Event.COMPLETE, onComplete);
				// gh#1438
				fileReference.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				//fileReference.addEventListener(Event.SELECT, onSelect);
				fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			} else {
				throw new Error("This is not implemented as present (in fact this will save to a remote PHP script rather than the local machine)");
			}
			
		}
		
		private function onComplete(event:Event):void {
			dispatchEvent(new RecorderEvent(RecorderEvent.SAVE_COMPLETE, null, true));
		}
		private function onIOError(event:IOErrorEvent):void {
            dispatchEvent(new RecorderEvent(RecorderEvent.SAVE_ERROR, event, true));
		}
        private function securityErrorHandler(event:SecurityErrorEvent):void {
            dispatchEvent(new RecorderEvent(RecorderEvent.SAVE_ERROR, event, true));
        }

	}

}