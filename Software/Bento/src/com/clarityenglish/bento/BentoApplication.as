package com.clarityenglish.bento {
	import com.clarityenglish.textLayout.util.TLF2Application;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;

	public class BentoApplication extends TLF2Application {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function BentoApplication() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		protected function get facade():BentoFacade {
			throw new Error("This must be overriden by the child BentoApplication");
		}
		
		private function onAddedToStage(event:Event):void {
			trace(stage);
			
			//stage.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			//stage.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			//log.info("Added to stage: {0}", event.target);
			//facade.onViewAdded(event.target);
		}
		
		private function onRemovedFromStage(event:Event):void {
			//log.info("Removed from stage: {0}", event.target);
			//facade.onViewRemoved(event.target);
		}
		
		private function onCreationComplete(event:FlexEvent):void {
			trace("creation complete");
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			// Start the PureMVC framework
			facade.sendNotification(BBNotifications.STARTUP, this);
		}
		
	}
}