$(document).ready(function(){
	$('#reset_data').click(function(){
		if(confirm("Do you want to go back to initial state?") == true){
			var prj = $('#publish_select option:selected').val();
			var body_id = $('body').attr('id');
			$.ajaxSetup({async: false});
			var reset = 'reset.php',d = {'page':body_id};
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
