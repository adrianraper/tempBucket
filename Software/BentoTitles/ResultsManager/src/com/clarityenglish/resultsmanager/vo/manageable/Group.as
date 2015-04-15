package com.clarityenglish.resultsmanager.vo.manageable {
	import com.clarityenglish.resultsmanager.ApplicationFacade;
	import com.clarityenglish.resultsmanager.model.ContentProxy;
	import com.clarityenglish.common.vo.content.Title;
	import mx.core.IUID;
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	[RemoteClass(alias = "com.clarityenglish.resultsmanager.vo.manageable.Group")]
	[Bindable]
	public class Group extends Manageable implements IUID {
		
		/**
		 * Collection of manageables belonging to this group
		 */
		private var _manageables:Array;
		
		/**
		 * Textual description of the group
		 */
		public var description:String;
		
		/**
		 * Whether or not MyGroups is enabled
		 */
		public var enableMyGroups:Boolean;
		
		public function Group() {
			manageables = new Array();
		}
		
		public function get manageables():Array { return _manageables; }
		
		public function set manageables(value:Array):void {
			super.children = value;
			
			_manageables = value;
		}
		
		/**
		 * Implementing a children field allows us to use this class directly as a dataprovider to a tree
		 */
		override public function get children():Array {
			return manageables;
		}
		
		override public function set children(children:Array):void {
			manageables = children;
		}
		
		/**
		 * Recursively count the number of users below this level
		 */
		override public function get userCount():uint {
			var count:uint = 0;
			
			for each (var m:Manageable in manageables)
				count += m.userCount;
				
			return count;
		}
		
		/**
		 * Recursively count the number of groups in and below this level (this includes the current group)
		 */
		override public function get groupCount():uint {
			var count:uint = 1;
			
			for each (var m:Manageable in manageables)
				count += m.groupCount;
				
			return count;
		}
		
		/**
		 * This method is no longer used. No licence allocation.
		 * A group is licensed for a title if all its members are licensed.
		 * 
		 * @param	title
		 * @return
		 */
		override public function isLicencedForTitle(title:Title):Boolean {
			// Special case - if there are no children return false
			if (children.length == 0) return false;
			
			for each (var manageable:Manageable in manageables) {
				// Ignore Users unless they are of type User.USER_TYPE_STUDENT as they are not licenced to titles
				if (manageable is User && (manageable as User).userType != User.USER_TYPE_STUDENT)
					continue;
				
				// Recurse down the tree
				if (!manageable.isLicencedForTitle(title))
					return false;
			}
					
			return true;
		}
		
		public function hasHiddenContent():Boolean {
			// We shouldn't really be retrieving proxies from value objects, but the alternatives are much messier and we know
			// we are doing it for a good reason :)
			var contentProxy:ContentProxy = ApplicationFacade.getInstance().retrieveProxy(ContentProxy.NAME) as ContentProxy;
			return (contentProxy && contentProxy.hasHiddenContent(this));
		}
		// v3.4 duplicate the above in case we want to show which groups have got edited content.
		// Don't need this. Better to do it through an interface in the itemRenderer.
		/*
		public function hasEditedContent():Boolean {
			// We shouldn't really be retrieving proxies from value objects, but the alternatives are much messier and we know
			// we are doing it for a good reason :)
			var contentProxy:ContentProxy = ApplicationFacade.getInstance().retrieveProxy(ContentProxy.NAME) as ContentProxy;
			return (contentProxy && contentProxy.hasEditedContent(this));
		}
		*/
		
		/** 
		 * Returns all groups in and below this manageables (all the way down the tree).  For example calling this on a
		 * top level group will return every group in that tree.
		 * 
		 * @param ids An optional array of ids to search for
		 * @return An array of Group objects
		 */
		override public function getSubGroups(ids:Array = null):Array {
			var result:Array = new Array();
			
			for each (var child:Manageable in children) {
				if (child is Group) {
					if (!ids || ids.indexOf(child.id) > -1)
						result.push(child);
						
					result = result.concat(child.getSubGroups(ids));
				}
			}
			
			return result;
		}
		
		/**
		 * Returns all users in and below this manageable (all the way down the tree).  For example calling this on the
		 * top level group will return every user in the tree.
		 * 
		 * @param userType If this parameter is given only users of the specified userType are returned
		 * @return An array of User objects
		 */
		override public function getSubUsers(userType:int = -1):Array {
			var result:Array = new Array();
			
			for each (var child:Manageable in children)
				result = result.concat(child.getSubUsers(userType));
			
			return result;
		}
		
		/**
		 * Determines whether this manageable contains the given manageable
		 * 
		 * @param	manageable
		 * @return
		 */
		override public function contains(manageable:Manageable):Boolean {
			var result:Boolean = false;
			
			for each (var child:Manageable in children) {
				if (child.uid == manageable.uid || child.contains(manageable)) {
					result = true;
					break;
				}
			}
			
			return result;
		}
		
		/* INTERFACE mx.core.IUID */
		
		/**
		 * By linking the uid (used by Flex dataProviders) to a unique key based on the type and database id we can ensure
		 * that Flex components still know which object is which even when performing a complete refresh from the backend.
		 */
		override public function get uid():String{
			return "group" + id;
		}
		
		override public function set uid(value:String):void { }
		
		public function toString():String {
			return "G:" + name;
		}
		
	}
	
}