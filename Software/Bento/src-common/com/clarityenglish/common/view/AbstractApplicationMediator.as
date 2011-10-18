/*
 Mediator - PureMVC
 */
package com.clarityenglish.common.view {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.bento.view.interfaces.IBentoApplication;
	import com.clarityenglish.common.vo.config.BentoError;
	
	import flash.display.Sprite;
	
	import mx.controls.Alert;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class AbstractApplicationMediator extends Mediator implements IMediator {
	
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		public function AbstractApplicationMediator(NAME:String, viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		/**
		 * xxx
		 */
		private function get application():IBentoApplication {
			// This should return an iBentoApplication
			//return viewComponent;
			return (viewComponent as IBentoApplication);
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
		}
        
		/**
		 * List all notifications this Mediator is interested in.
		 * <P>
		 * Automatically called by the framework when the mediator
		 * is registered with the view.</P>
		 * 
		 * @return Array the list of Nofitication names
		 */
		override public function listNotificationInterests():Array {
			return [
					CommonNotifications.TRACE_NOTICE,
					CommonNotifications.TRACE_WARNING,
					CommonNotifications.TRACE_ERROR,
					CommonNotifications.COPY_LOADED,
					CommonNotifications.CONFIG_ERROR,
			];
		}

		/**
		 * Handle all notifications this Mediator is interested in.
		 * <P>
		 * Called by the framework when a notification is sent that
		 * this mediator expressed an interest in when registered
		 * (see <code>listNotificationInterests</code>.</P>
		 * 
		 * @param INotification a notification 
		 */
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				case CommonNotifications.CONFIG_ERROR:
					// Errors handled by this mediator show an alert (or similar) on the current screen
					// and are generally warnings that nothing is going to happen now. But
					// some might request a state change as well as an alert.
					// A typical such error would be wrong name/password/
					// Hmm, but can you ask a state to do this? How do I know which state?
					// Is this where a FSM would come in handy?
					this.application.showErrorMessage(note.getBody() as BentoError);
					break;
				case CommonNotifications.TRACE_NOTICE:
					log.info(note.getBody().toString());
					break;
				case CommonNotifications.TRACE_WARNING:
					log.warn(note.getBody().toString());
					break;
				case CommonNotifications.TRACE_ERROR:
					log.error(note.getBody().toString());
					Alert.show(note.getBody() as String, "Error", Alert.OK, application as Sprite);
					break;
				case CommonNotifications.COPY_LOADED:
					// Set the alert box labels from the copy
					//var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					//Alert.yesLabel = copyProvider.getCopyForId("yes");
					//Alert.noLabel = copyProvider.getCopyForId("no");
					break;
				default:
					break;		
			}
		}
		
	}
}
