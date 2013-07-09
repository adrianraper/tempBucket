package com.clarityenglish.bento.controller.recorder {
	import com.clarityenglish.bento.RecorderNotifications;
	import com.clarityenglish.bento.model.AudioProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class RecordingStartCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var audioProxy:AudioProxy = facade.retrieveProxy(RecorderNotifications.RECORD_PROXY_NAME) as AudioProxy;
			
			audioProxy.stop();
			audioProxy.record();
		}
		
	}
	
}