$(document).ready(function(){
	$('#ref_browser').change(function(){
		sessionStorage.clear();
		var rn = $('#ref_browser option:selected').attr("id");
		var prj = $('#publish_select option:selected').val();
		window.location="synbrowser.php?PRJ="+prj+"&REF="+rn;
	});
});

//Hash variable
	var hash_spc_info = {};
	var hash_asmbl_info = {};
	var hash_block_info = {};
	var hash_asmbl_con = {};
	var hash_ref_target = {};
	var hash_asmbl_color = {};
	var hash_json = {};
	var hash_gene_info = {};
//Array gene name
	var arr_gene_name = [];
//SVG information
	var selected_asmblL;
	var width = 1000;
	var height = 760;
	var chr_rect_width = 30;
	var con_rect_width = 28;
	var target_x1 = 285;
	var target_x2 = 720;
	var btw_chr = 50;
	var max_height = 298;
	var mod_rate;
	var gene_rate;
	var ref_y_pos = 150;
	var max_cl_len;
	var ref_x_pos = (width-chr_rect_width)/2;
	var target_y_pos1;
	var target_y_pos2;
	var rgb;
	var text_color;
	var json_gene_info;
	var wiki_gene_name;
	var wiki_gene_chr;

	function get_spc_id(){
		sessionStorage.clear();
		var select1 = document.getElementById("ref_browser");
		var select2 = document.getElementById("tar_browser");
		var spc1 = select1.options[select1.selectedIndex].value;
		var spc2 = select2.options[select2.selectedIndex].value;
		var resolution = 0;
		if($('#resolution').length != 0){
			resolution = $('#resolution').val();
		}
		var chr = document.getElementById("refChr_browser").value;
		var prj = $('#publish_select option:selected').val();
		$.ajaxSetup({async: false});
		var CurState = 'writeCurState.php',d2 = {'prj':prj,'S1':spc1,'S2':spc2,'ASMBL':chr,'RES':resolution};
		$.post(CurState,d2,function(response2){});
		if(resolution == 0){
			window.location="synbrowser.php?PRJ="+proj+"&REF="+spc1+"&TAR="+spc2+"&ASMBL="+chr;
		} else {
			window.location="synbrowser.php?PRJ="+proj+"&REF="+spc1+"&TAR="+spc2+"&RES="+resolution+"&ASMBL="+chr;
		}
	}
	
	function draw_svg (){
		var main_svg = d3.select("#body").append("svg")
				.attr("id","main_svg")
				.attr("width",width)
				.attr("height",height);		
		var whole_synteny = main_svg.append("g")
				.attr("id","sy_whole_group");
		var chromosome_group = whole_synteny.append("g")
				.attr("id","sy_chrmosome_group");
		var ref_group = chromosome_group.append("g")
				.attr("id","sy_"+ref+"_group");
		var target_group = chromosome_group.append("g")
				.attr("id","sy_"+target+"_group");
		var conserved_group = whole_synteny.append("g")
				.attr("id","sy_conserved_group");
		var tooltip_group = main_svg.append("g")
				.attr("id","sy_tooltip_group")
				.style("opacity",0);
		draw_ref_chr(selected_asmbl);
	}
	
	function getRate(chr){
		var ref_chr_len = selected_asmblL;
		var arr_target_chr = hash_ref_target[chr].split("\t");
		var max_chr_len = ref_chr_len;
		for (var i = 0; i < arr_target_chr.length; i++){
			var target_chr = arr_target_chr[i];
			var target_chr_len = hash_asmbl_info[target_chr]*1;
			if (max_chr_len < target_chr_len){
				max_chr_len = target_chr_len;
			}
		}
		mod_rate = max_height/max_chr_len * 1;
	}
	
	function get_max_height(chr){
		var max_len;
		var max_cl_len = 20 * max_ref_asmbl_num + 70;
		var length_ref = selected_asmblL * mod_rate * 1;
		var total_length_ref = length_ref + 150;
		var arr_target_chr = hash_ref_target[chr].split("\t");
		var total_length_left = 0;
		var total_length_right = 0;
		
		if (arr_target_chr.length == 1){
			var length_left = hash_asmbl_info[arr_target_chr[0]]*1*mod_rate;
			if (((length_ref - length_left)/2) >=130 || ((length_ref - length_left)/2) <= -100){
				target_y_pos1 = 70;
			} else {
				target_y_pos1 = ref_y_pos + ((length_ref - length_left)/2);		
			}
			total_length_left = length_left + target_y_pos1;	
		}
		else if (arr_target_chr.length == 2){
			var length_left = hash_asmbl_info[arr_target_chr[0]]*1*mod_rate;
			var length_right = hash_asmbl_info[arr_target_chr[1]]*1*mod_rate; 
			if (((length_ref - length_left)/2) <= -100){
				target_y_pos1 = 70;
			} else {
				target_y_pos1 = ref_y_pos + ((length_ref - length_left)/2);
			}
			if (((length_ref - length_right)/2) <= -100){
				target_y_pos2 = 70;
			} else {
				target_y_pos2 = ref_y_pos + ((length_ref - length_right)/2);
			}
			total_length_left = length_left + target_y_pos1;
			total_length_right = length_right + target_y_pos2;
		} else {		
			for (var i = 0; i < arr_target_chr.length; i += 2){
				total_length_left = total_length_left + hash_asmbl_info[arr_target_chr[i]]*1*mod_rate;
				if (i != 0){
					total_length_left += btw_chr;
				}
			}	
			for (var i = 1; i < arr_target_chr.length; i += 2){
				total_length_right = total_length_right + hash_asmbl_info[arr_target_chr[i]]*1*mod_rate;
				if (i != 1){
					total_length_right += btw_chr;
				}
			}
			
			if (((length_ref - total_length_left)/2) <= -100){
				target_y_pos1 = 70;
			} else {
				target_y_pos1 = ref_y_pos + ((length_ref - total_length_left)/2);
			}
			if (((length_ref -total_length_right)/2) <= -100){
				target_y_pos2 = 70;
			} else {
				target_y_pos2 = ref_y_pos + ((length_ref - total_length_right)/2);
			}
			total_length_left += target_y_pos1;
			total_length_right += target_y_pos2;
		}
		
		max_len = total_length_left;
		if (max_len < total_length_right){
			max_len = total_length_right;
		}
		max_len *= 1;
		
		if (max_len > max_cl_len){
			if ((max_len + 100) > height){
				var tmp_height = max_len + 100;
				d3.select("#main_svg").attr("height",tmp_height);
			} else{
				d3.select("#main_svg").attr("height",height);
			}
		} else {
			var tmp_height = max_cl_len + 100;
			d3.select("#main_svg").attr("height",tmp_height);
		}	
	}
	
	function draw_color_legend(){
		//Color legend parameters
		var rect_size = 20;
		var max_rect_y = max_ref_asmbl_num * rect_size;
		var text_x = 180;
		var text_y = 0;	
		//Color legend main text
		var color_legend = d3.select("#main_svg").append("g").attr("id","sy_color_legend_group");
		var color_legend_text = color_legend.append("text")
				.attr("id","sy_color_legend_text")
				.style("font-size","15px")
				.style("font-family","inherit")
				.style("cursor","default")
				.style("font-weight","bold")
				.text("Color Legend");
		
		//Color legend position and rotation
		var text_width = $("#sy_color_legend_text")[0].getBoundingClientRect().width;
		if ((max_rect_y - text_width) > 0){
			text_y = text_width + ((max_rect_y - text_width)/2) + 70;
		} else {
			text_y = ((text_width-max_rect_y)/2) + max_rect_y + 70;
		}
		color_legend_text.attr("transform","translate("+text_x+","+text_y+") rotate(270)")
		
		for (var rchr in hash_asmbl_color){
			var trgb = hash_asmbl_color[rchr].split("\t")[0];
			var ttext_color = hash_asmbl_color[rchr].split("\t")[1];
			Dcolor_legend(rchr, trgb, ttext_color, text_x);
		}
	}
	
	function Dcolor_legend(rchr, rgb, text_color, text_x){
	//Rect or text of color legend parameters	
		var rect_size = 20;
		var rect_x = text_x + 10;
		var rect_text_x = text_x + 20;
		var rect_y,rect_text_y;
		var chr_num = 0;
		for (var trchr in hash_asmbl_color){
			if (trchr != rchr){
				chr_num++;
			} else {
				break;
			}
		}
		//Color legend main text
		var color_legend = d3.select("#sy_color_legend_group");
		var legend_rect = color_legend.append("g")
				.attr("id","sy_legend_rect");
		var legend_text = color_legend.append("g")
				.attr("id","sy_legend_text");
		// Main color legend	
		rect_y = 70 + rect_size * chr_num;
		rect_text_y = rect_y + 15;
		var sub_chr = rchr;
		var chr_reg = /^chr/;
		if(chr_reg.test(rchr)){
			sub_chr = rchr.substring(3);
		}
		
		if(sub_chr.length > 3){
			sub_chr = sub_chr.substring(0,3);
		}
		
		//Rect of color legend		
		legend_rect.append("rect")
				.attr("id","sy_legend_"+rchr+"_rect")
				.attr("x",rect_x)
				.attr("y",rect_y)
				.attr("width",rect_size)
				.attr("height",rect_size)
				.style("stroke","black")
				.style("stroke-width","1px")
				.style("fill","rgb("+rgb+")")
				.style("cursor","pointer")
				.on("mouseover",function(){highlight(rchr,'chr');})
				.on("mouseout",function(){dehighlight(rchr);})
				.on("click",function(){reload_function(rchr);});
		//Text of color test		
		legend_text.append("text")		
				.attr("id","sy_legend_"+rchr+"_text")
				.attr("x",rect_text_x)
				.attr("y",rect_text_y)
				.style("fill",text_color)
				.style("font-family","inherit")
				.style("font-weight","bold")
				.style("text-anchor","middle")
				.style("cursor","pointer")
				.text(sub_chr)
				.on("mouseover",function(){highlight(rchr,'chr');})
				.on("mouseout",function(){dehighlight(rchr);})
				.on("click",function(){reload_function(rchr);});
				
		if (sub_chr.length == '3'){
			d3.select("#sy_legend_"+rchr+"_text").style("font-size","10px");
		}
		else{
			d3.select("#sy_legend_"+rchr+"_text").style("font-size","12px");
		}
	}
	
	function draw_ref_chr(chr)
	{
		getRate(chr);
		get_max_height(chr);
		var ref_common_name = ref;
		var chr_len = selected_asmblL * mod_rate + 2;
		
		var R_chr_draw_group = d3.select("#sy_"+ref+"_group")
				.append("g")
				.attr("id","sy_"+ref+"_"+chr+"_group")
				.attr("transform","translate("+ref_x_pos+","+ref_y_pos+")");
		
		var spc_text = R_chr_draw_group.append("text")
				.attr("x",chr_rect_width/2)
				.attr("y",-20)
				.style("font-size","17px")
				.style("font-weight","bold")
				.style("font-family","inherit")
				.style("text-anchor","middle")
				.text(ref_common_name)
		
		var chr_text = R_chr_draw_group.append("text")
				.attr("x",chr_rect_width/2)
				.attr("y",chr_len + 25)
				.style("font-size","17px")
				.style("font-weight","bold")
				.style("font-family","inherit")
				.style("text-anchor","middle")
				.text(chr)
		
		var left_chr_draw = R_chr_draw_group.append("line")
				.style("fill","none")
				.style("stroke","black")
				.style("stroke-width",2)
				.attr("x1",0)
				.attr("y1",0)
				.attr("x2",0)
				.attr("y2",chr_len);
		
		var right_chr_draw = R_chr_draw_group.append("line")
				.style("fill","none")
				.style("stroke","black")
				.style("stroke-width",2)
				.attr("x1",chr_rect_width)
				.attr("y1",0)
				.attr("x2",chr_rect_width)
				.attr("y2",chr_len);
			
		var top_elliptical_arc = R_chr_draw_group.append("path")
				.style("stroke","black")
				.style("stroke-width",2)
				.style("fill","none")
				.attr("d","M 30 0 A 15 6 0 0 0 0 0");
				
		var bottom_elliptical_arc = R_chr_draw_group.append("path")
				.style("stroke","black")
				.style("stroke-width",2)
				.style("fill","none")
				.attr("d","M 0 "+chr_len+" A 15 6 0 0 0 30 "+chr_len);
				
		var arr_target_chr = hash_ref_target[chr].split("\t");
		var arr_con = hash_asmbl_con[chr].split("\t");
		draw_color_legend();
		for (var i = 0; i < arr_target_chr.length; i++){
			var target_chr = arr_target_chr[i];
			draw_target_chr(chr,target_chr);
		}
		for (var i = 0; i < arr_con.length; i++){
			var con = arr_con[i];
			draw_conserved_segments(con);
		}
	}
	
	function draw_target_chr (ref_chr, target_chr){
		var arr_target_chr = hash_ref_target[ref_chr].split("\t");
		var target_common_name = target;
		var chr_len = hash_asmbl_info[target_chr] * 1 * mod_rate + 2;
		var x_pos = 0;
		var y_pos1 = target_y_pos1;
		var y_pos2 = target_y_pos2;
		var pos;
		var T_chr_draw_group;
		for (var i = 0; i < arr_target_chr.length; i++){
			if (target_chr == arr_target_chr[i]){
				pos = i;
			}
		}
		
		if (pos % 2 == 0){
			x_pos = target_x1;
		} else {
			x_pos = target_x2;
		}

		var total_length = 0;
		
		if (pos % 2 == 0){
			if (pos != 0){
				for (var i = 0; i <= pos-2; i += 2){
					var tmp_chr_len = hash_asmbl_info[arr_target_chr[i]] * 1 * mod_rate;
					y_pos1 = y_pos1 + tmp_chr_len + btw_chr;
				}
			}
			T_chr_draw_group = d3.select("#sy_"+target+"_group")
					.append("g")
					.attr("id","sy_"+target+"_"+target_chr+"_group")
					.attr("transform","translate("+x_pos+","+y_pos1+")");
		} else {						
			if (pos != 1){
				for(var i = 1; i <= pos-2; i += 2){
					var tmp_chr_len = hash_asmbl_info[arr_target_chr[i]] * 1 * mod_rate;
					y_pos2 = y_pos2 + tmp_chr_len + btw_chr;
				}
			}
			T_chr_draw_group = d3.select("#sy_"+target+"_group")
					.append("g")
					.attr("id","sy_"+target+"_"+target_chr+"_group")
					.attr("transform","translate("+x_pos+","+y_pos2+")");
		}

		if (pos == 0 || pos == 1){
			var spc_text = T_chr_draw_group.append("text")
					.attr("x",chr_rect_width/2)
					.attr("y",-20)
					.style("font-size","17px")
					.style("font-weight","bold")
					.style("font-family","inherit")
					.style("text-anchor","middle")
					.text(target_common_name);
		}
		
		var chr_text = T_chr_draw_group.append("text")
				.attr("x",chr_rect_width/2)
				.attr("y",chr_len + 25)
				.style("font-size","17px")
				.style("font-weight","bold")
				.style("font-family","inherit")
				.style("text-anchor","middle")
				.text(target_chr)
				.on("mouseover",function(){target_highlight(ref_chr,target_chr);})
				.on("mouseout",function(){target_dehighlight(ref_chr,target_chr);});
				
		var left_chr_draw = T_chr_draw_group.append("line")
				.style("fill","none")
				.style("stroke","black")
				.style("stroke-width",2)
				.attr("x1",0)
				.attr("y1",0)
				.attr("x2",0)
				.attr("y2",chr_len);
		
		var right_chr_draw = T_chr_draw_group.append("line")
				.style("fill","none")
				.style("stroke","black")
				.style("stroke-width",2)
				.attr("x1",chr_rect_width)
				.attr("y1",0)
				.attr("x2",chr_rect_width)
				.attr("y2",chr_len);
				
		var top_elliptical_arc = T_chr_draw_group.append("path")
				.style("stroke","black")
				.style("stroke-width",2)
				.style("fill","none")
				.attr("d","M 30 0 A 15 6 0 0 0 0 0");
				
		var bottom_elliptical_arc = T_chr_draw_group.append("path")
				.style("stroke","black")
				.style("stroke-width",2)
				.style("fill","none")
				.attr("d","M 0 "+chr_len+" A 15 6 0 0 0 30 "+chr_len);
	}
	
	function draw_conserved_segments (con){
		var R_arr_tmp = (hash_block_info[ref][con]).split("\t");
		var R_chr = R_arr_tmp[0];
		var R_chr_len = selected_asmbl;
		var R_y1 = R_arr_tmp[1]*mod_rate*1;
		var R_y2 = R_arr_tmp[2]*mod_rate*1;
		var R_len = R_y2 - R_y1;
		var R_dir = R_arr_tmp[3];
		var R_y_pos1 = ref_y_pos + R_y1 + 1;
		var R_y_pos2 = R_y_pos1 + R_len;
		var R_x_pos = ref_x_pos + 1;
		var T_arr_tmp = hash_block_info[target][con].split("\t");
		var T_chr = T_arr_tmp[0];
		var arr_target_chr = hash_ref_target[R_chr].split("\t");
		var T_y1 = T_arr_tmp[1]*mod_rate*1;
		var T_y2 = T_arr_tmp[2]*mod_rate*1;
		var T_len = T_y2 - T_y1;
		var T_dir = T_arr_tmp[3];
		var T_x_pos;
		var T_y_pos;
		var T_y_pos1;
		var T_y_pos2;
		var E_x_pos1;
		var E_x_pos2;
		
		for (var i = 0; i < arr_target_chr.length; i++){
			if (T_chr == arr_target_chr[i]){
				T_y_pos = i;
			}
		}
		
		if (T_y_pos % 2 == 0){
			T_x_pos = target_x1 + 1;
			E_x_pos1 = target_x1 + chr_rect_width + 1;
			E_x_pos2 = ref_x_pos - 1;
			T_y_pos1 = target_y_pos1;
			if (T_y_pos != 0)
			{
				for (var i = 0; i <= T_y_pos-2; i += 2)
				{
					var tmp_chr_len = hash_asmbl_info[arr_target_chr[i]] * mod_rate * 1;
					T_y_pos1 = T_y_pos1 + tmp_chr_len + btw_chr;
				}
			}
			T_y_pos1 += T_y1 + 1;
			T_y_pos2 = T_y_pos1 + T_len;
		} else {
			T_x_pos = target_x2 + 1;
			E_x_pos1 = ref_x_pos + chr_rect_width + 1;
			E_x_pos2 = target_x2 - 1;
			T_y_pos1 = target_y_pos2 + 1;
			if (T_y_pos != 1){
				for (var i = 1; i <= T_y_pos-2; i += 2){
					var tmp_chr_len = hash_asmbl_info[arr_target_chr[i]] * mod_rate * 1;
					T_y_pos1 = T_y_pos1 + tmp_chr_len + btw_chr;
					T_y_pos2 = T_y_pos1;
				}
			}
			T_y_pos2 = T_y_pos1;
			T_y_pos1 += T_y1 + 1;
			T_y_pos2 = T_y_pos1 + T_len;
		}
					
		var con_group = d3.select("#sy_conserved_group")
				.append("g")
				.attr("id","sy_conserved_"+con+"_group");
				
		var ref_con_rect = con_group.append("rect")
				.attr("id","sy_conserved_"+ref+"_"+con+"_rect")
				.attr("x",R_x_pos)
				.attr("y",R_y_pos1)
				.attr("width",con_rect_width)
				.attr("height",R_len)
				.style("fill","rgb("+rgb+")")
				.style("stroke","none")
				.on("mouseover",function(){highlight(con); info_vis(con);})
				.on("mouseout",function(){dehighlight(con);})
				.on("mousemove",function(){info_move();})
				.on("click",function(){conserved_region_zoom_in(con);});
		
		if (ref == 'susScr2'){
			ref_con_rect.style("cursor","default");
		} else {
			ref_con_rect.style("cursor","pointer");
		}
				
		var target_con_rect = con_group.append("rect")
				.attr("id","sy_conserved_"+target+"_"+con+"_rect")
				.attr("x",T_x_pos)
				.attr("y",T_y_pos1)
				.attr("width",con_rect_width)
				.attr("height",T_len)
				.style("fill","rgb("+rgb+")")
				.style("storke","none")
				.on("mouseover",function(){highlight(con); info_vis(con);})
				.on("mouseout",function(){dehighlight(con);})
				.on("r",function(){info_move();})
				.on("click",function(){conserved_region_zoom_in(con);});
		if (ref == 'susScr2'){
			target_con_rect.style("cursor","default");
		} else {
			target_con_rect.style("cursor","pointer");
		}
				
		var edge_con_polygon = con_group.append("polygon")
				.attr("id","sy_edge_"+ref+"_"+target+"_"+con+"_polygon");
		if (R_dir == T_dir){
			if (T_y_pos % 2 == 0){
				edge_con_polygon.attr("points",""+E_x_pos1+","+T_y_pos1+" "+E_x_pos1+","+T_y_pos2+" "+E_x_pos2+","+R_y_pos2+" "+E_x_pos2+","+R_y_pos1+"");
			} else {
				edge_con_polygon.attr("points",""+E_x_pos1+","+R_y_pos1+" "+E_x_pos1+","+R_y_pos2+" "+E_x_pos2+","+T_y_pos2+" "+E_x_pos2+","+T_y_pos1+"");
			}
		} else {
			if (T_y_pos % 2 ==0){
				edge_con_polygon.attr("points",""+E_x_pos1+","+T_y_pos1+" "+E_x_pos1+","+T_y_pos2+" "+E_x_pos2+","+R_y_pos1+" "+E_x_pos2+","+R_y_pos2+"");
			} else {
				edge_con_polygon.attr("points",""+E_x_pos1+","+R_y_pos1+" "+E_x_pos1+","+R_y_pos2+" "+E_x_pos2+","+T_y_pos1+" "+E_x_pos2+","+T_y_pos2+"");
			}
		}
		
		edge_con_polygon.attr("stroke","none")
				.style("fill","rgb("+rgb+")")
				.style("fill-opacity",".6")
				.on("mouseover",function(){highlight(con); info_vis(con);})
				.on("mouseout",function(){dehighlight(con);})
				.on("mousemove",function(){info_move();})
				.on("click",function(){conserved_region_zoom_in(con);});
		if (ref == 'susScr2'){
			edge_con_polygon.style("cursor","default");
		} else {
			edge_con_polygon.style("cursor","pointer");
		}
	}
	
	function highlight (norm, type){
		d3.select("#sy_color_legend_group")
				.selectAll("rect")
				.style("fill-opacity",.2);
		d3.select("#sy_conserved_group")
				.selectAll("rect")
				.style("fill-opacity",.2);
		d3.selectAll("polygon")
				.style("fill-opacity",.2);
		d3.select("#sy_tooltip_group")
				.attr("transform","translate(-500,-500)")
				.style("opacity",0);
		
		if (type == 'chr'){
			d3.select("#sy_legend_"+norm+"_rect")
					.style("fill-opacity","1");
			if (norm == selected_asmbl){
				var arr_con = hash_asmbl_con[norm].split("\t");
				for (var i = 0; i < arr_con.length; i++){
					var con = arr_con[i];
					d3.select("#sy_conserved_"+ref+"_"+con+"_rect")
							.style("fill-opacity",1);
					d3.select("#sy_conserved_"+target+"_"+con+"_rect")
							.style("fill-opacity",1);
					d3.select("#sy_edge_"+ref+"_"+target+"_"+con+"_polygon")
							.style("fill-opacity",.6);
				}
			}
		} else {
			if (norm.indexOf(",") != -1){
				var arr_norm = norm.split(",");
				for (var i = 0; i < arr_norm.length; i++){
					var tmp_con = arr_norm[i];
					var ref_chr = hash_block_info[ref][tmp_con].split("\t")[0];
					d3.select("#sy_legend_"+ref_chr+"_rect")
							.style("fill-opacity","1");
					d3.select("#sy_conserved_"+ref+"_"+tmp_con+"_rect")
							.style("fill-opacity",1)
							.style("stroke","black")
							.style("stroke-width","1px");
					d3.select("#sy_conserved_"+target+"_"+tmp_con+"_rect")
							.style("fill-opacity",1)
							.style("stroke","black")
							.style("stroke-width","1px");
					d3.select("#sy_edge_"+ref+"_"+target+"_"+tmp_con+"_polygon")
							.style("fill-opacity",.6)
							.style("stroke","black")
							.style("stroke-width","1px");
				}
			} else {
				var ref_chr = hash_block_info[ref][norm].split("\t")[0];
				d3.select("#sy_legend_"+ref_chr+"_rect")
						.style("fill-opacity",1);
				d3.select("#sy_conserved_"+ref+"_"+norm+"_rect")
						.style("fill-opacity",1)
						.style("stroke","black")
						.style("stroke-width","1px");
				d3.select("#sy_conserved_"+target+"_"+norm+"_rect")
						.style("fill-opacity",1)
						.style("stroke","black")
						.style("stroke-width","1px");
				d3.select("#sy_edge_"+ref+"_"+target+"_"+norm+"_polygon")
						.style("fill-opacity",.6)
						.style("stroke","black")
						.style("stroke-width","1px");
			}
		}
	}
	
	function dehighlight(norm){
		d3.select("#sy_conserved_group")
				.selectAll("rect")
				.style("fill-opacity",1);
		d3.select("#sy_color_legend_group")
				.selectAll("rect")
				.style("fill-opacity",1);
		d3.selectAll("polygon")
				.style("fill-opacity",.6)
				.style("stroke","none");
		d3.select("#sy_tooltip_group")
				.style("opacity",0)
				.attr("transform","translate(-500,-500)");
				
		if (norm.indexOf(",") != -1){
            var arr_con = norm.split(",");
            for (var i = 0; i < arr_con.length; i++){
                var tmp_con = arr_con[i];
                d3.select("#sy_conserved_"+ref+"_"+tmp_con+"_rect")
                        .style("stroke","none");
                d3.select("#sy_conserved_"+target+"_"+tmp_con+"_rect")
                        .style("stroke","none");
            }
        } else {
            d3.select("#sy_conserved_"+ref+"_"+norm+"_rect")
                    .style("stroke","none");
            d3.select("#sy_conserved_"+target+"_"+norm+"_rect")
                    .style("stroke","none");
        }	
	}

	function info_vis(con){
		var block_info = "";
		var ref_chr;
		ref_chr = hash_block_info[ref][con].split("\t")[0];
		var ref_s = commify(hash_block_info[ref][con].split("\t")[1]);
		var ref_e = commify(hash_block_info[ref][con].split("\t")[2]);
		var ref_dir = hash_block_info[ref][con].split("\t")[3];
		var target_chr = hash_block_info[target][con].split("\t")[0];
		var target_s = commify(hash_block_info[target][con].split("\t")[1]);
		var target_e = commify(hash_block_info[target][con].split("\t")[2]);
		var target_dir = hash_block_info[target][con].split("\t")[3];
		var ref_info = ref + "\t" + ref_chr + ":" + ref_s + "-" + ref_e + "\t" + ref_dir;
		var target_info = target + "\t" + target_chr + ":" + target_s + "-" + target_e + "\t" + target_dir;
		
		
		d3.select("#sy_tooltip_group")
				.remove();
		var tooltip = d3.select("#main_svg").append("g")
				.attr("id","sy_tooltip_group")
				.style("opacity",0);
		var tooltip_text = tooltip.append("text").attr("id","sy_tooltip_text").style("opacity",0);
		
		tooltip_text.append("tspan")
				.attr("x","0")
				.attr("y","0")
				.style("font-family","inherit")
				.style("font-size","15px")
				.style("fill",text_color)
				.text("Synteny block:" + con);
		tooltip_text.append("tspan")
				.attr("x","0")
				.attr("y","16")
				.style("font-family","inherit")
				.style("font-size","15px")
				.style("fill",text_color)
				.text(ref_info);
		tooltip_text.append("tspan")
				.attr("x","0")
				.attr("y","32")
				.style("font-family","inherit")
				.style("font-size","15px")
				.style("fill",text_color)
				.text(target_info);
				
		var text_width = $("#sy_tooltip_text")[0].getBoundingClientRect().width;
		tooltip_text.remove();
		
		var tooltip_rect = tooltip.append("rect")
				.attr("id","sy_tooltip_rect")
				.attr("x",0)
				.attr("y",0)
				.attr("rx",3)
				.attr("ry",3)
				.attr("width",text_width+20)
				.attr("height",60)
				.attr("fill","rgb("+rgb+")")
				.attr("stroke","#aaa")
				.attr("stroke-width","1px");
				
		var tooltip_text = tooltip.append("text").attr("id","sy_tooltip_text");
		
		tooltip_text.append("tspan")
				.attr("x",8)
				.attr("y",17)
				.style("font-family","inherit")
				.style("font-size","15px")
				.style("fill",text_color)
				.text("Synteny block:" + con);
		tooltip_text.append("tspan")
				.attr("x",8)
				.attr("y",34)
				.style("font-family","inherit")
				.style("font-size","15px")
				.style("fill",text_color)
				.text(ref_info);
		tooltip_text.append("tspan")
				.attr("x",8)
				.attr("y",51)
				.style("font-family","inherit")
				.style("font-size","15px")
				.style("fill",text_color)
				.text(target_info);
				
		var tooltip_opacity = document.getElementById("sy_tooltip_group").style.opacity;
		var tooltip_pos_x = d3.event.pageX - $('#body').offset().left + 20;
		var tooltip_pos_y = d3.event.pageY - $('#body').offset().top;
		var tooltip_w = text_width + 20;
		var tooltip_h = 60;
		var svg_h = $('#main_svg').height();
		
		if (tooltip_pos_y >= (svg_h - tooltip_h)){
			tooltip_pos_y = tooltip_pos_y - tooltip_h;
		}
	
		if (tooltip_pos_x >= (width - tooltip_w)){
			tooltip_pos_x = tooltip_pos_x - tooltip_w - 40;
		}
		
		tooltip.attr("transform","translate("+tooltip_pos_x+","+tooltip_pos_y+")")
				.style("opacity",1);
	}
	
	function info_move(){
		var tooltip = d3.select("#sy_tooltip_group");
		var tooltip_pos_x = d3.event.pageX - $('#body').offset().left + 20;
		var tooltip_pos_y = d3.event.pageY - $('#body').offset().top;
		var tooltip_w = $("#sy_tooltip_group")[0].getBoundingClientRect().width;		
		var tooltip_h = $("#sy_tooltip_group")[0].getBoundingClientRect().height;
		var svg_h = $('#main_svg').height();
		
		if (tooltip_pos_y >= (svg_h - tooltip_h)){
			tooltip_pos_y = tooltip_pos_y - tooltip_h;
		}
		
		if (tooltip_pos_x >= (width - tooltip_w)){
			tooltip_pos_x = tooltip_pos_x - tooltip_w - 40;
		}
		
		var tooltip = d3.select("#sy_tooltip_group").attr("transform","translate("+tooltip_pos_x+","+tooltip_pos_y+")");
	}
	
	function target_highlight(ref_chr,target_chr){
		var arr_target_con = [];
		var arr_ref_con = hash_asmbl_con[ref_chr].split("\t");
		for (var i = 0; i < arr_ref_con.length; i++){
			var tmp_con = arr_ref_con[i];
			var tmp_target_chr = hash_block_info[target][tmp_con].split("\t")[0];
			if (tmp_target_chr == target_chr){
				arr_target_con.push(tmp_con);
			}
		}
		var con = arr_target_con.join(',');
		highlight(con);
	}
	
	function target_dehighlight(ref_chr,target_chr){
		var arr_target_con = [];
		var arr_ref_con = hash_asmbl_con[ref_chr].split("\t");
		for (var i =0; i < arr_ref_con.length; i++){
			var tmp_con = arr_ref_con[i];
			var tmp_target_chr = hash_block_info[target][tmp_con].split("\t")[0];
			if (tmp_target_chr == target_chr){
				arr_target_con.push(tmp_con);
			}
		}
		var con = arr_target_con.join(',');
		dehighlight(con);
	}

	//Gene track
	var layoutInfo = {
			width: 880,
			height: 200,
			container: "#sy_gene_annotation_group",
			initStart: 0,
			initEnd: 200000,
			left_margin: 15,
			right_margin: 15,
			bottom_margin: 5,
			axis_height: 50,
	};
	
	function conserved_region_zoom_in(con){
		if(geneTrack_flag == 0){return;}
		var chr = hash_block_info[ref][con].split("\t")[0];
		var start = hash_block_info[ref][con].split("\t")[1]*1;
		var end = hash_block_info[ref][con].split("\t")[2]*1;
		setTimeout(function(){gene_annotation_zoom_in(chr,start,end,"syn");},1000);
	}
	
	function gene_annotation_zoom_in(chr,p_start,p_end,type)
	{
		if (d3.select("#sy_gene_annotation_group")){
			d3.select("#sy_gene_annotation_group").remove();
		}
		
		var whole_group = d3.select("#sy_whole_group")
				.transition()
				.duration(800)
				.style("opacity",.1);
		var gene_annotation_group = d3.select("#main_svg")
				.append("g")
				.attr("id","sy_gene_annotation_group")
				.attr("transform","translate(50,100)")
				.style("opacity",0);
		var gene_annotation_main_rect = gene_annotation_group.append("rect")
				.attr("x",180)
				.attr("y",-35)
				.attr("width",540)
				.attr("height",35)
				.style("fill","rgb("+rgb+")")
				.style("stroke","none");
		var gene_annotation_main = gene_annotation_group.append("text")
				.attr("id","main_text")
				.attr("x",450)
				.attr("y",-10)
				.attr("text-anchor","middle")
				.style("font-family","inherit")
				.style("font-weight","bold")
				.style("font-size","20px")
				.style("fill",text_color)
				.text("Annotated reference genes in syntenic regions ("+chr+")");
		var gene_annotation_rect = gene_annotation_group.append("rect")
				.attr("id","sy_gene_annotation_rect")
				.attr("x",0)
				.attr("y",0)
				.attr("width",900)
				.attr("height",250)
				.style("fill","white")
				.style("stroke","rgb("+rgb+")")
				.style("stroke-width","3px");
		var gene_annotation_close_circle = gene_annotation_group.append("circle")
				.attr("cx",900)
				.attr("cy",0)
				.attr("r",11)
				.style("stroke","white")
				.style("stroke-width","2px")
				.style("fill","black")
				.style("cursor","pointer")
				.on("click",function(){gene_annotation_zoom_out();});
		var gene_annotation_x = gene_annotation_group.append("text")
				.attr("x",900)
				.attr("y",5)
				.attr("text-anchor","middle")
				.style("font-size","18px")
				.style("font-family","inherit")
				.style("font-weight","bold")
				.style("fill","white")
				.style("cursor","pointer")
				.text("x")
				.on("click",function(){gene_annotation_zoom_out();});
		if (type == 'gene'){
			setTimeout(function(){gene_annotation_group.transition().duration(200).style("opacity",1);gene_annotation_track(chr,p_start,p_end,type)},500);
		} else if (type == 'pos'){
			setTimeout(function(){gene_annotation_group.transition().duration(200).style("opacity",1);gene_annotation_track(chr,p_start,p_end,type)},500);
		} else if (type == 'syn'){
			setTimeout(function(){gene_annotation_group.transition().duration(200).style("opacity",1);gene_annotation_track(chr,p_start,p_end,type)},500);
		} else {
			setTimeout(function(){gene_annotation_group.transition().duration(200).style("opacity",1);gene_annotation_track(chr)},500);
		}
	}

	
	function gene_annotation_track(chr,p_start,p_end,type){
		var visStart, visEnd;
		
		if (type === 'gene'){
			if (typeof p_start !== 'undefined' && typeof p_end !== 'undefined'){
				visStart = p_start * 1;
				visEnd = p_end * 1;
				var sub_length = parseInt((visEnd - visStart));
				visStart -= sub_length;
				visEnd += sub_length;
			} else {
				visStart = hash_json[chr][0].items[0].start * 1;
				visEnd = visStart + 1000000;
			}
		} else if (type == 'pos'){
			visStart = p_start * 1;
			visEnd = p_end * 1;
		}
		else if (type == 'syn')
		{
			if (typeof p_start !== 'undefined' && typeof p_end !== 'undefined')
			{
				if (((p_end * 1) - (p_start * 1)) <= 1000000)
				{
					visStart = p_start * 1;
					visEnd = p_end * 1;
				}
				else
				{
					var mid_point = (p_start * 1) + (((p_end * 1) - (p_start * 1))/2);
					visStart = mid_point - 500000;
					visEnd = mid_point + 500000;
				}				
			}
		}
		else
		{
			visStart = hash_json[chr][0].items[0].start * 1;
			visEnd = visStart + 1000000;
		}
			
		layoutInfo.initStart = visStart;
		layoutInfo.initEnd = visEnd;
		layoutInfo.color = rgb + "\t" + text_color;
		layoutInfo.genomesize = selected_asmblL*1;
		var contextLayout = {container: "#sy_gene_annotation_group" };
		contextLayout.genomesize = selected_asmblL*1;
		trackInfo = hash_json[chr];
		var linearTrack = new genomeTrack(layoutInfo,trackInfo);
		var brush = new linearBrush(contextLayout,linearTrack);
		linearTrack.addBrushCallback(brush);
	}
		
	function gene_annotation_zoom_out()
	{
		var gene_annotation_group = d3.select("#sy_gene_annotation_group")
				.transition()
				.duration(800)
				.style("opacity",0)
				.remove();
		var whole_group = d3.select("#sy_whole_group")
		setTimeout(function(){whole_group.transition().duration(200).style("opacity",1);},500);
	}

	function visual_gene(gene,searched_term){	
		var	unvalidated_gene = gene.toLowerCase();
		var validated_gene = '';
		var validated_chr = '';
		var validated_index1 = '';
		var validated_index2 = '';
		
		for (var i = 0; i < hash_json[selected_asmbl].length - 1; i++){
			for (var j = 0 ; j < hash_json[selected_asmbl][i].items.length; j++){
				var exists_gene = hash_json[selected_asmbl][i].items[j].name.toLowerCase();
				if (unvalidated_gene == exists_gene){
					hash_json[selected_asmbl][i].items[j].sTerm = searched_term;							
					validated_chr = selected_asmbl;
					validated_index1 = i;
					validated_index2 = j;
					validated_gene = gene;
				}
			}
		}
		
		if (validated_gene == ''){
			alert("Gene/Protein not found in our database");
		} else {
			if (typeof hash_ref_target[selected_asmbl] == 'undefined'){
				
			} else {
				var visStart = hash_json[validated_chr][validated_index1].items[validated_index2].start * 1;
				var visEnd = hash_json[validated_chr][validated_index1].items[validated_index2].end * 1;
				setTimeout(function(){mark_gene(validated_chr,validated_index1,validated_index2);},300);
				setTimeout(function(){gene_annotation_zoom_in(validated_chr,visStart,visEnd,"gene");},400);
			}
		}
	}
	
	
	
	function position_search()
	{
		//is_int || ctype_digit || (int)
		var start = document.getElementById("sy_chr_startP_text").value;
		start = start.replace(/\,/g,'');	
		var end = document.getElementById("sy_chr_endP_text").value;
		end = end.replace(/\,/g,'');
		var chr = document.getElementById("sy_chr").value;

		if (start === '' || end === '')
		{
			alert("ERROR - Both start or end coordinates were not provided");
		}
		else
		{
			start = start * 1;
			end = end * 1;
			if (isNaN(start) || isNaN(end))
			{
				alert("ERROR - Start or end coordinates are not integer values");
			}
			else
			{
				if (start < 0 || end < 0)
				{
					alert("ERROR - Start or end coordinates are not positive integer values");
				}
				else
				{
					if (start !== '' && end !== '')
					{
						if (start >= end)
						{
							alert("ERROR - Start coordinate is larger than end coordinate"); 
						}
						else
						{
							sessionStorage.setItem("start",start);
							sessionStorage.setItem("end",end);
							reload_function(chr, "positionSearch");
						}
					}
				}
			}
		}
	}
	
	function draw_gene_trackP(chr, start, end)
	{
		var visStart = start * 1;
		var visEnd = end * 1;
		

		if (visEnd > selected_asmblL || visStart > selected_asmblL)
		{
			var i = hash_json[chr].length;
			var j = hash_json[chr][i-1].items.length;
			visEnd = hash_json[chr][i-1].items[j-1].end * 1;
			visStart = visEnd - 1000000;
			alert("Start or end coordinates are out of the range of the selected chromosome (total length "+selected_asmblL+").\nSo they were adjusted to "+visStart+"-"+visEnd+".");
		}
		
		if (ref == 'susScr2')
		{
			alert("No gene/protein annotation data for susScr2");
			setTimeout(function(){mark_pos(chr,visStart,visEnd);},300);
		}
		else
		{
			setTimeout(function(){mark_pos(chr,visStart,visEnd);},300);
			setTimeout(function(){gene_annotation_zoom_in(chr,visStart,visEnd,"pos");},400);
		}
	}
	
	function mark_pos(chr,start,end)
	{
		var mod_s = start * mod_rate;
		var mod_e = end * mod_rate;
		
		var mark_pos_group = d3.select("#sy_"+ref+"_"+chr+"_group").append("g")
				.attr("id","sy_"+ref+"_"+chr+"_chr_pos_search_group");
				
		mark_pos_group.append("line")
				.style("fill","none")
				.style("stroke","darkgray")
				.style("stroke-width",2)
				.attr("x1",0)
				.attr("x2",0)
				.attr("y1",mod_s)
				.attr("y2",mod_e);
				
		mark_pos_group.append("line")
				.style("fill","none")
				.style("stroke","darkgray")
				.style("stroke-width",2)
				.attr("x1",chr_rect_width)
				.attr("x2",chr_rect_width)
				.attr("y1",mod_s)
				.attr("y2",mod_e);
	}
	
	function mark_gene(chr,index1,index2)
	{
		var con = hash_json[chr][index1].items[index2].cr;
		var R_arr_tmp = hash_block_info[ref][con].split("\t");
		var R_chr = R_arr_tmp[0];
		var T_arr_tmp = hash_block_info[target][con].split("\t");
		var T_chr = T_arr_tmp[0];
		var arr_target_chr = hash_ref_target[R_chr].split("\t");
		var visStart = hash_json[chr][index1].items[index2].start*1;
		var visEnd = hash_json[chr][index1].items[index2].end*1;
		var T_y_pos;
		for (var i = 0; i < arr_target_chr.length; i++)
		{
			if (T_chr == arr_target_chr[i])
			{
				T_y_pos = i;
			}
		}
		
		var gene_y_pos = (hash_json[chr][index1].items[index2].start*1 + ((hash_json[chr][index1].items[index2].end*1 - hash_json[chr][index1].items[index2].start*1)/2))*mod_rate-4;
		var gene_x_pos;
		var mark_gene_group = d3.select("#sy_"+ref+"_"+chr+"_group").append("g")
					.attr("id","sy_"+ref+"_"+chr+"_mark_arrow_rev");
		var mark_gene_img;
		
		if (T_y_pos % 2 == 0)
		{
			mark_gene_img = mark_gene_group.append("image")
					.attr("xlink:href","http://bioinfo.konkuk.ac.kr/synteny_portal/img/arrow_rl.png");
			gene_x_pos = chr_rect_width + 1;
			
		}
		else
		{
			mark_gene_img = mark_gene_group.append("image")
					.attr("xlink:href","http://bioinfo.konkuk.ac.kr/synteny_portal/img/arrow_rr.png");
			gene_x_pos = -10;			
		}
		
		mark_gene_img.attr("x",gene_x_pos)
				.attr("y",gene_y_pos)
				.attr("width",10)
				.attr("height",10)
				.style("cursor","pointer")
				.on("mouseover",function(){highlight(con);})
				.on("mouseout",function(){dehighlight(con);})
				.on("click",function(){gene_annotation_zoom_in(chr,visStart,visEnd,"gene")});
	}
	
	function selectedOptions()
	{
		var sel1 = document.getElementById("ref_browser");
		for (var i = 0; i < sel1.length; i++)
		{
			if (sel1[i].value == ref)
			{
				sel1[i].selected = true;
			}
		}
		
		var sel2 = document.getElementById("tar_browser");
		for (var i = 0; i < sel2.length; i++)
		{
			if (sel2[i].value == target)
			{
				sel2[i].selected = true;
			}
		}
		
		var sel3 = $('#resolution option');
		for (var i = 0; i < sel3.length; i++)
		{
			if (sel3[i].value == resolution)
			{
				sel3[i].selected = true;
			}
		}
		
		var sel4 = document.getElementById("refChr_browser");
		for (var i = 0; i < sel4.length; i++)
		{
			if (sel4[i].value == selected_asmbl)
			{
				sel4[i].selected = true;
			}
		}
		
		var sel5 = document.getElementById("sy_chr");
		for (var i = 0; i < sel5.length; i++)
		{
			if (sel5[i].value == selected_asmbl)
			{
				sel5[i].selected = true;
			}
		}
	}
	
	function linearClick(trackName,d)
	{
		var total_chr = d.chr;
		var chr_num = total_chr.substring(3);
		var start = d.start;
		var end = d.end;
		var Gene_id = d.GeneID;
		var refl = ref.toLowerCase();
		var day = new Date();
		var id= day.getTime();
		window.open("http://genome.ucsc.edu/cgi-bin/hgTracks?db="+refl+"&position="+total_chr+":"+start+"-"+end,id, 'scrollbars=yes,status=no,menubar=no,resizable=yes,width=1200,height=900');
	}
	
	function reload_function(chr, type){
		sessionStorage.removeItem('prj');
		var select1 = document.getElementById("ref_browser");
		var spc1 = select1.options[select1.selectedIndex].value;
		var select2 = document.getElementById("tar_browser");
		var spc2 = select2.options[select2.selectedIndex].value;
		var resolution = 0;
		
		if($('#resolution').length != 0){
			resolution = $('#resolution').val();
		}
		
		if(type == "geneSearch"){
			var Sgene = $('#sy_search_text').val();
			if(resolution == 0){
				window.location="synbrowser.php?PRJ="+proj+"&REF="+ref+"&TAR="+target+"&ASMBL="+chr+"&GENE="+Sgene;
			} else {
				window.location="synbrowser.php?PRJ="+proj+"&REF="+ref+"&TAR="+target+"&RES="+resolution+"&ASMBL="+chr+"&GENE="+Sgene;
			}
		} else if(type == "positionSearch"){
			var Sstart = $('#sy_chr_startP_text').val();
			var Send = $('#sy_chr_endP_text').val();
			if(resolution == 0){
				window.location="synbrowser.php?PRJ="+proj+"&REF="+ref+"&TAR="+target+"&ASMBL="+chr+"&S="+Sstart+"&E="+Send;
			} else {
				window.location="synbrowser.php?PRJ="+proj+"&REF="+ref+"&TAR="+target+"&RES="+resolution+"&ASMBL="+chr+"&S="+Sstart+"&E="+Send;
			}	
		} else {
			var prj = $('#publish_select option:selected').val();
			$.ajaxSetup({async: false});
			var CurState = 'writeCurState.php',d2 = {'prj':prj,'S1':spc1,'S2':spc2,'ASMBL':chr,'RES':resolution};
			$.post(CurState,d2,function(response2){});
			if(resolution == 0){
				window.location="synbrowser.php?PRJ="+proj+"&REF="+ref+"&TAR="+target+"&ASMBL="+chr;
			} else {
				window.location="synbrowser.php?PRJ="+proj+"&REF="+ref+"&TAR="+target+"&RES="+resolution+"&ASMBL="+chr;
			}
		}
	}

	function commify(num){
		var reg = /(^[+-]?\d+)(\d{3})/;
		num += '';
		while(reg.test(num))
			num = num.replace(reg, '$1' + ',' + '$2');
		return num;
	}
	
	function mark_pos(chr,start,end)
	{
		var mod_s = start * mod_rate;
		var mod_e = end * mod_rate;
		
		var mark_pos_group = d3.select("#sy_"+ref+"_"+chr+"_group").append("g")
				.attr("id","sy_"+ref+"_"+chr+"_chr_pos_search_group");
				
		mark_pos_group.append("line")
				.style("fill","none")
				.style("stroke","darkgray")
				.style("stroke-width",2)
				.attr("x1",0)
				.attr("x2",0)
				.attr("y1",mod_s)
				.attr("y2",mod_e);
				
		mark_pos_group.append("line")
				.style("fill","none")
				.style("stroke","darkgray")
				.style("stroke-width",2)
				.attr("x1",chr_rect_width)
				.attr("x2",chr_rect_width)
				.attr("y1",mod_s)
				.attr("y2",mod_e);
	}
	
	function mark_gene(chr,index1,index2){
		var con = hash_json[chr][index1].items[index2].cr;
		var R_arr_tmp = hash_block_info[ref][con].split("\t");
		var R_chr = R_arr_tmp[0];
		var T_arr_tmp = hash_block_info[target][con].split("\t");
		var T_chr = T_arr_tmp[0];
		var arr_target_chr = hash_ref_target[R_chr].split("\t");
		var visStart = hash_json[chr][index1].items[index2].start*1;
		var visEnd = hash_json[chr][index1].items[index2].end*1;
		var T_y_pos;
		for (var i = 0; i < arr_target_chr.length; i++){
			if (T_chr == arr_target_chr[i]){
				T_y_pos = i;
			}
		}
		
		var gene_y_pos = (hash_json[chr][index1].items[index2].start*1 + ((hash_json[chr][index1].items[index2].end*1 - hash_json[chr][index1].items[index2].start*1)/2))*mod_rate-4;
		var gene_x_pos;
		var mark_gene_group = d3.select("#sy_"+ref+"_"+chr+"_group").append("g")
					.attr("id","sy_"+ref+"_"+chr+"_mark_arrow_rev");
		var mark_gene_img;
		
		if (T_y_pos % 2 == 0){
			mark_gene_img = mark_gene_group.append("image")
					.attr("xlink:href","img/arrow_rl.png");
			gene_x_pos = chr_rect_width + 1;
			
		} else {
			mark_gene_img = mark_gene_group.append("image")
					.attr("xlink:href","img/arrow_rr.png");
			gene_x_pos = -10;			
		}
		
		mark_gene_img.attr("x",gene_x_pos)
				.attr("y",gene_y_pos)
				.attr("width",10)
				.attr("height",10)
				.style("cursor","pointer")
				.on("mouseover",function(){highlight(con);})
				.on("mouseout",function(){dehighlight(con);})
				.on("click",function(){gene_annotation_zoom_in(chr,visStart,visEnd,"gene")});
	}
	
	function question_box_on(type, event)
	{
		if($('#qq'+type).length == 0)
		{
			var e = event||window.event;
			var mouseX = e.pageX + 20;
			var mouseY = e.pageY - 50;
			var docu = "";
			
			if(type == "qresolution")
			{
				docu = "Minimum size of a reference block in bp.";
			}
			else if (type == "qgene_search")
			{
				docu = "Users can search for the locations of a reference gene.";
			}
			else if (type == "qposition_search")
			{
				docu = "Users can directly move to the specified region in the reference species, and display syntenic relationship and annotated genes in that region.";
			}

			$('body').append("<div id=\"q"+type+"\" class=\"Question_box\" style=\"position:absolute; top:"+mouseY+"px; left:"+mouseX+"px;\">"
			+ "<b>"+docu+"</b>"
			+ "</div>"
			);
		}
	}

	function question_box_off(type){
		$('.Question_box').remove();
	}

	function question_box_click(type, event){
		$('.Question_box').remove();
		
		if($('#qq'+type).length == 0){
			var e = event||window.event;
			var mouseX = e.pageX + 20;
			var mouseY = e.pageY - 50;
			var docu = "";
			if(type == "qresolution"){
				docu = "Minimum size of a reference block in bp.";
			} else if (type == "qgene_search"){
				docu = "Users can search for the locations of a reference gene.";
			} else if (type == "qposition_search"){
				docu = "Users can directly move to the specified region in the reference species, and display syntenic relationship and annotated genes in that region.";
			}
			
			$('body').append("<div id=\"qq"+type+"\" class=\"qQuestion_box\" style=\"position:absolute; top:"+mouseY+"px; left:"+mouseX+"px;\">"
			+ "<b>"+docu+"</b>"
			+ "</div>"
			);
		} else {
			$('.qQuestion_box').remove();
		}
	}
	
	function makeBrowser_img(){
		var html = d3.select("svg")
			.attr("version", 1.1)
			.attr("xmlns", "http://www.w3.org/2000/svg")
			.node().parentNode.innerHTML;
		var svg_code = html;
		var prj = $('#publish_select option:selected').val();
		var save_svg = 'saveSVG.php', d = {'prj':prj,'svg':svg_code,'type':'SynBrowser'};
		$.ajaxSetup({async: false});
		$.post(save_svg,d,function(){});
		$.ajaxSetup({async: true});
		svgDownload_browser();
	}
	
	function svgDownload_browser(){
		var fmt = $('#b_img_fmt option:selected').val();
		var prj = $('#publish_select option:selected').val();
		var imgsrc = '../data/'+prj+'/browser/image/SynBrowser.'+fmt;
			if(UrlExists(imgsrc)){
				$('#downloadLink').prop('href', imgsrc);
				$('#downloadLink').prop('download', 'SynBrowser.'+fmt);
				$('#downloadLink')[0].click();
			}
	}
	
	function gene_list(data){
		var arr_id_list = data.id_convert;
		$.each(arr_id_list,function(key) {
			var wiki_gene = arr_id_list[key].gene_name;
			arr_gene_name.push(wiki_gene);
		});
		arr_gene_name = arr_gene_name.sort();
	}
	
	function autoComplete(){
		$("#sy_search_text").autocomplete({
			source: arr_gene_name,
			minLength: 2,
			matchContains: true
		}).data( "uiAutocomplete" )._renderItem = function( ul, item ) {
			var term = this.element.val(),
            regex = new RegExp( '(' + term + ')', 'gi' );
			t = item.label.replace( regex , "<b style=\"color:blue\">$&</b>" );
			return $( "<li></li>" ).data("item.autocomplete", item)
			.append( "<a style='height:30px;'><div style='width: 100%; float: left;overflow: hidden; white-space:nowrap; text-overflow: ellipsis; text-align: left;'>" + t + "</div></a>")
			.appendTo( ul );
		}
	}
	
	function gene_search(){
		var searched_term = document.getElementById("sy_search_text").value;
		var wiki_gene = "";
		var wiki_chr = "";
		$.each(json_gene_info,function(key){
			var item = json_gene_info[key];
			$.each(item,function(key2){
				var item2 = item[key2];
				if($.isArray(item2)){
					for(var i = 0; i < item2.length; i++){
						if (item2[i].toLowerCase() === searched_term.toLowerCase()){
							wiki_gene = item.gene_name;
							wiki_chr = item.chr;
						}
					}						
				} else {
					if (item2.toLowerCase() === searched_term.toLowerCase()){
						wiki_gene = item.gene_name;
						wiki_chr = item.chr;
					}
				}
			});
		});

		if (wiki_gene == ""){
			alert("Gene is not found in our database");
		} else {
			sessionStorage.setItem("gene",wiki_gene);
			sessionStorage.setItem("searched_term",searched_term);
			reload_function(wiki_chr, "geneSearch");
		}
	}
	
	$(function () {
		if(geneTrack_flag == 0){return;}
		if (typeof hash_ref_target[selected_asmbl] !== 'undefined'){
			if (sessionStorage.getItem("start") !== null && sessionStorage.getItem("end") !== null){
				var visStart = sessionStorage.getItem("start");
				var visEnd = sessionStorage.getItem("end");
				draw_gene_trackP(selected_asmbl,visStart,visEnd);
				sessionStorage.removeItem("start");
				sessionStorage.removeItem("end");
			}
			
			if (sessionStorage.getItem("gene") !== null && sessionStorage.getItem("searched_term") !== null){
				var gene = sessionStorage.getItem("gene");
				var searched_term = sessionStorage.getItem("searched_term");
				visual_gene(gene,searched_term);
				sessionStorage.removeItem("gene");
				sessionStorage.removeItem("searched_term");
			}
		}
		
		var prj = $('#publish_select option:selected').val();
		$.ajax({
			url: '../data/'+prj+'/browser/'+ref+'.id.json',
			dataType: "json",
			success: function (data) {
				json_gene_info = data.id_convert;
				gene_list(data);
			}
		});
		
		$("#sy_search_text").keypress(function(event){
			if (event.keyCode == '13'){
				event.preventdefault();
			} else {				
				autoComplete();
			}
		});
	});
