package com.clarityenglish.bento.vo {
	
	[RemoteClass(alias="com.clarityenglish.bento.vo.Href")]
	public class Href {
		
		public static const XHTML:String = "xhtml";
		public static const MENU_XHTML:String = "menu_xhtml";
		public static const EXERCISE:String = "exercise";
		public static const EXERCISE_GENERATOR:String = "exercise_generator";
		
		public var type:String;
		public var filename:String;
		public var currentDir:String;
		public var serverSide:Boolean;
		public var transforms:Array;
		public var options:Object;
		
		public function Href(type:String, filename:String, currentDir:String = null, serverSide:Boolean = false) {
			this.type = type;
			this.filename = filename;
			this.currentDir = currentDir;
			this.serverSide = serverSide;
			this.transforms = [];
		}
		
		/**
		 * Get the full url including the current dir and filename
		 * 
		 * @return 
		 */
		public function get url():String {
			return ((currentDir) ? currentDir + "/" : "") + filename;
		}
		
		/**
		 * Get the path that the file itself is in (by removing the filename from the full url).  This is used to
		 * load resources within the file.
		 * 
		 * @return 
		 */
		public function get rootPath():String {
			return url.replace(/\/(\w|\d|\.|-)*$/, "");
		}
		
		/**
		 * Get the extension of the filename
		 * 
		 * @return  
		 */
		public function get extension():String {
			var matches:Array = filename.match(/\.([^\.]+)$/);
			return (matches && matches.length == 2) ? matches[1].toLowerCase() : null;
		}
		
		/**
		 * Create a new Href relative to this href (this simply means that currentDir is set to this Href's currentDir)
		 * 
		 * @param type
		 * @param filename
		 * @return 
		 */
		// gh#265 add "serverSide" to the function
		public function createRelativeHref(type:String, filename:String, serverSide:Boolean = false):Href {
			return new Href(type, filename, rootPath, serverSide);
		}
		
		public function resetTransforms():void {
			transforms = [];
		}
		
		public function clone():Href {
			return new Href(type, filename, currentDir, serverSide);
		}
		
		public function toString():String {
			return "[Href type=" + type + " filename=" + filename + " currentDir=" + currentDir + ((serverSide) ? " *SERVERSIDE*" : "") + "]";
		}
		
	}
	
}