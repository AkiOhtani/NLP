#!/opt/local/bin/perl

use strict;
use Dumpvalue;

package Clusters;

# this subroutean is get first line that means row names,
# and, othe line's first column is each column name.
# those data insert big list.
# * rownames and colnames useful index keys.
sub readfile {
	my($self, $filename) = @_;

	# get file data
	open my $file, '<', $filename;
	# first line is column titles
	my @colnames = split('\t', <$file>);
#my @colnames = split(' ', <$file>);
	my @lines = <$file>;
	close $file;

	# set data
	my @rownames = ();
	my @data = ();
	foreach my $line(@lines) {
		my @p = split('\t', $line);
		# my @p = split(' ', $line);
		# each line's first column is colum name
		unshift(@rownames, shift(@p));
		# other column is this line's data
		unshift(@data, \@p);
	}

	return \@rownames, \@colnames, \@data;
}

sub hcluster {
	# $rows: array reference
	# $distance: subroutean reference
	my($self, $rows, $distance) = @_;
	my $currentclustid = -1;
	my %distances = ();

	# Clusters are lines first.
	my @clust;
	map {
		push(@clust, Bicluster->new(vec => $rows->[$_], id => $_));
	} (0..$#$rows);

	while ($#clust > 0) {
		my @lowestpair = (0,1);
		my $closest = $distance->($clust[0]->{vec}, $clust[1]->{vec});

		# 全ての組をループし、もっとも距離の近い組を探す
		foreach my $i(0..$#clust) {
			foreach my $j($i+1..$#clust){
				# 距離をキャッシュしてあればそれを使う
				if (!defined($distances{$clust[$i]->{id}}{$clust[$j]->{id}})) {
					$distances{$clust[$i]->{id}}{$clust[$j]->{id}} = $distance->($clust[$i]->{vec}, $clust[$j]->{vec});
				}
				my $d = $distances{$clust[$i]->{id}}{$clust[$j]->{id}};
				if ($d < $closest) {
					$closest = $d;
					@lowestpair = ($i, $j);
				}
			}
		}

		# 二つのクラスタの平均を計算する
		my @mergevec = ();
		foreach my $i(0..$#{$clust[0]->{vec}}) {
			push(@mergevec, ($clust[$lowestpair[0]]->{vec}->[$i] + $clust[$lowestpair[1]]->{vec}->[$i]) / 2.0);
		}

		# 新たなクラスタを作る
		my $newcluster = Bicluster->new(
			id       => $currentclustid,
			vec      => \@mergevec,
			left     => $clust[$lowestpair[0]],
			right    => $clust[$lowestpair[1]],
			distance => $closest,
			);

		# 元のセットではないクラスタのIDは負にする
		$currentclustid = -1;
		splice(@clust, $lowestpair[1], 1);
		splice(@clust, $lowestpair[0], 1);
		push(@clust, $newcluster);
	}

	return $clust[0];
}

1;

# 階層的なツリーを表現するのに使うこれらのすべてのプロパティを持つBiclusterというクラス
package Bicluster;

sub new {
	my($self, %attr) = @_;
	return bless {
		id       => $attr{id},
		vec      => $attr{vec},
		left     => $attr{left},
		right    => $attr{right},
		distance => $attr{distance},
	}, $self;
}

1;

package main;

my($blognames, $words, $data) = Clusters->readfile('kagawa.txt');
my $start = time;
my $clust = Clusters->hcluster($data, \&pearson);
my $end = time;

printclust($clust, $blognames, 0);

#Dumpvalue->new->dumpValue($cluster);

sub pearson {
	my($v1, $v2) = @_;
	my($sum1, $sum2, $sum1Sq, $sum2Sq, $pSum) = (0, 0, 0, 0, 0);

	map {
		$sum1 += $_;
		$sum1Sq += $_ ** 2;
	} @$v1;

	map {
		$sum2 += $_;
		$sum2Sq += $_ ** 2;
	} @$v2;

	map {
		$pSum += $v1->[$_] * $v2->[$_];
	} 0..$#$v1;

	my $num = $pSum - ($sum1 * $sum2 / scalar(@$v1));
	my $den = sqrt(($sum1Sq - $sum1 ** 2 / scalar(@$v1)) * 
				   ($sum2Sq - $sum2 ** 2 / scalar(@$v1)));

	if ($den == 0) {
		return 0;
	}
	return 1.0 - $num / $den;
}

sub printclust {
	my($clust, $labels, $n) = @_;

	# 階層化のレイアウトにするためにインデントする
	foreach my $i(0..$n) {
		print " ";
	}

	if ($clust->{id} < 0) {
		# 負のidはこれが枝である事を示している
		print '-', "\n";
	}
	else {
		# 正のidはこれが終端だという事を示している
		if ($labels == undef) {
			print $clust->{id}, "\n";
		}
		else {
			print $labels->[$clust->{id}], "\n";
		}
	}

	# 右と左の枝を表示
	if ($clust->{left}) {
		printclust($clust->{left}, $labels, $n + 1);
	}
	if ($clust->{right}) {
		printclust($clust->{right}, $labels, $n + 1);
	}
}

1;
