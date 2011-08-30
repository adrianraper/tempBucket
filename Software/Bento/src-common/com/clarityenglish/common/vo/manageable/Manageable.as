package com.clarityenglish.common.vo.manageable {
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.Reportable;
	import org.davekeen.util.ClassUtil;
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.manageable.Manageable")]
	[Bindable]
	public class Manageable extends Reportable {
		
		/**
		 * Group or user name for display in tree
		 */
		public var name:String;
		
		/**
		 * Custom attributes
		 */
		public var custom1:String;
		public var custom2:String;
		public var custom3:String;
		public var custom4:String;
		
		public function Manageable() {
			
		}
		
		/**
		 * This returns the label of the reportable to be shown in the tree (in this case the name)
		 */
		[Transient]
		override public function get reportableLabel():String { return name; }
		
		/**
		 * Count the number of Users in and below this Manageable.  Overridden by concrete implementations.
		 */
		public function get userCount():uint {
			return 0;
		}
		
		/**
		 * Count the number of Groups in and below this Manageable.  Overridden by concrete implementations.
		 */
		public function get groupCount():uint {
			return 0;
		}
		
		/**
		 * Lets us know whether or not this manageable is licenced for use with a given title
		 * 
		 * @param	title The title to check the license for
		 * @return
		 */
		public function isLicencedForTitle(title:Title):Boolean {
			throw new Error("Must be overridden by children");
		}
		
		/** 
		 * Returns all groups in and below this manageables (all the way down the tree).  For example calling this on a
		 * top level group will return every group in that tree.
		 * 
		 * @param ids An optional array of ids to search for
		 * @return An array of Group objects
		 */
		public function getSubGroups(ids:Array = null):Array {
			throw new Error("Must be overridden by children");
		}
		
		/**
		 * Returns all users in and below this manageable (all the way down the tree).  For example calling this on a
		 * top level group will return every user in that tree.
		 *
		 * @param userType If this parameter is given only users of the specified userType are returned
		 * @return An array of User objects
		 */
		public function getSubUsers(userType:int = -1):Array {
			throw new Error("Must be overridden by children");
		}
		
		/**
		 * Determines whether this manageable contains the given manageable
		 * 
		 * @param	manageable
		 * @return
		 */
		public function contains(manageable:Manageable):Boolean {
			throw new Error("Must be overridden by children");
		}
		
		/**
		 * A helper function to normalize an array of manageables.  This effectively eliminates duplicates and is used in
		 * situations where the user might select a bunch of groups and users together.
		 * 
		 * @param	manageables
		 * @return
		 */
		public static function normalizeManageables(manageables:Array):Array {
			var removeList:Array = new Array();
			
			// Get a list of duplicates that need to be removed
			for each (var m:Manageable in manageables) {
				var contains:Boolean = false;
				
				for each (var n:Manageable in manageables)
					if (m.contains(n))
						removeList.push(n);
				
			}
			
			// Filter the array by the manageables we want to remove
			return manageables.filter(function(item:Manageable, index:int, array:Array):Boolean {
				for each (var removeManageable:Manageable in removeList)
					if (removeManageable.uid == item.uid)
						return false;
				
				return true;
			} );
		}
		
		public static function getPathToManageable(manageable:Manageable, manageables:Array):Array {
			var path:Array = new Array();
			getPathElement(manageable, manageables);
			
			function getPathElement(needle:Manageable, haystack:Array):void {
				for each (var child:Manageable in haystack) {
					if (child.contains(needle)) {
						path.push(child);
						getPathElement(needle, child.children);
					}
				}
			}
			
			return path;
		}
		
		/**
		 * We need to override the reportables version of this method since ids for manageables are unique and we only want to return a single
		 * entry in the IDObject rather than a tree.
		 * 
		 * @return
		 */
		override public function toIDObject():Object {
			var reportableObj:Object = new Object();
			reportableObj[ClassUtil.getClassAsString(this)] = id;
			
			return reportableObj;
		}
		
	}
	
}