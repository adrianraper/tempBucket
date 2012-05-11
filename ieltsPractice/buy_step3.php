<?php
	session_start();
	//require_once(dirname(__FILE__)."/languageOps.php");
?>
<div id="content_box_buy">
                            <div id="buy_box">
                                <p class="title">Step 3: Review and pay</p>
                                <div id="buy_step_1" class="buy_off"><span class="num">1</span>Enter your subscription details</div>
                                <div id="buy_step_2" class="buy_off"><span class="arrow"></span><span class="num">2</span>Choose your payment method</div>
                                <div id="buy_step_3" class="buy_on"><span class="arrow"></span><span class="num">3</span>Review and pay</div>
                                <div id="buy_step_4" class="buy_off"><span class="arrow"></span><span class="num">4</span>Start studying</div>
                                <div class="clear"></div>
                            </div>
                            
                            <div id="buy_container">
                                
                                <div id="buy_content">
                                <p class="review_des">Please carefully review your details below. Click back to make changes or click Pay to process.</p>
                                    <div id="buy_review_content">
                                        
                                       
                                        <div class="review_title">Member information</div>
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
                                            <p class="review_txt"><strong>Subscription period:</strong> <label id="R2IReviewSubscriptionPeriod"></label>  (US$ <label id="R2IReviewAmount"></label>)</p>
                                            <p class="review_txt"><strong>Expires on:</strong> <label id="R2IReviewExpiryDate"></label></p>
                                            
                                        </div>
                                        
                                        <div class="review_total">
                                            <p class="title">Total amount</p>
                                            <p class="money">US$ <label id="R2IReviewTotalAmount"></label></p>
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