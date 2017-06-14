$(document).ready(function(){
	$('#publish_select').change(function(){
		sessionStorage.clear();
		var prj = $('#publish_select option:selected').val();
		var body_id = $('body').attr('id');
		if(body_id == "synbrowser-body"){
			window.location="synbrowser.php?PRJ="+prj;
		} else if(body_id == "syncircos-body"){
			window.location="syncircos.php?PRJ="+prj;
		}
	});
	
	$('#publish_data').click(function(){
		if(confirm("Are you sure to publish web pages as current state?") == true){
			$.ajaxSetup({async: false});
			var prj = $('#publish_select option:selected').val();
			var publish = 'publish_website.php',d = {'prj':prj};
			$.post(publish,d,function(response){
				alert(response);
			});
			window.location="main.php";
		} else {
			return;
		}
	});
	
	$('#delete_data').click(function(){
		var prj = $('#publish_select option:selected').val();
		var body_id = $('body').attr('id');
		$.ajaxSetup({async: false});
		if(prompt("Are you sure to unpublish the website ("+prj+") ?\nIf you really want to unpublish the website, enter 'unpublish'.") == 'unpublish'){
			var delete_data = 'delete_website.php',d = {'prj':prj};
			$.post(delete_data,d,function(response){
				alert(response);
			});
			
			window.location="main.php";
		} else {
			return;
		}
	});
	
	$('#reset_data').click(function(){
		if(confirm("Do you want to go back to initial state?") == true){
			var prj = $('#publish_select option:selected').val();
			var body_id = $('body').attr('id');
			$.ajaxSetup({async: false});
			var reset = 'reset.php',d = {'prj':prj,'page':body_id};
			$.post(reset,d,function(response){});
			if(body_id == "synbrowser-body"){
				window.location="synbrowser.php?PRJ="+prj;
			} else if(body_id == "syncircos-body"){
				window.location="syncircos.php?PRJ="+prj;
			}
		}
	});
});

function UrlExists(url){
    var httpp = new XMLHttpRequest();
    httpp.open('HEAD', url, false);
    httpp.send();
    return httpp.status!=404;
}
