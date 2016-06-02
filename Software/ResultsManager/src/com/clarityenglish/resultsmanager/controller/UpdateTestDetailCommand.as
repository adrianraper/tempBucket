/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.common.vo.tests.TestDetail;
	import com.clarityenglish.resultsmanager.model.TestDetailsProxy;
	import com.clarityenglish.resultsmanager.view.shared.events.TestDetailEvent;
	import com.clarityenglish.utils.TraceUtils;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class UpdateTestDetailCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var testDetailEvent:TestDetailEvent = note.getBody() as TestDetailEvent;
			
			var testDetailsProxy:TestDetailsProxy = facade.retrieveProxy(TestDetailsProxy.NAME) as TestDetailsProxy;
			
			switch (testDetailEvent.type) {
				case TestDetailEvent.UPDATE:
					testDetailsProxy.updateTestDetail(testDetailEvent.testDetail);
					break;
				case TestDetailEvent.ADD:
					testDetailsProxy.addTestDetail(testDetailEvent.testDetail);
					break;
				case TestDetailEvent.DELETE:
					testDetailsProxy.deleteTestDetail(testDetailEvent.testDetail);
					break;
			}
		}
		
	}
}