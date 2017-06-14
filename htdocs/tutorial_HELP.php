<html>
<script src="js/jquery-1.12.0.min.js"> </script>
<link href="css/bootstrap.css" rel="stylesheet">
<script type="text/javascript" src="js/bootstrap.js"></script>
<link href = "css/font/css/font-awesome.min.css" rel="stylesheet" >
<link href="css/msp.css" rel="stylesheet">

<style>
	div{
		display: block;
	}
	.well{
		margin-bottom: 3px;
	}	
	.gif{
		width:100%;
	}
	 
	.list{
		/*margin: 20px;*/
		cursor:pointer;
	}
	.noshow{
		display:none;
	}
	table td{
		text-align: left;
	}
	.arrow{
		width:50px;
	}
	table tr{
		cursor:pointer;
	}
	.highlight{
		font-weight: bold;
	}
	.selected{
		color:red;
	}
	.header{
		cursor: default;
	}
</style>
<script>
	var tab = "&nbsp;&nbsp;&nbsp;&nbsp;";
</script>
<?php
	if($_GET['module'] == 'syncircos'){
		$c = "active highlight";
		$b = "";
		
		$c_d = '';
		$b_d = 'noshow';	
	}
	if($_GET['module'] == 'synbrowser'){
		$b = "active highlight";
		$c = "";
		
		$b_d = '';
		$c_d = 'noshow';	
	}
