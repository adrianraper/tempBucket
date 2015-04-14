package com.clarityenglish.resultsmanager.view.shared.ui {
	import com.clarityenglish.common.vo.content.Course;
	import com.clarityenglish.common.vo.content.Exercise;
	import com.clarityenglish.common.vo.content.Title;
	import com.clarityenglish.common.vo.content.Unit;
	import com.clarityenglish.common.vo.manageable.Group;
	import com.clarityenglish.common.vo.manageable.User;
	import com.clarityenglish.resultsmanager.Constants;
	import com.clarityenglish.resultsmanager.view.shared.interfaces.ICheckBoxRendererProvider;
	import com.clarityenglish.utils.TraceUtils;
	
	import flash.events.MouseEvent;
	
	import mx.controls.CheckBox;
	import mx.controls.Image;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	import mx.core.ClassFactory;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.davekeen.controls.SmoothImage;
	import org.davekeen.utils.ClassUtils;
	
	/**
	 * ...
	 * @author Dave Keen
	 */
	public class ReportableTreeItemRenderer extends TreeItemRenderer {
		
		private static const OFF:String = "off";
		private static const ON:String = "on";
		private static const TRI:String = "tri";
		private static const EMPTY:String = "empty";
		private static const DISABLE:String = "disable";
		
		[Embed(source="/../assets/group_icon.swf")]
		private var groupIcon:Class;
		
		[Embed(source="/../assets/hiddengroup_icon.swf")]
		private var hiddenGroupIcon:Class;
		
		[Embed(source="/../assets/admin_icon.swf")]
		private var adminIcon:Class;
		
		[Embed(source="/../assets/teacher_icon.swf")]
		private var teacherIcon:Class;
		
		[Embed(source="/../assets/reporter_icon.swf")]
		private var reporterIcon:Class;
		
		[Embed(source="/../assets/author_icon.swf")]
		private var authorIcon:Class;
		
		[Embed(source="/../assets/student_icon.swf")]
		private var studentIcon:Class;
		
		[Embed(source="/../assets/expired_icon.swf")]
		private var expiredIcon:Class;
		
		[Embed(source="/../assets/normal_exercise_icon.swf")]
		private var normalExerciseIcon:Class
		
		[Embed(source="/../assets/protected_exercise_icon.swf")]
		private var protectedExerciseIcon:Class
		
		[Embed(source="/../assets/edited_exercise_icon.swf")]
		private var editedExerciseIcon:Class
		
		[Embed(source="/../assets/moved_exercise_icon.swf")]
		private var movedExerciseIcon:Class
		
		[Embed(source="/../assets/added_exercise_icon.swf")]
		private var addedExerciseIcon:Class
		
		public var useCheckBox:Boolean;
		public var triStateEnabled:Boolean;
		public var checkBoxRendererProvider:ICheckBoxRendererProvider;
		//public var enabledCheckBoxToolTip:String;
		//public var disabledCheckBoxToolTip:String;
		public var checkBoxToolTips:Object;
		public var useLargeIcons:Boolean;
		
		private var image:Image;
		private var expiredImage:Image;
		
		private var checkBox:CheckBox;
		
		private var enableEdit:Boolean;
		
		public function ReportableTreeItemRenderer() {
			super();
		}
		
		/**
		 * Return a ReportableTreeItemRenderer ClassFactory for use as an itemRenderer in a tree
		 * 
		 * @param	useCheckBox Whether or not this is a checkbox tree
		 * @param	checkBoxRendererProvider A class implementing ICheckBoxRendererProvider used to implement the checkbox
		 * @param	triStateEnabled Automatically draw tri-state checkboxes
		 * @param	checkBoxToolTips Strings for the different states of the checkBox
		 * @param	largeIcons Boolean used to indicate if the top level icon should be large
		 * 
		 * @return
		 */
		public static function getRendererFactory(useCheckBox:Boolean = false, checkBoxRendererProvider:ICheckBoxRendererProvider = null, 
											triStateEnabled:Boolean = false, checkBoxToolTips:Object = undefined, useLargeIcons:Boolean = true):ClassFactory {
			var reportableClassFactory:ClassFactory = new ClassFactory();
			reportableClassFactory.properties = { useCheckBox: useCheckBox, 
												  checkBoxRendererProvider: checkBoxRendererProvider, 
												  triStateEnabled: triStateEnabled,
												  //enabledCheckBoxToolTip: enabledToolTip,
												  //disabledCheckBoxToolTip: disabledToolTip
												  checkBoxToolTips: checkBoxToolTips,
												  useLargeIcons: useLargeIcons
												  };
			reportableClassFactory.generator = ReportableTreeItemRenderer;
			
			return reportableClassFactory;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			image = new Image();
			image.setStyle("verticalAlign", "middle");
			
			expiredImage = new SmoothImage();
			//expiredImage.setStyle("verticalAlign", "middle");
			expiredImage.setStyle("verticalAlign", "bottom");
			expiredImage.source = expiredIcon;
			expiredImage.alpha = 0.8;
			//expiredImage.width = expiredImage.height = 16;
			expiredImage.width = expiredImage.height = 12;
			expiredImage.y = 4;
			
			addChild(image);
			addChild(expiredImage);
			
			if (!checkBox) {
				checkBox = new CheckBox();
				checkBox.styleName = this;
				checkBox.x = 0;
				checkBox.y = 9;
				checkBox.addEventListener(MouseEvent.CLICK, onCheckBoxClick);
				// Just in case you passed an undefined toolTip object
				if (!checkBoxToolTips) checkBoxToolTips = new Object();
				// the default will be for enabledCheckBoxToolTip
				if (checkBoxToolTips.disabledCheckBoxToolTip) checkBox.toolTip = checkBoxToolTips.disabledCheckBoxToolTip;
				addChild(checkBox);
			}
		}
		
		override protected function measure():void {
			super.measure();
			
			if (data) {
				switch (ClassUtils.getClass(data)) {
					case Title:
						if (useLargeIcons) {
							measuredHeight = 50;
						} else {
							measuredHeight = 16;
						}
						break;
					case Course:
					case Unit:
					case Exercise:
					case Group:
					case User:
						break;
				}
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if (!data) return;
			
			image.x = 15;
			
			switch (ClassUtils.getClass(data)) {
				case Title:
					//var imageSize:String;
					if (useLargeIcons) {
						image.width = image.height = 50;
						//imageSize = "";
					} else {
						image.width = image.height = 16;
						//imageSize = "Small-";
					}
					image.source = Constants.HOST + Constants.LOGO_FOLDER + "/" + (data as Title).productCode + ".swf";
					image.visible = true;
					icon.visible = false;
					expiredImage.visible = false;
					break;
				case Course:
				case Unit:
					image.visible = false;
					icon.visible = true;
					expiredImage.visible = false;
					break;
				case Exercise:
					// v3.4 I also want to change the icon based on whether I can edit this exericse, or not, or already have
					icon.visible = false;
					expiredImage.visible = false;
					image.width = image.height = 16;
					image.visible = true;
					// First see if it is protected
					// If instead of referring back to the mediator to pick this up dynamically
					// We could set it into the data, and then reset the data each time we click a new group.
					if ((data as Exercise).enabledFlag & Exercise.ENABLED_FLAG_NONEDITABLE) {
						// v3.5 I would prefer to see only relevant icons if I am not an author
						if (Constants.userType == User.USER_TYPE_AUTHOR) {
							image.source = protectedExerciseIcon;
							image.toolTip = checkBoxToolTips.protectedExerciseToolTip;
						} else {
							image.visible = false;
						}						
					} else if ((data as Exercise).enabledFlag & Exercise.ENABLED_FLAG_EDITED) {
						image.source = editedExerciseIcon;
						image.toolTip = checkBoxToolTips.editedExerciseToolTip;
					// v3.5 Also like to know if we have moved or added this exercise please
					} else if ((data as Exercise).enabledFlag & Exercise.ENABLED_FLAG_MOVED) {
						image.source = movedExerciseIcon;
						image.toolTip = checkBoxToolTips.movedExerciseToolTip;
					} else if ((data as Exercise).enabledFlag & Exercise.ENABLED_FLAG_INSERTED) {
						image.source = addedExerciseIcon;
						image.toolTip = checkBoxToolTips.addedExerciseToolTip;
					} else {
						// v3.5 I would prefer to see only relevant icons if I am not an author
						if (Constants.userType == User.USER_TYPE_AUTHOR) {
							image.source = normalExerciseIcon;
							image.toolTip = "";
						} else {
							image.visible = false;
						}						
					}
					break;
				case Group:
					image.width = image.height = 16;
					image.source = ((data as Group).hasHiddenContent()) ? hiddenGroupIcon : groupIcon;
					image.visible = true;
					icon.visible = false;
					expiredImage.visible = false;
					break;
				case User:
					image.width = image.height = 16;
					
					// Draw the applicable user icon
					switch ((data as User).userType) {
						case User.USER_TYPE_ADMINISTRATOR:
							image.source = adminIcon;
							break;
						case User.USER_TYPE_REPORTER:
							image.source = reporterIcon;
							break;
						case User.USER_TYPE_TEACHER:
							image.source = teacherIcon;
							break;
						case User.USER_TYPE_AUTHOR:
							image.source = authorIcon;
							break;
						case User.USER_TYPE_STUDENT:
							image.source = studentIcon;
							break;
						case User.USER_TYPE_AUTHOR:
							image.source = null;
							break;
					}
					// v3.4 Can I draw a different icon if this is you?
					// Yes, but it just goes on top.
					//if ((data as User).userID == Constants.userID) {
					//	icon.visible = true;
					//} else {
						icon.visible = false;
					//}
					
					image.visible = true;
					//icon.visible = false;
					
					expiredImage.x = image.x;
					expiredImage.visible = (data as User).isExpired();
					break;
			}
			
			if (useCheckBox) {
				checkBox.visible = true;
				
				var treeListData:TreeListData = TreeListData(listData);
				var checkBoxColor:String;
			
				checkBox.enabled = isCheckBoxEnabled();
				//if (triStateEnabled && !isCheckBoxSelected() && treeListData.hasChildren) {
				// Shouldn't we be saying that if the checkBox is disabled we won't bother with triState?				
				// TODO AR confirm this with DK
				if (triStateEnabled) {
				//if (triStateEnabled && checkBox.enabled) {
					var state:String = getState(data);

					switch (state) {
						case OFF:
						case EMPTY:
							checkBox.selected = false;
							if (checkBoxToolTips.offCheckBoxToolTip) {
								checkBox.toolTip = checkBoxToolTips.offCheckBoxToolTip;
								//TraceUtils.myTrace("setting tri.offToolTip=" + checkBoxToolTips.offCheckBoxToolTip);
							}
							if (ClassUtils.getClass(data) == Group) {
								if (checkBoxToolTips.offGroupCheckBoxToolTip) {
									checkBox.toolTip = checkBoxToolTips.offGroupCheckBoxToolTip;
									//TraceUtils.myTrace("setting tri.offToolTip=" + checkBoxToolTips.offCheckBoxToolTip);
								}							
							}
							break;
						case ON:
							checkBox.selected = true;
							checkBoxColor = "#000000";
							if (checkBoxToolTips.onCheckBoxToolTip) {
								checkBox.toolTip = checkBoxToolTips.onCheckBoxToolTip;
							}
							if (ClassUtils.getClass(data) == Group) {
								if (checkBoxToolTips.onGroupCheckBoxToolTip) {
									checkBox.toolTip = checkBoxToolTips.onGroupCheckBoxToolTip;
								}							
							}
							break;
						case TRI:
							checkBox.selected = true;
							checkBoxColor = "#999999";
							if (checkBoxToolTips.triCheckBoxToolTip) {
								checkBox.toolTip = checkBoxToolTips.triCheckBoxToolTip;
							}
							break;
						case DISABLE:
							checkBox.enabled = false;
							break;
					}
				} else {
					checkBox.selected = isCheckBoxSelected();
					if (checkBox.selected && checkBoxToolTips.onCheckBoxToolTip) {
						checkBox.toolTip = checkBoxToolTips.onCheckBoxToolTip;
					}
					if (!checkBox.selected && checkBoxToolTips.offCheckBoxToolTip) {
						checkBox.toolTip = checkBoxToolTips.offCheckBoxToolTip;
						//TraceUtils.myTrace("setting offToolTip=" + checkBoxToolTips.offCheckBoxToolTip);
					}
				}
				// set a disabled tool tip - overrides others
				// AR If I only pass a disabled tool tip - I see it on everything. I guess I have to clear out if I don't use it.
				if (!checkBox.enabled && !checkBox.selected && checkBoxToolTips.disabledCheckBoxToolTip) {
					//TraceUtils.myTrace(data.caption + " setting disabledToolTip=" + checkBoxToolTips.disabledCheckBoxToolTip);
					checkBox.toolTip = checkBoxToolTips.disabledCheckBoxToolTip;
				}
				
				enableEdit = isEnableContentEdit();
				if (!enableEdit) {
					checkBox.toolTip = checkBoxToolTips.enableEditContent;
				}
				
				checkBox.setStyle("iconColor", checkBoxColor);
				
			} else {
				checkBox.visible = false;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			//TraceUtils.myTrace("uDL width=" + unscaledWidth + " useLargeIcons=" + useLargeIcons);
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (!data) return;

			switch (ClassUtils.getClass(data)) {
				case Title:
					if (useLargeIcons) {
						label.x = 70;
						label.y = 16;
					} else {
						label.x = 32; // extra as no icon					
						label.y = 0;
					}
					break;
				case Course:
				case Unit:
				case Exercise:
					label.x = icon.x + 19;
					label.y = 0;
				// v3.4 I am now using image for exercises, so need to align it too
				//	break;
				case Group:
					image.x = icon.x;
					image.y = icon.y;
					break;
				case User:
					image.x = expiredImage.x = icon.x;
					image.y = expiredImage.y = icon.y;
					label.x += 2;
					break;
			}
			
			if (useCheckBox) {
				switch (ClassUtils.getClass(data)) {
					case Title:
					case Course:
					case Unit:
					case Exercise:
						label.x += 22;
						checkBox.x = label.x - 22;
						checkBox.y = label.y + 8;
						break;
					case Group:
					case User:
						label.x += 30;
						checkBox.x = label.x - 22;
						checkBox.y = 9;
						break;
				}
			}
		}
		
		// v3.4 Just an idea. Don't know where to call this from. Perhaps I have to recreate the itemRenderer altogether
		// if I want to change some of its properties?
		//public function setUseCheckBox(myUseCheckBox:Boolean):void {
		//	MonsterDebugger.trace(this, "setUseCheckBox to " + myUseCheckBox);
		//	useCheckBox = myUseCheckBox;
		//}
		private function isCheckBoxEnabled(forData:Object = null):Boolean {
			return checkBoxRendererProvider.isCheckBoxEnabled((forData) ? forData : data);
			//var tempEnabled:Boolean = checkBoxRendererProvider.isCheckBoxEnabled((forData) ? forData : data);
			//MonsterDebugger.trace(this, "renderer.isCheckBoxEnabled=" + tempEnabled.toString());
			//return tempEnabled;
		}
		
		private function isCheckBoxSelected(forData:Object = null):Boolean {
			return checkBoxRendererProvider.isCheckBoxSelected((forData) ? forData : data);
		}

		//gh:#29
		private function isEnableContentEdit():Boolean {
			return checkBoxRendererProvider.isEnableContentEdit();
		}
		/*
		private function isContentEdited(forData:Object = null):Boolean {
			// I don't really want to add this to the checkBoxRenderer interface as it has nothing to do with it.
			// Yet I do want to refer back to the contentMediator as the place to do the check. So how?
			// I could put it into exercise, just like hasHiddenContent is put into group, though DK says we shouldn't really have done that.
			// DK suggests making another interface for the mediator IContentRendererProvider and using that. 
			// An alternative is to put the edited data into enabledFlag for the data object each time I change group.
			return checkBoxRendererProvider.isContentEdited((forData) ? forData : data);
		}
		*/
		private function onCheckBoxClick(e:MouseEvent):void {
			// AR Why don't I get an automatic downward selection here?
			// Because we assume that the place that created the tree will do it?
			// What about if I really want one!
			checkBoxRendererProvider.onCheckBoxClick(data, checkBox.selected);
		}
		
		// AR This is attempting to give you downward selection from any node
		/*
		var state:String = getState(data);
		switch (state) {
			case forTree.OFF:
			case forTree.EMPTY:
			case forTree.TRI:
				forTree.setState(forTree.data, forTree.ON);
				break;
			default:
				forTree.setState(forTree.data, forTree.OFF);
		}
		*/
		private function setState(data:Object, state:String):void {
			// If this is a leaf, set its state;
			if (!data.children) {
				checkBox.selected = (state == ON);
				return;
			}
			// If it is a branch, go into it's children
			if (triStateEnabled) {
				for each (var child:Object in data.children) {
					setState(child, state)
				}
			}
		}
			
		private function getState(data:Object):String {
			// Note that this doesn't respect the data descriptor so in license tree, for example, it will count admins and teachers
			// (who aren't in the tree).  Agreed with Adrian that this behaviour is ok.
			
			// If a leaf then normal
			if (!data.children)
				return isCheckBoxSelected(data) ? ON : OFF;
			
			//gh#223
			if (data.hasOwnProperty("productCode") && data.productCode == "54" ){
					return DISABLE;
			}
			
			// If a branch then work out its state from the children
			var selectedCount:int = 0;
			var totalCount:int = data.children.length;
			
			for each (var child:Object in data.children) {
				switch (getState(child)) {
					case ON:
						selectedCount++;
						break;
					case TRI:
						return TRI;
				}
			}
			
			if (totalCount == 0) {
				return EMPTY;
			} else if (selectedCount == totalCount) {
				return ON;
			} else if (selectedCount > 0 && selectedCount < totalCount) {
				return TRI;
			} else {
				return OFF;
			}
		}
		
	}
	
}