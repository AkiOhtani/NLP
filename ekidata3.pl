#!/opt/local/bin/perl
use strict;
use warnings;
use CGI;
use LWP::Simple;
use XML::Simple;
use HTML::Template;
use URI::Escape;
use Encode;
use utf8;
use JSON;
use Data::Dumper;
use File::Slurp; ## これはファイルを読むモジュール
use URI;
use encoding qw(utf8);

my $query = "高知県";

##入力テキストファイル
my $intext = "test.txt";


## ４７都道府県(query)に対応する都道府県コードをハッシュで用意
my %code = ("北海道", "01", "青森県", "02","岩手県","03","宮城県","04","秋田県","05","山形県","06","福島県","07","茨城県","08","栃木県","09","群馬県","10","埼玉県","11","千葉県","12","東京都","13","神奈川県","14","新潟県","15","富山県","16","石川県","17","福井県","18","山梨県","19","長野県","20","岐阜県","21","静岡県","22","愛知県","23","三重県","24","滋賀県","25","京都府","26","大阪府","27","兵庫県","28","奈良県","29","和歌山県","30","鳥取県","31","島根県","32","岡山県","33","広島県","34","山口県","35","徳島県","36","香川県","37","愛媛県","38","高知県","39","福岡県","40","佐賀県","41","長崎県","42","熊本県","43","大分県","44","宮崎県","45","鹿児島県","46","沖縄県","47");

if ($code{$query}) {
	
	$query = $code{$query};

	my $ue = URI::Escape::uri_escape($query);


## 路線データAPI用のURL準備
	my $url = "http://www.ekidata.jp/api/p/".$ue.".xml"; #新潟県　都道府県コード:15
## 路線データAPIの結果取得
	my $response = get($url);
	#print "$response\n";
	print "----------------------------------------------------------------\n";

## 路線データAPIの結果のXMLを処理
	my $ref = XMLin($response);

## XML中の路線名を取得、全駅名を表示
	my $i = 0;
	my $j = 0;
	
	while($ref->{'line'}[$i]) {
		my $line = $ref->{'line'}[$i]->{'line_name'};

#		$ue = URI::Escape::uri_escape($line);
		## 駅データAPI用のURL準備
		$url = "http://www.ekidata.jp/api/l/".$ref->{'line'}[$i]->{'line_cd'}.".xml";
		## 駅データAPIの結果取得
		my $response = get($url);

		my $ref2 = XMLin($response);
		## 各路線の全駅を表示
		while($ref2->{'station'}[$j]) {
			print my $station = $ref2->{'station'}[$j]->{'station_name'};
			print " ";
			
			## Geoapiで各駅の緯度・軽度を取得
			$url = "http://www.geocoding.jp/api/?v=1.1&q=".$station;

			my $response2 = get($url);

			my $ref3 = XMLin($response2);

			# 緯度 
			print $ref3->{'coordinate'}->{'lat'}." ";
			# 経度
			print $ref3->{'coordinate'}->{'lng'}." ";
			print "\n";
		
			$j++;
		}
		$j = 0;
		$i++;
	}

print "\n----------------------------------------------------------------\n";


}
