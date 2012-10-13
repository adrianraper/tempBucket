package com.clarityenglish.components {
	import flash.events.MouseEvent;
	
	import mx.core.IVisualElement;
	
	import spark.components.IItemRenderer;
	import spark.components.SpinnerList;
	import spark.events.DropDownEvent;
	import spark.events.RendererExistenceEvent;
	import spark.layouts.VerticalSpinnerLayout;
	
	public class PatchedSpinnerList extends SpinnerList {
		
		public function PatchedSpinnerList() {
			super();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			// #410 - match row count to data provider length
			if (dataGroup && dataGroup.layout)
				(dataGroup.layout as VerticalSpinnerLayout).requestedRowCount = dataProvider.length;
		}
		
		override protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void {
			super.dataGroup_rendererAddHandler(event);
			var renderer:IVisualElement = event.renderer;
			
			if (!renderer)
				return;
			
			renderer.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
		}
		
		override protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void {
			super.dataGroup_rendererRemoveHandler(event);
			
			var renderer:Object = event.renderer;
			
			if (!renderer)
				return;
			
			renderer.removeEventListener(MouseEvent.CLICK, onMouseClickHandler);
		}
		
		private function onMouseClickHandler(event:MouseEvent):void {
			// #410 - if the click is on the already selected item then shut the spinner list
			var newIndex:int;
			
			if (event.currentTarget is IItemRenderer)
				newIndex = IItemRenderer(event.currentTarget).itemIndex;
			else
				newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
			
			if (event.currentTarget["enabled"] == undefined || event.currentTarget["enabled"] == true) {
				if (selectedIndex == newIndex) {
					var spinnerDropDownList:SpinnerDropDownList = parentDocument.parent as SpinnerDropDownList;
					spinnerDropDownList.closeDropDown(false);
				}
			}
		}
	
	}
}
