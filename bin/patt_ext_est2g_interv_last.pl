#!/usr/bin/env perl
use strict;


@ARGV > 1 || die "usage: $0 <genome_sequence.fna> <exonerate.output> ['p' if p2genome output) Default is e2genome]
    le das la secuencia genomica y el output de est2genome de la busqueda de algun EST en esta secuencia y
    devuelve las secuencias de 5', Exones, Intrones y 3' de la genomica correspondiente al mapeo con el EST \n";

my $sequence= shift;
my (%genome,$genome_sequence, $query, $target);
open IN, $sequence or die "Cant read $sequence\n";
while(<IN>){
    next if /^>/;
    chomp;
    $genome_sequence.= $_;
}

if( defined $ARGV[1] ){
    pop(@ARGV);
    while(<>){
        my ($name, $begin, $end);
        if( /^\s+Query: (\S+)/ ){
            $query= $1;
        }
        if( /^\s+Target: (\S+)/ ){
            $target= $1;
        }
        if( /^(\S+)\s+exonerate:protein2genome:(bestfit|local)\s+gene\s+\d+\s+\d+\s+\S+\s+([+-])/ ){
            my ($name, $strand)= ($1, $3);
            $genome{$name}{strand}= $strand;
        }
        if( /^(\S+)\s+exonerate:protein2genome:(bestfit|local)\s+exon\s+(\d+)\s+(\d+)\s+\S+\s+([+-])/ ){
            ($name, $begin, $end)=($1, $3, $4);
#             print "$name, $begin, $end\n";
            push @{$genome{$name}{begin}}, $begin;
            push @{$genome{$name}{end}}, $end;
        }
        if( /^(\S+)\s+exonerate:protein2genome:(bestfit|local)\s+intron\s+(\d+)\s+(\d+)\s+\S+\s+([+-])/ ){
            ($name, $begin, $end)=($1, $3, $4);
#             print "$name, $begin, $end\n";
            push @{$genome{$name}{begin}}, $begin;
            push @{$genome{$name}{end}}, $end;
        }
    }
}else{
    while(<>){
        my ($name, $begin, $end);
        if( /^(\S+)\s+exonerate:est2genome\s+gene\s+\d+\s+\d+\s+\S+\s+([+-])/ ){
            my ($name, $strand)= ($1, $2);
            $genome{$name}{strand}= $strand;
        }
        if( /^(\S+)\s+exonerate:est2genome\s+exon\s+(\d+)\s+(\d+)\s+\S+\s+([+-])/ ){
            ($name, $begin, $end)=($1, $2, $3);
#             print "$name, $begin, $end\n";
            push @{$genome{$name}{begin}}, $begin;
            push @{$genome{$name}{end}}, $end;
        }
        if( /^(\S+)\s+exonerate:est2genome\s+intron\s+(\d+)\s+(\d+)\s+\S+\s+([+-])/ ){
            ($name, $begin, $end)=($1, $2, $3);
#             print "$name, $begin, $end\n";
            push @{$genome{$name}{begin}}, $begin;
            push @{$genome{$name}{end}}, $end;
        }

    }
}

my $genome_sequence_reverse= reverse_seq($genome_sequence);
my $length= length($genome_sequence);
my $cds;

foreach my $seq ( sort keys %genome ){
    my $last;
    print "\n##    $query    ##\n";
    if( $genome{$seq}{strand} eq '+' ){
        my $start5 = $genome{$seq}{begin}[0] - 1000 > 0 ? $genome{$seq}{begin}[0] - 1000 : 0;
        print "\n5'.. $seq\t$start5\t",$genome{$seq}{begin}[0] - 1,"\n";
        print substr($genome_sequence, $start5 -1, 1000), "\n";
        for(my $i=0; $i< @{$genome{$seq}{begin}}; $i++){
                my $interv= $genome{$seq}{end}[$i] - $genome{$seq}{begin}[$i];
                print "Exon\t$seq\t$genome{$seq}{begin}[$i]\t$genome{$seq}{end}[$i]\n" unless ($i % 2);
                $cds.=substr($genome_sequence, $genome{$seq}{begin}[$i] -1, $interv +1) unless ($i % 2);
                print "Intron\t$seq\t$genome{$seq}{begin}[$i]\t$genome{$seq}{end}[$i]\n" if ($i % 2);
                print substr($genome_sequence, $genome{$seq}{begin}[$i] -1, $interv +1), "\n";
                $last= $genome{$seq}{end}[$i];
        }
        my $start3 = $last + 1000 < length($genome_sequence) ? $last + 1000 : length($genome_sequence);
        print "3'.. $seq\t",$last + 1,"\t$start3\n";
        print substr($genome_sequence, $last, $start3 - $last), "\n";
    }else{
        my $start5 = ($length-$genome{$seq}{end}[0]) - 1000 > 0 ? ($length-$genome{$seq}{end}[0] - 1000) : 0;
        print "\n5'.. $seq\t$start5\t",($length-$genome{$seq}{end}[0]),"\n";
        print substr($genome_sequence_reverse, $start5, 1000), "\n";
        for(my $i=0; $i< @{$genome{$seq}{end}}; $i++){
                my $interv= ($length-$genome{$seq}{begin}[$i]) - ($length-$genome{$seq}{end}[$i]);
                print "Exon\t$seq\t",($length-$genome{$seq}{end}[$i]) + 1,"\t",($length-$genome{$seq}{begin}[$i]) + 1,"\n" unless ($i % 2);
                $cds.= substr($genome_sequence_reverse, ($length-$genome{$seq}{end}[$i]), $interv +1) unless ($i % 2);
                print "Intron\t$seq\t",($length-$genome{$seq}{end}[$i]) + 1,"\t",($length-$genome{$seq}{begin}[$i]) + 1,"\n" if ($i % 2);
                print substr($genome_sequence_reverse, ($length-$genome{$seq}{end}[$i]), $interv +1), "\n";
                $last= ($length-$genome{$seq}{begin}[$i]);
        }
        my $start3 = $last + 1000 < length($genome_sequence) ? $last + 1000 : length($genome_sequence);
        print "3'.. $seq\t",$last,"\t$start3\n";
        print substr($genome_sequence_reverse, $last +1, $start3 - $last), "\n";
    }
#     print "\nCDs:\n>${query}_$target\n$cds\n";
    print "\nCDs:\n>$query\n$cds\n";
    my $rand= rand[100000];
    my $tmpfile= "/var/tmp/karel/cosaexonerate_".$rand;
    open OUT, ">$tmpfile" or die "can't write in $tmpfile\n";
#     print OUT ">${query}_$target\n$cds\n";
    print OUT ">${query}_$seq\n$cds\n";
    print "\nProt:\n",`/home/karel/bin/code2aa.l $tmpfile`,"\n";

    open CDSsingle, ">${query}_cds.fna";
    print CDSsingle ">${query}_$seq\n$cds\n";
    open PROTsingle, ">${query}_prot.faa";
    print PROTsingle `/home/karel/bin/code2aa.l $tmpfile`;

    #~ open CDS, ">>all_cds.fna";
    #~ print CDS ">${query}_$seq\n$cds\n";
    #~ open PROT, ">>all_prot.faa";
    #~ print PROT `/home/karel/bin/code2aa.l $tmpfile`;
    unlink $tmpfile;
}

sub reverse_seq{
# reverse_seq($seq|\$seq) returns the complementary sequence of the DNA $seq

    my $nucs= ref($_[0]) ? scalar(reverse(${$_[0]} ) ) : scalar(reverse($_[0]));
    $nucs=~ tr/ACGTacgtnN/TGCAtgcanN/;
    return $nucs;
}
