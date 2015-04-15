/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.vo.manageable.Group;
	import com.clarityenglish.resultsmanager.model.ManageableProxy;
	import com.clarityenglish.resultsmanager.view.management.events.ManageableEvent;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class ImportManageablesCommand extends SimpleCommand {
		
		// gh#653
		public static const EXCEL_IMPORT:String = "excel_import";
		public static const XML_IMPORT:String = "xml_import";
		
		override public function execute(note:INotification):void {
			var manageableProxy:ManageableProxy = facade.retrieveProxy(ManageableProxy.NAME) as ManageableProxy;
			
			switch (note.getType()) {
				case XML_IMPORT:
					var parentGroup:Group = note.getBody() as Group;
					manageableProxy.importManageablesFromFile(parentGroup);
					break;
				case ManageableEvent.IMPORT_FROM_EXCEL:
				case ManageableEvent.IMPORT_FROM_EXCEL_WITH_MOVE:
				case ManageableEvent.IMPORT_FROM_EXCEL_WITH_COPY:
					var groups:Array = note.getBody().groups;
					var users:Array = note.getBody().users;
					parentGroup = note.getBody().parentGroup as Group;
					// v3.6.1 Allow moving and import
					//manageableProxy.importManageables(groups, users, parentGroup);
					manageableProxy.importManageables(groups, users, parentGroup, note.getType());
					break;
				default:
					throw new Error("Unknown type for import manageables");
			}
			
		}
		
	}
}