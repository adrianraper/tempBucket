package com.clarityenglish.ielts.controller {
	import com.clarityenglish.ielts.IELTSNotifications;
	import com.clarityenglish.ielts.model.IELTSProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	
	public class CourseSelectCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var ieltsProxy:IELTSProxy = facade.retrieveProxy(IELTSProxy.NAME) as IELTSProxy;
			ieltsProxy.currentCourseClass = note.getBody() as String;
			
			sendNotification(IELTSNotifications.COURSE_CLASS_SELECTED, ieltsProxy.currentCourseClass);
		}
		
	}
	
}