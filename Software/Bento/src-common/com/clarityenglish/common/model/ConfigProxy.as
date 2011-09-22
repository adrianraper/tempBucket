/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class ConfigProxy extends Proxy implements IProxy {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "ConfigProxy";
		
		private var config:XML;
		
		public function ConfigProxy(data:Object = null) {
			super(NAME, data);
			
			//if (FlexGlobals.topLevelApplication.parameters.configFile) {
			//	var configFile:String = FlexGlobals.topLevelApplication.parameters.configFile;
			//} else {
			var configFile:String = "config.xml";
			//}
			getConfigFile(configFile);
		}
		
		/**
		 * Reads the config file. Assume that this is given or picked up from application parameters.
		 *
		 * @param	filename
		 * @return
		 */
		public function getConfigFile(filename:String = null):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			urlLoader.addEventListener(Event.COMPLETE, onConfigLoadComplete);
			
			try {
				log.info("Open config file: {0}", filename);
				urlLoader.load(new URLRequest(filename));
			} catch (e:SecurityError) {
				log.error("A SecurityError has occurred for the config file {0}", filename);
			}
		}
		
		public function onConfigLoadComplete(e:Event):void {
			config = new XML(e.target.data);
		}
		
		public function errorHandler(e:IOErrorEvent):void {
			log.error("Problem loading the config file: {0}", e.text);
		}
		
		// Then methods to get the configuration data
		public function getContentPath():String {
			return config.contentPath;
		}
	}
}
