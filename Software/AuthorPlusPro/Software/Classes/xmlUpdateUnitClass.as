import Classes.xmlFunc;

class Classes.xmlUpdateUnitClass extends Classes.xmlFunc {
	
	var master:Object;
	
	function xmlUpdateUnitClass(m:Object) {
		master = m;
	}
	
	function setXmlFile(s:String) : Void {
		if (_global.NNW.control.__server) {
			s = _global.replace(s, "\\", "/");
			s = _global.replace(s, "//", "/");
		}
		XMLfile = s;
	}
	
	function onLoadingSuccess() : Void {
		var u = this.firstChild.childNodes;
		var l = u.length;
		for (var i=0; i<l; i++) {
			_global.NNW.interfaces.setNodeAttr(u[i], i, l);
		}
		generateFile();
	}
	
	function onLoadingError() : Void {
		master.menuCnt++;
		master.updateMenuOneByOne();
	}
	
	function onSavingSuccess() : Void {
		master.menuCnt++;
		master.updateMenuOneByOne();
	}
	
	function onSavingError() : Void {
		master.menuCnt++;
		master.updateMenuOneByOne();
	}
}