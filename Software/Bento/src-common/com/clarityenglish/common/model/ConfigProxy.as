/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
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
		
		// TODO. Make a config class to hold all this info
		//private var config:XML;
		//private var parameters:Array;
		//private var RMSettings:Object;
		private var config:Config;
		
		/**
		 * Configuration information comes from three sources
		 * 1) config.xml. This holds base paths and other information that is common to all accounts, but differs between products
		 * 2) parameters passed from the start page or command line. This is specific to this account or this user or this session
		 * 3) details from the database for this account. Specific to this account.
		 * 
		 * Get it in the above order as, in theory, each could override the previous, though in practice this doesn't happen
		 */
		
		public function ConfigProxy(data:Object = null) {
			super(NAME, data);
			
			config = new Config();
			// You might have passed a special config file as a paramter. If not, use a default name and path.
			// The path should actually be the same folder as the start page, /area1/RoadToIELTS2
			if (FlexGlobals.topLevelApplication.parameters.configFile) {
				var configFile:String = FlexGlobals.topLevelApplication.parameters.configFile;
			} else {
				configFile = "config.xml";
			}
			getConfigFile(configFile);
		}
		
		/**
		 * Method to get details sent on the command line, or from the start page
		 * 
		 */
		private function getApplicationParameters():void {
			
			/**
			 *  Use what is passed from start page or command line
			 */
			config.mergeParameters(FlexGlobals.topLevelApplication.parameters);

			// Trigger the database call
			getRMSettings();
		}
		/**
		 * Method to get details about the account from the database
		 * 
		 */
		private function getRMSettings():void {
			var params:Array = [ config ];
			// new RemoteDelegate("getRMSettings", params, this).execute();
			onDelegateResult("getRMSettings", {status:"success", account:{rootID:"163", name:'Clarity', loginOptions:2, verified:true, licenceStartDate:100, licenceExpiryDate:999999999}});
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
			//config = new XML(e.target.data);
			config.mergeFileData(new XML(e.target.data));
			getApplicationParameters();
		}
		
		public function errorHandler(e:IOErrorEvent):void {
			log.error("Problem loading the config file: {0}", e.text);
		}
		
		// Then methods to get the configuration data
		public function getContentPath():String {
			return config.paths.content;
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				case "getRMSettings":
					if (data) {
						config.mergeAccountData(data);
						// At this point we can check to see if the config contains anything that stops us going on
						// This account doesn't have this title
						if (config.noSuchTitle())
							var error:BentoError = new BentoError(BentoError.ERROR_NO_SUCH_ACCOUNT);
						if (config.accountSuspended())
							error = new BentoError(BentoError.ERROR_ACCOUNT_SUSPENDED);
						if (config.licenceInvalid())
							error = new BentoError(BentoError.ERROR_LICENCE_INVALID);
						if (config.licenceExpired())
							error = new BentoError(BentoError.ERROR_LICENCE_EXPIRED);
						if (config.licenceNotStarted())
							error = new BentoError(BentoError.ERROR_LICENCE_NOT_STARTED);
						if (config.termsNotAccepted())
							error = new BentoError(BentoError.ERROR_TERMS_NOT_ACCEPTED);
						if (config.outsideIPRange())
							error = new BentoError(BentoError.ERROR_OUTSIDE_IP_RANGE);
						if (config.outsideRURange())
							error = new BentoError(BentoError.ERROR_OUTSIDE_RU_RANGE);
					} else {
						// Can't read from the database
						error = new BentoError(BentoError.ERROR_DATABASE_READING);
					}
					if (error) {
						sendNotification(CommonNotifications.CONFIG_ERROR, error);
					} else {
						sendNotification(CommonNotifications.CONFIG_LOADED);
					}
					break;
				default:
					sendNotification(CommonNotifications.TRACE_ERROR, "Result from unknown operation: " + operation);
			}
		}
		
		public function onDelegateFault(operation:String, data:Object):void{
			sendNotification(CommonNotifications.TRACE_ERROR, data);
		}
		

	}
}
