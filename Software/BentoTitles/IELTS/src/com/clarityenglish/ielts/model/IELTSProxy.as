package com.clarityenglish.ielts.model {
	
	import com.clarityenglish.bento.model.BentoProxy;
	
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
	public class IELTSProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "IELTSProxy";
		
		private var _currentCourseClass:String;
		
		public function IELTSProxy() {
			super(NAME);
		}
		
		/**
		 * This gets the course class that any view is currently working with. If there is no class, this will return the first one in the menu.
		 * 
		 * @return 
		 */
		public function get currentCourseClass():String {
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			if (!_currentCourseClass)
				_currentCourseClass = bentoProxy.menuXHTML..course[0].@["class"];
			return _currentCourseClass;
		}
		
		public function set currentCourseClass(value:String):void {
			_currentCourseClass = value;
		}
			
	}
		
}