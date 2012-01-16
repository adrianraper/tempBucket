package com.clarityenglish.ielts.view.account {
	import com.clarityenglish.bento.view.base.BentoView;
	import com.clarityenglish.common.vo.manageable.User;
	
	import flash.events.MouseEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	import mx.controls.Alert;
	import mx.controls.SWFLoader;
	
	import org.osflash.signals.Signal;
	
	import spark.components.Button;
	import spark.components.TextInput;
	
	public class AccountView extends BentoView {
				
		[SkinPart(required="true")]
		public var currentPassword:TextInput;
		
		[SkinPart(required="true")]
		public var newPassword:TextInput;
		
		[SkinPart(required="true")]
		public var confirmPassword:TextInput;
		
		[SkinPart(required="true")]
		public var examDate:TextInput;
		
		[SkinPart(required="true")]
		public var examTime:TextInput;
		
		[SkinPart(required="true")]
		public var saveChangesButton:Button;

		[SkinPart]
		public var IELTSApp1:SWFLoader;

		public var updateUser:Signal = new Signal(Object);
		
		[Bindable]
		public var userDetails:User;
		
		public function AccountView() {
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			
			switch (instance) {
				case saveChangesButton:
					instance.addEventListener(MouseEvent.CLICK, onUpdateButtonClick);
					break;
				
				case IELTSApp1:
					var context:LoaderContext = new LoaderContext();
					
					/* Specify the current application's security domain. */
					//context.securityDomain = SecurityDomain.currentDomain;
					
					/* Specify a new ApplicationDomain, which loads the sub-app into a peer ApplicationDomain. */
					context.applicationDomain = new ApplicationDomain();
					
					instance.loaderContext = context;                 
					instance.source = "http://dock.projectbench/Software/Widget/IELTS/bin/BandScoreCalculator-200.swf?widgetdatawidth=200&widgetdataheight=300&widgetdatalanguage=EN&widgetdatacountry=none&widgetdatabclogo=true";
					break
			}
		}
		
		/**
		 * Populate the form with existing details 
		 * 
		 */
		public function showUserDetails(user:User):void {
			// Split into separate date and time
			if (user.birthday) {
				examDate.text = user.birthday;
			} else if (user.expiryDate) {
				examDate.text = user.expiryDate.substr(0, 10);
				examTime.text = user.expiryDate.substr(11, 5);
			} else {
				examDate.text = "2012-04-01";
				examTime.text = "09:00";				
			}
		}
		
		/**
		 * The user has clicked the update button
		 *
		 * @param event
		 */
		protected function onUpdateButtonClick(event:MouseEvent):void {
			// Any validation to do here?
			if (newPassword.text != confirmPassword.text) {
				showUpdateError("The two new passwords you typed must be the same.");
			} else {
				// Trigger the update command. Use an Event or a Signal?
				// Do I really need to pass anything at all since the mediator can get it all anyway?
				// Or I could use a form and pass that?
				var newUserDetails:Object = new Object();
				newUserDetails.currentPassword = currentPassword.text;
				newUserDetails.password = newPassword.text;
				newUserDetails.examJustDate = examDate.text;
				newUserDetails.examJustTime = examTime.text;
				updateUser.dispatch(newUserDetails);
			}
		}
		
		public function showUpdateError(msg:String = ""):void {
			if (msg) {
				Alert.show(msg, "Update problem");
			} else {
				Alert.show("Sorry, these details can't be updated.", "Update problem");				
			}
		}
		public function showUpdateSuccess(msg:String = ""):void {
			if (msg) {
				Alert.show(msg, "Update success");
			} else {
				Alert.show("Your details have been changed.", "Update");				
			}
		}
		
	}
	
}