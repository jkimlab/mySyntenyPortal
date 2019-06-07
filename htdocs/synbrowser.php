<?php include "./topbar.php";?>
<script type="text/javascript" src="js/d3-tip.js"></script>
<script type="text/javascript" src="js/linearplot.js"></script>
<script type="text/javascript" src="js/linearbrush.js"></script>
<script type="text/javascript" src="js/browser.js"></script>
<script>
if(sessionStorage.getItem('prj') !== null){
	var prj = sessionStorage.getItem('prj');
	sessionStorage.clear();
	window.location="synbrowser.php?PRJ="+prj;
}
</script>
<?php //Project list
if(isset($_GET['PRJ'])){$project_base = $_GET['PRJ'];}else{$project_base = "";}
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

<?php //Currnet state
$tar_arr = array();
$resolution_arr = array();
$state_f = fopen("../data/$project_base/cur_state","r");
while($line = fgets($state_f)){
	$line = trim($line);
	if(empty($line)){continue;}
	$arr = preg_split("/\s+/",$line);
	if(preg_match('/^SB/',$line)){
		if($arr[1] == "ref_name"){
			$ref_name = $arr[2];
		} else if($arr[1] == "ref_asmbl"){
			$selected_asmbl = $arr[2];
		} else if($arr[1] == "tar_name"){
			$tar_name = $arr[2];
		} else if($arr[1] == "res"){
			$resolution = $arr[2];
		}					
	} else {
		if($arr[0] === "Project_name"){
			$project_name = $arr[1];
		} else if ($arr[0] === "Project_desc"){
			$arr2 = preg_split("/\t/",$line);
			$project_desc = $arr2[1];	
		} else if ($arr[0] === "Ref_names"){
			$tar_arr = preg_split("/,/",$arr[1]);
		} else if ($arr[0] === "Resolutions"){
			if($arr[1] != 0){
				$resolution_arr = preg_split("/,/",$arr[1]);
			}
		} else {
		}
	}
}
fclose($state_f);

if(isset($_GET['REF'])){$ref_name = $_GET['REF'];}
if(isset($_GET['TAR'])){$tar_name = $_GET['TAR'];} else {
	if(isset($_GET['REF'])){
		$files = scandir("../data/$project_base/browser");
		foreach ($files as $v){
			if (preg_match("/^[.]/",$v)){
				continue;
			} else {
				if(preg_match("/.linear/",$v)){
					$arr_tmp = preg_split("/[.]/",$v);
					if($arr_tmp[1] == $ref_name){continue;}
					$tar_name = $arr_tmp[1];
					break;
				}
			}
		}
	}
}
if(isset($_GET['RES'])){$resolution = $_GET['RES'];}
if(isset($_GET['ASMBL'])){$selected_asmbl = $_GET['ASMBL'];}
if(isset($_GET['S']) && isset($_GET['E'])){$Sstart = $_GET['S'];$Send = $_GET['E'];}
if(isset($_GET['GENE'])){$search_gene = $_GET['GENE'];}
?>

<body id="synbrowser-body">
<center>
<div style="width:1000px;border-left:1px;border-right:1px">
<div style="width:920px;display:block;margin-top:20px;text-align:right;">
	<a  id="fontColor" style="font-weight:bold;cursor:pointer;" onclick="window.open('./tutorial_HELP.php?module=synbrowser', 'doc','status=no,menubar=no,width=1010,height=600');">HELP</a>
</div>
	<div style="margin-bottom:30px;font-size:17px;"><b>SynBrowser draws the interactive linear plot by using selected species and chromosome.</b></div><br>
<div>
	<div style="vertical-align:top;">Reference<br>
		<select id="ref_browser" style="margin-left:2px;width:100px;height:30px;line-height:17px;margin-top:5px;">
		<?php
		foreach ($tar_arr as $i => $spc_name){
			if($spc_name == $ref_name){
				echo "<option id=\"$spc_name\" selected>$spc_name</option>\n";
			} else {
				echo "<option id=\"$spc_name\">$spc_name</option>\n";
			}
		}
