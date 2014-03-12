package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class PreviewModeCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			if (note.getBody() as Boolean) {
				courseProxy.isPreviewMode = true;
				sendNotification(RotterdamNotifications.PREVIEW_SHOWN);
			} else {
				courseProxy.isPreviewMode = false;
				sendNotification(RotterdamNotifications.PREVIEW_HIDDEN);
			}
			
		}
		
	}
	
}