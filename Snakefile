"""
Author: Karel Estrada
Affiliation: UUSMB (Unidad Universitaria de Secuenciación Masiva y Bioinformática)
Aim: PATT: Proteome Annotation Transfer Tools (A Snakemake workflow)
usage: snakemake --cores <core_numbers> --rerun-incomplete --config PROTREF="protein.faa" GENOME="genome.fasta" PREFIX="prefix_outputfilename" NEWPREFIX="prefix_newgenenames_" -s path/to/Snakefile_PATT
Latest modification: Fri 20 Jan 2023 09:38:23 AM CST
version: 1.0
"""

# variables that PATT needs:
# GENOME= "genome.fasta" # Fasta file of genome that we want to annotate. Default: "genome.fasta"
# PROTREF= "protein.faa" # Fasta file of the reference proteins that we want to transfer or annotate in our genome. PATT can take it from STDIN. Default: "protein.faa"
# PREFIX= "prefix" # Output file prefix. Default: "mySpecies"
# NEWPREFIX= "prefix_" # Prefix name we want for the proteins/transcripts in the our genome. We suggest ending in "_" for aesthetics. Default: "{PREFIX}_"
# OLDPREFIX= "prefix" # Prefix that the proteins have in the faa to be transferred. Perl regular expressions are accepted ex: "^\S+gene[^_|\s]+". PATT generates new names of the transferred proteins keeping all(default) or a part of the original annotated protein identifier. Default: "=gene". ex: if the names of the proteins to be transferred have this form "tsol_\d+", my variable can be OLDPREFIX= "=genetsol_" and the new names will be "mySpecies_\d+"

# ex:
#PROTREF= "GCF_000002545.3_ASM254v2_protein_sinmito.faa"
#GENOME= "ICN001_fil.fasta"
#PREFIX= "ICN001"
#NEWPREFIX= "ICN001_"

PATTTEMP= "patttemp"
PARALLEL= "parallel.txt"

if "GENOME" not in config.keys():
    GENOME = "Inside"
else:
    GENOME = config["GENOME"]
if GENOME== "Inside":
    GENOME = "genome.fasta"

if "PROTREF" not in config.keys():
    PROTREF = "Inside"
else:
    PROTREF = config["PROTREF"]
if PROTREF== "Inside":
    PROTREF = "protein.faa"

if "PREFIX" not in config.keys():
    PREFIX = "Inside"
else:
    PREFIX = config["PREFIX"]
if PREFIX== "Inside":
    PREFIX = "mySpecies"

if "NEWPREFIX" not in config.keys():
    NEWPREFIX = "Inside"
else:
    NEWPREFIX = config["NEWPREFIX"]
if NEWPREFIX== "Inside":
    NEWPREFIX = expand("{prefix}_", prefix=PREFIX)

if "OLDPREFIX" not in config.keys():
    OLDPREFIX = "Inside"
else:
    OLDPREFIX = config["OLDPREFIX"]
if OLDPREFIX== "Inside":
    OLDPREFIX = "=gene"

rule all:
    input:
        expand("{prefix}.faa", prefix=PREFIX),
        {PATTTEMP}

rule tmpWD:
    output:
        #temp(directory({PATTTEMP}))
        directory({PATTTEMP}) # keep temp files
    shell:
        """
        mkdir {output[0]}
        cp {PROTREF} {GENOME} {output[0]}
        """

rule splitfasta:
    input:
        rules.tmpWD.output
    output:
        temp("splitfasta")
    threads:
        workflow.cores * 1
    message:
        "splitting protein fasta.."
    shell:
        """
        cd {PATTTEMP}
        patt_parte_fasta_enpartes_indicadas.pl {PROTREF} {threads}
        cd ..
        touch {output}
        """

