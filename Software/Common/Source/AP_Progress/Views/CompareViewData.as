class AP_Progress.Views.CompareViewData
{
	// const 
	private var START_XID:Number	= 100;
	private var FIRST_COLOR:Number	= 0x318DBD;
	private var SECOND_COLOR:Number	= 0xFF8DBD;
	
	// memeber variables
	private var m_aSeries:Array; 
	private var m_aGraphValues:Array;
	private var m_aColor:Array;
	
	public function CompareViewData(){
		m_aSeries			= new Array();
		m_aGraphValues		= new Array();
	}
	
	public function addSeries(strSeriesName:String):Void{
		var v1:Number= 0;
		var bExisted:Boolean= false;
		for(v1=0; v1<m_aSeries.length; ++v1){
			if(m_aSeries[v1]==strSeriesName){
				bExisted= true;
				break;
			}
		}
		if(!bExisted)
			m_aSeries.push(strSeriesName);
	}
	
	public function addGraphValue(strSeriesName:String, nValue:Number):Void{
		var v1:Number= 0;
		var bExisted:Boolean= false;
		
		for(v1=0; v1<m_aSeries.length; ++v1){
			if(m_aSeries[v1]==strSeriesName){
				bExisted= true;
				break;
			}
		}
		
		if(bExisted){			
			if(m_aGraphValues[v1][0]==undefined){
				m_aGraphValues[v1]= new Array();
			}
			m_aGraphValues[v1].push(Math.round(nValue));
		}
	}
	
	public function outputAmData():String{
		// add the xml common header and series first
		var strResult:String;
		
		strResult= 	"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
					+ "<chart>"
						+ "<series>";
		
		var v1:Number= 0;
		for(v1=0; v1<m_aSeries.length; ++v1){
			strResult+= "<value xid=\"" + String(START_XID + v1) + "\">" + m_aSeries[v1] + "</value>";
		}
		
		strResult+= "</series>"
					+ "<graphs>";
					
		// add the value of graph
		var v2:Number		= 0;
		var nCurGid:Number	= 0;
		var nCurXID:Number	= 0;

		for(v2=0; v2<m_aGraphValues[0].length; ++v2, ++nCurGid){
			nCurXID= START_XID;
			strResult+= "<graph gid=\"" + nCurGid + "\">";
			for(v1=0; v1<m_aGraphValues.length; ++v1, ++nCurXID){
				if(nCurGid==2)
					++nCurGid;
				
				strResult+= "<value xid=\"" + nCurXID + "\">" + m_aGraphValues[v1][v2] + "</value>";
								
			}
			strResult+= "</graph>";
		}
				
		// footer
		strResult+= 	"</graphs>"
					+ "</chart>";
		return strResult;
	}
	
	public function haveData():Boolean{
		return (m_aSeries.length > 0);
	}
}