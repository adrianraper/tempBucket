package com.clarityenglish.rotterdam.player.view.progress {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressAnalysisView;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressCompareView;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressCoverageView;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressScoreView;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.ButtonBar;
	import spark.components.Group;
	
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
		
		[SkinPart]
		public var anonWarning:Group;

		public var currentCourseClass:String;
		
		// #341
		public var _user:User;
		
		public function get assetFolder():String {
			return config.remoteDomain + '/Software/ResultsManager/web/resources/assets/';
		}

		// Constructor to let us initialise our states
		public function ProgressView() {
			super();
		}
		
		protected override function commitProperties():void {
			super.commitProperties();	
			
			// We can't rely on partAdded due to caching, so do the injection here too
			if (progressScoreView)
				progressScoreView.courseClass = currentCourseClass;
			
			if (progressCoverageView)
				progressCoverageView.courseClass = currentCourseClass;
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case progressNavBar:
					progressNavBar.dataProvider = new ArrayCollection( [
						{ label: "My coverage", data: "coverage" },
						{ label: "Compare", data: "compare" },
						{ label: "Analyse", data: "analysis" },
						{ label: "My scores", data: "score" },
					] );
					
					progressNavBar.requireSelection = true;
					progressNavBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
				
				case progressCoverageView:
				case progressScoreView:
				case progressCompareView:
				case progressAnalysisView:
					// #234
					instance.productVersion = productVersion;
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
			
			return state;
			//return state + ((productVersion == IELTSApplication.DEMO) ? "_demo" : "");
		}
		
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onNavBarIndexChange(event:Event):void {
			invalidateSkinState(); // #301
		}
		
		[Bindable]
		public function get user():User {
			return _user;
		}
		
		public function set user(value:User):void {
			if (_user != value) {
				_user = value;
			}
			if (Number(_user.id) < 1) {
				anonWarning.visible = true;
			}
		}

	}
}