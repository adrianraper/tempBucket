package com.clarityenglish.textLayout.css.properties {
	import com.newgonzo.web.css.properties.PropertyManager;
	import com.newgonzo.web.css.values.IValue;
	import com.newgonzo.web.css.values.ListValue;
	
	public class TabManager extends PropertyManager {
		
		public function TabManager(propertyName:String) {
			super(propertyName, defaultValue, isInherited);
		}
		
		public override function get defaultValue():IValue {
			var listValue:ListValue = new ListValue();
			listValue.separator = " ";
			return listValue;
		}
		
	}
}
