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
		public function Literals(defaultLanguage:String = 'EN', applicationName:String = 'BandScoreCalculator') {
			
			// Set the default langauge to use
			this.literalsLanguage = defaultLanguage;
			this.applicationName = applicationName;
			//TraceUtils.myTrace("in lits for " + applicationName + " in " + this.literalsLanguage);
			
		}
		public function loadXMLFile(folder:String=null) {
			//TraceUtils.myTrace("load XML");
			// Read the XML file - default is the same folder as the swf (not the same folder as the html that loads the swf)
			var literalsLoader:URLLoader = new URLLoader();
			if (folder) {
				if (folder.charAt(folder.length-1)!="/")
					folder+="/";
			}
			//TraceUtils.myTrace("path=" + folder);
			literalsLoader.load(new URLRequest(folder + "literals.xml"));
			literalsLoader.addEventListener(Event.COMPLETE, processXML);
		}
		
		private function processXML(e:Event):void {
			this.literalsXML = new XML(e.target.data);
			//TraceUtils.myTrace(this.literalsXML.language.(@code==this.literalsLanguage).group.(@name=='BandScoreCalculator').toXMLString());
			//TraceUtils.myTrace('got ' + this.literalsXML.toString());
			// Broadcast an event for the literals class
			dispatchEvent(new Event(Literals.LOADED));
		}
		
		public function literalExists(litName:String):Boolean {
			if (!this.literalsXML) return false;
			var thisLiteral:XMLList = this.literalsXML.language.(@code==this.literalsLanguage).group.(@name==this.applicationName||@name=='common').lit.(@name==litName);
			if (thisLiteral.length()==0) {
				// If you are not working in English, check that in case it has extra literals
				if (this.literalsLanguage!='EN') {
					thisLiteral = this.literalsXML.language.(@code=='EN').group.(@name==this.applicationName||@name=='common').lit.(@name==litName);
					if (thisLiteral.length() == 0) {
						return false;
					}
				} else {
					return false;
				}
			}
			return true;			
		}
		
		// Note that you can't use 'name' as the variable in (@name==name). So change to litName.
		public function getLiteral(litName:String, replaceObj:Object=null):String {
			if (!this.literalsXML) return 'not loaded';
			//TraceUtils.myTrace('getting ' + litName);
			var thisLiteral:XMLList = this.literalsXML.language.(@code==this.literalsLanguage).group.(@name==this.applicationName||@name=='common').lit.(@name==litName);
			//TraceUtils.myTrace("xmllist = " + this.literalsXML.language.(@code==this.literalsLanguage).group.(@name==this.applicationName||@name=='common').lit.(@name==litName));
			
			if (thisLiteral.length()==0) {
				// If you are not working in English, check that in case it has extra literals
				if (this.literalsLanguage!='EN') {
					TraceUtils.myTrace("try English for " + litName);
					thisLiteral = this.literalsXML.language.(@code=='EN').group.(@name==this.applicationName||@name=='common').lit.(@name==litName);
					if (thisLiteral.length() == 0) {
						return litName;
					}
				} else {
					return litName;
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