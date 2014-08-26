/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	import com.clarityenglish.common.model.CopyProxy;
	
	import flash.net.SharedObject;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class CopyLoadCommand extends SimpleCommand {		
		override public function execute(note:INotification):void {
			var copyProxy:CopyProxy = facade.retrieveProxy(CopyProxy.NAME) as CopyProxy;
			
			// gh#58 - if there is a language code stored in the shared object then overwrite the existing one
			var settingsSharedObject:SharedObject = SharedObject.getLocal("settings");
			if (settingsSharedObject.data["languageCode"]) {
				CopyProxy.languageCode = settingsSharedObject.data["languageCode"];
			}
			copyProxy.getCopy();
		}
		
	}
}