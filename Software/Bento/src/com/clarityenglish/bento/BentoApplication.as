package com.clarityenglish.bento {
	import com.clarityenglish.bento.vo.content.model.answer.Feedback;
	import com.clarityenglish.textLayout.util.TLF2Application;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	
	import org.davekeen.util.ClassUtil;

	public class BentoApplication extends TLF2Application {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public var isCtrlDown:Boolean;
		
		public function BentoApplication() {
			// Configure logging
			var logTarget:TraceTarget = new TraceTarget();
			logTarget.filters = [ "com.*", "org.*", "AnswerableBehaviour.*" ];
			logTarget.level = LogEventLevel.ALL;
			logTarget.includeDate = false;
			logTarget.includeTime = false;
			logTarget.includeCategory = true;
			logTarget.includeLevel = true;
			Log.addTarget(logTarget);
			
			creationPolicy = "none";
			
			// Create deferred content with maximum priority so that this happens before any other ADDED_TO_STAGE listeners fire
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, int.MAX_VALUE);
		}
		
		protected function get facade():BentoFacade {
			throw new Error("This must be overriden by the child BentoApplication");
		}
		
		private function onAddedToStage(event:Event):void {
			log.info("Added to stage");
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.addEventListener(Event.ADDED_TO_STAGE, onViewAddedToStage, true);
			stage.addEventListener(Event.REMOVED_FROM_STAGE, onViewRemovedFromStage, true);
			
			// Top level listeners to detect whether keys are held down (used by WordClickCommand to determine if ctrl is pressed)
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			createDeferredContent();
		}
		
		private function onViewAddedToStage(event:Event):void {
			facade.onViewAdded(event.target);
		}
		
		private function onViewRemovedFromStage(event:Event):void {
			facade.onViewRemoved(event.target);
		}
		
		protected function onKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.CONTROL) isCtrlDown = true;
		}
		
		protected function onKeyUp(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.CONTROL) isCtrlDown = false;
		}
		
	}
}