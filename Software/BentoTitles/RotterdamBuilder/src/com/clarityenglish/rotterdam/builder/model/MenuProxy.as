package com.clarityenglish.rotterdam.builder.model {
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * This is used for interacting with the LMS through SCORM.
	 *
	 * @author Clarity
	 */
	public class MenuProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "MenuProxy";
		
		private var _xml:XML;
		
		public function MenuProxy() {
			super(NAME);
		}
		
		public function get xml():XML {
			return _xml;
		}
		
	}

}
