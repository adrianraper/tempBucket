/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.resultsmanager.view.management.events.ContentEvent;
	//import com.clarityenglish.common.vo.manageable.Group;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
	import nl.demonsters.debugger.MonsterDebugger;
    
	/**
	 * SimpleCommand
	 */
	public class EditedContentCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var e:ContentEvent = note.getBody() as ContentEvent;
			
			var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
			switch (e.type) {
				case ContentEvent.MOVE_CONTENT_BEFORE:
				case ContentEvent.MOVE_CONTENT_AFTER:
					contentProxy.moveContent(e.editedUID, e.groupID, e.relatedUID, e.type);
					break;
				case ContentEvent.INSERT_CONTENT_BEFORE:
				case ContentEvent.INSERT_CONTENT_AFTER:
					contentProxy.insertContent(e.editedUID, e.groupID, e.relatedUID, e.type);
					break;
				case ContentEvent.COPY_CONTENT_BEFORE:
					var changeType:String = ContentEvent.INSERT_CONTENT_BEFORE;
					contentProxy.copyContent(e.editedUID, e.groupID, e.relatedUID, changeType);
					break;
				case ContentEvent.COPY_CONTENT_AFTER:
					changeType = ContentEvent.INSERT_CONTENT_AFTER;
					contentProxy.copyContent(e.editedUID, e.groupID, e.relatedUID, changeType);
					break;
				case ContentEvent.RESET_CONTENT:
					contentProxy.resetEditedContent(e.editedUID, e.groupID);
					break
				case ContentEvent.CHECK_FOLDER:
					//MonsterDebugger.trace(this, "check_folder in editedContentCommand");
					contentProxy.checkEditedContentFolder(e.groupID);
					break
			}
		}
		
	}
}