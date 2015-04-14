package com.clarityenglish.common.vo.content {
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.content.Exercise")]
	[Bindable]
	public class Exercise extends Content {
		
		public static const ENABLED_FLAG_MENUON:uint = 1;
		public static const ENABLED_FLAG_NAVIGATEON:uint = 2;
		public static const ENABLED_FLAG_RANDOMON:uint = 4;
		public static const ENABLED_FLAG_DISABLED:uint = 8;
		public static const ENABLED_FLAG_EDITED:uint = 16;
		public static const ENABLED_FLAG_NONEDITABLE:uint = 32;
		public static const ENABLED_FLAG_AUTOPLAY:uint = 64;
		public static const ENABLED_FLAG_NONDISPLAY:uint = 128;
		public static const ENABLED_FLAG_EXITAFTER:uint = 256;
		public static const ENABLED_FLAG_MOVED:uint = 512;
		public static const ENABLED_FLAG_INSERTED:uint = 1024;
		//public static const ENABLED_FLAG_EDITEDCONTENT_INSERT:uint = 512;

		public static const EDIT_MODE_EDITED:uint = 0;
		public static const EDIT_MODE_DELETED:uint = 1;
		public static const EDIT_MODE_INSERTEDBEFORE:uint = 2;
		public static const EDIT_MODE_INSERTEDAFTER:uint = 3;
		public static const EDIT_MODE_MOVEDBEFORE:uint = 4;
		public static const EDIT_MODE_MOVEDAFTER:uint = 5;

		// EMU progress reporting
		public var trackableID:String;
		public var maxScore:Number;

		// v3.4 Editing Clarity Content
		// I need another UID to show that although this item is currently placed at x in the tree (and so has a particular UID)
		// it originated at y - and therefore if you move it again the UID to go into the database is x not y.
		// If you allow moving of units, you probably need to do the same thing there too.
		public var originalUID:String;
		
		// v3.4.1 Editing Clarity Content. Bug. #132. It could be very useful to know if the filename is different from usual
		public var filename:String;
		
		public function Exercise() {
			
		}
		
		/* INTERFACE mx.core.IUID */		
		override public function get uid():String {
			return parent.uid + "." + id;
		}
		
		override public function set uid(value:String):void { }
		
	}
	
}