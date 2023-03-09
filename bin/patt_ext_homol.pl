#!/usr/bin/env perl
use Parallel::ForkManager;

my $pm = new Parallel::ForkManager(1);


$ARGV[2] ||= 0;
my ($fasta, $genome, $protein_list)= ($ARGV[0], $ARGV[1], $ARGV[2]);
#~ print STDERR "$fasta\n";
my (@list);

if( $protein_list ){
    open IN, $protein_list or die "Cant read $protein_list\n";
    while(<IN>){
        chomp;
        push @list, $_;
    }

}else{
    chomp(@list = `grep '^>' $fasta | cut -d'>' -f2 | cut -d' ' -f1`);
}


extract_prot_and_blat();


sub extract_prot_and_blat{
    foreach my $prot ( @list ){
		$pm->start and next;
        system("patt_grep_fasta.pl '$prot' $fasta > ${prot}.faa 2>/dev/null"); # extrae las prot
        system("blat -q=prot -t=dnax -minScore=20 $genome ${prot}.faa ${prot}.blat 1>/dev/null"); # corre blat
        system("patt_blat_best_match.pl ${prot}.blat > ${prot}.blat.best 2>/dev/null"); # deja del blat el mejor hit o lugar en el genoma donde aparece
        my ($contig, $from, $to)= ext_cont("${prot}.blat.best"); # extrae las coordenadas de la region genomica donde mejor hace match
        system("echo '$contig $from $to' > ${prot}.coords");
        system("patt_grep_fasta.pl -x ${prot}.coords $genome > ${prot}.coords.fna 2>/dev/null"); # construye el fasta con la secuencia de acuerdo a las coordenadas de la region genomica donde mejor hace match
        system("exonerate -m protein2genome -s 0 -c 1 --showtargetgff T -n 1 ${prot}.faa ${prot}.coords.fna > ${prot}.protein2genome"); # corre exonerate
        system("patt_ext_est2g_interv_last.pl ${prot}.coords.fna ${prot}.protein2genome p > ${prot}.results"); # extrae el CDs, la secuencia peptidica y los intervalos (UTRs, exones, intrones)
        unlink "${prot}.faa", "${prot}.blat", "${prot}.blat.best", "${prot}.coords.fna", "${prot}.coords";
        $pm->finish;
    }
    $pm->wait_all_children;
}
sub ext_cont{
    my $bestblat= shift;
    my ($newfrom, $newto, $contig);
    open IN, $bestblat or die "Cant read $bestblat\n";
    while(<IN>){
        my ($length, $from, $to);
        ($contig, $length, $from, $to)= (split)[13, 14, 15, 16];
        ($from - 10000) > 0 ? ($newfrom= ($from - 10000)) : ($newfrom= 0);
        ($to + 10000) < $length ? ($newto= ($to + 10000)) : ($newto= $length);
    }
    return $contig, $newfrom, $newto;
}
