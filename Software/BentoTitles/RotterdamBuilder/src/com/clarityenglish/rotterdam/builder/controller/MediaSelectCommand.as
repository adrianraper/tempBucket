package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class MediaSelectCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			switch (note.getBody().source) {
				case "computer":
					sendNotification(RotterdamNotifications.MEDIA_UPLOAD, note.getBody(), note.getType());
					break;
				case "cloud":
					sendNotification(RotterdamNotifications.MEDIA_CLOUD_SELECT, note.getBody(), note.getType());
					break;
				case "external":
					// gh#111 - in 'external' mode we already have a url so there is no user interaction necessary 
					var node:XML = note.getBody().node;
					node.@src = note.getBody().url;
					delete node.@tempid;
					break;
				default:
					log.error("Unknown source " + note.getBody().source + " for media selection");
			}
		}
		
	}
	
}