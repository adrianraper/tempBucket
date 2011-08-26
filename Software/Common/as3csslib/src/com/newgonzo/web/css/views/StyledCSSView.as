package com.newgonzo.web.css.views
{
	import com.newgonzo.web.css.CSS;

	public class StyledCSSView implements ICSSView
	{
		public var css:CSS;
		public var view:ICSSView;
		
		public function StyledCSSView(view:ICSSView, css:CSS)
		{
			this.view = view;
			this.css = css;
		}
		
		public function get ignoreCase():Boolean
		{
			return view.ignoreCase;
		}
		
		public function set ignoreCase(value:Boolean):void
		{
			view.ignoreCase = value;
		}
		
		public function localName(node:*):String
		{
			return view.localName(node);
		}
		
		public function namespaceURI(node:*):String
		{
			return view.namespaceURI(node);
		}
		
		public function lang(node:*):String
		{
			return view.lang(node);
		}
		
		public function cssId(node:*):String
		{
			return view.cssId(node);
		}
		
		public function cssClass(node:*):String
		{
			return view.cssClass(node);
		}
		
		public function childIndex(node:*):int
		{
			return view.childIndex(node);
		}
		
		public function parent(node:*):*
		{
			return view.parent(node);
		}
		
		public function numChildren(node:*):int
		{
			return view.numChildren(node);
		}
		
		public function child(node:*, index:int):*
		{
			return view.child(node, index);
		}
		
		public function textContent(node:*):String
		{
			return view.textContent(node);
		}
		
		public function isPseudoClass(node:*, pseudoClass:String):Boolean
		{
			return view.isPseudoClass(node, pseudoClass);
		}
		
		public function isType(node:*, localName:String):Boolean
		{
			return view.isType(node, localName);
		}
		
		public function attributes(node:*, localName:String, namespaceURI:String=null):Array
		{
			var style:Object = css.style(node);
			var value:* = style[localName];
			
			if(value)
				return [value];
			else
				return view.attributes(node, localName, namespaceURI);
		}
		
		public function presentationalHint(node:*, localName:String):String
		{
			return view.presentationalHint(node, localName);
		}
	}
}