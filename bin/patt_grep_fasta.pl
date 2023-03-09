#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Std;
my(%opts,$left,$right,$base);

getopts("Nh1oscrdDvLl:x:y:b:n:", \%opts);
help() if $opts{'h'};
my $regex=shift unless $opts{'l'} || $opts{'x'} ||$opts{'y'} || $opts{'b'};

my @files=@ARGV;
@files >=1 or help();

my $cnt=0;
if( $opts{c} ){
    die "Option -c requires -(l|x|y)\n" unless ($opts{l} or $opts{x} or $opts{y});
    die "Option -c and -v are not compatible\n" if $opts{v};
}
if( $opts{n} ){
    die "Option -n requires -(x|y)\n" unless ($opts{x} or $opts{y});
    my $n=$opts{n};
    $n= "$n:$n" unless $n=~tr/:/:/;
    ($left,$right)=$n=~ m{^(\d+)?:(\d+)?$} or die "Bad option -n $opts{n}\n";
    $left||=0;
    $right|=0;
}
$base= $opts{1} ? 1 :0;
if( $opts{'l'} ){
    die "patt_grep_fasta.pl: las opciones -l y -s no son compatibles\n" if $opts{'s'};
    $opts{v} ?  wo_list() :  w_list();
}elsif($opts{'x'} || $opts{y}|| $opts{b}){
    die "patt_grep_fasta.pl: las opciones -(b|x|y) y -s no son compatibles\n" if $opts{'s'};
    die "patt_grep_fasta.pl: las opciones -(b|x|y) y -v no son compatibles\n" if $opts{'v'};
    w_list_extract($opts{x}) if $opts{x};
    w_list_extract($opts{y},1) if $opts{y};
    w_blat_style($opts{b}) if $opts{b};

}elsif($opts{'r'}){
    $opts{v} ?  wo_regex() : w_regex();
}else{
    $opts{v} ?  wo_string() : w_string();
}

print STDERR "$cnt sequence found\n";


# ================================ positivas
sub w_regex{
    foreach my $file ( @files ){
        my $fasta = read_fasta_file($file);
        if( $opts{'s'} ){ # busca en la secuencia
            while(my $data = shift @$fasta) {
                my($name, $desc, $seq)= @$data;
                next unless $seq=~ m{$regex};

                $desc= $opts{D} ? " $desc" : '';
                print ">$name$desc\n$seq\n";
                exit if $opts{'o'};
                $cnt++;
            }
        }else{
            while(my $data = shift @$fasta) {
                my($name, $desc, $seq)= @$data;
                if( $opts{d} ){
                    next unless ($name=~ m{$regex} || $desc=~ m{$regex});
                    print ">$name $desc\n$seq\n";
                    $cnt++;
                }else{
                    next unless $name=~ m{$regex} ;
                    $desc= $opts{D} ? " $desc" : '';
                    print ">$name$desc\n$seq\n";
                    $cnt++
                }
                exit if $opts{'o'};
            }
        }
    }
}
sub w_string{
    foreach my $file ( @files ){
        my $fasta = read_fasta_file($file);
        if( $opts{'s'} ){ # busca en la secuencia
            while(my $data = shift @$fasta) {
                my($name, $desc, $seq)= @$data;
                next unless index($seq, $regex)>=0;

                $desc= $opts{D} ? " $desc" : '';
                print ">$name$desc\n$seq\n";
                exit if $opts{'o'};
                $cnt++;
            }
        }else{
            while(my $data = shift @$fasta) {
                my($name, $desc, $seq)= @$data;
                next unless $name eq $regex;

                $desc= $opts{D} ? " $desc" : '';
                print ">$name$desc\n$seq\n";
                exit if $opts{'o'};
                $cnt++;
            }
        }
    }
}

sub w_list{
    my $IN = sopen("< $opts{'l'}", 0);
    my (%wanted,%strand);
    while(<$IN>){
        next if /^#/;
        next if/^\s*$/;
        my($name,$strand)=(split);
        $wanted{$name}++;
        if( $opts{c} ){
            die "Not strand in $_" unless $strand=~/^[+-]$/;
            $strand{$name}=$strand;
        }
    }
    foreach my $file ( @files ){
            my $fasta = read_fasta_file($file);
        while(my $data = shift @$fasta) {
            my($name, $desc, $seq)= @$data;
            next unless $wanted{$name};
            $desc= $opts{D} ? " $desc" : '';
            if( $opts{c} ){
                if( $wanted{$name} eq '-' ){
                    print ">$name.r$desc\n", reverse_seq($seq),"\n";
                }else{
                    print ">$name.f$desc\n$seq\n";
                }
            }else{
                print ">$name$desc\n$seq\n";
            }
            exit if $opts{'o'};
            $cnt++;
        }
    }
}

