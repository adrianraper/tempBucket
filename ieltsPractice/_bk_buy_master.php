<?php
	session_start();
	include_once "variables.php";
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Road to IELTS: IELTS preparation and practice</title>
<link rel="stylesheet" type="text/css" href="css/home.css" />
<link rel="stylesheet" type="text/css" href="css/buy.css" />
<script type="text/javascript" src="script/jquery-1.4.3.min.js"></script>
<script type="text/javascript" src="script/jquery-validation/jquery.validate.js"></script>
<script type="text/javascript" src="script/common.js"></script>
<script type="text/javascript" src="script/Buy/control.js"></script>
</head>

<body id="buy_page">
	<div id="container_outter">
        <div id="container">
            <div id="header_outter">
        	    <?php include ( 'header.php' ); ?>
        
        </div>
            <form method="post" action="" name="R2IBuyForm" id="R2IBuyForm" style="margin:0; padding:0;">
				<!-- This is where the inner HTML sits-->
				<div id="buy_innerHTML">
                
                		<div id="content_box_buy">
                            <div id="buy_box">
                                <p class="title">Step 1: Choose your subscription</p>
                                <div id="buy_step_1" class="buy_on"><span class="num">1</span>Choose your subscription</div>
                                <div id="buy_step_2" class="buy_off"><span class="arrow"></span><span class="num">2</span>Choose your payment method</div>
                                <div id="buy_step_3" class="buy_off"><span class="arrow"></span><span class="num">3</span>Review and Pay</div>
                                <div id="buy_step_4" class="buy_off"><span class="arrow"></span><span class="num">4</span>Start learning</div>
                                <div class="clear"></div>
                            </div>
                
                            <div class="buy_container">
                                <div id="buy_content">
                        
                                     
                                     <div class="buy_field_box">
                                         <p class="subtitle">A. Choose your Road to IELTS module:</p>
                                         <div class="buy_inner_box">
                                             
                                                <div class="choose_box_container">
                                                     <div class="choose_box">
                                                        <div class="choose_radio"><input name="R2ISelectModule" id="R2ISelectModuleAC" type="radio" value="52" /></div>
                                                        <div id="choose_RTIA" class="on">Academic module</div>
                                                     </div>
                                                     <div class="choose_box">
                                                        <div class="choose_radio"><input name="R2ISelectModule" id="R2ISelectModuleGT" type="radio" value="53" /></div>
                                                        <div id="choose_RTIG" class="off">General Training module</div>
                                                     </div>
                                                     <div class="clear"></div>
                                                 </div>
                           
                                                 <p class="buy_notsure">Not sure? Click here.</p>
                                       
                                         </div>
                                         
                                         
                                         
                                     </div>
                                     
                                     <div class="buy_field_box">
                                         <p class="subtitle">B. Choose your subscription period:</p>
                                         <div class="buy_inner_box">
                          
                                                     <div class="month_box">
                                                        <div class="choose_radio"><input name="R2ISelectSubscription" id="R2ISelectSubscription1m" type="radio" value="31" /></div>
                                                        <div class="choose_month">One month (US$49.99)</div>
                                                        <div class="clear"></div>
                                                     </div>
                                                     
                                                     <div class="month_box">
                                                        <div class="choose_radio"><input name="R2ISelectSubscription" id="R2ISelectSubscription3m" type="radio" value="92" /></div>
                                                        <div class="choose_month">Three months (US$99.99)</div>
                                                        <div class="clear"></div>
                                                     </div>
                                                     <div class="buy_field_line">
                                                        <p class="error_line" name="RTIProductError" id="RTIProductError" style="display:none"></p>
                                                     </div>
                                               
                                             
                                         
                                         </div>
                                     </div>
                                     
                                     <div class="buy_field_box">
                                         <p class="subtitle">C. Create your account:</p>
                                         <div class="buy_inner_box">
                                            <div class="buy_field_line">
                                                <p class="name">Your email:</p>
                                                <input name="RTIChooseEmail" id="RTIChooseEmail" type="text" class="field" />
                                                <p class="note">(This will be your login name)</p>
                                                <div class="clear"></div>
                                                <p class="error" name="RTIEmailError" id="RTIEmailError"></p>
                                        
                                            </div>
                                            
                                            <div class="buy_field_line">
                                                <p class="name">Your password:</p>
                                                <input name="RTIChoosePassword" id="RTIChoosePassword" type="password" class="field" />
                                                <p class="note">(8-15 English alphabet characters)</p>
                                                <div class="clear"></div>
                                                <p class="error" name="RTIPasswordError" id="RTIPasswordError"></p>
                                        
                                            </div>
                                            
                                            <div class="buy_field_line">
                                                <p class="name">Retype password:</p>
                                                <input name="RTIRetypePassword" id="RTIRetypePassword" type="password" class="field" />
                                                
                                                <div class="clear"></div>
                                                <p class="error" name="RTIPassword2Error" id="RTIPassword2Error"></p>
                                        
                                            </div>
                                         
                                         </div>
                                     </div>
                                     
                                     <div class="buy_field_box">
                                         <p class="subtitle">D. Enter your details:</p>
                                         <div class="buy_inner_box">
                                            <div class="buy_field_line">
                                                <p class="name">Your name:</p>
                                                <input name="RTIName" id="RTIName" type="text" class="field" />
                                                <p class="note">(We will use this name in emails)</p>
                                                <div class="clear"></div>
                                                <p class="error" name="RTINameError" id="RTINameError" style="display:none"></p>
                                        
                                            </div>
                                            
                                            <div class="buy_field_line">
                                                <p class="name">Your age group:</p>
                                                <select name="RTIAgeGroup" id="RTIAgeGroup" class="field">
                                                  <option value="" selected="selected" disabled>Please select your age group</option>
                                                  <option value="b18">Below 18</option>
                                                  <option value="18-25">18-25</option>
                                                  <option value="25-40">25-40</option>
                                                  <option value="40-55">40-55</option>
                                                  <option value="55a">55 above</option>
                                                </select>
                                                <p class="note">(This is for research purposes)</p>
                                                <div class="clear"></div>
                                        
                                            </div>
                                            
                                            <div class="buy_field_line">
                                                <p class="name">Phone:</p>
                                                <input name="RTIPhone" id="RTIPhone" type="text" class="field" />
                                                <p class="note">(In case we need to contact you about your payment)</p>
                                                <div class="clear"></div>
                                            </div>
                                            
                                            <div class="buy_field_line">
                                                <p class="name">Country:</p>
                                                <select name="RTICountry" id="RTICountry" class="field">
                                                        <option value="" selected="selected" disabled>Please select your country</option>
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
                                                <div class="clear"></div>
                                                <p class="error" name="RTICountryError" id="RTICountryError" style="display:none"></p>
                                            </div>
                                            
                                            <div class="buy_field_line">
                                                <input name="RTINewsletter" id="RTINewsletter" type="checkbox" value="" />I would like to receive the latest news from Clarity.
                                            </div>
                                         
                                         </div>
                                     </div>
                                     
                                     
                                     <div class="buy_button_area">
                                        <div class="btn_blue_general" onclick="SaveAndGo('2')">Continue</div>
                                    
                                        <div class="buy_comment">
                                            <div class="form_waiting" name="RTIMsgWait" id="RTIMsgWait" style="display:none">Please wait...</div>
                                            <div class="form_oops" name="RTIMsgError" id="RTIMsgError" style="display:none">Please fill in the required fields</div>
                                         </div>
                                        <div class="clear"></div>
                                    </div>
                                
                                </div>
                                <div id="buy_banner"></div>
                                <div class="clear"></div>
                            </div>
                        
                
               
               <div class="buy_txt">
               </div>
			</div>
            
            
            			<div id="content_box_buy">
            				<div id="buy_box">
                                <p class="title">Step 2: Choose your payment method</p>
                                <div id="buy_step_1_off"><span class="num_off">1</span> Choose your subscription</div>
                                <div id="buy_step_2" class="buy_on"><span class="num_on">2</span> Choose your payment method</div>
                                <div id="buy_step_3" class="buy_off"><span class="num_off">3</span> Review and Pay</div>
                                <div id="buy_step_4" class="buy_off"><span class="num_off">4</span> Start learning</div>
                                <div class="clear"></div>
                            </div>
                
                <div id="buy_container">
                	<div id="buy_payment_content">
                    	 <p id="method_title">Please choose your payment method:</p>
                         <div class="buy_payment_line_on">
                         	<p class="name">Credit card</p>
                            <p class="card" id="visa"><input name="R2ISelectPayment" id="R2ISelectPaymentVisa" type="radio" value="Visa" class="radio" onclick="changePayment2();"/>Visa</p>
                            <p class="card" id="master"><input name="R2ISelectPayment" id="R2ISelectPaymentMC" type="radio" value="MC" class="radio" onclick="changePayment2();"/>Master card</p>
                            <p class="card_note">*Credit Card verification with 3D Secure</p>
                            
                            <div class="clear"></div>
                         </div>
                         <div class="buy_payment_line_off">
                         	<p class="name">Paypal</p>
                            <p id="paypal"><input name="R2ISelectPayment" id="R2ISelectPaymentPP" type="radio" value="PP" class="radio" onclick="changePayment2();"/>PayPal Express Checkout</p>
                            <div class="clear"></div>
                         </div>
                         <div class="buy_payment_line_off">
                         	<p class="name">Cash</p>
                            <p id="transfer">
                            	<input name="R2ISelectPayment" id="R2ISelectPaymentMT" type="radio" value="MT" class="radio" onclick="changePayment2();"/>Money Transfer
                                <span class="money_note">(Via Western Union or Money Gram)</span>
                            </p>
                            <p id="deposit"><input name="R2ISelectPayment" id="R2ISelectPaymentDB" type="radio" value="DB" class="radio" onclick="changePayment2();"/>Direct Bank Deposit</p>
                            <div class="clear"></div>
                         </div>
                         
                         <div id="buy_payment_user">
							<p id="guide_title">User Guide</p>
                           	   <div id="creditcard_user">
                                	<div class="guide_box">
                                        <p class="guide_txt">When you pay by credit card you can immediately start using our service.</p>
                                        <p class="guide_txt">
                                            <strong>Credit Card verification with 3D Secure</strong><br />
                                            Please verify credit card information and register the personal identifying message of the credit card holder on the authentication page - provided by credit card issuer to use VISA and Master card online.<br />
                                            *This process may vary between different credit card issuing companies.
                                       </p>
                                        
                                        <p class="guide_txt">
                                            More information for Visa: <a href="https://usa.visa.com/personal/security/vbv/index.jsp" target="_blank">https://usa.visa.com/personal/security/vbv/index.jsp</a><br />
                                       More information for Master card: <a href="http://www.mastercard.us/support/securecode.html" target="_blank">http://www.mastercard.us/support/securecode.html</a>
                                       </p>
                                   </div>
                                   <div class="import_box">
                                   	<p class="note_title">Important note</p>
                                    <p class="note_txt">Do not click any buttons on the navigation bar of your browser during the payment process.</p>
                                    <p class="note_txt">Your account will be created as soon as you complete the purchase. If you're not given your account details, please contact us at <a href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Paypal enquiry">support@clarityenglish.com</a>.</p>
                                   
                                   
                                   </div>
                               </div>
                               
                               <div id="paypal_user">
                               		<div class="guide_box">
                                        <p class="guide_txt">When you pay by PayPal you can immediately start using our service.</p>
                                         <strong>Paypal instructions</strong><br />
                                        
                                        <p class="guide_txt">When you have completed your purchase at PayPal, you will see a page like the one below. You <span class="high">must click
