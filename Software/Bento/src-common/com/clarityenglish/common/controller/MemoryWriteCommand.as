/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	
	import com.clarityenglish.common.events.MemoryEvent;
	import com.clarityenglish.common.model.MemoryProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class MemoryWriteCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var memoryEvent:MemoryEvent = note.getBody() as MemoryEvent;

			var memoryProxy:MemoryProxy = facade.retrieveProxy(MemoryProxy.NAME) as MemoryProxy;
			memoryProxy.writeMemory(memoryEvent.memory);
		}
	}
}