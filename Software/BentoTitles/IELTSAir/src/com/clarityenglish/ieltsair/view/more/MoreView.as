package com.clarityenglish.ieltsair.view.more {
	import com.clarityenglish.bento.view.base.BentoView;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.ButtonBar;
	import spark.events.IndexChangeEvent;
	
	public class MoreView extends BentoView {
		
		[SkinPart]
		public var moreNavBar:ButtonBar;
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case moreNavBar:
					moreNavBar.dataProvider = new ArrayCollection( [
						{ label: "About us", data: "about" },
						{ label: "Contact us", data: "contact" },
					] );
					
					moreNavBar.requireSelection = true;
					moreNavBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
			}
		}
		
		protected function onNavBarIndexChange(event:IndexChangeEvent):void {
			
		}
		
	}
}
