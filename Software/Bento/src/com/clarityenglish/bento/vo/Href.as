package com.clarityenglish.bento.vo {
	
	public class Href {
		
		public static const XHTML:String = "xhtml";
		public static const EXERCISE:String = "exercise";
		
		public var type:String;
		
		public var filename:String;
		
		public var currentDir:String;
		
		public function Href(type:String, filename:String, currentDir:String = null) {
			this.type = type;
			this.filename = filename;
			this.currentDir = currentDir;
		}
		
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
		
		public function toString():String {
			return "[Href filename=" + filename + " currentDir=" + currentDir + "]";
		}
		
	}
	
}
