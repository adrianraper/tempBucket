package com.clarityenglish.bento {
	import com.clarityenglish.textLayout.util.TLF2Application;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.VideoPlayer;
	import spark.skins.spark.VideoPlayerSkin;

	public class BentoApplication extends TLF2Application {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function BentoApplication() {
			// Configure logging
			var logTarget:TraceTarget = new TraceTarget();
			logTarget.filters = [ "com.*", "org.*" ];
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