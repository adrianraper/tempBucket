/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.core.FlexGlobals;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class ConfigProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "ConfigProxy";
		
		private var config:XML;
		public function ConfigProxy(data:Object = null) {
			super(NAME, data);
			
			//if (FlexGlobals.topLevelApplication.parameters.configFile) {
			//	var configFile:String = FlexGlobals.topLevelApplication.parameters.configFile;
			//} else {
			var configFile:String ='config.xml';
			//}
			getConfigFile(configFile);
		}
		
		/**
		 * Reads the config file. Assume that this is given or picked up from application parameters.
		 * 
		 * @param	filename
		 * @return
		 */
		public function getConfigFile(filename:String=null):void {
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			urlLoader.addEventListener(Event.COMPLETE, onConfigLoadComplete);
			try {
				trace("open config file:" + filename);
				urlLoader.load(new URLRequest(filename));
			}
			catch (error:SecurityError)
			{
				trace("A SecurityError has occurred for the config file " + filename);
			}
		}
		public function onConfigLoadComplete(e:Event):void {
			config = new XML(e.target.data);
		}
		public function errorHandler(e:IOErrorEvent):void {
			trace("Problem loading the config file: " + e);
		}
		// Then methods to get the configuration data
		public function getContentPath():String {
			return config.contentPath;
		}
	}
}