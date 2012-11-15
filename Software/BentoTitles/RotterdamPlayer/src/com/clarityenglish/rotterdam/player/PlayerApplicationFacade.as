package com.clarityenglish.rotterdam.player {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.BentoFacade;
	import com.clarityenglish.common.CommonNotifications;
	import com.clarityenglish.rotterdam.CommonAbstractApplicationFacade;
	import com.clarityenglish.rotterdam.controller.RotterdamStartupStateMachineCommand;
	import com.clarityenglish.rotterdam.player.controller.PlayerStartupCommand;
	import com.clarityenglish.rotterdam.player.view.progress.ProgressMediator;
	import com.clarityenglish.rotterdam.player.view.progress.ProgressView;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressAnalysisMediator;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressAnalysisView;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressCompareMediator;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressCompareView;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressCoverageMediator;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressCoverageView;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressScoreMediator;
	import com.clarityenglish.rotterdam.player.view.progress.components.ProgressScoreView;
	
	public class PlayerApplicationFacade extends CommonAbstractApplicationFacade {
		
		public static function getInstance():BentoFacade {
			if (instance == null) instance = new PlayerApplicationFacade();
			return instance as BentoFacade;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			mapView(ProgressView, ProgressMediator);
			mapView(ProgressScoreView, ProgressScoreMediator);
			mapView(ProgressCompareView, ProgressCompareMediator);
			mapView(ProgressAnalysisView, ProgressAnalysisMediator);
			mapView(ProgressCoverageView, ProgressCoverageMediator);
			
			// Remove the default Bento state machine (which isn't quite applicable to the builder) and replace it with a new one
			removeCommand(CommonNotifications.CONFIG_LOADED);
			registerCommand(CommonNotifications.CONFIG_LOADED, RotterdamStartupStateMachineCommand);
			
			registerCommand(BBNotifications.STARTUP, PlayerStartupCommand);
		}
		
	}
	
}