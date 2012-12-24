package Kabuyoso::Web::Confirm;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;       # 追加
use HTML::FillInForm::Lite;    #追加
use utf8;
# This action will render a template
sub index {
    my $self = shift;
    my $ite =
      $self->app->db->search( "User", { "key" => $self->param('key') } );
    my $row = $ite->next;
    if ($row) {
        printf( "%s\n", $row->user_id );
        printf( "%s\n", $row->key );
        $self->stash( "key"     => $self->param("key") );
        $self->stash( "user_id" => $row->user_id );
        $self->render();
    }
}
sub complete {
    my $self = shift;
    $self->render();
}
# This action will render a template
sub post {
    my $self = shift;
    my @messages;
    my $row;
    my $validator = FormValidator::Lite->new( $self->req );
    # エラーメッセージを設定
    $validator->set_message(
        'user_id.not_null' => 'UserID is Empty',
        'key.not_null'     => 'key is Empty',
    );
    # 入力値チェック
    my $res = $validator->check(
        user_id => [qw/NOT_NULL/],
        key     => [qw/NOT_NULL/],
    );
    # もし入力値が正しくなかったら
    if ( $validator->has_error ) {
        @messages = $validator->get_error_messages;
    }
    else {
        $row = $self->app->db->single( "User",
            { "user_id" => $self->param('user_id') } );
        if ( $self->param("key") ne $row->key ) {
            push( @messages, 'key is invalid' );
        }
        if ( $row->active ne "0" ) {
            push( @messages, 'already active user' );
        }
    }
    if (@messages) {
        my $msg = '';
        for my $temp (@messages) {
            $msg = $msg . $temp;
        }
        $self->flash( message => $msg . "不正なアクセスです" );
        $self->redirect_to('/confirm/complete');
    }
    else {
        $row->update( { active => 1 } );
        $self->flash( message => $self->param('user_id')
              . "さんのユーザ登録が完了しました" );
        $self->redirect_to('/confirm/complete');
    }
}
1;