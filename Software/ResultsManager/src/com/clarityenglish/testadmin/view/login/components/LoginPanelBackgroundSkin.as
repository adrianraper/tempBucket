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
  		[Embed('/../assets/DPT_TA_logo.png')]
  		private var logoClass:Class;

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {

			var cr:Number = 12;
			graphics.clear();
			graphics.beginFill(0xffffff);
			graphics.drawRoundRectComplex(0, 0, width, height, cr, cr, cr, cr);
			graphics.endFill();
			//graphics.beginFill(0x0b7bad);
			//graphics.drawRoundRectComplex(0, 130, width, height-130, 0, 0, cr, cr);
			//graphics.endFill();

			var logo:BitmapAsset = BitmapAsset(new logoClass());
			logo.move(178,50);
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