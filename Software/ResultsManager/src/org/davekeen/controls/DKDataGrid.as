package org.davekeen.controls {
	import flash.events.Event;
	import mx.controls.DataGrid;
	
	/**
	 * ...
	 * @author ...
	 */
	public class DKDataGrid extends DataGrid {
	
		[Bindable]
		public var retainVerticalScrollPosition:Boolean;
		
		private var refreshData:Boolean;
		private var lastVerticalScrollPosition:Number;
		//private var isResetting:Boolean;
		
		public function DKDataGrid() {
			addEventListener(Event.RENDER, onRender, false, 0, true);
		}
		
		override public function set dataProvider(value:Object):void {
			lastVerticalScrollPosition = verticalScrollPosition;
			refreshData = true;
			super.dataProvider = value;
		}
		
		private function onRender(e:Event):void {
			if (refreshData) {
				refreshData = false;
				
				if (retainVerticalScrollPosition)
					verticalScrollPosition = (lastVerticalScrollPosition <= maxVerticalScrollPosition) ? lastVerticalScrollPosition : maxVerticalScrollPosition;

			}
		}
		
		
	}
	
}