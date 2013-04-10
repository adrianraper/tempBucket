package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.vo.Href;
	
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
			
			switch (selectedNode.localName()) {
				case "course":
					bentoProxy.selectedNode = selectedNode;
					sendNotification(BBNotifications.COURSE_START, selectedNode);
					sendNotification(BBNotifications.COURSE_STARTED, selectedNode);
					sendNotification(BBNotifications.SELECTED_NODE_CHANGED, selectedNode);
					break;
				case "exercise":
					var attribute:String = note.getType() || "href";
					var href:Href = bentoProxy.createRelativeHref(Href.EXERCISE, selectedNode.@[attribute]);
					switch (href.extension) {
						case "xml":
							bentoProxy.selectedNode = selectedNode;
							// TODO: exercise start & stop notifications here?
							sendNotification(BBNotifications.SELECTED_NODE_CHANGED, selectedNode);
							break;
						case "pdf":
							sendNotification(BBNotifications.PDF_SHOW, href);
							break;
						default:
							log.error("Attempt to load href with unknown extension {0} - {1}", href.extension, href);
							break;
					}
					break;
			}
		}
		
	}
	
}