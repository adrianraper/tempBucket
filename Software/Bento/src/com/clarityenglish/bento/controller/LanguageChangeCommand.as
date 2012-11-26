package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	
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
				settingsSharedObject.data["languageCode"] = languageCode;
				settingsSharedObject.flush();
				
				CopyProxy.languageCode = languageCode;
				
				sendNotification(BBNotifications.LANGUAGE_CHANGED, languageCode);
			}
		}
		
	}
	
}