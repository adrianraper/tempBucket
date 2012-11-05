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
	
	public class AudioWidgetAddCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var uid:String = UIDUtil.createUID();
			var textFlowString:String = TLFUtil.textToTextFlowString("I am a new audio widget");
			var node:XML = <audio id={uid} span="1" title="New Audio widget"><text>{textFlowString}</text></audio>;
			
			facade.sendNotification(RotterdamNotifications.WIDGET_ADD, node);
			
			var uploadOptions:Object = {
				fileFilter: new FileFilter("Audio (*.mp3)", "*.mp3"),
				node: node
			};
			facade.sendNotification(RotterdamNotifications.MEDIA_UPLOAD, uploadOptions, uid);
		}
		
	}
	
}