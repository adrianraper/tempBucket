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
		var nUnit:Number;
		var nSection:Number;
		var nTempNumber:Number;
		var nTempString:String;
		
		var v1:Number		= 0;
		var bFound:Boolean	= false;
		for (oNode= myXmlRec.firstChild; oNode != undefined && oNode.attributes.caption != undefined; oNode= oNode.nextSibling){
			bFound		= false;
			nTempString	= oNode.attributes.caption;
			
			for (v1=0; v1<m_aUnitName.length; ++v1){
				if (m_aUnitName[v1] == nTempString){
					bFound= true; 
				}
			}
			
			if (!bFound)
				m_aUnitName.push(nTempString);
				
			// Some titles want to group units together into sections - do that here
			if (_global.ORCHID.root.licenceHolder.licenceNS.branding.toLowerCase().indexOf("clarity/cp2") >= 0) {
				// Define sections that will accumulate data
				var sectionsArray:Array = new Array({section:0, caption:'Introduction', totalCount:0, totalScore:0, totalCorrect:0, totalWrong:0, totalTime:0, sectionCount:0},
										{section:1, caption:'Consonant Clusters', totalCount:0, totalScore:0, totalCorrect:0, totalWrong:0, totalTime:0, sectionCount:0},
										{section:2, caption:'Word Stress', totalCount:0, totalScore:0, totalCorrect:0, totalWrong:0, totalTime:0, sectionCount:0},
										{section:3, caption:'Connected Speech', totalCount:0, totalScore:0, totalCorrect:0, totalWrong:0, totalTime:0, sectionCount:0},
										{section:4, caption:'Sentence Stress', totalCount:0, totalScore:0, totalCorrect:0, totalWrong:0, totalTime:0, sectionCount:0},
										{section:5, caption:'Intonation', totalCount:0, totalScore:0, totalCorrect:0, totalWrong:0, totalTime:0, sectionCount:0});
				//_global.myTrace("empty section, caption=" + sectionsArray[0].caption);
				// Go through each unit node
				for (aNode= oNode.firstChild; aNode != undefined; aNode= aNode.nextSibling){
					nTotalCorrect = 0;
					nTotalWrong = 0;
					nTotalScore = 0;
					nTime = 0;
					
					// extract caption
					strCaption	= aNode.attributes.caption;
					
					// extract score
					nTotalScore	= Math.round(aNode.attributes.score);
					
					// extract count
					nCount		= aNode.attributes.count;
					
					nUnit = Math.round(aNode.attributes.unit);
					switch (nUnit) {
						case 1:
						case 2:
						case 3:
						case 4:
						case 5:
						case 6:
							nSection=1;
							break;
						case 7:
						case 8:
						case 9:
						case 10:
						case 11:
						case 12:
							nSection=2;
							break;
						case 13:
						case 14:
						case 15:
						case 16:
						case 17:
						case 18:
							nSection=3;
							break;
						case 19:
						case 20:
						case 21:
						case 22:
						case 23:
						case 24:
							nSection=4;
							break;
						case 25:
						case 26:
						case 27:
						case 28:
						case 29:
						case 30:
							nSection=5;
							break;
						default:
							nSection=0;					
					}
					for (bNode= aNode.firstChild; bNode != undefined; bNode= bNode.nextSibling){
						// extract total number of correct
						nTempNumber= Number(bNode.attributes.correct);
						if (nTempNumber>0) {
							nTotalCorrect+= nTempNumber;
							//_global.myTrace("exercise=" + bNode.attributes.caption + " correct=" + nTempNumber);
						}
							
						// extract total number of wrong
						nTempNumber= Number(bNode.attributes.wrong);
						if (nTempNumber>0)
							nTotalWrong+= nTempNumber;
							
						// extract total time
						nTime+= Number(bNode.attributes.duration);
					}
					//_global.myTrace("unit=" + strCaption + " section=" + nSection + " totalTime=" + nTime + " score=" + nTotalScore  + " count=" + nCount);
					// Add the sub totals to the sections
					sectionsArray[nSection].totalWrong+=nTotalWrong;
					sectionsArray[nSection].totalCorrect+=nTotalCorrect;
					sectionsArray[nSection].totalScore+=nTotalScore;
					sectionsArray[nSection].totalTime+=nTime;
					sectionsArray[nSection].totalCount+=nCount;
					sectionsArray[nSection].sectionCount++;
				}
				// Put into the data for the charts
				for (var i=0; i<sectionsArray.length; i++) {
					var section = sectionsArray[i];
					//_global.myTrace("section=" + section.caption + " totalTime=" + section.totalTime + " score=" + section.totalScore);
					//var ViewData:AboutUViewData= new AboutUViewData(strCaption, nTotalWrong, nTotalCorrect, nTotalScore, nTime, nCount);
					if (section.sectionCount>0) {
						var avgScore = Math.round(section.totalScore/section.sectionCount);
					} else {
						var avgScore = 0;
					}
					var ViewData:AboutUViewData= new AboutUViewData(section.caption, section.totalWrong, section.totalCorrect, avgScore, section.totalTime, section.totalCount);
					m_aData.push(ViewData);
				}
			} else {
				for (aNode= oNode.firstChild; aNode != undefined; aNode= aNode.nextSibling){
					nTotalCorrect = 0;
					nTotalWrong = 0;
					nTotalScore = 0;
					nTime = 0;
					
					// extract caption
					strCaption	= aNode.attributes.caption;
					
					// extract score
					nTotalScore	= Math.round(aNode.attributes.score);
					
					// extract count
					nCount		= aNode.attributes.count;
					
					for (bNode= aNode.firstChild; bNode != undefined; bNode= bNode.nextSibling){
						// extract total number of correct
						nTempNumber= Number(bNode.attributes.correct);
						if (nTempNumber>0)
							nTotalCorrect+= nTempNumber;
							
						// extract total number of wrong
						nTempNumber= Number(bNode.attributes.wrong);
						if (nTempNumber>0)
							nTotalWrong+= nTempNumber;
							
						// extract total time
						nTime+= Number(bNode.attributes.duration);
					}
					var ViewData:AboutUViewData= new AboutUViewData(strCaption, nTotalWrong, nTotalCorrect, nTotalScore, nTime, nCount);
					m_aData.push(ViewData);
				}
			}
		}
	}
	
	public function haveData():Boolean{
		return (m_aData.length > 0);
	}
	
	public function givePieXmlDataOn(strUnitOption:String, strDataOption:String):String{
		//_global.myTrace("strUnitOption and strDataOption: " + strUnitOption + ", " + strDataOption);
		var strResult:String;
		
		strResult = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
				+ "<pie>";
					
		var v1:Number 						= 0;
		// v6.5.4.3 Now it seems to be further away - why? What happens if you remove this all
		//var nOffset:Number					= 30;
		//var nDistanceFromCenterBase:Number	= 40;
		// v6.5.6.5 It seems I sometimes get zero time shown (as 0) - why not chop it out here?
		for(v1=0; v1<m_aData.length; ++v1){
			if (Math.ceil(m_aData[v1].getData(strDataOption))>0) {
				strResult 	+= "<slice title=\"" + m_aData[v1].getData("caption") + "\"";
				// v6.5.4.3 This line seems to make no difference. 
				// From the documentation it is <settings><data_labels><radius>20%</radius></data_labels></settings> that you set at the chart level
				// And then each slice can override this with label_radius.
				//strResult	+= " label_radius=\"" + (nDistanceFromCenterBase + nOffset * (v1 % 2)) + "\""; 
				strResult+= ">" + Math.ceil(m_aData[v1].getData(strDataOption)) + "</slice>";
			}
		}
		
		strResult+= "</pie>";
		_global.myTrace(strResult);
		return strResult;
	}
	
	public function getAllUnitName():Array{
		return m_aUnitName;
	}
}