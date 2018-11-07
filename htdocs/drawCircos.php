<?php
	$project_name = $_POST['prj'];
	$ref_name = $_POST['ref'];
	$circos_num = $_POST['cir_num'];
	$synteny_path = "../data/$project_name/synteny";
	$circos_dir = "../data/$project_name/circos/circos$circos_num";
	$circos_info_F = "$circos_dir/circos$circos_num.info";
	$size_dir = "../data/$project_name/sizes";
	$result_dir = "../data/$project_name/circos/circos$circos_num";
	$abs_path = realpath("../data/$project_name/");
	$cytoband_dir = "$abs_path/cytoband";
	$flag = 0;
	$circos_info=fopen("".$result_dir."/circos$circos_num.info","a");
	$state_f = fopen("../data/$project_name/cur_state","r");
	while($line = fgets($state_f)){
		$line = trim($line);
		if(preg_match('/^Cytoband/',$line)){
			$arr = preg_split('/\s+/',$line);
			fwrite($circos_info,"Cytoband\t$arr[1]\t$cytoband_dir/$arr[1].cytoband.txt\n");
		}
	}
	fclose($state_f);
	fclose($circos_info);
	
	shell_exec("../scripts/drawCircos.pl -s $synteny_path -i $circos_info_F -z $size_dir -o $circos_dir");
	shell_exec("../scripts/svg_transform.pl $circos_dir/circos.svg $circos_dir");
	shell_exec("chmod -R 777 $circos_dir");
?>
