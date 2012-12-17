package com.clarityenglish.resultsmanager.view.management.events {
	import com.clarityenglish.resultsmanager.view.management.ContentMediator;
	import com.clarityenglish.common.vo.content.Content;
	import flash.events.Event;
	import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class ContentEvent extends Event {
		
		// v3.4 For Editing Clarity Content
		public static const EDIT_EXERCISE:String = "edit_exercise";
		public static const DELETE_EXERCISE:String = "delete_exercise";
		public static const RESET_CONTENT:String = "reset_content";
		public static const MOVE_CONTENT_BEFORE:String = "move_content_before";
		public static const MOVE_CONTENT_AFTER:String = "move_content_after";
		public static const INSERT_CONTENT_BEFORE:String = "insert_content_before";
		public static const INSERT_CONTENT_AFTER:String = "insert_content_after";
		public static const CHECK_FOLDER:String = "check_folder";
		public static const COPY_CONTENT_BEFORE:String = "copy_content_before";
		public static const COPY_CONTENT_AFTER:String = "copy_content_after";
		//gh:#29
		public static const DISABLE_CONTENT_EDIT:String = "disable_content_edit";
		
		// And to show direct links to content
		public static const DIRECT_START_LINK:String = "direct_start_link";
		public static const PREVIEW:String = "preview";
		
		// For refreshing content based on a button click
		public static const GET_CONTENT:String = "get_content";
		
		public var editedUID:String;
		public var relatedUID:String;
		public var groupID:String;
		public var caption:String;
		
		public function ContentEvent(type:String, editedUID:String = null, groupID:String = null, relatedUID:String=null, caption:String=null, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			
			this.editedUID = editedUID;
			this.relatedUID = relatedUID;
			this.groupID = groupID;
			this.caption = caption;
		}
		
		public override function clone():Event { 
			return new ContentEvent(type, editedUID, groupID, relatedUID, caption, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ContentEvent", "type", "editedUID", "groupID", "relatedUID", "caption", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}