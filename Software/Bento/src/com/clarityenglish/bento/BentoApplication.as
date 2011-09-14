package com.clarityenglish.bento {
	import com.clarityenglish.textLayout.util.TLF2Application;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	
	import org.davekeen.util.ClassUtil;

	public class BentoApplication extends TLF2Application {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function BentoApplication() {
			// Configure logging
			var logTarget:TraceTarget = new TraceTarget();
			logTarget.filters = [ "*" ];
			logTarget.level = LogEventLevel.ALL;
			logTarget.includeDate = false;
			logTarget.includeTime = false;
			logTarget.includeCategory = true;
			logTarget.includeLevel = true;
			Log.addTarget(logTarget);
			
			creationPolicy = "none";
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function get facade():BentoFacade {
			throw new Error("This must be overriden by the child BentoApplication");
		}
		
		private function onAddedToStage(event:Event):void {
			log.info("Added to stage");
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.addEventListener(Event.ADDED_TO_STAGE, onViewAddedToStage, true);
			stage.addEventListener(Event.REMOVED_FROM_STAGE, onViewRemovedFromStage, true);
			
			createDeferredContent();
		}
		
		private function onViewAddedToStage(event:Event):void {
			facade.onViewAdded(event.target);
		}
		
		private function onViewRemovedFromStage(event:Event):void {
			facade.onViewRemoved(event.target);
		}
		
	}
}