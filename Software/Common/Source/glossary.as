glossaryNS.glossaryStore = new Array();

// v6.3.6 Change scope
//this.loadGlossary = function (idx, xmlURL, callback) {
glossaryNS.loadGlossary = function (idx, xmlURL, callback) {
	myTrace("loadGlossary " + xmlURL); 
	var glossary = new XML();
	glossary.ignoreWhite = true;
	// v6.3.6 Change scope
	//this.glossaryNS.glossaryStore[idx] = glossary;
	_global.ORCHID.root.mainHolder.glossaryNS.glossaryStore[idx] = glossary;
	glossary.idx = idx;
	glossary.callback = callback;
	glossary.onLoad = function(success) {
		// once loaded the data successfully you can trigger the callback
		if (success) {
			//trace("data loaded into XML for " + this.idx);
			this.callback(this.idx);
		} else {
			this.callback(false);
			myTrace("sorry, cannot get the glossary for idx=" + this.idx);
		}
	}
	//trace("request to load idx=" + idx);
	glossary.load(xmlURL);
}

// function called to look up an entry in the glossary
// v6.3.6 Change scope
//function lookUp(searchWord, idx, statsObject) {
glossaryNS.lookup = function (searchWord, idx, statsObject) {
	//trace("I will look up " + searchWord);
	var searchWordNoCase = searchWord.toLowerCase();
	if (statsObject == undefined) statsObject = new Object();
	var counter=0;
	// v6.3.6 Change scope
	//var glossary = this.glossaryNS.glossaryStore[idx];
	var glossary = _global.ORCHID.root.mainHolder.glossaryNS.glossaryStore[idx];
	// v6.2 The glossary now has an additional <hw> tag round it
	// that groups together <entry> nodes
	//for (var entry in glossary.firstChild.childNodes) {
	// v6.3.5 If you are searching for "best" you will pick up "bestselling"
	// first using this reverse loop, so do it alphabetically (assuming that
   // the xml is alphabetic!)
	var loopLength = glossary.firstChild.childNodes.length;
	for (var hw=0; hw<loopLength; hw++) {
		var tH = glossary.firstChild.childNodes[hw];
		// is this a combining entry?
		if (tH.nodeName == "hw") {
			//build="";
			for (var entry in tH.childNodes) {
				//trace("entry=" + glossary.firstChild.childNodes[entry].nodeName);
				var tE = tH.childNodes[entry];
				// is this a glossary entry?
				if (tE.nodeName == "entry") {
					counter++;
					for (var node in tE.childNodes) {
						var tN = tE.childNodes[node];
						//trace("tN name=" + tN.nodeName + " value=" + tN.firstChild.nodeValue);
						// is this the word or one of its parts? (=w or =inf)
						if (tN.nodeName == "w" || tN.nodeName == "inf") {
							if (tN.firstChild.nodeValue.toLowerCase() == searchWordNoCase) {
								statsObject.entryIDX = hw;
								statsObject.searchCount += counter;
								statsObject.searches++;
								// as soon as you find a match, send the whole <hw> tag
								// v6.3.6 Change scope
								//return formatEntryAsHTML(tH);
								return glossaryNS.formatEntryAsHTML(tH);
							}
						}
					}
				}
			}
		}
	}
	// v6.3.4 Use proper literal
	var substList = [{tag:"[x]", text:"<b>" + searchWord + "</b>"}];
	//myTrace("can't find=" + _global.ORCHID.root.objectHolder.substTags(_global.ORCHID.literalModelObj.getLiteral("noGlossaryEntry", "messages"), substList));
	return _global.ORCHID.root.objectHolder.substTags(_global.ORCHID.literalModelObj.getLiteral("noGlossaryEntry", "messages"), substList)+"<br>";
}
// v6.3.6 Change scope
// function that formats a glossary entry into html
//formatEntryAsHTML = function(myHW) {
glossaryNS.formatEntryAsHTML = function(myHW) {
	//trace("myHW = " + myHW.toString());
	var htmlString = "";
	// v6.3.4 Use different colours
	if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EGU") >= 0) {
		var thisColour = "#00719C";
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("EssGU") >= 0) {
		var thisColour = "#BE4718";
	} else if (_global.ORCHID.root.licenceHolder.licenceNS.branding.indexOf("AGU") >= 0) {
		var thisColour = "#006633";
	} else {
		var thisColour = "#0000FF";
	}
	//for (var entry in myHW.childNodes) {
	for (var entry=0;entry<myHW.childNodes.length;entry++) {
		var myEntry = myHW.childNodes[entry];
		//trace("myEntry=" + myEntry.toString());
		if (myEntry.nodeName == "entry") {
			buildP = buildW = buildS = "";
			// v6.2 This needs to be done in increasing order
			//for (var i in myEntry.childNodes) {
			for (var i=0; i<myEntry.childNodes.length; i++) {
				var tag = myEntry.childNodes[i];
				// find the head word
				if (tag.nodeName == "w") {
					var buildW = tag.firstChild.nodeValue;
				// find the part of speech
				} else if (tag.nodeName == "pos") {
					var buildP = tag.firstChild.nodeValue;
				// look for all the senses for this word
				} else if (tag.nodeName == "sense") {
					//trace("sense=" + tag.toString());
					buildG = buildD = "";
					buildE = [];
					for (var j in tag.childNodes) {
						var sense = tag.childNodes[j];
						// look for the guide word
						if (sense.nodeName == "gwd") {
							buildG = sense.firstChild.nodeValue;
						// look for the definition
						} else if (sense.nodeName == "def") {
							buildD = sense.firstChild.nodeValue;
							//trace("buildD=" + buildD);
						// look for example sentences
						} else if (sense.nodeName == "eg") {
							buildE.push(sense.firstChild.nodeValue);
						}
					}
					if (buildG != "") buildS += "<b>" + buildG + "</b>&nbsp;";
					if (buildD != "") buildS += "<font color='" + thisColour + "'>" + buildD + "</font>";
					if (buildE.length > 0) {
						buildS += "<i><li>" + buildE.join("</li><li>") + "</li></i>";
					} else {
						buildS += "<br>";
					}
				}
			}
			htmlString += "<p><font color='" + thisColour + "'><b>" + buildW + "</b></font> ";
			if (buildP != "") htmlString +=	"(" + buildP + ")";
			htmlString += "</p>";
			if (buildS != "") htmlString +=	"<p>" + buildS + "</p>";
		}
	}
	return htmlString;
}
// to show that you are now loaded - used for stuff other than APO control
//trace("set movieloaded to true");
// v6.3.6 Change scope
//this.movieLoaded = true;
glossaryNS.movieLoaded = true;
