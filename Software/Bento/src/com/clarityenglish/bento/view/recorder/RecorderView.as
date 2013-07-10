package com.clarityenglish.bento.view.recorder {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
	
	import mx.controls.ProgressBar;
	
	import org.davekeen.util.StateUtil;
	
	import spark.components.Label;
	
	public class RecorderView extends BentoView {
		
		[SkinPart(required="true")]
		public var recordWaveformView:WaveformView;
		
		[SkinPart(required="true")]
		public var compareWaveformView:WaveformView;
		
		[SkinPart(required="true")]
		public var progressLabel:Label;
		
		[SkinPart(required="true")]
		public var progressBar:ProgressBar;
		
		public function RecorderView() {
			StateUtil.addStates(this, [ "minimized", "full", "compare", "progress" ], true);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case recordWaveformView:
					recordWaveformView.addEventListener(RecorderEvent.MINIMIZE, onMinimize, false, 0, true);
					recordWaveformView.addEventListener(RecorderEvent.MAXIMIZE, onMaximize, false, 0, true);
					recordWaveformView.addEventListener(RecorderEvent.COMPARE, onCompare, false, 0, true);
					break;
			}
		}
		
		protected function onMinimize(event:RecorderEvent):void {
			currentState = "minimized";
		}
		
		protected function onMaximize(event:RecorderEvent):void {
			currentState = "full";
		}
		
		protected function onCompare(event:RecorderEvent):void {
			currentState = "compare";
			dispatchEvent(event.clone());
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}