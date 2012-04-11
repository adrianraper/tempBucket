package com.clarityenglish.ielts.controller {
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class IELTSRegisterCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// #299
			navigateToURL(new URLRequest("http://www.ieltspractice.com"), "_blank");
		}
		
	}
}
