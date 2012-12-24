package Kabuyoso::DB::Schema;
use Teng::Schema::Declare;
table {
    name 'User';
    columns qw( user_id mail key password yoso_count win_count active create_at datetime);
};
1;