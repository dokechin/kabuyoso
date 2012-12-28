package Kabuyoso::DB::Schema;
use Teng::Schema::Declare;
table {
    name 'User';
    columns qw( user_id mail key password bet_count win_count betting_count active create_at datetime);
};
table {
    name 'Stock';
    columns qw( stock_code name);
};
table {
    name 'Bet';
    columns qw( user_id stock_code start_date start_price require_price up_or_down win_price win_date create_at limit_date active);
};
1;