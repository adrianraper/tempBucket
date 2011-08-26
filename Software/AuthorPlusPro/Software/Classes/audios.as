class Classes.audios extends XML {
	var files:Object;
	var XMLfile:String;
	
	function audios() {
		files = new Object();
		XMLfile = _global.NNW.paths.main+"/"+"audios.xml";
		
		// load literals when the literal instance is ready
		this.ignoreWhite = true;
		loadXMLfile();
	}
	
	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	function loadXMLfile() : Void {
		var cacheStr = (XMLfile.indexOf("http://")>-1) ? "?"+random(99999) : "";
		load(XMLfile+cacheStr);
	}
	
	function onLoad(success) : Void {
		if (success) {
			if (this.firstChild.nodeName=="audios" && this.firstChild.attributes.program=="Author Plus Online") {
				// v0.16.1, DL: if version of photos is undefined or smaller than the program's one
				// reload the file
				if (this.firstChild.attributes.version==undefined || !_global.NNW.main.passVersionCheck(this.firstChild.attributes.version)) {
					myTrace("Audios list version not okay - reload.");
					load(XMLfile+"?"+random(99999));
				} else {
					myTrace("Audios list loaded; version: "+this.firstChild.attributes.version);
					loadAudios();
				}
			} else {
				myTrace("Audios list cannot be loaded - reload.");
				load(XMLfile+"?"+random(99999));
			}
		} else {
			myTrace("Audios list cannot be loaded - reload.");
			load(XMLfile+"?"+random(99999));
		}
		// v0.16.1, DL: move onModuleLoaded into loadAudios
		// so that users have to reload in order to get through
		//_global.NNW.main.onModuleLoaded();
		//_global.NNW.main.pBar.setPercentage(25);
	}
	
	function loadAudios() : Void {
		for (var i=0; i<this.firstChild.childNodes.length; i++) {
			var exNode = this.firstChild.childNodes[i];
			var exType = exNode.attributes.name;
			var file = exNode.firstChild.nodeValue;
			addFileName(exType, file);
		}
		_global.NNW.main.onModuleLoaded();
	}
	
	function addFileName(exType:String, file:String) : Void {
		files[exType] = file;
	}
	
	function getFilename(exType:String) : String {
		if (files[exType] != undefined) {
			return files[exType];
		} else {
			return "";
		}
	}
}
