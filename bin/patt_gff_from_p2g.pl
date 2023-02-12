#!/usr/bin/env perl
use strict;

my $print= 0;
my $line;
while(<*.protein2genome>){
    chomp;
    (my $name= $_)=~s/(.*)\.protein2genome/$1/;
    open OUT, ">$name.gff" or die "can't write in $name.gff";
    open IN, $_ or die "Cant read $_\n";
    my $genelength;
    while(<IN>){
        next if /^\S+\s+\S+\s+similarity/ or /^\S+\s+\S+\s+splice/ ;
        if( /^\s+Target range: (\d+) -> (\d+)/ ){
        	$genelength= abs($2-$1);
        }
        next if (defined $genelength && $genelength > 80000); # no cachar los genes mayores a 80kb (posible error de p2g)
        if( /^##gff-version/ ){
            $print++;
            for(my $i=1; $i< 8; $i++){
                $line= <IN>;
            }
            next
        }
        if( $print ){
            if( /^# --- END OF GFF/ ){
                $print= 0;
                last
            }
            if( /^(.*)gene_id 0(.*sequence (\S+).*)/ ){
                print OUT "# model gene_$3\n$1gene_id $3$2\n";
            }else{
                print OUT;
            }
        }
    }
    print OUT "//\n";
    close OUT;
}
