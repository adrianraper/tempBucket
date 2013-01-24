/*
Simple Command - PureMVC
*/
package com.clarityenglish.common.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.CommonNotifications;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
	
	/**
	 * SimpleCommand
	 */
	public class LoggedInCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var data:Object = note.getBody();
		}
		
	}
}