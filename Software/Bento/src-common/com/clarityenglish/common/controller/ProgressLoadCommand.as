﻿/*
Simple Command - PureMVC
 ****
	NOT USED
 ****
 */
package com.clarityenglish.common.controller {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	import com.clarityenglish.common.model.ProgressProxy;
	import com.clarityenglish.common.vo.progress.Progress;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class ProgressLoadCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			//var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			//var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			//var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			//progressProxy.getProgressData(loginProxy.user, configProxy.getAccount(), note.getBody().href as Href, note.getBody().type);
		}
		
	}
}