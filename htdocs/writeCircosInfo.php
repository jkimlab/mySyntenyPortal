<?php
	$project_name = $_POST['prj'];
	$circos_info = $_POST['circos_info'];
	$circos_num = $_POST['cir_num'];
	$flag = 0;
	$index_F = fopen("../data/$project_name/circos/index","r");
	while($line = fgets($index_F)){
		$line = trim($line);
		$line_arr = split("[\t]",$line);
		if($circos_info == $line_arr[1]){
			$flag = $line_arr[0];
		}
	}
	fclose($index_F);
	
	if($flag == 0){
		$result_dir = "../data/$project_name/circos/circos$circos_num";
		shell_exec("mkdir -p ".$result_dir);
		$arr_circos_info = split("[\|]",$circos_info);
		$resolution = array_shift($arr_circos_info);
		$circos_info_F=fopen("".$result_dir."/circos$circos_num.info","w");
		$spc_num = 0;
		fwrite($circos_info_F,"Resolution\t$resolution\n");
		foreach($arr_circos_info as $i => $v){
			if($i%2 == 0){
				fwrite($circos_info_F,"$spc_num\t$v\t");
			} else {
				fwrite($circos_info_F,"$v\n");
				$spc_num++;
			}
		}
		fclose($circos_info_F);
		echo $flag;
	} else {
		echo $flag;
	}
?>
