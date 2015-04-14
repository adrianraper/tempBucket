package com.clarityenglish.common.vo.content {
	import com.clarityenglish.common.vo.Reportable;
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.content.Content")]
	[Bindable]
	public class Content extends Reportable {

		// v3.4 Editing Clarity Content
		public static const CONTENT_NONEDITABLE:int = 32;
		public static const CONTENT_EDITED_CONTENT:int = 16;
		
		/**
		 * The name of the content.  I'm not totally sure what this is used for (looks like the caption is used instead).
		 * This is the standard. Caption was a duplicate.
		 */
		public var name:String;
		
		/**
		 * The caption of the content for display in the tree.
		 * Use name instead.
		 */
		// public var caption:String;
		
		/**
		 * Multi-purpose field used for storing various statistics about the content object
		 */
		[Transient]
		public var stats:Object;
		
		/**
		 * Sets various navigation and display options (binary flags) - not actually used by title
		 */
		private var _enabledFlag:uint;
		
		public function Content() {
			
		}
		
		/**
		 * This returns the label of the reportable to be shown in the tree (in this case the caption)
		 * Override to name.
		 */
		[Transient]
		//override public function get reportableLabel():String { return caption; }
		override public function get reportableLabel():String { return name; }
		
		public function get enabledFlag():uint { return _enabledFlag; }
		
		public function set enabledFlag(value:uint):void {
			_enabledFlag = value;
		}
		
		/* INTERFACE mx.core.IUID */
		
		/**
		 * For content the UID is defined as <productCode>.<courseID>.<unitID>.<exerciseID> - together these uniquely define an item of content.
		 */
		
	}
	
}