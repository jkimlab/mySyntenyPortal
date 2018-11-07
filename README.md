
mySyntenyPortal 
====================
A stand-alone application for constructing websites for visualizing and browsing synteny blocks

Quick start
-------------------
    git clone https://github.com/jkimlab/mySyntenyPortal.git
    cd mySyntenyPortal
    perl ./install.pl build
    sudo perl ./install.pl install
    perl ./mySyntenyPortal build -conf ./configurations/sample.conf

System requirements
-------------------
* Linux x64
* Apache >= 2.2.15 
* zlib >= 1.2.8
* ImageMagick >= 6.7.x
* Perl >= 5.8.x or new
* Perl modules
 
 To list all required perl modules, use the command below.

    perl ./src/check_modules.pl


Download source
-------------------

    git clone https://github.com/jkimlab/mySyntenyPortal.git


Installing mySyntenyPortal
-------------------
To install mySyntenyPortal, use the 'install.pl' perl script.

    Usage:  ./install.pl [build|install|clean] <parameters>
  
     ** It requires a 'sudo' privilege for the 'install' command. **

    Simple examples:
        ./install.pl build
        ./install.pl install
        ./install.pl clean

    Commands:
        build    =>  complile third party tools and set path information
        install  =>  make a symbolic link in the web root directory
        clean    =>  clean up third party tools and remove the symbolic link in the web root directory

    Parameters:
      [ install ]
        -webroot_path|w => Apache web root path (default: /var/www/html)
        -manager_name|m => Website manager name (default: mySyntenyPortal)
      
      [ clean ]
        -manager_name|m => Website manager name (default: mySyntenyPortal)

* Examples

    You can compile mySyntenyPortal and set your own path information by one command below.
    
        ./install.pl build
    
    To access web interfaces, mySyntenyPortal makes a symbolic link in the web root directory.
    
        sudo ./install.pl install
        sudo ./install.pl install -webroot_path [Webroot directory path]
        sudo ./install.pl install -manager_name [Website manager name]
       
    To clean up mySyntenyPortal, use a command below.
    
        sudo ./install.pl clean -manager_name [Website manager name]

When mySyntenyPortal is successfully installed, you can access the website manager
* Default
   
        http://your.host/mySyntenyPortal

* In case of setting the custom website manager name
   
        http://your.host/[Website manager name]


Building or removing a website
-------------------
To build or remove a website, you need to write a configuration file.
Then, you can use the 'mySyntenyPortal' perl script.

    Usage:  ./mySyntenyPortal [build|remove] <parameters>

      ** It may require a 'sudo' privilege. **

    Simple examples:
        ./mySyntenyPortal build -p 10 -conf ./configurations/sample.conf
        ./mySyntenyPortal remove -website_name Sample_website

    Commands:
        build              => build a website
        remove             => remove a website

    Parameters:
      [ build ]
        -conf|c            => Configuration file
        -core|p            => Number of threads (default: 10)

      [ remove ]
        -website_name|w    => Website name
        -conf|c            => Configuration file


* Examples
    
    To build a website
    
        ./mySyntenyPortal build -conf [configuration file]

    To remove a website

        ./mySyntenyPortal remove -website_name [Website name]

* Configuration file

You can build a website by using two types of input data which are assembly sequences or synteny block definitions.

- With assembly sequences
        
            # Website name (REQUIRED)
            >Website_name
            Example

            # Input Assemblies (REQUIRED)
            # FASTA format (https://en.wikipedia.org/wiki/FASTA_format)
            >Assemblies
            Human   ../data/example_inputs/human.fa
            Mouse   ../data/example_inputs/mouse.fa
            Cow ../data/example_input/cow.fa

            # Divergence times (REQUIRED)
            # Example) Human-chimpanzee: near, Human-mouse: medium, Human-chicken: far
            >Divtimes
            Human,Mouse medium
            Human,Cow   medium
            Mouse,Cow   medium

            # Resolutions (REQUIRED)
            # The minimum size of synteny blocks in base pair
            >Resolutions
            150000,300000,400000,500000

            # Gene annotations of references (OPTIONAL)
            # Gene transfer format (GTF) (https://en.wikipedia.org/wiki/Gene_transfer_format)
            >Annotation
            Human   ../data/example_inputs/Homo_sapiens.GRCh38.87.gtf.gz
            Mouse   ../data/example_inputs/Mus_musculus.GRCm38.87.gtf.gz

            # Cytogenetic bands (OPTIONAL)
            # Column 1: Chromosome
            # Column 2: Start position
            # Column 3: End position
            # Column 4: Name of cytogenetic band
            # Column 5: Giemsa stain results
            # Refer to the sample files '[mySyntenyPortal_root]/data/example_input/Human.cytoband'
            >Cytoband
            Human   ../data/example_inputs/Human.cytoband
            Mouse   ../data/example_inputs/Mouse.cytoband
            Cow ../data/example_inputs/Cow.cytoband

            # Pre-built circos plots (OPTIONAL)
            # If you want to visualize all chromosomes/scaffolds, you can write 'all' instead of specific chromosomes
            >circos1
            resolution:150000
            Human:chr1,chr3,chr5,chr6,chr8,chr12,chr15,chr19
            Mouse:chr1,chr3,chr7,chr17,chr18
            Cow:chr3,chr9,chr10,chr14,chr17,chr22

            # Email address is used to make a contact link in published website. (OPTIONAL)
            >Email
            Your@e-mail.com

