drop table if exists Kabuyoso;
create table  User(
       user_id                      text,
       mail                         text,
       key                          text,
       password                     text,
       yoso_count                   int,
       win_count                    int,
       active                       int,
       create_at                    datetime
);

create table expect (
       user_id                      text,
       stock_code                   text,
       start_price                  int,
       expect_price                 int,
       up_or_down                   text,
       trade_price                  int,
       create_at                    datetime,
       end_at                       date,
       trade_at                     date,
       active                       int);

