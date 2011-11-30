/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	import com.clarityenglish.common.model.ConfigProxy;
	
	import mx.core.FlexGlobals;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class ConfigLoadCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			// You might have passed a special config file as a paramter. If not, use a default name and path.
			// The path should actually be the same folder as the start page, /area1/RoadToIELTS2
			if (FlexGlobals.topLevelApplication.parameters.configFile) {
				var configFile:String = FlexGlobals.topLevelApplication.parameters.configFile;
			} else {
				configFile = "config.xml";
			}
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			configProxy.loadConfig(configFile);
		}
		
	}
}