##入力テキストファイル
my $intext = "gotouchicategorydir/nara.txt";

##出力POSファイル
my $chasen_pos = "chasen.txt";
my $mecab_pos = "mecab.txt";

##茶筅
## -j:日本語モード -i w:文字コードutf-8
my $cmd = "chasen -i w ${intext} >${chasen_pos}";
system($cmd);

##Mecab
## -Ochasen:chasen互換出力
$cmd = "mecab -Ochasen ${intext} >${mecab_pos}";
system($cmd);
