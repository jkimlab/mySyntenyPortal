<?php include "topbar.php";?>
<script>
$(window).load(function(){
	var InfiniteRotator = {
		init: function(){
			var initialFadeIn = 2000;
			var itemInterval = 5000;
			var fadeTime = 1500;
			var numberOfItems = $('.rotating-item').length;
			var currentItem = 0;
			$('.rotating-item').eq(currentItem).fadeIn(initialFadeIn);
			var infiniteLoop = setInterval(function(){
				$('.rotating-item').eq(currentItem).fadeOut(fadeTime);
				if (currentItem == numberOfItems -1){
					currentItem = 0;
				} else {
					currentItem++;
				}
				$('.rotating-item').eq(currentItem).fadeIn(fadeTime);
			}, itemInterval);
		}
	};
	InfiniteRotator.init();
});

var project_info = new Array;

$(function(){
	$("li.active a").click(function(){
		
		var $parent = $(this).parent();
		if (!$parent.hasClass("active")){
			$parent.addClass("active");
			event.stopImmediatePropagation();
		}
	});
});
</script>
<style>
	.main_display {
		width: 1000px;
		height: 350px;
		margin: auto;
	}
	.main {
		text-align: left;
		text-indent: 50px;
		margin-top: 50px;
	}
	.text {
		margin-top: 125px;
		margin-left: 25px;
		width: 540px;
		z-index: 4;
		text-align: center;
		float: left;
	}
	.image {
		position: absolute;
		float: left;
		margin-left:-570px;
	}
	#fig1 {
		position: absolute;
		height: 330px;
		margin-top: 20px;
		margin-left: 610px;
		z-index: 3;
	}
	#fig2 {
		position: absolute;
		height: 330px;
		margin-top: 15px;
		margin-left: 615px;
		z-index: 2;
	}
	.rotating-item {
		display: none;
	}

	.tab-pane {
		width:850px;
		text-align:left;
		padding:10px;
		font-size:17px;
	}
	
	pre {
		text-align: left;
		overflow-x: auto;
		white-space: nowrap;
	}
</style>
<body id="main-body">

<div class="content" style="width:1000px">
	<div class="main_display">	
		<div class="text">
			<p style="font-size:70px; letter-spacing:-2px; text-align:left; font-weight:600"> mySyntenyPortal </p>
            <p style="font-size:18px; margin-top:-10px"> Web portal for interactive comparative genomics </p>
		</div>
		<div class="image">
			<img class="rotating-item" id="fig1" src="./img/main1.png">
			<img class="rotating-item" id="fig2" src="./img/main2.png">
		</div>
	</div>
	<center>
	<hr style="width:980px; border-color:#ccc; margin:10px 10px 10px 10px">
	
	<script>
	<?php 
		$project_path_info = fopen("./path_info.txt", "r");
		$line_num=0;
		$n=0;
		$projects;

		while ($line = fgets($project_path_info)){
			$line = trim ($line);
			if (strpos($line, ">") !== false){
				$split = explode (">", $line);
				echo "project_info['$split[1]'] = new Array();\n";	
				$projects = $split[1];
				$n=0;
			}
			else {
				if (empty($line)){continue;}
				else {
					$split = explode ("=", $line);
					$split_bar = str_replace("_"," ",$split[0]);
					
					if($n == 2){
						echo "project_info['$projects'][$n] = \"$split_bar: <a style='cursor:pointer' target='_blank' href='../publish/$projects'>$split[1]</a>\"\n";
					} else {
						echo "project_info['$projects'][$n] = \"$split_bar: $split[1]\"\n";
					}
					$n++;
				}
			}
			
		}
?>
</script>
<div class="path_info" style="width:910px;display:inline-block;"></div>
<div class="project_info" style="display:inline-block;font-size:25px;margin-bottom:10px;margin-top:15px;">
<b>Website information</b>
</div>
<script>
	var loop_flag = 0;
	for (var key in project_info) {
		
		var key_id = key.replace(/\s/g,"_");
		$(".path_info").append("<div id='"+key_id+"' style='width:450px;text-align:left;text-indent:5px;padding:0px 10px'>"
		+key.bold()+"</div>");

		for (var key2 in project_info[key]){
			var s = project_info[key][key2].split(':');
				$("#"+key_id).append("<pre>"+s[1]+"</pre>\n");
		}
		delete project_info[key];
		if(loop_flag == 1){break;}
		loop_flag++;
	}
	
	var list_num = 1;
	$(".project_info").append("<ul id='project_list"+list_num+"' class='nav nav-tabs' role='tablist' style='font-size:15px;margin-bottom:10px;'></ul>");
	$(".project_info").append("<div id='tab-content"+list_num+"' class='tab-content'></div>");
	
	var first_li = "";
	for (var key in project_info) {
		if(first_li == ""){first_li = key+"_li";}
		$("#project_list"+list_num+"").append("<li id='"+key+"_li' class='list' role='presentation'><a href='#"+key+"' aria-controls='"+key+"' role='tab' data-toggle='tab'>"+key+"</a></li>");

		var s = "";
		for (var key2 in project_info[key]){
			if(key2 == 3){
				s += project_info[key][key2]+"<br>";
			} else {
				s += project_info[key][key2]+"<br>";
			}
			
		}

		var ul_width = $("#project_list"+list_num+"").outerWidth();
		if(ul_width > 890){
			$("#"+key+"_li").remove();
			list_num++;
			$(".project_info").append("<ul id='project_list"+list_num+"' class='nav nav-tabs' role='tablist' style='font-size:15px;margin-bottom:10px;'></ul>");
			$(".project_info").append("<div id='tab-content"+list_num+"' class='tab-content'></div>");
			$("#project_list"+list_num+"").append("<li id='"+key+"_li' class='list' role='presentation'><a href='#"+key+"' aria-controls='"+key+"' role='tab' data-toggle='tab'>"+key+"</a></li>");
		}
		
		$("#tab-content"+list_num+"").append("<div role='tabpanel' class='tab-pane fade' id='"+key+"'><pre>"+s+"</pre></div>");
	}
	
	$(document).ready(function(){
		if(sessionStorage.getItem('prj') !== null){
			var prj = sessionStorage.getItem('prj');
			$('#'+prj+'_li').find('a').trigger('click');
		} else {
			$('#'+first_li).find('a').trigger('click');
		}
		$(".list").click(function(){
			$('li.active').removeClass("active");
			$('div.active').removeClass("active");
		});

		$(".list").click(function(){
			var id = this.id;
			var sep = /_li/;
			var idsplit = id.split(sep);
			sessionStorage.setItem('prj',idsplit[0]);
		});
	});
</script>
</center>
<?php include "footer.php";?>