"Return to Clarity Language Consultants Ltd" at the bottom</span> to return to IELTSPractice.com. <span class="high">Otherwise, your
account won't be created.</span></p>
                                        <p class="guide_txt">To find out more about PayPal, go to <a href="http://www.paypal.com" target="_blank">www.paypal.com</a>.</p>
                                    </div>
                                    
                                    <div class="img_paypal"></div>
                                    
                                 <div class="import_box">
                                   	<p class="note_title">Important note</p>
                                    <p class="note_txt">PayPal Pop-up window will be shown when you click on [Pay] button</p>
                                   <p class="note_txt">Your account will be created as soon as you complete the purchase. If you're not given your account details, please contact us at <a href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Paypal enquiry">support@clarityenglish.com</a>.</p>
                                   
                                   
                                 </div>
                                    
                               </div>
                               
                               <div id="moneytransfer_user">
                           		 <div class="guide_box">
                                   <p class="guide_txt">You account will be activated as soon as the payment has been confirmed.</p>
                                         <p class="guide_txt"><strong>Pay by Money Transfer</strong></p>
                                         
                                         <p class="guide_txt">Money Transfer is the fastest way to transfer money to us. Payment is usually received within 1 day. Two well known money transfer companies are Western Union and MoneyGram.</p>
                                         
                                         <ul class="guide_list">
                                             <li>Locate your nearest money transfer agent. (Go to <a href="http://www.westernunion.com" target="_blank">www.westernunion.com</a> or <a href="www.moneygram.com">www.moneygram.com</a>).</li>
                                             <li>Go to the agent’s office and pay the above amount.
                                             <li>Make your payment to:<br />
                                                Clarity Languange Consultants Ltd.<br />
                                                PO Box 9674<br />
                                                Sai Kung, Hong Kung<br />
                                            </li>
                                            <li>Send us an email when you have completed the payment so we know it has been sent. In the email please give
