package com.clarityenglish.bento.css.views {
	import com.newgonzo.web.css.CSS;
	import com.newgonzo.web.css.views.XMLCSSView;
	
	public class StyledXMLView extends XMLCSSView {
		public var css:CSS;
		
		public function StyledXMLView(css:CSS) {
			super();
			this.css = css;
		}
		
		override public function attributes(node:*, localName:String, namespaceURI:String = null):Array {
			var style:Object = css.style(node);
			var value:* = style[localName];
			
			if (value) {
				return [value];
			} else {
				return super.attributes(node, localName, namespaceURI);
			}
		}
	}
}