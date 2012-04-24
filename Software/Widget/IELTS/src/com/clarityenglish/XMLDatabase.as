package com.clarityenglish 
{

	/**
	 * ...
	 * @author Adrian Raper, Clarity Language Consultants Ltd
	 */
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.clarityenglish.utils.TraceUtils;

	public class XMLDatabase extends EventDispatcher {
		
		public static var LOADED:String = "loaded";
		var institutionsXML:XML;
		
		/**
		 * Reads an xml file of institutions that recognise IELTS
		 * 
		 * @param	message The text to display
		 * @return
		 */
		public function XMLDatabase(databaseName:String, folder:String=null) {
			loadXMLFile(databaseName, folder);
		}
		private function loadXMLFile(databaseName:String, folder:String=null) {
			//TraceUtils.myTrace("load XML");
			// Read the XML file - default is the same folder as the swf (not the same folder as the html that loads the swf)
			var dataLoader:URLLoader = new URLLoader();
			if (folder) {
				if (folder.charAt(folder.length-1)!="/")
					folder+="/";
			}
			TraceUtils.myTrace("path=" + folder);
			dataLoader.load(new URLRequest(folder + databaseName));
			dataLoader.addEventListener(Event.COMPLETE, processXML);
		}
		
		private function processXML(e:Event):void {
			this.institutionsXML = new XML(e.target.data);
			//TraceUtils.myTrace("full xml=" + this.institutionsXML.toString().substr(0,1024));
			// Broadcast an event for the literals class
			dispatchEvent(new Event(XMLDatabase.LOADED));
		}
		
		public function getInstitution(searchString:String):XMLList {
			if (!this.institutionsXML) return new XMLList();
			// Make the search case insensitive
			var searchPattern:RegExp = new RegExp(searchString, "i"); 
			var idResults:XMLList = this.institutionsXML.institution.(id.toString().search(searchPattern) > -1);
			var nameResults:XMLList = this.institutionsXML.institution.(name.toString().search(searchPattern) > -1);
			//TraceUtils.myTrace("name match xml=" + nameResults.toString().substr(0,1024));
			var cityResults:XMLList = this.institutionsXML.institution.(city.toString().search(searchPattern) > -1);
			var stateResults:XMLList = this.institutionsXML.institution.(state.toString().search(searchPattern) > -1);
			//var thisInstitution:XMLList = nameResults + cityResults + stateResults;
			var thisInstitution:XMLList = idResults + nameResults + cityResults + stateResults;
			TraceUtils.myTrace("matched " + thisInstitution.length());
			//var thisInstitution:XMLList = nameResults;
			return thisInstitution;
		}

	}
	
}