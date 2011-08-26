import mx.events.EventDispatcher;
class Classes.xmlFunc extends XML {
	
	var control:Object;
	var XMLfile:String;
	var initSave:Boolean;
	
	var _serverPath:String;
	var _serverWriteFilePath:String;
	
	var targetNode:XMLNode;
	
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	
 	function dispatchEvent() {};
 	function addEventListener() {};
 	function removeEventListener() {};
	
	function xmlFunc() {
		
		mdm = _global.mdm; // v6.4.3 mdm Script 2.0
		
		this.ignoreWhite = true;
		targetNode = new XMLNode();
		mx.events.EventDispatcher.initialize(this);
		
		addListener(this);
		initSave = false;
		
		_serverPath = _global.NNW.paths.serverPath;
		formWritePath();
	}
	
	// v6.4.1.2, DL: form write path
	function formWritePath() : Void {
		// v6.4.1.2, DL: handle both scripting language (ASP/PHP)
		// refresh the _serverPath to ensure it has been updated after reading the licence
		_serverPath = _global.NNW.paths.serverPath;
		// default as ASP as the moment
		if (_serverPath.substr(-3, 3).toLowerCase()=="php") {
			_serverWriteFilePath = _serverPath+"/XMLWrite.php";
		} else {
			_serverWriteFilePath = _serverPath+"/XMLWrite.asp";
		}
	}
	
	function myTrace(s:String) {
		_global.myTrace(s);
	}
	
	function addListener(o:Object) : Void {
		this.addEventListener("onLoadingSuccess", o);
		this.addEventListener("onLoadingError", o);
		this.addEventListener("onFinishAction", o);
		this.addEventListener("onSavingSuccess", o);
		this.addEventListener("onSavingError", o);
	}
	
	function loadXML(t:String) : Void {
		// v6.4.1.2, DL: debug - for network version, no need to fix path
		if (control.__server) {
			XMLfile = _global.replace(XMLfile, "\\", "/");
			XMLfile = _global.replace(XMLfile, "//", "/");
		}
		if (XMLfile!=undefined && XMLfile.length>0) {
			// v0.16.1, DL: lock file before loading
			myTrace("call control.lockFile from xmlFunc");
			control.lockFile(t);
		}
		myTrace("end of xmlFunc.loadXML");
	}
	
	function loadXMLAfterLocking() : Void {
		//myTrace("xmlFunc.loadXMLAfterLocking");
		// v0.4.3, DL: passing a random thing as request gets rid of the caching problem
		removeAllNodes();
		load(XMLfile+"?nocache="+random(999999));
	}
	
	function onLoad(success:Boolean) : Void {
		// an instance of this will reload the xml file when necessary
		// but the declaration will be accumulated each time (bug?) so we've to rewrite it
		myTrace("xmlFunc.onLoad - got " + XMLfile);
		this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
		if (success) {
			// v0.4.3, DL: no more error nodes coming back
			/* sR node returned => error */
			if (this.firstChild.nodeName=="sR") {
				if (this.firstChild.firstChild.attributes.fileExists=="false") {
					myTrace("The file doesn't exists.");
					/* file doesn't exist */
					dispatchEvent({type:"onLoadingError"});
				} else {
					/* unknown error occurred */
					control.onConnFail();
				}
				
			/* content returned => loading success */
			} else {
				dispatchEvent({type:"onLoadingSuccess"});
			}
		} else {
			// v0.4.3, DL: now no response means no file
			// => do not generate error message but create new file
			/* no response */
			//control.onConnFail();
			dispatchEvent({type:"onLoadingError"});
		}
	}
	
	function onSavingError() : Void {
		myTrace("Saving error occured.");
		control.onSavingError();
	}
	
	function toString() : String {
		var xStr = "";
		xStr += (this.xmlDecl!=null) ? this.xmlDecl : "";
		xStr += (this.docTypeDecl!=null) ? this.docTypeDecl : "";
		xStr += this.firstChild.toString();
		return xStr;
	}
	
