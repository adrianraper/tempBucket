package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.rotterdam.RotterdamNotifications;
	import com.clarityenglish.rotterdam.builder.model.ContentProxy;
	
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import org.davekeen.rpc.ResultResponder;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class AuthoringMediator extends BentoMediator implements IMediator {
		
		public function AuthoringMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():AuthoringView {
			return viewComponent as AuthoringView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// This view runs directly off the generator xml (not loaded through the server)
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.menuXHTML && view.widgetNode && view.widgetNode.@href)
				view.href = bentoProxy.menuXHTML.href.createRelativeHref(Href.EXERCISE_GENERATOR, view.widgetNode.@href);
			
			view.exerciseSave.add(onExerciseSave);
		}
		
		override public function onRemove():void {
			super.onRemove();
			
			view.exerciseSave.remove(onExerciseSave);
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
		
		protected function onExerciseSave(widgetXML:XML, exerciseXML:XML, exerciseGeneratorHref:Href):void {
			sendNotification(RotterdamNotifications.EXERCISE_SAVE, { widgetXML: widgetXML, exerciseXML: exerciseXML });
		}
		
	}
}
