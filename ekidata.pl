#!/opt/local/bin/perl
use LWP::Simple;
use URI::Escape;
#my $query = "松尾豊 うどん";
#my $ue = URI::Escape::uri_escape($query);
# my $url = "http://boss.yahooapis.com/ysearch/web/v1/$ue?"
# ."appid=gt33JKTV34FKDv3AXuxs6ZC8prX.uGFZKZnOa3CqrH9dMpgz2HAVEqIoZ3vv2URI27IEDg--&amp;"
# ."format=xml&amp;lang=jp&amp;region=jp";
	my $url = "http://www.ekidata.jp/api/p/15.xml"; #新潟県　都道府県コード:15
my $response = get($url);
print "$response\n";
