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
	
	public class ImageWidgetAddCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var node:XML, tempid:String = UIDUtil.createUID();
			var title:String;
			if (note.getBody().title) {
				title = note.getBody().title;
			}
			if (note.getBody().node) {
				node = note.getBody().node;
			} else {
				node = <exercise type="image" column="0" span="1" caption="Image"><text></text></exercise>;
				facade.sendNotification(RotterdamNotifications.WIDGET_ADD, node);
			}
			node.@tempid = tempid;
			
			var uploadOptions:Object = {
				typeFilter: [ new FileFilter("Images (*.png, *.jpg, *.jpeg)", "*.png;*.jpg;*.jpeg") ],
				node: node,
				title: title,
				span: note.getBody().span,
				source: note.getBody().source,
				url: note.getBody().url // gh#111 - this is only used in 'external' types where the user has already entered a url
			};
			facade.sendNotification(RotterdamNotifications.MEDIA_SELECT, uploadOptions, tempid);
		}
		
	}
	
}