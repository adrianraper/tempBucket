package com.clarityenglish.rotterdam.player.view.progress.ui {
	
	import flash.events.MouseEvent;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.osflash.signals.Signal;
	
	import spark.components.ToggleButton;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class ProgressCourseBarComponent extends SkinnableComponent {

		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		[SkinPart(required="true")]
		public var readingCourseButton:ToggleButton;
		
		[SkinPart(required="true")]
		public var listeningCourseButton:ToggleButton;
		
		[SkinPart(required="true")]
		public var speakingCourseButton:ToggleButton;
		
		[SkinPart(required="true")]
		public var writingCourseButton:ToggleButton;
		
		public var courseSelect:Signal = new Signal(String);
		
		public function ProgressCourseBarComponent() {
			super();
		}
		
		override protected function getCurrentSkinState():String {
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case writingCourseButton:		
				case listeningCourseButton:		
				case readingCourseButton:		
				case speakingCourseButton:	
					instance.addEventListener(MouseEvent.CLICK, onCourseClick);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void {
			super.partRemoved(partName, instance);
			switch (instance) {
				case writingCourseButton:		
				case listeningCourseButton:		
				case readingCourseButton:		
				case speakingCourseButton:	
					instance.removeEventListener(MouseEvent.CLICK, onCourseClick);
					break;
			}
		}
		
		protected function onCourseClick(event:MouseEvent):void {
			courseSelect.dispatch(event.target.label.toLowerCase());
		}
	}
}