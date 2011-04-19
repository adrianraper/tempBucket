
class Classes.interfaces extends XML {
	
	private var XMLfile:String;
	
	private var Programs:Object;
	private var code:String;
	
	function interfaces() {
		XMLfile = _global.NNW.paths.main+"/"+"interfaces.xml";
		Programs = new Object();
		
		// set default as Author Plus (student)
		loadDefaults();
		
		// load interfaces when the interface instance is ready
		_global.myTrace("interfaces from " + XMLfile);
		this.ignoreWhite = true;
		loadXMLfile();
	}
	
	private function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	
	private function loadXMLfile() : Void {
		var cacheStr = (XMLfile.indexOf("http://")>-1) ? "?"+random(99999) : "";
		load(XMLfile+cacheStr);
	}
	
	private function onLoad(success) : Void {
		if (success) {
			if (this.firstChild.nodeName=="interfaces") {
				// v0.16.1, DL: if version of interfaces is undefined or smaller than the program's one
				// reload the file
				if (this.firstChild.attributes.version==undefined || !_global.NNW.main.passVersionCheck(this.firstChild.attributes.version)) {
					myTrace("Interfaces version not okay - reload.");
					load(XMLfile+"?"+random(99999));
				} else {
					myTrace("Interfaces loaded; version: "+this.firstChild.attributes.version);
					loadInterfaces();
				}
			} else {
				myTrace("Interfaces cannot be loaded - reload.");
				load(XMLfile+"?"+random(99999));
			}
		} else {
			myTrace("Interfaces cannot be loaded - reload.");
			load(XMLfile+"?"+random(99999));
		}
	}
	
	private function loadDefaults() : Void {
		var s = "";
		
		code = "AuthorPlus";
		Programs[code] = new Object();
		var p = Programs[code];
		
		p.picPrefix = "Menu-APL-";
		p.picSuffix = "";
		p.captionPos = "bc";
		
		s = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22";
		p.pics = new Array();
		p.pics = s.split(",");
				
		// v6.4.2.5 Change the way x and y found
		/*p.miniMax = 6;
		
		s = "1,2,3,6,7,8";
		p.miniPos = new Array();
		p.miniPos = s.split(",");
		*/
		// Load the different menu position sets, longest first
		// these are the positions to use for a smaller menu set, based on the full menu set
		p.menuPos = new Array();
		s = "2,3,4,7,8,9";
		p.menuPos.push(s.split(","))
		s = "2,3,7,8";
		p.menuPos.push(s.split(","))
		
		s = "24,156,288,420,552,24,156,288,420,552";
		p.xPos = new Array();
		p.xPos = s.split(",");
		
		s = "70,70,70,70,70,230,230,230,230,230";
		p.yPos = new Array();
		p.yPos = s.split(",");

		p.xInc = 0;	
		p.yInc = 320;
	}
	
	private function loadInterfaces() : Void {
		var pList = this.firstChild.childNodes;
		for (var i=0; i<pList.length; i++) {
			if (pList[i].nodeName=="program") {
				Programs[pList[i].attributes.code] = new Object();
				var p = Programs[pList[i].attributes.code];
				p.picPrefix = "";
				p.picSuffix = "";
				p.pics = new Array();
				p.captionPos = "bc";
				// v6.4.2.5 Change the way x and y found
				//p.miniMax = 0;
				//p.miniPos = new Array();
				p.menuPos = new Array();
				p.xPos = new Array();
				p.yPos = new Array();
				p.xInc = 0;
				p.yInc = 0;
				for (var j=0; j<pList[i].childNodes.length; j++) {
					var node = pList[i].childNodes[j];
					switch (node.nodeName) {
					case "pic" :
						p.picPrefix = node.attributes.prefix;
						p.picSuffix = node.attributes.suffix;
						p.pics = node.attributes.names.split(",");
						_global.myTrace("interfaces." + pList[i].attributes.code + ".pics=" + p.pics.toString());
						p.captionPos = node.attributes.captionPos;
						break;
					case "mini" :
						// v6.4.2.5 Change the way x and y found
						//p.miniMax = Number(node.attributes.max);
						//p.miniPos = node.attributes.pos.split(",");
						p.menuPos.push(node.attributes.pos.split(","));
						break;
					case "coor" :
						p.xPos = node.attributes.x.split(",");
						p.yPos = node.attributes.y.split(",");
						p.xInc = Number(node.attributes.xInc);
						p.yInc = Number(node.attributes.yInc);
						break;
					}
				}
			}
		}
		_global.NNW.main.onModuleLoaded();
	}
	
