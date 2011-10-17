package org.davekeen.collections {
	
	/**
	 * A simple map that uses Vectors instead of a Dictionary and hence circumvents https://bugs.adobe.com/jira/browse/FP-2869 and can use XML
	 * as a key.
	 * 
	 * One disadvantage of this is that this cannot use weak references and VectorMaps have to be explicitly cleared and nullified in order for
	 * garbage collection to work properly.
	 * 
	 * @author Dave
	 */
	public class VectorMap {
		
		private var keys:Vector.<Object>;
		private var values:Vector.<Object>;
		
		public function VectorMap() {
			clear();
		}
		
		public function put(key:Object, value:Object):void {
			// If the key exists then replace it
			// TODO: TEST ME!
			var idx:int = keys.indexOf(key);
			if (idx >= 0) {
				keys.splice(idx, 1);
				values.splice(idx, 1);
			}
			
			keys.push(key);
			values.push(value);
		}
		
		public function fetch(key:Object):Object {
			var idx:int = keys.indexOf(key);
			return (idx < 0) ? null : values[idx];
		}
		
		public function getKeys():Vector.<Object> {
			return keys;
		}
		
		public function getValues():Vector.<Object> {
			return values;
		}
		
		public function clear():void {
			keys = new Vector.<Object>();
			values = new Vector.<Object>();
		}
		
	}
	
}
