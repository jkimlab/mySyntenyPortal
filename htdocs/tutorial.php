<?php	include './topbar.php';	?>
<link href = "css/font/css/font-awesome.min.css" rel="stylesheet" >

<style>
	div{
		display: block;
	}
	.well{
		margin-bottom: 3px;
	}	
	.gif{
		width:100%;
	}
	 
	.list{
	/*	margin: 20px; */
		cursor:pointer;
	}
	.noshow{
		display:none;
	}
	table td{
		text-align: left;
	}
	.arrow{
		width:50px;
	}
	table tr{
		cursor:pointer;
	}
	.highlight{
		font-weight: bold;
	}
	.selected{
		color:red;
	}
	.header{
		cursor: default;
	}
	.well{
		padding-left:70px;
		padding-right:70px;
	}
	.example_box{
		background-color: white; 
		padding:10px;margin-top:10px;
	}
</style>
<script>
	var tab = "&nbsp;&nbsp;&nbsp;&nbsp;";
</script>
<body id="tutorial-body">
	<div style="padding-top:10px">
		<div style="margin: 10 0 10 0">
			<ul class="nav nav-tabs">
				<li role="presentation" class="list active highlight" id="project"><a href="#">Website management</a></li>
				<li role="presentation" class="list" id="syncircos"><a href="#">SynCircos</a></li>
				<li role="presentation" class="list" id="synbrowser"><a href="#">SynBrowser</a></li>
			</ul>	
		</div>

		<div id="project_div" class="tutorial_box">
			<div style="padding:10px; margin: 10 0 10 0"><center>
				<h2 style="color:steelblue"><strong>Website management</strong></h2>
				<hr/>	
			</center></div>				
			<table class="table table-hover">
				<tr class="header"><th>1. Constructing/Removing a website (by using a command line interface)</th><td style="width:50px;"></td></tr>
				<tr class="header"><td><script>document.write(tab);</script>(1) Preparing configuration files</td><td style="width:50px;"></td></tr>
				<tr class="header"><td><script>document.write(tab+tab);</script>(1-1) With assemblies</td><td style="width:50px;"></td></tr>
				<tr id="24"><td><script>document.write(tab+tab+tab);</script>(1-1-1) Preparing a configuraion file</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif24"><td colspan=2><div class="well">
					<p># Website name (Required)</p>
					<div class="example_box">
						>Website_name<br/>
						Example<br/>
					</div><br/>
					<p># Input assemblies (Required)</p>
					### Path list for files in FASTA format<br/>
					<div class="example_box">
						> Assemblies<br/>
						Human ../data/example_inputs/human.fa<br/>
						Mouse ../data/example_inputs/mouse.fa<br/>
						Cow ../data/example_inputs/cow.fa<br/>
					</div><br/>
					<p># Divergence times (Required)</p>
					### Example) Human-chimpanzee: near, Human-mouse: medium, Human-chicken: far<br/>
					<div class="example_box">
						> Divtimes<br/>
						Human,Mouse	medium<br/>
						Human,Cow	medium<br/>
						Mouse,Cow	medium<br/>
					</div><br/>
					<p># Resolutions (Required)</p>
					### The minimum size of synteny blocks in base pair<br/>
					<div class="example_box">
						> Resolutions
						150000,300000,400000,500000<br/>
					</div><br/>
					<p># Gene annotations of reference (Optional)</p>
					### Path list of files in Gene transfer format(GTF)<br/>
					<div class="example_box">
						>Annotation<br/>
						Human	../data/example_inputs/Homo_sapiens.GRCh38.87.gtf.gz<br/>
						Mouse	../data/example_inputs/Mus_musculus.GRCm38.87.gtf.gz<br/>
					</div><br/>
					<p>#Cytogenetic bands (Optional)</p>
					<div class="example_box">
						> Cytoband<br/>
						Human	../data/example_inputs/Human.cytoband<br/>
						Mouse	../data/example_inputs/mouse.cytoband<br/>
						Cow	../data/example_inputs/mouse.cytoband<br/>
					</div><br/>
					<p># Pre-built circos plots (Optional)</p>
					### If user wants to visualize all chromosomes/scaffolds, user should write 'all' instead of specific chromosomes.<br/>
					<div class="example_box">
						> Circos1<br/>
						resolution:150000<br/>
						Human:chr1,chr3,chr5,chr6,chr8,chr12,chr15,chr19<br/>
						Mouse:chr1,chr3,chr7,chr17,chr18<br/>
						Cow:chr3,chr9,chr10,chr14,chr17,chr22<br/><br/>
					</div><br/>
					<p># Email address (Optional)</p>
					### It is used to make a contact link in published website.<br/>
					<div class="example_box">
						> Email<br/>
						User@email.com<br/>
					</div>
				</div></td></tr>
				<tr id="25"><td><script>document.write(tab+tab+tab);</script>(1-1-2) Required input data & formats</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif25"><td colspan=2><div class="well">
				<p># FASTA format <a target="_blank" href="https://en.wikipedia.org/wiki/FASTA_format"><i class="fa fa-question-circle" aria-hidden="true"></i></a></p>
				<div class="example_box">
					>1<br/>
					TTATTCCGCATCTTCTGAAGAAGATGTTCCGAATATATCCTTAGAAAGGA<br/>
					GGTGATCCAGCCGCACCTTCCGATACGGCTACCTTGTTACGACTTCACCC<br/>
				</div><br/>
				<p># GTF format <a target="_blank" href="https://en.wikipedia.org/wiki/Gene_transfer_format"><i class="fa fa-question-circle" aria-hidden="true"></i></a></p>
				<div class="example_box">
					1       havana  gene    11869   14409   .       +       .       gene_id "ENSG00000223972"; gene_version "5"; gene_name "DDX11L1"; gene_source "havana"; gene_biotype "transcribed_unprocessed_pseudogene"; 
					havana_gene "OTTHUMG00000000961"; havana_gene_version "2";<br/>
					1       havana  transcript      11869   14409   .       +       .       gene_id "ENSG00000223972"; gene_version "5"; transcript_id "ENST00000456328"; transcript_version "2"; gene_name "DDX11L1"; gene_source "havana"; 
					gene_biotype "transcribed_unprocessed_pseudogene"; havana_gene "OTTHUMG00000000961"; havana_gene_version "2"; transcript_name "DDX11L1-002"; transcript_source "havana"; transcript_biotype "processed_transcript"; havana_transcript "OTTHUMT00000362751"; havana_transcript_version "1"; tag "basic"; transcript_support_level "1";<br/>
				</div><br/>
				<p># Cytoband format <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTables?db=hg38&hgta_group=map&hgta_track=cytoBand&hgta_table=cytoBand&hgta_doSchema=describe+table+schema"><i class="fa fa-question-circle" aria-hidden="true"></i></a></p>
				<div class="example_box">
					chr1	0	2300000	p36.33	gneg<br/>
					chr1	2300000	5400000	p36.32	gpos25<br/>
					chr1	5400000	7200000	p36.31	gneg<br/>
				</div><br/>
				</div></td></tr>
				<tr class="header"><td><script>document.write(tab+tab);</script>(1-2) With synteny blocks</td><td style="width:50px;"></td></tr>
				<tr id="27"><td><script>document.write(tab+tab+tab);</script>(1-2-1) Preparing a configuraion file</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif27"><td colspan=2><div class="well">
					<p># Website name (Required)</p>
					<div style="background-color: white; padding:10px;margin-top:10px">
						> Website_name<br/>
						Example<br/>
					</div><br/>
					<p># Input synteny blocks (Required)</p>
					### Path list of files in synteny format<br/>
					<div style="background-color: white; padding:10px;margin-top:10px">
						> Synteny_blocks <br/>
						Human,Mouse ../data/example_inputs/human.mouse.synteny<br/>
						Human,Cow   ../data/example_inputs/human.cow.synteny<br/>
					</div><br/>
					<p># Genome size files (Required)</p>
					### Path list of files in genome size format<br/>
					<div style="background-color: white; padding:10px;margin-top:10px">
						> Genome_size<br/>
						Human	../data/example_inputs/human.sizes<br/>
						Mouse	../data/example_inputs/mouse.sizes<br/>
						Cow	../data/example_inputs/cow.sizes<br/>
					</div><br/>
					<p># Gene annotations of reference (Optional)</p>
					### Path list of files in Gene transfer format(GTF)<br/>
					<div style="background-color: white; padding:10px;margin-top:10px">
						> Annotation<br/>
						Human	../data/example_inputs/Homo_sapiens.GRCh38.87.gtf.gz<br/>
						Mouse	../data/example_inputs/Mus_musculus.GRCm38.87.gtf.gz<br/>
					</div><br/>
					<p># Cytogenetic bands (Optional)</p>
					<div style="background-color: white; padding:10px;margin-top:10px">
						> Cytoband<br/>
						Human	../data/example_inputs/Human.cytoband<br/>
						Mouse	../data/example_inputs/mouse.cytoband<br/>
						Cow	../data/example_inputs/mouse.cytoband<br/>
					</div><br/>
					<p># Pre-built circos plots (Optional)</p>
					### If user wants to visualize all chromosomes/scaffolds, user should write 'all' instead of specific chromosomes.<br/>
					<div style="background-color: white; padding:10px;margin-top:10px">
						> Circos1<br/>
						resolution:150000<br/>
						Human:chr1,chr3,chr5,chr6,chr8,chr12,chr15,chr19<br/>
						Mouse:chr1,chr3,chr7,chr17,chr18<br/>
						Cow:chr3,chr9,chr10,chr14,chr17,chr22<br/>
					</div><br/>
					<p># Email address (Optional)</p>
					###It is used to make a contact link in published website.</br>
					<div style="background-color: white; padding:10px;margin-top:10px">
						> Email<br/>
						User@email.com<br/>
					</div>
				</div></td></tr>
				<tr id="28"><td><script>document.write(tab+tab+tab);</script>(1-2-2) Required input data & formats</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif28"><td colspan=2><div class="well">
				<p># Synteny format</p>
				One line starting with a '>' sign, followd by the synteny number<br>
				The other two lines containing the coordinates and the orientation in each scaffold of pairwise alignment<br/>
				(First line is only for reference chromosome(scaffold)<br/><br/>
				<div style="background-color: white; padding:10px;margin-top:10px">
					>1<br/>
					Human.chr1:933237-58547094 +<br/>
					Mouse.chr4:103313481-156255944 -<br/><br>
					>2<br/>
					Human.chr1:58654678-67136459 +<br/>
					Mouse.chr4:94941999-103299247 +
				</div><br/>
				<p># Genome size format</p>
				First column containing chromosome(scaffold) name and second column containing chromosome(scaffold) size <br/><br/>
				How to make?<br/>
				[mySyntenyPortal_root]/src/third_party/kent/faSize -detailed [FASTA] > [size file]<br/><br/>
				<div style="background-color: white; padding:10px;margin-top:10px">
					chr1  249250621<br/>
					chr2  243199373
				</div><br/>
				<p>GTF format <a target="_blank" href="https://en.wikipedia.org/wiki/Gene_transfer_format"><i class="fa fa-question-circle" aria-hidden="true"></i></a></p>
				<div style="background-color: white; padding:10px;margin-top:10px">
					1       havana  gene    11869   14409   .       +       .       gene_id "ENSG00000223972"; gene_version "5"; gene_name "DDX11L1"; gene_source "havana"; gene_biotype "transcribed_unprocessed_pseudogene"; 
					havana_gene "OTTHUMG00000000961"; havana_gene_version "2";<br/>
					1       havana  transcript      11869   14409   .       +       .       gene_id "ENSG00000223972"; gene_version "5"; transcript_id "ENST00000456328"; transcript_version "2"; gene_name "DDX11L1"; gene_source "havana"; 
					gene_biotype "transcribed_unprocessed_pseudogene"; havana_gene "OTTHUMG00000000961"; havana_gene_version "2"; transcript_name "DDX11L1-002"; transcript_source "havana"; transcript_biotype "processed_transcript"; havana_transcript "OTTHUMT00000362751"; havana_transcript_version "1"; tag "basic"; transcript_support_level "1";<br/>
				</div><br/>
				<p>Cytoband format <a target="_blank" href="http://genome.ucsc.edu/cgi-bin/hgTables?db=hg38&hgta_group=map&hgta_track=cytoBand&hgta_table=cytoBand&hgta_doSchema=describe+table+schema"><i class="fa fa-question-circle" aria-hidden="true"></i></a></p>
				<div style="background-color: white; padding:10px;margin-top:10px">
					chr1	0	2300000	p36.33	gneg<br/>
					chr1	2300000	5400000	p36.32	gpos25<br/>
					chr1	5400000	7200000	p36.31	gneg<br/>
				</div><br/>
				</div>
				</td></tr>						
				<tr class="header"><td><script>document.write(tab);</script>(2) Command lines</td><td style="width:50px;"></td></tr>
				<tr id="29"><td><script>document.write(tab+tab);</script>(2-1) Building website</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif29"><td colspan=2><div class="well">
					User can use the 'mySyntenyPortal' perl script to build website.<br/><br/>
					Command: <br/>
					<script>document.write(tab+tab+tab);</script>./mySyntenyPortal build &lt;parameters&gt;<br/><br/>
					Parameter:<br/>
					<script>document.write(tab+tab+tab);</script>-conf|c<script>document.write(tab+tab+tab);</script>=> Configuration file<br/>
					<script>document.write(tab+tab+tab);</script>-core|p<script>document.write(tab+tab+tab);</script>=> Number of threads (default: 10)<br/><br/>
					Example:<br/>
					<div class="example_box"><script>document.write(tab+tab+tab);</script>./mySyntenyPortal build -p 10 -conf ./configurations/sample.conf<br/></div>
				</div></td></tr>
				<tr id="30"><td><script>document.write(tab+tab);</script>(2-2) Removing website</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif30"><td colspan=2><div class="well">
					User can use the 'mySyntenyPortal' perl script to remove website.<br/><br/>
					Command: <br/>				
					<script>document.write(tab+tab+tab);</script>./mySyntenyPortal remove &lt;parameters&gt;<br/><br/>
					Parameter:<br/>
					<script>document.write(tab+tab+tab);</script>-website_name|w<script>document.write(tab+tab+tab);</script>=> Website name<br/>
					<script>document.write(tab+tab+tab);</script>-conf|c<script>document.write(tab+tab+tab);</script>=> Configuration file<br/><br/>
					Example:<br/>
					<div class="example_box"><script>document.write(tab+tab+tab);</script>./mySyntenyPortal remove -website_name Sample_website<br/></div>
				</div></td></tr>					
			</table>
			<br/>
			<table class="table table-hover">
				<tr class="header"><th>2. Publishing/Unpublishing a website (by using a web interface)</th><td style="width:50px"></td></tr>
				<tr id="31"><td><script>document.write(tab);</script>(1) Drawing default plots</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif31"><td colspan=2>
					<p><script>document.write(tab+tab+tab);</script> This step is to draw plots which are used as default plots in the pubilshed website.</p>
					<p><center>< SynCircos ></center></p><img class="gif" src="img/tutorial_img/Website_2_1_1.gif"><br/>
					<p><center>< SynBrowser ></center></p><img class="gif" src="img/tutorial_img/Website_2_1_2.gif">					
				</td></tr>
				<tr id="32"><td><script>document.write(tab);</script>(2) Publishing a website</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif32"><td colspan=2><img class="gif" src="img/tutorial_img/Website_2_2.gif"></td></tr>
				<tr id="33"><td><script>document.write(tab);</script>(3) An example of a pubilshed website</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif33"><td colspan=2><img class="gif" src="img/tutorial_img/Website_2_3.gif"></td></tr>
				<tr id="34"><td><script>document.write(tab);</script>(4) Published website information</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif34"><td colspan=2><center>&lt;Before publishing&gt;</center>
				<img class="gif" src="img/tutorial_img/Website_2_4.jpg">
				<center>&lt;After publishing&gt;</center>
				<img class="gif" src="img/tutorial_img/Website.a_2_4.jpg">
				</td></tr>
				<tr id="35"><td><script>document.write(tab);</script>(5) Unpublishing a selected website</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif35"><td colspan=2><img class="gif" src="img/tutorial_img/Website_3_1.gif"></td></tr>	
			</table>
		</div>
		
		<!--<span class="target" id="10"></span>-->
		<div id="syncircos_div" class="tutorial_box noshow">
			<div style="padding:10px; margin: 10 0 10 0"><center>
				<h2 style="color:steelblue"><strong>SynCircos</strong></h2>
				SynCircos draws the interactive Circos plot by using selected species and chormosomes.</br>
				<hr/>			
			</center></div>
			<table class="table table-hover">
				<tr><th>1. Drawing a plot</th><td style="width:50px"></td></tr>
				<tr id="1"><td><script>document.write(tab);</script>(1) Selecting a reference species and chromosomes (or scaffolds)</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif1"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_1.gif"></td></tr>
				<tr id="2"><td><script>document.write(tab);</script>(2) Selecing a target species and chromosomes (or scaffolds)</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif2"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_2.gif"></td></tr>
				<tr id="3"><td><script>document.write(tab+tab);</script>(2-1) Adding a target species</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif3"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_2_1.gif"></td></tr>
				<tr id="4"><td><script>document.write(tab+tab);</script>(2-2) Removing a target species</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif4"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_2_2.gif"></td></tr>
				<tr id="5"><td><script>document.write(tab);</script>(3) Selecting a resolution of synteny blocks (Only assemblies input)</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif5"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_3.gif"></td></tr>
				<tr id="6"><td><script>document.write(tab);</script>(4) Clicking 'Submit' button to draw the Circos plot</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif6"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_4.gif"></td></tr>
				<tr id="7"><td><script>document.write(tab);</script>(5) An example of the Circos plot</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif7"><td colspan=2><img class="gif" src="img/tutorial_img/SynCircos_1_5.gif"></td></tr>
			</table>
			<br/>
			<table class="table table-hover">
				<tr><th>2. Downloading a plot</th><td style="width:50px"></td></tr>
				<tr id="8"><td><script>document.write(tab);</script>(1) Selecting an image format.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif8"><td colspan=2><img class="gif" id ="gif8" src="img/tutorial_img/SynCircos_2_1.gif"></td></tr>
				<tr id="9"><td><script>document.write(tab);</script>(2) Clicking on 'Download' button.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif9"><td colspan=2><img class="gif" id ="gif9" src="img/tutorial_img/SynCircos_2_2.gif"></td></tr>
			</table>
		</div>
		
		<div id="synbrowser_div" class="tutorial_box noshow">
			<div style="padding:10px; margin: 10 0 10 0">
				<center><h2 style="color:steelblue"><strong>SynBrowser</strong></h2>
				SynBrowser shows synthenic relationships between two chosen species with annotated genes of a reference species.<br/>
				User can easily navigate the reference chromosomes by using coordinates or genes.<br/>
				<hr/>
				</center>
			</div>
			<table class="table table-hover">
				<tr><th>1. Drawing a plot</th><td style="width:50px"></td></tr>
				<tr id="10"><td><script>document.write(tab);</script>(1) Selecting a reference species and a chromosome.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif10"><td colspan=2><img class="gif" id ="gif10" src="img/tutorial_img/Synbrowser_1_1.gif"></td></tr>
				<tr id="11"><td><script>document.write(tab);</script>(2) Selecting a target species.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif11"><td colspan=2><img class="gif" id ="gif11" src="img/tutorial_img/Synbrowser_1_2.gif"></td></tr>
				<tr id="12"><td><script>document.write(tab);</script>(3) Selecting a resolution of synteny blocks. (Only assemblies input)</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif12"><td colspan=2><img class="gif" id ="gif12" src="img/tutorial_img/Synbrowser_1_3.gif"></td></tr>
				<tr id="13"><td><script>document.write(tab);</script>(4) Clicking 'Submit' button to draw a plot showing pairwise synthenic information.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif13"><td colspan=2><img class="gif" id ="gif13" src="img/tutorial_img/Synbrowser_1_4.gif"></td></tr>
			</table>
			<br/>
			<table class="table table-hover">
				<tr><th>2. Downloading a plot</th><td style="width:50px"></td></tr>
				<tr id="14"><td><script>document.write(tab);</script>(1) Selecting an image format.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif14"><td colspan=2><img class="gif" id ="gif14" src="img/tutorial_img/Synbrowser_2_1.gif"></td></tr>
			 	<tr id="15"><td><script>document.write(tab);</script>(2) Clicking on 'Download' button.</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif15"><td colspan=2><img class="gif" id ="gif15"  src="img/tutorial_img/Synbrowser_2_2.gif"></td></tr>
			</table>
			<br/>
			<table class="table table-hover">
				<tr><th>3. Browsing the details of synteny blocks</th><td style="width:50px"></td></tr>
				<tr id="16"><td><script>document.write(tab);</script>(1) Obtaining information about synteny blocks</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif16"><td colspan=2><img class="gif" id ="gif16" src="img/tutorial_img/Synbrowser_3_1.gif"></td></tr>
				<tr id="17"><td><script>document.write(tab);</script>(2) Browsing gene annotation</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif17"><td colspan=2><img class="gif" id ="gif17" src="img/tutorial_img/Synbrowser_3_2.gif"></td></tr>
				<tr id="18"><td><script>document.write(tab);</script>(3) Obtaining gene information</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif18"><td colspan=2><img class="gif" id ="gif18" src="img/tutorial_img/Synbrowser_3_3.gif"></td></tr>
			</table>
			<br/>
			<table class="table table-hover">			
				<tr><th>4. Searching for a specific position in synteny blocks</th><td style="width:50px"></td></tr>
				<tr id="19"><td><script>document.write(tab);</script>(1) Selecting a reference chromosome</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif19"><td colspan=2><img class="gif" id ="gif19"  src="img/tutorial_img/Synbrowser_4_1.gif"></td></tr>
				<tr id="20"><td><script>document.write(tab);</script>(2) Searching by using a query gene</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif20"><td colspan=2><img class="gif" id ="gif20"  src="img/tutorial_img/Synbrowser_4_2.gif"></td></tr>
				<tr id="21"><td><script>document.write(tab);</script>(3) Searching by using a coordinate of synteny blocks</td><td class="arrow" style="vertical-align: middle;">
				<i class="fa fa-angle-double-down" aria-hidden="true"></i></td></tr>
				<tr class="noshow" id="gif21"><td colspan=2><img class="gif" id="gif21"  src="img/tutorial_img/Synbrowser_4_3.gif"></td></tr>
			</table>
		</div>	
	</div>
<script>
	$('.list').click(function(){
		var id = this.id;
		$.map($('.list'),function(ele){
			$(ele).removeClass('highlight');
			$(ele).removeClass('active');
		});
		$(this).addClass('highlight');
		$(this).addClass('active');
		
		$.map($('.tutorial_box'),function(ele){
			$(ele).removeClass('noshow');
			$(ele).addClass('noshow');
		});
		$('#'+id+'_div').removeClass('noshow');
	});
	
	$('tr').click(function(){
		var id = $(this).attr('id');
		$('#gif'+id).toggle();
		if($(this).find($('.arrow')).hasClass('selected')){
			$(this).find($('.arrow')).removeClass('selected');
			$(this).find($('.arrow')).html('<i class="fa fa-angle-double-down" aria-hidden="true"></i>');
		}else{
			$(this).find($('.arrow')).addClass('selected');
			$(this).find($('.arrow')).html('<i class="fa fa-angle-up" aria-hidden="true"></i>');
		}
	});
</script>
<?php include './footer.php';?>			
