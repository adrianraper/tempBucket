package com.clarityenglish.bento.model {
	import com.clarityenglish.bento.BBNotifications;
	
	import flash.utils.Dictionary;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * This is used for storing arbitrary key/value data.
	 */
	public class DataProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "DataProxy";
		
		private var defaultFunctions:Dictionary;
		
		public function DataProxy() {
			super(NAME);
			
			data = new Dictionary();
			defaultFunctions = new Dictionary();
		}
		
		public function get(key:String):Object {
			if (data[key]) return data[key];
			
			if (defaultFunctions[key]) {
				data[key] = defaultFunctions[key](facade);
				return data[key];
			}
			
			return null;
		}
		
		public function getString(key:String):String {
			return get(key) as String;
		}
		
		public function set(key:String, value:Object):void {
			data[key] = value;
			
			log.info("Set {0}={1}", key, value);
			
			sendNotification(BBNotifications.DATA_CHANGED, value, key);
		}
		
		/**
		 * Set a function that will be called to generate a default if there is no value for the given key.
		 * 
		 * @param key The key that this will be the default function for
		 * @param defaultFunction A function with interface: function(facade:Facade):Object
		 */
		public function setDefaultFunction(key:String, defaultFunction:Function):void {
			defaultFunctions[key] = defaultFunction;
		}
		
	}
	
}