package com.clarityenglish.ielts.view.zone {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.ExerciseMark;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.ielts.IELTSNotifications;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	public class AdviceZoneSectionMediator extends AbstractZoneSectionMediator implements IMediator {
		
		public function AdviceZoneSectionMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():AdviceZoneSectionView {
			return viewComponent as AdviceZoneSectionView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// This view runs off the menu xml so inject it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			view.hrefToUidFunction = bentoProxy.getExerciseUID;
			
			// Inject the available video channels
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);
			
			view.exerciseSelect.add(onExerciseSelect);
			view.videoScore.add(onVideoScore);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.exerciseSelect.remove(onExerciseSelect);
			view.videoScore.remove(onVideoScore);
			
			// This is a special case that writes the score if the user goes away from the view without explicitly paused or stopping the video (GH #50)
			var exerciseMark:ExerciseMark = view.videoSelector.getVideoScore();
			if (exerciseMark)
				onVideoScore(exerciseMark);
		}
		
		override public function listNotificationInterests():Array {
			return super.listNotificationInterests().concat([
				
			]);
		}
		
		override public function handleNotification(note:INotification):void {
			super.handleNotification(note);
			
			switch (note.getName()) {
				
			}
		}
		
		protected function onExerciseSelect(node:XML, attribute:String):void {
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, node, attribute);
		}
		
		protected function onVideoScore(exerciseMark:ExerciseMark):void {
			sendNotification(BBNotifications.SCORE_WRITE, exerciseMark);
		}
		
	}
}
