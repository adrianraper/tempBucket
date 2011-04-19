//Model for different interface languages
// v6.4.3 This causes a problem - since you should either be using _global.ORCHID or just this.
//_global.LiteralModel = function(dataSource, language) {
LiteralModel = function(dataSource, language) {
	//myTrace("create new LiteralModel object in " + language);
	//myTrace("new Literal Model for " + language);
	EventBroadcaster.initialize(this);
	this.dataSource = dataSource;
	this.currentLanguage = language;
	this.loaded = false;
}

LiteralModel.prototype.loadData = function() {
	this.xmlObj = new XML();
	this.xmlObj.ignoreWhite = true;
	this.xmlObj.master = this;
	
	this.xmlObj.onLoad = function(success) {
		if(success) {
			// To try and test what happens if literals loads slowly, add a delay here.
			// This does work as a brake, but since the data is actually loaded it isn't much of a test!
			// how about delaying the load call? Yes, that tests it nicely. See below.
			/*
			this.literalSlowCheck = function( ) {
				myTrace("after slow literal check");
				clearInterval(this.literalSlowCheckIntID);
				_global.ORCHID.literalModelObj.loaded = true;
				//this.master.broadcastMessage("onLiteralData", success);
				_global.ORCHID.literalModelObj.broadcastMessage("literalEvent", "onLiteralLoad", success);
			}
			this.literalSlowCheckIntID = setInterval(this.literalSlowCheck, 5000);
			*/
			// v6.5.4.6 I think you mean the parent.
			this.loaded = true;
			this.master.loaded = true;
			//this.master.broadcastMessage("onLiteralData", success);
			this.master.broadcastMessage("literalEvent", "onLiteralLoad", success);
		} else {
			//this.master.broadcastMessage("onLiteralData", success);
			this.master.broadcastMessage("literalEvent", "onLiteralLoad", success);
		}
	}
	// v6.5.6.4 To test that slow loading literals will be waited for:
	/*
	var literalSlowCheck = function( ) {
		clearInterval(literalSlowCheckIntID);
		myTrace("after slow literal check for " + _global.ORCHID.literalModelObj.dataSource);
		_global.ORCHID.literalModelObj.xmlObj.load(_global.ORCHID.literalModelObj.dataSource);
	}
	this.literalSlowCheckIntID = setInterval(literalSlowCheck, 5000);
	*/
	this.xmlObj.load(this.dataSource);
}

//v6.4.1 Allow you to find the mediaFolder (and nice name) of any language code
LiteralModel.prototype.getLanguageDetails = function(language) {
	if (language == undefined) {
		//trace("undefined lang");
		language = this.currentLanguage;
	}
	var lits = this.xmlObj;
	var numLangs = lits.firstChild.childNodes.length;
	while (numLangs--) {
		if (lits.firstChild.childNodes[numLangs].attributes.code == language) {
			return {code:lits.firstChild.childNodes[numLangs].attributes.code, 
				name:lits.firstChild.childNodes[numLangs].attributes.name,
				mediaFolder:lits.firstChild.childNodes[numLangs].attributes.mediaFolder};
		}
	}
}

LiteralModel.prototype.getLiteral = function(name, group, language) {
	if (language == undefined) {
		//trace("undefined lang");
		language = this.currentLanguage;
	}
	var lits = this.xmlObj;
	var numLangs = lits.firstChild.childNodes.length;
	while (numLangs--) {
		//myTrace("checking lang=" + lits.firstChild.childNodes[numLangs].attributes.name);
		// v6.4.1 switch code and name, and return an object (code + name)
		//if (lits.firstChild.childNodes[numLangs].attributes.name == language) {
		if (lits.firstChild.childNodes[numLangs].attributes.code == language) {
			var thisLangNode = lits.firstChild.childNodes[numLangs];
			var numGroups = thisLangNode.childNodes.length;
			while (numGroups--) {
				//myTrace("checking group=" + thisLangNode.childNodes[numGroups].attributes.name);
				if (thisLangNode.childNodes[numGroups].attributes.name == group) {
					var thisGroupNode = thisLangNode.childNodes[numGroups];
					var numLits = thisGroupNode.childNodes.length;
					while (numLits--) {
						//myTrace("checking name=" + thisGroupNode.childNodes[numLits].attributes.name + "with " + name);
						if (thisGroupNode.childNodes[numLits].attributes.name == name) {
							//myTrace("getLiteral - name: " + name + " group: " + group + " language: " + language + " value: " + thisGroupNode.childNodes[numLits].attributes.value);
							//return thisGroupNode.childNodes[numLits].attributes.value;
							return thisGroupNode.childNodes[numLits].firstChild.nodeValue;
						}
					}
				}
			}
		}
	}
	//v6.3.6 If another language fails, try EN in case it is a new literal, not yet added
	if (language != "EN") {
		myTrace("getLiteral fail - name: " + name + " group: " + group + " language: " + language);
		return this.getLiteral(name, group, "EN");
	} else {
		myTrace("getLiteral fail - name: " + name + " group: " + group + " language: " + language);
		// v6.5.4.7 Change this to at least return the code - it will make it easier to spot missing literals
		//return undefined;
		return group+":"+name;
	}
}