	// v6.4.1.4, DL: get unit picture name (to put in unit node's "picture" attribute)
	// pos range: [0, nodes.length-1]
	private function getUnitPicture(pos:Number) : String {
		var p:Object = Programs[code];
		var pic:String = "";
		pos = pos % p.pics.length;
		pic = p.picPrefix + p.pics[pos] + p.picSuffix;
		return pic;
	}
	
	// get caption position
	private function getCaptionPosition() : String {
		var p:Object = Programs[code];
		return p.captionPos;
	}
	
	// pos range: [0, nodes.length-1]
	// total: nodes.length
	private function getUnitXPos(pos:Number, total:Number) : Number {
		var p:Object = Programs[code];
		var n:Number = 0;
		
		// v6.4.2.5 Change the way the menu positions are calculated
		/*
		// normal menu
		if (total>p.miniMax) {
			var l = p.xPos.length;
			if (pos+1 > l) {
				var inc = Math.floor(pos/l);
				pos = pos % l;				
				n = Number(p.xPos[pos]) + p.xInc * inc;
			} else {
				n = Number(p.xPos[pos]);
			}
			
		// mini menu
		} else {
			n = Number(p.xPos[p.miniPos[pos]]);
		}
		*/
		// which menu set should we deal with?
		for (var i in p.menuPos) {
			if (total<= p.menuPos[i].length) {
				//_global.myTrace("menuPos[" + i + "]=" + p.menuPos[i].toString() + " so " + pos + "=" + p.menuPos[i][pos]);
				n = Number(p.xPos[p.menuPos[i][pos]-1]);
				//_global.myTrace("for " + pos + " of " + total + " x=" + n);
				return n;
			}
		}
		// If no small menu, then full menu, with increments
		var l = p.xPos.length;
		if (pos+1 > l) {
			var inc = Math.floor(pos/l);
			pos = pos % l;				
			n = Number(p.xPos[pos]) + p.xInc * inc;
		} else {
			n = Number(p.xPos[pos]);
		}
		return n;
	}
	// pos range: [0, nodes.length-1]
	// total: nodes.length
	private function getUnitYPos(pos:Number, total:Number) : Number {
		var p:Object = Programs[code];
		var n:Number = 0;
		
		// v6.4.2.5 Change the way the menu positions are calculated
		/*
		// normal menu
		if (total>p.miniMax) {
			var l = p.yPos.length;
			if (pos+1 > l) {
				var inc = Math.floor(pos/l);
				pos = pos % l;
				n = Number(p.yPos[pos]) + p.yInc * inc;
			} else {
				n = Number(p.yPos[pos]);
			}
			
		// mini menu
		} else {
			n = Number(p.yPos[p.miniPos[pos]]);
		}
		*/
		// which menu set should we deal with?
		for (var i in p.menuPos) {
			if (total<= p.menuPos[i].length) {
				n = Number(p.yPos[p.menuPos[i][pos]-1]);
				return n;
			}
		}
		// If no small menu, then full menu, with increments
		var l = p.yPos.length;
		if (pos+1 > l) {
			var inc = Math.floor(pos/l);
			pos = pos % l;				
			n = Number(p.yPos[pos]) + p.yInc * inc;
		} else {
			n = Number(p.yPos[pos]);
		}
		return n;
	}
	
	/*
		setter function for setting the interface to be used
	*/
	public function setInterface(s:String) : Void {
		code = s;
	}
	
	/*
		getter functions for xml writing classes to use
	*/
	public function getInterface() : String {
		return code;
	}
	
	/*
		set node attribute with parameters (node, position, total no. of nodes)
	*/
	// AR v6.4.2.5 This should not be called if the menu you are working on has been customised with different pictures and x, y
	// maybe there should be a customised="true" attribute that you check
	public function setNodeAttr(node:Object, pos:Number, total:Number) : Void {
		var attr = node.attributes;
		if (attr.customised == "true" || attr.customised == true) {
			_global.myTrace(attr.caption + " has customised menu graphic");
		} else {
			//_global.myTrace("interfaces.setNode " + pos + " of " + total);
			attr["x"] = getUnitXPos(pos, total);	// v0.13.0, DL: pass total no. of units for different arrangements
			attr["y"] = getUnitYPos(pos, total);	// v0.13.0, DL: pass total no. of units for different arrangements
			attr["caption-position"] = getCaptionPosition();
			attr["picture"] = getUnitPicture(pos);
		}
	}
}
