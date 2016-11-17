package com.clarityenglish.common.vo {
	import com.clarityenglish.common.vo.manageable.User;
	import mx.core.IUID;
	import org.davekeen.utils.ClassUtils;
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.Reportable")]
	[Bindable]
	public class Reportable implements IUID {
		
		/**
		 * The id of this reportable in the xml or database.  This has to be a Number, not a uint as the ids in the XML are so large that they
		 * go back round to 0 if they exceed the uint limit (which they do).
		 * 
		 * THIS HAS BEEN CHANGED TO A STRING AS WE SUSPECT AS<->PHP WAS CORRUPTING LARGER NUMBERS EVEN WHEN USING NUMBER INSTEAD OF INT
		 */
		public var id:String;
		
		[Transient]
		public var parent:Reportable;
		
		public function Reportable() {
			
		}
		
		/**
		 * These are dummy implementations that should be overridden by child classes
		 */
		[Transient]
		public function get children():Array { return null; }
		public function set children(children:Array):void {
			// All methods in concrete Reportables that set children (e.g. function set manageables(value:Array) in Group) also call this
			// setter.  Its responsibility is to set the parent reference in each child to allow the application to navigate upwards through
			// the hierarchy of Reportables, as well as downwards.
			
			for each (var child:Reportable in children)
				child.parent = this;
		}
		
		/**
		 * This returns the label of the reportable to be shown in the tree and should be overridden by child classes
		 */
		[Transient]
		public function get reportableLabel():String { return null; }
		
		/**
		 * Go through this reportable and all children returning an array of all reportables of class c
		 * 
		 * @param	c The class to search for (e.g. Title, Group, etc)
		 * @return An array of reportables
		 */
		public function getSubChildrenOfClass(c:Class):Array {
			var result:Array = new Array();
				
			for each (var child:Reportable in children)
				result = result.concat(child.getSubChildrenOfClass(c));
			
			if (this is c)
				result.push(this);
				
			return result;
		}
		
		/**
		 * Go through this reportable and all children returning an array of all reportables
		 * 
		 * @return An array of reportables
		 */
		public function getSubChildren():Array {
			var result:Array = new Array();
			
			for each (var child:Reportable in children)
				result = result.concat(child.getSubChildren());
			
			result.push(this);
			
			return result;
		}
		
		/**
		 * Encode the reportable tree (this and all parents) into an object with each class mapped to its id. For example:
		 * { Exercise: 23483, Unit: 1, Course: 1434, Title: 0 }
		 * 
		 * @return An object
		 */
		public function toIDObject():Object {
			var reportable:Reportable = this;
			
			var reportableObj:Object = new Object();
			do {
				// v3.3 Multi-group users.
				//reportableObj[ClassUtils.getClassAsString(reportable)] = reportable.id;
				if (reportable is User) {
					reportableObj[ClassUtils.getClassAsString(reportable)] = (reportable as User).userID;
				} else {
					reportableObj[ClassUtils.getClassAsString(reportable)] = reportable.id;
				}
				reportable = reportable.parent;
			} while (reportable);
			
			return reportableObj;
		}
		// Copy of the above to give me the caption for each part of the reportable tree
		public function toCaptionObject():Object {
			var reportable:Reportable = this;
			
			var reportableObj:Object = new Object();
			do {
				reportableObj[ClassUtils.getClassAsString(reportable)] = reportable.reportableLabel;
				reportable = reportable.parent;				
			} while (reportable);
			
			return reportableObj;
		}		
		/* INTERFACE mx.core.IUID */
		
		public function get uid():String{
			throw new Error("Must be overridden by children");
		}
		
		public function set uid(value:String):void{
			throw new Error("Must be overridden by children");
		}
		
	}
	
}