package com.clarityenglish.bento.controller {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	/**
	 * Select the parent of the currently selected node.  Used for 'back' buttons, amongst other things.
	 * TODO: This isn't correct.  Probably best would be to have selectedCourse, selectedUnit, selectedExercise all derived from selectedNode (and with binding based on it)
	 * and have views/mediators grab/bindage-tools to the appropriate one.  Then we can e.g. go up to the unit instead of the course and still have everything work correctly
	 * since the derived getters will traverse up the hierarchy to determine the bits.
	 */
	public class SelectedNodeUpCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public override function execute(note:INotification):void {
			super.execute(note);
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, bentoProxy.selectedNode.parent().parent());
		}
		
	}
	
}