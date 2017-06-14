<?php
	$project_name = $_POST['prj'];
	shell_exec("../scripts/publish.pl $project_name");
	shell_exec("cp ./path_info.txt ./.path_tmp");

	$project_path = Array();
	$flag = 0;
	$path_F = fopen("./path_info.txt","w");
	$tmp_F = fopen("./.path_tmp","r");
	while($line = fgets($tmp_F)){
		$line = trim($line);
		if(preg_match('/^>/',$line)){
			$flag++;
			$arr = preg_split('/>/',$line);
			$proj = $arr[1];
			if($flag < 3){
				fwrite($path_F,"$line\n");
			}
			continue;
		}

		if($flag < 3){
			fwrite($path_F,"$line\n");
		} else {
			if($line == ""){continue;}
			$arr = preg_split('/=/',$line);
			$project_path[$proj][$arr[0]] = $arr[1];
			if($proj == $project_name){
				$project_path[$proj]['Published_website_path'] = "[mySyntenyPortal root]/publish/$project_name";
			}
		}
	}
	fclose($tmp_F);

	foreach($project_path as $i => $val){
		fwrite($path_F,">$i\n");
		ksort($project_path[$i]);
		foreach($project_path[$i] as $j => $val2){
			fwrite($path_F,"$j=$val2\n");
		}
		fwrite($path_F,"\n");
	}

	fclose($path_F);

	shell_exec("chmod -R 777 ../publish/$project_name");

	echo "The website has been published in\n[mySyntenyPortal root]/publish/$project_name";
?>
