package com.clarityenglish.bento.css {
	import com.clarityenglish.bento.css.properties.TabManager;
	import com.newgonzo.web.css.CSSContext;
	import com.newgonzo.web.css.ICSSFactory;
	import com.newgonzo.web.css.views.ICSSView;
	
	public class ExerciseCSSContext extends CSSContext {
		
		public function ExerciseCSSContext(defaultCSSView:ICSSView = null, objectFactory:ICSSFactory = null) {
			super(defaultCSSView, objectFactory);
			
			// Add property managers here
			addPropertyManager(new TabManager("tab-stops"));
		}
		
	}
}
