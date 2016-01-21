package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.model.CopyProxy;
import com.clarityenglish.common.model.LoginProxy;
import com.clarityenglish.common.vo.manageable.User;

import flash.net.SharedObject;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class LanguageChangeCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var languageCode:String = note.getBody().toString();
			
			if (languageCode != CopyProxy.languageCode) {
				var settingsSharedObject:SharedObject = SharedObject.getLocal("settings");
				// gh#612 this needs to be keyed on the userID
				//settingsSharedObject.data["languageCode"] = languageCode;
				var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
				var user:User = loginProxy.user; 
				settingsSharedObject.data["preferences.languageCode." + user.userID] = languageCode;
				settingsSharedObject.flush();
				
				CopyProxy.languageCode = languageCode;
				
				sendNotification(BBNotifications.LANGUAGE_CHANGED, languageCode);
			}
		}
		
	}
	
}