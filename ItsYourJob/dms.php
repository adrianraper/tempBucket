<?php
session_start();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Clarity English | It's Your Job |Terms and conditions</title>

<!--CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<link rel="stylesheet" type="text/css" href="css/job_dms_internal.css" />
<script type="text/javascript" language="JavaScript" src="script/dms_validation.js"></script>
<script type="text/javascript" src="script/dms_datepicker.js">

/***********************************************
* Jason's Date Input Calendar- By Jason Moon http://calendar.moonscript.com/dateinput.cfm
* Script featured on and available at http://www.dynamicdrive.com
* Keep this notice intact for use.
***********************************************/

</script>
</head>

<body>

<div id="container">
	<!--Bannar Area-->
<div id="bannar_before_login" class="ban_join">
	<a href="./joinus.php" class="ban_link"></a>
	<a href="./index.php" class="ban_home"></a>
</div>
    <div class="bannar_rainbow_line" id="welcome_line">

    

    
  </div>
<!--End of Bannar Area-->

  <div id="content_container">

    <h1 class="general_heading">Clarity Life Skills - It's Your Job Internal Data Management System</h1>
    <!--Content Area-->
    <div id="general_box_outter">
    
    
    	    <div id="general_box">
            
            
            <div class="join_box_content">





    <h2>User information</h2>
    <form style="margin:0; padding:0;" id="IYJdmsForm" name="IYJdmsForm">
    <div class="join_box_content_inner">
    <p>Please complete all fields using the standard English alphabet.</p>

        <div style="position:relative; height:45px">

        	<div class="field_title">1. Subscription period:</div>
             
            <div class="datepicker_box">
                <div class="datepicker_title">Start date:</div>
                <div class="datepicker_area"><script>DateInput('startdate', true, 'YYYY-MM-DD')</script></div>
                <div class="datepicker_title">End date:</div>
                <div class="datepicker_area"><script>DateInput('enddate', true, 'YYYY-MM-DD')</script></div>
         	</div>
    
         </div>
   

            

        <ul class="fielding">
        
        <li>
  
          <p class="field_title">2. User full name :</p>
          <p class="field_line">
            	<input name="IYJreg_uFullName" type="text" class="field" id="IYJreg_uFullName" tabindex="1" onblur="checkName()" />
		  </p>
        </li>
        <li><p class="field_msg_line">(The name we use to contact you.)</p></li>
        <li><p class="field_warn_line"><label id="IYJreg_uFullNameNote" name="IYJreg_uFullNameNote"></label></p></li>
	
		<li>
            <p class="field_title">3. Email : </p>
            <p class="field_line">
				<input type="text" name="IYJreg_uEmail" id="IYJreg_uEmail" tabindex="2" class="field" onblur="checkEmail()" />
            </p>
        </li>
    	<li><p class="field_msg_line">(This will be your login name.)</p></li>
        <li><p class="field_warn_line"><label id="IYJreg_uEmailNote" name="IYJreg_uEmailNote"></label></p></li>
		
        <li>
            <p class="field_title">4. Country :</p>
            <p class="field_line">
			<select name="IYJreg_uCountry" id="IYJreg_uCountry" class="field_country" tabindex="3" onChange="checkCountry()">
            	<option value="none" selected="selected">Please select your country</option>
                <option value="Afghanistan">Afghanistan</option>
                <option value="Aland Islands">Aland Islands</option>
                <option value="Albania">Albania</option>
                <option value="Algeria">Algeria</option>
                <option value="American Samoa">American Samoa</option>
                <option value="Andorra">Andorra</option>
                <option value="Angola">Angola</option>
                <option value="Anguilla">Anguilla</option>
                <option value="Antarctica">Antarctica</option>
                <option value="Antigua and Barbuda">Antigua and Barbuda</option>
                <option value="Argentina">Argentina</option>
                <option value="Armenia">Armenia</option>
                <option value="Aruba">Aruba</option>
                <option value="Australia">Australia</option>
                <option value="Austria">Austria</option>
                <option value="Azerbaijan">Azerbaijan</option>
                <option value="Bahamas">Bahamas</option>
                <option value="Bahrain">Bahrain</option>
                <option value="Bangladesh">Bangladesh</option>
                <option value="Barbados">Barbados</option>
                <option value="Belarus">Belarus</option>
                <option value="Belgium">Belgium</option>
                <option value="Belize">Belize</option>
                <option value="Benin">Benin</option>
                <option value="Bermuda">Bermuda</option>
                <option value="Bhutan">Bhutan</option>
                <option value="Bolivia">Bolivia</option>
                <option value="Bosnia and Herzegovina">Bosnia and Herzegovina</option>
                <option value="Botswana">Botswana</option>
                <option value="Bouvet Island">Bouvet Island</option>
                <option value="Brazil">Brazil</option>
                <option value="British Indian Ocean Territory">British Indian Ocean Territory</option>
                <option value="Brunei">Brunei</option>
                <option value="Bulgaria">Bulgaria</option>
                <option value="Burkina Faso">Burkina Faso</option>
                <option value="Burundi">Burundi</option>
                <option value="Cambodia">Cambodia</option>
                <option value="Cameroon">Cameroon</option>
                <option value="Canada">Canada</option>
                <option value="Cape Verde">Cape Verde</option>
                <option value="Cayman Islands">Cayman Islands</option>
                <option value="Central African Republic">Central African Republic</option>
                <option value="Chad">Chad</option>
                <option value="Chile">Chile</option>
                <option value="China">China</option>
                <option value="Christmas Island">Christmas Island</option>
                <option value="Cocos (Keeling) Islands">Cocos (Keeling) Islands</option>
                <option value="Colombia">Colombia</option>
                <option value="Comoros">Comoros</option>
                <option value="Congo">Congo</option>
                <option value="Congo, The Democratic Republic Of The">Congo, The Democratic Republic Of The</option>
                <option value="Cook Islands">Cook Islands</option>
                <option value="Costa Rica">Costa Rica</option>
                <option value="Cote D'Ivoire">Cote D'Ivoire</option>
                <option value="Croatia">Croatia</option>
                <option value="Cuba">Cuba</option>
                <option value="Cyprus">Cyprus</option>
                <option value="Czech Republic">Czech Republic</option>
                <option value="Denmark">Denmark</option>
                <option value="Djibouti">Djibouti</option>
                <option value="Dominica">Dominica</option>
                <option value="Dominican Republic">Dominican Republic</option>
                <option value="Ecuador">Ecuador</option>
                <option value="Egypt">Egypt</option>
                <option value="El Salvador">El Salvador</option>
                <option value="Equatorial Guinea">Equatorial Guinea</option>
                <option value="Eritrea">Eritrea</option>
                <option value="Estonia">Estonia</option>
                <option value="Ethiopia">Ethiopia</option>
                <option value="Falkland Islands">Falkland Islands</option>
                <option value="Faroe Islands">Faroe Islands</option>
                <option value="Fiji">Fiji</option>
                <option value="Finland">Finland</option>
                <option value="France">France</option>
                <option value="French Guiana">French Guiana</option>
                <option value="French Polynesia">French Polynesia</option>
                <option value="French Southern Territories">French Southern Territories</option>
                <option value="Gabon">Gabon</option>
                <option value="Gambia">Gambia</option>
                <option value="Georgia">Georgia</option>
                <option value="Germany">Germany</option>
                <option value="Ghana">Ghana</option>
                <option value="Gibraltar">Gibraltar</option>
                <option value="Greece">Greece</option>
                <option value="Greenland">Greenland</option>
                <option value="Grenada">Grenada</option>
                <option value="Guadeloupe">Guadeloupe</option>
                <option value="Guam">Guam</option>
                <option value="Guatemala">Guatemala</option>
                <option value="Guernsey">Guernsey</option>
                <option value="Guinea">Guinea</option>
                <option value="Guinea-Bissau">Guinea-Bissau</option>
                <option value="Guyana">Guyana</option>
                <option value="Haiti">Haiti</option>
                <option value="Heard Island and Mcdonald Islands">Heard Island and Mcdonald Islands</option>
				<option value="Honduras">Honduras</option>
                <option value="Hong Kong">Hong Kong</option>
                <option value="Hungary">Hungary</option>
                <option value="Iceland">Iceland</option>
                <option value="India">India</option>
                <option value="Indonesia">Indonesia</option>
                <option value="Iran">Iran</option>
                <option value="Iraq">Iraq</option>
                <option value="Ireland">Ireland</option>
                <option value="Isle Of Man">Isle Of Man</option>
                <option value="Israel">Israel</option>
                <option value="Italy">Italy</option>
                <option value="Jamaica">Jamaica</option>
                <option value="Japan">Japan</option>
                <option value="Jersey">Jersey</option>
                <option value="Jordan">Jordan</option>
                <option value="Kazakhstan">Kazakhstan</option>
                <option value="Kenya">Kenya</option>
                <option value="Kiribati">Kiribati</option>
                <option value="Korea, North">Korea, North</option>
                <option value="Korea, South">Korea, South</option>
                <option value="Kuwait">Kuwait</option>
                <option value="Kyrgyzstan">Kyrgyzstan</option>
                <option value="Laos">Laos</option>
                <option value="Latvia">Latvia</option>
                <option value="Lebanon">Lebanon</option>
                <option value="Lesotho">Lesotho</option>
                <option value="Liberia">Liberia</option>
                <option value="Libya">Libya</option>
                <option value="Liechtenstein">Liechtenstein</option>
                <option value="Lithuania">Lithuania</option>
                <option value="Luxembourg">Luxembourg</option>
                <option value="Macao">Macao</option>
                <option value="Macedonia">Macedonia</option>
                <option value="Madagascar">Madagascar</option>
                <option value="Malawi">Malawi</option>
                <option value="Malaysia">Malaysia</option>
                <option value="Maldives">Maldives</option>
                <option value="Mali">Mali</option>
                <option value="Malta">Malta</option>
                <option value="Marshall Islands">Marshall Islands</option>
                <option value="Martinique">Martinique</option>
                <option value="Mauritania">Mauritania</option>
                <option value="Mauritius">Mauritius</option>
                <option value="Mayotte">Mayotte</option>
                <option value="Mexico">Mexico</option>
                <option value="Micronesia, Federated States Of">Micronesia, Federated States Of</option>
                <option value="Moldova">Moldova</option>
                <option value="Monaco">Monaco</option>
                <option value="Mongolia">Mongolia</option>
                <option value="Montenegro">Montenegro</option>
                <option value="Montserrat">Montserrat</option>
                <option value="Morocco">Morocco</option>
                <option value="Mozambique">Mozambique</option>
                <option value="Myanmar">Myanmar</option>
                <option value="Namibia">Namibia</option>
                <option value="Nauru">Nauru</option>
                <option value="Nepal">Nepal</option>
                <option value="Netherlands">Netherlands</option>
                <option value="Netherlands Antilles">Netherlands Antilles</option>
                <option value="New Caledonia">New Caledonia</option>
                <option value="New Zealand">New Zealand</option>
                <option value="Nicaragua">Nicaragua</option>
                <option value="Niger">Niger</option>
                <option value="Nigeria">Nigeria</option>
                <option value="Niue">Niue</option>
                <option value="Norfolk Island">Norfolk Island</option>
                <option value="Northern Mariana Islands">Northern Mariana Islands</option>
                <option value="Norway">Norway</option>
                <option value="Oman">Oman</option>
                <option value="Pakistan">Pakistan</option>
                <option value="Palau">Palau</option>
                <option value="Palestine">Palestine</option>
                <option value="Panama">Panama</option>
                <option value="Papua New Guinea">Papua New Guinea</option>
                <option value="Paraguay">Paraguay</option>
                <option value="Peru">Peru</option>
                <option value="Philippines">Philippines</option>
                <option value="Pitcairn Islands">Pitcairn Islands</option>
                <option value="Poland">Poland</option>
                <option value="Portugal">Portugal</option>
                <option value="Puerto Rico">Puerto Rico</option>
                <option value="Qatar">Qatar</option>
                <option value="Reunion">Reunion</option>
                <option value="Romania">Romania</option>
                <option value="Russia">Russia</option>
                <option value="Rwanda">Rwanda</option>
                <option value="Saint Barthelemy">Saint Barthelemy</option>
                <option value="Saint Helena">Saint Helena</option>
                <option value="Saint Kitts and Nevis">Saint Kitts and Nevis</option>
                <option value="Saint Lucia">Saint Lucia</option>
                <option value="Saint Martin">Saint Martin</option>
                <option value="Saint Pierre and Miquelon">Saint Pierre and Miquelon</option>
                <option value="Saint Vincent and The Grenadines">Saint Vincent and The Grenadines</option>
                <option value="Samoa">Samoa</option>
                <option value="San Marino">San Marino</option>
                <option value="Sao Tome and Principe">Sao Tome and Principe</option>
                <option value="Saudi Arabia">Saudi Arabia</option>
                <option value="Senegal">Senegal</option>
                <option value="Serbia">Serbia</option>
                <option value="Seychelles">Seychelles</option>
                <option value="Sierra Leone">Sierra Leone</option>
                <option value="Singapore">Singapore</option>
                <option value="Slovakia">Slovakia</option>
                <option value="Slovenia">Slovenia</option>
                <option value="Solomon Islands">Solomon Islands</option>
                <option value="Somalia">Somalia</option>
                <option value="South Africa">South Africa</option>
                <option value="South Georgia and The South Sandwich Islands">South Georgia and The South Sandwich Islands</option>
                <option value="Spain">Spain</option>
                <option value="Sri Lanka">Sri Lanka</option>
                <option value="Sudan">Sudan</option>
                <option value="Suriname">Suriname</option>
                <option value="Svalbard and Jan Mayen">Svalbard and Jan Mayen</option>
                <option value="Swaziland">Swaziland</option>
                <option value="Sweden">Sweden</option>
                <option value="Switzerland">Switzerland</option>
                <option value="Syria">Syria</option>
                <option value="Taiwan">Taiwan</option>
                <option value="Tajikistan">Tajikistan</option>
                <option value="Tanzania">Tanzania</option>
                <option value="Thailand">Thailand</option>
                <option value="Timor-Leste">Timor-Leste</option>
                <option value="Togo">Togo</option>
                <option value="Tokelau">Tokelau</option>
                <option value="Tonga">Tonga</option>
                <option value="Trinidad and Tobago">Trinidad and Tobago</option>
                <option value="Tunisia">Tunisia</option>
                <option value="Turkey">Turkey</option>
                <option value="Turkmenistan">Turkmenistan</option>
                <option value="Turks and Caicos Islands">Turks and Caicos Islands</option>
                <option value="Tuvalu">Tuvalu</option>
                <option value="Uganda">Uganda</option>
                <option value="Ukraine">Ukraine</option>
                <option value="United Arab Emirates">United Arab Emirates</option>
                <option value="United Kingdom">United Kingdom</option>
                <option value="United States">United States</option>
                <option value="United States Minor Outlying Islands">United States Minor Outlying Islands</option>
                <option value="Uruguay">Uruguay</option>
                <option value="Uzbekistan">Uzbekistan</option>
                <option value="Vanuatu">Vanuatu</option>
                <option value="Vatican City">Vatican City</option>
                <option value="Venezuela">Venezuela</option>
                <option value="Vietnam">Vietnam</option>
                <option value="Virgin Islands, British">Virgin Islands, British</option>
                <option value="Virgin Islands, U.S.">Virgin Islands, U.S.</option>
                <option value="Wallis and Futuna">Wallis and Futuna</option>
                <option value="Western Sahara">Western Sahara</option>
                <option value="Yemen">Yemen</option>
                <option value="Zambia">Zambia</option>
                <option value="Zimbabwe">Zimbabwe</option>
            </select>
            </p>
            </li>
      		<li><p class="field_warn_line"><label id="IYJreg_uCountryNote" name="IYJreg_uCountryNote"></label></p></li>
            
       
   
    </ul>
    
   <p id="comsoon"  >* coming soon</p>
    
    <ul class="setting">
        <li>
            <div class="setting_left">
                <p class="setting_title">5. Delivery frequency</p> </div>
            <div class="setting_right">
                
                <p><input name="IYJreg_dFreq" id="IYJreg_dFreq" type="radio" value="0" checked="checked" />All at once</p>
                <p  style="display:none"><input name="IYJreg_dFreq" id="IYJreg_dFreq" type="radio" value="1" DISABLED  />One unit every day *</p>
                <p  style="display:none"><input name="IYJreg_dFreq" id="IYJreg_dFreq" type="radio" value="3" DISABLED />One unit every three days *</p>
            </div>
        </li>
        
        
        <li>
            <div class="setting_left">
                <p class="setting_title">6. Program version</p>
                </div>
            <div class="setting_right">
                <p><input name="IYJreg_language" id="IYJreg_language" type="radio" value="EN" checked="checked" />International English</p>
                <p  style="display:none"><input name="IYJreg_language" id="IYJreg_language" type="radio" value="NAMEN" DISABLED />North American English *</p>
                <p  style="display:none"><input name="IYJreg_language" id="IYJreg_language" type="radio" value="INDEN" DISABLED />Indian English *</p>
            </div>
        </li>
        
        <li>
            <div class="setting_left">
                <p class="setting_title">7. Contact method</p>
             </div>
            <div class="setting_right">
                <div class="set_column">
                	<p><input name="IYJreg_contact" id="IYJreg_contact" type="checkbox" value="Email" checked="checked" onClick="ClearSingleChecked(document.joinUsForm.IYJreg_contact, 1)" /> Email</p>
                   <!--<p><input name="IYJreg_contact" id="IYJreg_contact" type="checkbox" value="Not at all" onClick="ClearAllChecked(document.joinUsForm.IYJreg_contact)"/> Not at all</p>-->
				   <p><input name="IYJreg_contact" id="IYJreg_contact" type="checkbox" value="Not at all" onClick="ClearSingleChecked(document.joinUsForm.IYJreg_contact, 0)"/> Not at all</p>
              </div>
              
               <div class="set_column">
                	<p><input name="IYJreg_contact" id="IYJreg_contact" type="checkbox" value="SMS" onClick="ClearSingleChecked(document.joinUsForm.IYJreg_contact, 3)" DISABLED/> SMS *</p>
                   	<p><input name="IYJreg_contact" id="IYJreg_contact" type="checkbox" value="Facebook" onClick="ClearSingleChecked(document.joinUsForm.IYJreg_contact, 3)" DISABLED/> Facebook *</p>  
               </div>
          </div>
            <!--<div class="setting_right">
                <div class="set_column">
                	<p><input name="IYJreg_contact" id="IYJreg_contact" type="checkbox" value="Email" checked="checked" onClick="ClearSingleChecked(document.joinUsForm.IYJreg_contact, 3)" /> Email</p>
                    <p><input name="IYJreg_contact" id="IYJreg_contact" type="checkbox" value="Facebook" onClick="ClearSingleChecked(document.joinUsForm.IYJreg_contact, 3)" /> Facebook</p>
                    </div>
                <div class="set_column">
                	<p><input name="IYJreg_contact" id="IYJreg_contact" type="checkbox" value="SMS" onClick="ClearSingleChecked(document.joinUsForm.IYJreg_contact, 3)" /> SMS</p>
                   	<p><input name="IYJreg_contact" id="IYJreg_contact" type="checkbox" value="Not at all" onClick="ClearAllChecked(document.joinUsForm.IYJreg_contact)"/> Not at all</p>
                    
                    </div>
            </div>-->
        </li>
        
        
    </ul>

    
    </div>
    
    
   
    
    <div class="btn_area">
        <div class="btn_save_submit" tabindex="5" onclick="javascript:checkRegData();"></div>

    </div>

	</form>
</div>

            
            
            </div>
    

        
        </div>
        
        
        
        
    </div>

    
    
    
    
  <!--End of Content Area-->
    
   <!--Footer Area-->
<div id="footer">
    	<div id="footer_clarity_logo"><a href="http://www.ClarityEnglish.com/" target="_blank"></a></div>
        
        <div id="footer_clarity_line">Copyright &copy; 1993 -
    <script type="text/javascript">
		var d = new Date()
		document.write(d.getUTCFullYear())
	</script>
    Clarity Language Consultants Ltd. All rights reserved.</div>
    
        <div id="footer_links_line"><a href="terms.htm">Terms and conditions</a> | <a href="http://www.clarityenglish.com/aboutus/index.php" target="_blank">About Clarity</a></div>
  </div>
    
    <!--End of Footer Area-->

</div>     
<!--End of Container-->
<script type="text/javascript">
//setLabelText("IYJreg_startDate",startDate);
//setLabelText("IYJreg_expiryDate",expiryDate);
</script>


<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-873320-5");
pageTracker._trackPageview();
} catch(err) {}</script>


</body>
</html>
