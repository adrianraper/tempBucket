package com.clarityenglish.textLayout.css {
	import com.clarityenglish.textLayout.css.properties.TabManager;
	import com.newgonzo.web.css.CSSContext;
	import com.newgonzo.web.css.ICSSFactory;
	import com.newgonzo.web.css.views.ICSSView;
	
	public class XHTMLCSSContext extends CSSContext {
		
		public function XHTMLCSSContext(defaultCSSView:ICSSView = null, objectFactory:ICSSFactory = null) {
			super(defaultCSSView, objectFactory);
			
			// Add property managers here
			addPropertyManager(new TabManager("tab-stops"));
		}
		
	}
}
