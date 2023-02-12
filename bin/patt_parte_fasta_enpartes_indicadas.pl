#!/usr/bin/env perl
use strict;

my ($file, $parts)=@ARGV;

chomp(my $seqs=`grep -c '^>' $file`);
my $per_part=int($seqs/$parts);

my $file_to_open= $file;
open IN, $file_to_open or die "Cant read $file_to_open\n";

my ($i, $j)=(0, 0);
while(<IN>){
    if( /^>/ ){
        unless($j++ % $per_part){
            open OUT, ">>$file.$i";
            $i++ unless $i==$parts-1;
        }
    }
    print OUT;
}
