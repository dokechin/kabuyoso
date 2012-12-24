package Kabuyoso::Web;
use Mojo::Base 'Mojolicious';
use Kabuyoso::DB;
# This method will run once at server start
sub startup {
  my $self = shift;
  # Documentation browser under "/perldoc"
#  $self->plugin('PODRenderer');
  $self->plugin('page_navigator');
  my $config = $self->plugin('Config', { file => 'kabuyoso_web.conf' }); # ’Ç‰Á
  $self->attr( db => sub { Kabuyoso::DB->new( $config->{db} ) } ); # ’Ç‰Á
  # Router
  my $r = $self->routes;
  # Normal route to controller
  $r->get('/')->to('root#index');
  $r->post('/')->to('root#post');
  $r->get('/register')->to('register#index');
  $r->post('/register')->to('register#post');
  $r->get('/register/complete')->to('register#complete');
  $r->get('/confirm')->to('confirm#index');
  $r->post('/confirm')->to('confirm#post');
  $r->get('/confirm/complete')->to('confirm#complete');
  $r->get('/new_entry')->to('newentry#index');
  $r->post('/new_entry')->to('newentry#post');
  $r->get('/new_entry/complete')->to('newentry#complete');
  $r->get('/login')->to('login#index');
  $r->post('/login')->to('login#post');
}
1;