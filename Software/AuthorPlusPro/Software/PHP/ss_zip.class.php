<?PHP
/** SS_ZIP class is designed to work with ZIP archives
@author Yuriy Horobey, smiledsoft.com
@email info@smiledsoft.com
*/
class ss_zip{
	/** contains whole zipfile
	@see ss_zip::archive()
	@see ss_zip::ss_zip()
	*/
	var $zipfile="";
	/** compression level	*/
	var $complevel=6; 
	/** entry counter */
	var $cnt=0;
	/** current offset in zipdata segment */
	var $offset=0;
	/** index of current entry 
		@see ss_zip::read()
	*/
	var $idx=0;
	/**
	ZipData segment, each element of this array contains local file header plus zipped data
	*/
	var $zipdata=array();
	/**	central directory array	*/
	var $cdir=array();
	/**	constructor
	@param string zipfile if not empty must contain path to valid zip file, ss_zip will try to open and parse it.
	If this parameter is empty, the new empty zip archive is created.
	@param int complevel compression level, 1-minimal compression, 9-maximal, default is 6
	*/
	function ss_zip($zipfile="",$complevel=6){
		$this->clear();
		if($complevel<1)$complevel=1;
		if($complevel>9)$complevel=9;
		$this->complevel=$complevel;
		$this->open($zipfile);
	}
	/**Resets the objec, clears all the structures
	*/
	function clear(){
		$this->zipfile="";
		$this->complevel=6; 
		$this->cnt=0;
		$this->offset=0;
		$this->idx=0;
		$this->zipdata=array();
		$this->cdir=array();
	}
	/**opens zip file.
	This function opens file pointed by zipfile parameter and creates all necessary structures
	@param str zipfile path to the file
	@param bool append if true the newlly opened archive will be appended to existing object structure
	*/	
	function open($zipfile, $append=false){
		
		if(file_exists($zipfile)){
			$start_offset =strlen(implode($this->zipdata));
			if(!$append)$this->clear();			
			$fh=fopen($zipfile,'r');
			$data=fread($fh,filesize($zipfile));
			fclose($fh);
			$cdiridx = strpos($data,"PK\x01\x02");
			$endidx = strpos($data,"PK\x05\x06", $cdiridx);
			$zds=substr($data,0,$cdiridx);
			$zdsl=strlen($zds);
			$cds=substr($data,$cdiridx,$endidx-$cdiridx);
			$cdsl=strlen($cds);
			for($i=0;$i<$zdsl;){
				$idx= strpos($zds,"PK\x03\x04",$i+1);
				if(!$idx)$idx=$zdsl;
				$zde=substr($zds,$i,$idx-$i);
				$this->zipdata[]=$zde;
				$i=$idx;

			}

			for($i=0;$i<$cdsl;){
				$idx= strpos($cds,"PK\x01\x02",$i+1);
				if(!$idx)$idx=$cdsl;
				$cde=substr($cds,$i,$idx-$i);
				if($append){
					$offset=substr($cde,42,4);
					$offset=unpack('Vofs',$offset);
					$offset=$offset['ofs'];
					$offset = $start_offset + $offset;			
					$ofspack=pack("V",$offset);
					$cde[42]=$ofspack[0];
					$cde[43]=$ofspack[1];
					$cde[44]=$ofspack[2];
					$cde[45]=$ofspack[3];
				}
				$this->cdir[]=$cde;
				$i=$idx;

			}
			$this->offset+=strlen($zds);
			$this->cnt=count($this->cdir);
			$this->seek_idx(0);
			$this->archive();
		}
	
	}
	/**saves to the disc or sends zipfile to the browser.
	@param str zipfile path under which to store the file on the server or file name under which the browser will receive it.
	If you are saving to the server, you are responsible to obtain appropriate write permissions for this operation.
	@param char where indicates where should the file be sent 
	<ul>
	<li>'f' -- filesystem </li>
	<li>'b' -- browser</li>
	</ul>
	Please remember that there should not be any other output before you call this function. The only exception is
	that other headers may be sent. See <a href='http://php.net/header' target='_blank'>http://php.net/header</a>
	*/
	function save($zipfile, $where='f'){
		if(!$this->zipfile)$this->archive();
		$zipfile=trim($zipfile);
		
		if(strtolower(trim($where))=='f'){
			 $this->_write($zipfile,$this->zipfile);
		}else{
			$zipfile = basename($zipfile);
			header("Content-type: application/octet-stream");
			header("Content-disposition: attachment; filename=\"$zipfile\"");
			print $this->archive();
		}	
	}
	
