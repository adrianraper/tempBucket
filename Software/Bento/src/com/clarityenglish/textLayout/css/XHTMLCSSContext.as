package com.clarityenglish.textLayout.css {
	import com.clarityenglish.textLayout.css.properties.TabManager;
	import com.clarityenglish.textLayout.elements.FloatableTextFlow;
	import com.newgonzo.web.css.CSSContext;
	import com.newgonzo.web.css.ICSSFactory;
	import com.newgonzo.web.css.properties.PropertyManager;
	import com.newgonzo.web.css.properties.css3.backgrounds.BackgroundColorManager;
	import com.newgonzo.web.css.properties.css3.borders.BorderModule;
	import com.newgonzo.web.css.properties.css3.borders.BorderShorthand;
	import com.newgonzo.web.css.properties.css3.box.BoxModule;
	import com.newgonzo.web.css.values.StringValue;
	import com.newgonzo.web.css.views.ICSSView;
	
	import org.w3c.dom.css.CSSPrimitiveValueTypes;
	
	public class XHTMLCSSContext extends CSSContext {
		
		public function XHTMLCSSContext(defaultCSSView:ICSSView = null, objectFactory:ICSSFactory = null) {
			super(defaultCSSView, objectFactory);
			
			// Border
			addPropertyManagers(BorderModule.PROPERTY_MANAGERS); // gh#364
			
			// Padding & margin
			addPropertyManagers(BoxModule.PROPERTY_MANAGERS);
			
			// Background
			addPropertyManager(new BackgroundColorManager());
			
			// Misc
			addPropertyManager(new TabManager("tab-stops"));
			addPropertyManager(new PropertyManager("position", new StringValue(CSSPrimitiveValueTypes.CSS_STRING, FloatableTextFlow.POSITION_STATIC), true));
		}
		
	}
}
