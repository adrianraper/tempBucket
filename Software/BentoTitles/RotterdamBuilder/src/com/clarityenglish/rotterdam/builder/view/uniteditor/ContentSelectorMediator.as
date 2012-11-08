package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.rotterdam.builder.model.ContentProxy;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	
	import org.davekeen.rpc.ResultResponder;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class ContentSelectorMediator extends BentoMediator implements IMediator {
		
		public function ContentSelectorMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():ContentSelectorView {
			return viewComponent as ContentSelectorView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			var contentProxy:ContentProxy = facade.retrieveProxy(ContentProxy.NAME) as ContentProxy;
			contentProxy.getContent().addResponder(new ResultResponder(onContentLoadSuccess));
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
		
		private function onContentLoadSuccess(e:ResultEvent, token:Object):void {
			view.titleCollection = new ArrayCollection(e.result as Array);
		}
		
	}
}
