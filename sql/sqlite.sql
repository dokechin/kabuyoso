drop table if exists Kabuyoso;
create table  User(
       user_id                      text,
       mail                         text,
       key                          text,
       password                     text,
       bet_count                    int,
       win_count                    int,
       betting_count                int,
       active                       int, -- 0:inactive 1:active 2:blacklist
       create_at                    datetime
);
create table Stock(
       stock_code                   text,
       name                         text);
create table Bet (
       user_id                      text,
       stock_code                   text,
       stock_name                   text,
       start_date                   date,
       start_price                  int,
       require_price                int,
       up_or_down                   text,
       win_price                    int,
       win_date                     date,
       create_at                    datetime,
       limit_date                   date,
       active                       int); -- 1:active 2:fail 3:success
 