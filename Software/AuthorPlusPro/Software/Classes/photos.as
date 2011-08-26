class Classes.photos extends XML {
	var Sizes:Object;
	var XMLfile:String;
	
	function photos() {
		Sizes = new Object();
		XMLfile = _global.NNW.paths.main+"/"+"photos.xml";
		
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
			if (this.firstChild.nodeName=="photos" && this.firstChild.attributes.program=="Author Plus Online") {
				// v0.16.1, DL: if version of photos is undefined or smaller than the program's one
				// reload the file
				if (this.firstChild.attributes.version==undefined || !_global.NNW.main.passVersionCheck(this.firstChild.attributes.version)) {
					myTrace("Photos list version not okay - reload.");
					load(XMLfile+"?"+random(99999));
				} else {
					myTrace("Photos list loaded; version: "+this.firstChild.attributes.version);
					loadPhotos();
				}
			} else {
				myTrace("Photos list cannot be loaded - reload.");
				load(XMLfile+"?"+random(99999));
			}
		} else {
			myTrace("Photos list cannot be loaded - reload.");
			load(XMLfile+"?"+random(99999));
		}
		// v0.16.1, DL: move onModuleLoaded into loadPhotos
		// so that users have to reload in order to get through
		//_global.NNW.main.onModuleLoaded();
		//_global.NNW.main.pBar.setPercentage(20);
	}
	
	function loadPhotos() : Void {
		/* v0.13.0, DL: add dimension to photos */
		for (var s=0; s<this.firstChild.childNodes.length; s++) {
			var sizeNode = this.firstChild.childNodes[s];
			var dimension = sizeNode.attributes.value;
			addNewSize(dimension);
			for (var c=0; c<sizeNode.childNodes.length; c++) {
				var categoryNode = sizeNode.childNodes[c];
				var categoryName = categoryNode.attributes.name;
				addNewCategory(dimension, categoryName);
				for (var f=0; f<categoryNode.childNodes.length; f++) {
					var fileNode = categoryNode.childNodes[f];
					var filePath = "";
					var fileName = "";
					for (var k=0; k<fileNode.childNodes.length; k++) {
						switch (fileNode.childNodes[k].nodeName) {
						case "path" :
							var fileNodeValue = fileNode.childNodes[k].firstChild.nodeValue;
							filePath = (fileNodeValue!=undefined) ? fileNodeValue : "";
							break;
						case "name" :
							var fileNodeValue = fileNode.childNodes[k].firstChild.nodeValue;
							fileName = (fileNodeValue!=undefined) ? fileNodeValue : "";
							break;
						}
					}
					addFileName(dimension, categoryName, filePath, fileName);
				}
			}
		}
		// v0.10.0, DL: add own graphic
		for (var i in Sizes) {
			addNewCategory(i, "YourGraphic");
			// v0.10.0, DL: no graphic
			addNewCategory(i, "NoGraphic");
		}
		_global.NNW.main.onModuleLoaded();
	}
	
	function addNewSize(dimension:String) : Void {
		Sizes[dimension] = new Object();
		Sizes[dimension].Categories = new Object();
	}
	
	function addNewCategory(dimension:String, categoryName:String) : Void {
		Sizes[dimension].Categories[categoryName] = new Array();
	}
	
	function addFileName(dimension:String, categoryName:String, filePath:String, fileName:String) : Void {
		Sizes[dimension].Categories[categoryName].push({path:filePath, name: fileName});
	}
	
	function randFileFromCategory(dimension:String, categoryName:String) : Object {
		var max = Sizes[dimension].Categories[categoryName].length - 1;
		var i = randRange(0, max);
		//myTrace(i+" : "+Categories[categoryName][i]);
		return Sizes[dimension].Categories[categoryName][i];
	}
	
	function randRange(min:Number, max:Number) : Number {
	   var randomNum:Number = Math.floor(Math.random()*(max-min+1))+min;
	   return randomNum;
	}
}