your name and <span class="high">quote the above reference number</span> and the <span class="high">money transfer number</span>.</li>
                                        </ul>
                                 </div>
                                    
                                    <div class="import_box">
                                       <p class="note_title">Important note</p>
                           
                                       <p class="note_txt">The money transfer information will be sent to you as soon as you click on [Pay] button. If you don't receive our email, please contact us at <a href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Money transfer enquiry">support@clarityenglish.com</a>.</p>
                                       
                                       <p class="note_txt">Remember to advise us via email when your payment has been sent so that we know that it is on the way.</p>
                                       
                                 </div>
                                    
                           </div>
                           
                               <div id="directbank_user">
                                    <div class="guide_box">
                                         <p class="guide_txt">An email will be sent to you with the payment instructions. You account will be activated as soon as the payment
    has been confirmed.</p>
                                         <p class="guide_txt"><strong>Pay by Direct Bank Deposit</strong></p>                                     
                                         <p class="guide_txt">Please make all cheques or bank drafts payable to:<br /><span class="high">Clarity Language Consultants Ltd</span></p>
                                         <p class="guide_txt">
                                            Payable to: Clarity Language Consultants Ltd<br />
                                            SWIFT number: HSBC HKHH<br />
                                            Bank code: 054<br />
                                            Branch code: 055<br />
                                            Account number: 055 808 729 838 AUD savings<br />
                                            Bank address: HSBC, Sai Kung Office, Shop 9, Sai Kung Gardens, Sai Kung, Hong Kong<br />
                                            Please note that the sum received in payment must be nett of bank charges.
                                        </p>
                                     </div>
                                     
                                     <div class="import_box">
                                           <p class="note_title">Important note</p>
                               
                                           <p class="note_txt">The bank information will be sent to you as soon as you click on [Pay] button. If you don't receive our email, please contact us at <a href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Bank transfer enquiry">support@clarityenglish.com</a>.</p>
                                           
                                           <p class="note_txt">Remember to advise us via email when your payment has been sent so that we know that it is on the way.</p>
                                           
                                     </div>
                                        
                               </div>
                         
                         </div>
                         
                         
                         
                         
                    
                    </div>
                    <div class="buy_payment_note">
                    	<p class="note_title">Having trouble with payment?</p>
                        <p class="txt">If you have any problem by card payment, please contact Clarity support by email support@clarityenglishc.com, on +44 (0) 845 130 5627 or +852 2791 1787 (Monday to Friday, GMT xx:30 - xx:30)</p>
                    
                    </div>
                    
                    
                    <div class="buy_payment_note">
                    	<p class="gate_title">Gateway powered by: </p>
                        <p class="txt">Online transaction processing is provided by PayDollar using Extended Validation 256-bit SSL encryption. All confidential information is encrypted before it is transmitted, to protect the data from being read and interpreted. 3-D Secure authentication is also supported by Verified by Visa and Mastercard SecureCode.</p>
                    
                    </div>
                    
                    <div class="buy_payment_note">
                    	<p class="note_title">Paypal verified</p>
                        <a id="img_paypal_seal" href="https://www.paypal.com/uk/verified/pal=adrian.raper@clarityenglish.com" target="_blank"></a>
                        <p class="txt">Clarity is a legitimate PayPal verified user, we are enrolled in PayPal Expanded Use Programme. Paypal's verification process increases security when you pay parties you do not know. Click on the icon and log in to Paypal to learn more.</p>
                    
                    </div>
                    
                    
                    
                    
                    <div id="buy_content">
                    
                    	 <div id="buy_terms_link">
                         <input name="RTINewsletter" id="RTINewsletter" type="checkbox" value="" />I have carefully reviewed and agree with the terms and conditions.
                         </div>
                    	 
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         <div class="buy_button_area">
                            <div class="btn_blue_general" onclick="Backward('1')">Back</div>
                            <div class="btn_blue_general" onclick="SaveAndGo('3')">Review and Pay</div>
                        
                            <div class="buy_comment">
                                <!--div class="form_waiting" id="form_waiting" style="display:none">Please wait...</div>
                                <div class="form_ok" id="form_ok" style="display:none">Sent successfully</div-->
                                <div class="form_oops" name="R2IStep2Msg" id="R2IStep2Msg" style="display:none"></div>
                             </div>
                            <div class="clear"></div>
                    	</div>

                    
                    </div>
                    
                    <div class="clear"></div>
                </div>
                        
                
               
               <div class="buy_txt">
               		
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
               
               
               
               </div>
               
               
               
            
            
            
            </div>
            
                        <div id="content_box_buy">
                            <div id="buy_box">
                                            <p class="title">Step 3: Review details and pay</p>
                                            <div id="buy_step_1_off"><span class="num_off">1</span> Choose your subscription</div>
                                            <div id="buy_step_2" class="buy_off"><span class="num_off">2</span> Choose your payment method</div>
                                            <div id="buy_step_3" class="buy_on"><span class="num_on">3</span> Review and Pay</div>
                                            <div id="buy_step_4" class="buy_off"><span class="num_off">4</span> Start learning</div>
                                            <div class="clear"></div>
                                        </div>
                            
                            <div id="buy_container">
                                
                                <div id="buy_content">
                                <p class="review_des">Please carefully review your details below. Click back to make changes or forward to proceed to payment.</p>
                                    <div id="buy_review_content">
                                        
                                       
                                        <div class="review_title">user information</div>
                                        <div class="review_box">
                                            
                                           
                                            <p class="review_txt"><strong>Your email:</strong> <label id="R2IReviewEmail"></label></p>
                                            <p class="review_txt"><strong>Your password:</strong> <label id="R2IReviewPassword"></label></p>
                                            <p class="review_txt"><strong>Your name:</strong> <label id="R2IReviewName"></label></p>
                                            <p class="review_txt"><strong>Phone:</strong> <label id="R2IReviewPhone"></label></p>
                                            <p class="review_txt"><strong>Country:</strong> <label id="R2IReviewCountry"></label></p>
                                            <p class="review_txt"><strong>Payment method:</strong> <label id="R2IReviewPaymentMethod"></label></p>
                                        </div>
                                        
                                        <div class="review_title">Program options</div>
                                        <div class="review_box">
                                            <!--p class="review_txt">Credit card: <strong>Visa</strong> (Credit Card verification with 3D Secure)</p-->
                                            <p class="review_txt"><strong>Module:</strong> <label id="R2IReviewModule"></label></p>
                                            <p class="review_txt"><strong>Subscription period:</strong> <label id="R2IReviewSubscriptionPeriod"></label>  (USD <label id="R2IReviewTotalAmount"></label>)</p>
                                            <p class="review_txt"><strong>Expires on:</strong> 18 June 2012</p>
                                            
                                        </div>
                                        
                                        <div class="review_total">
                                            <p class="title">Total amount</p>
                                            <p class="money">US$ 49.99</p>
                                            <div class="clear"></div>
                                        </div>
                                        
                                
                                        
                                        
                                    
                                    
                                    </div>
                                     
                                     <div class="buy_button_area">
                                        <div class="btn_blue_general" onclick="Backward('2')">Back</div>
                                        <div class="btn_blue_general" onclick="processCheckOut()">Pay</div>
                                    
                                        <div class="buy_comment">
                                            <!--div class="form_waiting" id="form_waiting" style="display:none">Please wait...</div>
                                            <div class="form_ok" id="form_ok" style="display:none">Sent successfully</div-->
                                            <div class="form_oops" name="R2IStep3Msg" id="R2IStep3Msg" style="display:none"></div>
                                         </div>
                                        <div class="clear"></div>
                                    </div>
            
                                
                                </div>
                                
                                <div class="clear"></div>
                            </div>
                                    
                            
                        
                        </div>
                        
                        
                        <div id="content_box_buy">
                            <div id="buy_box">
                                            <p class="title">Step 4: Start learning</p>
                                            <div id="buy_step_1_off"><span class="num_off">1</span> Choose your subscription</div>
                                            <div id="buy_step_2" class="buy_off"><span class="num_off">2</span> Choose your payment method</div>
                                            <div id="buy_step_3" class="buy_off"><span class="num_off">3</span> Review and Pay</div>
                                            <div id="buy_step_4" class="buy_on"><span class="num_on">4</span> Start learning</div>
                                            <div class="clear"></div>
                                        </div>
                            
                            <div id="buy_start_email">
                            	<p class="buy_start_title">Thank you!</p>
                                <p class="buy_start_subtitle">Your order details has been sent to us.</p>
                                <p class="buy_start_txt">An email has been sent to you with the payment instructions. Please follow the steps
                                and as soon as the payment has been confirmed Road to IELTS will be activated.</p>
                              <p class="buy_start_txt">Please include the your full name and given reference number in the email along with
                              the bank receipt.</p>
                                
                                <p class="buy_start_smtitle">Program options</p>
                                <p class="buy_start_txt">
                                    <strong>Module:</strong> Academic Module<br />
                                    <strong>Subscription period:</strong> 1 month<br />
                                    <strong>Expires on:</strong> 30.June.2012                              </p>
                                
                                <p class="buy_start_smtitle">Payment amount</p>
                                <p class="buy_start_txt"><strong>USD $49.99</strong></p>
                                
                            	
                                <p class="buy_start_smtitle">Payment details</p>
                              <p class="buy_start_txt"><strong>Reference number:</strong> ABCDEFG</p>
                             
                          </div>
                                    
                            
                        
                        </div>
                        
                        <div id="content_box_buy">
                            <div id="buy_box">
                                            <p class="title">Step 4: Start learning</p>
                                            <div id="buy_step_1_off"><span class="num_off">1</span> Choose your subscription</div>
                                            <div id="buy_step_2" class="buy_off"><span class="num_off">2</span> Choose your payment method</div>
                                            <div id="buy_step_3" class="buy_off"><span class="num_off">3</span> Review and Pay</div>
                                            <div id="buy_step_4" class="buy_on"><span class="num_on">4</span> Start learning</div>
                                            <div class="clear"></div>
                                        </div>
                            
                            <div id="buy_start_learn">
                            	<p class="buy_start_title">Thank you!</p>
                                <p class="buy_start_subtitle">We have successfully created your account.<br />
