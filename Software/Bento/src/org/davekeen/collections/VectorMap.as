package org.davekeen.collections {
	
	/**
	 * A simple key/value map that uses Vectors instead of a Dictionary and hence circumvents https://bugs.adobe.com/jira/browse/FP-2869 and can use XML
	 * as a key.
	 * 
	 * One disadvantage of this is that this cannot use weak references and VectorMaps have to be explicitly cleared and nullified in order for
	 * garbage collection to work properly.
	 * 
	 * @author Dave
	 */
	public class VectorMap {
		
		private var _keys:Vector.<Object>;
		private var _values:Vector.<Object>;
		
		public function VectorMap() {
			clear();
		}
		
		/**
		 * Add value to the map indexed on key
		 * 
		 * @param key
		 * @param value
		 */
		public function put(key:Object, value:Object):void {
			if (key == null)
				throw new Error("Attempted to put an entry into the map with a null key");
			
			// If the key exists then replace it
			var idx:int = _keys.indexOf(key);
			if (idx >= 0) {
				_keys.splice(idx, 1);
				_values.splice(idx, 1);
			}
			
			_keys.push(key);
			_values.push(value);
		}
		
		/**
		 * Retrieve the value with the given key, or null if it doesn't exist
		 * 
		 * @param key
		 * @return 
		 */
		public function get(key:Object):Object {
			if (key == null)
				throw new Error("Attempted to get an entry into the map with a null key");
			
			var idx:int = _keys.indexOf(key);
			return (idx < 0) ? null : values[idx];
		}
		
		/**
		 * Remove the value with the given key
		 * 
		 * @param key
		 * @return The removed object if it existed, or null otherwise
		 */
		public function remove(key:Object):Object {
			if (key == null)
				throw new Error("Attempted to remove an entry in the map with a null key");
			
			var idx:int = _keys.indexOf(key);
			if (idx >= 0) {
				var object:Object = get(key);
				
				_keys.splice(idx, 1);
				_values.splice(idx, 1);
				
				return object;
			}
			
			return null;
		}
		
		/**
		 * Return the list of keys
		 *  
		 * @return 
		 */
		public function get keys():Vector.<Object> {
			return _keys;
		}
		
		/**
		 * Return the list of values
		 * 
		 * @return 
		 */
		public function get values():Vector.<Object> {
			return _values;
		}
		
		/**
		 * Returns true if the map contains the given key
		 * 
		 * @param key
		 * @return 
		 */
		public function containsKey(key:Object):Boolean {
			if (key == null)
				throw new Error("Attempted to test for an entry in the map with a null key");
			
			return (_keys.indexOf(key) > -1);
		}
		
		/**
		 * Empty the map
		 */
		public function clear():void {
			_keys = new Vector.<Object>();
			_values = new Vector.<Object>();
		}
		
	}
	
}
