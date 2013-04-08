package com.clarityenglish.bento {
	import caurina.transitions.properties.CurveModifiers;
	import caurina.transitions.properties.DisplayShortcuts;
	
	import com.clarityenglish.textLayout.util.TLF2Application;
	
	import flash.display.StageQuality;
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
		
		[Bindable]
		public var versionNumber:String = "(unknown)";
		
		public static const DEMO:String = "DEMO";
		
		public var isCtrlDown:Boolean;
		
		protected var facade:BentoFacade;
		
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
			
			// Initialize some Tweener plugins
			DisplayShortcuts.init();
			CurveModifiers.init();
			
			// Create deferred content with maximum priority so that this happens before any other ADDED_TO_STAGE listeners fire
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, int.MAX_VALUE);
			
			// Listen for activation
			addEventListener(Event.ACTIVATE, onActivate);
		}
		
		// #472 - check instantly on activation
		protected function onActivate(event:Event):void {
			facade.sendNotification(BBNotifications.NETWORK_CHECK_AVAILABILITY);
		}
		
		private function onAddedToStage(event:Event):void {
			log.info("Added to stage");
			
			stage.quality = StageQuality.BEST;
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.addEventListener(Event.ADDED_TO_STAGE, onViewAddedToStage, true);
			stage.addEventListener(Event.REMOVED_FROM_STAGE, onViewRemovedFromStage, true);
			
			// Top level listeners to detect whether keys are held down (used by WordClickCommand to determine if ctrl is pressed)
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			createDeferredContent();
		}
		
		private function onViewAddedToStage(event:Event):void {
			if (facade) {
				facade.onViewAdded(event.target);
			} else {
				log.error("facade is not defined");
			}
		}
		
		private function onViewRemovedFromStage(event:Event):void {
			if (facade) {
				facade.onViewRemoved(event.target);
			} else {
				log.error("facade is not defined");
			}
		}
		
		protected function onKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.CONTROL) isCtrlDown = true;
		}
		
		protected function onKeyUp(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.CONTROL) isCtrlDown = false;
		}
		
		protected override function getCurrentSkinState():String {
			return currentState;
		}
		
	}
}