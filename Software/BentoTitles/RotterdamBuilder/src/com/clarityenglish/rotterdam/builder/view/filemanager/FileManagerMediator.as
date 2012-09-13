package com.clarityenglish.rotterdam.builder.view.filemanager {
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.model.ConfigProxy;
	import com.clarityenglish.common.model.LoginProxy;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	
	/**
	 * A Mediator
	 */
	public class FileManagerMediator extends BentoMediator implements IMediator {
		
		public function FileManagerMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():FileManagerView {
			return viewComponent as FileManagerView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			// TODO: This should go elsewhere since lots of things will use it
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			var loginProxy:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			
			//var contentPath:String = configProxy.getConfig().paths.content; - until we have a product and product code this points at RoadToIELTS so do it manually
			var contentPath:String = "http://dock.contentbench/Content/Rotterdam";
			contentPath += "/" + loginProxy.user.id;
			
			view.href = new Href(Href.XHTML, "media/media.xml", contentPath);
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
