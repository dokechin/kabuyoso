package Kabuyoso::DB;
use parent 'Teng';
use String::Random;
use Calendar::Japanese::Holiday;
use Time::Local;
use Finance::YahooJPN::Quote


__PACKAGE__->load_plugin('SearchBySQLAbstractMore');

sub get_key() {
    my $rand_str = String::Random->new->randregex('[A-Za-z0-9]{32}');
    return $rand_str;
}

sub login {
    my $self     = shift;
    my $user_id  = shift;
    my $password = shift;
    my $row      = $self->single( 'User', { user_id => $user_id } );
    if ( defined $row && $row->password eq $password ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub isBacyu {

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    $year += 1900;
    $mon  += 1;

    if (   ( $wday == 0 || $wday == 6 )
        || ( $mon == 1 && ( $mday == 1 || $mday == 2 || $daymday== 3 ) )
        || ( $mon == 12 && $mday == 31 ) )
    {
        return undef;
    }

    if ( isHoliday( $year, $mon, $mday, 1 ) ) {
        return undef;
    }
    else {
        if ( $hour < 8){
            return -1;
        }
        if ( 8 <= $hour  && $hour <= 16  ) {
            return 0;
        }
        else{
            return 1;
        }

    }
}

sub isEigyobi {

    my $self = shift;

    my $year  = shift;
    my $mon = shift;
    my $mday = shift;

    my $time = timelocal(0,0,0,$mday,$mon-1,$year-1900);
    my $wday = (localtime($time))[6];

    if (   ( $wday == 0 || $wday == 6 )
        || ( $mon == 1 && ( $mday == 1 || $mday == 2 || $daymday== 3 ) )
        || ( $mon == 12 && $mday == 31 ) )
    {
        return 0;
    }


    if ( isHoliday( $year, $mon, $mday, 1 ) ) {
        return 0;
    }
    else {
        return 1;
    }
}

sub getLastEigyobi {
    my $self = shift;
   
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    my $time = timelocal(0,0,0,$mday,$mon,$year);

    my $bacyu = isBacyu();

    if ( defined $bacyu && $bacyu == 1){
        return sprintf "%04d-%02d-%02d", $year, $mon ,$mday;
    }

    $time = $time - 86400;
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime($time);

    while(isEigyobi(  $self, $year+1900,$mon + 1,$mday) == 0){
        $time = $time - 86400;
       ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime($time);
    }
    return sprintf "%04d-%02d-%02d", $year + 1900, $mon + 1,$mday;   
   
}

sub getNextEigyobi {

    my $self = shift;

    my $year  = shift;
    my $mon = shift;
    my $mday = shift;

    if (isEigyobi($self,$year,$mon,$mday)){
        return sprintf "%04d-%02d-%02d", $year , $mon ,$mday;
    }

    my $time = timelocal(0,0,0,$mday,$mon-1,$year-1900);

    $time = $time + 86400;
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime($time);

    while(isEigyobi(  $self, $year+1900,$mon + 1,$mday) == 0){
        $time = $time + 86400;
       ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime($time);
    }
    return sprintf "%04d-%02d-%02d", $year + 1900, $mon + 1,$mday;   

}

sub getLastPrice {

    my $self = shift;
    my $code = shift;
   
    my $last_eigyobi = getLastEigyobi($self);

#   my @quote = Finance::YahooJPN::Quote->historical($code );


    return 123;

}


1;