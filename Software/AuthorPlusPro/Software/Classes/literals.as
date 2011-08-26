/*
	an instance of this class would be controlling everything related to the literals
	this class should only communicate with:
		1. screens : namespace for functions that control/capture UI events
		
	a direct reference to _global.NNW.screens is used in the function onChangeLiterals()
	for changing all the literals after selection of a language
	this is not implemented w/ EventDispatcher
	'coz it'd be too costy to declare an instance merely for this purpose
*/

class Classes.literals extends XML {
	var Strings:Object;
	var DefaultLanguage:String;
	var SelectedLanguage:String;
	var LanguagesAvailable:Array;
	var XMLfile:String;

	var Fonts:Object;	// v0.16.1, DL: store fonts for particular language
	var DefaultFont:String;
	
	var PermittedLanguages:Array;	// v6.4.1.2, DL: permitted by passing variable language=EN,MS,ZHO
	var attemptedLoads:Number; // ugly way of only trying to reload a couple of times
	
	function literals() {
		Strings = new Object();
		DefaultLanguage = SelectedLanguage = "EN";
		LanguagesAvailable = new Array();
		//myTrace("server is " + NNW.__server);
		XMLfile = _global.addSlash(_global.NNW.paths.main)+"literals.xml";
		attemptedLoads = 0;
		
		Fonts = new Object();	// v0.16.1, DL: store fonts for particular language
		DefaultFont = "Verdana";
		
		var l = _global.NNW._defaultLanguage;
		if (l.indexOf(",")>-1) {
			PermittedLanguages = l.split(",");
		} else {
			PermittedLanguages = undefined;
		}
		
		// load literals when the literal instance is ready
		this.ignoreWhite = true;
		myTrace("loading literals from " + XMLfile);
		loadXMLfile();
	}
	
	function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	function loadXMLfile() : Void {
		attemptedLoads++;
		var cacheStr = (XMLfile.indexOf("http://")>-1) ? "?"+random(99999) : "";
		load(XMLfile+cacheStr);
	}
	
	function onLoad(success) : Void {
		if (success) {
			// v6.4.3 Don't inisist on APO name, just AP
			//if (this.firstChild.nodeName=="literals" && this.firstChild.attributes.program=="Author Plus") {
			if (this.firstChild.nodeName=="literals" && this.firstChild.attributes.program.indexOf("Author Plus")>=0) {
				// v0.16.1, DL: if version of literals is undefined or smaller than the program's one
				// reload the file
				if (this.firstChild.attributes.version==undefined || !_global.NNW.main.passVersionCheck(this.firstChild.attributes.version)) {
					if (_parent.attemptedloads > 2){
						myTrace("Literals cannot be loaded - give up.");
						loadLiterals();
					} else {
						myTrace("Literals not right version.");
						load(XMLfile+"?"+random(99999));
					}
				} else {
					myTrace("Literals loaded; version: "+this.firstChild.attributes.version);
					loadLiterals();
				}
			} else {
				if (_parent.attemptedloads > 2){
					myTrace("Literals cannot be loaded - give up.");
					loadLiterals();
				} else {
					myTrace("Literals too old - reload.");
					load(XMLfile+"?"+random(99999));
				}
			}
		} else {
			if (_parent.attemptedloads > 2){
				myTrace("Literals cannot be loaded - give up.");
				loadLiterals();
			} else {
				myTrace("Literals too old - reload.");
				load(XMLfile+"?"+random(99999));
			}
		}
		// v0.16.1, DL: move onModuleLoaded into loadLiterals
		// so that users have to reload in order to get through
		//_global.NNW.main.onModuleLoaded();
		//_global.NNW.main.pBar.setPercentage(15);
	}
	
	// English literals (defaults, should be loaded from literals.xml, just in case it's damaged or not found)
	function loadDefaults() : Void {
		var langCode = "EN";
		setNewLanguage(langCode, "English");
	}
	
	function setDefaultLiterals(langCode:String) : Void {
		// v0.16.1, DL: there are too many literals, better not set it in the program anymore
		/* buttons */
		//setLiteral(langCode, "btnOK", "OK");
		/* labels */
		//setLiteral(langCode, "lblExercise", "Exercise");
		/* messages */
		//setLiteral(langCode, "msgLoginFail", "Invalid username or password.");
	}
	
