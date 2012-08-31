/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.config.PerformanceLog;
	
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class PerformanceLogCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {

			var log:PerformanceLog = note.getBody() as PerformanceLog;

			// TODO. Could use config.remoteDomain here
			var url:String = "/Software/Common/lib/php/writeLog.php";
			var request:URLRequest = new URLRequest(url);
			var requestVars:URLVariables = new URLVariables();
			requestVars.method = 'R2I_performance_log';
			// If the start time is server based, then the end time must be too
			if (log.timeTaken() > 0) {
				requestVars.timeTaken = log.timeTaken();
			} else {
				requestVars.startTime = log.startTime;
			}
			
			requestVars.task = log.task;
			if (log.IP)
				requestVars.IP = log.IP;
			if (log.data)
				requestVars.data = log.data;
			
			request.data = requestVars;
			request.method = URLRequestMethod.POST;
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			//trace('write out ' + requestVars.method);
			try {
				urlLoader.load(request);
			} catch (e:Error) {
				trace(e);
			}
		}
	}		
}