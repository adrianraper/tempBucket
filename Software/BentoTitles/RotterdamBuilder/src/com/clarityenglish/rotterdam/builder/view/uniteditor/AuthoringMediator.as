package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.rotterdam.builder.model.ContentProxy;
	
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
			
			// This view runs off the authoring xml so load it here
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			if (bentoProxy.menuXHTML && view.widgetNode && view.widgetNode.@href)
				view.href = bentoProxy.menuXHTML.href.createRelativeHref(Href.EXERCISE_GENERATOR, view.widgetNode.@href);
		}
		
		override public function onRemove():void {
			super.onRemove();
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
		
	}
}
