package com.clarityenglish.common.controller {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.error.ErrorView;
	import com.clarityenglish.common.vo.config.BentoError;
	import com.clarityenglish.common.vo.config.Config;
	import com.clarityenglish.controls.video.players.HTMLVideoPlayer;
	
	import flash.display.DisplayObject;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.TitleWindow;
	
	public class ShowErrorCommand extends SimpleCommand {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var titleWindow:TitleWindow;

		private var errorView:ErrorView;
		
		public override function execute(note:INotification):void {
			super.execute(note);

			var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;

			// Create the title window; maintain a reference so that the command doesn't get garbage collected until the window is shut
			titleWindow = new TitleWindow();
			titleWindow.styleName = "errorTitleWindow";
			//titleWindow.title = copyProvider.getCopyForId('stdErrorTitle');

			errorView = new ErrorView();
			//trace("load error message");
			errorView.error = note.getBody() as BentoError;
			titleWindow.addElement(errorView);
			
			// Create and centre the popup
			PopUpManager.addPopUp(titleWindow, FlexGlobals.topLevelApplication as DisplayObject, true, PopUpManagerChildList.POPUP, FlexGlobals.topLevelApplication.moduleFactory);
			PopUpManager.centerPopUp(titleWindow);
			
			// TODO This is not a very transparent way to check if there is StageWebView video that we need to hide
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (configProxy.isPlatformiPad())
				HTMLVideoPlayer.hideAllVideo(); // gh#749
			
			// Show the close button
			// TODO. It might be easier for the user to also have an OK button that does the same thing as this close.
			// So hide the close button
			titleWindow.closeButton.visible = false;
			
			// Listen for the close event so that we can cleanup
			titleWindow.addEventListener(CloseEvent.CLOSE, onClosePopUp);
		}
		
		/**
		 * Close the popup and make all variables eligible for garbage collection
		 * 
		 * @param event
		 */
		protected function onClosePopUp(event:CloseEvent = null):void {
			titleWindow.removeEventListener(CloseEvent.CLOSE, onClosePopUp);
			
			var isFatal:Boolean = errorView.error.isFatal;
			
			errorView = null;
			PopUpManager.removePopUp(titleWindow);
			titleWindow = null;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			if (configProxy.isPlatformiPad())
				HTMLVideoPlayer.showAllVideo(); // gh#749
			
			// Exit the program
			if (isFatal) sendNotification(CommonNotifications.EXIT);
		}
		
	}
	
}