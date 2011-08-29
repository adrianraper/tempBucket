package com.clarityenglish.bento.view.exercise.ui.behaviours {
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Group;
	
	public class AbstractSectionBehaviour {
		
		/**
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		protected var container:Group;
		
		public function AbstractSectionBehaviour(container:Group) {
			this.container = container;
		}
		
	}
}
