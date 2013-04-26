#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use LWP::Simple;
use XML::Simple;
use HTML::Template;
use URI::Escape;
use Encode;
use utf8;
use encoding qw(utf8);

##CGIモジュール準備
my $q = new CGI;

##GETメソッドの'query'パラメータの値を取得
my $key = $q->param('query');
##queryにおまじない
#my $query = decode('utf-8', $key) || ""
my $query = "高知県";
##HTMLヘッダを出力
print $q->header(-charset => 'UTF-8');
##HTMLボディを出力
print $q->start_html(-title=>'しょぼいCGI',  -encoding => 'UTF-8',);
print $q->center($q->h1('しょぼいCGI'));
print $q->hr;
##HTMLフォームを出力
print $q->start_form(-method => 'GET');
print $q->textfield(-name => 'query',-value => $query);
print $q->submit;
print $q->end_form;


## XML中の都道府県名とコードを表示
my $hit = "県名は".$query;
print $q->strong($hit);
print $q->br;

## ４７都道府県(query)に対応するローマ字をハッシュで用意                            
my %code = ("北海道", "hokkaido", "青森県", "aomori","岩手県","iwate","宮城県","miyagi","秋田県","akita","山\\
形県","yamagata","福島県","hukushima","茨城県","ibaraki","栃木県","tochigi","群馬県","gunma","埼玉県","saitama","千葉県","chiba","東京都","tokyo","神奈川県","kanagawa","新潟県","niigata","富山県","toyama","石川県","ishikawa","福井県","hukui","山梨県","yamagata","長野県","nagano","岐阜県","gihu","静岡県","shizuoka","愛知県","aichi","三重県","mie","\\
滋賀県","shiga","京都府","kyoto","大阪府","osaka","兵庫県","hyougo","奈良県","nara","和歌山県","wakayama","鳥\\
取県","tottori","島根県","shimane","岡山県","okayama","広島県","hiroshima","山口県","yamaguchi","徳島県","tokushima","香川県","kagawa","愛媛県","ehime","高知県","kouchi","福岡県","hukuoka","佐賀県","saga","長崎県","nagasaki","熊本県","kumamoto","大分県","ooita","宮崎県","miyazaki","鹿児島県","kagoshima","沖縄県","okinawa");

##POSファイル集合があるディレクトリ
my $dir="gotouchidir";

if ($code{$query}) {
	$query = $code{$query};
}

print $query."\n";

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

##TFIDFの計算
foreach my $key1 ( keys %tf ) {
	print "$key1\n";
	foreach my $key2 ( keys % { $tf { $key1 } } ) {
		my $tf = $tf{$key1}{$key2};
		my $df = keys % { $df { $key2 } };
		my $idf = log($N/$df)+1;
		my $tfidf = $tf * $idf;
		#if ($key1 eq $query) {
			print $q->a({href=>"term:$key2 tf:$tf idf:$idf tfidf:$tfidf"},$key1)."\n";
			#print $q->br;
		#}
	}
}
