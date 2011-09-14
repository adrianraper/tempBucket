package com.clarityenglish.textLayout.components.behaviours {
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	
	import spark.components.Group;
	
	public class AbstractXHTMLBehaviour {
		
		/*
		 * Standard flex logger
		 */
		protected var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		protected var container:Group;
		
		public function AbstractXHTMLBehaviour(container:Group) {
			this.container = container;
		}
		
	}
}