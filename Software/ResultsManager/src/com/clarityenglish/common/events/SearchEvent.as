package com.clarityenglish.common.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class SearchEvent extends Event {

		public static const SEARCH:String = "search";
		public static const CLEAR_SEARCH:String = "clear_search";
		
		public static const REGEXP:String = "regexp";
		public static const EQUALS:String = "equals";
		public static const MORE_THAN:String = "more_than";
		public static const LESS_THAN:String = "less_than";
		public static const FUNCTION:String = "function";
		
		private var conditions:Array;
		
		public function SearchEvent(type:String, conditions:Array = null, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			
			this.conditions = (conditions) ? conditions : new Array();
		}
		
		/**
		 * A search condition consists of a property and a regular expression.  If the property of the object being searched
		 * matches the regular expression the condition passes.  If all conditions pass the object is a valid search result.
		 * Empty RegExps are not added to the conditions.
		 * 
		 * @param	property A property on the object being search, for example 'name'
		 * @param	regExp A regular expression to be matched on that property
		 */
		public function addRegExpCondition(property:String, regExp:RegExp):void {
			if (regExp.source != "")
				conditions.push( { property: property, value: regExp, type: REGEXP } );
		}
		
		public function addEqualsCondition(property:String, value:*):void {
			conditions.push( { property: property, value: value, type: EQUALS } );
		}
		
		public function addMoreThanCondition(property:String, value:Number):void {
			conditions.push( { property: property, value: value, type: MORE_THAN } );
		}
		
		public function addLessThanCondition(property:String, value:Number):void {
			conditions.push( { property: property, value: value, type: LESS_THAN } );
		}
		
		public function addFunctionCondition(callback:Function, params:Array):void {
			conditions.push( { callback: callback, params: params, type: FUNCTION } );
		}
		
		public function getConditions():Array {
			return conditions;
		}
		
		public function validateObject(obj:Object):Boolean {
			for each (var condition:Object in getConditions()) {
				switch (condition.type) {
					case SearchEvent.REGEXP:
						// Ticket #114 - studentID can be null so we need to explicitly check for this as well as the match
						if (!obj[condition.property] || !obj[condition.property].match(condition.value))
							return false;
						break;
					case SearchEvent.EQUALS:
						if (obj[condition.property] != condition.value)
							return false;
						break;
					case SearchEvent.MORE_THAN:
						if (obj[condition.property] <= condition.value)
							return false;
						break;
					case SearchEvent.LESS_THAN:
						if (obj[condition.property] >= condition.value)
							return false;
						break;
					case SearchEvent.FUNCTION:
						return condition.callback(obj, condition.params);
						break;
					default:
						throw new Error("Unknown search condition type '" + condition.type + "'");
				}
			}
			
			return true;
		}
		
		public override function clone():Event { 
			return new SearchEvent(type, conditions, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("SearchEvent", "type", "conditions", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}