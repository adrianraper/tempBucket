package com.clarityenglish.rotterdam.builder.controller.widgets {
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.UIDUtil;
	
	import org.davekeen.rpc.ResultResponder;
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class AuthoringWidgetAddCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
			var node:XML, tempid:String = UIDUtil.createUID();
			
			if (note.getBody().node) {
				node = note.getBody().node;
			} else {
				var nodeString:String = '<exercise type="authoring" column="0" span="1" caption="' + copyProvider.getCopyForId('widgetAuthoringCaption') + '"><text></text></exercise>';
				node = new XML(nodeString);
				facade.sendNotification(RotterdamNotifications.WIDGET_ADD, node);
			}
			node.@tempid = tempid;
			
			var authoringOptions:Object = {
				node: node,
				type: note.getBody().type
			};
			
			if (!node.hasOwnProperty("@href")) {
				// If there is no href for the exercise then create one, and create an exercise xml file before opening the window
				node.@href = "exercises/" + (new Date()).time + ".generator.xml";
				
				var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
				courseProxy.exerciseCreate(node, authoringOptions.type).addResponder(new ResultResponder(function():void {
					openAuthoringWindow(authoringOptions, tempid);
				}));
			} else {
				// Otherwise we are editing so just open the window directly
				openAuthoringWindow(authoringOptions, tempid);
			}
		}
		
		protected function openAuthoringWindow(authoringOptions:Object, tempid:String):void {
			facade.sendNotification(RotterdamNotifications.AUTHORING_WINDOW_SHOW, authoringOptions, tempid);
		}
		
	}
	
}