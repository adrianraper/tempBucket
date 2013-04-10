package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class SelectedNodeChangeCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var selectedNode:XML = note.getBody() as XML;
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			bentoProxy.selectedNode = selectedNode;
			
			switch (selectedNode.localName()) {
				case "course":
					sendNotification(BBNotifications.COURSE_START, selectedNode);
					sendNotification(BBNotifications.COURSE_STARTED, selectedNode);
					break;
			}
			
			sendNotification(BBNotifications.SELECTED_NODE_CHANGED, selectedNode);
		}
		
	}
	
}