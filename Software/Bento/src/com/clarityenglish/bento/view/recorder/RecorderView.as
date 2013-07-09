package com.clarityenglish.bento.view.recorder {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.view.recorder.ui.LevelMeter;
	
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.supportClasses.SliderBase;
	
	public class RecorderView extends BentoView {
		
		[SkinPart]
		public var recordButton:Button;
		
		[SkinPart]
		public var stopButton:Button;
		
		[SkinPart]
		public var playButton:Button;
		
		[SkinPart]
		public var pauseButton:Button;
		
		[SkinPart]
		public var scrubBar:SliderBase;
		
		[SkinPart]
		public var levelMeter:LevelMeter;
		
		public var record:Signal = new Signal();
		public var stop:Signal = new Signal();
		public var play:Signal = new Signal();
		public var pause:Signal = new Signal();
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case recordButton:
					recordButton.addEventListener(MouseEvent.CLICK, onRecordButtonClick);
					break;
				case stopButton:
					stopButton.addEventListener(MouseEvent.CLICK, onStopButtonClick);
					break;
				case playButton:
					playButton.addEventListener(MouseEvent.CLICK, onPlayButtonClick);
					break;
				case pauseButton:
					pauseButton.addEventListener(MouseEvent.CLICK, onPauseButtonClick);
					break;
			}
		}
		
		protected function onRecordButtonClick(event:MouseEvent):void {
			record.dispatch();
		}
		
		protected function onStopButtonClick(event:MouseEvent):void {
			stop.dispatch();
		}
		
		protected function onPlayButtonClick(event:MouseEvent):void {
			play.dispatch();
		}
		
		protected function onPauseButtonClick(event:MouseEvent):void {
			pause.dispatch();
		}
		
	}
}