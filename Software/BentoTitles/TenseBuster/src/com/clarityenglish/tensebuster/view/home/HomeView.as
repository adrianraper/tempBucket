package com.clarityenglish.tensebuster.view.home {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.collections.XMLListCollection;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class HomeView extends BentoView {
		
		[SkinPart(required="true")]
		public var coursesList:List;
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			coursesList.dataProvider = new XMLListCollection(menu.course);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case coursesList:
					coursesList.addEventListener(IndexChangeEvent.CHANGE, onListSelect);
					break;
			}
			
		}

		private function onListSelect(event:IndexChangeEvent):void {
			
		}
		
	}
}