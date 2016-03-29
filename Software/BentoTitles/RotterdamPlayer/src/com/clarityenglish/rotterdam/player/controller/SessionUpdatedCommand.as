/*
Simple Command - PureMVC
*/
package com.clarityenglish.rotterdam.player.controller {
	
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.ProgressProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	/**
	 * gh#954 The session record might have been updated
	 */
	public class SessionUpdatedCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;

			// TODO gh#1452 though nothing to do with that fix - when you stay on a course for >1 min
			// this is called, but not with a note
			if (note)
			    if (configProxy.getConfig().sessionID != note.getBody().sessionID)
    				progressProxy.sessionIdChanged(note.getBody().sessionID);
		}
		
	}
}