package com.clarityenglish.textLayout.css {
	import com.clarityenglish.textLayout.css.properties.TabManager;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.newgonzo.web.css.CSSContext;
	import com.newgonzo.web.css.ICSSFactory;
	import com.newgonzo.web.css.properties.PropertyManager;
	import com.newgonzo.web.css.values.StringValue;
	import com.newgonzo.web.css.views.ICSSView;
	
	import org.w3c.dom.css.CSSPrimitiveValueTypes;
	
	public class XHTMLCSSContext extends CSSContext {
		
		public function XHTMLCSSContext(defaultCSSView:ICSSView = null, objectFactory:ICSSFactory = null) {
			super(defaultCSSView, objectFactory);
			
			// Add property managers here
			addPropertyManager(new TabManager("tab-stops"));
			
			// TODO: This doesn't stop position being inherited
			addPropertyManager(new PropertyManager("position", new StringValue(CSSPrimitiveValueTypes.CSS_STRING, FloatableTextFlow.POSITION_STATIC), true));
		}
		
	}
}
