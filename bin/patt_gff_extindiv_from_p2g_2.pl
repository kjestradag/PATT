#!/usr/bin/env perl
use strict;

my $id;
my $file_to_open= shift;  # recibe gff

open IN, $file_to_open or die "Cant read $file_to_open\n";
while(<IN>){
    if( /^.*\s+gene_id\s+(\S+)/ ){
	#~ if( /^BdivMO1.*\.(\d+\-\d+)/ ){
        $id= "gene".$1;
        #~ next
    }
    if( /.*\s+cds\s+/ ){
        chomp;
        my @camp= split;
        print "$camp[0]\texonerate:p2g\tCDS\t$camp[3]\t$camp[4]\t$camp[5]\t$camp[6]\t$camp[7]\tID=$id\n";
    }

}
