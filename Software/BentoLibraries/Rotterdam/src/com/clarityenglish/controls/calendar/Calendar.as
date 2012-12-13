package com.clarityenglish.controls.calendar {
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.formatters.DateFormatter;
	
	import spark.components.Button;
	import spark.components.DataGroup;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	public class Calendar extends SkinnableComponent {
		
		[SkinPart(required="true")]
		public var daysDataGroup:DataGroup;
		
		[SkinPart(required="true")]
		public var dataGroup:DataGroup;
		
		[SkinPart(required="true")]
		public var nextMonthButton:Button;
		
		[SkinPart(required="true")]
		public var monthLabel:Label;
		
		[SkinPart(required="true")]
		public var prevMonthButton:Button;
		
		private var _firstOfMonth:Date;
		private var _firstOfMonthChanged:Boolean;
		
		private var _endOfMonth:Date;
		
		private var _dataProvider:ListCollectionView;
		private var _dataProviderChanged:Boolean;
		
		private var dateFormatter:DateFormatter;
		
		public function Calendar() {
			super();
			
			dateFormatter = new DateFormatter();
			dateFormatter.formatString = "MMMM YYYY";
		}
		
		public function set firstOfMonth(value:Date):void {
			_firstOfMonth = new Date(value.fullYear, value.month);
			
			_endOfMonth = new Date(firstOfMonth);
			_endOfMonth.month++;
			_endOfMonth.seconds--;
			
			_firstOfMonthChanged = true;
			invalidateProperties();
		}
		
		public function get firstOfMonth():Date {
			return _firstOfMonth;
		}
		
		public function get endOfMonth():Date {
			return _endOfMonth;
		}
		
		public function set dataProvider(value:ListCollectionView):void {
			_dataProvider = value;
			_dataProviderChanged = true;
			invalidateProperties();
		}
		
		public function get dataProvider():ListCollectionView {
			return _dataProvider;
		}
		
		protected override function commitProperties():void {
			super.commitProperties();
			
			if (_firstOfMonthChanged || _dataProviderChanged) {
				// Set the label in the month chooser
				monthLabel.text = dateFormatter.format(firstOfMonth);
				
				// Figure out the date in the top left of the calendar
				var topLeftDate:Date = new Date(firstOfMonth);
				topLeftDate.date -= firstOfMonth.day;
				
				// Build all the dates for the calendar
				var data:Array = [];
				for (var n:uint = 0; n < 7 * 6; n++) {
					var date:Date = new Date(topLeftDate);
					date.date += n;
					
					// If the dataProvider contains an entry for this date then include it in the data
					var labels:Array = [];
					if (dataProvider) {
						for (var q:uint = 0; q < dataProvider.length; q++) {
							var entry:Object = dataProvider.getItemAt(q);
							if (entry.date.fullYear == date.fullYear && entry.date.month == date.month && entry.date.date == date.date) {
								labels.push(entry.label);
							}
						}
					}
					
					data.push({ date: date, labels: labels });
				}
				
				dataGroup.dataProvider = new ArrayCollection(data);
				
				_firstOfMonthChanged = _dataProviderChanged = false;
			}
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case daysDataGroup:
					var days:Array = [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ];
					daysDataGroup.dataProvider = new ArrayCollection(days);
					break;
				case nextMonthButton:
					nextMonthButton.addEventListener(MouseEvent.CLICK, onNextMonth);
					break;
				case prevMonthButton:
					prevMonthButton.addEventListener(MouseEvent.CLICK, onPrevMonth);
					break;
			}
		}
		
		protected function onNextMonth(event:MouseEvent):void {
			if (firstOfMonth) firstOfMonth = new Date(firstOfMonth.fullYear, firstOfMonth.month + 1);
		}
		
		protected function onPrevMonth(event:MouseEvent):void {
			if (firstOfMonth) firstOfMonth = new Date(firstOfMonth.fullYear, firstOfMonth.month - 1);
		}
		
	}
}
