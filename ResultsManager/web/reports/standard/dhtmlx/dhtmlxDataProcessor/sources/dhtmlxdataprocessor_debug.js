dataProcessor.prototype._o_init = dataProcessor.prototype.init;
dataProcessor.prototype.init=function(obj){
    this._console=this._console||this._createConsole();
    return this._o_init(obj);
}

dataProcessor.prototype._createConsole=function(){
    var c=document.createElement("DIV");
    c.style.cssText='width:450px; height:420px; overflow:auto; position:absolute; top:0px; right:0px; border:1px dashed black; font-family:Tahoma; Font-size:10pt;';
    c.innerHTML="<div style='width:100%; background-color:gray; font-weight:bold; color:white;'><span style='cursor:pointer;float:right;' onclick='this.parentNode.parentNode.style.display=\"none\"'><sup>[close]&nbsp;</sup></span>&nbsp;DataProcessor</div><div style='width:100%; height:200px; overflow-Y:scroll;'>&nbsp;Current state</div><div style='width:100%; height:200px; overflow-Y:scroll;'>&nbsp;Log:</div>";
    if (document.body) document.body.insertBefore(c,document.body.firstChild);
    else dhtmlxEvent(window,"load",function(){
        document.body.insertBefore(c,document.body.firstChild);
    })    
    dhtmlxEvent(window,"dblclick",function(){ 
        c.style.display='';
    })    
    return c;
}

dataProcessor.prototype._log=function(data){
    this._console.childNodes[2].innerHTML=this._console.childNodes[2].innerHTML+"<br/>"+data;
}
dataProcessor.prototype._updateStat=function(data){
    var data=["&nbsp;Current state"];
    for(var i=0;i<this.updatedRows.length;i++)
		if(typeof this.updatedRows[i] != "undefined"){
		    data.push("&nbsp;ID:"+this.updatedRows[i]+" Status: "+(this.obj.getUserData(this.updatedRows[i],"!nativeeditor_status")||"updated"))
		}
	this._console.childNodes[1].innerHTML=data.join("<br/>")+"<hr/>Current mode: "+this.updateMode;
}

dataProcessor.prototype._o_setUpdated=dataProcessor.prototype.setUpdated;
dataProcessor.prototype.setUpdated = function(rowId,state,forceUpdate){
    this._log("&nbsp;row <b>"+rowId+"</b> marked as "+(state?"updated":"normal"));
    var res=this._o_setUpdated(rowId,state,forceUpdate);
    this._updateStat();
    return res;
}




dataProcessor.prototype._o_sendData = dataProcessor.prototype.sendData;
dataProcessor.prototype.sendData = function(rowId){
    if (rowId){
        this._log("&nbsp;Initiating data sending for <b>"+rowId+"</b>");
        if (!this.obj.rowsAr[rowId])
            this._log("&nbsp;Error! row with such ID not exists <b>"+rowId+"</b>");
    }
    var res=this._o_sendData(rowId);
    if (rowId && res && res.length){
        this._log("&nbsp;Server url: "+res[0]);
        this._log("<blockquote>"+res[1].replace(/\&/g,"<br/>")+"<blockquote>");
    }
    return res;
}

dataProcessor.prototype.afterUpdate = function(that,b,c,d,xml){
		if (that._debug)
			alert("XML status: "+(xml.xmlDoc.responseXML?"correct":"incorrect")+"\nServer response: \n"+xml.xmlDoc.responseText);
        that._log("server response received <code>"+(xml.xmlDoc.responseText||"").replace(/\&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")+"</code>");			
        if (!atag || !atag.tagName) return that._log("Not a XML");
		var atag=xml.doXPath("//data/action");
		if (!atag)
		    that._log("No actions found ( incorrect XML , or incorrect content type of data )")
        that._waitMode--;
		if ((!atag)||(!atag.length)){
		    that._log("fallback to low level parsing")
			var i=0;
			var atag=xml.getXMLTopNode("data");
			if (!atag) that._log("XML not valid for sure");
        	while ((atag.childNodes[i])&&(atag.childNodes[i].tagName)&&(atag.childNodes[i].tagName!="action")) i++;
           	atag=atag.childNodes[i];
           	var action = atag.getAttribute("type");
           	var sid = atag.getAttribute("sid");
           	var tid = atag.getAttribute("tid");
            that._log("Action: "+action+" SID:"+sid+" TID:"+tid);
            if (!that.obj.rowsAr[sid]) that._log("Incorrect SID, row with such ID not exists in grid");
		    if ((that._uActions)&&(that._uActions[action])&&(!that._uActions[action](atag))) {}
			else that.afterUpdateCallback(sid,tid,action);           
			that._in_progress[sid]=null;
        }   
        else   {
           for (var i=0; i<atag.length; i++){
           var btag=atag[i];
           var action = btag.getAttribute("type");
           var sid = btag.getAttribute("sid");
           var tid = btag.getAttribute("tid");
			that._log("Action: "+action+" SID:"+sid+" TID:"+tid);
			if (!that.obj.rowsAr[sid]) that._log("Incorrect SID, row with such ID not exists in grid");
		    if ((that._uActions)&&(that._uActions[action])&&(!that._uActions[action](btag))) {}
			else that.afterUpdateCallback(sid,tid,action);
			that._in_progress[sid]=null;
		}}
		
		if (!that.stopOnError) 
			that.sendData();
		that.stopOnError=false;
}

