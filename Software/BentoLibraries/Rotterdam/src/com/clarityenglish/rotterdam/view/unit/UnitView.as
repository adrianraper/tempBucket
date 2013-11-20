package com.clarityenglish.rotterdam.view.unit {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import flash.events.Event;
	
	import mx.collections.ListCollectionView;
	
	import spark.components.List;
	
	public class UnitView extends BentoView {
		
		[SkinPart(required="true")]
		public var widgetList:List;
		
		protected var _widgetCollection:ListCollectionView;

		[Bindable(event="widgetCollectionChanged")]
		public function get widgetCollection():ListCollectionView {
			return _widgetCollection;
		}

		public function set widgetCollection(value:ListCollectionView):void {
			// gh#731
			if (value !== _widgetCollection) {
				_widgetCollection = null;
				dispatchEvent(new Event("widgetCollectionChanged"));
				
				callLater(function():void {
					_widgetCollection = value;
					dispatchEvent(new Event("widgetCollectionChanged"));
				});
			}
		}

		protected override function commitProperties():void {
			super.commitProperties();
		}

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				
			}
		}
		
	}
}