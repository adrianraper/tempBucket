/*
Mediator - PureMVC
*/
package com.clarityenglish.testadmin.view.management {
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.events.EmailEvent;
	import com.clarityenglish.common.events.LoginEvent;
	import com.clarityenglish.common.model.CopyProxy;
	import com.clarityenglish.common.model.interfaces.CopyProvider;
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.manageable.*;
	import com.clarityenglish.resultsmanager.RMNotifications;
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.resultsmanager.model.LicenceProxy;
	import com.clarityenglish.resultsmanager.model.ReportProxy;
	import com.clarityenglish.resultsmanager.model.TestProxy;
	import com.clarityenglish.resultsmanager.model.UsageProxy;
	import com.clarityenglish.resultsmanager.view.management.events.ReportEvent;
	import com.clarityenglish.resultsmanager.view.shared.events.TestEvent;
	import com.clarityenglish.testadmin.ApplicationFacade;
	import com.clarityenglish.testadmin.view.*;
	import com.clarityenglish.testadmin.view.management.components.*;
	
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
		// TODO How to get the productCode nicely here?
		public var productCode:String = '63';
		
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
			testadminView.addEventListener(LoginEvent.LOGOUT, onLogout);
			
			//testadminView.testDetailPanel.addEventListener(TestEvent.UPDATE, onTestUpdate);
			testadminView.testDetailPanel.addEventListener(TestEvent.ADD, onTestAdd);
			testadminView.testDetailPanel.addEventListener(TestEvent.CANCEL, onTestCancel);
			testadminView.addEventListener(TestEvent.DELETE, onTestUpdate);
			testadminView.addEventListener(TestEvent.UPDATE, onTestUpdate);
			
			testadminView.addEventListener(EmailEvent.SEND_EMAIL, onSendEmail);
			testadminView.addEventListener(EmailEvent.PREVIEW_EMAIL, onPreviewEmail);
			
			// Inject fixed test data into the view
			testadminView.productCode = productCode;
			testadminView.defaultLanguage = 'EN';
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
				RMNotifications.TESTS_LOADED,
				RMNotifications.TEST_UPDATED,
				RMNotifications.TEST_ADDED,
				RMNotifications.TEST_DELETED,
				RMNotifications.TEST_LICENCES_LOADED,
				RMNotifications.CONTENT_LOADED,
				CommonNotifications.EMAIL_SENT,
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
					contentProxy.getContent(new Array(productCode));
					
					// Also need to find how many licences have been used
					var usageProxy:UsageProxy = facade.retrieveProxy(UsageProxy.NAME) as UsageProxy;
					usageProxy.getTestUse(productCode);
					break;
				
				case CommonNotifications.COPY_LOADED:
					var copyProvider:CopyProvider = facade.retrieveProxy(CopyProxy.NAME) as CopyProvider;
					testadminView.setCopyProvider(copyProvider);
					break;
				
				case RMNotifications.CONTENT_LOADED:
					var titles:Array = note.getBody() as Array;
					// If all goes well, there will only be one title coming back anyway
					for each (var title:Title in titles) {
					if (title.id == productCode) 
						testadminView.selectedTitle = title;
				}
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
						var testProxy:TestProxy = facade.retrieveProxy(TestProxy.NAME) as TestProxy;
						testProxy.getTests(selectedManageable as Group);
						testadminView.selectedGroup = selectedManageable;
					} else {
						testadminView.selectedGroup = null;
					}
					testadminView.resetSelection();
					break;
				
				// This will send back an array of testDetails
				case RMNotifications.TESTS_LOADED:
					testadminView.testList.dataProvider = note.getBody() as Array;
					testadminView.resetSelection();
					break;
				
				//case RMNotifications.TEST_DELETED:
				//	testadminView.testList.dataProvider = note.getBody() as Array;
				//	testadminView.resetSelection();
				//	// gh#1499 
				//	testadminView.clearLicencesScheduled();
				//	break;
				
				case RMNotifications.TEST_ADDED:
					testadminView.testList.dataProvider = note.getBody() as Array;
					testadminView.testList.selectedIndex = testadminView.testList.dataProvider.length - 1;
					// Update editable status of test detail
					testadminView.resetSelection();
					
					// gh#1499 
					testadminView.addLicencesScheduled();
					break;
				
				case RMNotifications.TEST_UPDATED:
					var currentIdx:uint = testadminView.testList.selectedIndex;
					testadminView.testList.dataProvider = note.getBody() as Array;
					testadminView.testList.selectedIndex = currentIdx;
					testadminView.resetSelection();
					break;
				
				// For the number of licences
				case RMNotifications.TEST_LICENCES_LOADED:
					var data:Object = note.getBody();
					testadminView.initLicencesUsed(data.purchased, data.used, data.scheduled);
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
			/*
			if (e.scoreLessThan >= 0) opts.scoreLessThan = e.scoreLessThan;
			if (e.scoreMoreThan >= 0) opts.scoreMoreThan = e.scoreMoreThan;
			if (e.durationLessThan >= 0) opts.durationLessThan = e.durationLessThan;
			if (e.durationMoreThan >= 0) opts.durationMoreThan = e.durationMoreThan;
			opts.attempts = e.attempts;
			*/
			opts.detailedReport = e.detailedReport;
			// v3.2 Optional id in the report
			opts.includeStudentID = e.includeStudentID;
			// gh#777
			opts.includeInactiveUsers = e.includeInactiveUsers;
			
			reportProxy.getReport(e.forReportables, e.forClass, e.onReportables, opts, e.template);
		}
		
		private function onTestUpdate(e:TestEvent):void {			
			sendNotification(RMNotifications.UPDATE_TEST, e);
		}
		private function onTestCancel(e:TestEvent):void {			
			testadminView.resetSelection();
		}
		private function onTestAdd(e:TestEvent):void {			
			sendNotification(RMNotifications.ADD_TEST, e);
		}
		
		private function onSendEmail(e:EmailEvent):void {
			sendNotification(CommonNotifications.SEND_EMAIL, e);
		}
		private function onPreviewEmail(e:EmailEvent):void {
			sendNotification(CommonNotifications.PREVIEW_EMAIL, e);
		}
		private function onLogout(e:LoginEvent):void {
			sendNotification(CommonNotifications.LOGOUT);
		}
	}
}