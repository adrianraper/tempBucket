package com.clarityenglish.textLayout.util {
	import flashx.textLayout.container.TextContainerManager;
	
	import mx.managers.SystemManager;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.LoadEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;

	
	public class TLF2SystemManager extends SystemManager {
		
		public function TLF2SystemManager() {
			var tlfReference:Array = [ TextContainerManager ];
			var osmfReference:Array = [ LoadEvent, MediaContainer, MediaPlayer, MediaFactory, DefaultMediaFactory ];
			super(); 
		}
		
	}
}
