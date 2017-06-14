<?php include './topbar.php';?>
<script type="text/javascript" src="js/circos.js"></script>
<script>
if(sessionStorage.getItem('prj') !== null){
	var prj = sessionStorage.getItem('prj');
	sessionStorage.clear();
	window.location="syncircos.php?PRJ="+prj;
}
</script>
<?php //Project list
if(isset($_GET['PRJ'])){$project_base = $_GET['PRJ'];} else {$project_base = "";}
$projects = array();
$path_info = fopen("./path_info.txt","r");
while($line = fgets($path_info)){
	$line = trim($line);
	if(preg_match('/^>/',$line)){
		$arr = preg_split("/>/",$line);
		if($arr[1] == "mySyntenyPortal webroot"||$arr[1] == "mySyntenyPortal root"){continue;}
		array_push($projects,$arr[1]);
	}
}
fclose($path_info);

echo "<script>\n";
foreach ($projects as $i => $prj){
	if($project_base == ""){$project_base = $prj;}
	echo "$('#publish_select').append('<option value=\'$prj\'>$prj</option>');\n";
}
echo "$('#publish_select').val('$project_base').attr('selected','selected');\n";
echo "sessionStorage.setItem('prj','$project_base');";
echo "</script>\n";
?>

<?php //Current state
$tar_arr = array();
$resolution_arr = array();
$state_f = fopen("../data/$project_base/cur_state","r");
while($line = fgets($state_f)){
	$line = trim($line);
	if(empty($line)){continue;}
	$arr = split("[[:space:]]",$line);
	if(preg_match('/^SC/',$line)){
		if($arr[1] == "circos_num"){
			$circos_num = $arr[2];
		}
	} else {
		if($arr[0] === "Project_name"){
			$project_name = $arr[1];
		} else if ($arr[0] === "Project_desc"){
			$arr2 = split("[\t]",$line);
			$project_desc = $arr2[1];
		} else if ($arr[0] === "Ref_names"){
			$tar_arr = split("[,]",$arr[1]);
		} else if ($arr[0] === "Resolutions"){
			if($arr[1] != 0){
				$resolution_arr = split("[,]",$arr[1]);
			}
		} else {
		}
	}
}
fclose($state_f);

if(isset($_GET['REF'])){$ref_name = $_GET['REF'];}
?>

