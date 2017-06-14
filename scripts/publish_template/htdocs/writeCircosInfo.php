<?php
	session_Start();
	$user_id = session_Id();
	$spc_name = $_POST['name'];
	$spc_chr = $_POST['chr'];
	$spc_type = $_POST['type'];
	$circos_num = $_POST['cir_num'];
	$resolution = "";
	if(isset($_POST['res'])){$resolution = $_POST['res'];}
	$result_dir = "../session/$user_id/circos/circos$circos_num";
	shell_exec("mkdir -p $result_dir");
	if($spc_type == "ref"){
		shell_exec("mkdir -p ".$result_dir);
		$circos_info=fopen("$result_dir/circos$circos_num.info","w");
		fwrite($circos_info,"Resolution\t$resolution\n");
		fwrite($circos_info,"0\t$spc_name\t$spc_chr\n");
		fclose($circos_info);
	} else {
		$tar_num = $_POST['tn'];
		$circos_info=fopen("$result_dir/circos$circos_num.info","a");
		fwrite($circos_info,"$tar_num\t$spc_name\t$spc_chr\n");
		fclose($circos_info);
	}
?>
