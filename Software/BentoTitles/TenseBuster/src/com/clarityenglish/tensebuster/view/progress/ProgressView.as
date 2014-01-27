package com.clarityenglish.tensebuster.view.progress
{
	import com.clarityenglish.bento.BentoApplication;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.components.ProgressAnalysisView;
	import com.clarityenglish.bento.view.progress.components.ProgressCompareView;
	import com.clarityenglish.bento.view.progress.components.ProgressCoverageView;
	import com.clarityenglish.bento.view.progress.components.ProgressScoreView;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.ButtonBar;
	import spark.components.Label;
	
	public class ProgressView extends BentoView
	{
		[SkinPart]
		public var progressNavBar:ButtonBar;
		
		[SkinPart]
		public var progressScoreView:ProgressScoreView;

		[SkinPart]
		public var progressCompareView:com.clarityenglish.tensebuster.view.progress.ProgressCompareView;
		
		[SkinPart]
		public var progressAnalysisView:com.clarityenglish.tensebuster.view.progress.ProgressAnalysisView;
		
		[SkinPart]
		public var progressCoverageView:ProgressCoverageView;
		
		[Bindable]
		public var isAnonymousUser:Boolean;
		
		[SkinPart]
		public var progressAnonymousLabel:Label;
		
		private var _androidSize:String;
		
		// gh#11
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
		}
		
		[Bindable]
		public function get androidSize():String {
			return _androidSize;
		}
		
		public function set androidSize(value:String):void {
			_androidSize = value;
		}
		
		public function getCopyProvider():CopyProvider {
			return copyProvider;
		}

		// Constructor to let us initialise our states
		public function ProgressView() {
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressNavBar:
					// gh#11 Language Code
					progressNavBar.dataProvider = new ArrayCollection( [
						{ label: copyProvider.getCopyForId("progressNavBarCoverage"), data: "coverage" },
						{ label: copyProvider.getCopyForId("progressNavBarCompare"), data: "compare" },
						{ label: copyProvider.getCopyForId("progressNavBarAnalyse"), data: "analysis" },
						{ label: copyProvider.getCopyForId("progressNavBarScores"), data: "score" },
						{ label: copyProvider.getCopyForId("progressNavBarCertificate"), data: "certificate" },
					] );
					progressNavBar.requireSelection = true;
					progressNavBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
				case progressAnonymousLabel:
					instance.text = copyProvider.getCopyForId("progressAnonymousLabel");
					break;					
			}
		}
		
		/**
		 * The state comes from the selection in the progress bar, plus _demo if we are in a demo version 
		 */
		protected override function getCurrentSkinState():String {
			var state:String = (!progressNavBar || !progressNavBar.selectedItem) ? "coverage" : progressNavBar.selectedItem.data;
			return state + ((productVersion == BentoApplication.DEMO) ? "_demo" : "");
		}
		
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onNavBarIndexChange(event:Event):void {
			invalidateSkinState(); // #301
		}
		
	}
}