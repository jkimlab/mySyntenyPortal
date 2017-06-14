<?php
	$project_name = $_POST['prj'];
	$page = $_POST['page'];
	shell_exec("cp ../data/$project_name/cur_state ../data/$project_name/.state_tmp");
	if($page == "syncircos-body"){
		$reset_F = fopen("../data/$project_name/.reset_state","r");
		while($line = fgets($reset_F)){
			$line = trim($line);
			if(preg_match('/^SC/',$line)){
				$arr = split("[[:space:]]",$line);
				$circos_num = $arr[2];
			}
		}
		fclose($reset_F);
		$cur_F = fopen("../data/$project_name/cur_state","w");
		$prev_F = fopen("../data/$project_name/.state_tmp","r");
		while($line = fgets($prev_F)){
			$line = trim($line);
			if(preg_match('/^SC/',$line)){
				fwrite($cur_F,"SC\tcircos_num\t$circos_num\n");
			} else {
				fwrite($cur_F,"$line\n");
			}
		}
		fclose($prev_F);
		fclose($cur_F);
	} else {
		$browser_info = Array();
		$reset_F = fopen("../data/$project_name/.reset_state","r");
		while($line = fgets($reset_F)){
			$line = trim($line);
			if(preg_match('/^SB/',$line)){
				$arr = split("[[:space:]]",$line);
				$browser_info[$arr[1]] = $arr[2];
			}
		}
		fclose($reset_F);
		$cur_F = fopen("../data/$project_name/cur_state","w");
		$prev_F = fopen("../data/$project_name/.state_tmp","r");
		while($line = fgets($prev_F)){
			$line = trim($line);
			if(preg_match('/^SB/',$line)){
				$arr = split("[[:space:]]",$line);
				$t = $arr[1];
				fwrite($cur_F,"$arr[0]\t$arr[1]\t$browser_info[$t]\n");
			} else {
				fwrite($cur_F,"$line\n");
			}
		}
		fclose($prev_F);
		fclose($cur_F);
	}
?>
