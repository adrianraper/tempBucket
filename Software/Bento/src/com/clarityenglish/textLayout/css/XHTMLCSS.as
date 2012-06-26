package com.clarityenglish.textLayout.css {
	import com.newgonzo.web.css.CSS;
	import com.newgonzo.web.css.ICSSContext;
	import com.newgonzo.web.css.ICSSDocument;
	import com.newgonzo.web.css.rules.StyleRule;
	
	import org.w3c.dom.css.ICSSRuleList;
	import org.w3c.dom.css.ICSSStyleDeclaration;
	import org.w3c.dom.css.ICSSValue;
	
	public class XHTMLCSS extends CSS {
		
		public static const defaultContext:ICSSContext = new XHTMLCSSContext();
		
		public function XHTMLCSS(source:String=null, context:ICSSContext=null) {
			super(source, context ? context : defaultContext);
		}
		
	}
}