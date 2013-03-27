package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class MediaUploadErrorCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		// gh#159
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoError:BentoError = new BentoError();
			bentoError.errorContext = note.getBody().message;
			bentoError.isFatal = false;
			
			facade.sendNotification(RotterdamNotifications.WIDGET_DELETE, note.getBody().node);
			facade.sendNotification(CommonNotifications.BENTO_ERROR, bentoError);
		}
		
	}
	
}