	/** adds data to zip file
	@param str filename path under which the content of data parameter will be stored into the zip archive
	@param str data content to be stored under name given by path parameter
	@see ss_zip::add_file()
	*/
	function add_data($filename,$data=null){

		$filename=trim($filename);
		$filename=str_replace('\\', '/', $filename);
		if($filename[0]=='/') $filename=substr($filename,1);

		if( ($attr=(($datasize = strlen($data))?32:16))==32 ){
			$crc	=	crc32($data);
			$gzdata = gzdeflate($data,$this->complevel);
			$gzsize	=	strlen($gzdata);
			$dir=dirname($filename);
//			if($dir!=".") $this->add_data("$dir/");
		}else{
			$crc	=	0;
			$gzdata = 	"";
			$gzsize	=	0;

		}
		$fnl=strlen($filename);
        $fh = "\x14\x00";    // ver needed to extract 
        $fh .= "\x00\x00";    // gen purpose bit flag 
        $fh .= "\x08\x00";    // compression method 
        $fh .= "\x00\x00\x00\x00"; // last mod time and date 
		$fh .=pack("V3v2",
			$crc, //crc
			$gzsize,//c size
			$datasize,//unc size
			$fnl, //fname lenght
			0 //extra field length
		);
		

		//local file header
		$lfh="PK\x03\x04";
		$lfh .= $fh.$filename;
		$zipdata = $lfh;
		$zipdata .= $gzdata;
		$zipdata .= pack("V3",$crc,$gzsize,$datasize);
		$this->zipdata[]=$zipdata;
		//Central Directory Record
		$cdir="PK\x01\x02";
		$cdir.=pack("va*v3V2",
		0,
		$fh,
    	0, 		// file comment length 
    	0,		// disk number start 
    	0,		// internal file attributes 
    	$attr,	// external file attributes - 'archive/directory' bit set 
		$this->offset
		).$filename;

		$this->offset+= 42+$fnl+$gzsize;
		$this->cdir[]=$cdir;
		$this->cnt++;
		$this->idx = $this->cnt-1;
	}
	/** adds a file to the archive
	@param str filename contains valid path to file to be stored in the arcive. 
	@param str storedasname the path under which the file will be stored to the archive. If empty, the file will be stored under path given by filename parameter
	@see ss_zip::add_data()
	*/	
	function add_file($filename, $storedasname=""){
		$fh= fopen($filename,"r");
		$data=fread($fh,filesize($filename));
		if(!trim($storedasname))$storedasname=$filename;
		return $this->add_data($storedasname, $data);
	}
	/** compile the arcive.	
	This function produces ZIP archive and returns it.
	@return str string with zipfile
	*/
	function archive(){
		if(!$this->zipdata) return "";
		$zds=implode('',$this->zipdata);
		$cds=implode('',$this->cdir);
		$zdsl=strlen($zds);
		$cdsl=strlen($cds);
		$this->zipfile= 
			$zds
			.$cds
			."PK\x05\x06\x00\x00\x00\x00"
	        .pack('v2V2v'
        	,$this->cnt			// total # of entries "on this disk" 
        	,$this->cnt			// total # of entries overall 
        	,$cdsl					// size of central dir 
        	,$zdsl					// offset to start of central dir 
        	,0);							// .zip file comment length 
		return $this->zipfile;
	}
	/** changes pointer to current entry.
	Most likely you will always use it to 'rewind' the archive and then using read()
	Checks for bopundaries, so will not allow index to be set to values < 0 ro > last element
	@param int idx the new index to which you want to rewind the archive curent pointer 
	@return int idx the index to which the curent pointer was actually set
	@see ss_zip::read()
	*/
	function seek_idx($idx){
		if($idx<0)$idx=0;
		if($idx>=$this->cnt)$idx=$this->cnt-1;
		$this->idx=$idx;
		return $idx;
	}
	/** Read an entry from the arcive which is pointed by inner index pointer.
	The curent index can be changed by seek_idx() method.
	@return array Returns associative array of the following structure
	<ul>
	<li>'idx'=>	index of the entry </li>
	<li>'name'=>full path to the entry </li>
	<li>'attr'=>integer file attribute of the entry </li>
	<li>'attrstr'=>string file attribute of the entry <br>
	This can be:
		 <ul>
			 <li>'file' if the integer attribute was 32</li>
			 <li>'dir'  if the integer attribute was 16 or 48</li>
			 <li>'unknown' for other values</li>
		 </ul>
	</li>
	</ul>
	@see ss_zip::seek_idx()
	*/
	function read(){

		if($this->idx>=0 and $this->idx < $this->cnt ){
			$cde=$this->cdir[$this->idx];
			$fnl= unpack('Vfnl',substr($cde,28,4));
			$fnl=$fnl['fnl'];
			$name = substr($cde,46,$fnl);

			$attr = unpack('Vattr',substr($cde,38,4));
			$attr=$attr["attr"];

			switch($attr){
				case 32:$attrstr="file";break;
				case 48:$attrstr="dir";	break;
				case 16:$attrstr="dir";	break;
				default:$attrstr="unknown";
				break;

			}
			$entry=array(
				'idx'=>$this->idx,
				'name'=>$name,
				'attr'=>$attr,
				'attrstr'=>$attrstr
			);
			$this->idx++;
			return $entry;			
		}else{
			return false;
		}

	}
	/** Removes entry from the archive.
	please be very carefull with this function, there is no undo after you save the archive
	@return bool true on success or false on failure
	@param int idx
	*/
	function remove($idx){
	
		if(!$this->_check_idx($idx) or $this->cnt<=0) return false;
		$this->idx=0;
		$ofsdel=strlen($this->zipdata[$idx]);
		array_splice($this->zipdata,$idx,1);
		array_splice($this->cdir,$idx,1);
		$this->cnt=count($this->cdir);
		$this->offset=strlen(implode('',$this->zipdata));

		//recalc offsets in cdir
		for($i=$idx;$i<$this->cnt;$i++){
			$offset=substr($this->cdir[$i],42,4);
			$offset=unpack('Vofs',$offset);
			$offset=$offset['ofs'];
			$offset-=$ofsdel;			
			$ofspack=pack("V",$offset);
			$this->cdir[$i][42]=$ofspack[0];
			$this->cdir[$i][43]=$ofspack[1];
			$this->cdir[$i][44]=$ofspack[2];
			$this->cdir[$i][45]=$ofspack[3];
		
		}
		$this->zipfile="";
		
		return true;
	}
	/** extracts data from the archive and return it as a string.
	This will return data identified by idx parameter. 
	@param int idx index of the entry
	@return array returns associative array of the folloving structure:
	 <ul>
		 <li>'file' path under which the entry is stored in the archive</li>
		 <li>'data' In case if the entry was file, contain its data. For directory entry this is empty</li>
		 <li>'size' size of the data</li>
		 <li>'error' the error if any has happened. The bit 0 indicates incorect datasize, bit 1 indicates CRC error</li>
	 </ul>
	@see ss_zip::extract_file
	*/
	function extract_data($idx){
		if(!$this->_check_idx($idx) ) return false;
		$crc=substr($this->zipdata[$idx],14,4);
		$crc=unpack('Vz',$crc);
		$crc=$crc['z'];

		$gzsize=substr($this->zipdata[$idx],18,4);
		$gzsize=unpack('Vz',$gzsize);
		$gzsize=$gzsize['z'];
		
		$datasize=substr($this->zipdata[$idx],22,4);
		$datasize=unpack('Vz',$datasize);
		$datasize=$datasize['z'];

		$fnl=substr($this->zipdata[$idx],26,2);
		$fnl=unpack('vz',$fnl);
		$fnl=$fnl['z'];

		$extra=substr($this->zipdata[$idx],28,2);
		$extra=unpack('vz',$extra);
		$extra=$extra['z'];
		$fn=substr($this->zipdata[$idx],30,$fnl);
		$didx=30+$fnl+$extra;
		$data=substr($this->zipdata[$idx],$didx,$gzsize);
		$data=@gzinflate($data);
		$dsz=strlen($data);
		$error=0;
		if($dsz!=$datasize) $error+=1;
		$dcrc=crc32($data);
		if($dcrc!=$crc) $error+=2;
		return array(
		"file"=>$fn,
		"data"=>$data,
		"size"=>$dsz,
		"error"=>$error);
	}
	/** extracts the entry and creates it in the file system.
	@param int idx Index of the entry
	@param string path the first part of the path where the entry will be stored. So if this 
	is '/my/server/path' and entry is arhived/file/path/file.txt then the function will attempt to
	store it under /my/server/path/arhived/file/path/file.txt You are responsible to ensure that you
	have write permissions for this operation under your operation system. 
	*/
	function extract_file($idx,$path="."){
		$rec=$this->extract_data($idx);
		if(!$rec['error']){
			$fpt=explode('/',$rec['file']);
			$cnt=count($fpt);//sjip the file
			$dir=$path;
			for($i=0;$i<$cnt;$i++){
				@mkdir($dir);			
				$dir="$dir/".$fpt[$i];
			}
			if($path[strlen($path)-1]!='/')$path.="/";
			if($rec['data'])	$this->_write("$path".$rec['file'],$rec['data']);
		} 
		return $rec;
	}
	function _check_idx($idx){
		return $idx>=0 and $idx<$this->cnt;
	}
	function _write($name,$data){
		$fp=fopen($name,"w");
		fwrite($fp,$data);
		fclose($fp);
	}
}

/** debug helper.
the only job for this function is take parameter $v and ouput it with print_r() preceding with < xmp > etc
The $l is a label like l=myvar
*/
function dbg($v,$l='var'){echo"<xmp>$l=";print_r($v);echo"</xmp>";}
?>