package com.clarityenglish.textLayout.css {
	import com.newgonzo.web.css.CSS;
	import com.newgonzo.web.css.ICSSContext;
	
	public class XHTMLCSS extends CSS {
		
		public static const defaultContext:ICSSContext = new XHTMLCSSContext();
		
		public function XHTMLCSS(source:String=null, context:ICSSContext=null) {
			super(source, context ? context : defaultContext);
		}
		
	}
}