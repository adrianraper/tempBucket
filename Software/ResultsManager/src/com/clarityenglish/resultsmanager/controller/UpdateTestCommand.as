/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.common.vo.tests.ScheduledTest;
	import com.clarityenglish.resultsmanager.model.TestProxy;
	import com.clarityenglish.resultsmanager.view.shared.events.TestEvent;
	import com.clarityenglish.utils.TraceUtils;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class UpdateTestCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var testEvent:TestEvent = note.getBody() as TestEvent;
			
			var testProxy:TestProxy = facade.retrieveProxy(TestProxy.NAME) as TestProxy;
			
			switch (testEvent.type) {
				case TestEvent.UPDATE:
					testProxy.updateTest(testEvent.test);
					break;
				case TestEvent.ADD:
					testProxy.addTest(testEvent.test);
					break;
				case TestEvent.DELETE:
					testProxy.deleteTest(testEvent.test);
					break;
			}
		}
		
	}
}