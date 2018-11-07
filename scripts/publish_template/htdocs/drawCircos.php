<?php
	session_Start();
	$user_id = session_Id();
	$ref_name = $_POST['ref'];
	$tars = $_POST['tars'];
	$circos_num = $_POST['cir_num'];
	$synteny_path = "../data/synteny";
	$circos_dir = "../session/$user_id/circos/circos$circos_num";
	$circos_info_F = "$circos_dir/circos$circos_num.info";
	$size_dir = "../data/sizes";
	$abs_path = realpath("../data");
	$cytoband_dir = "$abs_path/cytoband";
	$flag = 0;
	$circos_info=fopen($circos_info_F,"a");
	$state_f = fopen("../session/$user_id/cur_state","r");
	while($line = fgets($state_f)){
		$line = trim($line);
		if(preg_match('/^Cytoband/',$line)){
			$arr = preg_split('/\s+/',$line);
			fwrite($circos_info,"Cytoband\t$arr[1]\t$cytoband_dir/$arr[1].cytoband.txt\n");
		}
	}
	fclose($state_f);
	fclose($circos_info);
	shell_exec("../script/drawCircos.pl -s $synteny_path -i $circos_info_F -z $size_dir -o $circos_dir");
	shell_exec("../script/svg_transform.pl $circos_dir/circos.svg $circos_dir");
	shell_exec("chmod -R 777 $circos_dir");
?>
