package com.clarityenglish.rotterdam.builder.controller.widgets {
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.textLayout.util.TLFUtil;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class TextWidgetAddCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note)
			
			var textFlowString:String = TLFUtil.textToTextFlowString("I am a new text widget");
			
			facade.sendNotification(RotterdamNotifications.WIDGET_ADD, <exercise type="text" column="0" span="1" title="New text widget"><text>{textFlowString}</text></exercise>);
		}
		
	}
	
}