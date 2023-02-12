#!/usr/bin/env perl
use strict;

# sortear los gff por chr y luego por coordenada del gene, manteniendo el orden de los campos..

my (%rel, $chr, $pos);

my $file_to_open= shift;
open IN, $file_to_open or die "Cant read $file_to_open\n";
while(<IN>){
	chomp;
	if( /^((\S+).*\s+gene\s+(\d+).*)$/ ){
		($chr, $pos)= ($2,$3);
		push @{$rel{$chr}{$pos}}, $1;
		next
    }
    push @{$rel{$chr}{$pos}}, $_;
}

foreach my $Chr ( sort keys %rel ){
	foreach my $Pos ( sort {$a<=>$b} keys %{$rel{$Chr}} ){
    	foreach my $line ( @{$rel{$Chr}{$Pos}} ){
        	print "$line\n";
        }

    }

}
