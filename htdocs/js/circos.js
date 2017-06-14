$(document).ready(function(){
	$('#ref_circos').change(function(){
		sessionStorage.clear();
		var rn = $('#ref_circos option:selected').attr("id");
		var prj = $('#publish_select option:selected').val();
		window.location="syncircos.php?PRJ="+prj+"&REF="+rn;
	});
	
	$('#ref_chr_available').change(function(){
		var values = $('#ref_chr_available').val();
		document.getElementById('ref_textArea').value = "";
		for (var i=0; i < values.length; i++){
			var v = values[i];
			var reg = /^chr/;
			if(reg.test(v)){
				v = v.substring(3);
			}
			
			if(i == 0){
				document.getElementById('ref_textArea').value += v;
			} else {
				document.getElementById('ref_textArea').value += ","+v;
			}
		}
	});
});

function chrSelectAll(id, type)
{
	var s = document.getElementById(id+"_chr_available");
	for(var i=0; i < s.options.length; i++){
		s.options[i].selected = type;
	}
	
	var values = $('#'+id+"_chr_available").val();

	document.getElementById(id+"_textArea").value = "";
	if(!values){return;}
	for (var i=0; i < values.length; i++)
	{
		var v = values[i];
		var reg = /^chr/;
		if(reg.test(v)){
			v = v.substring(3);
		}
		
		if(i == 0){
			document.getElementById(id+"_textArea").value += v;
		} else {
			document.getElementById(id+"_textArea").value += ","+v;
		}
	}
}

function chrSelect(id, spc_chr){
	var values = spc_chr;
	values = values.replace(/chr/g,"");
	document.getElementById(id+'_textArea').value = values;
}

function tarAdd(){
	var project = "";
	var ref_name = "";
	var tar_name = "";
	var tar_chr = "";
	if(arguments.length == 4){
		project = arguments[0];
		ref_name = arguments[1];
		tar_name = arguments[2];
		tar_chr = arguments[3];
	} else {
		project = arguments[0];
		ref_name = arguments[1];
	}
	
	var tar_num = 1;
	var last_tar_id = "";
	var selected_tars = "";
	while(1){
		last_tar_id = 'tar'+tar_num+'_div';
		if($('#'+last_tar_id).length == 0){break;}
		tar_num++;
	}
	
	var vis_tar_num = "";
	if(tar_num < 10){
		vis_tar_num = "0"+tar_num;
	} else {
		vis_tar_num = tar_num;
	}
	
	$('#Species').append("<div id=\""+last_tar_id+"\" style=\"margin-top:5px;margin-left:-17px;line-height:5px;\">"
	+ "<img id=\"tar_minus\" align=\"top\" width=\"25px\" style=\"cursor:pointer;margin-left:0px;margin-top:0px;\" src=\"./img/minus.png\" onclick=\"tarDel('"+project+"',"+tar_num+")\"/>"
	+ "Target "+vis_tar_num
	+ "<select id=\"target_"+tar_num+"\" class=\"tar_menu\" style=\"margin-left:4px;\"></select>\n"
	+ "<input type=\"button\" class=\"msp_btn\" value=\"Chrs/Scafs >>\" style=\"margin-left:2px;margin-top:0px;\" id=\"tar"+tar_num+"_chr\" onClick=\"refChrClick(this.id);\"/>\n"
	+ "<textarea id=\"tar"+tar_num+"_textArea\" style=\"margin-left:2px;\"></textarea>\n"
	+ "</div>"
	+ "<div id=\"tar"+tar_num+"_chr_div\" style=\"width:1000px; height:160px; margin-top:10px;\" hidden>"
	+ "<select id=\"tar"+tar_num+"_chr_available\" class=\"tar_available_chr\" multiple size=\"10\" style=\"float:left; margin-left:480px; width:160px; height:150px;\"></select>"
	+ "<div id=\"tar"+tar_num+"_chr_select_button\" style=\"width:39px; float:right; margin-right:310px; margin-top:0px;\">"
	+ "<input type=\"button\" class=\"msp_btn\" value=\"Close\" style=\"margin-bottom:50px;margin-top:5px;\" onclick=\"CloseChr('tar"+tar_num+"');\"/>"
	+ "<input type=\"button\" class=\"msp_btn\" value=\"Select all\"  onclick=\"chrSelectAll('tar"+tar_num+"', true);\"/>"
	+ "<input type=\"button\" class=\"msp_btn\" value=\"Unselect all\" style=\"margin-top:5px;\" onclick=\"chrSelectAll('tar"+tar_num+"', false);\"/>"
	+ "</div>"
	+ "</div>"
	);

	$.ajaxSetup({async: false});
	var getTar = 'c_getTarInfo.php', data = {'prj':project,'ref':ref_name, 'tar':tar_name};
	$.post(getTar,data, function(response){
		$('#target_'+tar_num).html(response);
	});
	
	if(tar_name == ""){tar_name = $('#tar'+tar_num+'_div option:selected').attr("id");}
	var getTarChr = 'c_getTarChr.php', data2 = {'prj':project,'tar':tar_name};
	$.post(getTarChr, data2, function(response3){
		$("#tar"+tar_num+"_chr_available").html(response3);
		if(tar_chr == "all" || tar_chr == ""){
			chrSelectAll("tar"+tar_num, true);
		} else {
			chrSelect("tar"+tar_num, tar_chr);
		}
	});
	
	$('#target_'+tar_num).on('change',function(){
		changed_tar_name = $('#tar'+tar_num+'_div option:selected').attr("id");
		var getTarChr = 'c_getTarChr.php', data2 = {'prj':project, 'tar':changed_tar_name};
		$.post(getTarChr, data2, function(response3){
			$("#tar"+tar_num+"_chr_available").html(response3);
			chrSelectAll("tar"+tar_num,true);
		});
	});
	
	$('#tar'+tar_num+'_chr_available').on('change',function(){
		var values = $('#tar'+tar_num+'_chr_available').val();
		document.getElementById('tar'+tar_num+'_textArea').value = "";
		for (var i=0; i < values.length; i++)
		{
			var v = values[i];
			var reg = /^chr/;
			if(reg.test(v)){
				v = v.substring(3);
			}
			if(i == 0){
				document.getElementById('tar'+tar_num+'_textArea').value += v;
			} else {
				document.getElementById('tar'+tar_num+'_textArea').value += ","+v;
			}
		}
	});
}

