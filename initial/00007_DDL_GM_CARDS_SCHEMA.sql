
drop table GM_BOARD_CARDS;
drop table GM_GAMEDEF_CARDS;

create table GM_GAMEDEF_CARDS
(
  gamedef_card_code varchar2(10),

  gamedef_code varchar2(8), -- Null to apply for all games
  used_for_class varchar2(10),   -- PLAYER, BOARD, CARD, TURN, PIECE
  used_for_detail varchar2(10),
  
  card_name varchar2(50),
  card_description varchar2(1000),
  
  parameter1 varchar2(10),
  parameter2 varchar2(10),
  parameter3 varchar2(10),
  parameter4 varchar2(10),
  parameter5 varchar2(10),
  
  constraint gm_gd_cards_pk primary key (gamedef_card_code)
  --constraint gm_gd_cards_game_fk foreign key(gamedef_code) references gm_gamedef_boards(gamedef_code)

);
/
create table GM_BOARD_CARDS 
(
  game_id number,
  card_id number,
  gamedef_card_code varchar2(5),
  player number,
  parameter1 varchar2(10),
  parameter2 varchar2(10),
  parameter3 varchar2(10),
  parameter4 varchar2(10),
  parameter5 varchar2(10),

  constraint gm_board_cards_pk primary key (game_id, card_id),
  constraint gm_board_cards_game_fk foreign key(gamedef_card_code) references GM_GAMEDEF_CARDS(gamedef_card_code)
);
/
create or replace view gm_board_cards_view as
  select C.gamedef_card_code, C.card_id, C.player, C.game_id, CD.used_for_class, CD.used_for_detail, CD.card_name, CD.card_description,
          '<id="' || C.card_id || '" type="card"> ' || CD.gamedef_card_code || '</b>' value,
          CD.card_name label
  from gm_board_cards C
  join gm_gamedef_cards CD on C.gamedef_card_code = CD.gamedef_card_code

/
select * from gm_board_cards_view;
/
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_detail, card_name, card_description) values('PAWN1', 'CHESS%', 'PIECE','PAWN', 'Pawn 2 Steps', 'Your pawns can move up to two squares.');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_detail, card_name, card_description) values('PAWN2', 'CHESS%', 'PIECE','PAWN', 'Pawn 2 Steps', 'Your pawns can move up to two squares.');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_detail, card_name, card_description) values('PAWN3', 'CHESS%', 'PIECE','PAWN', 'Pawn 2 Steps', 'Your pawns can move up to two squares.');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_detail, card_name, card_description) values('PAWN4', 'CHESS%', 'PIECE','PAWN', 'Pawn 2 Steps', 'Your pawns can move up to two squares.');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 1, 1, 'PAWN1');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 2, 1, 'PAWN2');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 3, 1, 'PAWN2');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 4, 1, 'PAWN2');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 5, 1, 'PAWN2');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 6, 1, 'PAWN2');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 7, 1, 'PAWN2');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 8, 2, 'PAWN3');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 9, null, 'PAWN4');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(7, 10, null, 'PAWN5');

commit;

select * from gm_board_cards where game_id=7 and player=1;
