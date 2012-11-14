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
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			var returnedXml:XML = new XML(note.getBody());
			
			// Saving a menu.xml file can cause ids to be inserted on the server, so we need to go through the loaded menu xml inserting ids
			XmlUtils.copyXmlAttributes(returnedXml, bentoProxy.menuXHTML.xml, "course", [ "id" ]);
			XmlUtils.copyXmlAttributes(returnedXml, bentoProxy.menuXHTML.xml, "unit", [ "id" ]);
			XmlUtils.copyXmlAttributes(returnedXml, bentoProxy.menuXHTML.xml, "exercise", [ "id" ]);
		}
		
	}
	
}