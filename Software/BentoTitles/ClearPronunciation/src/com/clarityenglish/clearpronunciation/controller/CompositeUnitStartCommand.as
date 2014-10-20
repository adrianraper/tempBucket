package com.clarityenglish.clearpronunciation.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class CompositeUnitStartCommand extends SimpleCommand {
		
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			courseProxy.currentUnit = note.getBody().unit as XML;
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			bentoProxy.selectedNode = note.getBody().exercise as XML;
			
			facade.sendNotification(BBNotifications.UNIT_STARTED, courseProxy.currentUnit);
		}
	}
}