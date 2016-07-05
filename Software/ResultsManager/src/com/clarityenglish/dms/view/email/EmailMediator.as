/*
 Mediator - PureMVC
 */
package com.clarityenglish.dms.view.email {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.dms.DMSNotifications;
	import com.clarityenglish.common.model.EmailProxy;
	import com.clarityenglish.common.events.EmailEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.clarityenglish.dms.view.email.components.*;
	import com.clarityenglish.dms.view.email.*;
	
	/**
	 * A Mediator
	 */
	public class EmailMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "EmailMediator";
		
		public function EmailMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			emailView.addEventListener(EmailEvent.RELOAD_EMAIL_TEMPLATES, onReloadEmailTemplates);
			emailView.addEventListener(EmailEvent.CLEAR_TO_LIST, onClearToList);
			emailView.addEventListener(EmailEvent.PREVIEW_EMAIL, onPreviewEmail);
		}
		
		private function get emailView():EmailView {
			return viewComponent as EmailView;
		}

		/**
		 * Get the Mediator name.
		 * <P>
		 * Called by the framework to get the name of this
		 * mediator. If there is only one instance, we may
		 * define it in a constant and return it here. If
		 * there are multiple instances, this method must
		 * return the unique name of this instance.</P>
		 * 
		 * @return String the Mediator name
		 */
		override public function getMediatorName():String {
			return EmailMediator.NAME;
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
					CommonNotifications.COPY_LOADED,
					DMSNotifications.ACCOUNTS_LOADED,
					DMSNotifications.EMAIL_TEMPLATES_LOADED,
					DMSNotifications.EMAIL_TO_LIST_CHANGED
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
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					emailView.setCopyProvider(copyProvider);
					break;
				case DMSNotifications.EMAIL_TEMPLATES_LOADED:
					emailView.setTemplateDefinitions(note.getBody() as Array);
					break;
				case DMSNotifications.ACCOUNTS_LOADED:
					// Each time the accounts are reloaded we need to clear the to list otherwise we will end up with out-of-date
					// references and memory leaks (where the to list contains accounts that no longer exist)
					var emailProxy:EmailProxy = facade.retrieveProxy(EmailProxy.NAME) as EmailProxy;
					emailProxy.clearToList();
					break;
				case DMSNotifications.EMAIL_TO_LIST_CHANGED:
					emailView.setEmailToList(note.getBody() as Array);
					break;
				default:
					break;		
			}
		}
		
		private function onReloadEmailTemplates(e:EmailEvent):void {
			var emailProxy:EmailProxy = facade.retrieveProxy(EmailProxy.NAME) as EmailProxy;
			emailProxy.getEmailTemplates();
		}
		
		private function onClearToList(e:EmailEvent):void {
			var emailProxy:EmailProxy = facade.retrieveProxy(EmailProxy.NAME) as EmailProxy;
			emailProxy.clearToList();
		}
		
		private function onPreviewEmail(e:EmailEvent):void {
			var emailProxy:EmailProxy = facade.retrieveProxy(EmailProxy.NAME) as EmailProxy;
			emailProxy.previewEmail(e.templateDefinition);
		}

	}
}
