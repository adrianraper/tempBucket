package com.clarityenglish.rotterdam.view.unit.widgets {
	import com.clarityenglish.bento.view.DynamicView;
	import com.clarityenglish.bento.vo.Href;
	
	public class AuthoringWidget extends AbstractWidget {
		
		[SkinPart]
		public var dynamicView:DynamicView;
		
		public function AuthoringWidget() {
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case dynamicView:
					dynamicView.href = menuXHTMLHref.createRelativeHref(Href.EXERCISE, xml.@href, true);
					break;
			}
		}
		
	}
	
}
