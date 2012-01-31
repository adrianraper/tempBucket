package com.clarityenglish.common.vo.content {
	import com.clarityenglish.common.vo.dictionary.DictionarySingleton;
	import org.davekeen.util.DateUtil;
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	[RemoteClass(alias = "com.clarityenglish.common.vo.content.Title")]
	[Bindable]
	public class Title extends Content {
		
		// Of course these are really database values (T_LicenceType) but sometimes it is quick to refer to these constants!
		public static const LICENCE_TYPE_LT:int = 1;
		public static const LICENCE_TYPE_AA:int = 2;
		public static const LICENCE_TYPE_CT:int = 3;
		public static const LICENCE_TYPE_SINGLE:int = 4;
		public static const LICENCE_TYPE_I:int = 5;
		public static const LICENCE_TYPE_TT:int = 6;
		
		/**
		 * The collection of courses belonging to this title
		 */
		private var _courses:Array;
		
		/**
		 * The product code - used for linking users and titles for licencing
		 */
		public var productCode:Number;
		
		public var maxStudents:uint;
		public var maxTeachers:uint;
		public var maxReporters:uint;
		public var maxAuthors:uint;
		
		/**
		 * Note that these dates are stored as ANSI strings in the format YYYY-MM-DD JJ:NN:SS.  Use DateUtils.dateToAnsiString to convert.
		 */
		public var expiryDate:String;
		public var licenceStartDate:String;
		
		public var languageCode:String;
		public var startPage:String;
		public var licenceFile:String;
		public var contentLocation:String;
		// v3.5 This is a field directly tied to T_Accounts, only DMS displays it
		public var dbContentLocation:String;
		
		public var licenceType:Number;
		// v3.6.5 Adding licence clearance date
		public var licenceClearanceDate:String;
		public var licenceClearanceFrequency:Number;
		
		// v3.1 For emus and courses - not used for database storage
		public var indexFile:String;
		// v3.1 For emus to specify other titles that they include - not used for database storage
		public var licencedProductCodes:String;
		public var deliveryFrequency:Number;
		
		public var checksum:String;
		
		public function Title() {
			courses = new Array();
		}
		
		public function addCourse(course:Course):void {
			//TraceUtils.myTrace("title.as.addCourse code=" + productCode + " licenceStartDate=" + licenceStartDate);
			courses.push(course);
		}
		
		public function get courses():Array { return _courses; }
		
		public function set courses(value:Array):void {
			super.children = value;
			
			_courses = value;
		}
		
		/**
		 * Search the courses within this title for the one with the given id.  If this course does not exist return null.
		 * 
		 * @param	courseId The course ID to search for
		 * @return
		 */
		public function getCourseById(courseId:String):Course {
			for each (var course:Course in courses)
				if (course.id == courseId) return course;
				
			return null;
		}
		
		/**
		 * This creates a new title with default parameters.  Note that this does not add the caption or contentLocation and so this must be
		 * done manually.
		 * 
		 * @param	productCode
		 * @return
		 */
		public static function createDefault(productCode:Number):Title {
			var title:Title = new Title();
			title.productCode = productCode;
			// It is based on productCode as only RM cares about non students, and it doesn't care about students
			if (productCode==2) {
				title.maxStudents = 0;
				title.maxTeachers = 3;
				title.maxReporters = 1;
				// v3.6 For now, we are only switching on ECC by application
				title.maxAuthors = 0;
			} else {
				title.maxStudents = 30;
				title.maxTeachers = 0;
				title.maxReporters = 0;
				title.maxAuthors = 0;
			}
			
			// Set the expiry date one year from today
			var date:Date = new Date();
			date.fullYear++;
			title.expiryDate = DateUtil.dateToAnsiString(date);
			
			title.licenceStartDate = DateUtil.dateToAnsiString(new Date());
			title.licenceType = 1;
			
			// Ideally we would look up the T_ProductLanguage table to find the default language code
			title.languageCode = "EN";
			// v3.4.2 And we do want to set the caption too. This will not trigger an extra dictionaries PHP call, so not expensive.
			var products:Array = DictionarySingleton.getInstance().products;
			//TraceUtils.myTrace("getting RM name from products dictionary=" + products[productCode].label);
			for each (var product:Object in products) {
				if (product.data == productCode) {
					title.name = product.label;
					break;
				}
			}
			return title;
		}
		
		/**
		 * Implementing a children field allows us to use this class directly as a dataprovider to a tree
		 */
		[Transient]
		override public function get children():Array { return courses; }
		
		override public function set children(children:Array):void {
			courses = children;
		}
		
		/**
		 * Since titles have no real id fake it as the product code.  This is used to identify a title when calling encodeTreeAsObject when
		 * setting hidden groups (and will possibly have uses elsewhere too).
		 */
		override public function get id():String {
			//TraceUtils.myTrace("title.as.getID code=" + productCode + " licenceStartDate=" + licenceStartDate);
			return productCode.toString();
		}
		
		override public function set id(id:String):void { }
		
		/* INTERFACE mx.core.IUID */
		
		override public function get uid():String {
			return productCode.toString();
		}
		
		override public function set uid(value:String):void { }
		
	}
	
}