#!/usr/bin/env perl
use strict;
use Getopt::Std;
my(%options, %score, %line);
getopts("htpw:m:",\%options);
help() if defined $options{h};
@ARGV==1 or help();
my $blat=shift;
my $weight= defined $options{w}? $options{w} :2;
my $minscore= defined $options{m} ? $options{m} : -1000000;

# discard blat's heading
my $file_to_open= "$blat";
open IN, $file_to_open or die "Cant read $file_to_open\n";
my $line=0;
while(<IN>){
    last if /^---/;
    next if $line++<6;
    seek(IN, 0, 0);
    last;
}

while(<IN>){
    my($match, $name, $start, $end, $name2);
    if( defined $options{t} ){
        ($match, $name, $start, $end, $name2)=(split)[0, 13, 15, 16, 9];
    }else{
        ($match, $name, $start, $end, $name2)=(split)[0, 9, 11, 12, 13];
    }
    my $score=$match - $weight * ($end-$start -$match);
    next if $score< $minscore;
    if( defined $options{p} ){
        next if defined $score{$name}{$name2} && $score{$name}{$name2} >$score;
        $score{$name}{$name2}=$score;
        $line{$name}{$name2}=$_;
    }else{
        next if defined $score{$name} && $score{$name} >$score;
        $score{$name}=$score;
        $line{$name}=$_;
    }
}

if( defined $options{p} ){
    foreach my $name ( sort keys %line ){
        foreach my $name2 ( sort keys %{$line{$name}} ){
            print $line{$name}{$name2};
        }
    }

}else{
    foreach my $name ( sort keys %line ){
        print $line{$name};
    }
}




sub help{
    print << 'aqui' ;
# Usage: blat_best_match.l [options] <blat>\n";
# Basado en un blat, escoge las lineas del mejor match
-t     Obtener mejor para el target, default= mejor para el query
-p     Mejor de cada par query-target, default= mejor global para el query
          (o para el target con la opcion -t)
-w N   El score es $match - N*($end-$start - $match),  default N=2;
-m N   Minscore,  defualt N=0;
-h     Esta ayuda
aqui
;
exit(0);

}
=pod
$Log$
=cut