- With synteny block definitions

            # Website name (REQUIRED)
            >Website_name
            Example

            # Input synteny blocks (REQUIRED)
            # 
            # Example)
            # 
            # >1
            # Human.chr1:933237-58547094 +
            # Mouse.chr4:103313481-156255944 -
            #
            # >2
            # Human.chr1:58654678-67136459 +
            # Mouse.chr4:94941999-103299247 +
            #
            # Refer to the sample file '[mySyntenyPortal_root]/data/example_input/human.mouse.synteny'
            >Synteny_blocks
            Human,Mouse ../data/example_inputs/human.mouse.synteny
            Human,Cow   ../data/example_inputs/human.cow.synteny

            # Genome size files (REQUIRED)
            #
            # Column1: Chromosome/scaffold_name
            # Column2: Length
            # 
            # Example
            # chr1  249250621
            # chr2  243199373
            # 
            # How to make?
            # [mySyntenyPortal_root]/src/third_party/kent/faSize -detailed [FASTA] > [size file]
            >Genome_size
            Human   ../data/example_inputs/human.sizes
            Mouse   ../data/example_inputs/mouse.sizes
            Cow ../data/example_inputs/cow.sizes

            # Gene annotations of references (OPTIONAL)
            # Gene transfer format (GTF) (https://en.wikipedia.org/wiki/Gene_transfer_format)
            >Annotation
            Human   ../data/example_inputs/Homo_sapiens.GRCh38.87.gtf.gz
            Mouse   ../data/example_inputs/Mus_musculus.GRCm38.87.gtf.gz

            # Cytogenetic bands (OPTIONAL)
            # Column 1: Chromosome
            # Column 2: Start position
            # Column 3: End position
            # Column 4: Name of cytogenetic band
            # Column 5: Giemsa stain results
            # Refer to the sample files '[mySyntenyPortal_root]/data/example_input/Human.cytoband'
            >Cytoband
            Human   ../data/example_inputs/human.cytoband
            Mouse   ../data/example_inputs/mouse.cytoband
            Cow ../data/example_inputs/cow.cytoband

            # Pre-built circos plots (OPTIONAL)
            # If you want to visualize all chromosomes/scaffolds, you can write 'all' instead of specific chromosomes
            >circos1
            Human:chr1,chr3,chr5,chr6,chr8,chr12,chr15,chr19
            Mouse:chr1,chr3,chr7,chr17,chr18
            Cow:chr3,chr9,chr10,chr14,chr17,chr22

            # Email address is used to make a contact link in published website (OPTIONAL)
            >Email
            Your@e-mail.com

- Converting synteny block definitions

       # With synteny block built by Cinteny
            ./scripts/convert_synteny/Cinteny2CS.pl [Input synteny block] [Output synteny block]
            
       # With synteny block built by Satsuma
            ./scripts/convert_synteny/Satsuma2CS.pl [Input synteny block] [Output synteny block]
    
       # With synteny block built by SyntenyTracker
            ./scripts/convert_synteny/SyntenyTracker2CS.pl [Input synteny block] [Output synteny block]           
            

Third party tools
-------------------
* Bedtools (http://bedtools.readthedocs.io/en/latest/)
* KentUtils (http://hgdownload.soe.ucsc.edu/downloads.html#utilities_downloads)
* LASTZ (http://www.bx.psu.edu/~rsharris/lastz/)
* inferCars (http://www.bx.psu.edu/miller_lab/car/)
* Circos (http://circos.ca/)

Contact
-------------------  
bioinfolabkr@gmail.com
