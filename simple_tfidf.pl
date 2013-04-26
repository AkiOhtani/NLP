#!/usr/bin/perl

##POSファイル集合があるディレクトリ
my $dir="gotouchidir";

##ファイル数変数
my $N;

##DFハッシュ
my %df;

##tfハッシュ
my %tf;

##POSファイル集合があるディレクトリからファイルを読み込み
opendir(DIR, $dir);
while(my $file=readdir(DIR)) {
	my $posfile = $dir."/".$file;
	open(IN,"< $posfile");
	while(<IN>){
		chomp;
		##ファイルから一行読み込み、行の先頭(形態素)を切り出す
		my @line = split(/\t/,$_);
		if($line[0]){
			##DFカウント
			$df{$line[0]}{$posfile}=1;
			##TFカウント
			$tf{$posfile}{$line[0]}++;
		}
	}
	close(IN);
	##ファイル数カウント
	$N++;
}
closedir(DIR);

print "\n--------------------tf-idf-----------------------------------------\n";
##TFIDFの計算
foreach my $key1 ( keys %tf ) {
	#print "<$key1>\n";
	print "<$key1 >\n";
	foreach my $key2 ( keys % { $tf { $key1 } } ) {
		my $tf = $tf{$key1}{$key2};
		my $df = keys % { $df { $key2 } };
		my $idf = log($N/$df)+1;
		my $tfidf = $tf * $idf;
		if ($tfidf > 10 ) {
			#print "term:$key2 tf:$tf idf:$idf tfidf:$tfidf\n";
			print "$key2:$tfidf ";
		}
	}
	print "\n";
}
print "---------------------------------------------------------------------\n";
