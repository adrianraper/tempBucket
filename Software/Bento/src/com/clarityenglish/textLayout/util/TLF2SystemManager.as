package com.clarityenglish.textLayout.util {
	import flashx.textLayout.container.TextContainerManager;
	
	import mx.managers.SystemManager;
	
	public class TLF2SystemManager extends SystemManager {
		
		public function TLF2SystemManager() {
			var c:Class = TextContainerManager; // force the inclusion of this class
			super();
		}
		
	}
}
