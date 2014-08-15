////////////////////////////////////////////////////////////////////////////////
//
// ADOBE SYSTEMS INCORPORATED
// Copyright 2008-2010 Adobe Systems Incorporated
// All Rights Reserved.
//
// NOTICE: Adobe permits you to use, modify, and distribute this file
// in accordance with the terms of the license agreement accompanying it.
//
//////////////////////////////////////////////////////////////////////////////////
//  
// WARNING: THIS FILE IS GENERATED BY A SCRIPT.  DO NOT EDIT
//  
//================================================================================
		/**
		 * TabStopFormat:
		 * The position of the tab stop, in pixels, relative to the start edge of the column.
		 * <p>Legal values are numbers from 0 to 10000 and FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of 0.</p>
		 * @see FormatValue#INHERIT
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get position():*
		{
			return _tabStopFormat ? _tabStopFormat.position : undefined;
		}
		public function set position(positionValue:*):void
		{
			writableTabStopFormat().position = positionValue;
			tabStopFormatChanged();
		}

		[Inspectable(enumeration="start,center,end,decimal,inherit")]
		/**
		 * TabStopFormat:
		 * The tab alignment for this tab stop. 
		 * <p>Legal values are TabAlignment.START, TabAlignment.CENTER, TabAlignment.END, TabAlignment.DECIMAL, FormatValue.INHERIT.</p>
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of TabAlignment.START.</p>
		 * @see FormatValue#INHERIT
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.TabAlignment
		 */
		public function get alignment():*
		{
			return _tabStopFormat ? _tabStopFormat.alignment : undefined;
		}
		public function set alignment(alignmentValue:*):void
		{
			writableTabStopFormat().alignment = alignmentValue;
			tabStopFormatChanged();
		}

		/**
		 * TabStopFormat:
		 * The alignment token to be used if the alignment is DECIMAL.
		 * <p>Default value is undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have a value of null.</p>
		 * 
		 * @throws RangeError when set value is not within range for this property
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get decimalAlignmentToken():*
		{
			return _tabStopFormat ? _tabStopFormat.decimalAlignmentToken : undefined;
		}
		public function set decimalAlignmentToken(decimalAlignmentTokenValue:*):void
		{
			writableTabStopFormat().decimalAlignmentToken = decimalAlignmentTokenValue;
			tabStopFormatChanged();
		}