	function generateFile() : Void {
		if (this.xmlDecl!='<?xml version="1.0" encoding="UTF-8"?>') {
			this.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
		}
		
		var xmlFuncObj = this;
		if (XMLfile!=undefined && XMLfile.length>0) {
			
			// response from saving xml (ASP/PHP)
			var xmlResponse:XML = new XML();
			xmlResponse.onLoad = function(success) {
				if (success) {
					if (this.firstChild.nodeName=="sR" && this.firstChild.firstChild.attributes.save!="error") {
						xmlFuncObj.myTrace("xmlFunc.generateFile.onLoad.success");
						xmlFuncObj.dispatchEvent({type:"onSavingSuccess"});
					} else {
						xmlFuncObj.myTrace(this.toString());
						xmlFuncObj.dispatchEvent({type:"onSavingError"});
					}
				} else {
					xmlFuncObj.dispatchEvent({type:"onSavingError"});
				}
			}
			
			// get file path & name
			// v6.4.1.2, DL: debug - for local files don't change the string (handled seperately below)
			var f = XMLfile;
			if (control.__server) {
				f = _global.replace(f, "\\", "/");
				f = _global.replace(f, "//", "/");
			}
			
			// get path for creating course.xml
			// AR v6.4.2.5 Build a path from the course.xml folder to the media and exercise folders. But this shouldn't be hardcoded to Courses
			// It is held in the course object for each course and is supposed to be able to be different. I also don't see what you are doing here
			// with this path - using it to create a /Courses/Media folder. Check on code in xmlExerciseClass.
			var p = _global.getPath(f);
			_global.myTrace("file path = "+p);
			// for course.xml, create the courses directory
			// v6.4.3 Change name from paths.userPath to paths.content
			//if (XMLfile == _global.NNW.paths.userPath+"/course.xml") {
			// AR v6.4.2.5 Shouldn't I be using paths.MGS??
			//if (XMLfile == _global.addSlash(_global.NNW.paths.content)+"course.xml") {
			if (XMLfile == _global.addSlash(_global.NNW.paths.MGSPath)+"course.xml") {
				p += _global.addSlash("") + "Courses";
			}
			
			// if path is not complete, we can't do saving
			if (p.length>0) {
				
				// v6.4.1.2, DL: for network version, use FSP to write files
				if (control.__local) {
					// create folder by FSP
					// v6.4.3 mdm.script.2
					//_root.mdm.makefolder(p);
					if (mdm.System.winVerString.indexOf("98")>0) {
						mdm.FileSystem.makeFolder(p);
					} else {
						mdm.FileSystem.makeFolderUnicode(p);
					}
					// AR v6.4.2.5 I don't understand this - why would the filename be exercises??
					// Or am I using getFilename to actually get the last folder name? Yes, probably that is it. So if I am saving
					// a file into the /Exercises folder, I will automatically make sure that a /Media folder exists.
					if (_global.getFilename(p).toLowerCase()=="exercises") {
						//_root.mdm.makefolder(_global.addSlash(_global.getPath(p))+"Media");
						if (mdm.System.winVerString.indexOf("98")>0) {
							mdm.FileSystem.makeFolder(_global.addSlash(_global.getPath(p))+"Media");
						} else {
							mdm.FileSystem.makeFolderUnicode(_global.addSlash(_global.getPath(p))+"Media");
						}
					}
					// write file by FSP
					//_root.mdm.saveutf8_filename(f);
					var thisFilename = f;
					
					// set attributes of file to be writable
					var attrib = "-R";
					//_root.mdm.setfileattribs(f, attrib);
					
					var xs = this.toString();
					xs = _global.fixTags(xs);
					xs = _global.replace(xs, "&nbsp;", " ");
					xs = _global.replace(xs, "<CDATA>", "<![CDATA[");
					xs = _global.replace(xs, "</CDATA>", "]]>");
					// v6.4.3 mdm.script.2
					//fscommand("mdm.saveutf8", xs);
					// This does not save - gives an exception so I guess that the XML is open. Try delayed save.
					//myTrace("direct save of " + thisFilename);
					//mdm.FileSystem.saveFileUnicode(thisFilename, xs);
					//mdm.FileSystem.setFileAttribs(thisFilename, attrib);
					// v6.4.2.7 Pass the object that will broadcast the end event to this function as you simply cannot do it from here!
					//var intID:Number = _global['setTimeout'](xmlFuncObj.control, "onSaveFile", 100, thisFilename, xs);
					var intID:Number = _global['setTimeout'](xmlFuncObj.control, "onSaveFile", 100, thisFilename, xs, xmlFuncObj);
				
					// return success (let's deal with failure later)
					// xmlFuncObj.myTrace("--- File saved.");
					// AR v6.4.2.5 It should be the onSaveFile that triggers the event, success or failure. I should be passing
					// this object to it so it can call back.
					// v6.4.2.7 Pass the object that will broadcast the end event to this function as you simply cannot do it from here!
					//_global.myTrace("xmlFunc.generateFile.broadcast.onSavingSuccess");
					//xmlFuncObj.dispatchEvent({type:"onSavingSuccess"});
					
				} else {
					// v6.4.1.2, DL: form the write path again to ensure it is updated after reading the licence
					formWritePath();
					// v6.4.2.6 Also pass the userDataPath to the scripting files
					//this.sendAndLoad(_serverWriteFilePath+"?prog=NNW&path="+p+"&file="+f, xmlResponse);
					_global.myTrace("xmlFunc.sendAndLoad=" + _serverWriteFilePath+"?prog=NNW&path="+p+"&file="+f+"&udp="+_global.NNW.paths.userDataPath);
					this.sendAndLoad(_serverWriteFilePath+"?prog=NNW&path="+p+"&file="+f+"&udp="+_global.NNW.paths.userDataPath, xmlResponse);
					
					
					/*if (control._editClarity && _global.getFilename(f)=="course.xml") {
						var n = _global.NNW.interfaces.getInterface();
						if (n!="AuthorPlus") {
							var x:XML = new XML(this.toString());
							x.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
							for (var i in x.firstChild.childNodes) {
								if (x.firstChild.childNodes[i].attributes.program!=n) {
									x.firstChild.childNodes[i].removeNode();
								}
							}
							var dummyResponse:XML = new XML();
							dummyResponse.onLoad = function(success) {
								_global.myTrace("writing to original's course.xml:");
								if (success) {
									_global.myTrace("success");
								} else {
									_global.myTrace("fail");
								}
							}
							//_global.myTrace("xml to write in program's course.xml");
							//_global.myTrace(x.toString());
							x.sendAndLoad(_serverWriteFilePath+"?prog=NNW&file="+_global.NNW.paths[n+"Content"]+"/course.xml", dummyResponse);
							//_global.myTrace("run : "+_serverWriteFilePath+"?prog=NNW&file="+_global.NNW.paths[n+"Content"]+"/course.xml");
						}
					}*/
				}
				//myTrace("--- Saving file at: "+f);
			} else {
				myTrace("--- File path: "+XMLfile+" not complete, saving skipped.");
				dispatchEvent({type:"onSavingSuccess"});
			}
		} else {
			myTrace("--- File path not complete, saving skipped.");
			dispatchEvent({type:"onSavingSuccess"});
		}
		/*
		if (XMLfile!=undefined && XMLfile.length>0) {
			// form full path for the xml file
			var f = _global.replace(_global.NNW.path + XMLfile, "\\", "/");
			myTrace("Saving file at: "+f);
			// create directory if provided in path
			_root.xmlFolder = _global.getPath(f);
			if (_root.xmlFolder.length>0) {
				fscommand("mdm.makefolder", "xmlFolder");
			}
			// write file
			_root.xmlFilename = f;
			fscommand("mdm.saveutf8_filename", "xmlFilename");
			fscommand("mdm.saveutf8", toString());
		}
		*/
	}
	
