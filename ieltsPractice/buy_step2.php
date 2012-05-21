<?php
	session_start();
	//require_once(dirname(__FILE__)."/languageOps.php");
?>
<link rel="stylesheet" type="text/css" href="css/home.css" />
<link rel="stylesheet" type="text/css" href="css/buy.css" />

		<div id="content_box_buy">
            				<div id="buy_box">
                                <p class="title">Step 2: Choose your payment method</p>
                                <div id="buy_step_1" class="buy_off"><span class="num">1</span>Enter your subscription details</div>
                                <div id="buy_step_2" class="buy_on"><span class="arrow"></span><span class="num">2</span>Choose your payment method</div>
                                <div id="buy_step_3" class="buy_off"><span class="arrow"></span><span class="num">3</span>Review and pay</div>
                                <div id="buy_step_4" class="buy_off"><span class="arrow"></span><span class="num">4</span>Start studying</div>
                                <div class="clear"></div>
                            </div>
                
                <div id="buy_container">
                	<div id="buy_payment_content">
                    	 <p id="method_title">Please choose your payment method:</p>
                         <div class="buy_payment_line_on">
                         	<p class="name">Credit card</p>
                            <p class="card" id="visa"><input name="R2ISelectPayment" id="R2ISelectPaymentVisa" type="radio" value="Visa" class="radio" onclick="changePayment2();"/>Visa</p>
                            <p class="card" id="master"><input name="R2ISelectPayment" id="R2ISelectPaymentMC" type="radio" value="MC" class="radio" onclick="changePayment2();"/>MasterCard</p>
                            <p class="card_note">*Credit card verification with 3-D Secure</p>
                            
                            <div class="clear"></div>
                         </div>
                         <div class="buy_payment_line_off">
                         	<p class="name">PayPal</p>
                            <p id="paypal"><input name="R2ISelectPayment" id="R2ISelectPaymentPP" type="radio" value="PP" class="radio" onclick="changePayment2();"/>PayPal Express Checkout</p>
                            <div class="clear"></div>
                         </div>
                         <div class="buy_payment_line_off" style="display:none">
                         	<p class="name">Cash</p>
                            <p id="transfer">
                            	<input name="R2ISelectPayment" id="R2ISelectPaymentMT" type="radio" value="MT" class="radio" onclick="changePayment2();"/>Western Union money transfer
                                
                            </p>
                            <p id="deposit"><input name="R2ISelectPayment" id="R2ISelectPaymentDB" type="radio" value="DB" class="radio" onclick="changePayment2();"/>
                            Direct bank deposit</p>
                            <div class="clear"></div>
                         </div>
                         
                         <div id="buy_payment_user" style="display:none">
							<p id="guide_title">User guide</p>
                           	   <div id="creditcard_user">
                                	<div class="guide_box">
                                        <p class="guide_txt">You will be able to start using Road to IELTS as soon as your credit card payment has been approved.</p>
                                        <p class="guide_txt">
                                            <strong>Credit card verification with 3-D Secure</strong><br />
                                            Please verify your credit card information and register the personal identifying message of the credit card holder on the authentication page - provided by credit card issuer to use VISA and MasterCard online.<br />
                                            *This process may vary between different credit card issuing companies.
                                       </p>
                                        
                                        <p class="guide_txt">
                                            More information for Visa: <a href="https://usa.visa.com/personal/security/vbv/index.jsp" target="_blank" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step2_link_3dvisa']);">https://usa.visa.com/personal/security/vbv/index.jsp</a><br />
                                       More information for MasterCard: <a href="http://www.mastercard.us/support/securecode.html" target="_blank" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step2_link_3dmaster']);">http://www.mastercard.us/support/securecode.html</a>
                                       </p>
                                   </div>
                                   <div class="import_box">
                                   	<p class="note_title">Important note</p>
                                    <p class="note_txt">Do not click any buttons on the navigation bar of your browser during the payment process.</p>
                                    <p class="note_txt">Your account will be created as soon as you complete the purchase. If you're not given your account details, please contact us at <a href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Credit Card enquiry">support@clarityenglish.com</a>.</p>
                                   
                                   
                                   </div>
                               </div>
                               
                               <div id="paypal_user">
                               		<div class="guide_box">
                                        <p class="guide_txt">When you pay by PayPal you can immediately start using our service.</p>
                                         <strong>PayPal instructions</strong><br />
                                        
                                        <p class="guide_txt">PayPal pop-up window will be shown when you click on Pay button. When you have completed your purchase at PayPal, you will see a page like the one below. You <span class="high">must click