<?php //Reading info
$circos_tar_arr = array();
$circos_chr_arr = array();
$circos_resolution = 0;
$circos_files = scandir("../data/$project_base/circos/");
$next_circos_num = count($circos_files)-2;
$circos_arr_index = 0;
$circos_info_f = fopen("../data/$project_base/circos/circos$circos_num/circos$circos_num.info","r");
while($line = fgets($circos_info_f)){
	$line = trim($line);
	$arr = split("[[:space:]]",$line);
	if(preg_match('/^Resolution/',$line)){
		$circos_resolution = $arr[1];
	} else if (preg_match('/^Cytoband/',$line)){
		continue;
	} else {
		$circos_chr_arr[$circos_arr_index] = $arr[2];
		if($arr[0] != 0){
			if(!isset($_GET['REF'])){
				array_push($circos_tar_arr,$arr[1]);
			}
		} else {
			if(!isset($_GET['REF'])){
				$ref_name = $arr[1];
			}
		}
		$circos_arr_index++;
	}
}
fclose($circos_info_f);
?>
	<body id="syncircos-body">
	<center>
	<div style="border-left:1px;border-right:1px">
	<div style="width:920px;display:block;margin-top:20px;text-align:right;">
		<a  id="fontColor" style="font-weight:bold;cursor:pointer;" onclick="window.open('./tutorial_HELP.php?module=syncircos', 'doc','status=no,menubar=no,width=1010,height=600');">HELP</a>
	</div>
	<div style="margin-top:0px;margin-bottom:30px;font-size:17px;"><b>SynCircos draws the interactive Circos plot by using selected species and chromosomes.</b><br>
	</div>
	<div style="width:600px;text-align:right;margin-bottom:10px;margin-left:20px;">
	<?php
		if(!empty($resolution_arr)){
			echo "Resolution (bp)\n";
			echo "<img id=\"qresolution\" class='qimg' width=\"15px\" style=\"cursor:pointer;margin-left:-5px;\" src=\"./img/docu_link.png\" onmouseover=\"question_box_on(this.id, event);\" onmouseleave=\"question_box_off(this.id);\"/>\n";
			echo "<select id=\"resolution\" style=\"width:100px\">\n";
			foreach ($resolution_arr as $i => $resolution){
				$resolution_fmt = number_format($resolution);
				if($circos_resolution == $resolution){
					print "<option value=\"$resolution\" selected>$resolution_fmt</option>\n";
				} else {
					print "<option value=\"$resolution\">$resolution_fmt</option>\n";
				}
			}
			echo "</select>&nbsp&nbsp\n";
		}
	?>
	
	</div><br>	
	<div id="Species" style="width:990px;display:block;">
	<div style="width:500px;height:30px;font-size:15px;display:inline;margin-left:75px;vertical-align:bottom;">
	Species name
	<div style="width:420px;">
	<input type="button" class="msp_btn" value="Add a target" style="width:110px;height:25px;font-size:13px;float:left;margin-left:20px;padding:3px 14px 5px;" onclick="tarAdd(<?php echo "'$project_base', '$ref_name'"?>);">
	<input type="button" class="msp_btn" value="Delete a target" style="width:110px;height:25px;font-size:13px;float:left;margin-left:7px;padding:3px 12px 5px;" onclick="tarDel_bottom();">
	<input type="button" id="reset_data" class="publish_group msp_reset_btn" value="Reset" style="float:right;height:30px;margin-left:2px;"/>
	<input type="button" class="msp_submit_btn" value="Submit" style="float:right;height:30px;" onclick="Get_img(<?php echo "'$project_base','$ref_name','$next_circos_num'";?>);">
	</div></div>
	<!-- Reference Line -->
	<div class="circos_species" style="display:block;margin-top:5px;"> Reference  
		<select id="ref_circos" style="margin-left:2px;width:100px;height:30px;line-height:17px;"><?php
			foreach ($tar_arr as $i => $spc_name){
				if($spc_name == $ref_name){
					echo "<option id=\"$spc_name\" selected>$spc_name</option>\n";
				} else {
					echo "<option id=\"$spc_name\">$spc_name</option>\n";
				}
			}
		?></select>
	<input type="button" class="msp_btn" value="Chrs/Scafs >>" style="margin-left:2px;" id="ref_chr" onClick="refChrClick(this.id);"/>
	<textarea id="ref_textArea" style="margin-left:2px;"><?php
	if(!isset($_GET['REF'])){
		if($circos_chr_arr[0] !== "all"){
			$ref_chrs = str_replace("chr","",$circos_chr_arr[0]);
			echo $ref_chrs;
		}
	}
	?></textarea>
	</div>
	<div id="ref_chr_div" style="width:1000px; height:160px; margin-top:10px;" hidden>
		<select id="ref_chr_available" multiple size="10" style="float:left; margin-left:480px; width:160px; height:150px;">
		<?php
			$size_F = fopen("../data/$project_base/sizes/$ref_name.sizes","r");
			$tmp_chr_arr = array();
			while($line = fgets($size_F)){
				$line = trim($line);
				$arr_tmp = split("[[:space:]]",$line);
				$chr_num = $arr_tmp[0];
				array_push($tmp_chr_arr,$chr_num);
			}
			fclose($size_F);
			natsort($tmp_chr_arr);
			foreach ($tmp_chr_arr as $chr_num){
				echo "<option value=\"$chr_num\">$chr_num</option>\n";
			}
		?>
		</select>
		<div id="ref_chr_select_button" style="width:39px; float:right; margin-right:310px; margin-top:0px;">
		<input type="button" class="msp_btn" value="Close" style="margin-bottom:50px;margin-top:5px;" onclick="CloseChr('ref');"/>
		<input type="button" class="msp_btn" value="Select all"  onclick="chrSelectAll('ref', true);"/>
		<input type="button" class="msp_btn" value="Unselect all" style="margin-top:5px;" onclick="chrSelectAll('ref', false);"/>
		</div>
	</div>
	<script>
		if($('#ref_textArea').val() == ""){chrSelectAll('ref', true);}
	<!-- Target div -->
	<?php
	if(empty($circos_tar_arr)){
		echo "tarAdd(\"$project_base\",\"$ref_name\");\n";
	} else {
		foreach ($circos_tar_arr as $i => $tar_name){
			$j = $i+1;
			echo "tarAdd(\"$project_base\",\"$ref_name\",\"$tar_name\",\"$circos_chr_arr[$j]\");\n";
		}
	}
	?>
	</script>
	</div>	
	<a style="display:none;" id="downloadLink" href="#" download="#"></a>
	<hr style="width:980px; border-color:#ccc;margin:20px 0px 10px 0px;">
	<div style="width:990px;">
	<div style="position:relative;width:970px;text-align:center;z-index:100;">
	Image format
	<select id="img_fmt" style="width:90px;">
		<option value="png">PNG</option>
		<option value="jpg">JPEG</option>
		<option value="svg" selected>SVG</option>
		<option value="pdf">PDF</option>
	</select>
	<input type="button" class="msp_btn" value="Download" onclick="makeCircos_img(<?php echo "'$circos_num'";?>);">
	</div>
	<!-- Result -->
	<div id="loading" hidden>
		<br><br><br><br><br><br><br>
		<font size="3"><b>Now processing...</b></font>
		<br><br>
		<img id="loading-image" width="50px" height="50px" src="./img/ajax-loader.gif" alt="Loading..."/>
		<br><br><br><br><br><br><br>
	</div>
	
	<div id="div_result" style="height:800px;margin-top:-20px;">
		<?php
			include "../data/$project_base/circos/circos$circos_num/circos.event.svg";
		?>
	</div>
	</div>
</center>
<script>
var transform_state = 0;
d3.selectAll(".transforms, .transforms_path")
	.on("mouseover",function(){mouseOver(this.id);})
	.on("mouseout",function(){mouseOut(this.id);})
	.on("click",function(){mouseClick(this.id);})
	.style("cursor","pointer");
	
setInterval(function () {
	 var color = "#"; 
	 var random = Math.floor( Math.random() * 0xffffff ).toString( 16 );
	 var gap = 6 - random.length;
	 if ( gap > 0 ) {for ( var x = 0; x < gap; x++ ) color += "0";}
	 document.getElementById ( "fontColor" ).style.color = color + random;
}, 500);
</script>
<?php include './footer.php';?>
