package com.clarityenglish.resultsmanager.view.management.events {
	import com.clarityenglish.resultsmanager.view.management.ManageablesMediator;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.Manageable;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class ManageableEvent extends Event {
		
		public static const ADD_GROUP:String = "add_group";
		public static const ADD_TEACHER:String = "add_teacher"; // This is just used within the view - ADD_USER is used for PureMVC communication
		public static const ADD_REPORTER:String = "add_reporter"; // This is just used within the view - ADD_USER is used for PureMVC communication
		public static const ADD_LEARNER:String = "add_learner"; // This is just used within the view - ADD_USER is used for PureMVC communication
		public static const ADD_AUTHOR:String = "add_author"; // This is just used within the view - ADD_USER is used for PureMVC communication
		
		public static const ASSIGN_CLASSES:String = "assign_classes";
		public static const GET_EXTRA_GROUPS:String = "get_extra_groups";
		
		public static const EXPORT:String = "export";
		public static const ARCHIVE:String = "archive";
		public static const IMPORT:String = "import";
		// v3.6.1
		// gh#653
		public static const IMPORT_FROM_EXCEL:String = "import_from_excel";
		public static const IMPORT_FROM_EXCEL_WITH_MOVE:String = "import_from_excel_with_move";
		public static const IMPORT_FROM_EXCEL_WITH_COPY:String = "import_from_excel_with_copy";
		
		public static const DELETE:String = "delete";
		public static const DETAILS:String = "details";
		public static const SEARCH:String = "search";
		
		public static const ADD_USER:String = "add_user";
		public static const UPDATE_USERS:String = "update_users";
		public static const UPDATE_GROUPS:String = "update_groups";
		public static const MOVE_MANAGEABLES:String = "move_manageables";
		
		public var manageables:Array;
		public var parentGroup:Group;
		
		public function ManageableEvent(type:String, manageables:Array = null, parentGroup:Group = null, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			
			this.manageables = manageables;
			this.parentGroup = parentGroup;
		}
		
		public function get manageable():Manageable {
			if (manageables.length != 1)
				throw new Error("Unable to get a single manageable from ManageableEvent as there are " + manageables.length + " objects");
				
			return manageables[0] as Manageable;
		}
		
		public function set manageable(m:Manageable):void {
			manageables = [ m ];
		}
		
		public override function clone():Event { 
			return new ManageableEvent(type, manageables, parentGroup, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ManageableEvent", "type", "manageables", "parentGroup", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}