﻿package org.davekeen.util {
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class XmlUtils {
		
		/**
		 * Copies attributes from one XML object to another.  It only makes sense if they have exactly the same structure.  In practice this
		 * is used for updating a client XML object when a server-side call has changed some of its attributes.
		 * 
		 * @param sourceXml
		 * @param targetXml
		 * @param nodeName
		 * @param attributes
		 */
		public static function copyXmlAttributes(sourceXml:XML, targetXml:XML, nodeName:String, attributes:Array):void {
			var sourceNodes:XMLList = sourceXml.descendants(nodeName);
			var targetNodes:XMLList = targetXml.descendants(nodeName);
			
			if (sourceNodes.length() != targetNodes.length())
				throw new Error("Unable to copy from source to target as they have different numbers of nodes");
			
			for (var n:uint = 0; n < sourceNodes.length(); n++)
				for each (var attribute:String in attributes)
					targetNodes[n]["@" + attribute] = sourceNodes[n]["@" + attribute];
		}
		
	}
}