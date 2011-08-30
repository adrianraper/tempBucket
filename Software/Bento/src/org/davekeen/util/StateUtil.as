package org.davekeen.util {
	import mx.events.FlexEvent;
	import mx.states.State;
	
	import spark.components.supportClasses.SkinnableComponent;

	public class StateUtil {
		
		/**
		 * A helper method to define states without using MXML.
		 * 
		 * <pre>
		 * StateUtil.addStates(this, [ "state1", "state2", "state3" ] );
		 * </pre>
		 * 
		 * if the equivalent of:
		 * 
		 * <pre>
		 * <s:states>
		 *   <s:State name="state1" enterState="invalidateSkinState()" />
		 *   <s:State name="state2" enterState="invalidateSkinState()" />
		 *   <s:State name="state3" enterState="invalidateSkinState()" />
		 * </s:states>
		 * </pre>
		 * 
		 * If an optional third paramter is set true, the current (i.e. default) state will be set to the first in the list
		 * 
		 * @param component
		 * @param states
		 * @param personSelected
		 * 
		 */
		public static function addStates(component:SkinnableComponent, states:Array, firstStateIsDefault:Boolean = false):void {
			for each (var stateName:String in states) {
				var state:State = new State( { name: stateName } );
				
				state.addEventListener(FlexEvent.ENTER_STATE, function(e:FlexEvent):void { component.invalidateSkinState(); }, false, 0, false );
				component.states.push(state);
			}
			
			if (firstStateIsDefault && states.length > 0)
				component.currentState = states[0];
		}
		
	}
	
}