?>
		</select>
	</div>
	<div>Chr/Scaf<br>
		<select id="refChr_browser" style="width:80px;margin-top:5px;"><?php
	$arr_ref_asmbl = array();
	if(!empty($resolution_arr)){
		$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.$resolution.linear","r");
		$geneTrack_F = "../data/$project_base/browser/$ref_name.$tar_name.$resolution.geneTrack";
	} else {
		$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.linear","r");
		$geneTrack_F = "../data/$project_base/browser/$ref_name.$tar_name.geneTrack";
	}
	while($line = fgets($input_f)){
		$line = trim($line);
		if(preg_match('/^#/',$line)){
			if(preg_match("(^#$ref_name)",$line)){
				$arr_tmp = preg_split("/\s+/",$line);
				$asmbl = $arr_tmp[1];
				$asmblL = $arr_tmp[2];
				array_push($arr_ref_asmbl,$asmbl);
			}
		}
	}
	
	$selected_asmbl_flag = 0;
	foreach ($arr_ref_asmbl as $chr_num){
		if($chr_num === $selected_asmbl){
			$selected_asmbl_flag = 1;
			echo "<option value=\"$chr_num\" selected>$chr_num</option>\n";
		} else {
			echo "<option value=\"$chr_num\">$chr_num</option>\n";
		}
	}
	
	if($selected_asmbl_flag == 0){
		$selected_asmbl = $arr_ref_asmbl[0];
	}
	
	if(file_exists($geneTrack_F)){
		$geneTrack_flag = 1;
	} else {
		$geneTrack_flag = 0;
	}
?>
		</select>
	</div>
	<div>Target<br>
		<select id="tar_browser" style="margin-top:5px;">
<?php
	$spc_info = array();
	$hash_target = array();
	$first_target = "";
	$tar_flag = array();
	$arr_resolution = array();
	$files = scandir("../data/$project_base/browser");
	foreach ($files as $v){
		if (preg_match("/^\./",$v)){
			continue;
		} else {
			if(preg_match("/.linear/",$v)){
				$arr_tmp = preg_split("/[.]/",$v);
				if($arr_tmp[0] !== $ref_name){continue;}
				if($arr_tmp[1] == $tar_name){array_push($arr_resolution,$arr_tmp[2]);}
				if(in_array($arr_tmp[1],$tar_flag)){continue;}
				if($arr_tmp[1] == $tar_name){
					echo "<option id=\"$arr_tmp[1]\" value=\"$arr_tmp[1]\" selected>$arr_tmp[1]</option>";
				} else {
					echo "<option id=\"$arr_tmp[1]\" value=\"$arr_tmp[1]\">$arr_tmp[1]</option>";
				}
				array_push($tar_flag,$arr_tmp[1]);
			}
		}
	}
?>
		</select>
	</div>
<?php
	if(!empty($resolution_arr)){
		echo"<div id=\"resolution_div\" style=\"width:115px\">Resolution (bp)<img id=\"qresolution\" class='qimg' width=\"15px\" style=\"cursor:pointer;\" src=\"./img/docu_link.png\" onmouseover=\"question_box_on(this.id, event);\" onmouseleave=\"question_box_off(this.id);\"/><select id=\"resolution\" style=\"width:100px;margin-top:5px;\">\n";
		foreach ($resolution_arr as $value){
			$fValue = number_format($value);
			if($resolution == ""){$resolution = $value;}
			if ($value == $resolution){
				echo "<option value=\"".$value."\" selected>".$fValue."</option>";
			} else {
				echo "<option value=\"".$value."\">".$fValue."</option>";
			}
		}
		echo"</select>\n";
	}
	echo "</div>\n";
	
?>	
	<input type="button" class="msp_submit_btn" style="height:30px;" value="Submit" onclick="get_spc_id();">
	<input type="button" id="reset_data" class="msp_reset_btn" value="Reset" style="height:30px;"/>
</div>
<br><br>
<div>Image format
<select id="b_img_fmt" style="width:80px">
	<option value="png">PNG</option>
	<option value="jpg">JPEG</option>
	<option value="svg" selected>SVG</option>
	<option value="pdf">PDF</option>
</select>
<input type="button" class="msp_btn" id="img_fmt_button" value="Download" onclick="makeBrowser_img();">
</div>
<br><br>
<div id="geneTrackMenu" style="display:inline-block;">
	<div id="geneSearchEngine">
		Search <b>Gene/Protein name</b>
		<input type="text" class="browser_txt"  id="sy_search_text" value="<?php if(isset($search_gene)){echo $search_gene;}?>">&nbsp
		<input type="button" class="msp_btn" value="Search" onclick="gene_search();">
		<img id="qgene_search" class='qimg' width="15px" style="cursor:pointer; margin-bottom:10px;" src="./img/docu_link.png" onmouseover="question_box_on(this.id,event);" onmouseleave="question_box_off(this.id);"/>
	</div>
	<br><br>
	<div id="regionSearchEngine">
		Navigate <b>Chromosome/Scaffold</b>			
		<select id="sy_chr" style="width:80px;margin-right:10px;">
