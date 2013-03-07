package com.clarityenglish.rotterdam.builder.controller.widgets {
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import flash.net.FileFilter;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.UIDUtil;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ExerciseWidgetAddCommand extends SimpleCommand {
		
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
				node = <exercise type="exercise" column="0" span="1" caption="Exercise"><text></text></exercise>;
				facade.sendNotification(RotterdamNotifications.WIDGET_ADD, node);
			}
			node.@tempid = tempid;
			
			var courseSelectOptions:Object = {
				node: node
			};
			
			facade.sendNotification(RotterdamNotifications.CONTENT_WINDOW_SHOW, courseSelectOptions, tempid);
		}
		
	}
	
}