<?php
class MediaNode {
	
	// An Arthur media node has attributes, no value
	// What type of media is it?
	private $type;
	private $qualifier;
	
	// Where is it?
	private $filename;
	private $location;
	private $url;

	// mode controls behaviour (such as hidden until after marking, or autorun)
	private $mode;
	 
	// w, y, width and height might be used as is unless this ruins floats
	private $x;
	private $y;
	private $width;
	private $height;
	private $stretch;

	// should be caption
    private $name;
	
	// for reference
	private $id;

	protected $parent;
	
	function getParent() {
		return $this->parent;
	}
	function setParent($object) {
		$this->parent = $object;
	}
	
	public function __construct($xmlObj=null, $parent=null) {
		// Keep a reference back to the section we are part of
		$this->setParent($parent);
		
		//echo $xmlObj;
		if ($xmlObj) {
			// Dig out the text and settings from this xml
			$attr = $xmlObj->attributes();
			if (count($attr)>0) {
				foreach($attr as $a => $b) {
					switch ($a) {
						case 'id':
						case 'x':
						case 'y':
						case 'width':
						case 'height':
						case 'stretch':
						case 'location':
						case 'mode':
						case 'filename':
						case 'name':
                        case 'url':
							$this->$a = $b;
							break;
						case 'type':
							// First character is a subtype
							$this->qualifier = substr($b,0,1);
							// Then third onwards is the real type
							$this->type = substr($b,2);
						default:
					}
				}
			}
		}
	}
	
	function getID(){
		return $this->id;
	}
	// A utility function to describe the object
	function toString() {
		global $newline;
		$build=$newline.'<media ';
		// Loop through all (private and public) members of this class
		
		foreach (get_object_vars($this) as $a=>$b) {
			switch ($a) {
				case 'id':
				case 'x':
				case 'y':
				case 'width':
				case 'height':
				case 'stretch':
				case 'location':
				case 'mode':
				case 'filename':
				case 'type':
				case 'qualifier':
                case 'name':
                case 'url':
			  		// Simple attributes
			  		if ($b)
			  			$build.="$a=$b ";
			  		break;
			}
		}
		$build.='/>';
		return $build;
	}
	// This function turns the object into a string to go into the xhtml file.
	// <media name="weblink" url="http://www.studyskillssuccess.com/reading.html" mode="1" id="1004" type="m:url" />
	function output() {
		$build='';
		switch ($this->type) {
			case 'picture':
			case 'image':
				$build.= '<img ';
                $build .= 'src="../media/'.$this->filename.'" ';
				break;
			case 'streamingAudio':
			case 'audio':
				/*
				 <video width="320" height="240" controls>
				  <source src="movie.mp4" type="video/mp4">
				  <source src="movie.ogg" type="video/ogg">
				  Your browser does not support the video tag.
  				 </video>
				 */
				$build.= '<audio controls class="compact">';
                $build .= '<source src="../media/'.$this->filename.'" type="audio/mp3">';
				break;
			case 'video':
				$build.= '<video controls>';
                $build .= '<source src="../media/'.$this->filename.'" type="video/mp4">';
				break;
            case 'url':
                $build.= '<a ';
                $thisUrl = str_replace('#sharedMedia#	', '', $this->url);
                $build .= 'src="../media/'.$thisUrl.'" ';
                break;
			// Possibly other media nodes will be blocked as they were hacks
			case 'text':
				return '';
				break;
			default:
				//$build.= '<media ';
		}
		// Then based on the x and y we will position it somehow
		// But for now don't try to get video to float as it will fail
		// It also seems likely that most video exercises will get tweaked a bit anyway
        /*
		if ($this->type!='video' && $this->type!='url') {
			if ($this->x>=100 && $this->y<=100) {
				$build.= 'class="rightFloat" ';
			} else {	
				$build.= 'class="leftFloat" ';
			}
		}
        */
		// Other attributes that just get copied
		//$build.="mode=\"$this->mode\" id=\"$this->id\" ";

		// Let it be a natural width and height unless stretched
		//if ($this->stretch=='true')
		//	$build.="height=\"$this->height\" width=\"$this->width\" ";

        switch ($this->type) {
            case 'url':
                $build .= '>'.$this->name.'</a>';
                break;
            case 'audio':
            case 'video':
                $build .= '</'.$this->type.'>';
                break;
            default:
                $build .= ' />';
        }
		return $build;
	}
}
