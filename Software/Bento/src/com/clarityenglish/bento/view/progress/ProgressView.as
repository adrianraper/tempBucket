package com.clarityenglish.bento.view.progress {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.progress.components.ProgressAnalysisView;
	import com.clarityenglish.bento.view.progress.components.ProgressCompareView;
	import com.clarityenglish.bento.view.progress.components.ProgressCoverageView;
	import com.clarityenglish.bento.view.progress.components.ProgressScoreView;
	import com.clarityenglish.common.vo.manageable.User;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.ButtonBar;
	import spark.components.Label;
	
	/*[SkinState("score")]
	[SkinState("compare")]
	[SkinState("analysis")]
	[SkinState("coverage")]*/
	public class ProgressView extends BentoView {

		[SkinPart]
		public var progressNavBar:ButtonBar;
		
		[SkinPart]
		public var progressScoreView:ProgressScoreView;

		[SkinPart]
		public var progressCompareView:ProgressCompareView;
		
		[SkinPart]
		public var progressAnalysisView:ProgressAnalysisView;
		
		[SkinPart]
		public var progressCoverageView:ProgressCoverageView;

		// gh#100
		//[SkinPart]
		//public var anonWarning:Group;
		[Bindable]
		public var anonUser:Boolean = true;
		
		[SkinPart]
		public var progressAnonymousLabel:Label;
		
		// gh#100
		//public var anoyAlertLabel:Label;
		
		// #341
		public var _user:User;

		// gh#11
		public function get assetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getDefaultLanguageCode().toLowerCase() + '/';
		}
		public function get languageAssetFolder():String {
			return config.remoteDomain + config.assetFolder + copyProvider.getLanguageCode().toLowerCase() + '/';
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
					] );
					
					progressNavBar.requireSelection = true;
					progressNavBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
				case progressScoreView:
				case progressCompareView:
				case progressAnalysisView:
					 instance.viewCopyProvider = this.copyProvider;
				case progressCoverageView:
					// #234
					instance.productVersion = productVersion;
					break;
				case progressAnonymousLabel:
					instance.text = copyProvider.getCopyForId("progressAnonymousLabel");
					break;					
			}
		}
		
		protected override function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			switch (instance) {
				case progressNavBar:
					progressNavBar.removeEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
			}	
		}
		
		/**
		 * This shows what state the skin is currently in
		 * 
		 * @return string State name 
		 */
		protected override function getCurrentSkinState():String {
			var state:String = (!progressNavBar || !progressNavBar.selectedItem) ? "coverage" : progressNavBar.selectedItem.data;
			
			// TODO: Can't reference this here
			//return state + ((productVersion == IELTSApplication.DEMO) ? "_demo" : "");
			return state;
		}
		
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onNavBarIndexChange(event:Event):void {
			invalidateSkinState(); // #301
		}
		
		// gh#100 seems this is never used or set
		public function get user():User {
			return _user;
		}
		
		public function set user(value:User):void {
			if (_user != value) {
				_user = value;
			}
			// gh#100 
			if (_user && Number(_user.id) > 0)
				anonUser = false;
			
		}
	}
}