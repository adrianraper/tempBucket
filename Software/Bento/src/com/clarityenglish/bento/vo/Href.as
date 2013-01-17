package com.clarityenglish.bento.vo {
	
	[RemoteClass(alias="com.clarityenglish.bento.vo.Href")]
	public class Href {
		
		public static const XHTML:String = "xhtml";
		public static const MENU_XHTML:String = "menu_xhtml";
		public static const EXERCISE:String = "exercise";
		
		public var type:String;
		public var filename:String;
		public var currentDir:String;
		public var serverSide:Boolean;
		public var transforms:Array;
		
		public function Href(type:String, filename:String, currentDir:String = null, serverSide:Boolean = false, transforms:Array = null) {
			this.type = type;
			this.filename = filename;
			this.currentDir = currentDir;
			this.serverSide = serverSide;
			this.transforms = transforms;
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
			return (matches.length == 2) ? matches[1].toLowerCase() : null;
		}
		
		/**
		 * Create a new Href relative to this href (this simply means that currentDir is set to this Href's currentDir)
		 * 
		 * @param type
		 * @param filename
		 * @return 
		 */
		public function createRelativeHref(type:String, filename:String):Href {
			return new Href(type, filename, rootPath);
		}
		
		public function clone():Href {
			return new Href(type, filename, currentDir);
		}
		
		public function toString():String {
			return "[Href type=" + type + " filename=" + filename + " currentDir=" + currentDir + ((serverSide) ? " *SERVERSIDE*" : "") + "]";
		}
		
	}
	
}