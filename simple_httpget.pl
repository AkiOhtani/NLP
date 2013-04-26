#!/opt/local/bin/perl

##必要なモジュールの宣言
##HTTPクライアントモジュール
use LWP::UserAgent;
##文字コード変換モジュール
use NKF;
##タグ除去モジュール
use HTML::Scrubber;

##クエリー
my $query = "トリンドル玲奈";

##HTTPクライアント設定
my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla");

#Scrubberのオブジェクト生成
my $scrubber = HTML::Scrubber->new();

##URL
my $url = "http://news.google.co.jp/news?q=".$query;

##HTML取得
my $req = HTTP::Request->new(GET =&gt; $url);
$req->header('Accept' =&gt; 'text/html');
my $res = $ua->request($req);
if ($res->is_success) {
	my $src = $res->content;

	##文字コード変換
	my $utfsrc = _encode(\$src);

	##タグの除去
	my $plain_src = $scrubber->scrub($utfsrc);

	##結果を出力
	print "$plain_src\n";
}

#関数(文字コードをUTF8に変換)
 sub _encode {
	my ($ref_src) = @_;
	return nkf('-w','-Lu',$$ref_src);
}
