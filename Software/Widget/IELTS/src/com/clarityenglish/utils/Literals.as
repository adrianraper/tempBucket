package com.clarityenglish.utils 
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

	public class Literals extends EventDispatcher {
		
		public static var LOADED:String = "loaded";
		var literalsXML:XML;
		var literalsLanguage:String;
		var applicationName:String;
		
		/**
		 * Reads an xml file of multi-language literals and gives methods to get back the literal you want
		 * 
		 * @param	message The text to display
		 * @return
		 */
		public function Literals(defaultLanguage:String = 'EN', applicationName:String = 'SelfAssessedBandScoreCalculator') {
			
			// Set the default langauge to use
			this.literalsLanguage = defaultLanguage;
			this.applicationName = applicationName;
			//TraceUtils.myTrace("in lits for " + this.literalsLanguage);
			
		}
		public function loadXMLFile(folder:String=null) {
			//TraceUtils.myTrace("load XML");
			// Read the XML file - default is the same folder as the swf (not the same folder as the html that loads the swf)
			var literalsLoader:URLLoader = new URLLoader();
			if (folder) {
				if (folder.charAt(folder.length-1)!="/")
					folder+="/";
			}
			TraceUtils.myTrace("path=" + folder);
			literalsLoader.load(new URLRequest(folder + "literals.xml"));
			literalsLoader.addEventListener(Event.COMPLETE, processXML);
		}
		
		private function processXML(e:Event):void {
			this.literalsXML = new XML(e.target.data);
			//TraceUtils.myTrace(this.literalsXML.language.(@code==this.literalsLanguage).group.(@name=='BandScoreCalculator').toXMLString());
			//TraceUtils.myTrace(this.getLiteral('applicationName'));
			// Broadcast an event for the literals class
			dispatchEvent(new Event(Literals.LOADED));
		}
		
		public function literalExists(name:String):Boolean {
			if (!this.literalsXML) return false;
			var thisLiteral:XMLList = this.literalsXML.language.(@code==this.literalsLanguage).group.(@name==this.applicationName||@name=='common').lit.(@name==name);
			if (thisLiteral.length()==0) {
				// If you are not working in English, check that in case it has extra literals
				if (this.literalsLanguage!='EN') {
					thisLiteral = this.literalsXML.language.(@code=='EN').group.(@name==this.applicationName||@name=='common').lit.(@name==name);
					if (thisLiteral.length() == 0) {
						return false;
					}
				} else {
					return false;
				}
			}
			return true;			
		}
		
		public function getLiteral(name:String, replaceObj:Object=null):String {
			if (!this.literalsXML) return 'not loaded';
			//TraceUtils.myTrace('getting ' + name);
			//var thisLiteral = this.literalsXML.language.(@name==this.literalsLanguage).group.(@name=='BandScoreCalculator').lit.(@name==name);
			//var thisLiteral:XMLList = this.literalsXML.language.(@code==this.literalsLanguage).group.(@name==this.applicationName).lit.(@name==name);
			var thisLiteral:XMLList = this.literalsXML.language.(@code==this.literalsLanguage).group.(@name==this.applicationName||@name=='common').lit.(@name==name);
			//TraceUtils.myTrace("xmllist = " + thisLiteral.toString());
			
			if (thisLiteral.length()==0) {
				// If you are not working in English, check that in case it has extra literals
				if (this.literalsLanguage!='EN') {
					TraceUtils.myTrace("try English for " + name);
					thisLiteral = this.literalsXML.language.(@code=='EN').group.(@name==this.applicationName||@name=='common').lit.(@name==name);
					if (thisLiteral.length() == 0) {
						return name;
					}
				} else {
					return name;
				}
				
			} 
			var str:String = thisLiteral.toString();
			// Do the substitution if required
			if (replaceObj) {
				for (var searchString:String in replaceObj) {
					var regExp:RegExp = new RegExp("\{" + searchString + "\}", "g");
					str = str.replace(regExp, replaceObj[searchString]);
				}
			}	
			return str;
		}

	}
	
}