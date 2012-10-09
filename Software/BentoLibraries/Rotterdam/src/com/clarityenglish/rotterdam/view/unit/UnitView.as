package com.clarityenglish.rotterdam.view.unit {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.textLayout.vo.XHTML;
	
	import mx.collections.ListCollectionView;
	
	import spark.components.List;
	
	public class UnitView extends BentoView {
		
		[SkinPart(required="true")]
		public var widgetList:List;
		
		[Bindable]
		public var widgetCollection:ListCollectionView;
		
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