"Return to Clarity Language Consultants Ltd" at the bottom</span> to return to IELTSPractice.com. <span class="high">Otherwise, your
account won't be created.</span></p>



                                        <p class="guide_txt">To find out more about PayPal, go to <a href="http://www.paypal.com" target="_blank" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step2_link_paypal']);">www.paypal.com</a>.</p>
                                    </div>
                                    
                                    <div class="img_paypal"></div>
                                    
                                 <div class="import_box">
                                   	<p class="note_title">Important note</p>
                                  
                                   <p class="note_txt">Your account will be created as soon as you complete the purchase. If you're not given your account details, please contact us at <a href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Paypal enquiry">support@clarityenglish.com</a>.</p>
                                   
                                   
                                 </div>
                                    
                               </div>
                               
                               <div id="moneytransfer_user"  style="display:none;">
                           		 <div class="guide_box">
                                   <p class="guide_txt">You account will be activated as soon as  payment has been confirmed.</p>
                                   <p class="guide_txt"><strong>Paying by money transfer</strong></p>
                                         
                                         <p class="guide_txt">Payment is usually received within 1 day. Here is how you can pay by Western Union:</p>
                                         
                                         <ul class="guide_list">
                                             <li>Locate your nearest Western Union money transfer agent. (Go to <a href="http://www.westernunion.com" target="_blank" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step2_link_westernunion']);">www.westernunion.com</a>).</li>
                                             <li>Go to the agent's office and pay the above amount in <span class="high">US Dollars</span>.</li>
                                             <li>Advise agent the special instruction: <span style="color:#0A436E; font-weight:bold;">Recipient must receive money in US$ (not Hong Kong Dollars)</span></li>
                                             <li>Make your payment to: <br />Ng, Ka Pui Christine</li>
                                           	 <li>Send us an email when you have completed the payment so we know it has been sent. In the email please provide:<br />
                
                                                <ol class="guide_num">
                                                    <li>Sender name</li>
                                                    <li>Sender Country</li>
                                                    <li>Money Control Transfer Number (10-digit)</li>
                                                    <li>Quote the reference number</li>
                                                </ol>
                
              
                                            </li>
                                        </ul>
                                 </div>
                                    
                                    <div class="import_box">
                                       <p class="note_title">Important note</p>
                           
                                       <p class="note_txt">The money transfer information will be sent to you as soon as you click on [Pay] button. If you don't receive our email, please contact us at <a href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Money transfer enquiry">support@clarityenglish.com</a>.</p>
                                       
                                       <p class="note_txt">Remember to advise us via email when your payment has been sent so that we know that it is on the way.</p>
                                       
                                 </div>
                                    
                           </div>
                           
                               <div id="directbank_user"  style="display:none;">
                                    <div class="guide_box">
                                         <p class="guide_txt">An email will be sent to you with the payment instructions. You account will be activated as soon as the payment
    has been confirmed.</p>
                                         <p class="guide_txt"><strong>Pay by direct bank deposit</strong></p>                                     
                                         
                                         <p class="guide_txt">
                                            Payable to: Clarity Language Consultants Ltd<br />
                                            SWIFT number: HSBC HKHH<br />
                                            Bank code: 054<br />
                                            Branch code: 055<br />
                                            Account number:  055 808 729 838 USD savings<br />
                                            Bank address: HSBC, Sai Kung Office, Shop 9, Sai Kung Gardens, Sai Kung, Hong Kong
                                         </p>
                                         <p class="guide_txt">Send us an email when you have completed the payment so we know it has been sent. In the email please provide your:
                                         <ol class="guide_num">
                                                        <li>Sender name</li>
                                                        <li>Sender Country</li>
                                                        <li>Bank transactions reference number</li>
                                                        <li>Quote the above reference number</li>
                                                </ol>
                                         </p>
                                       
                                     </div>
                                     
                                     <div class="import_box">
                                           <p class="note_title">Important note</p>
                               
                                           <p class="note_txt">The bank information will be sent to you as soon as you click on Pay button. If you don't receive our email, please contact us at <a href="mailto: support@clarityenglish.com?subject=IELTSPractice.com Bank transfer enquiry">support@clarityenglish.com</a>.</p>
                                           
                                       <p class="note_txt">Remember to advise us via email when your payment has been sent so  we know that it is on the way.</p>
                                           
                                 </div>
                                        
                               </div>
                         
                         </div>
                         
                         
                         
                         
                    
                    </div>
                    <div class="buy_payment_note">
                    	<p class="note_title">Having trouble with payment?</p>
                        <p class="txt">If you have any problems with payment, please contact Clarity support by email at <a href="mailto:support@clarityenglish.com?Subject=IELTSPractice.com payment trouble">support@clarityenglish.com</a>, on +44 (0) 845 130 5627 or +852 2791 1787, Monday to Friday 09:30 - 18:30 (GMT +8.00).</p>
                    
                    </div>
                    
                    
                    <div class="buy_payment_note" id="buy_paydollar"  style="display:none;">
                    	<p class="gate_title">Gateway powered by: </p>
                        <p class="txt">Online transaction processing is provided by PayDollar using Extended Validation 256-bit SSL encryption. All confidential information is encrypted before it is transmitted, to protect the data from being read and interpreted. 3-D Secure authentication is also supported by Verified by Visa and MasterCard SecureCode.</p>
                    
                    </div>
                    
                    <div class="buy_payment_note" id="buy_paypal"  style="display:none;">
                    	<p class="note_title">Paypal verified</p>
                        <a id="img_paypal_seal" href="https://www.paypal.com/uk/verified/pal=adrian.raper@clarityenglish.com" target="_blank" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/internal-links/buy/step2_link_paypal_verify']);"></a>
                        <p class="txt">Clarity is a legitimate PayPal verified user, we are enrolled in PayPal Expanded Use Programme. Paypal's verification process increases security when you pay parties you do not know. Click on the icon and log in to PayPal to learn more.</p>
                    
                    </div>
                    
                    
                    
                    
                    <div id="buy_content">
                    
                    	 <div id="buy_terms_link">
                         <input name="RTINewsletter" id="RTIAgreeTerms" type="checkbox" value="" />I have carefully reviewed and agree with the <a href="terms.php" target="_blank" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step2_link_terms']);">terms and conditions</a>.                         </div>
                    	 
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         <div class="buy_button_area">
                            <div class="btn_blue_general" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step2_btn_back']); Backward('1')">Back</div>
                            <div class="btn_blue_general" onclick="_gaq.push(['_trackPageview', 'internal-links/buy/step2_btn_reviewpay']); SaveAndGo('3')">Review and Pay</div>
                        
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