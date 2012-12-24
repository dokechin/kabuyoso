package Kabuyoso::Web::Login;
use Mojo::Base 'Mojolicious::Controller';
use HTML::FillInForm::Lite;    #追加
use FormValidator::Lite qw(Japanese Email);
use utf8;
# This action will render a template
sub index {
    my $self = shift;
    $self->session(expires => 1);
    $self->render();
}
# This action will render a template
sub post {
    my $self = shift;
    my @messages;
    my $validator = FormValidator::Lite->new( $self->req );
    # エラーメッセージを設定
    $validator->set_message(
        'user_id.not_null'      => 'UserID is Empty',
        'user_id.length'        => 'UserID length',
        'user_id.ascii'      => 'UserID is not ascii',
        'password.not_null'    => 'Password is Empty',
        'password.ascii'    => 'Password is not ascii',
    );
    # 入力値チェック
    my $res = $validator->check(
        user_id   => [ qw/NOT_NULL ASCII/, [qw/LENGTH 3 10/] ],
        password => [ qw/NOT_NULL ASCII/,   [qw/LENGTH 6 20/] ],
    );
    # もし入力値が正しくなかったら
    if ( $validator->has_error ) {
        @messages = $validator->get_error_messages;
    }
    else {
        if ($self->app->db->login($self->param('user_id'),$self->param('password')) == 0){
            push @messages, 'login error';
        }
    }
    if (@messages) {
        $self->flash( error_messages => \@messages );
        $self->redirect_to('/login');
    }
    else {
        $self->session("user_id" => $self->param('user_id'));
        $self->redirect_to('/user/' . $self->param('user_id'));
    }
}
1;