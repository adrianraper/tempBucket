package com.clarityenglish.tensebuster.view.progress
{
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.components.ProgressAnalysisView;
	import com.clarityenglish.bento.view.progress.components.ProgressCompareView;
	import com.clarityenglish.bento.view.progress.components.ProgressCoverageView;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.ButtonBar;
	
	public class ProgressView extends BentoView
	{
		[SkinPart]
		public var progressNavBar:ButtonBar;
		
		[SkinPart]
		public var progressCompareView:ProgressCompareView;
		
		[SkinPart]
		public var progressAnalysisView:ProgressAnalysisView;
		
		[SkinPart]
		public var progressCoverageView:ProgressCoverageView;
		
		[Bindable]
		public var isAnonymousUser:Boolean;
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressNavBar:
					progressNavBar.dataProvider = new ArrayCollection( [
						{ label: copyProvider.getCopyForId("progressNavBarCoverage"), data: "coverage" },
						{ label: copyProvider.getCopyForId("progressNavBarCompare"), data: "compare" },
						{ label: copyProvider.getCopyForId("progressNavBarAnalyse"), data: "analysis" },
						{ label: copyProvider.getCopyForId("progressNavBarScores"), data: "score" },
					] );
					
					progressNavBar.requireSelection = true;
					progressNavBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
			}
		}
		
		protected function onNavBarIndexChange(event:Event):void {
			invalidateSkinState();
		}
		
		/**
		 * The state of the skin is driven by the tab bar (coverage, compare or analyse)
		 */
		protected override function getCurrentSkinState():String {
			var state:String = (!progressNavBar || !progressNavBar.selectedItem) ? "coverage" : progressNavBar.selectedItem.data;
			return state;
		}
	}
}