function tarDel(project,tar_num)
{
	$('#tar'+tar_num+'_div').remove();
	$('#tar'+tar_num+"_chr_div").remove();
	
	var tn = $('.tar_menu').length;
	for(var i=tar_num+1;i<=tn+1;i++)
	{
		var j = i-1;
		var selected_chrs = $('#tar'+i+'_textArea').val();
		var selected_tar = $('#target_'+i).val();
		
		$('#tar'+i+'_div').attr("id","tar"+j+"_div");
		$('#target_'+i).attr("id","target_"+j);
		$('#tar'+i+"_chr").attr("id","tar"+j+"_chr");
		$('#tar'+i+"_textArea").attr("id","tar"+j+"_textArea");
		$('#tar'+i+"_chr_div").attr("id","tar"+j+"_chr_div");
		$('#tar'+i+"_chr_available").attr("id","tar"+j+"_chr_available");
		$('#tar'+i+"_chr_select_button").attr("id","tar"+j+"_chr_select_button");
		
		var html1 = $('#tar'+j+'_div').html();
		html1 = html1.replace("tarDel('"+project+"',"+i+")","tarDel('"+project+"',"+j+")");
		if(i < 10){
			html1 = html1.replace('Target 0'+i,'Target 0'+j);
		}
		else if(i == 10){
			html1 = html1.replace('Target '+i,'Target 0'+j);
		}
		else{
			html1 = html1.replace('Target '+i,'Target '+j);
		}
		$('#tar'+j+'_div').html(html1);
		var html3 = $('#tar'+j+"_chr_select_button").html();
		html3 = html3.replace("'tar"+i+"'","'tar"+j+"'");
		html3 = html3.replace("'tar"+i+"'","'tar"+j+"'");
		html3 = html3.replace("'tar"+i+"'","'tar"+j+"'");
		$('#tar'+j+"_chr_select_button").html(html3);
		$('#tar'+j+'_textArea').val(selected_chrs);
		$("#target_"+j+" option[value='"+selected_tar+"']").prop('selected', true);

		$('#target_'+j).unbind();
		$('#tar'+j+'_chr_available').unbind();
		
		var ctar_num = 0;
		$('#target_'+j).change(function(){
			var tar_id = $(this).val();
			var parent_id = $(this).parent().attr("id");
			var sep = /tar|_div/;
			var idsplit = parent_id.split(sep);
			ctar_num = idsplit[1];
			var tar_name = $('#tar'+j+'_div option:selected').attr("id");
			console.log(tar_name);
			var getTarChr = 'c_getTarChr.php', data2 = {'prj':project, 'tar':tar_name};
			$.post(getTarChr, data2, function(response3){
				$("#tar"+ctar_num+"_chr_available").html(response3);
				chrSelectAll("tar"+ctar_num,true);
			});
		});
		
		$('#tar'+j+'_chr_available').change(function(){
			var values = $(this).val();
			var parent_id = $(this).parent().attr("id");
			var sep = /tar|_chr_div/;
			var idsplit = parent_id.split(sep);
			ctar_num = idsplit[1];
			document.getElementById('tar'+ctar_num+'_textArea').value = "";
			if(!values){return;}
			for (var i=0; i < values.length; i++){
				var v = values[i];
				var reg = /^chr/;
				if(reg.test(v)){
					v = v.substring(3);
				}
				if(i == 0){
					document.getElementById('tar'+tar_num+'_textArea').value += v;
				} else {
					document.getElementById('tar'+tar_num+'_textArea').value += ","+v;
				}
			}
		});
	}
}

