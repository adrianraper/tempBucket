<script src="/bootstrap/js/supportEnquiry.js"></script>
<?php $currentSelection="support"; ?>
<?php $supportSelection="contact"; ?>
<?php $eoSelection="support"; ?>

<div class="P-E7DAE9-bg">
<div class="container ">
	 <div class="row support-ticket">
                <div class="col-lg-6 col-md-6 col-sm-5 support-left">
                	<div class="support-ticket-help">
                        <p id="support-header" class="general-subtag">Need help?</p>
                        <p class="general-text">Contact our Support Team at <span class="general-bold-tag">support@clarityenglish.com </span>or fill in the enquiry form here.</p>
                    </div>
					
                    <div class="support-ticket-pledge">
					<p class="general-subtag">Technical support pledge</p>

					<p class="general-text">
                    My aim is to ensure you have smooth, trouble-free use of any software you purchase from Clarity. 
					I therefore guarantee to find a fast and effective solution to any technical problems related to Clarity software, or provide a full refund.</p>
                    <p class="general-text">
                    Dr Adrian Raper, 
                    </p>
                    <p class="general-text">
                    Technical Director
                    </p>
                   	 
                    </div>
                </div>
              <!---------- start of Price enquiry section---------->
              <div class="col-lg-6 col-md-6 col-sm-7 support-right">
              	<div class="support-lead-detail general-shadow">
                   <form>
                              <div class="form-group">
                                <input type="text" id="F_Name" class="form-control general-text" placeholder="Your name*">
                              </div>
							  
							  <div class="form-group">
                                <input type="email" id="F_Email" class="form-control general-text" id="exampleInputEmail1" placeholder="Your email*">
                              </div>
							  
                              <div class="form-group">
                                <input type="text" id="F_Institution" class="form-control general-text" placeholder="Your institution*">
                              </div>
                              
                              <div class="form-group">
                                  <select id="F_Program" class="form-control general-text lead-form-select productlist" name="productlist">
                                               <option value="" selected>I would like to ask about*</option>
											   <option value="ar">Active Reading</option>
                                               <option value="bw">Business Writing</option>
                                               <option value="cpone">Clear Pronunciation 1 (Sounds)</option>
                                               <option value="cptwo">Clear Pronunciation 2 (Speech)</option>
                                               <option value="dpt">Dynamic Placement Test</option>
                                               <option value="rm">Results Manager</option>
                                               <option value="rti">Road to IELTS</option>
                                               <option value="sss">Study Skills Success</option>
                                               <option value="tb">Tense Buster</option>
											   <option value="pw">Practical Writing</option>
                                               <option value="others">Others</option>
                                  </select>
								
                               </div>
                               
                              
									
							  <div class="form-group">
                                <input type="text" id="F_SerialNo" class="form-control general-text" placeholder="Your serial number">
                              </div>
                              
                              


                              <div class="form-group">
                              <textarea id="F_Message" class="form-control general-text" placeholder="Your message to us*" rows="6"></textarea>
                              </div>
                              <!---errormsg--->
                               <div id="errorMsgMissingField" class="lead-warn-field lead-warn-box">
                                <p class="general-text error-msg">Please fill in the missing field(s) and click Send.</p>
                              </div>

                              <div id="errorMsgEmail" class="lead-warn-email lead-warn-box">
                                <p class="general-text error-msg">Please input a valid email address.</p>
                              </div>
                              <!---errormsg--->
                              
                              <div class="general-button-box">
                                <button type="button" id="btnSend" class="btn btn-default general-input-btn input-bg-p" onclick="verifySupportEnquiryForm();">Send</button>
                              </div>
                                
                    </form>
                    </div>
              </div>
              <!---------- end of price enquiry section---------->
                
              </div>
	
</div>
</div>