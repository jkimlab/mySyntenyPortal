<?php
	$project_base = $_POST['prj'];
	$tar_name = $_POST['tar'];
	
	$tmp_chr_arr = array();
	$size_F = fopen("../data/$project_base/sizes/$tar_name.sizes","r");
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
