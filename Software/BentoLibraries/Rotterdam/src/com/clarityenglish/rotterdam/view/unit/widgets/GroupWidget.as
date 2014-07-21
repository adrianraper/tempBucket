package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.rotterdam.view.unit.ui.WidgetList;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.ResizeEvent;
	
	import spark.components.ToggleButton;
	
	public class GroupWidget extends AbstractWidget {
		
		[SkinPart]
		public var groupWidgetList:WidgetList;
		
		[SkinPart]
		public var collapseToggleButton:ToggleButton;
		
		private var _groupWidgetHeight:Number;
		private var _groupWidgetListHeight:Number;
		
		public function GroupWidget():void {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		[Bindable]
		public function get groupWidgetHeight():Number {
			return _groupWidgetHeight;
		}
		
		public function set groupWidgetHeight(value:Number):void {
			_groupWidgetHeight = value;
		}
		
		[Bindable]
		public function get groupWidgetListHeight():Number {
			return _groupWidgetListHeight;
		}
		
		public function set groupWidgetListHeight(value:Number):void {
			_groupWidgetListHeight = value;
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
				if (exercise.@column == 0) {
					groupWidgetList.height = Math.max(groupWidgetList.height, exercise.@ypos) + Number(exercise.@layoutheight);
				}
			}
			// store list height here for collapse and expand animation
			groupWidgetListHeight = groupWidgetList.height;
		}
		
		protected function onCollapseToggleButtonClick(event:Event):void {
			
		}
		
		protected function onAddedToStage(event:Event):void {
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		protected function onResize(event:Event):void {
			width = stage.stageWidth - 40;
		}
	}
}