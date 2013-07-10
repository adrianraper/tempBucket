package com.clarityenglish.bento.view.recorder {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.recorder.events.WaveformEvent;
	import com.clarityenglish.bento.view.recorder.ui.LevelMeter;
	
	import flash.events.MouseEvent;
	
	import org.davekeen.util.StateUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.supportClasses.SliderBase;
	
	public class RecorderView extends BentoView {
		
		[SkinPart(required="true")]
		public var recordWaveformView:WaveformView;
		
		public function RecorderView() {
			StateUtil.addStates(this, [ "minimized", "full", "compare" ], true);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case recordWaveformView:
					recordWaveformView.addEventListener(WaveformEvent.MINIMIZE, onMinimize, false, 0, true);
					recordWaveformView.addEventListener(WaveformEvent.MAXIMIZE, onMaximize, false, 0, true);
					break;
			}
		}
		
		protected function onMinimize(event:WaveformEvent):void {
			currentState = "minimized";
		}
		
		protected function onMaximize(event:WaveformEvent):void {
			currentState = "full";
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}