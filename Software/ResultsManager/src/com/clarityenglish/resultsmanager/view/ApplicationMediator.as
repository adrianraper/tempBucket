/*
 Mediator - PureMVC
 */
package com.clarityenglish.resultsmanager.view {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.view.AbstractApplicationMediator;
	import com.clarityenglish.common.view.login.LoginMediator;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.ResultsManager;
	import com.clarityenglish.resultsmanager.view.loginopts.LoginOptsMediator;
	import com.clarityenglish.resultsmanager.view.management.ManagementMediator;
	import com.clarityenglish.resultsmanager.view.usage.UsageMediator;
	import com.clarityenglish.utils.TraceUtils;
	import com.flexiblexperiments.ListItemGroupedDragProxy;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class ApplicationMediator extends AbstractApplicationMediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "ApplicationMediator";
		
		private var _directStart:String;
		
		public function ApplicationMediator(viewComponent:Object, directStart:String) {
			// pass the viewComponent to the superclass where
			// it will be stored in the inherited viewComponent property
			_directStart = directStart;
			super(NAME, viewComponent);
		}
		
		private function get application():ResultsManager {
			return viewComponent as ResultsManager;
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			facade.registerMediator(new ManagementMediator(application.managementView));
			facade.registerMediator(new UsageMediator(application.usageView));
			facade.registerMediator(new LoginOptsMediator(application.loginOptsView));
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
			return ApplicationMediator.NAME;
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
			// Concatenate any extra notifications to the array returned by this function in the superclass
			return super.listNotificationInterests().concat([
					RMNotifications.CONTENT_LOADED,
					RMNotifications.DIRECT_START,
					]);
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
			super.handleNotification(note);
			
			switch (note.getName()) {
				case CommonNotifications.LOGGED_IN:
					application.topStack.selectedIndex = 1;
					application.configureTabsForLoggedInUser();
					
					if (Constants.noStudents) {
						var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
						application.showAlert(copyProvider.getCopyForId("noStudentsAlert") + " (" + Constants.manageablesCount + ")", copyProvider.getCopyForId("notice"));
					}
					
					break;
				case CommonNotifications.LOGGED_OUT:
					application.topStack.selectedIndex = 0;
					break;
				case CommonNotifications.COPY_LOADED:
					copyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					
					// Set the copy in any static classes (e.g. Renderers or things that are recycled)
					ListItemGroupedDragProxy.copyProvider = copyProvider;
					
					application.setCopyProvider(copyProvider);
					break;
					
				// v3.5.0 Once the content is loaded you can check to see if all titles are AA
				case RMNotifications.CONTENT_LOADED:
					application.configureTabsForTitles(note.getBody() as Array);
					break;
					
				// v3.6.0 If you are starting with directStart parameter, configure tabs
				case RMNotifications.DIRECT_START:
					TraceUtils.myTrace("appMediator.directStart=" + (note.getBody() as String));
					application.configureTabsForDirectStart(note.getBody() as String);
					break;
				default:
					break;
			}
		}

	}
}
