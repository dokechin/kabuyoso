use Mojo::Server::PSGI;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Kabuyoso::Web;
use Plack::Builder;
use Plack::Builder::Conditionals;
my $web = Kabuya::Web->new();
my $server = Mojo::Server::PSGI->new(app => $web);
my $app = sub {
    $server->run(@_);
};
builder {
      enable match_if addr(['192.168.0.0/24','127.0.0.1']),
          "Plack::Middleware::ReverseProxy";
      $app;
};