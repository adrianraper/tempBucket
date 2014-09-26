package com.clarityenglish.clearpronunciation.view.unit {
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.rotterdam.model.CourseProxy;
	import com.googlecode.bindagetools.Bind;
	
	import org.puremvc.as3.interfaces.IMediator;
	import com.clarityenglish.common.model.ConfigProxy;
	import mx.collections.ArrayCollection;
	
	public class UnitMediator extends BentoMediator implements IMediator {
		
		public function UnitMediator(mediatorName:String, viewComponent:BentoView) {
			super(mediatorName, viewComponent);
		}
		
		private function get view():UnitView {
			return viewComponent as UnitView;
		}
		
		override public function onRegister():void {
			super.onRegister();
			
			var courseProxy:CourseProxy = facade.retrieveProxy(CourseProxy.NAME) as CourseProxy;
			Bind.fromProperty(courseProxy, "widgetCollection")
				.toProperty(view, "widgetCollection");
			
			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			var configProxy:ConfigProxy = facade.retrieveProxy(ConfigProxy.NAME) as ConfigProxy;
			view.channelCollection = new ArrayCollection(configProxy.getConfig().channels);
			view.isPlatformiPad = configProxy.isPlatformiPad();
		}
	}
}