An email will also be sent to you with your login details.</p>
                                
                              
                                
                                <p class="buy_start_smtitle">Login details</p>
                                <p class="buy_start_txt">
                                    <strong>Login name:</strong> somename@email.com<br />
                                    <strong>Password:</strong> Halohalo<br />
                                </p>
                                
                                <p class="buy_start_smtitle">Account details</p>
                                <p class="buy_start_txt">
                                    <strong>User name:</strong> Jones<br />
                                    <strong>Subscription period:</strong> 1 month<br />
                                    <strong>Expires on:</strong> 30 June 2012<br />
                                    <strong>Module:</strong> Academic module
                                </p>
                                
                                <p class="buy_start_smtitle">Payment amount</p>
                                <p class="buy_start_txt"><strong>USD $49.99</strong></p>
                                
                            	
                                <p class="buy_start_smtitle">Payment details</p>
                              	<p class="buy_start_txt"><strong>Reference number:</strong> ABCDEFG</p>
                                
                                <a class="btn_start_learn" target="_blank" href="#">Start learning now!</a>
                             
                          </div>
                                    
                            
                        
                        </div>
                        
                        <div id="content_box_buy">
                            <div id="buy_box">
                                            <p class="title">Step 4: Start learning</p>
                                            <div id="buy_step_1_off"><span class="num_off">1</span> Choose your subscription</div>
                                            <div id="buy_step_2" class="buy_off"><span class="num_off">2</span> Choose your payment method</div>
                                            <div id="buy_step_3" class="buy_off"><span class="num_off">3</span> Review and Pay</div>
                                            <div id="buy_step_4" class="buy_on"><span class="num_on">4</span> Start learning</div>
                                            <div class="clear"></div>
                                        </div>
                            
                          <div id="buy_start_error">
                           	<p class="buy_start_error_title">We’re sorry,</p>
                                <p class="buy_start_error_subtitle">your payment was not successful.</p>
                                
                              
                                <div class="buy_start_error_box">
                                    <p class="buy_start_smtitle">Possible cause(s) :</p>
                                    <p class="buy_start_txt">
                                        (Session.CLS_message:)
                                    </p>
                            </div>
                                
                                
                                <div class="buy_start_error_box">
                                    <p class="buy_start_smtitle">Possible solution(s):</p>
                                    <ul>
                                        <li>Please check the information entered and see if you can continue your registration.</li>
                                        <li>Please contact the Clarity Support Team at support@clarityenglish.com. We will get back to you within
                                        one working day.</li>
                                        <li>If payment by credit card has failed, please use PayPal to complete the purchase.</li>
                                    </ul>
                                </div>
                                
                            <div class="buy_start_error_box">
                                    <p class="buy_start_smtitle">Error details:</p>
                                    <ul>
                                        <li>Please check the information entered and see if you can continue your registration.</li>
                                        <li>Please contact the Clarity Support Team at support@clarityenglish.com. We will get back to you within
