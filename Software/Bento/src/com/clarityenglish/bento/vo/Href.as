package com.clarityenglish.bento.vo {
	
	public class Href {
		
		public var filename:String;
		
		public var currentDir:String;
		
		public function Href(filename:String, currentDir:String = null) {
			this.filename = filename;
			this.currentDir = currentDir;
		}
		
		public function get url():String {
			return ((currentDir) ? currentDir + "/" : "") + filename;
		}
		
		public function toString():String {
			return "[Href filename=" + filename + " currentDir=" + currentDir + "]";
		}
		
	}
	
}
