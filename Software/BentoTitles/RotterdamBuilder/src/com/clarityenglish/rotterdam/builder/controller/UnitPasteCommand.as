package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.model.DataProxy;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class UnitPasteCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			
			var clipboard:Object = dataProxy.get("clipboard");
			if (clipboard && clipboard.type == "unit") {
				courseProxy.unitCollection.addItem(clipboard.xml);
			}
		}
		
	}
	
}