?>
<body style="margin-top:0px">
	<div style="margin-top:10px">
		<div style="margin: 10 0 10 0">
			<ul class="nav nav-tabs">
				<li role="presentation" class="list <?php echo $c?>" id="syncircos"><a href="#">SynCircos</a></li>
				<li role="presentation" class="list <?php echo $b?>" id="synbrowser"><a href="#">SynBrowser</a></li>
			</ul>	
		</div>

		<div id="syncircos_div" class="tutorial_box <?php echo $c_d?>">
			<div style="padding:10px; margin: 10 0 10 0"><center>
				<h2 style="color:steelblue"><strong>SynCircos</strong></h2>
				SynCircos draws the interactive Circos plot by using selected species and chormosomes.</br>
				<hr/>			
			</center></div>
			<table class="table table-hover">
				<tr><th>1. Drawing a plot</th><td style="width:50px"></td></tr>
				<tr id="1"><td><script>document.write(tab);</script>(1) Selecting a reference species and chromosomes (or scaffolds)</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif1"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_1.gif"></td></tr>
				<tr id="2"><td><script>document.write(tab);</script>(2) Selecing a target species and chromosomes (or scaffolds)</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif2"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_2.gif"></td></tr>
				<tr id="3"><td><script>document.write(tab+tab);</script>(2-1) Adding a target species</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif3"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_2_1.gif"></td></tr>
				<tr id="4"><td><script>document.write(tab+tab);</script>(2-2) Removing a target species</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif4"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_2_2.gif"></td></tr>
				<tr id="5"><td><script>document.write(tab);</script>(3) Selecting a resolution of synteny blocks</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif5"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_3.gif"></td></tr>
				<tr id="6"><td><script>document.write(tab);</script>(4) Clicking 'Submit' button to draw the Circos plot</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif6"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_4.gif"></td></tr>
				<tr id="7"><td><script>document.write(tab);</script>(5) An example of the Circos plot</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif7"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_5.gif"></td></tr>
			</table>
			<br/>
			<table class="table table-hover">
				<tr><th>2. Downloading a plot</th><td style="width:50px"></td></tr>
				<tr id="8"><td><script>document.write(tab);</script>(1) Selecting an image format.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif8"><td colspan=2><img class="gif" id ="gif8" src="img/tutorial_img/SynCircos_2_1.gif"></td></tr>
				<tr id="9"><td><script>document.write(tab);</script>(2) Clicking on 'Download' button.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif9"><td colspan=2><img class="gif" id ="gif9" src="img/tutorial_img/SynCircos_2_2.gif"></td></tr>
			</table>
		</div>
		
		<div id="synbrowser_div" class="tutorial_box <?php echo $b_d?>">
			<div style="padding:10px; margin: 10 0 10 0">
				<center><h2 style="color:steelblue"><strong>SynBrowser</strong></h2>
				SynBrowser shows synthenic relationships between two chosen species with annotated genes of a reference species.<br/>
				User can easily navigate the reference chromosomes by using coordinates or genes.<br/>
				<hr/>
				</center>
			</div>
			<table class="table table-hover">
				<tr><th>1. Drawing a plot</th><td style="width:50px"></td></tr>
				<tr id="10"><td><script>document.write(tab);</script>(1) Selecting a reference species and a chromosome.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif10"><td colspan=2><img class="gif" id ="gif10" src="img/tutorial_img/Synbrowser_1_1.gif"></td></tr>
				<tr id="11"><td><script>document.write(tab);</script>(2) Selecting a target species.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif11"><td colspan=2><img class="gif" id ="gif11" src="img/tutorial_img/Synbrowser_1_2.gif"></td></tr>
				<tr id="12"><td><script>document.write(tab);</script>(3) Selecting a resolution of synteny blocks.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif12"><td colspan=2><img class="gif" id ="gif12" src="img/tutorial_img/Synbrowser_1_3.gif"></td></tr>
				<tr id="13"><td><script>document.write(tab);</script>(4) Clicking 'Submit' button to draw a plot showing pairwise synthenic information.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif13"><td colspan=2><img class="gif" id ="gif13" src="img/tutorial_img/Synbrowser_1_4.gif"></td></tr>
			</table>
			<br/>
			<table class="table table-hover">
				<tr><th>2. Downloading a plot</th><td style="width:50px"></td></tr>
				<tr id="14"><td><script>document.write(tab);</script>(1) Selecting an image format.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif14"><td colspan=2><img class="gif" id ="gif14" src="img/tutorial_img/Synbrowser_2_1.gif"></td></tr>
			 	<tr id="15"><td><script>document.write(tab);</script>(2) Clicking on 'Download' button.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif15"><td colspan=2><img class="gif" id ="gif15"  src="img/tutorial_img/Synbrowser_2_2.gif"></td></tr>
			</table>
			<br/>
			<table class="table table-hover">
				<tr><th>3. Browsing the details of synteny blocks</th><td style="width:50px"></td></tr>
				<tr id="16"><td><script>document.write(tab);</script>(1) Obtaining information about synteny blocks</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif16"><td colspan=2><img class="gif" id ="gif16" src="img/tutorial_img/Synbrowser_3_1.gif"></td></tr>
				<tr id="17"><td><script>document.write(tab);</script>(2) Browsing gene annotation</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif17"><td colspan=2><img class="gif" id ="gif17" src="img/tutorial_img/Synbrowser_3_2.gif"></td></tr>
				<tr id="18"><td><script>document.write(tab);</script>(3) Obtaining gene information</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif18"><td colspan=2><img class="gif" id ="gif18" src="img/tutorial_img/Synbrowser_3_3.gif"></td></tr>
			</table>
			<br/>
			<table class="table table-hover">			
				<tr><th>4. Searching for a specific position in synteny blocks</th><td style="width:50px"></td></tr>
				<tr id="19"><td><script>document.write(tab);</script>(1) Selecting a reference chromosome</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif19"><td colspan=2><img class="gif" id ="gif19"  src="img/tutorial_img/Synbrowser_4_1.gif"></td></tr>
				<tr id="20"><td><script>document.write(tab);</script>(2) Searching by using a query gene</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif20"><td colspan=2><img class="gif" id ="gif20"  src="img/tutorial_img/Synbrowser_4_2.gif"></td></tr>
				<tr id="21"><td><script>document.write(tab);</script>(3) Searching by using a coordinate of synteny blocks</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif21"><td colspan=2><img class="gif" id="gif21"  src="img/tutorial_img/Synbrowser_4_3.gif"></td></tr>
			</table>
		</div>	
				
	</div>
</body>

<script>
	$('.list').click(function(){
		var id = this.id;
		$.map($('.list'),function(ele){
			$(ele).removeClass('highlight');
			$(ele).removeClass('active');
		});
		$(this).addClass('highlight');
		$(this).addClass('active');
		
		$.map($('.tutorial_box'),function(ele){
			$(ele).removeClass('noshow');
			$(ele).addClass('noshow');
		});
		$('#'+id+'_div').removeClass('noshow');
	});
	
	$('tr').click(function(){
		var id = $(this).attr('id');
		$('#gif'+id).toggle();
		if($(this).find($('.arrow')).hasClass('selected')){
			$(this).find($('.arrow')).removeClass('selected');
			$(this).find($('.arrow')).html('<i class="fa fa-angle-double-down" aria-hidden="true"></i>');
		}else{
			$(this).find($('.arrow')).addClass('selected');
			$(this).find($('.arrow')).html('<i class="fa fa-angle-up" aria-hidden="true"></i>');
		}
	});
</script>

</html>
