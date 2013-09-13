package com.clarityenglish.tensebuster.view.home {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.MouseEvent;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Label;
	import spark.components.List;
	
	public class HomeView extends BentoView {
		
		[SkinPart(required="true")]
		public var coursesList:List;
		
		[SkinPart]
		public var homeInstructionLabel:Label;
		
		public var courseSelect:Signal = new Signal(XML);
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			coursesList.dataProvider = new XMLListCollection(menu.course);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case coursesList:
					coursesList.addEventListener(MouseEvent.CLICK, onListClick);
					coursesList.setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
					break;
				case homeInstructionLabel:
					homeInstructionLabel.text = copyProvider.getCopyForId("homeInstructionLabel");
					break;
			}
		}

		private function onListClick(event:MouseEvent):void {
			var course:XML = event.currentTarget.selectedItem as XML;
			if (course)
				courseSelect.dispatch(course);
		}
		
	}
}