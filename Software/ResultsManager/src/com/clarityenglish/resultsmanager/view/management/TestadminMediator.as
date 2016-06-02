/*
 Mediator - PureMVC
 */
package com.clarityenglish.resultsmanager.view.management {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.common.vo.manageable.*;
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.resultsmanager.model.LicenceProxy;
	import com.clarityenglish.resultsmanager.model.ReportProxy;
	import com.clarityenglish.resultsmanager.model.TestDetailsProxy;
	import com.clarityenglish.resultsmanager.model.UsageProxy;
	import com.clarityenglish.resultsmanager.view.*;
	import com.clarityenglish.resultsmanager.view.management.components.*;
	import com.clarityenglish.resultsmanager.view.management.events.ReportEvent;
	import com.clarityenglish.resultsmanager.view.shared.events.TestDetailEvent;
	import com.clarityenglish.utils.TraceUtils;
	
	import flash.events.Event;
	
	import org.davekeen.utils.ClassUtils;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class TestadminMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "TestadminMediator";
		
		public function TestadminMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		/**
		 * Setup event listeners and register sub-mediators
		 */
		override public function onRegister():void {
			super.onRegister();
			facade.registerMediator(new ManageablesMediator(testadminView.manageablesView));
			
			testadminView.addEventListener(ReportEvent.GENERATE, onGenerateReport);
			
			testadminView.testDetailPanel.addEventListener(TestDetailEvent.UPDATE, onTestDetailUpdate);
			testadminView.testDetailPanel.addEventListener(TestDetailEvent.ADD, onTestDetailAdd);
			testadminView.addEventListener(TestDetailEvent.DELETE, onTestDetailDelete);

		}
		
		private function get testadminView():TestadminView {
			return viewComponent as TestadminView;
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
			return TestadminMediator.NAME;
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
					RMNotifications.MANAGEABLES_LOADED,
					RMNotifications.MANAGEABLE_SELECTED,
					RMNotifications.TEST_DETAILS_LOADED,
					RMNotifications.TEST_DETAIL_UPDATED,
					RMNotifications.TEST_DETAIL_ADDED,
					RMNotifications.TEST_DETAIL_DELETED,
					RMNotifications.TEST_LICENCES_LOADED,
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
					testadminView.manageables = note.getBody() as Array;
					// gh#1487 Need to trigger get content if the management tab is not being loaded
					var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
					contentProxy.getContent();
					// Also need to find how many licences have been used
					var usageProxy:UsageProxy = facade.retrieveProxy(UsageProxy.NAME) as UsageProxy;
					usageProxy.getTestUse(61);
					break;
				case RMNotifications.SHOW_REPORT_WINDOW:
					// TODO: Need to remove generateReport from this CMMenu as we have our own report generator button
					// and we don't have content to hand for the main one
					testadminView.showReportWindow(note.getBody() as ReportEvent);
					break;
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					testadminView.setCopyProvider(copyProvider);
					break;
				case RMNotifications.MANAGEABLE_SELECTED:
					// Make sure that just one group is selected
					var selectedManageables:Array = note.getBody() as Array;
					if (!selectedManageables || selectedManageables.length > 1) {
						var selectedManageable:Manageable = null;
					} else {
						selectedManageable = selectedManageables[0] as Manageable;
					}
					if (selectedManageable is Group) {
						var testDetailsProxy:TestDetailsProxy = facade.retrieveProxy(TestDetailsProxy.NAME) as TestDetailsProxy;
						testDetailsProxy.getTestDetails(selectedManageable as Group);
						testadminView.selectedGroup = selectedManageable;
					} else {
						testadminView.selectedGroup = null;
					}
					break;
				// This will send back an array of testDetails
				case RMNotifications.TEST_DETAILS_LOADED:
				case RMNotifications.TEST_DETAIL_DELETED:
					testadminView.testList.dataProvider = note.getBody() as Array;
					break;
				case RMNotifications.TEST_DETAIL_ADDED:
					testadminView.testList.dataProvider = note.getBody() as Array;
					testadminView.testList.selectedIndex = testadminView.testList.dataProvider.length - 1;
					break;
				case RMNotifications.TEST_DETAIL_UPDATED:
					var currentIdx:uint = testadminView.testList.selectedIndex;
					testadminView.testList.dataProvider = note.getBody() as Array;
					testadminView.testList.selectedIndex = currentIdx;
					break;
				
				// For the number of licences
				case RMNotifications.TEST_LICENCES_LOADED:
					var data:Object = note.getBody();
					testadminView.showLicencesUsed(data.purchased, data.used, data.scheduled);
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
			// gh#777
			opts.includeInactiveUsers = e.includeInactiveUsers;
			
			reportProxy.getReport(e.forReportables, e.forClass, e.onReportables, opts, e.template);
		}

		private function onTestDetailUpdate(e:TestDetailEvent):void {			
			sendNotification(RMNotifications.UPDATE_TEST_DETAIL, e);
		}
		private function onTestDetailDelete(e:TestDetailEvent):void {			
			sendNotification(RMNotifications.DELETE_TEST_DETAIL, e);
		}
		private function onTestDetailAdd(e:TestDetailEvent):void {			
			sendNotification(RMNotifications.ADD_TEST_DETAIL, e);
		}
	}
}