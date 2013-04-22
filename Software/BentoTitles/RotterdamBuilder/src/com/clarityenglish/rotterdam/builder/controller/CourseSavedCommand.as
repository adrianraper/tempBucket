package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.XmlUtils;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class CourseSavedCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			
			// Disable the dirty watcher in CourseProxy for these operations (gh#90)
			courseProxy.xmlWatcherEnabled = false;
			
			// This is very hacky; remove the namespace.  Namespaces in general need to be sorted out.
			var xmlString:String = note.getBody().toString();
			xmlString = xmlString.replace(" xmlns=\"http://www.w3.org/1999/xhtml\"", "");
			var returnedXml:XML = new XML(xmlString);
			
			// Saving a menu.xml file can cause ids to be inserted on the server, so we need to go through the loaded menu xml inserting ids
			XmlUtils.copyXmlAttributes(returnedXml, bentoProxy.menuXHTML.xml, "course", [ "id" ]);
			XmlUtils.copyXmlAttributes(returnedXml, bentoProxy.menuXHTML.xml, "unit", [ "id" ]);
			XmlUtils.copyXmlAttributes(returnedXml, bentoProxy.menuXHTML.xml, "exercise", [ "id" ]);
			
			// And turn the dirty watcher in CourseProxy back on now that we are done (gh#90)
			courseProxy.xmlWatcherEnabled = true;
			
			sendNotification(BBNotifications.ITEM_CLEAN, "settings"); // gh#83
			sendNotification(BBNotifications.ITEM_CLEAN, "xhtml"); // gh#90
			
			// gh#229
			courseProxy.updateCurrentCourse();
		}
		
	}
	
}