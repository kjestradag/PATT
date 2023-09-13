[![DOI](https://zenodo.org/badge/600843059.svg)](https://zenodo.org/badge/latestdoi/600843059)

<div align="center">
    <h1>${\color{black}PATT:\ {\color{red}P}roteome\ {\color{red}A}nnotation\ {\color{red}T}ransfer\ {\color{red}T}ool}$</h1>
</div>

![pipeline](https://user-images.githubusercontent.com/43998702/218341198-6ab0f54c-c842-43bc-9a05-7c53cf014147.png)

<div align="justify">
Proteome Annotation Transfer Tool (PATT) is a powerful and versatile software tool for transferring annotations from a reference genome to an unannotated query genome. Developed using the Snakemake workflow management system, PATT provides a highly parallelized architecture and efficient approach to annotating new genomes, enabling researchers to rapidly and accurately annotate large-scale genomic data sets.
PATT searches for the best protein ortholog of a close reference in a genome that we want to annotate, generating the best model of it and returning its coding and peptide sequence as well as its coordinates through .gff and .gbk annotation files.
PATT is designed to simplify the process of annotating new genomes, streamlining your research process and delivering high-quality results.
</div>

## Dependencies:

> **Snakemake** (https://snakemake.readthedocs.io/en/stable/index.html)

> **Exonerate** (https://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate) (v.2.4.0)

> **Blat** (https://github.com/djhshih/blat)

> **Perl** (https://www.perl.org/get.html) (v5.30.0)

> **AWK**

> **Java**

> **Parallel** (https://manpages.ubuntu.com/manpages/impish/man1/parallel.1.html)

**Perl Modules**

>  Getopt::Long

>  Getopt::Std

>  Parallel::ForkManager

## Installation:

### Option 1

PATT pipeline it is written in Snakemake and Perl. For greater convenience/ease of installing PATT, we use the [Apptainer/Singularity](https://apptainer.org/) container platform and build an image with the complete environment (script and dependencies) needed to run PATT.

You just need to [download](https://figshare.com/ndownloader/files/37939014) the Singularity image **PATT** and have installed "Apptainer/Singularity". If you don't have it installed, you can install it:

**with Conda** 
>  conda install -c conda-forge singularity 

Alternatively, x86_64 RPMs are available on GitHub immediately after each Apptainer release and they can be installed directly from there:

**with RPMs**
>  sudo yum install -y https://github.com/apptainer/apptainer/releases/download/v1.1.3/apptainer-1.1.3-1.x86_64.rpm

**with DEB**
>  wget https://github.com/apptainer/apptainer/releases/download/v1.1.3/apptainer_1.1.3_amd64.deb

>  sudo apt-get install -y ./apptainer_1.1.3_amd64.deb

For more details of the Apptainer installation process, go [here](https://apptainer.org/docs/admin/main/installation.html).

### Option 2

Make sure you have all **dependencies** installed.
You also need to download and have in your path **all the "bin" scripts**.

To avoid errors with Java, you also need to create a variable with the absolute path of "readseq.jar" which is in the bin folder:
>  export CLASSPATH="/full/path/to/bin/readseq.jar"

You can check [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) on their site for more details of this.

## Quick usage: (Install Option 1)
  > PATT <genome.fasta> <protein.fasta>

  notes:
 
    1- You need to put "PATT" in your path, otherwise you must give the whole path so that it can be found.

    2- The input [fasta](https://en.wikipedia.org/wiki/FASTA_format) files must exist in your $HOME, otherwise you need to set the environment variable SINGULARITY_BIND
    to bind paths where your sequences are located
    ex: export SINGULARITY_BIND="../path/for/the/inputs/fasta"

## Quick usage: (Install Option 2)

For genome.fasta and protein.faa file name run:
  > snakemake --cores <number of threads> -s /path/of/Snakefile

If genome or protein fastas files have other names, then run:
  > snakemake --cores <core_numbers> --config PROTREF="current_protein_fasta_filename" GENOME="current_genome_fasta_filename" -s path/of/Snakefile_PATT

### More options

  > snakemake --cores <core_numbers> --rerun-incomplete --config PROTREF="protein.faa" GENOME="genome.fasta" PREFIX="prefix_outputfilename" NEWPREFIX="prefix_newgenenames_" -s path/of/Snakefile_PATT

  **About variables that PATT optionally needs:**
  
  GENOME= "genome.fasta" # Fasta file of genome that we want to annotate. Default: "genome.fasta"
  
  PROTREF= "protein.faa" # Fasta file of the reference proteins that we want to transfer or annotate in our genome. Default: "protein.faa"
  
  PREFIX= "prefix" # Output file prefix. Default: "mySpecies"
  
  NEWPREFIX= "prefix_" # Prefix name we want for the proteins/transcripts in the our genome. We suggest ending in "_" for aesthetics. Default: "{PREFIX}_"
  
  OLDPREFIX= "prefix" # Prefix that the proteins have in the faa to be transferred. Perl regular expressions are accepted ex: "^\S+gene[^_|\s]+". PATT generates new names of the transferred proteins keeping all(default) or a part of the original annotated protein identifier. Default: "=gene". ex: if the names of the proteins to be transferred have this form "tsol_\d+", my variable can be OLDPREFIX= "=genetsol_" and the new names will be "mySpecies_\d+"

## Output files

The output of PATT produces 4 files:

### File "<prefix>.gff"

Annotation file in [GFF](https://www.ensembl.org/info/website/upload/gff.html#fields) format of the transferred proteins.

### File "<prefix>.gbk"

Annotation file in [GenBank](https://www.ncbi.nlm.nih.gov/Sitemap/samplerecord.html) format of the transferred proteins.
  
### File "<prefix>.ffn"

Fasta file of all coding sequences (CDs).
  
### File "<prefix>.faa"

<p align="justify">
Fasta file of the peptide sequences.
</p>

## Citation
Estrada, K. (2023). PATT (Proteome Annotation Transfer Tool) (Version 1) [Computer software]. https://doi.org/10.5281/zenodo.7958134
  
## Acknowledgments

PATT wouldn't be the same without my fellow researchers at the UUSMB (Unidad Universitaria de Secuenciación Masiva y Bioinformática) Jerome Verleyen and Alejandro Sanchez, who helped me with ideas and challenges during PATT's development.

PATT uses [Snakemake](https://snakemake.readthedocs.io/en/stable/index.html) for pipeline development, [Exonerate](https://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate) to perform alignments, [Readseq](https://currentprotocols.onlinelibrary.wiley.com/doi/full/10.1002/0471250953.bia01es00) for handling file formats, Mario Stanke script "gff2gbSmallDNA.pl" and many lines of code and scripts from my dear friend and god-level programmer, [Alejandro Garciarrubio](https://github.com/agarrubio), I am grateful for his help and guidance.

## Author

  Karel Estrada and yahel

  karel.estrada@ibt.unam.mx

  Twitter: [@kjestradag](https://twitter.com/kjestradag) 
