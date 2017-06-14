<?php
	$project_name = $_POST['prj'];
	
	shell_exec("cp ./path_info.txt ./.path_tmp");
	$flag = 0;
	$path_F = fopen("./path_info.txt","w");
	$tmp_F = fopen("./.path_tmp","r");
	while($line = fgets($tmp_F)){
		$line = trim($line);
		if(preg_match('/^>/',$line)){
			if($line == ">$project_name"){
				$flag = 1;
			} else {
				$flag = 0;
			}
		}
		
		if($flag == 0){
			fwrite($path_F,"$line\n");
		} else {
			if(!preg_match('/^Published/',$line)){
				fwrite($path_F,"$line\n");
			}
		}
	}
	fclose($tmp_F);
	fclose($path_F);

	shell_exec("rm -rf ../publish/$project_name");
	echo "Your website ($project_name) is successfully unpublished.";
?>
