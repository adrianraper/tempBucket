package com.clarityenglish.bento.model.adaptor {
	import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
	
	import flash.display.NativeMenu;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Dave Keen
	 * Can I add events to this adaptor? It seems that only methods defined in the interface are accepted.
	 * No. You add the events to the AIRClarityRecorder object.
	 */
	public class AIRRecorderAdaptor extends EventDispatcher implements IRecorderAdaptor  {
		
		private var mp3Data:ByteArray;
		
		public function setContextMenuItems(contextMenu:*, menuItems:Array):void {
			//(contextMenu as NativeMenu).items = menuItems;
		}
		
		public function saveMp3Data(mp3Data:ByteArray, filename:String = null):void {
			if (!filename) {
				// If no filename is specified then open a browser
				//var fileReference:FileReference = new FileReference();
				//fileReference.save(mp3Data);
				
				this.mp3Data = mp3Data;
				
				// Can I set a default name?
				//var file:File = new File();
				var file:File = File.documentsDirectory.resolvePath("my recording.mp3");
				file.browseForSave("Save MP3 As");
				file.addEventListener(Event.CANCEL, onFileCancel, false, 0, true);
				file.addEventListener(Event.SELECT, onFileSelect, false, 0, true);
			} else {
				// Use AIR File and FileStream to save to the given filename
				throw new Error("This is not implemented at present (in fact this will save to a remote PHP script rather than the local machine")
			}
		}
		
		/**
		 * The user cancelled the file dialog so ditch the stored mp3data and do nothing
		 * 
		 * @param	e
		 */
		private function onFileCancel(e:Event):void {
			mp3Data = null;
			// You need to pass this event on as it is picked up and used to help AIR work out if it should be in front or not
			this.dispatchEvent(e);
		}
		
		/**
		 * If the user has chosen a file to save to ensure it ends with .mp3 and write the mp3data to it
		 * 
		 * @param	e
		 */
		private function onFileSelect(e:Event):void {
			var file:File = e.currentTarget as File;
			if (!file.extension || file.extension.toLowerCase() != "mp3")
				file = new File(file.nativePath + ".mp3");
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(mp3Data);
			fileStream.close();
			
			mp3Data = null;
			//trace("adaptor onFileSelect");
			//trace("event=" + this.dispatchEvent(new Event(Event.SELECT)));
			// You need to pass this event on as it is picked up and used to help AIR work out if it should be in front or not
			this.dispatchEvent(e);
			// gh#456
			this.dispatchEvent(new RecorderEvent(RecorderEvent.SAVE_COMPLETE));
		}
	}

}