LiteralModel.prototype.setLiteralLanguage = function(language) {
	this.currentLanguage = language;
	this.broadcastMessage("literalEvent", "onLanguageChanged");
}

LiteralModel.prototype.getLiteralLanguage = function() {
	return this.currentLanguage;
}

LiteralModel.prototype.getLiteralLanguageList = function() {
	
	// v6.3.5 If the command line had a required language, the lang list is considered to only contain 1 item
	myTrace("commandLine.language=" + _global.ORCHID.commandLine.language);
	//myTrace("getLitLangList, idx=" + _global.ORCHID.literalModelObj.currentLiteralIdx);
	if (_global.ORCHID.commandLine.language.indexOf("*") > 0) {
		myTrace("forced, so no list");
		return undefined;
	}
	// does the command line say we have a suggested lang, or a list of filtered ones?
	if (_global.ORCHID.commandLine.language.indexOf(",") >0) {
		// it is a list
		var filteredLangs = _global.ORCHID.commandLine.language;
		var suggestedLang = filteredLangs.split(",")[0];
		myTrace("filtered, so small list");
	// v6.4.2.6 Allow it to be completely empty and do nothing
	//} else {
	} else if (_global.ORCHID.commandLine.language <> "" && _global.ORCHID.commandLine.language <> undefined) {
		// it is just one
		var filteredLangs = undefined;
		var suggestedLang = _global.ORCHID.commandLine.language;
		myTrace("suggested, so pre-set list");
	}

	var rtnArray = new Array();
	var lits = this.xmlObj;
	var numLangs = lits.firstChild.childNodes.length;
	for(var i = 0; i < numLangs; i++) {
		if (lits.firstChild.childNodes[i].nodeName == "language") {
			// v6.4.1 switch code and name, and return an object (code + name)
			// v6.4.1 And add media folder
			// v6.4.2 You might only allow languages from a list
			if (filteredLangs != undefined) {
				// if not in the list, skip
				if (filteredLangs.indexOf(lits.firstChild.childNodes[i].attributes.code) <0) {
					//myTrace("ignore " + lits.firstChild.childNodes[i].attributes.code);
					continue;
				}
			}
			//rtnArray.push(lits.firstChild.childNodes[i].attributes.name);
			//myTrace("lang name=" + lits.firstChild.childNodes[i].attributes.name + " code=" + lits.firstChild.childNodes[i].attributes.code,0);
			rtnArray.push({code:lits.firstChild.childNodes[i].attributes.code, name:lits.firstChild.childNodes[i].attributes.name,
						mediaFolder:lits.firstChild.childNodes[i].attributes.mediaFolder});
			// v6.3.5 If this matched the suggested language, save the index
			// Or you could push the matching language to the first item in the list.
			//myTrace("this item name=" + lits.firstChild.childNodes[i].attributes.name);
			// v6.3.6 BUT, I only want to do this check against the command line once.
			if (_global.ORCHID.literalModelObj.currentLiteralIdx == undefined) {
				// v6.4.1 switch code and name
				//if (_global.ORCHID.commandLine.language == lits.firstChild.childNodes[i].attributes.name) {
				if (suggestedLang == lits.firstChild.childNodes[i].attributes.code) {
					//myTrace("so save idx as " + rtnArray.length -1);
					this.currentLiteralIdx = rtnArray.length -1;
				}
			}
		}
	}
	return rtnArray;
}
