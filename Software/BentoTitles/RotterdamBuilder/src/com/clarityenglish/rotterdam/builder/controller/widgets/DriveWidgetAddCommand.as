package com.clarityenglish.rotterdam.builder.controller.widgets {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.UIDUtil;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	// gh#679
	public class DriveWidgetAddCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note)
			
			var src:String = note.getBody().url;
			
			var node:XML, tempid:String = UIDUtil.createUID();
			if (note.getBody().node) {
				node = note.getBody().node;
			} else {
				node = <exercise type="drive" permission="Google" column="0" span="1" caption="Link to Drive"><text></text></exercise>;
				facade.sendNotification(RotterdamNotifications.WIDGET_ADD, node);
			}
			
			node.@src = src;
		}
		
	}
	
}