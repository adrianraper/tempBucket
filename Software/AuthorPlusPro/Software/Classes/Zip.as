class Zip {
	private var connect_name:String;
	private var receive_name:String;
	private var arg:String;
	public var Event:LocalConnection;
	private var $ZS:LocalConnection;
	
	function Zip(user:String,serial:String) {
		//var user="Adrian Raper";
		//var serial="263082341957793057-1834082842";
		_root.mdm.Extensions.Zip.LoadZipEx(user, serial);
		receive_name = "_flashzip";
		connect_name = "_flashzipreceive";
		Event = new LocalConnection();
		Event.connect(receive_name);
		$ZS = new LocalConnection();
		//Event.close();
		//Event.connect(receive_name);
		_global.myTrace("Zip Extension for ZinC");
	}
	public function CompressFiles(filename:String, FileList:Array, Password:String, CompressMethod:Number, SpanSize:Number, Comment:String, Replace:Boolean):Void {
		trace("Command CompressFiles");
		if (Replace) {
			arg = filename+","+FileList.join("$")+","+Password+","+CompressMethod+","+SpanSize+","+Comment+","+"true";
		} else {
			arg = filename+","+FileList.join("$")+","+Password+","+CompressMethod+","+SpanSize+","+Comment+","+"false";
		}
		trace(arg);
		$ZS.send(connect_name, "CompressFiles", arg);
	}
	public function CompressFolder(filename:String, Folder:String, Mask:String, Password:String, CompressMethod:Number, SpanSize:Number, Comment:String):Void {
		arg = filename+","+Folder+","+Mask+","+Password+","+CompressMethod+","+SpanSize+","+Comment;
		_global.myTrace("Command CompressFolder:" + arg);
		$ZS.send(connect_name, "CompressFolder", arg);
	}
	public function ExtractDirect(filename:String, Folder:String, password:String):Void {
		arg = filename+","+Folder+","+password;
		_global.myTrace("Command ExtractDirect :" + arg);
		$ZS.send(connect_name, "ExtractDirect", arg);
	}
	public function CancelProcess():Void {
		trace("Command CancelCompress :");
		$ZS.send(connect_name, "CancelCompress");
	}
	public function OpenZip(filename:String, password:String, callback:String):Void {
		trace("Command OpenZip :"+filename);
		arg = filename+","+password+","+callback;
		$ZS.send(connect_name, "OpenZip", arg);
		//
	}
	public function Replace(oldfile:String, newfile:String, callback:String):Void {
		trace("Command Replace :");
		arg = oldfile+","+newfile+","+callback;
		$ZS.send(connect_name, "Replace", arg);
		//
	}
	public function CloseZip():Void {
		trace("Command CloseZip ");
		$ZS.send(connect_name, "CloseZip");
		//
	}
	public function AddFile(filename:String):Void {
		trace("Command AddFile");
		$ZS.send(connect_name, "AddFile", filename);
	}
	public function DeleteFile(filename:String):Void {
		trace("Command DeleteFile");
		$ZS.send(connect_name, "DeleteFile", filename);
	}
	public function CurrentDir(dir:String):Void {
		trace("Command CurrentDir");
		$ZS.send(connect_name, "CurrentDir", dir);
	}
	public function GetComment(callback:String):Void {
		trace("Command GetComment");
		arg = callback;
		$ZS.send(connect_name, "GetComment", arg);
	}
	public function SetComment(comment:String):Void {
		trace("Command SetComment");
		arg = comment;
		$ZS.send(connect_name, "SetComment", arg);
	}
	public function TestZip(callback:String):Void {
		trace("Command TestZip");
		arg = callback;
		$ZS.send(connect_name, "TestZip", arg);
	}
	public function ExtractFile(filename:String):Void {
		trace("Command ExtractFile");
		arg = filename;
		$ZS.send(connect_name, "ExtractFile", arg);
	}
	public function Free():Void {
		$ZS.send(connect_name, "Close");
		$ZS.close();
		Event.close();
		_root.mdm.Extensions.Zip.FreeZipEx();
	}	
	//function
}
