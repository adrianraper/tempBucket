package com.newgonzo.web.css
{
	import com.newgonzo.web.css.parser.CSSParser;
	import com.newgonzo.web.css.parser.ICSSParser;
	import com.newgonzo.web.css.selectors.IExtendedSelector;
	import com.newgonzo.web.css.views.ICSSView;
	import com.newgonzo.web.css.views.XMLCSSView;
	
	import org.w3c.css.sac.ISelectorList;

	public class CSSSelector
	{
		protected var cssView:ICSSView;
		protected var selectors:ISelectorList;
		
		public function CSSSelector(source:String, view:ICSSView = null, parser:ICSSParser = null)
		{
			cssView = view || new XMLCSSView();
			
			var parser:ICSSParser = parser || new CSSParser();
			selectors = parser.parseSelectors(source);
		}
		
		public function query(node:*, viewOverride:ICSSView = null):Array
		{
			var view:ICSSView = viewOverride || cssView;
			var results:Array = new Array();
			
			if(matches(node, view))
			{
				results.push(node);
			}
			
			addMatchingChildren(node, view, results);
			return results;
			
		}
		
		public function matches(node:*, viewOverride:ICSSView = null):Boolean
		{
			var view:ICSSView = viewOverride || cssView;
			var selector:IExtendedSelector;
			var i:uint = 0;
			var len:uint = selectors.length;
			
			while(i < len)
			{
				selector = selectors.item(i) as IExtendedSelector;
				
				if(selector.match(view, node))
					return true;
				
				i++;
			}
			
			return false;
		}
		
		protected function addMatchingChildren(node:*, view:ICSSView, target:Array):void
		{
			var numChildren:int = view.numChildren(node);
			
			if(numChildren == 0)
			{
				return;
			}
			
			var child:*;
			var i:int = 0;
			
			for(; i<numChildren; i++)
			{
				child = view.child(node, i);
				
				if(matches(child, view))
				{
					target.push(child);
				}
				
				addMatchingChildren(child, view, target);
			}
		}
	}
}