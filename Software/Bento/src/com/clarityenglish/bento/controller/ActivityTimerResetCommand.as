package com.clarityenglish.bento.controller {
	import com.clarityenglish.common.CommonNotifications;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	/**
	 * #269
	 */
	public class ActivityTimerResetCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		// The number of minutes of inactivity before Bento will automatically logout
		private const TIMEOUT:Number = 6 * 60 * 60; // 6 hours as seconds
		
		private static var activityTimer:Timer;
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			if (!activityTimer) {
				activityTimer = new Timer(TIMEOUT * 1000, 1);
				activityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
					sendNotification(CommonNotifications.LOGOUT);
				});
			} else {
				activityTimer.reset();
			}
			
			activityTimer.start();
		}
		
	}
	
}