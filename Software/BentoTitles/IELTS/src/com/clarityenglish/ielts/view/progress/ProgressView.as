package com.clarityenglish.ielts.view.progress {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.ielts.view.progress.components.ProgressAnalysisView;
	import com.clarityenglish.ielts.view.progress.components.ProgressCompareView;
	import com.clarityenglish.ielts.view.progress.components.ProgressCoverageView;
	import com.clarityenglish.ielts.view.progress.components.ProgressScoreView;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.davekeen.util.ClassUtil;
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
		public var progressScoreView:ProgressScoreView;

		[SkinPart]
		public var progressCompareView:ProgressCompareView;
		
		[SkinPart]
		public var progressAnalysisView:ProgressAnalysisView;
		
		[SkinPart]
		public var progressCoverageView:ProgressCoverageView;

		public var currentCourseClass:String;
		private var _licenceType:uint;

		// Constructor to let us initialise our states
		public function ProgressView() {
			super();
			
			// The first one listed will be the default
			StateUtil.addStates(this, [ "coverage", "compare", "analysis" , "score" ], true);
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
				
				case progressScoreView:
				case progressCoverageView:
					// Just two views use currentCourseClass
					instance.courseClass = currentCourseClass;
				case progressCompareView:
				case progressAnalysisView:
					// All the sub views run off the same href as the progress view, so directly inject it 
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
		
		[Bindable]
		public function get licenceType():uint {
			return _licenceType;
		}
		public function set licenceType(value:uint):void {
			if (_licenceType != value) {
				_licenceType = value;
			}
		}
		
	}
}