package com.clarityenglish.ielts.view.progress {
	import com.anychart.AnyChartFlex;
	import com.anychart.mapPlot.controls.zoomPanel.Slider;
	import com.anychart.viewController.ChartView;
	import com.clarityenglish.bento.view.base.BentoView;
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
	public class ProgressView extends BentoView {

		[SkinPart]
		public var progressNavBar:ButtonBar;
		
		[SkinPart]
		public var progressScoreView:ProgressScoreView;

		[SkinPart]
		public var progressCompareView:ProgressCompareView;
		
		[Embed(source="skins/ielts/assets/assets.swf", symbol="ProgressIcon")]
		private var progressIcon:Class;
		
		private var _fullChartXML:XML;
		private var _everyoneSummary:Array;
		private var _mySummary:Array;
		private var _myDetails:ArrayCollection;
		
		public var mySummaryDataLoaded:Signal = new Signal(Array);
		public var everyoneSummaryDataLoaded:Signal = new Signal(Array);
		public var myDetailsDataLoaded:Signal = new Signal(ArrayCollection);
		
		// Constructor to let us initialise our states
		public function ProgressView() {
			super();
			
			// The first one listed will be the default - really?
			StateUtil.addStates(this, [ "score", "compare" ], true);
		}
		
		protected override function commitProperties():void {
			super.commitProperties();		
		}
		
		// A common function for all of the progress charts
		public function initCharts(chartTemplateXML:XML):void {
			_fullChartXML = chartTemplateXML;
		}
		// Holding the progress data for all sub-views
		// We should send a signal with this data so that IF a view that wants to use it is waiting
		// it will pick it up and just add it in
		public function setMySummaryDataProvider(dataProvider:Array):void {
			_mySummary = dataProvider;
			mySummaryDataLoaded.dispatch(dataProvider);
		}
		public function setEveryoneSummaryDataProvider(dataProvider:Array):void {
			_everyoneSummary = dataProvider;
			everyoneSummaryDataLoaded.dispatch(dataProvider);
		}
		public function setMyDetailsDataProvider(dataProvider:ArrayCollection):void {
			_myDetails = dataProvider;
			myDetailsDataLoaded.dispatch(dataProvider);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			switch (instance) {
				case progressNavBar:
					progressNavBar.dataProvider = new ArrayCollection( [
						{ icon: progressIcon, label: "Your score", data: "score" },
						{ icon: progressIcon, label: "Compare", data: "compare" },
					] );
					
					progressNavBar.requireSelection = true;
					progressNavBar.addEventListener(Event.CHANGE, onNavBarIndexChange);
					break;
				case progressScoreView:
					if (_myDetails) {
						instance.setDataProvider(_myDetails);
					}
					break;
				case progressCompareView:
					// Inject any data you already have into the sub views
					if (_fullChartXML) {
						instance.initCharts(_fullChartXML);
					}
					if (_mySummary) {
						instance.setMySummaryDataProvider(_mySummary);
					}
					if (_everyoneSummary) {
						instance.setEveryoneSummaryDataProvider(_everyoneSummary);
					}
					break
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