<?php
	foreach ($arr_ref_asmbl as $chr_num){
		if($chr_num === $selected_asmbl){
			echo "<option value=\"$chr_num\" selected>$chr_num</option>\n";
		} else {
			echo "<option value=\"$chr_num\">$chr_num</option>\n";
		}
	}
?>
		</select>
		start
		<input type="text" class="browser_txt" id="sy_chr_startP_text" value="<?php if(isset($Sstart)){echo $Sstart;}?>">&nbsp
		end
		<input type="text" class="browser_txt" id="sy_chr_endP_text" value="<?php if(isset($Send)){echo $Send;}?>">&nbsp
		<input type="button" class="msp_btn" value="Go" onclick="position_search();">
		<img id="qposition_search" class='qimg' width="15px" style="cursor:pointer; margin-bottom:10px;" src="./img/docu_link.png" onmouseover="question_box_on(this.id,event);" onmouseleave="question_box_off(this.id);"/>
	</div>
</div>
<div id="NoGeneTrackMenu" style="display:inline-block;">
	<b>Search function is disabled because gene/protein annotation information is not available.</b>
</div>
<a style="display:none;" id="downloadLink" href="#" download="#"></a>
<script>
<?php // Gene track menu display
	if($geneTrack_flag == 0){
		echo "var geneTrack_flag = 0;\n";
		echo "$('#geneTrackMenu').hide();\n";
	} else {
		echo "var geneTrack_flag = 1;\n";
		echo "$('#NoGeneTrackMenu').hide();\n";
	}
?>
</script>
<hr style="width:980px; border-color:#ccc;margin:20px 0px 10px 0px;">
<div id="body"></div>
	<script>
<?php
	$arr_ref_asmbl = array();
	$ref_ex_asmbl = array();
	$target_ex_asmbl = array();
	$ref_target_asmbl = array();
	$gene_ex = array();
	$arr_spc = array();
	
	echo "\tvar resolution = \"$resolution\";\n";
	echo "\tvar selected_asmbl = \"$selected_asmbl\";\n";
	$arr_spc = array($ref_name,$tar_name);
	
//Species information
	echo "\tvar ref = \"$ref_name\";\n";
	echo "\tvar target = \"$tar_name\";\n";
	echo "\tvar proj = \"$project_base\";\n";
//Raw data for making synteny block
	echo "//Raw data for making synteny block\n";
	foreach ($arr_spc as $spc)
	{
		echo "\thash_block_info[\"$spc\"] = {};\n";
	}
// Get reference chromosome length information & Get block information
	echo "//Get chromosome length information & Get block information\n";
	$arr_con = array();
	if(!empty($resolution_arr)){
		$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.$resolution.linear","r");
	} else {
		$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.linear","r");
	}
	while($line = fgets($input_f)){
		$line = trim($line);
		if(preg_match('/^#/',$line)){
			if(preg_match("/(^#".$arr_spc[0].")/",$line)){
				$arr_tmp = preg_split("/\s+/",$line);
				$asmbl = $arr_tmp[1];
				$asmblL = $arr_tmp[2];
				if ($asmbl == $selected_asmbl){
					echo "\tselected_asmblL = $asmblL;\n";
				}
				array_push($arr_ref_asmbl,$asmbl);
			}
		} else {
			$arr_tmp = preg_split("/\|/",$line);
			$ref_asmbl = "";
			$target_asmbl = "";
			for ($i = 0, $j = count($arr_tmp); $i < $j; $i++){
				$arr_block_info = preg_split("/\s+/",$arr_tmp[$i]);
				$block_con = $arr_block_info[0];
				$block_asmbl = $arr_block_info[1];
				if ($i == 0){
					$ref_asmbl = $block_asmbl;
					if ($ref_asmbl == $selected_asmbl){
						array_push($arr_con,$block_con);
						if (!array_key_exists($block_asmbl,$ref_ex_asmbl)){
							$ref_ex_asmbl[$block_asmbl] = $block_con;
						} else {
							$ref_ex_asmbl[$block_asmbl] .= "\t".$block_con;
						}
						echo "\thash_block_info[\"$arr_spc[$i]\"][$block_con] = \"$block_asmbl\t$arr_block_info[2]\t$arr_block_info[3]\t$arr_block_info[4]\";\n";
					}
				} else {
					if ($ref_asmbl == $selected_asmbl){
						$target_asmbl = $block_asmbl;
						echo "\thash_block_info[\"$arr_spc[$i]\"][$block_con] = \"$block_asmbl\t$arr_block_info[2]\t$arr_block_info[3]\t$arr_block_info[4]\";\n";
					}
				}
			}
			
			if ($ref_asmbl == $selected_asmbl)
			{
				if (!isset($target_ex_asmbl[$ref_asmbl][$target_asmbl]))
				{
					$target_ex_asmbl[$ref_asmbl][$target_asmbl] = 0;
					if (!array_key_exists($ref_asmbl,$ref_target_asmbl))
					{
						$ref_target_asmbl[$ref_asmbl] = $target_asmbl;
					}
					else
					{
						$ref_target_asmbl[$ref_asmbl] .= "\t$target_asmbl";
					}
				}
			}
		}
	}
	fclose($input_f);
	
