package com.clarityenglish.bento.view.recorder {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.recorder.events.RecorderEvent;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

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

		[SkinPart]
        [Bindable]
		public var moreDetailsLabel:Label;
		public var micDetails:String;

		public function RecorderView() {
			StateUtil.addStates(this, [ "minimized", "full", "compare", "progress", "nomic" ], true);
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case recordWaveformView:
					recordWaveformView.addEventListener(RecorderEvent.MINIMIZE, onMinimize, false, 0, true);
					recordWaveformView.addEventListener(RecorderEvent.MAXIMIZE, onMaximize, false, 0, true);
					recordWaveformView.addEventListener(RecorderEvent.COMPARE, onCompare, false, 0, true);
					recordWaveformView.addEventListener(RecorderEvent.HELP, onHelp, false, 0, true);
                    // gh#1348
                    recordWaveformView.setCopyProvider(copyProvider);
					break;
                case compareWaveformView:
                    // gh#1348
                    compareWaveformView.setCopyProvider(copyProvider);
                    break;
                case moreDetailsLabel:
                    moreDetailsLabel.text = copyProvider.getCopyForId(micDetails);
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
		
		protected function onHelp(event:RecorderEvent):void {
			var url:String = copyProvider.getCopyForId("recorderHelpURL");
			var urlRequest:URLRequest = new URLRequest(url);
			navigateToURL(urlRequest, "_blank");
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}