#!/usr/bin/perl

##POSファイル集合があるディレクトリ
my $dir="gotouchidir";

##ファイル数変数
my $N;

##DFハッシュ
my %df;

##tfハッシュ
my %tf;

## 都道府県ハッシュ
my %gotouchi;


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


##TFIDFの計算
foreach my $key1 ( keys %tf ) {
	#print "<$key1>\n";
	foreach my $key2 ( keys % { $tf { $key1 } } ) {
		my $tf = $tf{$key1}{$key2};
		my $df = keys % { $df { $key2 } };
		my $idf = log($N/$df)+1;
		my $tfidf = $tf * $idf;
		if ($tfidf > 10 ) {
			#print "term:$key2 tf:$tf idf:$idf tfidf:$tfidf\n";	
			#print "$key2:$tf ";
			
			#　都道府県ハッシュのキーと値を追加
			$gotouchi{$key1}{$key2} = $tf;
		}
	}
}

print "--------------------term frequency--------------------------\n";
foreach my $prefecture ( keys  %gotouchi ) {
	print $prefecture."  ";
	foreach my $gourmet ( keys %{ $gotouchi { $prefecture } }) {
		print $gourmet.":";
		print $gotouchi{$prefecture}{$gourmet}." ";
	}
	print "\n\n";
}
print "-----------------------------------------------------------------\n";

## 都道府県の数だけクラスタを生成

# クラスタのハッシュを用意
my %cluster;

my $number = 1;

foreach $prefecture( keys %gotouchi ) {
	# クラスタの番号に対して都道府県名の配列を用意		
	my @prefectures = ($prefecture);
	@{$cluster{$number}} = @prefectures;
	$number = $number + 1;
}

$cluster{"all"} = $number - 1; # クラスタの総数

my $max = 0; # 類似度比較のためのバッファ
my $similarity = 0; # 類似度
my $presimilarity = 0; # 内積の和
my $sigmaX2 = 0; # 余弦を算出するための、x^2の和
my $sigmaY2 = 0; # 余弦を算出するための、y^2の和

# クラスタのペアとなる候補 
my $list1 = 0;
my $list2 = 0;

# ２つのクラスタリング内の要素の総数
my $count = 0;

print "\n--------------------hierarchical clustering--------------------------\n";
## クラスタの総数-1が1になるまでクラスタリング(階層化クラスタリング)
while (($cluster{"all"} - 1) > 0) {
	# バブルソートの要領(本当は違う)で類似度が最大となるペアを見つける
	for (my $i = 1; $i < $number - 1 ;$i++)  {
		for (my $j = $i + 1; $j <= $number - 1 ;$j++) {
			# 文書d_x,d_yの索引語'うどん'に対する重みの内積を用いて類似度を計算
			foreach my $prefecture (@{ $cluster{ $i }}  ) {
				foreach my $prefecture2 (@{ $cluster{ $j } }) {
					if ($prefecture eq $prefecture2) {
						# do nothing
					}
					else {
						foreach $key ( keys % { $gotouchi{$prefecture} } ) {
							foreach $key2 ( keys % { $gotouchi{$prefecture2} } ) {
								if ($key eq $key2) {

									## 索引後の重み(今回はtfの値を直接用いる)の内積をとる
									$presimilarity = $presimilarity + $tf{$prefecture}{$key} * $tf{$prefecture2}{$key2};
									$sigmaX2 = $sigmaX2 + $tf{$prefecture}{$key} * $tf{$prefecture}{$key};
									$sigmaY2 = $sigmaY2 + $tf{$prefecture2}{$key2} * $tf{$prefecture2}{$key2};
								}
							}
						}
						# 正しく計算されているならば
						if ($sigmaX2 != 0 && $sigmaY2 != 0) {
							## 類似度を余弦で再計算 
							$similarity = $similarity + ($presimilarity / sqrt($sigmaX2 * $sigmaY2));
						}
					}

							  	 
					# $presimilarity,$sigmaX2,$sigmaY2を初期化
					$presimilarity = 0;
					$sigmaX2 = 0;
					$sigmaY2 = 0;

					# ２つのクラスタリング内の要素の総数をカウント
					$count++;
				}
			}

			# 類似度の和を要素数で割る(群平均法)
			$similarity = $similarity / $count;

			# 要素数を初期化
			$count = 0;

			# もし類似度最大のペアが見つかればリストに保存
			if ($max < $similarity) {
				$max = $similarity;
				$list1 = $i;
				$list2 = $j;
				
				# 類似度を初期化
				$similarity = 0;
				
			}
			else {
				# 類似度を初期化
				$similarity = 0;
			}

		}
	}
	print "\n";


	print "(".($list1).",".($list2).") => ".$list1." "."類似度".$max."\n";


	# クラスタをマージする
	@prefectures = (@{$cluster{$list1}},@{$cluster{$list2}});
	@{$cluster{$list1}} = @prefectures;
	@{$cluster{$list2}} = (\0);
	
	$list1 = 0;
	$list2 = 0;
	$cluster{"all"}--;


	
	$max = 0;


}

print "---------------------------------------------------------------------\n";
