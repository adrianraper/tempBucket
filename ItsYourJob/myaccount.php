<?php
session_start();
date_default_timezone_set('UTC');
?>
<!--Don't Upload: CSS General-->
<link rel="stylesheet" type="text/css" href="css/job_general.css" />
<!--Don't Upload: CSS General-->

<!--My account whole panel - DIV loading -->
<div id="My_Account">

<div id="progress_left_area">
<ul>
	<li>
        <div id="btn_setting" class="progress_current_but">
            <a href="#" onclick="javascript:onClickSetting();return false;">
            <p class="menu_title">My account settings</p>
            </a>
        </div>
    </li>

	<li id="li_schedule" style="display:none">
        <div id="btn_schedule">
            <a href="#" onclick="javascript:onClickSchedule();return false;">
            <p class="menu_title">My schedule</p>
            </a>
        </div>
    </li>
</ul>
</div>
<!--End of Setting left area-->
<!--Setting Right area-->
<div id="set_right_area">
    <!--Setting: My account setting-->
    <div id="set_account_setting">
        <p class="set_time_title">My account settings</p>
        <form name="form_left_area" style="margin:0; padding:0;">
         <div class="form_left_box_outter"  >
            <div class="form_left_box">
                <p id="set_comsoon" >* coming soon</p>
            </div>
         </div>


       <div class="form_left_box_outter">
          <div class="form_left_box">
                    <div class="left_col">
                        <p class="heading">Subscription period</p>
                    </div>

                    <div class="right_col">
                        <ul><li>
                            From <?php echo Date("F j, Y", $_SESSION['LICENCESTARTDATE']);?> to <?php echo Date("F j, Y", $_SESSION['LICENCEEXPIRYDATE']);?>
                        </li></ul>
                    </div>
                    <p class="set_error_msg" style="display:none">Error Message</p>
                    <div class="clear"></div>

          </div>
	</div>

    <div class="form_left_box_outter">
        <div class="form_left_box">
            <div class="left_col">
                <p class="heading">Delivery frequency</p>
            </div>

            <div class="right_col">
                <ul>
                    <li><input id="radio_time" name="radio_time" type="radio" value="0" /> All at once</li>
                    <li style="display:none"><input id="radio_time" name="radio_time" type="radio" value="1" DISABLED/>One units every day*</li>
                    <li style="display:none"><input id="radio_time" name="radio_time" type="radio" value="7" DISABLED/>One units every 3 days*</li>
                </ul>
            </div>

            <p class="set_error_msg" style="display:none">Error Message</p>
            <div class="clear"></div>
          </div>
	</div>

    <div class="form_left_box_outter">
        <div class="form_left_box">
            <div class="left_col">
				<p class="heading">Program version</p>
            </div>
            <div class="right_col"><ul>
                <li><input id="radio_version" name="radio_version" type="radio" value="EN" />International English</li>
                <li><input id="radio_version" name="radio_version" type="radio" value="NAMEN"/>North American English</li>
                <li><input id="radio_version" name="radio_version" type="radio" value="INDEN"/>Indian English</li>
            </ul></div>
            <p class="set_error_msg" style="display:none">Error Message</p>
            <div class="clear"></div>
        </div>
    </div>

    <div class="form_left_box_outter">
          <div class="form_left_box">
               <div class="left_col">
                    <p class="heading">Contact method</p>
                    <p class="small_explain"><a href="popup_msg_reminder.htm" class="contact_explain_msg_iframe">What is this?</a></p>
                </div>

                <div class="right_col">
                    <ul id="set_contact_list">
                          <li><input name="choices" type="checkbox" value="email"/> Email</li>
                          <li><input name="choices" type="checkbox" value="facebook" DISABLED/> Facebook*</li>
                          <li><input name="choices" type="checkbox" value="sms" DISABLED/> SMS*</li>

                          <li><input name="no_choices" type="checkbox" value="none" onclick="uncheckAll();" /> Not at all</li>
                   </ul>
               </div>

                  <p class="set_error_msg" style="display:none">Error Message</p>
                  <div class="clear"></div>
			</div>
    </div>

      <div class="form_left_box_outter">
          <div class="form_left_box">
                    <div class="left_col">
                        <p class="heading">Change password</p>
                    </div>

                    <div class="right_col">

                        <ul id="set_pw_list">
                            <li>
                                <div class="left_col">Original password :</div>
                                <div class="right_col"><input name="ori_pwd" type="password" class="fieldpw"/></div>
                            </li>
                      <li>
                                <div class="left_col">Change password :</div>
                                <div class="right_col"><input name="new_pwd" type="password" class="fieldpw"/></div>
                            </li>
                     <li>
                                 <div class="left_col">Confirm password :</div>
                                 <div class="right_col"><input name="new_pwd_confirm" type="password" class="fieldpw"/></div>
                            </li>
                        </ul>
                     </div>
                        <p id="err_password_msg" class="set_error_msg" style="display:none">Error Message</p>
                        <div class="clear"></div>
                </div>
        </div>

		<div class="set_footer_area">
			<div id="save_but_area"><a href="javascript:saveSetting();" id="set_savebtn"></a></div>
            <div id="save_okmsg_area" class="set_error_msg_success">Your account settings have been successfully saved.<br/></div>
            <div id="save_errmsg_area" class="set_error_msg_failure">Your account settings can't be saved. Please try again.</div>
        </div>

        </form>
    </div>
    <!--End of Setting: My account setting-->

    <!--Setting: My Schedule--->
    <div id="set_schedule_setting" style="display:none">
        <p class="set_time_title">My schedule</p>
        <div id="set_agenda_area"></div>
    </div>
    <!--End of Setting: My Schedule--->
</div>
<!--End of Setting right area-->
<p class="clear"></p>
</div>
<!--End of My account whole panel - DIV loading -->