function tarDel_bottom()
{
	var tar_num = 1;
	var last_tar_id = "";
	while(1)
	{
		last_tar_id = 'tar'+tar_num+'_div';
		if($('#'+last_tar_id).length == 0)
		{
			tar_num--;
			last_tar_id = 'tar'+tar_num+'_div';
			break;
		}
		tar_num++;
	}
	
	
	$('#tar'+tar_num+"_del_button").remove();
	$('#'+last_tar_id).remove();
	$('#tar'+tar_num+"_chr_div").remove();
}

function Get_img(project,rn,circos_num)
{
	var tn = $('.tar_menu').length;
	
	if(tn == 0){
		alert("Please, select one or more target species.");
		return;
	}
	$('#ref_chr_div').hide();
	var ref_txt = $('#ref_textArea').val();
	var ref_user_chr = ref_txt.replace(/ /g,'');
	ref_user_chr = ref_user_chr.replace(/,$/,'');
	var ref_chr_arr = ref_user_chr.split(",");
	ref_chr_arr = ArrayUnique(ref_chr_arr);
	ref_user_chr = ref_chr_arr.join();
	$('#ref_textArea').val(ref_user_chr);
	
	var resolution = $("#resolution").val();
	
	var cinfo = resolution+"|"+rn+"|"+ref_user_chr;

	//Targets
	if(typeof(resolution) == 'undefined'){resolution = 0;}
	for(var i = 1;i <= tn;i++){
		$('#tar'+i+'_chr_div').hide();
		var t = $('#target_'+i+' option:selected').val();
		var tid = $('#tar'+i+'_assembly option:selected').val();
		var tname = $('#target_'+i+' option:selected').attr("id");	
		var t_txt = $('#tar'+i+'_textArea').val();
		var t_user_chr = t_txt.replace(/ /g,'');
		t_user_chr = t_txt.replace(/,$/,'');
		var t_chr_arr = t_user_chr.split(",");
		t_chr_arr = ArrayUnique(t_chr_arr);
		t_user_chr = t_chr_arr.join();
		$('#tar'+i+'_textArea').val(t_user_chr);
		cinfo += "|"+tname+"|"+t_user_chr;
	}
	
////////Debuging: Chr
	var ref_options = $('#ref_chr_available option');
	var ref_chr = $.map(ref_options ,function(option) {
		return option.value;
	});
	
	var error_flag = 0;
	var error_message = "";
	for(var i=0; i < ref_chr_arr.length; i++){
		if(ref_chr.indexOf("chr"+ref_chr_arr[i]) == -1 && ref_chr.indexOf(ref_chr_arr[i]) == -1){
			if(error_flag == 0){
				error_message = "ERROR - Invalid chromosome numbers were given!\n\nReference chromosome(s) - "+ref_chr_arr[i];
				error_flag = 1;
			} else {
				error_message += ", "+ref_chr_arr[i];
				error_flag = 1;
			}
		}
	}
	
	for(var i = 1;i <= tn;i++){
		var t_txt = $('#tar'+i+'_textArea').val();
		var t_chr_arr = t_txt.split(",");
		var t_options = $('#tar'+i+'_chr_available option');
		var t_chr = $.map(t_options ,function(option) {
			return option.value;
		});
		var tar_id = $('#target_'+i+' option:selected').val();
		var sub_error = "";
		t_user_chr = "";
		for(var ii=0; ii < t_chr_arr.length; ii++){
			if(t_chr.indexOf("chr"+t_chr_arr[ii]) == -1 && t_chr.indexOf(t_chr_arr[ii]) == -1){
				if(error_flag == 0){
					sub_error = "ERROR - Invalid chromosome numbers were given!\n\nTarget "+i+" chromosome(s) - "+t_chr_arr[ii];
					error_flag = 1;
				} else {
					if(sub_error == "") {
						sub_error += "\nTarget "+i+" chromosome(s) - "+t_chr_arr[ii];
					} else {
						sub_error += ", "+t_chr_arr[ii];
					}
				}
			}

			if(ii == (t_chr_arr.length-1)){
				error_message += sub_error;
			}
			
		}
	}
	
	if(error_flag == 1)
	{
		alert(error_message);
		return;
	}
////////////// Debug end
	$.ajaxSetup({async: false});
	$('#div_result').toggle();
	$('#loading').toggle();
	$('#ref_chr_div').hide();
	var writeRefInfo = 'writeCircosInfo.php', d = {'prj':project,'circos_info':cinfo,'cir_num':circos_num};
		$.post(writeRefInfo,d,function(response){
			if(response == 0){
				$.ajaxSetup({async: true});
				var writeCircosIndex = 'writeCircosIndex.php', d2 = {'prj':project,'circos_info':cinfo,'cir_num':circos_num};
				$.post(writeCircosIndex,d2,function(){});
				var drawCircos = 'drawCircos.php',d3 = {'prj':project,'ref':rn,'cir_num':circos_num};
				$.post(drawCircos,d3,function(response){
					$.ajaxSetup({async: false});
					var CurState = 'writeCurState.php',d4 = {'prj':project,'cir_num':circos_num};
					$.post(CurState,d4,function(response2){});
					window.location='syncircos.php?PRJ='+project;
				});
			} else {
				var CurState = 'writeCurState.php',d4 = {'prj':project,'cir_num':response};
				$.post(CurState,d4,function(response2){});
				window.location='syncircos.php?PRJ='+project;
			}
		});
	
}

