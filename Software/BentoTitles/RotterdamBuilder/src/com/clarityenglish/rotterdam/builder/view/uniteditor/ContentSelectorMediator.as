﻿package com.clarityenglish.rotterdam.builder.view.uniteditor {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
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
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.thumbnailScript = configProxy.getConfig().remoteGateway + "/services/thumbnail.php";
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
			filter(view.titleCollection);
			view.titleCollection.refresh();
		}
		
		// alice: program like CP has a single folder structure
		//filter is used to remove the single folder and display unit directly after title
		private function filter(titleCollection:ArrayCollection):void {
			for each (var item:Object in titleCollection) {
				if (item.children.length == 1) {
					var course:Object = item.children[0];
					var units:Object = course.children;
					item.children = units;
				}
			}
		}
		
	}
}
