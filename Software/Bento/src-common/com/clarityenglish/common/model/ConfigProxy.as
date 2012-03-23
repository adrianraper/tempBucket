﻿/*
Proxy - PureMVC
*/
package com.clarityenglish.common.model {
	
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.dms.vo.account.Account;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.formatters.DateFormatter;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;
	import mx.utils.URLUtil;
	
	import org.davekeen.delegates.IDelegateResponder;
	import org.davekeen.delegates.RemoteDelegate;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * A proxy
	 */
	public class ConfigProxy extends Proxy implements IProxy, IDelegateResponder {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public static const NAME:String = "ConfigProxy";
		
		private var config:Config;
		
		private var _dateFormatter:DateFormatter;

		/**
		 * Configuration information comes from three sources
		 * 1) config.xml. This holds base paths and other information that is common to all accounts, but differs between products
		 * 2) parameters passed from the start page or command line. This is specific to this account or this user or this session
		 * 3) details from the database for this account. Specific to this account.
		 * 
		 * Get it in the above order as, in theory, each could override the previous, though in practice this doesn't happen.
		 */
		public function ConfigProxy(data:Object = null) {
			super(NAME, data);
			
			_dateFormatter = new DateFormatter();
			_dateFormatter.formatString = "D MMMM YYYY";
			
			config = new Config();
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
			getAccountSettings();
			
		}
		/**
		 * Method to get details about the account from the database
		 *
		 * @return void - Asynchronous call. Will return account, title, config and error objects. 
		 */
		private function getAccountSettings():void {
			// TODO. Do you need to check that the remote gateway is up and running since we only just set it?
			
			if (Config.DEVELOPER.name == "DK") {
				config.prefix = "Clarity";
			}
			
			// Create a subset of the config object to pass to the remote call
			// I could do some error handling before we go
			//	we must have rootID or prefix (prefix is most likely)
			//	we must have a productCode
			//  and it isn't nice to send NaN as rootID
			var dbConfig:Object = { dbHost: config.dbHost, prefix: config.prefix, rootID: config.rootID, productCode: config.productCode };
			var params:Array = [ dbConfig ];
			new RemoteDelegate("getAccountSettings", params, this).execute();
			//onDelegateResult("getAccountSettings", {status:"success", account:{rootID:"163", name:'Clarity', loginOptions:2, verified:true, licenceStartDate:100, licenceExpiryDate:999999999}});
		}
		
		/**
		 * Reads the config file. Assume that this is given or picked up from application parameters.
		 *
		 * @param	filename
		 * @return
		 */
		public function loadConfig(filename:String = null):void {
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			urlLoader.addEventListener(Event.COMPLETE, onConfigLoadComplete);
			
			try {
				log.info("Open config file: {0}", filename);
				// Once the system is stable we might drop the cache clearer
				urlLoader.load(new URLRequest(filename + "?cache=" + new Date().getTime()));
			} catch (e:SecurityError) {
				log.error("A SecurityError has occurred for the config file {0}", filename);
			}
		}
		
		public function onConfigLoadComplete(e:Event):void {
			//config = new XML(e.target.data);
			config.mergeFileData(new XML(e.target.data));
			
			// Configure the delegate now that you have the gateway path 
			RemoteDelegate.setGateway(config.remoteGateway + "gateway.php");
			RemoteDelegate.setService(config.remoteService);
			
			// Next stage is to get data from the database
			getApplicationParameters();
		}
		
		public function errorHandler(e:IOErrorEvent):void {
			log.error("Problem loading the config file: {0}", e.text);
		}

		// Then methods to get parts of the configuration data
		public function getMenuFilename():String {
			//return "menu-Academic-LastMinute.xml";
			return config.paths.menuFilename;
		}
		
		public function getContentPath():String {
			return config.paths.content;
		}
		
		public function getAccount():Account {
			return config.account;
		}
		
		public function getUserID():String {
			return config.userID;
		}
		
		public function getInstanceID():String {
			return config.instanceID;
		}
		
		public function getProductVersion():String {
			return config.productVersion;
		}
		
		public function getProductCode():uint {
			return config.productCode;
		}
		
		public function getLicenceType():uint {
			return config.licenceType;
		}
		
		// Is it OK to just get the config object?
		public function getConfig():Config {
			return config;
		}
		
		public function getDateFormatter():DateFormatter {
			return _dateFormatter;
		}
		
		/**
		 * Direct login is implemented here. If a LoginEvent is returned then the application should log straight in without showing a login screen.
		 * 
		 * @return 
		 */
		public function getDirectLogin():LoginEvent {
			if (Config.DEVELOPER.name == "DK") {
				return new LoginEvent(LoginEvent.LOGIN, "dandelion", "password")
			}
			
			if (Config.DEVELOPER.name == "AR") {
				return new LoginEvent(LoginEvent.LOGIN, "adrian raper", "passwording")
			}
			// take it from config rather than direct from the parameters
			//if (FlexGlobals.topLevelApplication.parameters.studentID &&
			//	FlexGlobals.topLevelApplication.parameters.password) {
			if (config.studentID) {
				return new LoginEvent(LoginEvent.LOGIN, config.studentID, config.password);
			}

			// Anonymous login
			if (config.licenceType == Title.LICENCE_TYPE_AA) 
				return new LoginEvent(LoginEvent.LOGIN, null, null)

			return null;
		}
		
		/**
		 * Direct start is implemented here.  This will be implemented by the titles, so there are no rules about what kind of object should be returned
		 * from this method.  This is to allow any kind of direct starting (which may depend on the structure of the title).
		 * 
		 * @return 
		 */
		public function getDirectStart():Object {
			if (Config.DEVELOPER.name == "DK") {
				//return { courseClass: "reading" };
				//return { exerciseId: "1156165919121" };
			}
			if (Config.DEVELOPER.name == "AR") {
			//	return { exerciseId: "1156181253997" }; // Writing>Set 1 task 2>Linking words and phrases (1)
			//	return { exerciseId: "1156153794077" }; // Speaking>The speaking test (2)
			}
			
			return null;
		}
		
		/* INTERFACE org.davekeen.delegates.IDelegateResponder */
		public function onDelegateResult(operation:String, data:Object):void{
			switch (operation) {
				
				case "getAccountSettings":
					if (data) {
						// TODO. We should be able to set the language code for 
						//CopyProxy.languageCode = data.languageCode as String;
						/*
						We will get back the following objects in data
						account
						error - should this be called status and include info/warning/error objects?
						config
						<db>
							<note>
								<query dbHost="2" method="getRMSettings" rootID="" prefix="Clarity" eKey="" dateStamp="2011-10-17 22:50:42" productCode="9" cacheVersion="1318863042928" />
							</note>
							<note>dbhost=localhost dbname=rack80829 driver=mysql</note>
							<database version="6" />
							<settings loginOption="1" verified="1" selfRegister="0" />
							<decrypt key="undefined" />
							<account expiryDate="2012-12-31 23:59:59" maxStudents="998" groupID="163" rootID="163" licenceType="1" institution="Clarity Language Consultants Ltd" contentLocation="TenseBuster-International" MGSRoot="" licenceStartDate="2009-01-01 00:00:00" checksum="351669aed74a984aa13f8501ecdcadcd7c8f61b3cad49eaf4611a4510abfe85e" languageCode="EN" />
						</db>
						*/
						config.mergeAccountData(data);
						
						config.checkErrors();

						// TODO. This account doesn't have this title error DOESN'T stop us at this point.
						// At this point we can check to see if the config contains anything that stops us going on
						// This account doesn't have this title
						/* I don't see the value of doing this like this - just grab the error and throw it out
							Unless you want to only do that for some types of error?
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
						if (config.outsideRURange())
							error = new BentoError(BentoError.ERROR_OUTSIDE_RU_RANGE);
						if (config.outsideIPRange())
							error = new BentoError(BentoError.ERROR_OUTSIDE_IP_RANGE);
						*/
						if (config.anyError())
							var error:BentoError = config.error;
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
