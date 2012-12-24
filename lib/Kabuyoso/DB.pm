package Kabuyoso::DB;
use parent 'Teng';
use String::Random;

__PACKAGE__->load_plugin('SearchBySQLAbstractMore::Pager');

 sub get_key(){
  my $rand_str = String::Random->new->randregex('[A-Za-z0-9]{32}');  return $rand_str;
 }

sub login {
    my $self = shift;
    my $user_id = shift;
    my $password = shift;
    my $row = $self->single('User', {user_id => $user_id});
    if (defined $row && $row->password eq $password) {
        return 1;
    }
    else{
        return 0;
    }
}
1;