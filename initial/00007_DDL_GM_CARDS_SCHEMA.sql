/**** GM_CARDS_SCHEMA ****/

drop table GM_BOARD_CARDS;
drop table GM_GAMEDEF_CARDS;

create table GM_GAMEDEF_CARDS
(
  gamedef_card_code varchar2(10),

  gamedef_code varchar2(10), -- Null to apply for all games
  used_for_class varchar2(20),   -- PLAYER, BOARD, CARD, TURN, PIECE
  used_for_piece_type_code varchar2(20),
  used_for_player varchar2(20), -- 'OWN','NME','ANY'
  
  card_name varchar2(50),
  card_description varchar2(1000),
  card_html varchar2(500),
  
  routine     varchar2(20),
  parameter1  varchar2(20),
  parameter2  varchar2(20),
  parameter3  varchar2(20),
  parameter4  varchar2(20),
  parameter5  varchar2(20),
  
  jquery_code varchar2(1000),
  css_code    varchar2(1000),
  sql_code    varchar2(1000),
  
  constraint gm_gd_cards_pk primary key (gamedef_card_code)
);
/

create table GM_BOARD_CARDS 
(
  game_id number,
  card_id number,
  gamedef_card_code varchar2(10),
  player number,
  parameter1 varchar2(10),
  parameter2 varchar2(10),
  parameter3 varchar2(10),
  parameter4 varchar2(10),
  parameter5 varchar2(10),

  constraint gm_board_cards_pk primary key (game_id, card_id),
  constraint gm_board_cards_player_ct unique(game_id, card_id,player),
  constraint gm_board_cards_carddef_fk foreign key(gamedef_card_code) references GM_GAMEDEF_CARDS(gamedef_card_code)
);
/
