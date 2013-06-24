package com.clarityenglish.tensebuster.view.unit
{
	import com.clarityenglish.bento.BBNotifications;
	import com.clarityenglish.bento.model.BentoProxy;
	import com.clarityenglish.bento.view.base.BentoMediator;
	import com.clarityenglish.bento.view.base.BentoView;
	import com.googlecode.bindagetools.Bind;
	
	import org.puremvc.as3.interfaces.IMediator;
	
	public class UnitMediator extends BentoMediator implements IMediator {
		public function UnitMediator(mediatorName:String, viewComponent:BentoView)
		{
			super(mediatorName, viewComponent);
		}
		
		private function get view():UnitView {
			return viewComponent as UnitView;
		}
		
		public override function onRegister():void {
			super.onRegister();

			var bentoProxy:BentoProxy = facade.retrieveProxy(BentoProxy.NAME) as BentoProxy;
			view.href = bentoProxy.menuXHTML.href;
			
			Bind.fromProperty(bentoProxy, "selectedCourseNode").toProperty(view, "course");
			
			view.unitSelect.add(onUnitSelected);
		}
		
		public override function onRemove():void {
			super.onRemove();
			
			view.unitSelect.remove(onUnitSelected);
		}
		
		protected function onUnitSelected(unit:XML):void {
			sendNotification(BBNotifications.SELECTED_NODE_CHANGE, unit);
		}
	}
}