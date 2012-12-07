package com.clarityenglish.rotterdam.controller {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class CourseStartCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			log.info("Course started");
			
			// The current course is the loaded menuXHTML in BentoProxy
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			facade.sendNotification(RotterdamNotifications.COURSE_STARTED, bentoProxy.menuXHTML);
		}
		
	}
	
}