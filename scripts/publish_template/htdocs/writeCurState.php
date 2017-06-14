<?php
	session_Start();
	$user_id = session_Id();
	$cur_state_F = "../session/$user_id/cur_state";
	if(isset($_POST['cir_num'])){
		$circos_num = $_POST['cir_num'];
		$curstate = fopen($cur_state_F,"r");
		$keep_lines = array();
		while($line = fgets($curstate)){
			$line = trim($line);
			if(!preg_match('/^SC/',$line)){
				array_push($keep_lines,$line);
			}
		}
		fclose($curstate);

		$curstate = fopen($cur_state_F,"w");
		foreach ($keep_lines as $i => $line){
			fwrite($curstate,"$line\n");
		}
		fwrite($curstate,"SC\tcircos_num\t$circos_num\n");
		fclose($curstate);
	} else {
		$ref_name = $_POST['S1'];
		$tar_name = $_POST['S2'];
		$asmbl = $_POST['ASMBL'];
		$resolution = $_POST['RES'];
		$curstate = fopen($cur_state_F,"r");
		$keep_lines = array();
		while($line = fgets($curstate)){
			$line = trim($line);
			if(!preg_match('/^SB/',$line)){
				array_push($keep_lines,$line);
			}
		}
		fclose($curstate);

		$curstate = fopen($cur_state_F,"w");
		foreach ($keep_lines as $i => $line){
			fwrite($curstate,"$line\n");
		}
		fwrite($curstate,"SB\tref_name\t$ref_name\n");
		fwrite($curstate,"SB\tref_asmbl\t$asmbl\n");
		fwrite($curstate,"SB\ttar_name\t$tar_name\n");
		fwrite($curstate,"SB\tres\t$resolution\n");
		fclose($curstate);
	}
?>
