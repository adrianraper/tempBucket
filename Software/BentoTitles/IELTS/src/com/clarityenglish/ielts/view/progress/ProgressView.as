package com.clarityenglish.ielts.view.progress {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.progress.components.ProgressAnalysisView;
	import com.clarityenglish.ielts.view.progress.components.ProgressCompareView;
	import com.clarityenglish.ielts.view.progress.components.ProgressScoreView;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.ButtonBar;
	import spark.components.Label;
	
	[SkinState("score")]
	[SkinState("compare")]
	[SkinState("analysis")]
	[SkinState("coverage")]
	public class ProgressView extends BentoView {

		[SkinPart]
		public var progressNavBar:ButtonBar;
		
		[SkinPart]
		public var progressKeyBar:ButtonBar;
		
		[SkinPart]
		public var progressScoreView:ProgressScoreView;

		[SkinPart]
		public var progressCompareView:ProgressCompareView;
		
		[SkinPart]
		public var progressAnalysisView:ProgressAnalysisView;
		
		[SkinPart]
		public var progressCoverageView:ProgressCoverageView;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="ProgressIcon")]
		private var progressIcon:Class;
		
		// Constructor to let us initialise our states
		public function ProgressView() {
			super();
			
			// The first one listed will be the default - really?
			StateUtil.addStates(this, [ "coverage", "compare", "analysis" , "score" ], true);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();		
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				case progressNavBar:
					progressNavBar.dataProvider = new ArrayCollection( [
						{ icon: progressIcon, label: "My coverage", data: "coverage" },
						{ icon: progressIcon, label: "Compare", data: "compare" },
						{ icon: progressIcon, label: "Analyse", data: "analysis" },
						{ icon: progressIcon, label: "My scores", data: "score" },
					] );
					
					progressNavBar.requireSelection = true;
					progressNavBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
				
				// 1) Can I hijack buttonBar for this?
				// 2) Shoud it be in the individual state skins?
				case progressKeyBar:
					progressKeyBar.dataProvider = new ArrayCollection( [
						{ icon: writingIcon, label: "Writing", data: "writing" },
						{ icon: speakingIcon, label: "Speaking", data: "speaking" },
						{ icon: readingIcon, label: "Reading", data: "reading" },
						{ icon: listeningIcon, label: "Listening", data: "listening" },
					] );
					
					progressKeyBar.requireSelection = true;
					progressKeyBar.addEventListener(Event.CHANGE, onKeyBarIndexChange);
					break;
				
				case progressScoreView:
				case progressCoverageView:
					// These views need to preset a course to start with
					instance.course = menu.course.(@["class"]=='writing')[0];
					// keep going with shared stuff
				case progressCompareView:
				case progressAnalysisView:
					// The sub views run off the same href as the progress view, so directly inject it 
					instance.href = href;
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
		 * 
		 * This shows what state the skin is currently in
		 * 
		 * @return string State name 
		 */
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		/**
		 * When the tab is changed invalidate the skin state to force getCurrentSkinState() to get called again
		 * 
		 * @param event
		 */
		protected function onNavBarIndexChange(event:Event):void {
			// We can set the skin state from the tab bar click
			currentState = event.target.selectedItem.data;
		}
		
	}
}