	function findPath(xpath:String) : Boolean {
		var nodeFound:Boolean = false;
		targetNode = this.firstChild;
		
		var a:Array = xpath.split("/");
		for (var i=0; i<a.length; i++) {
			
			// get predicate first
			var pred:String = ""; 				// string to hold predicate
			var iop:Number = a[i].indexOf("[");	// number to hold index of predicate
			if (iop > -1) {
				pred = a[i].substring(iop+1, a[i].length-1);
				a[i] = a[i].substring(0, iop);
			}
			//trace("node to find = "+a[i]);
			
			// if have predicate, we've to get the attribute name & value
			if (pred.length>0) {
				var p:Array = pred.split("="); // attr = p[0], value = p[1]
				if (p[1].substr(0, 1)=="'" || p[1].substr(0, 1)=='"') {
					if (p[1].substr(0, 1) == p[1].substr(-1, 1)) {
						p[1] = p[1].substr(1, p[1].length-2);
					}
				}
				//trace("predicate = "+p[0]+" ; value = "+p[1]);
			}
			
			// start to find node
			var c = 0;
			var notFound = true;
			do {
				var nodeToExamine = targetNode.childNodes[c];
				if (nodeToExamine.nodeName == a[i]) {
					if (pred.length>0) {
							var attr = nodeToExamine.attributes;
							if (attr[p[0]] == p[1]) {
								targetNode = nodeToExamine;
								notFound = false;
							}
					} else {
						targetNode = nodeToExamine;
						notFound = false;
					}
				}
				c++;
			} while(notFound && targetNode.childNodes.length >= c);
		}
		nodeFound = !notFound;
		return nodeFound;
	}
	
