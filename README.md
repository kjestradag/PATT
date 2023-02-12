<div align="center">
  <h1>PATT</h1>
  <h1>${{\color{red}P}roteome\ {\color{red}A}nnotation\ {\color{red}T}ransfer\ {\color{red}T}ool}$</h1>
</div>
<div align="justify">
Proteome Annotation Transfer Tool (PATT) is a powerful and versatile software tool for transferring annotations from a reference genome to an unannotated query genome. Developed using the Snakemake workflow management system, PATT provides a streamlined and efficient approach to annotating new genomes, enabling researchers to rapidly and accurately annotate large-scale genomic data sets.

With its intuitive user interface and robust annotation algorithms, PATT is designed to simplify the process of annotating new genomes, making it accessible to both computational and non-computational biologists. Whether you are working with a large-scale transcriptome data set or a single genome assembly, PATT offers a comprehensive solution for annotating new genomes, streamlining your research process and delivering high-quality results.
</div>

## Dependencies:

> **Snakemake** (https://snakemake.readthedocs.io/en/stable/index.html)

> **Perl** (https://www.perl.org/get.html)

> **AWK**

**Perl Modules**

>  Getopt::Long

>  Parallel::ForkManager

## Installation:

### Option 1

PATT pipeline it is written in Snakemake and Perl. For greater convenience/ease of installing PATT, we use the [Apptainer/Singularity](https://apptainer.org/) container platform and build an image with the complete environment (script and dependencies) needed to run PATT.

You just need to [download](https://figshare.com/ndownloader/files/37939014) the Singularity image **PATT** and have installed "Apptainer/Singularity". If you don't have it installed, you can install it:

**with Conda** 
>  $ conda install -c conda-forge singularity 

Alternatively, x86_64 RPMs are available on GitHub immediately after each Apptainer release and they can be installed directly from there:

**with RPMs**
>  $ sudo yum install -y https://github.com/apptainer/apptainer/releases/download/v1.1.3/apptainer-1.1.3-1.x86_64.rpm

**with DEB**
>  $ wget https://github.com/apptainer/apptainer/releases/download/v1.1.3/apptainer_1.1.3_amd64.deb

>  $ sudo apt-get install -y ./apptainer_1.1.3_amd64.deb

For more details of the Apptainer installation process, go [here](https://apptainer.org/docs/admin/main/installation.html).

**Usage: (Install Option 1)** 
  > PATT <input.fasta> [output_dir]

    the input file should be a metagenome assembly
  
  optional:

    output_dir_name (default: rapdtool_results)
  
  notes:
 
    1- You need to put "PATT" in your path, otherwise you must give the whole path so that it can be found.

    2- The input fasta files must exist in your $HOME, otherwise you need to set the environment variable SINGULARITY_BIND
    to bind paths where your sequences are located
    ex: export SINGULARITY_BIND="../path/for/the/inputs/fasta"

### Option 2

Make sure you have all **dependencies** installed.
You also need to download and have in your path **all the "bin" scripts**.

A simple way to get some of the dependencies ready is through the conda and pypi package managers:

>  $ conda install -c bioconda focus metabat2 binning_refiner mash prodigal hmmer krona 

>  $ pip install micomplete

Also, you can check [Prodigal](https://github.com/hyattpd/Prodigal/wiki/installation), [HMMR](http://hmmer.org/documentation.html), or [Krona](https://github.com/marbl/Krona/wiki/Installing) on their site for more details of these.

Once the databases have been downloaded, you need to **create a folder rapdtool_DBs** (we suggest that it be within the path of the rest of the dependencies) and set the environment variable rapdtool_DB (export rapdtool_DB="../path/for/the/rapdtool_DBs")

For genome.fasta and protein.faa file name run:
$ snakemake --cores <number of threads> -s /path/of/Snakefile

If genome or protein fastas files have other names, then run:
snakemake --cores <core_numbers> --config PROTREF="current_protein_fasta_filename" GENOME="current_genome_fasta_filename"

More options:

$ snakemake --cores <core_numbers> --rerun-incomplete --config PROTREF="protein.faa" GENOME="genome.fasta" PREFIX="prefix_outputfilename" NEWPREFIX="prefix_newgenenames_" -s path/of/Snakefile_PATT

About variables that PATT needs:
  
  GENOME= "genome.fasta" # Fasta file of genome that we want to annotate. Default: "genome.fasta"
  
  PROTREF= "protein.faa" # Fasta file of the reference proteins that we want to transfer or annotate in our genome. Default: "protein.faa"
  
  PREFIX= "prefix" # Output file prefix. Default: "mySpecies"
  
  NEWPREFIX= "prefix_" # Prefix name we want for the proteins/transcripts in the our genome. We suggest ending in "_" for aesthetics. Default: "{PREFIX}_"
  
  OLDPREFIX= "prefix" # Prefix that the proteins have in the faa to be transferred. Perl regular expressions are accepted ex: "^\S+gene[^_|\s]+". PATT generates new names of the transferred proteins keeping all(default) or a part of the original annotated protein identifier. Default: "=gene". ex: if the names of the proteins to be transferred have this form "tsol_\d+", my variable can be OLDPREFIX= "=genetsol_" and the new names will be "mySpecies_\d+"

## Output directories and files

The output of RaPDTool produces 4 directories and 3 main files:

![rapdtool_output](https://user-images.githubusercontent.com/43998702/197233431-b97a7c1e-a94e-4b4d-812a-df6bc9305b54.png)

### Directory "log"

Contains the log file of the RaPDTool execution (logfmbm.txt).

**fmbm** is a kind of acronym that includes the main operations of the pipeline (Focus/Metabat/Binning_refiner/Mash).

***

## What about the results?

### File "rapdtools_confidence.txt"

<p align="justify">
Summarizes the best/most reliable **Mash** hits to be able to classify at the genus or species level. For the genus level it is considered a cut-off value <= 0.08 and <= 0.05 for species level.
Additionally it contains the results of the taxonomic classification with Focus, leaving only the species with a relative abundance greater than 1.
</p>

**rapdtools_confidence.tbl** contains the same data but with a prettier aesthetic

![rapdtool_result](https://user-images.githubusercontent.com/43998702/197008164-ab28e5b6-e79f-435c-a2c8-84ae590ce1a1.png)

### File "rapdtool_krona.html"

## Acknowledgments

PATT would not have been possible without my fellow researchers at the UUSMB (Unidad Universitaria de Secuenciación Masiva y Bioinformática), in particular, Jerome Verleyen and Alejandro Sanchez, they helped me with ideas and challenges during PATT's development.

PATT uses **Snakemake** (https://snakemake.readthedocs.io/en/stable/index.html) for pipeline development, **Exonerate** to perform alignments and **Readseq** (https://currentprotocols.onlinelibrary.wiley.com/doi/full/10.1002/0471250953.bia01es00) and Mario Stanke script to format manipulations.
