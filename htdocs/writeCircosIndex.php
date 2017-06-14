<?php
	$project_name = $_POST['prj'];
	$circos_num = $_POST['cir_num'];
	$circos_info = $_POST['circos_info'];
	$circos_index_F = fopen("../data/$project_name/circos/index","a");
		fwrite($circos_index_F,"$circos_num\t$circos_info\n");
	fclose($circos_index_F);
?>
