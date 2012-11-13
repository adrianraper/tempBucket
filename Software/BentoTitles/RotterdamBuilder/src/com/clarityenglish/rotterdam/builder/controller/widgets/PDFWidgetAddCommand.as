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
	
	public class PDFWidgetAddCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// note.getBody().source - this will be computer or cloud (needs to be a constant!)
			
			var uid:String = UIDUtil.createUID();
			var textFlowString:String = TLFUtil.textToTextFlowString("I am a new pdf widget");
			var node:XML = <exercise type="pdf" id={uid} column="0" span="1" title="New PDF widget"><text>{textFlowString}</text></exercise>;
			
			facade.sendNotification(RotterdamNotifications.WIDGET_ADD, node);
			
			var uploadOptions:Object = {
				fileFilter: new FileFilter("PDF documents (*.pdf)", "*.pdf"),
				node: node,
				source: note.getBody().source
			};
			facade.sendNotification(RotterdamNotifications.MEDIA_SELECT, uploadOptions, uid);
		}
		
	}
	
}