	function loadLiterals() : Void {
		myTrace("got first language " + this.firstChild.childNodes[0].attributes.code);
		for (var i=0; i<this.firstChild.childNodes.length; i++) {
			var langNode = this.firstChild.childNodes[i];
			var langCode = langNode.attributes.code;
			//myTrace("got language " + langCode);
			// v6.4.1.2, DL: implement skipping certain languages 
			var skipLanguage:Boolean = true;
			if (PermittedLanguages!=undefined) {
				for (var p in PermittedLanguages) {
					if (PermittedLanguages[p]==langCode) {
						skipLanguage = false;
					}
				}
			} else {
				skipLanguage = false;
			}
			if (!skipLanguage) {
				setNewLanguage(langCode, langNode.attributes.name, langNode.attributes.font);
				for (var j=0; j<langNode.childNodes.length; j++) {
					var groupNode = langNode.childNodes[j];
					for (var k=0; k<groupNode.childNodes.length; k++) {
						var litNode = groupNode.childNodes[k];
						var litName = litNode.attributes.name;
						var litValue = litNode.firstChild.nodeValue;
						switch (groupNode.attributes.name) {
						case "buttons":
							setLiteral(langCode, "btn"+litName, litValue);
							break;
						case "labels" :
							setLiteral(langCode, "lbl"+litName, litValue);
							break;
						case "messages" :
							setLiteral(langCode, "msg"+litName, litValue);
							break;
						case "instructions" :
							setLiteral(langCode, "ins"+litName, litValue);
							break;
						}
					}
				}
			}
		}
		_global.NNW.main.onModuleLoaded();
	}
	
	function setNewLanguage(langCode:String, languageName:String, langFont:String) : Void {
		Strings[langCode] = new Object();
		setLiteral(langCode, "languageName", languageName);
		setLanguageFont(langCode, langFont);
		setDefaultLiterals(langCode);
		LanguagesAvailable.push({code:langCode, name:languageName});
	}
	
	function setLiteral(langCode:String, idName:String, lit:String) : Void {
		Strings[langCode][idName] = lit;
	}
	
	function getLiteral(idName:String) : String {
		var lang = (SelectedLanguage.length>0 && SelectedLanguage!=undefined && SelectedLanguage!="undefined") ? SelectedLanguage : DefaultLanguage;
		var literal = Strings[lang][idName];
		// v0.9.0, DL: load the literal of the default language in case it isn't available in the selected language
		if ((literal==undefined||literal=="undefined") && lang!=DefaultLanguage) {
			literal = Strings[DefaultLanguage][idName];
		}
		literal = (literal!=undefined && literal!="undefined") ? literal : "";
		return literal;
	}
	
	function onChangeLiterals(newLang:String) : Void {
		SelectedLanguage = newLang;
		
		// v0.16.1, DL: set font on literals change
		var f = Fonts[newLang];
		_global.style.setStyle("fontFamily", f);
		_global.styles.Label.setStyle("fontFamily", f);
		_global.styles.TextInput.setStyle("fontFamily", f);
		_global.styles.TextArea.setStyle("fontFamily", f);
		_global.styles.ComboBox.setStyle("fontFamily", f);
		_global.styles.ScrollSelectList.setStyle("fontFamily", f);
		
		_global.NNW.screens.setLiteralsOnScreens();
	}
	
	// v0.16.1, DL: function to set font to a particular language
	function setLanguageFont(langCode:String, langFont:String) : Void {
		Fonts[langCode] = (langFont==undefined) ? DefaultFont : langFont;
	}
	
	// v0.16.1, DL: function to get font for a particular language
	function getLanguageFont(langCode:String) : String {
		return (Fonts[langCode]==undefined) ? DefaultFont : Fonts[langCode];
	}
	
	// v0.16.1, DL: function to return font for the selected language
	function getSelectedLanguageFont() : String {
		return getLanguageFont(SelectedLanguage);
	}
}