one working day.</li>
                                     
                                    </ul>
                            </div>
                                
                                
                                <div class="buy_button_area">
                                        <a class="btn_blue_general">Try again</a>
                                        <a class="btn_blue_general" href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Payment error">Send us an email</a>
                            
                                    
                                        
                                        <div class="clear"></div>
                            </div>
                                
                                
                                
                               
                                
                                
                             
                          </div>
                                    
                            
                        
                        </div>
                        
                        <div id="content_box_buy">
                            <div id="buy_box">
                                            <p class="title">Step 3: Review and Pay</p>
                                            <div id="buy_step_1_off"><span class="num_off">1</span> Choose your subscription</div>
                                            <div id="buy_step_2" class="buy_off"><span class="num_off">2</span> Choose your payment method</div>
                                            <div id="buy_step_3" class="buy_on"><span class="num_on">3</span> Review and Pay</div>
                                            <div id="buy_step_4" class="buy_off"><span class="num_off">4</span> Start learning</div>
                                            <div class="clear"></div>
                                        </div>
                            
                            <div id="buy_start_loading">
                             <p class="title">Redirecting...</p>
                            	<div id="buy_start_loading_inner">
                                <img src="images/ajax-loading.gif" />
                            	  <p class="txt">This page will be redirected to the payment gateway shortly.<br />
