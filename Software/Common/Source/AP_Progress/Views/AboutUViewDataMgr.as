import AP_Progress.Views.AboutUViewData;

class AP_Progress.Views.AboutUViewDataMgr
{
	// member variables
	private var m_aData:Array;
	private var m_aUnitName:Array;
	
	public function AboutUViewDataMgr(){
		m_aData		= new Array();
		m_aUnitName	= new Array();
	}
	
	public function analysisData(myXmlRec:XML):Void{
		var oNode:XMLNode;
		var aNode:XMLNode;
		var bNode:XMLNode;
				
		var strCaption:String
		var nTotalWrong:Number;
		var nTotalCorrect:Number;
		var nTotalScore:Number;
		var nTime:Number;
		var nCount:Number;
		var nTempNumber:Number;
		var nTempString:String;
		
		var v1:Number		= 0;
		var bFound:Boolean	= false;
		for(oNode= myXmlRec.firstChild; oNode != undefined && oNode.attributes.caption != undefined; oNode= oNode.nextSibling){
			bFound		= false;
			nTempString	= oNode.attributes.caption;
			
			for(v1=0; v1<m_aUnitName.length; ++v1){
				if(m_aUnitName[v1] == nTempString){
					bFound= true; 
				}
			}
			
			if(!bFound)
				m_aUnitName.push(nTempString);
				
			for(aNode= oNode.firstChild; aNode != undefined; aNode= aNode.nextSibling){
				nTotalCorrect		= 0;
				nTotalWrong			= 0;
				nTotalScore			= 0;
				nTime				= 0;
				
				// extract caption
				strCaption	= aNode.attributes.caption;
				
				// extract score
				nTotalScore	= Math.round(aNode.attributes.score);
				
				// extract count
				nCount		= aNode.attributes.count;
				
				for(bNode= aNode.firstChild; bNode != undefined; bNode= bNode.nextSibling){
					// extract total number of correct
					nTempNumber= Number(bNode.attributes.correct);
					if(nTempNumber>0)
						nTotalCorrect+= nTempNumber;
						
					// extract total number of wrong
					
					nTempNumber= Number(bNode.attributes.wrong);
					if(nTempNumber>0)
						nTotalWrong+= nTempNumber;
						
					// extract total time
					nTime+= Number(bNode.attributes.duration);
				}
				
				var ViewData:AboutUViewData= new AboutUViewData(strCaption, nTotalWrong, nTotalCorrect, nTotalScore, nTime, nCount);
				m_aData.push(ViewData);
			}
		}
	}
	
	public function haveData():Boolean{
		return (m_aData.length > 0);
	}
	
	public function givePieXmlDataOn(strUnitOption:String, strDataOption:String):String{
		_global.myTrace("strUnitOption and strDataOption: " + strUnitOption + ", " + strDataOption);
		var strResult:String;
		
		strResult= 	"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
					+ "<pie>";
					
		var v1:Number 						= 0;
		// v6.5.4.3 Now it seems to be further away - why? What happens if you remove this all
		//var nOffset:Number					= 30;
		//var nDistanceFromCenterBase:Number	= 40;
		for(v1=0; v1<m_aData.length; ++v1){
			strResult 	+= "<slice title=\"" + m_aData[v1].getData("caption") + "\"";
			// v6.5.4.3 This line seems to make no difference. 
			// From the documentation it is <settings><data_labels><radius>20%</radius></data_labels></settings> that you set at the chart level
			// And then each slice can override this with label_radius.
			//strResult	+= " label_radius=\"" + (nDistanceFromCenterBase + nOffset * (v1 % 2)) + "\""; 
			strResult+= ">" + Math.ceil(m_aData[v1].getData(strDataOption)) + "</slice>";
		}
		
		strResult+= "</pie>";

		return strResult;
	}
	
	public function getAllUnitName():Array{
		return m_aUnitName;
	}
}