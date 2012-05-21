<?php
	session_start();
	//require_once(dirname(__FILE__)."/languageOps.php");
?>

<link rel="stylesheet" type="text/css" href="css/home.css" />
<link rel="stylesheet" type="text/css" href="css/buy.css" />

			<div id="content_box_buy">
                            <div id="buy_box">
                                <p class="title">Step 1: Enter your subscription details</p>
                                <div id="buy_step_1" class="buy_on"><span class="num">1</span>Enter your subscription details</div>
                                <div id="buy_step_2" class="buy_off"><span class="arrow"></span><span class="num">2</span>Choose your payment method</div>
                                <div id="buy_step_3" class="buy_off"><span class="arrow"></span><span class="num">3</span>Review and pay</div>
                                <div id="buy_step_4" class="buy_off"><span class="arrow"></span><span class="num">4</span>Start studying</div>
                                <div class="clear"></div>
                            </div>
                
                            <div class="buy_container">
                                <div id="buy_content">
                        
                                     
                                     <div class="buy_field_box">
                                         <p class="subtitle">A. Choose your Road to IELTS module:</p>
                                         <div class="buy_inner_box">
                                             
                                                <div class="choose_box_container">
                                                     <div class="choose_box">
                                                        <div class="choose_radio"><input name="R2ISelectModule" id="R2ISelectModuleAC" type="radio" value="52" checked="yes" /></div>
                                                        <div id="choose_RTIA" class="on">Academic module</div>
                                                     </div>
                                                     <div class="choose_box">
                                                        <div class="choose_radio"><input name="R2ISelectModule" id="R2ISelectModuleGT" type="radio" value="53" /></div>
                                                        <div id="choose_RTIG" class="on">General Training module</div>
                                                     </div>
                                                     <div class="clear"></div>
                                                 </div>
                           
                                                 <p class="buy_notsure">Not sure? Click <a href="http://takeielts.britishcouncil.org/choose-ielts/ielts-academic-or-ielts-general-training?utm_source=Buy&utm_medium=txt_notsure&utm_campaign=Step%2B1" target="_blank">here</a>.</p>
                                                 <div class="buy_field_line">
                                                     </div>
                                       
                                       </div>
                                         
                                         
                                         
                                     </div>
                                     
                                     <div class="buy_field_box">
                                         <p class="subtitle">B. Choose your subscription period:</p>
                                         <div class="buy_inner_box">
                          
                                                     <div class="month_box">
                                                        <div class="choose_radio"><input name="R2ISelectSubscription" id="R2ISelectSubscription1m" type="radio" value="31" checked="yes" /></div>
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
                                                <input name="RTIChooseEmail" id="RTIChooseEmail" type="text" class="field" onblur="checkEmail()" value="" />
                                                <p class="note" id="RTIEmailValid">(This will be your login name.)</p>
                                                <div class="clear"></div>
                                                <p class="error" name="RTIEmailError" id="RTIEmailError"></p>
                                        
                                            </div>
                                            
                                            <div class="buy_field_line">
                                                <p class="name">Your password:</p>
                                                <input name="RTIChoosePassword" id="RTIChoosePassword" type="password" class="field"  value=""/>
                                                <!--p class="note">(8-15 English alphabet characters)</p-->
                                                <p class="note"></p>
                                                <div class="clear"></div>
                                                <p class="error" name="RTIPasswordError" id="RTIPasswordError"></p>
                                        
                                            </div>
                                            
                                            <div class="buy_field_line">
                                                <p class="name">Retype password:</p>
                                                <input name="RTIRetypePassword" id="RTIRetypePassword" type="password" class="field"  value=""/>
                                                
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
                                                <input name="RTIName" id="RTIName" type="text" class="field"  value=""/>
                                                <p class="note">(We will use this name in emails.)</p>
                                                <div class="clear"></div>
                                                <p class="error" name="RTINameError" id="RTINameError" style="display:none"></p>
                                        
                                            </div>
                                            
                                            
                                            <div class="buy_field_line">
                                                <p class="name">Phone:</p>
                                                <input name="RTIPhone" id="RTIPhone" type="text" class="field"  value=""/>
                                                <p class="note">(Optional: In case we need to contact you.)</p>
                                              <div class="clear"></div>
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
                                                <p class="note">(Optional: This is for research purposes.)</p>
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
                                                <input name="RTINewsletter" id="RTINewsletter" type="checkbox" value="yes" />I would like to receive the latest news from Clarity.
                                            </div>
                                         
                                         </div>
                                     </div>
                                     
                                     
                                     <div class="buy_button_area">
                                        <div class="btn_blue_general" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step1_btn_continue']); SaveAndGo('2')">Continue</div>
                                    
                                        <div class="buy_comment">
                                            <div class="form_waiting" name="RTIMsgWait" id="RTIMsgWait" style="display:none">Please wait...</div>
                                            <div class="form_oops" name="RTIMsgError" id="RTIMsgError" style="display:none">Please fill in the required fields</div>
                                         </div>
                                        <div class="clear"></div>
                                    </div>
                                
                                </div>
                                <div id="buy_content_left">
                                
                                    <div id="buy_questions"><a href="mailto:support@clarityenglish.com?subject=IELTSPractice.com enquiry"></a></div>
                                    <div id="buy_banner"></div>
                                </div>
                                <div class="clear"></div>
                            </div>
                        
                
               
               <div class="buy_txt">
               </div>
			</div>