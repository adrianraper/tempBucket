package com.clarityenglish.rotterdam.builder.controller {
	import com.clarityenglish.bento.model.DataProxy;
	
	import flash.desktop.Clipboard;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class UnitCopyCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			// Take a copy
			var unitCopy:XML = (note.getBody() as XML).copy();
			
			// Remove the ids from the unit itself and all the exercises gh#110
			delete unitCopy.@id;
			for each (var exercise:XML in unitCopy..exercise)
				delete exercise.@id;
			
			// Write the unit
			var dataProxy:DataProxy = facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			dataProxy.set("clipboard", { type: "unit", xml: unitCopy });
		}
		
	}
	
}