rule exthomol:
    input:
        rules.splitfasta.output
    output:
        temp("p2g")
    threads:
        workflow.cores * 1
    message:
        "running p2g.."
    params:
        parts= (workflow.cores * 1) -1
    shell:
        """
        cd {PATTTEMP}
        for i in `seq 0 {params.parts}`; do echo $i>> {PARALLEL}; done
        cat parallel.txt | parallel patt_ext_homol.pl {PROTREF}.{{}} {GENOME}
        cd ..
        touch {output}
        """

rule mergingGFF:
    input:
        rules.exthomol.output
    output:
        temp("all.gff")
    threads:
        1
    message:
        "merging GFF from p2g.."
    shell:
        """
        cd {PATTTEMP}
        patt_gff_from_p2g.pl
        cat *.gff > all; rm -f *.gff; mv all {output}
        cd ..
        touch {output}
        """

rule individualGFF:
    input:
        rules.mergingGFF.output
    output:
        temp("all_1.gff")
    threads:
        1
    message:
        "extracting individual GFFs.."
    shell:
        """
        cd {PATTTEMP}
        patt_gff_extindiv_from_p2g_2.pl all.gff > {output}
        cd ..
        touch {output}
        """

rule formatGFF:
    input:
        rules.individualGFF.output
    output:
        temp("all_2.gff")
    threads:
        1
    message:
        "making GFF format compatible.."
    shell:
        """
        cd {PATTTEMP}
        patt_fix_children_gff_for_artemis_karel.pl all_1.gff > {output}
        cd ..
        touch {output}
        """

rule fixingcoords:
    input:
        rules.formatGFF.output
    output:
        temp("all_2_fixcoords.gff")
    threads:
        1
    message:
        "fixing GFF genes coords.."
    shell:
        """
        cd {PATTTEMP}
        patt_gff_fix_coords.pl all_2.gff > {output}
        cd ..
        touch {output}
        """

rule sortingGFF:
    input:
        rules.fixingcoords.output
    output:
        temp("all_2_fixcoords_sorted.gff")
    threads:
        1
    message:
        "sorting GFF genes coords.."
    shell:
        """
        cd {PATTTEMP}
        patt_gff_fix_coords_sort.pl all_2_fixcoords.gff > {output}
        cd ..
        touch {output}
        """

rule updatePrefix:
    input:
        rules.sortingGFF.output
    output:
        expand("{prefix}.gff", prefix=PREFIX)
    threads:
        1
    message:
        "formating GFF to new prefix.."
    shell:
        """
        cd {PATTTEMP}
        perl -pi -e 's/ID{OLDPREFIX}/ID={NEWPREFIX}/g' {input}
        perl -pi -e 's/Parent{OLDPREFIX}/Parent={NEWPREFIX}/g' {input}
        perl -pi -e 's/exonerate:p2g/PATT/g' {input}
        mv {input} {output}
        cp {output} ../
        rm -f all*.gff
        cd ..
        touch {output}
        """

rule GFF2GBK:
    input:
        rules.updatePrefix.output
    output:
        expand("{prefix}.gbk", prefix=PREFIX)
    threads:
        1
    message:
        "creating genbank format (GBK).."
    shell:
        """
        cd {PATTTEMP}
        patt_gff2gbSmallDNA.pl {input} {GENOME} 0 --overlap {output} > /dev/null 2>&1
        cp {output} ../
        cd ..
        touch {output}
        """

rule CDSandProtein:
    input:
        rules.GFF2GBK.output
    output:
        expand("{prefix}.ffn", prefix=PREFIX),
        expand("{prefix}.faa", prefix=PREFIX)
    threads:
        1
    message:
        "creating CDs and Proteins fasta files.."
    shell:
        """
        cd {PATTTEMP}
        java run -format=8 -inform=2 -feat=CDS {input} -o {output[0]} 2>/dev/null
        perl -pi -e 's/^\>.*gene="([^"]+).*$/>\\1/' {output[0]}
        patt_code2aa_ws.pl {output[0]} > {output[1]}
        cp {output[0]} {output[1]} ../
        cd ..
        """
