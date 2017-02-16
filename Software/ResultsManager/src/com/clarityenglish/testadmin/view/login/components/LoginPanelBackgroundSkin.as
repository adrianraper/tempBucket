package com.clarityenglish.testadmin.view.login.components {
	import mx.core.UIComponent;
	import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DropShadowFilter;
	import mx.core.BitmapAsset; 

	public class LoginPanelBackgroundSkin extends UIComponent {
		
		public function LoginPanelBackgroundSkin() {
			super();
		}
	
		[Bindable]
  		[Embed('/../assets/dpt_admin_panel_logo_small.png')]
  		private var logoClass:Class;

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {

			var cr:Number = 12;
			graphics.clear();
			graphics.beginFill(0xffffff);
			graphics.drawRoundRectComplex(0, 0, width, height, cr, cr, cr, cr);
			graphics.endFill();

			var logo:BitmapAsset = BitmapAsset(new logoClass());
			/* Large logo on left, like dpt sign in 
			logo.move(40,60);
			addChild(logo);
			
			// a separating line
			graphics.lineStyle(1, 0x9B9B9B, 0.9);
			graphics.moveTo(logo.width + 80, 50); 
			graphics.lineTo(logo.width + 80, logo.height + logo.y);
			*/
			/* Medium logo on top */ 
			logo.move(110,20);
			addChild(logo);
			
			// the shadow
            var filter:BitmapFilter = getBitmapFilter();
            var myFilters:Array = new Array();
            myFilters.push(filter);
            filters = myFilters;
		}

        private function getBitmapFilter():BitmapFilter {
            var color:Number = 0x000000;
            var angle:Number = 45;
            var alpha:Number = 0.8;
            var blurX:Number = 4;
            var blurY:Number = 4;
            var distance:Number = 1;
            var strength:Number = 0.65;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;
            return new DropShadowFilter(distance,
                                        angle,
                                        color,
                                        alpha,
                                        blurX,
                                        blurY,
                                        strength,
                                        quality,
                                        inner,
                                        knockout);
        }
	}
}