package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.rotterdam.view.unit.ui.WidgetList;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	
	import spark.components.ToggleButton;
	
	public class GroupWidget extends AbstractWidget {
		
		[SkinPart]
		public var groupWidgetList:WidgetList;
		
		[SkinPart]
		public var collapseToggleButton:ToggleButton;
		
		private var _groupWidgetHeight:Number;
		
		[Bindable]
		public function get groupWidgetHeight():Number {
			return _groupWidgetHeight;
		}
		
		public function set groupWidgetHeight(value:Number):void {
			_groupWidgetHeight = value;
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case groupWidgetList:
					setGroupWidgetListHeight();
					break;
				case collapseToggleButton:
					collapseToggleButton.addEventListener(MouseEvent.CLICK, onCollapseToggleButtonClick);
			}
		}
		
		// set groupWidgetList height here. Height cannot be detected by component itself
		protected function setGroupWidgetListHeight():void {
			for each(var exercise:XML in _xml.exercise) {
				groupWidgetHeight = Math.max(groupWidgetList.height, exercise.@ypos) + Number(exercise.@layoutheight);
				groupWidgetList.height = groupWidgetHeight;
			}
		}
		
		protected function onCollapseToggleButtonClick(event:Event):void {
			
		}
	}
}