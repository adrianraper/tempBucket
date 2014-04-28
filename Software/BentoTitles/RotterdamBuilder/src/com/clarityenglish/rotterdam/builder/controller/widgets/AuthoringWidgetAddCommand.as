package com.clarityenglish.rotterdam.builder.controller.widgets {
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.UIDUtil;
	
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
			
			var node:XML, tempid:String = UIDUtil.createUID();
			
			if (note.getBody().node) {
				node = note.getBody().node;
			} else {
				node = <exercise type="authoring" column="0" span="1" caption="C-Builder Exercise"><text></text></exercise>;
				facade.sendNotification(RotterdamNotifications.WIDGET_ADD, node);
			}
			node.@tempid = tempid;
			
			var authoringOptions:Object = {
				node: node,
				type: note.getBody().type
			};
			
			facade.sendNotification(RotterdamNotifications.AUTHORING_WINDOW_SHOW, authoringOptions, tempid);
		}
		
	}
	
}