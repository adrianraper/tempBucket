package com.clarityenglish.bento.model {
	import flash.external.ExternalInterface;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * This is used for interacing with the container.
	 * 
	 * @author Dave
	 */
	public class ExternalInterfaceProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "ExternalInterfaceProxy";
		
		public function ExternalInterfaceProxy() {
			super(NAME);
			
			if (ExternalInterface.available) {
				log.debug("Binding external interface callbacks");
				
				ExternalInterface.addCallback("isExerciseDirty", isExerciseDirty);
			} else {
				log.error("External interface is not available in this container");
			}
		}
		
		private function isExerciseDirty():Boolean {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			// If we are not currently in an exercise then it can't be dirty
			if (!bentoProxy.currentExercise) return false;
			
			// Otherwise retrieve the dirty flag from the exercise proxy
			var exerciseProxy:ExerciseProxy = facade.retrieveProxy(ExerciseProxy.NAME(bentoProxy.currentExercise)) as ExerciseProxy;
			return exerciseProxy.exerciseDirty;
		}
		
	}
	
}