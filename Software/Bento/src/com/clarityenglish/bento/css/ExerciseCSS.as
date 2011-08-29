package com.clarityenglish.bento.css {
	import com.newgonzo.web.css.CSS;
	import com.newgonzo.web.css.ICSSContext;
	import com.newgonzo.web.css.ICSSDocument;
	import com.newgonzo.web.css.rules.StyleRule;
	
	import org.w3c.dom.css.ICSSRuleList;
	import org.w3c.dom.css.ICSSStyleDeclaration;
	import org.w3c.dom.css.ICSSValue;
	
	public class ExerciseCSS extends CSS {
		
		public static const defaultContext:ICSSContext = new ExerciseCSSContext();
		
		public function ExerciseCSS(source:String=null, context:ICSSContext=null) {
			super(source, context ? context : defaultContext);
		}
		
		public function getFloats():Array {
			var matchingNodes:Array = [];
			
			// This is a good start :)  not quite right however; John French is investigating
			var document:ICSSDocument;
			var cascade:Array = styleSelector.documents;
			
			for each (document in cascade) {
				var cssRules:ICSSRuleList = document.styleSheet.cssRules;
				for (var n:uint = 0; n < cssRules.length; n++) {
					var cssRule:StyleRule = cssRules.item(n) as StyleRule;
					if (cssRule) {
						var float:ICSSValue = cssRule.style.getPropertyCSSValue("float");
						//if (float)
						//	matchingNodes.push();
					}
				}
			}
			
			return null;
		}
		
	}
}