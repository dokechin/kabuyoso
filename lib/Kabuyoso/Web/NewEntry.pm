package Kabuyoso::Web::Newentry;
use Mojo::Base 'Mojolicious::Controller';
use HTML::FillInForm::Lite;    #追加
use FormValidator::Lite qw(Japanese Email);
use utf8;
# This action will render a template
sub index {
    my $self = shift;
    $self->render();
}
# This action will render a template
sub confirm {
    my $self = shift;
    $self->render();
}
# This action will render a template
sub complete {
    my $self = shift;
    my $row = $self->app->db->insert("Bet",{"user_id" => $self->session("user_id"),
         stock_code => $self->param("stock_code"),
         start_price => $self->param("start_price"),
         stock_name => $self->param("stock_name"),
         up_or_down => $self->param("up_or_down"),
         require_price => $self->param("require_price"),
         start_date => $self->param("start_date"),
         active => "1"});
   
    $self->render();
}
# This action will render a template
sub post {
    my $self = shift;
    my $stock;
    my $stock_name;
    my $lastPrice;
    my $requirePrice;
    my @messages;
    my $lastEigyobi;
    my $validator = FormValidator::Lite->new( $self->req );
    # エラーメッセージを設定
    $validator->set_message(
        'stock_code.not_null'    => 'Stock Code is Empty',
        'stock_code.uint'    => 'Stock Code is not valid',
        'up_or_down.not_null'    => 'Up or down is Empty',
    );
    # 入力値チェック
    my $res = $validator->check(
        stock_code   => [ qw/NOT_NULL UINT/ ],
        up_or_down   => [qw/NOT_NULL /],
    );
    # もし入力値が正しくなかったら
    if ( $validator->has_error ) {
        @messages = $validator->get_error_messages;
    }
    else {
#        if ($self->app->db->isBacyu() == 0){
#            push @messages, "Now trading date";
#        }
         $lastEigyobi = $self->app->db->getLastEigyobi();
         my $row = $self->app->db->single("Bet",{"user_id" => $self->session("user_id"),
         stock_code => $self->param("stock_code"),
         active => "1"});
         if ( defined $row ){
             push @messages,"既に登録済みです";
         }
         $stock = $self->app->db->single("Stock",{stock_code => $self->param("stock_code")});
         if ( !defined $stock){
             push @messages, "登録されていないコードです。";
         }
        $lastPrice = $self->app->db->getLastPrice($self->param('stock_code'));
        if ($lastPrice < 100){
             push @messages, "lower price";
        }
       
        if ($self->param("up_or_down") == 1){
            $requirePrice = $lastPrice * 1.1;
        }
        else{
            $requirePrice = $lastPrice * 0.9;
        }

    }
    if (@messages) {
        $self->flash( error_messages => \@messages );
        $self->flash( stock_code        => $self->param('stock_code') );
        $self->flash( up_or_down        => $self->param('up_or_down') );
        $self->redirect_to('/new_entry');
    }
    else {
        $self->flash( stock_code        => $self->param('stock_code') );
        $self->flash( start_date        => $lastEigyobi);
        $self->flash( up_or_down        => $self->param('up_or_down') );
        $self->flash( stock_name        => $stock->name );
        $self->flash( start_price       => $lastPrice );
        $self->flash( require_price     => $requirePrice);
        $self->redirect_to('/new_entry/confirm');
    }
}
1;
 