package com.newgonzo.web.css
{
	import com.newgonzo.web.css.properties.css3.color.ColorModule;
	import com.newgonzo.web.css.properties.css3.fonts.FontModule;
	import com.newgonzo.web.css.properties.css3.text.TextModule;
	import com.newgonzo.web.css.views.ICSSView;

	public class SVGCSSContext extends CSSContext
	{
		public function SVGCSSContext(defaultCSSView:ICSSView=null, objectFactory:ICSSFactory=null)
		{
			super(defaultCSSView, objectFactory);
			
			// inherited from css3
			addPropertyManagers(ColorModule.PROPERTY_MANAGERS);
			addPropertyManagers(FontModule.PROPERTY_MANAGERS);
			addPropertyManagers(TextModule.PROPERTY_MANAGERS);
			
			// specific to svg
		}
		
	}
}