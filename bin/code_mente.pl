use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Kabuyoso::DB;
use LWP::UserAgent;
use utf8;
my $trace;
GetOptions( "t" => \$trace );
my $conf = require "$Bin/../kabuyoso_web.conf";
my $db = new Kabuyoso::DB( $conf->{db} );
if ($trace) {
    my $ite = $db->search( 'Stock', {}, { order_by => 'stock_code' } );
    my $count = 0;
    while ( my $row = $ite->next ) {
        printf "%s(%s)\n", $row->stock_code, $row->name;
        $count++;
    }
    printf "total=%d件\n", $count;
    exit 0;
}
my $ua = LWP::UserAgent->new;
#タイムアウトを設定
$ua->timeout(10);
$ua->env_proxy;
my $req =
  HTTP::Request->new( GET => 'http://ikachi.sub.jp/kabuka/api/mst/csv.php' );
my $res = $ua->request($req);
my $content;
if ( $res->is_success ) {
    $content = $res->content;
}
else {
    exit 1;
}
my @lines = split( /(?:\r\n|\r|\n)/, $content );
my @download_code;
my $prev_code = '';
for my $line (@lines) {
    my ( $code, $name ) = split( ',', $line );
    if ( $prev_code ne $code ) {
        printf "$code\n", $code;
        push @download_code, $code;
        my $row = $db->single( 'Stock', { stock_code => $code } );
        if ($row) {
            if ( $row->name ne $name ) {
                $row->update( { name => $name } );
            }
        }
        else {
            $db->insert( 'Stock', { stock_code => $code, name => $name } );
        }
    }
    $prev_code = $code;
}
my $ite = $db->search( 'Stock', {}, { order_by => 'stock_code' } );
while ( my $row = $ite->next ) {
    my $found_rows = grep $row->stock_code, @download_code;
    if ( $found_rows == 0 ) {
        $row->delete;
    }
}
exit 0;