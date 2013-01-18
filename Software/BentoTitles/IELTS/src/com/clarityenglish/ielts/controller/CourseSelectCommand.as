package com.clarityenglish.ielts.controller {
	import com.clarityenglish.bento.model.DataProxy;
	
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
			
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			dataProxy.set("currentCourseClass", note.getBody() as String);
		}
		
	}
	
}