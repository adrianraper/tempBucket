/*
 Mediator - PureMVC
 */
package com.clarityenglish.resultsmanager.view.management {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.resultsmanager.model.ReportProxy;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.view.management.events.ReportEvent;
	import com.clarityenglish.common.vo.content.Content;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.clarityenglish.resultsmanager.view.management.components.*;
	import com.clarityenglish.resultsmanager.view.*;
	
	/**
	 * A Mediator
	 */
	public class ManagementMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "ManagementMediator";
		
		public function ManagementMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			
			facade.registerMediator(new ContentMediator(managementView.contentView));
			facade.registerMediator(new ManageablesMediator(managementView.manageablesView));
			
			managementView.addEventListener(ReportEvent.GENERATE, onGenerateReport);
		}
		
		private function get managementView():ManagementView {
			return viewComponent as ManagementView;
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
			return ManagementMediator.NAME;
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
					RMNotifications.SHOW_REPORT_WINDOW,
					CommonNotifications.COPY_LOADED,
					RMNotifications.CONTENT_LOADED,
					RMNotifications.MANAGEABLES_LOADED,
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
				case RMNotifications.MANAGEABLES_LOADED:
					managementView.manageables = note.getBody() as Array;
					break;
				case RMNotifications.CONTENT_LOADED:
					managementView.content = note.getBody() as Array;
					break;
				case RMNotifications.SHOW_REPORT_WINDOW:
					managementView.showReportWindow(note.getBody() as ReportEvent);
					break;
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					managementView.setCopyProvider(copyProvider);
					break;
				default:
					break;
			}
		}
		
		private function onGenerateReport(e:ReportEvent):void {
			var reportProxy:ReportProxy = facade.retrieveProxy(ReportProxy.NAME) as ReportProxy;
			
			var opts:Object = new Object();
			if (e.fromDate) opts.fromDate = e.fromDate;
			if (e.toDate) opts.toDate = e.toDate;
			if (e.scoreLessThan >= 0) opts.scoreLessThan = e.scoreLessThan;
			if (e.scoreMoreThan >= 0) opts.scoreMoreThan = e.scoreMoreThan;
			if (e.durationLessThan >= 0) opts.durationLessThan = e.durationLessThan;
			if (e.durationMoreThan >= 0) opts.durationMoreThan = e.durationMoreThan;
			opts.detailedReport = e.detailedReport;
			opts.attempts = e.attempts;
			// v3.2 Optional id in the report
			opts.includeStudentID = e.includeStudentID;
			
			reportProxy.getReport(e.forReportables, e.onReportables, opts, e.template);
		}

	}
}