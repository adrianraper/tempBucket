package com.clarityenglish.ielts.controller {
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class HrefSelectedCommand extends SimpleCommand {

		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var href:Href = note.getBody() as Href;
			switch (href.extension) {
				case "xml":
					sendNotification(IELTSNotifications.EXERCISE_SHOW, href);
					break;
				case "pdf":
					sendNotification(IELTSNotifications.PDF_SHOW, href);
					break;
				default:
					log.error("Attempt to load href with unknown extension {0} - {1}", href.extension, href);
			}
		}

	}
}
