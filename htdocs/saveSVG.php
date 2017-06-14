<?php
	$project_name = $_POST['prj'];
	$svg_code = $_POST['svg'];
	$type = $_POST['type'];

	if($type == "SynCircos"){
		$circos_num = $_POST['circos_num'];
		$out_dir = "../data/$project_name/circos/circos$circos_num/";
		shell_exec("mkdir -p ".$out_dir);
		$svg_F = fopen("$out_dir/SynCircos.svg","w");
		fwrite($svg_F,$_POST['svg']);
		fclose($svg_F);
		
		$pre_svg_F = "$out_dir/SynCircos.svg";
		$pdf_F = "$out_dir/SynCircos.pdf";
		$png_F = "$out_dir/SynCircos.png";
		$jpg_F = "$out_dir/SynCircos.jpg";
	} else {
		$out_dir = "../data/$project_name/browser/image";
		shell_exec("mkdir -p ".$out_dir);
		$svg_F = fopen("$out_dir/SynBrowser.svg","w");
		fwrite($svg_F,$_POST['svg']);
		fclose($svg_F);
		
		$pre_svg_F = "$out_dir/SynBrowser.svg";
		$pdf_F = "$out_dir/SynBrowser.pdf";
		$png_F = "$out_dir/SynBrowser.png";
		$jpg_F = "$out_dir/SynBrowser.jpg";
	}
	shell_exec("convert -density 100 ".$pre_svg_F." ".$pdf_F."");
	shell_exec("convert -density 100 ".$pre_svg_F." ".$png_F."");
	shell_exec("convert -density 100 ".$pre_svg_F." ".$jpg_F."");
	shell_exec("chmod -R 777 $out_dir");
?>
