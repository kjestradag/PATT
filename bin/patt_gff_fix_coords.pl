#!/usr/bin/env perl
use strict;

my $gff= shift;

open IN, $gff or die "Cant read $gff\n";
while(<IN>){
    chomp;
    if( /^(\S+)\.0\.(\d+)\-(\d+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+)(.*)/ ){
        print "$1\t$4\t$5\t",$2+$6,"\t",$2+$7,"$8\n";
    }

}
