package com.clarityenglish.bento.vo.content.model
{
	public class Hint
	{
		public var xml:XML;
		
		public function Hint(xml:XML = null) {
			this.xml = xml;
		}
		
		public function get source():String {
			return xml.@source;
		}
		
		public function get title():String {
			return (xml.@title.toString().length > 0) ? xml.@title : "Hint";
		}
		
		public function get width():Number {
			return xml.@width || NaN;
		}
		
		public function get height():Number {
			return xml.@height || NaN;
		}
	}
}