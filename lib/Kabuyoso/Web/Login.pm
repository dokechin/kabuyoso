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
        'user_id.not_null'      => 'ユーザＩＤが入力されていません。',
        'password.not_null'    => 'パスワードが入力されていません。',
    );
    # 入力値チェック
    my $res = $validator->check(
        user_id   => [ qw/NOT_NULL/ ],
        password => [ qw/NOT_NULL/ ],
    );
    # もし入力値が正しくなかったら
    if ( $validator->has_error ) {
        @messages = $validator->get_error_messages;
    }
    else {
        if ($self->app->db->login($self->param('user_id'),$self->param('password')) == 0){
            push @messages, 'ログインエラーです。';
        }
    }
    if (@messages) {
        $self->flash( error_messages => \@messages );
        $self->redirect_to('/login');
    }
    else {
        $self->session("user_id" => $self->param('user_id'));
        $self->redirect_to('/new_entry');
    }
}
1;