/*
Simple Command - PureMVC
 */
package com.clarityenglish.resultsmanager.controller {
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.common.vo.content.Content;
	import com.clarityenglish.common.vo.manageable.Group;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class SetContentVisibleCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var content:Content = note.getBody().content as Content;
			var group:Group = note.getBody().group as Group;
			var visible:Boolean = note.getBody().visible as Boolean;
			
			var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
			contentProxy.setContentVisible(content, group, visible);
		}
		
	}
}