sub w_blat_style{
    my $lista=shift;
    die "blat_style takes only one fasta\n" if @files != 1;
    (my $basename=$lista)=~ s{^.*/}{};
    my $IN = sopen("< $lista", 0);
    my %data;
    while(<$IN>){
        next if /^#/;
        next if/^\s*$/;
        chomp;
        my($name, $strand, $sizes, $starts,$comment)=  /^\s*(\S+)(?:\s+([+-]))?\s+([0-9,]+)\s+([0-9,]+\b)(.*)?/;
        $strand||='+';
        $comment||='';
        push @{$data{$name}}, [$., $strand,$sizes,$starts,$comment];
    }
    my $fasta = read_fasta_file($files[0]);
    while(my $data = shift @$fasta){
        my($name, $desc, $ori) = @$data;
        my($seq,$rev);
        next unless $data{$name};
        for(my $i=0; $i< @{$data{$name}}; $i++){
            my($line,$strand,$sizes,$starts,$comment)= @{$data{$name}[$i]};

            if( $strand eq '-' ){
                $seq=reverse_seq($ori) unless defined $rev;
            }elsif($strand eq '+'){
                $seq=$ori;
            }else{
                die "blat_style doesn understand strand '$strand'\n";
            }


            my $hit='';
            my @starts=split(',',$starts);
            my @sizes=split(',',$sizes);
            for(my $j=0; $j< @starts; $j++){
                print STDERR "$starts[$j]\t$sizes[$j]\n";
#                 $hit.=substr($seq,$starts[$j],$sizes[$j]) ;
                $hit.=substr($ori,$starts[$j],$sizes[$j]) ;
            }
            $hit=reverse_seq(\$hit) if $strand eq '-';
            print ">$name.$i $strand $sizes $starts $basename($line); $comment\n$hit\n";
            $cnt++;
        }


    }

}
sub w_list_extract{
    my $lista=shift;
    my $by_len=shift;
    my $IN = sopen("< $lista", 0);
    my %data;
    while(<$IN>){
        next if /^#/;
        next if/^\s*$/;
        chomp;
        my($coords,$rest)=split(/\s*,\s*/,$_,2);
        $rest= $rest ? " ,$rest" :'';
        my ($nick,$nickname,$name,$from, $to,$strand);
        $nick= $opts{L} ? "Ln$.." : '';

        if( $opts{N} ){
            ($nickname,$name,$from, $to,$strand)=split(" ",$coords);
            $nick.="$nickname.";
        }else{
            ($name, $from, $to,$strand)=(split);
        }

        $to=$from+$to if $by_len; # to is actually a fragment len
        push @{$data{$name}{from}}, $from - $base;
        push @{$data{$name}{to}}, $to - $base;
        push @{$data{$name}{nick}}, $nick;
        push @{$data{$name}{rest}}, $rest;
        if( $opts{c} ){
            $strand||='+';
            die "Not strand in $_" unless $strand=~/^[+-]$/;
            push @{$data{$name}{strand}}, $strand;
        }

    }
    #~ die Dumper(\%data);
    foreach my $file ( @files ){
		my $fasta = read_fasta_file($file);
		while(my $data = shift @$fasta) {
			my($name, $desc, $seq)= @$data;
			next unless $data{$name};
			$desc= $opts{D} ? "\t$desc" : '';
			for(my $i=0; $i< @{$data{$name}{from}}; $i++){
				neighborhood($data{$name},$i,$seq) if $opts{n};
				my $from=$data{$name}{from}[$i];
				my $to= $data{$name}{to}[$i];
				my $len= $to -$from;
				my $nick=$data{$name}{nick}[$i];
				my $rest=$data{$name}{rest}[$i];
				if( $opts{c} ){
					if( $data{$name}{strand}[$i] eq '-' ){
						print ">$nick$name.$i.$from-$to.r$rest$desc\n",
							reverse_seq(substr($seq, $from, $len)), "\n";
					}else{
						print ">$nick$name.$i.$from-$to.f$rest$desc\n",
							substr($seq, $from, $len), "\n";
					}


				}else{
					print ">$nick$name.$i.$from-$to$rest$desc\n",
						substr($seq, $from, $len), "\n";
				}


				exit if $opts{'o'};
				$cnt++;
			}
		}
    }
}
# ================================ negativas
sub wo_regex{
    foreach my $file ( @files ){
        my $fasta = read_fasta_file($file);
        if( $opts{'s'} ){ # busca en la secuencia
            while(my $data = shift @$fasta) {
                my($name, $desc, $seq)= @$data;
                next if $seq=~ m{$regex};
                $desc= $opts{D} ? " $desc" : '';
                print ">$name$desc\n$seq\n";
                exit if $opts{'o'};
                $cnt++;
            }
        }else{
            while(my $data = shift @$fasta) {
                my($name, $desc, $seq)= @$data;
                if( $opts{d} ){
                    next if ($name=~ m{$regex} || $desc=~ m{$regex});
                    print ">$name $desc\n$seq\n";
                }else{
                    next if $name=~ m{$regex} ;
                    $desc= $opts{D} ? " $desc" : '';
                    print ">$name$desc\n$seq\n";
                }
                exit if $opts{'o'};
                $cnt++;
            }
        }
    }
}
sub wo_string{
    foreach my $file ( @files ){
        my $fasta = read_fasta_file($file);
        if( $opts{'s'} ){ # busca en la secuencia
            while(my $data = shift @$fasta) {
                my($name, $desc, $seq)= @$data;
                next if index($seq, $regex)>=0;

                $desc= $opts{D} ? " $desc" : '';
                print ">$name\n$seq\n";
                exit if $opts{'o'};
                $cnt++;
            }
        }else{
            while(my $data = shift @$fasta) {
                my($name, $desc, $seq)= @$data;
                next if $name eq $regex;
                $desc= $opts{D} ? " $desc" : '';
                print ">$name$desc\n$seq\n";
                exit if $opts{'o'};
                $cnt++;
            }
        }
    }
}