function CloseChr(id)
{
	$('#'+id+'_chr_div').toggle();
}


function makeCircos_img(circos_num){
	var html = d3.select("svg")
		.attr("version", 1.1)
		.attr("xmlns", "http://www.w3.org/2000/svg")
		.node().parentNode.innerHTML;
	var svg_code = html;
	var prj = $('#publish_select option:selected').val();
	var save_svg = 'saveSVG.php', d = {'prj':prj,'svg':svg_code,'circos_num':circos_num,'type':'SynCircos'};
	$.ajaxSetup({async: false});
	$.post(save_svg,d,function(){});
	$.ajaxSetup({async: true});
	svgDownload(circos_num);
}
	
function svgDownload(circos_num){
	var fmt = $('#img_fmt option:selected').val();
	var prj = $('#publish_select option:selected').val();
	var imgsrc = '../data/'+prj+'/circos/circos'+circos_num+'/SynCircos.'+fmt;
		if(UrlExists(imgsrc)){
			$('#downloadLink').prop('href', imgsrc);
			$('#downloadLink').prop('download', 'SynCircos.'+fmt);
			$('#downloadLink')[0].click();
		}
}

function refChrClick(id)
{
	$('#'+id+'_div').toggle();
}

function setResolution(res)
{
	document.getElementById("resolution").value = res;
}

function mouseOver(id)
{
	if(transform_state == 0){
		d3.selectAll("path")
			.style("opacity",0.1);
		
		d3.selectAll("#"+id)
			.style("opacity",1);
	}
}

function mouseOut()
{
	if(transform_state == 0){
		d3.selectAll("path")
			.style("opacity",1);
		
		d3.selectAll(".transforms_path")
			.style("opacity",0.5);
	}
}

function mouseClick (id)
{
	if(transform_state == 0){
		d3.selectAll("path")
			.style("opacity",0.1);
	
		d3.selectAll("#"+id)
			.style("opacity",1);
		transform_state = 1;
	} else {
		d3.selectAll("path")
		.style("opacity",1);
	
		d3.selectAll(".transforms_path")
		.style("opacity",0.5);
		transform_state = 0;
	}
	
}


function question_box_on(type, event)
{
	if($('#qq'+type).length == 0){
		var e = event||window.event;
		var mouseX = e.pageX + 20;
		var mouseY = e.pageY - 50;
		var docu = "";
		
		if(type == "qresolution"){
			docu = "Minimum size of a reference block in bp.";
		}

		$('body').append("<div id=\"q"+type+"\" class=\"Question_box\" style=\"position:absolute; top:"+mouseY+"px; left:"+mouseX+"px;\">"
		+ "<b>"+docu+"</b>"
		+ "</div>"
		);
	}
}

function question_box_off(type)
{
	$('.Question_box').remove();
}

function question_box_click(type, event)
{
	$('.Question_box').remove();
	
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
		
		$('body').append("<div id=\"qq"+type+"\" class=\"qQuestion_box\" style=\"position:absolute; top:"+mouseY+"px; left:"+mouseX+"px;\">"
		+ "<b>"+docu+"</b>"
		+ "</div>"
		);
	}
	else
	{
		$('.qQuestion_box').remove();
	}
}

function ArrayUnique(array) {
	var result = [];
	$.each(array, function(index, element) {
		if ($.inArray(element, result) == -1) {
			result.push(element);
		}
	});
	return result;
}
