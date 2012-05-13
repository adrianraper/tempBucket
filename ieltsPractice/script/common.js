// This js contains commons vars that can use all across the website, eg. email pattern (for validation)
var emailPattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
var passwordPattern = /^([a-zA-Z0-9_.-@#$%^&+=]){8,15}$/;

// Below lists all error message that use in the whole website
var R2IBuyProductError = 'Please choose your Road to IELTS module and subscription period.';
var R2IBuyEmailPatternIncorrect = 'Please type a valid email.';
var R2IBuyEmailIsValid = 'Email is valid.';
var R2IBuyEmailExists = 'This email already exists, please log in above.';
var R2IBuyMultipleEmailExists = 'Multiple emails found. Please contact support@clarityenglish.com.';
var R2IBuyEmailUnknownError = "The system can't log you in. Please contact support@ieltspractice.com";
var R2IBuyPwdPatternIncorrect = 'Please type your password using 8-15 English alphabet characters.';
var R2IBuyRetypePwdIncorrect = 'Please re-type the same password.';
var R2IBuyNameMissing = 'Please input your name';
var R2IBuyCountryNotChose = 'Please select your country';
var R2IBuyWaiting = 'Please wait...';
var R2IBuyPaymentNotSelected = "Please choose your payment method.";
var R2IBuyTnCNotChecked = "Please check the box to accept the terms and conditions.";
var R2ILoginIncorrect = "Sorry, that email and password combination is not correct.";
var R2ILoginSuccess = "You have been successfully logged in.";
var R2ICost1Month = 49.99;
var R2ICost3Months = 99.99;
// Cheaper testing!
var R2ICost1Month = 0.99;
var R2ICost3Months = 1.99;