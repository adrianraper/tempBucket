import mx.utils.Delegate;

// v6.4.2.3 DK modelled on fspExportFilesClass
class Classes.fspScormExportClass {
	
	// parameters to be set before function is called		
	var basePath:String;
	var SCORM:Boolean;
	var mdmActionRun:Object;
	var uids:Array;
	var unames:Array;
	var cid:String;
	var cname:String;
	// v6.4.3 Software path
	var serverPath:String;
	
	// private variables used in this class
	private var tempFolder:String;	
	private var SCORMpath:String;
	private var ManifestXmlPath:String;
	private var FinishEdit:Boolean;
	
	var intID:Number;
		
	//v6.4.3 Running with mdmScript 2.0
	var mdm:Object;
	
	function fspScormExportClass() {
		mdm = _global.mdm; // v6.4.3 mdm Script 2.0
	}
		
	// private functions
	private function myTrace(s:String) : Void {
		_global.myTrace(s);
	}
	// public functions
	// for putting together a SCORM SCO ZIP pack
	public function createSCO() : Void {
		myTrace("fspScormExportClass.as: CreateSCO()");
		//myTrace("uids: "+uids);
		//myTrace("unames: "+unames);
		myTrace("cid: "+cid);
		myTrace("cname: "+cname);				
		
		//make temp folder for SCORM
		// v6.4.3 Tidy up folder names
		//tempFolder = basePath+"\\"+getCurrentClarityUniqueID();		
		//SCORMpath = basePath.substr(0,(basePath.length-("\\Content\\AuthorPlus".length))); //get the relative path of SCORM files
		//SCORMpath +="\\Software\\AuthorPlusPro\\Software\\SCORM";
		tempFolder = _global.addSlash(basePath)+getCurrentClarityUniqueID();		
		SCORMpath = _global.addSlash(this.serverPath) + "SCORM";
		// v6.4.3 Update to mdm script 2
		//_root.mdm.makefolder(tempFolder);
		if (mdm.System.winVerString.indexOf("98")>0) {
			mdm.FileSystem.makeFolder(tempFolder);
		} else {
			mdm.FileSystem.makeFolderUnicode(tempFolder);
		}

		myTrace("tempFolder: "+tempFolder);		
		//myTrace("_global.NNW.paths.main: "+_global.NNW.paths.main);
		myTrace("SCORMpath: "+SCORMpath);		
		
		//copy default SCORM files
		// v6.4.3 Remove APIWrapper and SCORMScripts from the ZIP file
		//var SCORMfiles:Array  = Array(	"APIWrapper.js", "SCORMScripts.js", 
		// v6.5 New SCORM files (you could just copy all that are here - would be neater)
		//var SCORMfiles:Array  = Array(	"adlcp_rootv1p2.xsd", "ims_xml.xsd", "imscp_v1p1.xsd", "imsmd_v1p2p2.xsd", 
		//								"imsmanifest.xml",  "SCORMStart.html");
		var SCORMfiles:Array  = Array(	"adlcp_rootv1p2.xsd", "ims_xml.xsd", "imscp_rootv1p1p2.xsd", "imsmd_rootv1p2p1.xsd", 
										"imsmanifest.xml",  "SCORMStart.html");
		
		for (var i in SCORMfiles) {
			var file = SCORMfiles[i];
			//myTrace("copy "+SCORMpath+"\\"+file+" to: "+tempFolder+"\\"+file);
			// v6.4.3 Update to mdm script 2
			//_root.mdm.copyfile(SCORMpath+"\\"+file, tempFolder+"\\"+file);
			if (mdm.System.winVerString.indexOf("98")>0) {
				mdm.FileSystem.copyFile(_global.addSlash(SCORMpath)+file, _global.addSlash(tempFolder)+file);
			} else {
				mdm.FileSystem.copyFileUnicode(_global.addSlash(SCORMpath)+file, _global.addSlash(tempFolder)+file);
			}
		}		
		
		ManifestXmlPath = tempFolder+"\\imsmanifest.xml";
		FinishEdit = false;
		//editManifestForExport
		editManifestForExport();
		
		// zip the files up, not here, because the files may not be edited yet
		//zipFolder()
	}
	
