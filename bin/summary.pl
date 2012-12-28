use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Kabuyoso::DB;
use LWP::UserAgent;
use utf8;
my $conf = require "$Bin/../kabuyoso_web.conf";
my $db = new Kabuyoso::DB( $conf->{db} );
my $ite = $db->search( 'User', {}, { order_by => 'user_id' } );
while ( my $user = $ite->next ) {
    my $ite = $db->search_by_sql_abstract_more(
        +{
            -columns => [qw/count(*)|count/],
            -from    => ['Bet'],
            -where   => +{
                'active'  => +{ between => [2, 3] },
                'user_id' => $user->user_id
            },
            -group_by => ['user_id']
        }
    );
    my $count;
    if ( my $row = $ite->next ) {
        $count = $row->count;
    }
    else {
        $count = 0;
    }
    $user->update( {bet_count => $count });
    $ite = $db->search_by_sql_abstract_more(
        +{
            -columns => [qw/count(*)|count/],
            -from    => ['Bet'],
            -where   => +{
                'active'  =>  2 ,
                'user_id' => $user->user_id
            },
            -group_by => ['user_id'],
        }
    );

    if ( my $row = $ite->next ) {
        $count = $row->count;
    }
    else {
        $count = 0;
    }
    $user->update( {win_count => $count} );
    $ite = $db->search_by_sql_abstract_more(
        +{
            -columns => [qw/count(*)|count/],
            -from    => ['Bet'],
            -where   => +{
                'active'  => 1,
                'user_id' => $user->user_id
            },
            -group_by => ['user_id'],
        }
    );
    if ( my $row = $ite->next ) {
        $count = $row->count;
    }
    else {
        $count = 0;
    }
    $user->update( {betting_count => $count} );
}
exit 0;
 