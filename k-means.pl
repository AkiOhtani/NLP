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

# elementのハッシュを用意
my %element;

# エレメントの数を保存する変数
my $number = 1;

## 都道府県の数だけelementを生成
foreach $prefecture( keys %gotouchi ) {
	# elementの番号に対して都道府県名の配列を用意		
	#my @prefectures = ($prefecture);
	$element{$number} = $prefecture;
	$number = $number + 1;
}

my $similarity = 0; # 類似度

# クラスタの数
my $k = int($N/2) - 1;
print $k;

# クラスタのハッシュを用意
my %cluster;

## ランダムでクラスタ作成(ただし、今回は決め打ち)
@{$cluster{1}} = ("うどん県");
@{$cluster{2}} = ("サウザンドリーブス県");
@{$cluster{3}} = ("バンビアイランド県");
$gotouchi{"うどん県"}{"麺類"} = 12;
$gotouchi{"うどん県"}{"ラーメン"} = 15;
$gotouchi{"うどん県"}{"そば"} = 18;
$gotouchi{"うどん県"}{"うどん"} = 20;
$gotouchi{"サウザンドリーブス県"}{"海鮮"} = 12;
$gotouchi{"サウザンドリーブス県"}{"魚介"} = 15;
$gotouchi{"サウザンドリーブス県"}{"寿司"} = 20;
$gotouchi{"バンビアイランド県"}{"洋食"} = 15;
$gotouchi{"バンビアイランド県"}{"イタリアン"} = 18;
$gotouchi{"バンビアイランド県"}{"フレンチ"} = 18;
$tf{"うどん県"}{"麺類"} = 12;
$tf{"うどん県"}{"ラーメン"} = 15;
$tf{"うどん県"}{"そば"} = 18;
$tf{"うどん県"}{"うどん"} = 20;
$tf{"サウザンドリーブス県"}{"海鮮"} = 12;
$tf{"サウザンドリーブス県"}{"魚介"} = 15;
$tf{"サウザンドリーブス県"}{"寿司"} = 20;
$tf{"バンビアイランド県"}{"洋食"} = 15;
$tf{"バンビアイランド県"}{"イタリアン"} = 18;
$tf{"バンビアイランド県"}{"フレンチ"} = 18;

# foreach $prefecture( keys %random ) {
# 	# elementの番号に対して都道府県名の配列を用意		
# 	my @prefectures = ($prefecture);
# 	@{$cluster{$number}} = @Prefectures;
# }

# クラスタの要素 
my %list;
for (my $i = 1; $i <= $k ;$i++)  {
	@{ $list{$i}} = ();
}

# クラスタとelementで類似度計算を行なった回数
my $count = 0;

# クラスタの変化監視変数
my $completed = 1;

print "\n--------------------k-means clustering--------------------------\n";
## クラスタが変化しなくなるまでクラスタリング(k-meansクラスタリング)
while (1) {
	# 類似度が100より大きくなるクラスタとelementのペアを見つける
	for ($i = 1; $i <= $k ;$i++)  {
		for (my $j = 1; $j <= ($number - 1) ;$j++) {
			# 文書d_x,d_yの索引語'うどん'に対する重みの内積を用いて類似度を計算
			foreach my $prefecture (@{ $cluster{ $i }}  ) {

					# クラスタとelementの全ての都道府県の組の類似度の和を求める
					foreach $key ( keys % { $gotouchi{$prefecture} } ) {
						foreach $key2 ( keys % { $gotouchi{$element{ $j } } } ) {
							if ($key eq $key2) {
								## 索引後の重み(今回はtfの値を直接用いる)の内積をとる
								$similarity = $similarity + $tf{$prefecture}{$key} * $tf{$element{$j}}{$key2};
							}
						}
					}
					$count++;
			}

			# 類似度の和を、クラスタとelementで類似度計算を行なった回数で割る（重心を求めたのと同じ）
			$similarity = $similarity / $count;

			# もし類似度が100より大きいペアが見つかればリストにelementの都道府県名を追加
			if ($similarity > 100) {
				push(@{ $list{$i} },$j);
				
				# 類似度を初期化
				$similarity = 0;
			}
		}
	}
	
	# クラスタを保存する
	my %original; # = %cluster;
	for ($i = 1; $i <= $k; $i++) {
		@{ $original{$i} }= @{ $cluster{$i}};
	}
	# クラスタを更新する
	my @prefectures = (); # 配列を空にする
	for ($i = 1; $i <= $k; $i++) {
		$count = 1;
		@prefectures = ();# 配列を空にする
		foreach $j ( @{ $list{ $i } } ) {
			#print $element{$j}."\n";
			#print key $gotouchi{$element{$j}};
			#print (keys %{$tf{$element{ $j } } });
			#print (keys %{$element{ $j }  });

			foreach $name (keys %tf) { 
				if ($count == $j) {
					push(@prefectures,$name); # $element{$j}を@prefecturesに追加
					$count = 1;
				}
				else {
					$count++;
				}
			}
			#print "hoge\n";
		}
		#print "<".@prefectures.">\n";
		@{ $cluster{$i} } = @prefectures;
		#print "\n";
	}
	# リストを初期化する
	for ($i = 1; $i <= $k; $i++) {
		@{ $list{$i} } = ();
	}
	# 保存したクラスタと更新したクラスタが異なるならば$completedに0を代入する	
	for ($i = 1; $i <= $k ;$i++) {
		print $completed = &distrcmp(@{ $cluster{$i} },@{ $original{$i} });
		if ($completed == 0) {
			last;
		}
	}
	# $completedが 1 ならば last
	if ($completed == 1) {
		last;
	}
}

print "\n";

print "(1が $k つ連続で出たら終了)\n\n";
## 最終結果を表示
for ($i = 1; $i <= $k ;$i++) {
	print "($i) => ";
		foreach $name (@{ $cluster{$i}} ) {
			print "$name ";
	}
	print "\n";
}

print "\n---------------------------------------------------------------------\n";

## リスト比較モジュール
sub distrcmp($$) {
     (@a, @b) = @_;
   
	 # (1)二つの要素の数が同じであること
	 return 0 if $#a != $#b;
	
	# (2)先頭から比較して、末尾までの内容が等しいこと
	 for (0..$#$a){
		 return 0 if $a->[$_] ne $b->[$_];
	 }
	 
	 return 1;
}
