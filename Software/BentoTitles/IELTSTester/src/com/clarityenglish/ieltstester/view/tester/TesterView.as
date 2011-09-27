package com.clarityenglish.ieltstester.view.tester {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.exercise.components.ExerciseView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.sparkTree.Tree;
	
	import flash.events.Event;
	
	import mx.collections.XMLListCollection;
	
	import spark.events.IndexChangeEvent;
	
	public class TesterView extends BentoView {
		
		private static const STARTING_IDX:uint = 0; // 9
		
		[SkinPart(required="true")]
		public var menuTree:Tree;
		
		[SkinPart(required="true")]
		public var exerciseView:ExerciseView; // TODO: This is going to be a DynamicView...
		
		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Set the unit of the first course as the dataprovider for the tree
			menuTree.dataProvider = new XMLListCollection(menu.course[0]..unit);
			
			var startingExercise:XML = menu.course[0].unit[0].exercise[0];
			
			// For testing purposes start the tree off with an exercise selected
			menuTree.expandItem(menuTree.dataProvider.getItemAt(0));
			menuTree.selectedItem = menu..exercise[STARTING_IDX];
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
			
			if (selectedNode.name() == "exercise")
				exerciseView.href = new Href(Href.EXERCISE, selectedNode.@href, href.rootPath);
			
		}
		
	}
	
}