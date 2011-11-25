﻿/*
Simple Command - PureMVC
 */
package com.clarityenglish.common.controller {
	
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.common.model.ProgressProxy;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class ScoreWriteCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			var data:ExerciseMark = note.getBody() as ExerciseMark;

			var progressProxy:ProgressProxy = facade.retrieveProxy(ProgressProxy.NAME) as ProgressProxy;
			progressProxy.writeScore(data);
		}
		
	}
}