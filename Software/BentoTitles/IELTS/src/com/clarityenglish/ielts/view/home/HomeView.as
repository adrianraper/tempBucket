package com.clarityenglish.ielts.view.home {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.bento.vo.Href;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.textLayout.vo.XHTML;
	import com.anychart.AnyChartFlex;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.TabBar;
	
	public class HomeView extends BentoView {

		[SkinPart(required="true")]
		public var userNameLabel:Label;

		[SkinPart(required="true")]
		public var readingCourse:Button;
		
		[SkinPart(required="true")]
		public var writingCourse:Button;
		
		[SkinPart(required="true")]
		public var speakingCourse:Button;
		
		[SkinPart(required="true")]
		public var listeningCourse:Button;
		
		[SkinPart(required="true")]
		public var examTipsCourse:Button;

		[SkinPart(required="true")]
		public var coveragePieChart:AnyChartFlex;
		
		public var _fullChartXML:XML;
		public var courseSelect:Signal = new Signal(XML);
		
		// This is the slurping method for getting data from view to skin. 
		// Elsewhere we are doing injection and it might be neater to stick to that.
		[Bindable]
		public var _user:User;
		public function set user(value:User):void {
			_user = value;
			// Also put some parts of this information into the skin
			//userNameLabel.text = _user.fullName;
		}

		public function setSummaryDataProvider(mySummary:Array, everyoneSummary:Array):void {
			//coveragePieChart.dataProvider = _dataProvider;
			coveragePieChart.anychartXML = _fullChartXML;
		}

		protected override function updateViewFromXHTML(xhtml:XHTML):void {
			super.updateViewFromXHTML(xhtml);
			
			// Populate the buttons with the course names
			//courseTabBar.dataProvider = new XMLListCollection(menu..course);
			
			// Get the coverage overview from the backside
			// This is probably a 'quick' call in usage stats mode rather than full progress
			
		}
		protected override function commitProperties():void {
			super.commitProperties();
		}		
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			//trace("partAdded in HomeView for " + partName);
			switch (instance) {
				case readingCourse:
				case writingCourse:
				case speakingCourse:
				case listeningCourse:
				case examTipsCourse:
					instance.addEventListener(MouseEvent.CLICK, onCourseClick);
					break;
				case coveragePieChart:
					// Initial settings for the chart
					initPieChart();
					break;
			}
		}
		/**
		 * The user has clicked a course button
		 * 
		 * @param event
		 */
		protected function onCourseClick(event:MouseEvent):void {
			var matchingCourses:XMLList = menu.course.(@caption == event.target.label);
			
			if (matchingCourses.length() == 0) {
				log.error("Unable to find a course with caption {0}", event.target.label);
			} else {
				courseSelect.dispatch(matchingCourses[0] as XML);
			}
		}
		/**
		 * Many settings for the pie chart are completely static and can be initialised here 
		 * 
		 */
		private function initPieChart():void {
			// Purely a charting test
			_fullChartXML=<anychart>
							  <charts>
								<chart plot_type="CategorizedVertical">
								  <data>
									<series name="Product Sales" type="Bar">
									  <point name="2004" y="63716" />
									  <point name="2005" y="72163" />
									  <point name="2006" y="94866" />
									  <point name="2007" y="56866" />
									  <point name="2008" y="19000" />
									</series>
								  </data>
								  <chart_settings>
									  <title>
										  <text>ACME Corp. Sales</text>
									  </title>
									  <axes>
										  <x_axis>
											  <title>
												  <text>Year</text>
											  </title>
										  </x_axis>
										  <y_axis>
											  <title>
												  <text>Sales (USD)</text>
											  </title>
										  </y_axis>
									  </axes>
								  </chart_settings>
								</chart>
							  </charts>
							</anychart>;
		}

	}
}