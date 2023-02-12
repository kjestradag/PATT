#!/usr/bin/env perl

use strict;

my %cds;
my $prevkey = "";
my $count = 1;
my $file = $ARGV[0];
chomp $file;
my $tags = `awk '{print \$9}' $file | uniq`;
my @order = split (/\n/, $tags);
while (<>) {
        chomp;
        my @line = split (/\s+/, $_);
        my $name = $line[0];
        my $method = $line[1];
        my $tag = $line[2];
        my $start = $line[3];
        my $end = $line[4];
        my $score = $line[5];
        my $strand = $line[6];
        my $key = $line[8];
        ($start, $end) = sort {$a <=> $b} ($start, $end);
        my $newline = "$name\t$method\tCDS\t$start\t$end\t$score\t$strand";
        push (@{$cds{$key}}, $newline);
}


foreach my $again (@order) {
        if ($again =~ /ID=/) {
                my $lastelem = (scalar @{$cds{$again}})-1;
                my $name = (split /\s+/, ${$cds{$again}}[0])[0];
                my $strand = (split /\s+/, ${$cds{$again}}[0])[6];
                my $method = (split /\s+/, ${$cds{$again}}[0])[1];
                my $first = (split /\s+/, ${$cds{$again}}[0])[3];
                my $last = (split /\s+/, ${$cds{$again}}[$lastelem])[4];
                ($first, $last) = sort {$a <=> $b} ($first, $last);
		        my $range = "$first\t$last";
                print "$name\t$method\tgene\t$range\t.\t$strand\t.\t$again;\n"; #<STDIN>;
                my $tag = (split /\=/, $again)[1];
                print "$name\t$method\tmRNA\t$range\t.\t$strand\t.\tID=$tag.1;Parent=$tag;\n"; #<STDIN>;
                my $count = 1;
                if( $strand eq '-' ){
                    my $numelem= @{$cds{$again}};
                    for(my $i=0; $i< $numelem; $i++){
                        my $lines= shift(@{$cds{$again}});
                        print "$lines\t.\tID=$tag.1.$count;Parent=$tag.1;\n"; #<STDIN>;
                        $count++;
                    }
                }elsif( $strand eq '+' ){
                    foreach my $lines (@{$cds{$again}}) {
                            print "$lines\t.\tID=$tag.1.$count;Parent=$tag.1;\n"; #<STDIN>;
                            $count++;
                    }
                }

        } else {
                print "weird tag $again\n";
        }
}

unlink glob("*protein2genome.gff");
