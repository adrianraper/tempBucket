package com.clarityenglish.ieltstester.view.tester {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.sparkTree.Tree;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	
	import spark.events.IndexChangeEvent;
	
	public class TesterView extends BentoView {
		
		private static const STARTING_CAPTION:String = "SpaceBug";
		
		[SkinPart(required="true")]
		public var menuTree:Tree;
		
		[SkinPart(required="true")]
		public var dynamicView:BentoView;
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Set the unit of the first course as the dataprovider for the tree
			menuTree.dataProvider = new XMLListCollection(menu.course[0]..unit);
			
			var startingExercise:XML = menu.course[0].unit[0].exercise[0];
			
			// For testing purposes start the tree off with everything expanded and an exercise selected
			for (var n:uint = 0; n < menuTree.dataProvider.length; n++)
				menuTree.expandItem(menuTree.dataProvider.getItemAt(n));
			
			menuTree.selectedItem = menu..exercise.(@caption == STARTING_CAPTION)[0];
			menuTree.dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE));
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case menuTree:
					menuTree.labelFunction = function(item:Object):String { return unescape(item.@caption); }
					menuTree.addEventListener(IndexChangeEvent.CHANGE, onMenuTreeChange);
					break;
			}
		}
		
		protected function onMenuTreeChange(event:IndexChangeEvent):void {
			var selectedNode:XML = event.target.selectedItem;
			
			if (selectedNode && selectedNode.name() == "exercise")
				dynamicView.href = href.createRelativeHref(Href.EXERCISE, selectedNode.@href);
			
		}
		
	}
	
}