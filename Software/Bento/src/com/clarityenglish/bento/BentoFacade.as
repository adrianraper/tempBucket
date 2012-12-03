﻿package com.clarityenglish.bento {
	import com.clarityenglish.bento.controller.*;
	import com.clarityenglish.bento.view.*;
	import com.clarityenglish.bento.view.marking.MarkingMediator;
	import com.clarityenglish.bento.view.marking.MarkingView;
	import com.clarityenglish.bento.view.swfplayer.SWFPlayerMediator;
	import com.clarityenglish.bento.view.swfplayer.SWFPlayerView;
	import com.clarityenglish.bento.view.warning.WarningMediator;
	import com.clarityenglish.bento.view.warning.WarningView;
	import com.clarityenglish.bento.view.xhtmlexercise.XHTMLExerciseMediator;
	import com.clarityenglish.bento.view.xhtmlexercise.components.XHTMLExerciseView;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.common.controller.*;
	
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.davekeen.util.ClassUtil;
	import org.davekeen.util.StringUtils;
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.utilities.statemachine.State;
	import org.puremvc.as3.utilities.statemachine.StateMachine;
	
	/**
	* ...
	* @author Dave Keen
	*/
	public class BentoFacade extends Facade implements IFacade {
		
		/**
		 * Standard flex logger
		 */
		private var log:ILogger = Log.getLogger(ClassUtil.getQualifiedClassNameAsString(this));
		
		private var mediatorClassByViewClass:Dictionary = new Dictionary();
		
		private var mediatorInstanceByView:Dictionary = new Dictionary(true);
		
		private var mediatorNameByInstance:Dictionary = new Dictionary();
		
		public function BentoFacade():void {
			super();
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			// Map built in views to their mediators
			mapView(DynamicView, DynamicMediator);
			mapView(XHTMLExerciseView, XHTMLExerciseMediator);
			mapView(SWFPlayerView, SWFPlayerMediator);
			mapView(MarkingView, MarkingMediator);
			mapView(WarningView, WarningMediator);
			
			// Initial config loading before the state machine is initialized
			registerCommand(CommonNotifications.CONFIG_LOAD, ConfigLoadCommand);
			registerCommand(CommonNotifications.CONFIG_LOADED, BentoStartupStateMachineCommand);
			
			registerCommand(CommonNotifications.COPY_LOAD, CopyLoadCommand);
			registerCommand(CommonNotifications.ACCOUNT_LOAD, AccountLoadCommand);
			
			// gh#21
			//registerCommand(CommonNotifications.ACCOUNT_RELOAD, AccountReloadCommand);
			
			// Map built in commands
			registerCommand(BBNotifications.BENTO_RESET, BentoResetCommand);
			registerCommand(BBNotifications.LANGUAGE_CHANGE, LanguageChangeCommand);
			registerCommand(BBNotifications.MENU_XHTML_LOAD, MenuXHTMLLoadCommand);
			registerCommand(BBNotifications.XHTML_LOAD, XHTMLLoadCommand);
			registerCommand(BBNotifications.QUESTION_NODE_ANSWER, QuestionNodeAnswerCommand);
			registerCommand(BBNotifications.QUESTION_STRING_ANSWER, QuestionStringAnswerCommand);
			registerCommand(BBNotifications.QUESTION_INCORRECT_ANSWER, QuestionIncorrectAnswerCommand);
			registerCommand(BBNotifications.FEEDBACK_SHOW, FeedbackShowCommand);
			registerCommand(BBNotifications.MARKING_SHOW, MarkingShowCommand);
			registerCommand(BBNotifications.WARN_DATA_LOSS, WarningShowCommand);
			registerCommand(BBNotifications.EXERCISE_START, ExerciseStartCommand);
			registerCommand(BBNotifications.EXERCISE_STOP, ExerciseStopCommand);
			registerCommand(BBNotifications.EXERCISE_SHOW_NEXT, ExerciseShowNextCommand);
			registerCommand(BBNotifications.EXERCISE_SHOW_PREVIOUS, ExerciseShowPreviousCommand);
			registerCommand(BBNotifications.EXERCISE_SHOW_OFFSET, ExerciseShowOffsetCommand);
			registerCommand(BBNotifications.EXERCISE_SHOW_FEEDBACK, ExerciseShowFeedbackCommand);
			registerCommand(BBNotifications.EXERCISE_PRINT, ExercisePrintCommand);
			registerCommand(BBNotifications.EXERCISE_TRY_AGAIN, ExerciseTryAgainCommand);
			registerCommand(BBNotifications.EXERCISE_RESTART, ExerciseRestartCommand);
			registerCommand(BBNotifications.WORD_CLICK, WordClickCommand);
			
			// AR add in login and logout
			registerCommand(CommonNotifications.ADD_USER, AddUserCommand);
			registerCommand(BBNotifications.USER_UPDATE, UpdateUserCommand);
			registerCommand(CommonNotifications.LOGIN, LoginCommand);
			registerCommand(CommonNotifications.LOGOUT, LogoutCommand);
			
			// For use with errors and exit
			registerCommand(CommonNotifications.BENTO_ERROR, ShowErrorCommand); // we might be able to replace everything with this
			registerCommand(CommonNotifications.INVALID_DATA, ShowErrorCommand);
			registerCommand(CommonNotifications.INVALID_LOGIN, ShowErrorCommand);
			registerCommand(CommonNotifications.ADD_USER_FAILED, ShowErrorCommand);
			registerCommand(CommonNotifications.EXIT, LogoutCommand);

			// For use with sessions and scores for progress
			registerCommand(BBNotifications.SESSION_START, SessionStartCommand);
			registerCommand(BBNotifications.SESSION_STOP, SessionStopCommand);
			registerCommand(BBNotifications.SCORE_WRITE, ScoreWriteCommand);
			registerCommand(BBNotifications.PROGRESS_DATA_LOAD, ProgressDataLoadCommand);
			
			// #269
			registerCommand(BBNotifications.ACTIVITY_TIMER_RESET, ActivityTimerResetCommand);
			
			// #265
			registerCommand(BBNotifications.CLOSE_ALL_POPUPS, CloseAllPopUpsCommand);
			
			// #472
			registerCommand(BBNotifications.NETWORK_CHECK_AVAILABILITY, NetworkCheckAvailability);
			registerCommand(BBNotifications.NETWORK_UNAVAILABLE, BentoResetCommand);

			// Performance logging
			registerCommand(CommonNotifications.PERFORMANCE_LOG, PerformanceLogCommand);
		}
		
		protected function mapView(viewClass:Class, mediatorClass:Class):void {
			mediatorClassByViewClass[viewClass] = mediatorClass;
		}
		
		public function onViewAdded(viewComponent:Object):void {
			if (!viewComponent)
				return;
			
			try {
				var mediatorClass:Class = mediatorClassByViewClass[ClassUtil.getClass(viewComponent)];
			} catch (e:ReferenceError) {
				return;
			}
			
			if (mediatorClass && mediatorInstanceByView[viewComponent] == null) {
				var uniqueMediatorName:String = ClassUtil.getClassAsString(mediatorClass) + new Date().getTime().toString();
				var mediator:IMediator = new mediatorClass(uniqueMediatorName, viewComponent);
				
				log.info("Auto-mediating with mediator {0} (unique mediator name={1})", mediator, uniqueMediatorName);
				
				registerMediator(mediator);
				
				mediatorInstanceByView[viewComponent] = mediator;
				mediatorNameByInstance[mediator] = uniqueMediatorName;
			}
		}
		
		public function onViewRemoved(viewComponent:Object):void {
			if (!viewComponent)
				return;
			
			var mediator:IMediator = mediatorInstanceByView[viewComponent];
			if (mediator) {
				log.info("Removing mediator {0}", mediatorNameByInstance[mediator]);
				
				removeMediator(mediatorNameByInstance[mediator]);
				
				// This should free the view component and mediator for garbage collection
				delete mediatorNameByInstance[mediator];
				delete mediatorInstanceByView[viewComponent];
			}
		}
		
		/**
		 * This takes all notifications and doubles them to be sent to the FSM.  Not really sure if this is best practices but the alternative is to manually list
		 * everything the state machine is interested in and redispatch StateMachine.ACTION events for each of them, which quickly get annoying and outweighs the
		 * convenience of having XML defined states.
		 * 
		 * @param	notificationName
		 * @param	body
		 * @param	type
		 */
		override public function sendNotification(notificationName:String, body:Object = null, type:String = null):void {
			// If this isn't a StateMachine notification (all of which begin with 'StateMachine/notes', duplicate it as an ACTION for the state machine.
			// Put a delay before dispatching the original notification to give the state machine time to get into a new state, if necessary.
			if (!StringUtils.beginsWith(notificationName, "StateMachine/notes")) {
				var stateMachine:StateMachine = retrieveMediator(StateMachine.NAME) as StateMachine;
				sendNotification(StateMachine.ACTION, null, notificationName);
				
				log.debug("sendNotification: " + notificationName);
				
				var f:Function = super.sendNotification;
				setTimeout(function():void { f(notificationName, body, type); }, 1);
			} else {
				
				super.sendNotification(notificationName, body, type);
			}
		}
		
	}
	
}