	function addNodesToPath(xpath:String, nodes:Array) : Void {
		if (findPath(xpath)) {
			for (var i=0; i<nodes.length; i++) {
				targetNode.appendChild(nodes[i].cloneNode(true));
			}
		}
		dispatchEvent({type:"onFinishAction"});
	}
	
	function delNodeFromPath(xpath:String) : Void {
		if (findPath(xpath)) {
			targetNode.removeNode();
		}
		dispatchEvent({type:"onFinishAction"});
	}
	
	function addAttrToPath(xpath:String, attr:Array) : Void {
		if (findPath(xpath)) {
			for (var i in attr) {
				if (i!="xpath") {
					targetNode.attributes[i] = attr[i];
				}
			}
		}
		dispatchEvent({type:"onFinishAction"});
	}

	function delAttrFromPath(xpath:String, attr:Array) : Void {
		if (findPath(xpath)) {
			for (var i in attr) {
				if (i!="xpath") {
					delete targetNode.attributes[i];
				}
			}
		}
		dispatchEvent({type:"onFinishAction"});
	}
	
	function addValueToPath(xpath:String, value:String) : Void {
		if (findPath(xpath)) {
			if (targetNode.firstChild.hasChildNodes()) {
				var children = targetNode.firstChild.childNodes;
				for (var i in children) {
					children[i].removeNode();
				}
			}
			targetNode.firstChild.appendChild(this.createTextNode(value));
		}
		dispatchEvent({type:"onFinishAction"});
	}
	
	function delValueFromPath(xpath:String) : Void {
		if (findPath(xpath)) {
			targetNode.firstChild.removeNode();
		}
		dispatchEvent({type:"onFinishAction"});
	}
	
	/* remove all nodes in this */
	function removeAllNodes() : Void {
		if (this.hasChildNodes()) {
			for (var i in this.childNodes) {
				this.childNodes[i].removeNode();
			}
		}
	}
	
	/* reset this XMLdoc to empty */
	function addRootNode() : Void {}	// this function is implemented in xmlCourse, xmlUnit & xmlExercise
	function resetDoc() : Void {
		myTrace("xmlFunc.resetDoc");
		// remove all nodes in this xml
		removeAllNodes();
		// add root node to this xml
		addRootNode();		
	}
}
