

<!--Script CheckForm -->
<script type="text/javascript" src="/script/checkform.js"></script>


<div id="header_menu">


	<div class="links">
      <a href="http://www.nas.ca">Contact us</a> | 
      <?php if (isset($_SESSION['UserName'])) { ?>
          <a href="/db_logout.php">Logout</a> 
      <?php } else { ?>
      <?php } ?>
      
  </div>
  
  <div class="clear"></div>

</div>
<div id="nas_header">
	<div id="topheader">
		
 


		<div id="headerbar">
		</div>
		<div id="searchheader">
			<form action="/search/results.php" id="cse-search-box"  onsubmit="return checkSearchForm();">
			<input type="hidden" name="cx" value="006757258002420349267:l5ss_k8gnda" style="display:none"/>
			<input type="hidden" name="cof" value="FORID:11;NB:1" style="display:none"/>
			<input type="hidden" name="ie" value="UTF-8" style="display:none"/>
			<input type="text" name="q" size="19" class="searchfield" id="q"/>
			<input type="submit" name="sa" value=""  class="searchbutton" />
			</form>
			<script type="text/javascript" src="/script/search_waterband.js"></script>
		</div>
	</div>
</div>
