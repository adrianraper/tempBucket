package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class DataProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "DataProxy";
		
		public function DataProxy() {
			super(NAME);
			
			data = new Dictionary();
		}
		
		public function get(key:String):Object {
			return (data[key]) ? data[key] : null;
		}
		
		public function set(key:String, value:Object):void {
			data[key] = value;
			
			sendNotification(BBNotifications.DATA_KEY_CHANGED, key);
		}
		
	}
	
}