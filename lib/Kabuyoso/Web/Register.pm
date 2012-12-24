package Kabuyoso::Web::Register;
use Mojo::Base 'Mojolicious::Controller';
use HTML::FillInForm::Lite;    #追加
use FormValidator::Lite qw(Japanese Email);
use utf8;
# This action will render a template
sub index {
    my $self = shift;
    $self->session(expire=>1);
    $self->session('user'=>'abc');
    $self->render();
}
# This action will render a template
sub complete {
    my $self = shift;
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
        'user_id.ascii'         => 'UserID is not ascii',
        'user_id.length'        => 'UserID length',
        'mail.not_null'         => 'Mail is Empty',
        'mail.email'            => 'Mail address invalid',
        'password1.not_null'    => 'Password1 is Empty',
        'password2.not_null'    => 'Password2 is Empty',
        'password1.length'      => 'Password1 length',
        'password2.length'      => 'Password2 length',
        'password1.ascii'       => 'Password1 is not ascii',
        'password2.ascii'       => 'Password2 is not ascii',
        'passwords.duplication' => 'passwords not same',
    );
    # 入力値チェック
    my $res = $validator->check(
        user_id   => [ qw/NOT_NULL ASCII/, [qw/LENGTH 3 10/] ],
        mail      => [qw/NOT_NULL EMAIL/],
        password1 => [ qw/NOT_NULL ASCII/, [qw/LENGTH 6 20/] ],
        password2 => [ qw/NOT_NULL ASCII/, [qw/LENGTH 6 20/] ],
        { passwords => [qw/password1 password2/] } => ['DUPLICATION'],
    );
    # もし入力値が正しくなかったら
    if ( $validator->has_error ) {
        @messages = $validator->get_error_messages;
    }
    else {
        my $ite = $self->app->db->search( "User",
            { "user_id" => $self->param('user_id') } );
        if ( $ite->next ) {
            push @messages, 'user_id is already registered';
        }
        $ite =
          $self->app->db->search( "User",
            { mail => $self->param('mail'), active => 1 } );
        if ( $ite->next ) {
            push @messages, 'mail is already registered';
        }
    }
    if (@messages) {
        $self->flash( error_messages => \@messages );
        $self->flash( user_id        => $self->param('user_id') );
        $self->flash( password1      => $self->param('password1') );
        $self->flash( password2      => $self->param('password2') );
        $self->flash( mail           => $self->param('mail') );
        $self->redirect_to('/register');
    }
    else {
        my $key = $self->app->db->get_key();
        $self->app->db->insert(
            'User',
            {
                user_id  => $self->param('user_id'),
                mail     => $self->param('mail'),
                password => $self->param('password1'),
                key      => $key,
                active   => 0,
            }
        );
        #mail send
        $self->flash(
            message => "メール送信しました http://localhost:3000/confirm?key="
              . $key );
        $self->redirect_to('/register/complete');
    }
}
1;