(Do not click any buttons ont eh navigation bar of your browser)</p>
                              
</div>
                                
                              
                                
                                
                                
                                
                                
                                
                                
                               
                             
                          </div>
                                    
                            
                        
                        </div>
                        
                        <div id="content_box_buy">
                            <div id="buy_box">
                                            <p class="title">Step 3: Review and Pay</p>
                                            <div id="buy_step_1_off"><span class="num_off">1</span> Choose your subscription</div>
                                            <div id="buy_step_2" class="buy_off"><span class="num_off">2</span> Choose your payment method</div>
                                            <div id="buy_step_3" class="buy_on"><span class="num_on">3</span> Review and Pay</div>
                                            <div id="buy_step_4" class="buy_off"><span class="num_off">4</span> Start learning</div>
                                            <div class="clear"></div>
                                        </div>
                            
                            <div id="buy_start_loading">
                             <p class="title">You're almost there...</p>
                            	<div id="buy_start_loading_inner">
                                <img src="images/ajax-loading.gif" />
                            	  <p class="txt">Please wait while we create your account...<br />
 (Do not click any buttons on the navigation bar of your browser.)</p>
                              
</div>
                                
                              
                                
                                
                                
                                
                                
                                
                                
                               
                             
                          </div>
                                    
                            
                        
                        </div>
                        
                        
                
                
                
                </div>
			</form>
				
            
            
        </div>
        <div id="footer">
        Data &copy; The British Council 2006 - 2012. Software &copy; Clarity Language Consultants Ltd, 2012. All rights reserved.
        </div>
    </div>


</body>
</html>
<script type="text/javascript">
nextStep("1");
</script>