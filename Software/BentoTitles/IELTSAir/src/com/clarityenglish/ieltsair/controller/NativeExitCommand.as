/*
Simple Command - PureMVC
 */
package com.clarityenglish.ieltsair.controller {
	import flash.desktop.NativeApplication;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class NativeExitCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			NativeApplication.nativeApplication.exit();
		}
		
	}
}