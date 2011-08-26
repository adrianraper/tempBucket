// ActionScript Document
_global.ORCHID.uiMessages = new Array();
Messages = new Object();
Messages.language = "British English";
Messages.marking = new Object();
Messages.marking.WellDone = "Well done!";
Messages.marking.Sorry = "Sorry";
uiMessages.push(Messages);
Messages = new Object();
Messages.language = "French";
Messages.marking = new Object();
Messages.marking.WellDone = "Bravo";
Messages.marking.Sorry = "Desole";
uiMessages.push(Messages);
Messages = new Object();
Messages.language = "Chinese";
Messages.marking = new Object();
Messages.marking.WellDone = "ê4";
Messages.marking.Sorry = "u~";
uiMessages.push(Messages);
getLanguageIdx = function(language) {
	for (var i=0;i<_global.ORCHID.uiMessages.length;i++) {
		if (_global.ORCHID.uiMessages[i].language == language) {
			return i;
		}
	}
	i = -1;
};
_global.ORCHID.languageIdx = getLanguageIdx("French");
trace("language["+_global.ORCHID.languageIdx+"]="+_global.ORCHID.uiMessages[_global.ORCHID.languageIdx].language);
