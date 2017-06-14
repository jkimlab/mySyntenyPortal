<html>
<head>
	<meta charset="UTF-8">
	<title> mySyntenyPortal </title>
	<link rel="stylesheet" href="http://code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
	<link rel="icon" href="img/favicon.ico" type="image/x-icon" />
	<script src="js/jquery-1.12.0.min.js"> </script>
	<script src="//code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
	<script type="text/javascript" src="js/d3.min.js"></script>
	<script type="text/javascript" src="js/msp.js"></script>
	<link href="css/bootstrap.css" rel="stylesheet">
	<script type="text/javascript" src="js/bootstrap.js"></script>
	<link href="css/msp.css" rel="stylesheet">
</head>

<nav class="navbar navbar-inverse navbar-fixed-top" style="position:fixed; height:50px; top:0; left:0; right:0;">		
	<div class="navigation" style="width:1050px; margin:auto; display:block;">
		<div class="navbar-header" id="menu">
			<a class="navbar-brand" id="main-nav" href="main.php" style="font-weight:bold">mySyntenyPortal</a>
			<ul class="nav navbar-nav" style="overflow:auto;margin: 0 0 0 0;"> 
				<li style="float:left;margin-left:50px;"> <a class="navbar-brand" id="syncircos-nav" href="syncircos.php"> SynCircos </a> </li>
				<li style="float:left;margin-left:50px;"> <a class="navbar-brand" id="synbrowser-nav" href="synbrowser.php"> SynBrowser </a> </li>
				<li style="float:left;margin-left:50px;"> <a class="navbar-brand" id="tutorial-nav" href="tutorial.php"> Tutorial </a> </li>
			</ul>
		</div>
			<select id="publish_select" class="publish_group" style="width:150px;margin-top:12px;margin-left:40px;"></select>
			<input type="button" id="publish_data" class="publish_group msp_publish_btn" value="Publish" style="height:30px;margin-left:2px;"/>
			<input type="button" id="delete_data" class="publish_group msp_delete_btn" value="Unpublish" style="height:30px;margin-left:2px;"/>
	</div>
</nav>