	private function editManifestForExport() : Void {
		if (!FinishEdit) {
			myTrace("editManifestForExport()");
			var cx = new XML();
			// v6.4.3 Ignore white SPACE
			cx.ignoreWhite = true;
			cx.master = this;		
			cx.onLoad = function(success) {			
				this.xmlDecl = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
				_global.myTrace("cx.onLoad success? "+success);
				//_global.myTrace("b4: xml:"+this.toString());
				if (success) {			
					//get XML information
					var manifest = this.firstChild;
					var organizations = manifest.firstChild;
					var organization = organizations.firstChild;
					var ctitle = organization.firstChild;
					var citem = organization.childNodes[1];				
					var ctext = ctitle.firstChild;
					
					//_global.myTrace("ctext: "+ctext);
					
					//course information
					var uids = this.master.uids;
					var unames = this.master.unames;
					var cid = this.master.cid;
					var cname = this.master.cname;
					
					//update course information (make it ZINC safe)
					cname = cname.split(",").join("@c@");		
					cname = cname.split("\"").join("@q@");		
					ctext.nodeValue = cname.split("&").join("@amp@");		
					
					//update item information
					citem.removeNode();
					for (var j=0; j<uids.length; j++) {
						// v6.4.3 Why a space in the node name?
						//var itemNode:XMLNode = this.createElement("item ");
						var itemNode:XMLNode = this.createElement("item");
						//set attributes
						// v6.5.1 The item can't have our Clarity id - so just make it ITEM-x
						//itemNode.attributes["identifier"] = uids[j];
						itemNode.attributes["identifier"] = "ITEM_" + (j+1);
						itemNode.attributes["isvisible"] = "true";
						// Remove hyphens
						//itemNode.attributes["identifierref"] = "RESOURCE-1";
						itemNode.attributes["identifierref"] = "RESOURCE_1";
						
						//add subnodes
						// v6.4.3 Why a space in the node name?
						//var titleNode:XMLNode = this.createElement("title ");
						var titleNode:XMLNode = this.createElement("title");
						var titleTextNode:XMLNode = this.createTextNode("titleTextNode");
						titleTextNode.nodeValue = unames[j];
						titleNode.appendChild(titleTextNode);
			
						// v6.4.3 Why a space in the node name?
						//var adlcpNode:XMLNode = this.createElement("adlcp:datafromlms ");
						var adlcpNode:XMLNode = this.createElement("adlcp:datafromlms");
						var adlcpTextNode:XMLNode = this.createTextNode("adlcpTextNode");
						adlcpTextNode.nodeValue = "course="+cid+",unit="+uids[j];
						adlcpNode.appendChild(adlcpTextNode);
			
						itemNode.appendChild(titleNode);
						itemNode.appendChild(adlcpNode);		
			
						organization.appendChild(itemNode);
					}
					
					// v6.4.3 mdm script 2. As the xml is open, you can't do anything to it until you close it
					// use the delayed onSaveFile in mdmActionRun
					//_root.mdm.saveutf8_filename(this.master.ManifestXmlPath);
					
					// set attributes of file to be writable
					//var attrib = "-R";
					//_root.mdm.setfileattribs(this.master.ManifestXmlPath, attrib);
					
					_global.myTrace("after: xml:"+this.toString());
					//fscommand("mdm.saveutf8", this.toString());
					var intID:Number = _global['setTimeout'](this.master.mdmActionRun, "onSaveFile", 100, this.master.ManifestXmlPath, this.toString());
				}			
				this.master.FinishEdit = true;
				this.master.editManifestForExport();
			}
			//myTrace("ManifestXmlPath: "+ManifestXmlPath);
			cx.load(ManifestXmlPath);		
		
		} else {
			// zip the folder content up
			intID = setInterval(this, "zipFolder", 1000);
		}
		
	}
			
	private function getCurrentClarityUniqueID() : String {
		return _global.NNW.control.time.getCurrentClarityUniqueID();
	}

	// v6.4.3 Replace this function with the ones built for export
	/*
	private function zipFolder() : Void {
			
		myTrace("fspScormExportClass:zipFolder()");
		clearInterval(intID);
		_root.zip_file=tempFolder+".zip";
		_root.zip_folder=tempFolder;
		_root.zip_ext="*.*";
		_root.zip_pwd="none";
		myTrace("zip file: "+_root.zip_file);
		myTrace("zip folder: "+_root.zip_folder);

		fscommand("flashvnn.ZipFolder","zip_file,zip_folder,zip_ext,zip_pwd");	
		
		// finish making zip
		mdmActionRun.onQueryFinish();
	}
	*/
	private function zipFolder() : Void {
		myTrace("fspScormExportClass:zipFolder()");
		clearInterval(intID);
		// v6.4.3 The following will NOT work, or rather it adds too many levels of folder to the zip
		// So you need to manipulate the path to get rid of ..
		//tempFolder = "D:\\Workbench\\AuthorPlusNetwork\\..\\Content\\AuthorPlus\\1153911435718";
		_root.zip_file=tempFolder+".zip";
		_root.zip_folder=tempFolder;
		_root.zip_ext="*.*";
		_root.zip_pwd="none";
		//fscommand("flashvnn.ZipFolder","zip_file,zip_folder,zip_ext,zip_pwd");
		myTrace("zip folder: "+_root.zip_folder);
		myTrace("zip file: "+_root.zip_file);
		mdm.Extensions.flashvnn.ZIPFolder(_root.zip_file,_root.zip_folder,_root.zip_ext,_root.zip_pwd);		
		// Is it safe to do this immediately? Or better to way for a little while?
		intID = setInterval(this, "checkZipFolder", 1000);
	}
	
	private function checkZipFolder() : Void {
		clearInterval(intID);
		_global.myTrace("checkZipFolder");
		if (mdm.System.winVerString.indexOf("98")>0) {
			var thisExists = mdm.FileSystem.fileExists(_root.zip_file);
		} else {
			var thisExists = mdm.FileSystem.fileExistsUnicode(_root.zip_file);
		}
		if (thisExists) {
			myTrace("zip created, so delete " + tempFolder);
			// At this point we want to delete the temp folder (and all in it)
			//mdm.FileSystem.deleteFolderUnicode(tempFolder);
			// But this ZINC command doesn't delete a folder with stuff in it!!! forums recommend using windows commands
			// Hope this isn't too dangerous!!!
			var builtCommand = "cmd.exe /K RMDIR /S /Q \"" + tempFolder + "\"";
			var command = mdm.System.Paths.system + builtCommand;
			myTrace(command);
			mdm.System.execStdOut(command);
			mdmActionRun.onQueryFinish();
		} else {
			myTrace("error: unable to create the zip file");
			mdmActionRun.onQueryError();
		}		
	}
}