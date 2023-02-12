#!/usr/bin/perl -w
use strict;

my ($name, %seq);

my $file_to_open= shift; # recibe el  gff2CDS.fna
open IN, $file_to_open or die "Cant read $file_to_open\n";
while(<IN>){
	chomp;
    if( /^>(\S+)/ ){
        $name= $1; next
    }
    $seq{$name}.= $_;
}

my %aacode = ( 'TTT', "F", 'TTC', "F", 'TTA', "L", 'TTG', "L", 'TCT', "S", 'TCC', "S", 'TCA', "S", 'TCG', "S", 'TAT', "Y", 'TAC', "Y", 'TAA', "*", 'TAG', "*", 'TGT', "C", 'TGC', "C", 'TGA', "*", 'TGG', "W", 'CTT', "L", 'CTC', "L", 'CTA', "L", 'CTG', "L", 'CCT', "P", 'CCC', "P", 'CCA', "P", 'CCG', "P", 'CAT', "H", 'CAC', "H", 'CAA', "Q", 'CAG', "Q", 'CGT', "R", 'CGC', "R", 'CGA', "R", 'CGG', "R", 'ATT', "I", 'ATC', "I", 'ATA', "I", 'ATG', "M", 'ACT', "T", 'ACC', "T", 'ACA', "T", 'ACG', "T", 'AAT', "N", 'AAC', "N", 'AAA', "K", 'AAG', "K", 'AGT', "S", 'AGC', "S", 'AGA', "R", 'AGG', "R", 'GTT', "V", 'GTC', "V", 'GTA', "V", 'GTG', "V", 'GCT', "A", 'GCC', "A", 'GCA', "A", 'GCG', "A", 'GAT', "D", 'GAC', "D", 'GAA', "E", 'GAG', "E", 'GGT', "G", 'GGC', "G", 'GGA', "G", 'GGG', "G" );

foreach my $orf  ( sort keys %seq ){
    print ">$orf\n";
    my @aa = map { $aacode{$_} ? $aacode{$_} : "X" } unpack '(A3)*', uc $seq{$orf};
    print join '', @aa, "\n";
}



########
#~ Para mitocondria de Project_ICastano_2022_11_07_14_24_04 donde:
#~ CTT Thr (no Leu)
#~ CTA Thr (no Leu)

#~ ATA Met (no Ile)

#~ TGA Trp (no stop codon)

#~ my ($name, %seq);
########

#~ my $file_to_open= shift; # recibe el  gff2CDS.fna
#~ open IN, $file_to_open or die "Cant read $file_to_open\n";
#~ while(<IN>){
	#~ chomp;
    #~ if( /^>(\S+)/ ){
        #~ $name= $1; next
    #~ }
    #~ $seq{$name}.= $_;
#~ }

#~ my %aacode = ( 'TTT', "F", 'TTC', "F", 'TTA', "L", 'TTG', "L", 'TCT', "S", 'TCC', "S", 'TCA', "S", 'TCG', "S", 'TAT', "Y", 'TAC', "Y", 'TAA', "*", 'TAG', "*", 'TGT', "C", 'TGC', "C", 'TGA', "W", 'TGG', "W", 'CTT', "T", 'CTC', "L", 'CTA', "T", 'CTG', "L", 'CCT', "P", 'CCC', "P", 'CCA', "P", 'CCG', "P", 'CAT', "H", 'CAC', "H", 'CAA', "Q", 'CAG', "Q", 'CGT', "R", 'CGC', "R", 'CGA', "R", 'CGG', "R", 'ATT', "I", 'ATC', "I", 'ATA', "M", 'ATG', "M", 'ACT', "T", 'ACC', "T", 'ACA', "T", 'ACG', "T", 'AAT', "N", 'AAC', "N", 'AAA', "K", 'AAG', "K", 'AGT', "S", 'AGC', "S", 'AGA', "R", 'AGG', "R", 'GTT', "V", 'GTC', "V", 'GTA', "V", 'GTG', "V", 'GCT', "A", 'GCC', "A", 'GCA', "A", 'GCG', "A", 'GAT', "D", 'GAC', "D", 'GAA', "E", 'GAG', "E", 'GGT', "G", 'GGC', "G", 'GGA', "G", 'GGG', "G" );

#~ foreach my $orf  ( sort keys %seq ){
    #~ print ">$orf\n";
    #~ my @aa = map { $aacode{$_} ? $aacode{$_} : "X" } unpack '(A3)*', uc $seq{$orf};
    #~ print join '', @aa, "\n";
#~ }