// Reference chromosome => color legend
	$ref_asmbl_num = 0;
	echo "//Get reference chromosome color information\n";
	$input_f = fopen("../data/$project_base/browser/colors.mySyntenyPortal.conf","r");
	while($line = fgets($input_f)){
		$line = trim($line);
		$arr_tmp = preg_split("/ = /",$line);
		$rgb = $arr_tmp[1];
		$text_col = getContrastYIQ($rgb);
		if ($ref_asmbl_num >= count($arr_ref_asmbl)){
			break;
		} else {
			$ref_asmbl = $arr_ref_asmbl[$ref_asmbl_num];
			if ($ref_asmbl == $selected_asmbl){
				echo "\trgb = \"$rgb\";\n";
				echo "\ttext_color = \"$text_col\";\n";
			}
			echo "\thash_asmbl_color[\"$ref_asmbl\"] = \"$rgb\t$text_col\";\n";
		}
		$ref_asmbl_num++;
	}
	fclose($input_f);
	
	echo "\tmax_ref_asmbl_num = $ref_asmbl_num;\n";

// Reference chromosome => conserved segments
	echo "//Reference chromosome => conserved region\n";
	foreach ($ref_ex_asmbl as $asmbl => $con){
		echo "\thash_asmbl_con[\"".$asmbl."\"] = \"$con\";\n";
	}
	
// Reference chromosome => Target chromosome
	$arr_tarchr = array();
	foreach ($ref_target_asmbl as $ref_asmbl => $target_chr)
	{
		$arr_tmp = preg_split("/\s+/",$target_chr);
		natsort($arr_tmp);
		$arr_tarchr = array_values($arr_tmp);
		$target_info = implode("\t",$arr_tarchr);
		echo "\thash_ref_target[\"$ref_asmbl\"] = \"$target_info\";\n";
	}

//Length of target chromosome
	echo "//Get target chromosome length information\n";
	if(!empty($resolution_arr)){
		$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.$resolution.linear","r");
	} else {
		$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.linear","r");
	}
	while($line = fgets($input_f)){
		$line = trim($line);
		if (preg_match("/(^#".$arr_spc[1].")/",$line)){
			$arr_tmp = preg_split("/\s+/",$line);
			$asmbl = $arr_tmp[1];
			$asmblL = $arr_tmp[2];
			if (in_array($asmbl,$arr_tarchr)){
				echo "\thash_asmbl_info[\"$asmbl\"] = $asmblL;\n";
			}
		}
	}
	fclose($input_f);

