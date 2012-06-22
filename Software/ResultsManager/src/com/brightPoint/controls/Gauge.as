package com.brightPoint.controls
/*
Copyright (c) 2008, Thomas W. Gonzalez

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

www.brightpointinc.com

*/
{
	import com.brightPoint.utils.GraphicsUtil;
	
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.RadioButton;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.effects.Effect;
	import mx.effects.Rotate;
	import mx.effects.Sequence;
	import mx.formatters.Formatter;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;


    //Face Color
    [Style(name="faceColor",type="Number",format="Color",inherit="yes")]
    
    [Style(name="faceShadowColor",type="Number",format="Color",inherit="yes")]
    
    [Style(name="bezelColor",type="Number",format="Color",inherit="yes")]
    
    [Style(name="centerColor",type="Number",format="Color",inherit="yes")]
    
    [Style(name="pointerColor",type="Number",format="Color",inherit="yes")]

    [Style(name="ticksColor",type="Number",format="Color",inherit="yes")]
    
    [Style(name="alertAlphas",type="Array",format="Color",inherit="yes")]
    
    [Style(name="alertColors",type="Array",format="Color",inherit="yes")]
     
    [Style(name="alertRatios",type="Array",format="Color",inherit="yes")]
    
    [Style(name="fontColor",type="Number",format="Color",inherit="yes")]
    
	public class Gauge extends Container
	{
		public function Gauge():void {
			super();
			//this.setStyle("borderColor",null);
			this.clipContent=false; 
			
		}
		
		
		//CHILDREN - You can use your own swf with the same symbol names to resking this gauge.
		[@Embed(source='gauge/GaugeSkins_Skin1.swf', symbol='face')][Bindable]
	    private var _faceSymbol:Class;
	    private var _face:Image;
	    private var _faceColorChanged:Boolean=true;
	    
	    [@Embed(source='gauge/GaugeSkins_Skin1.swf', symbol='faceShadow')][Bindable]
	    private var _faceShadowSymbol:Class;
	    private var _faceShadow:Image;
	    private var _faceShadowColorChanged:Boolean=true;

		private var _alerts:UIComponent;
		private var _ticks:UIComponent;

  		[@Embed(source='gauge/GaugeSkins_Skin1.swf', symbol='pointer')][Bindable]
	    private var _pointerSymbol:Class;
	    private var _pointer:Image;
	    private var _pointerColorChanged:Boolean=true;

	    [@Embed(source='gauge/GaugeSkins_Skin1.swf', symbol='bezel')][Bindable]
	    private var _bezelSymbol:Class;
	    private var _bezel:Image;
	    private var _bezelColorChanged:Boolean=false;
	     
	    [@Embed(source='gauge/GaugeSkins_Skin1.swf', symbol='nub')][Bindable]
	    private var _centerSymbol:Class;
	    private var _center:Image;
	    private var _centerColorChanged:Boolean=true;
	    
	    [@Embed(source='gauge/GaugeSkins_Skin1.swf', symbol='reflection')][Bindable]
	    private var _reflectionSymbol:Class;
	    private var _reflection:Image;
	    
	    private var _minRadio:RadioButton;
	 	private var _maxRadio:RadioButton;
	 
 		private var _valueLabel:Label;
 		private var _minLabel:Label;
 		private var _maxLabel:Label;
	 	
	 	//Privates
	 	[Bindable] private var _maxValue:Number=10;
	 	[Bindable] private var _minValue:Number = 0;
		// Clarity - set the default that is shown before you put real data in
	 	[Bindable] private var _value:Number=0;
	 	
	  	private var _dropShadowFilter:DropShadowFilter;
	  	private var _diameter:Number;
	    private var _effectInstances:Array;
	    private var _rotating:Boolean=false;
	    	
	    //If you swap out the asset .swf you will need to update these constants as appropriate so the gauge can measure correctly.
	    public static const FACE_DIAMETER:int=146;
	    public static const BASE_DIAMETER:int=150;
	    public static const	TICKS_DIAMETER:int=150;
	    public static const POINTER_WIDTH:int=11;
	    public static const POINTER_HEIGHT:int=88;
	    public static const POINTER_ORIGIN_SCALE:Number=0.68;
	    public static const BEZEL_DIAMETER:int=148;
	    public static const NUB_DIAMTER:int=17;
	    public static const REFLECTION_WIDTH:int=117;
	    public static const REFLECTION_HEIGHT:int=85;
	    public static const REFLECTION_OFFSET:int=9;
	    public static const MINMAX_Y:int=105;
	    public static const VALUE_Y:int=115;
	    
   		
   		[Bindable][Inspectable]
   		public var valueFormatter:Formatter=null;
	    
	    [Bindable][Inspectable]
     	public var positiveMaxValue:Boolean=true;
     	
     	     /**
     * Setters and Getters
     */
      
      	private var _showValue:Boolean=true;
      	private var _showMinMax:Boolean=true;
      	private var _glareAlpha:Number=1;
      	
      	public function set glareAlpha(param:Number):void {	_glareAlpha=param; }
      	
      	public function set showMinMax(param:Boolean):void { _showMinMax=param; }
      	
      	public function set showValue(param:Boolean):void {
      		_showValue=param;
      		this.invalidateDisplayList();
      	}
      	
      	public function get showValue():Boolean { return _showValue; }
      
     	 public function set minValue(param:Number):void {
	     	   if(positiveMaxValue)
	     	   		if (param<_maxValue) _minValue=param;
	     	   else
	     	   		if (param>_maxValue) _minValue=param; 	
	     	   //Reset Pointer
	     	   	setPointer();
	     }
	
	     public function set maxValue(param:Number):void {
	     	   if(positiveMaxValue)
	     	   		if (param>_minValue) _maxValue=param;
	     	   else
	     	   		if (param<_minValue) _maxValue=param;  
	     	   //Reset Pointer
	     	 	setPointer();
	     }
	    
	     [Bindable][Inspectable]
	     public function get maxValue():Number { return _maxValue; }
	     
	     [Bindable][Inspectable]
	     public function get minValue():Number { return _minValue; }		
	    
	    
	     [Bindable][Inspectable]
	     public function get value():Number { return this._value; }
	     
		
	     public function set value(param:Number):void
	     {
				this._value=param;
				setValueLabel();
				setPointer();
	     }
	     
	     private function setPointer():void 
	     {
	     	if(this._pointer!=null) {
				rotatePointer();
			}
			this.dispatchEvent(new Event("change"));
	     }
		
		override public function set height(value:Number):void {
			diameter=value;
		}
		
		override public function set width(value:Number):void {
			diameter=value;
		}
		
		public function set diameter(value:Number):void {
			super.width=value;
			super.height=value;
		}
		
		[Bindable]
		public function get diameter():Number {
			return this.width;
		}
		
	    // Define a static variable for initializing the style property.
        private static var classConstructed:Boolean = classConstruct();
    
        // Define a static method to initialize the style.
        private static function classConstruct():Boolean {
        
        	
            if (!StyleManager.getStyleDeclaration("Gauge"))  {
                // If Gauge has no CSS definition, 
                // create one and set the default value.
                var newStyleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("faceColor", 0x777777);
                newStyleDeclaration.setStyle("faceShadowColor", 0x777777);
                newStyleDeclaration.setStyle("bezelColor", 0x777777);
                newStyleDeclaration.setStyle("centerColor", 0x777777);
                newStyleDeclaration.setStyle("pointerColor",0x777777);
                newStyleDeclaration.setStyle("ticksColor",0xFFFFFF);
                newStyleDeclaration.setStyle("alertRatios",[]);
                newStyleDeclaration.setStyle("alertColors",[]);
                newStyleDeclaration.setStyle("alertAlphas",[]);
                newStyleDeclaration.setStyle("fontColor",0);
              
             // The line below has a performace hit we want to avoid for now
                StyleManager.setStyleDeclaration("Gauge",newStyleDeclaration, false);
            }
            
            return true;
        }


		// Override styleChanged() to detect changes in your new style.
        override public function styleChanged(styleProp:String):void {

            super.styleChanged(styleProp);

            // Check to see if style changed. 
            if (styleProp=="faceColor") 
            {
                _faceColorChanged=true; 
                return;
            }
            else if (styleProp=="faceShadowColor"){
            	_faceShadowColorChanged=true; 
                return;
            }
             else if (styleProp=="bezelColor"){
            	_bezelColorChanged=true; 
                return;
            }
             else if (styleProp=="centerColor"){
            	_centerColorChanged=true; 
                return;
            }
             else if (styleProp=="pointerColor"){
            	_pointerColorChanged=true; 
                return;
            }
             else if (styleProp=="ticksColor"){
                return;
            }
            
            invalidateDisplayList();
        }

		
		override protected function createChildren():void {
    		super.createChildren();
    
    		_dropShadowFilter = new DropShadowFilter(2,45,0,.3,2,2,1,1);
    		
    		_face = new Image();
    		_face.source=_faceSymbol;
    		    		    		
    		_faceShadow = new Image();
    		_faceShadow.source=_faceShadowSymbol;
    		
    		_alerts=new UIComponent();
    		
    		_ticks=new UIComponent();
    		
    		_pointer=new Image();
    		_pointer.source=_pointerSymbol;
    		_pointer.filters=[_dropShadowFilter];
    		
    		_bezel=new Image();
    		_bezel.source=_bezelSymbol;
    		
    		_center=new Image();
    		_center.source=_centerSymbol;
    		_center.filters=[_dropShadowFilter];
    		  		
    		_reflection=new Image();
    		_reflection.source=_reflectionSymbol;
    		
    		_minRadio=new RadioButton();
       		_minRadio.labelPlacement="bottom";
       		_minRadio.groupName="min";
       		_minRadio.addEventListener("click",onMinRadioClicked);
       		
    		_maxRadio=new RadioButton();
    		_maxRadio.labelPlacement="bottom";
    		_maxRadio.groupName="max";
    		_maxRadio.addEventListener("click",onMaxRadioClicked);
    		
    		_minLabel=new Label();
    		_minLabel.setStyle("textAlign","right");
    		_minLabel.visible=false;
    		
    		_maxLabel=new Label();
    		_maxLabel.setStyle("textAlign","left");
    		_maxLabel.visible=false;
    		
    		
    		_valueLabel=new Label();    
		 	_valueLabel.setStyle("textAlign","center");		
    		
    		addChild(_face);
    		addChild(_faceShadow);
    		addChild(_alerts);
    		addChild(_ticks);
    		addChild(_pointer);
    		addChild(_bezel);
    		addChild(_center);
    		addChild(_reflection);
    		addChild(_minRadio);
    		addChild(_maxRadio);
    		addChild(_valueLabel);
    		addChild(_minLabel);
    		addChild(_maxLabel);

		}
		
		// Implement the commitProperties() method. 
		override protected function commitProperties():void {
		    super.commitProperties();
		}

		override protected function measure():void {
			super.measure();
			
			 
			 _diameter=this.width;
			 var scale:Number = _diameter/Gauge.BASE_DIAMETER
			  
			//this is where we need to figure out appropriate heights of components
		 	_face.width=Gauge.FACE_DIAMETER * scale;
		 	_face.height=_face.width;
		 	_face.x=(_diameter-_face.width)/2;
		 	_face.y=_face.x;
		 	
		 	_faceShadow.width=_face.width;
		 	_faceShadow.height=_face.height;
		 	_faceShadow.y=_face.y;
		 	_faceShadow.x=_face.x;
		 	
		 	_ticks.height=Gauge.TICKS_DIAMETER*scale;
		 	_ticks.width=_ticks.height;
		 	_ticks.x=(_diameter - _ticks.width)/2;
		 	_ticks.y=_ticks.x;
		 	
		 	_pointer.rotation=0;
		 	_pointer.height=Gauge.POINTER_HEIGHT*scale;
		 	_pointer.width=Gauge.POINTER_WIDTH*scale;
		 	_pointer.x=(_diameter-_pointer.width)/2;
		 	_pointer.y=(_diameter/2)-(_pointer.height * Gauge.POINTER_ORIGIN_SCALE);
		 	
		 	_bezel.width=Gauge.BEZEL_DIAMETER*scale;
		 	_bezel.height=_bezel.width;
		 	_bezel.x=(_diameter-_bezel.width)/2;
		 	_bezel.y=_bezel.x;
		 	
		 	_center.width=Gauge.NUB_DIAMTER*scale;
		 	_center.height=_center.width;
		 	_center.x=(_diameter-_center.width)/2;
		 	_center.y=_center.x;
		 	
		 	_reflection.width=Gauge.REFLECTION_WIDTH*scale;
		 	_reflection.height=Gauge.REFLECTION_HEIGHT*scale;
		 	_reflection.x=Gauge.REFLECTION_OFFSET*scale;
		 	_reflection.y=_reflection.x;
		 	
		 	_minRadio.scaleX=scale;
		 	_minRadio.scaleY=scale;
		 	_minRadio.y=Gauge.MINMAX_Y*scale;
		 	_minRadio.x=(_diameter/2)*.45
		 	_minRadio.visible=_showMinMax;
		 	
			_maxRadio.scaleX=scale;
		 	_maxRadio.scaleY=scale;
		 	_maxRadio.y=Gauge.MINMAX_Y*scale;
		 	_maxRadio.x=(_diameter/2)+((_diameter/2)*.36);
		 	_maxRadio.visible=_showMinMax;
		 	
		 	_dropShadowFilter.distance=2*scale;
		 	_dropShadowFilter.blurX=2*scale;
		 	_dropShadowFilter.blurY=2*scale;
		 	
		 	_center.filters=[_dropShadowFilter];
		 	_pointer.filters=[_dropShadowFilter];
		 	
		 	_valueLabel.y=Gauge.VALUE_Y*scale;
		 	_valueLabel.width=_diameter;
		 	_valueLabel.height=55*scale;
		 	
		 	_minLabel.width=_diameter;
		 	_minLabel.height=25*scale;
		 	_minLabel.setStyle("fontSize",14*scale);
		 	_minLabel.x=_minRadio.x-_minLabel.width-_minRadio.width;
		 	_minLabel.y=_minRadio.y + _minRadio.height/2 + (scale);
		 
		 	
		 	_maxLabel.width=_diameter;
		 	_maxLabel.height=25*scale;
		 	_maxLabel.setStyle("fontSize",14*scale);
		 	_maxLabel.x=_maxRadio.x+(7*scale);
		 	_maxLabel.y=_maxRadio.y + _maxRadio.height/2 + (scale);
		 	
		}
	
		private function setValueLabel():void {
			if(valueFormatter) {
            	_valueLabel.text=valueFormatter.format(value);
            	_minLabel.text=valueFormatter.format(minValue);
            	_maxLabel.text=valueFormatter.format(maxValue);
            }
            else {
            	_valueLabel.text=value.toString();
            	_minLabel.text=minValue.toString();
            	_maxLabel.text=maxValue.toString();
            }
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {

            super.updateDisplayList(unscaledWidth, unscaledHeight);
           
           setValueLabel();
            
            var fontColor:Number = getStyle("fontColor");
            	
            _valueLabel.setStyle("fontSize",getStyle("fontSize"));
            _valueLabel.setStyle("color",fontColor);
            _valueLabel.setStyle("fontFamily",getStyle("fontFamily"));
            _valueLabel.setStyle("fontStyle",getStyle("fontStyle")); 
          	_valueLabel.setStyle("fontWeight",getStyle("fontWeight"));
            _valueLabel.setStyle("fontSharpness",getStyle("fontSharpness"));
            _valueLabel.setStyle("fontAntiAliasType",getStyle("fontAntiAliasType"));
            _valueLabel.visible=this._showValue;
            
            _reflection.alpha=_glareAlpha;
           
            _minLabel.setStyle("color",fontColor);
            _maxLabel.setStyle("color",fontColor);
            
            _maxRadio.visible=_showMinMax;
            _minRadio.visible=_showMinMax;
            
         //   _valueLabel.styleName=getStyle("fontStyle");
            
            
			measure();
            this.clipContent=false;
            drawTicks();
            drawAlerts();
            
             // Check to see if style changed. 
           if (_faceColorChanged==true) 
            {
            	transformColor(_face,getStyle("faceColor"));
            	_faceColorChanged=false;
            }

            if (_faceShadowColorChanged==true) 
            {
            	transformColor(_faceShadow,getStyle("faceShadowColor"));
            	_faceShadowColorChanged=false;
            }
 			if (_bezelColorChanged==true) 
            {
            	transformColor(_bezel,getStyle("bezelColor"));
            	_bezelColorChanged=false;
            }
			if (_centerColorChanged==true) 
            {
            	transformColor(_center,getStyle("centerColor"));
            	_centerColorChanged=false;
            }
            if (_pointerColorChanged==true) 
            {
            	transformColor(_pointer,getStyle("pointerColor"));
            	_pointerColorChanged=false;
            }
           
            rotatePointer(false);
  		}
  		
  	     private function calculatePointerAngle():Number {
			//rotate appropriate angle
		    var delta:Number;
			var ratio:Number;
			var angle:Number;
			if (this.positiveMaxValue)
				delta=this._maxValue-this._minValue;
			else
				delta=this._minValue-this._maxValue;
				
			ratio=_value/_maxValue;
			//Check to see if we exceed boundary conditions
			if (this._value> this._maxValue) ratio=1;
			if (this._value<this._minValue) ratio=0;
			angle=(241*ratio)-121

			return angle;
		}
  		
  		private function transformColor(obj:Object,color:Number):void {
	     	if (obj==null) return;
	     	var c:ColorTransform=new ColorTransform();
	     	c.color=color; 
	   		
	    	var ct:ColorTransform;
	    	
	    	ct=new ColorTransform(1,1,1,1,c.redOffset-127,c.greenOffset-127,c.blueOffset-127,0);
	     	obj.transform.colorTransform=ct;
     
     	}
  		
	  	/**
	  	 * This function draws the tick marks around the gauge
	  	 */
	  	  private function drawTicks():void
	      {  	
	        	
	      	var fCenterX:Number=(_ticks.width)/2;
	      	var fCenterY:Number=fCenterX;
	      	var fRadius:Number=fCenterX;
	      	
	      	var tickColor:Number=getStyle("ticksColor"); 
	       
	      	 _ticks.graphics.clear();
	       	_ticks.graphics.lineStyle(1,tickColor,1,true);
	      	
	      	for(var i:int=0;i<60;i++)
	        {
	        	if((i<=50 && i >=10))
	        	{
		            if (i%5==0 )
		            // Draw 5 minute ticks
		            {
		            	_ticks.graphics.lineStyle(1,tickColor,1,false,LineScaleMode.NONE,CapsStyle.NONE);
		            	_ticks.graphics.moveTo(fCenterX + fRadius/1.27*Math.sin(i*6*Math.PI/180),fCenterY + fRadius/1.25*Math.cos(i*6*Math.PI/180))
		            	_ticks.graphics.lineTo(fCenterX + fRadius/1.55*Math.sin(i*6*Math.PI/180),fCenterY + fRadius/1.55*Math.cos(i*6*Math.PI/180))
		
		            }
		            else // draw 1 minute ticks
		            {
		            	_ticks.graphics.lineStyle(1,tickColor,1,false,LineScaleMode.NONE,CapsStyle.NONE)
		                _ticks.graphics.moveTo(fCenterX + fRadius/1.27*Math.sin(i*6*Math.PI/180),fCenterY + fRadius/1.25*Math.cos(i*6*Math.PI/180))
						_ticks.graphics.lineTo(fCenterX + fRadius/1.40*Math.sin(i*6*Math.PI/180),fCenterY + fRadius/1.40*Math.cos(i*6*Math.PI/180))
		   				
		            }
		        }
	        }   	
      	}
      	
       private function rotatePointer(useEffect:Boolean=true):void  {
       		var angle:Number = this.calculatePointerAngle();
		   	var scale:Number=_diameter/Gauge.BASE_DIAMETER;
	     
	     	//If we are still rotating we need to end current rotation effects.
	    	if (this._rotating)
	     	{
	     		//trace("Prematurely ending rotation " + this.id + " angle=" + angle.toString()+ "...");
	     		for(var i:int=0;i<this._effectInstances.length;i++)
	     		{
	     			var e:Effect = _effectInstances[i];
	     			e.end();	
	     		}
	    		
	    		//Need to reset pointer as we are not sure what state it is in when the effects got interupted
	    		_pointer.rotation=0;
	    		measure();
		      
	     	}  	
	     	     	
	     	this._effectInstances=new Array();
	     
	     	var originX:Number=_pointer.width/2;
	     	var originY:Number=_pointer.height*Gauge.POINTER_ORIGIN_SCALE;
	
	     	this._rotating=true;
	
	     	var r:Rotate=new Rotate(_pointer);
	     	var r1:Rotate=new Rotate(_pointer);
	     	var r2:Rotate=new Rotate(_pointer);
	     	var r3:Rotate=new Rotate(_pointer); 
	     	var r4:Rotate=new Rotate(_pointer);
	     	var r5:Rotate=new Rotate(_pointer);
	      	
	     	var s:Sequence=new Sequence();
	 	     	
	     	var duration:int=350;
	     	
	     	r.originX=originX;
	     	r.originY=originY;   	
	     	r.angleFrom=_pointer.rotation;
	      	r.angleTo=angle+20;
	     	r.duration=duration*.7;
	
	     	
	     	r1.originX=r.originX;
	     	r1.originY=r.originY;
	     	r1.angleFrom=angle+20;
	     	r1.angleTo=angle-10;
	     	r1.duration=duration;
	     	
	     	r2.originX=r.originX;
	     	r2.originY=r.originY;
	     	r2.angleFrom=angle-10;
	     	r2.angleTo=angle+5;
	     	r2.duration=duration;
	     	
	     	r3.originX=r.originX;
	     	r3.originY=r.originY;
	     	r3.angleFrom=angle+5;
	     	r3.angleTo=angle-3;
	     	r3.duration=duration;
	
			r4.originX=r.originX;
	     	r4.originY=r.originY;
	     	r4.angleFrom=angle-3;
	     	r4.angleTo=angle+1;
	     	r4.duration=duration;
	     	
	     	r5.originX=r.originX;
	     	r5.originY=r.originY;
	     	r5.angleFrom=angle+1;
	     	r5.angleTo=angle;
	     	r5.duration=duration;
	
			if (useEffect) {	
				  	s.addChild(r);
			     	s.addChild(r1);
			     	s.addChild(r2);
			     	s.addChild(r3);
			     	s.addChild(r4);
			}
	   
	     	s.addChild(r5);
	     	
	     	if (useEffect) {	
		     	this._effectInstances.push(r);
		     	this._effectInstances.push(r1);
		     	this._effectInstances.push(r2);
		     	this._effectInstances.push(r3);
		     	this._effectInstances.push(r4);
		     }
	     	this._effectInstances.push(r5);
	     
     	
		
     	s.addEventListener("effectEnd",resetPointer);
     	s.play([_pointer]);
     
     }

     private function resetPointer(e:Event):void    {
     	//trace("... Rotate ending " + this.id + " rotation ");
     	
     	this._rotating=false;
     	
     }
     
      private function drawAlerts():void
      {

 		var alertLevels:Array=getStyle("alertRatios");
 		var alertColors:Array=getStyle("alertColors");
 		var alertAlphas:Array=getStyle("alertAlphas");
 		
 		if(!alertLevels || !alertColors  || !alertAlphas) return;
 		
      	this._alerts.graphics.clear();
  
      	
      	var alertArray:Array;
      	
      	var delta:Number;
		var ratio:Number;
		var angle:Number;

		
		if (this.positiveMaxValue)
			delta=this._maxValue-this._minValue;
		else
			delta=this._minValue-this._maxValue;
			
		ratio=_value/_maxValue;
		
		
      	
		var lastAngle:Number=210;
		var lastAlert:Number=0;
		
		for(var i:int=0;i<alertLevels.length;i++)
		{

			angle=(-240 * ((alertLevels[i]-lastAlert)/_maxValue));
			GraphicsUtil.drawArc(_alerts.graphics,lastAngle,angle,alertColors[i],alertAlphas[i],_diameter);
			lastAngle=lastAngle+angle;
			lastAlert=alertLevels[i];
			
		}
      }
     
      private function onMinRadioClicked(e:Event):void {
      		
      		if ((_minRadio.selected) && (_minLabel.visible)) 
		     {
		     	_minRadio.selected=false;
		     	_minLabel.visible=false;
		     }
		     else {
		     	_minLabel.visible=true;
		     }
      	}
      	
      	private function onMaxRadioClicked(e:Event):void {
      		
      		if ((_maxRadio.selected) && (_maxLabel.visible)) 
		     {
		     	_maxRadio.selected=false;
		     	_maxLabel.visible=false;
		     }
		     else {
		     	_maxLabel.visible=true;
		     }
      	}
	}
}