sub wo_list{
    my $IN = sopen("< $opts{'l'}", 0);
    my %wanted;
    while(<$IN>){
        next if /^#/;
        next if/^\s*$/;
        my($name)=(split);
        $wanted{$name}++;
    }
    foreach my $file ( @files ){
        my $fasta = read_fasta_file($file);
        while(my $data = shift @$fasta) {
            my($name, $desc, $seq)= @$data;
            next if $wanted{$name};

            $desc= $opts{D} ? " $desc" : '';
            print ">$name$desc\n$seq\n";
            exit if $opts{'o'};
            $cnt++;
        }
    }
}

sub neighborhood{
    my($data,$i,$seq)=@_;
    my $len=length($seq);
    if( $opts{c} &&  $data->{strand}[$i] eq '-'){
        $data->{from}[$i]= $data->{from}[$i]-$right >=0 ? $data->{from}[$i]-$right :0;
        $data->{to}[$i]= $data->{to}[$i]-$left <$len ? $data->{to}[$i]+$left :$len;
    }else{
        $data->{from}[$i]= $data->{from}[$i]-$left >=0 ? $data->{from}[$i]-$left :0;
        $data->{to}[$i]= $data->{to}[$i]-$right <$len ? $data->{to}[$i]+$right :$len;
    }
}

sub reverse_seq{
# reverse_seq($seq|\$seq) returns the complementary sequence of the DNA $seq

    my $nucs= ref($_[0]) ? scalar(reverse(${$_[0]} ) ) : scalar(reverse($_[0]));
    $nucs=~ tr/ACGTacgtnN/TGCAtgcanN/;
    return $nucs;
}
sub read_fasta_file {
    my ($file) = @_;
    my @seqs;
    open(my $fh, "<", $file) or die "Can't open $file: $!";
    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ /^>(\S+)\s*(.*)$/) {
            push @seqs, [$1,$2,''];
        } else {
            $seqs[-1][2] .= $line;
        }
    }
    close($fh);
    return \@seqs;
}
sub sopen{
# $fh=sopen($filename, [$verbose]) returns a filehandle_reference
    my $filename = shift;
    my $in = do { local *IN };
    open $in, $filename or die "$filename: $!";
    print STDERR "myopen $filename\n" if $_[0];
    return $in;
}


# =================================
sub help{
die <<'aqui';
patt_grep_fasta.pl [options] <query> <fasta_files>
options:
-h         This help
-s         Search as substring of sequence, not in seq_names
-d         Search (and include) description
-D         Inlude description in heading
-o         Exit after first match
-r         Query is a regex
-v reverse hit list ;  no es compatible con -x o -y
-l <file>  Take sequence names from 'file'; names should be exact;
-x <file>  As -l but eXtract region. List has 3+ columns:name, from, to, [strand]
-y <file>  As -l but extract region. List has 3+ columns:name, from, len, [strand]
           Note: even with -c from and to refere to the original strand
-1         from and to count from 1. Default they count from 0;
           Not compatible with -b (blat_style) # Revisar esto
-c         For -(l|x|y) complement negative strand. It is indicated with -|+
           Not compatible with -v or -q
           Will produce garbage if seq is protein
-n a:b     With -x or -y, extends left and right neighborhoods, a and b residues,
           respectively.
           If strand is negative, b:a will be done, so that the
           reported (reversed) seq estend a to the left and b to the right.
           'a' equals a:a, 'a:' equals a:0, and ':b' equals 0:b.
           -n is only compatible with -x or -y, and all their restrictions apply
-L         With -x or -y, prepend name with list's line_number
-N         With -x or -y, prepend name with 'nickname' which must be firts word in row. ie:
           nickname Contig from to [strand]
Note:      with  -x or -y, a row can have a comments. Coments must be separated from coords
           with a ',' (comma). Comments will appear verbatim in the sequence heading ie:
           [nickname] Contig from to [strand] [, comment ]
-l is not compatible with -r or -s
-q is not compatible with -s

Note: seq_names are as this ($seq_name)=~ m/^>(\S+)/
aqui
;

}