// Gene information 
	if($geneTrack_flag == 1){
		echo "//Gene information\n";
		$JSON_array = array();
		for ($i = 1; $i <= 7; $i++)
		{
			if ($i == 7)
			{
				$JSON_array[$i]['trackName'] = "track".$i;
				$JSON_array[$i]['trackType'] = "synTrack";
				$JSON_array[$i]['trackFeatures'] = "simple";
				$JSON_array[$i]['visible'] = false;
				$JSON_array[$i]['showLabels'] = false;
				$JSON_array[$i]['showTooltip'] = false;
			}
			else
			{		
				$JSON_array[$i]['trackName'] = "track".$i;
				$JSON_array[$i]['trackType'] = "geneTrack";
				$JSON_array[$i]['visible'] = true;
				$JSON_array[$i]['trackFeatures'] = "simple";
				$JSON_array[$i]['linear_mouseclick'] = 'linearClick';
				$JSON_array[$i]['showLabels'] = true;
				$JSON_array[$i]['showTooltip'] = true;
			}
		}
		if(!empty($resolution_arr)){
			$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.$resolution.geneTrack","r");
		} else {
			$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.geneTrack","r");
		}
		while($line = fgets($input_f)){
			$line = trim($line);
			$arr_tmp = preg_split("/\s+/",$line);
			$chr = $arr_tmp[0];
			$chr = "chr$chr";
			$tracks = $arr_tmp[1];
			$gene_id = $arr_tmp[2];
			$start = $arr_tmp[3] * 1;
			$end = $arr_tmp[4] * 1;
			$cr = $arr_tmp[5];
			$name = $arr_tmp[6];
			$strand = $arr_tmp[7];
			if ($chr == $selected_asmbl){
				if (!array_key_exists($chr,$gene_ex)){
					$id = 1;
					if(!isset($gene_ex[$chr][$tracks])){
						$gene_ex[$chr][$tracks] = array();
						$ITEM_array = array('chr' => $chr,'id' => $id,  'start' => $start, 'end' => $end, 'GeneID' => $gene_id, 'name' =>$name, 'cr' => $cr, 'strand' => $strand);
						array_push($gene_ex[$chr][$tracks],$ITEM_array);
					}
				} else {
					$id++;
					if (!array_key_exists($tracks, $gene_ex[$chr])){
						$gene_ex[$chr][$tracks] = array();
						$ITEM_array = array('chr' => $chr, 'id' => $id, 'start' => $start, 'end' => $end, 'GeneID' => $gene_id, 'name' =>$name, 'cr' => $cr, 'strand' => $strand);
						array_push($gene_ex[$chr][$tracks],$ITEM_array);
					} else {
						$ITEM_array = array('chr' => $chr, 'id' => $id, 'start' => $start, 'end' => $end, 'GeneID' => $gene_id, 'name' =>$name, 'cr' => $cr, 'strand' => $strand);
						array_push($gene_ex[$chr][$tracks],$ITEM_array);
					}
				}
			}
		}
		fclose($input_f);

		if(!empty($resolution_arr)){
			$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.$resolution.linear","r");
		} else {
			$input_f = fopen("../data/$project_base/browser/$ref_name.$tar_name.linear","r");
		}
		while($line = fgets($input_f)){
			$line = trim($line);
			$arr_tmp = preg_split("/\t/",$line);
			$ref_chr = $arr_tmp[1];
			$block_con = $arr_tmp[0];
			if ($ref_chr == $selected_asmbl){
				if (!preg_match("/(^#)/",$line)){
					if (!array_key_exists($ref_chr,$gene_ex)){	
						$id = 1;
						if (!array_key_exists("7",$gene_ex[$ref_chr])){
							$gene_ex[$ref_chr]["7"] = array();
							$syn_info = "Synteny_block "+$block_con;
							$ITEM_array = array('id'=>$id,'start'=>$arr_tmp[2],'end'=>$arr_tmp[3],'name'=>$syn_info);
							array_push($gene_ex[$ref_chr]["7"],$ITEM_array);
						}
					} else {
						$id++;
						if (!array_key_exists("7",$gene_ex[$ref_chr])){
							$gene_ex[$ref_chr]["7"] = array();
							$syn_info = "Synteny_block "+$block_con;
							$ITEM_array = array('id'=>$id,'start'=>$arr_tmp[2],'end'=>$arr_tmp[3],'name'=>$syn_info);
							array_push($gene_ex[$ref_chr]["7"],$ITEM_array);
						} else {
							$syn_info = "Synteny_block "+$block_con;
							$ITEM_array = array('id'=>$id,'start'=>$arr_tmp[2],'end'=>$arr_tmp[3],'name'=>$syn_info);
							array_push($gene_ex[$ref_chr]["7"],$ITEM_array);
						}
					}
				}
			}
		}
		
		foreach ($gene_ex as $chr => $arr_tmp){
			$main_array = array();
			foreach ($arr_tmp as $tracks => $data){
				$JSON_array[$tracks]['items'] = $data;
				array_push($main_array,$JSON_array[$tracks]);
			}
			$output = json_encode($main_array);
			echo "\thash_json[\"".$chr."\"] = ".$output."\n";
		}
	}
	
	function getContrastYIQ($rgb){
		$arr_col = preg_split("/,/",$rgb);
		$yiq = (($arr_col[0]*299)+($arr_col[1]*587)+($arr_col[2]*114))/1000;
		return ($yiq >= 128) ? 'black' : 'white';
	}
?>
	draw_svg();
	setInterval(function () {
	 var color = "#"; 
	 var random = Math.floor( Math.random() * 0xffffff ).toString( 16 );
	 var gap = 6 - random.length;
	 if ( gap > 0 ) {for ( var x = 0; x < gap; x++ ) color += "0";}
	 document.getElementById ( "fontColor" ).style.color = color + random;
	}, 500);

	</script>
</div>
</center>
<?php include './footer.php';?>
