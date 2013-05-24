package com.clarityenglish.rotterdam.view.course.ui
{
	import spark.components.supportClasses.ButtonBase;
	
	public class PublishButton extends ButtonBase
	{
		public function PublishButton()
		{
			super();
		}
		
		[Bindable]
		public var text:String;
	}
}