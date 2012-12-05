package com.clarityenglish.rotterdam.builder.controller.widgets {
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class VideoWidgetAddCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note)
			
			var src:String = note.getBody().url;
				
			var textFlowString:String = TLFUtil.textToTextFlowString("I am a new video widget");
			
			facade.sendNotification(RotterdamNotifications.WIDGET_ADD, <exercise type="video" src={src} column="0" span="2" caption="New video widget"><text>{textFlowString}</text></exercise>);
		}
		
	}
	
}