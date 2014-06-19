package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.XmlUtils;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class CourseImportedCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			
			// This is very hacky; remove the namespace.  Namespaces in general need to be sorted out.
			var xmlString:String = note.getBody().toString();
			xmlString = xmlString.replace(" xmlns=\"http://www.w3.org/1999/xhtml\"", "");
			var returnedXml:XML = new XML(xmlString);
			
			// The returned XML contains unit nodes that we want to merge into our main menu.xml
			for each (var unitNode:XML in returnedXml..unit)
				sendNotification(RotterdamNotifications.UNIT_COPY, unitNode);
			
			sendNotification(BBNotifications.INFORMATION_SHOW, {text: copyProvider.getCopyForId("importedUnits", {numberOfUnits: returnedXml..unit.length()})}, 'status');
		}
		
	}
	
}