/**** GM_CARDS_SCHEMA ****/

drop table GM_BOARD_CARDS;
drop table GM_GAMEDEF_CARDS;

create table GM_GAMEDEF_CARDS
(
  gamedef_card_code varchar2(10),

  gamedef_code varchar2(10), -- Null to apply for all games
  used_for_class varchar2(10),   -- PLAYER, BOARD, CARD, TURN, PIECE
  used_for_detail varchar2(10),
  
  card_name varchar2(50),
  card_description varchar2(1000),
  
  routine     varchar2(10),
  parameter1  varchar2(10),
  parameter2  varchar2(10),
  parameter3  varchar2(10),
  parameter4  varchar2(10),
  parameter5  varchar2(10),
  
  jquery_code varchar2(1000),
  css_code    varchar2(1000),
  sql_code    varchar2(1000),
  
  constraint gm_gd_cards_pk primary key (gamedef_card_code)
  --constraint gm_gd_cards_game_fk foreign key(gamedef_code) references gm_gamedef_boards(gamedef_code)

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

  constraint gm_board_cards_pk primary key (game_id, card_id,gamedef_card_code,player),
  constraint gm_board_cards_game_fk foreign key(gamedef_card_code) references GM_GAMEDEF_CARDS(gamedef_card_code)
);
/
              
create or replace view gm_board_cards_view as
  select C.gamedef_card_code, C.card_id, C.player, C.game_id, CD.used_for_class, CD.used_for_detail, CD.card_name, CD.card_description,
          '<div class="card-location" id="card-loc-' || C.card_id || '">' || 
          ' <div class="card" type="card" id="card-' || C.card_id || '"'
          || '" positions="' || (select listagg('loc-' || xpos||'-'||ypos,':') within group(order by xpos)
              from gm_board_pieces P
              where piece_type_code=CD.used_for_detail and P.game_id = C.game_id and P.player= C.player and status=1
              ) || '"'
          || '">' || CD.gamedef_card_code
          || '</div></div>' value,
          CD.card_name label
  from gm_board_cards C
  join gm_gamedef_cards CD on C.gamedef_card_code = CD.gamedef_card_code
/
select * from l;
exec process_card(2,'card-2',7,2);
select * from gm_board_pieces where xpos=7 and ypos=2;
/
create or replace procedure process_card(p_game_id number, p_piece_id varchar2, p_xpos number, p_ypos number)
as
  v_card_id number;
  v_piece_id number;
  v_player number;
  card_def gm_gamedef_cards%rowtype;
  piece gm_board_pieces%rowtype;
begin 

  v_card_id := replace(p_piece_id,'card-','');

  log_message('Processing card: [game_id=' || p_game_id || '][piece_id=' || p_piece_id || '][' || p_xpos || ',' || p_ypos || '][v_card_id=' || v_card_id || ']');

  -- Get card definition.
  select D.* into card_def
  from gm_board_cards C
  join gm_gamedef_cards D on C.gamedef_card_code = D.gamedef_card_code
  where C.game_id = p_game_id and C.card_id = v_card_id;
  select C.player into v_player from gm_board_cards C where C.game_id = p_game_id and C.card_id = v_card_id;

  if card_def.routine = 'REPLACE' then
    -- Retrieve the piece to apply the card onto
    select P.piece_id into v_piece_id
    from gm_board_pieces P
    where P.xpos = p_xpos and P.ypos = p_ypos and P.game_id = p_game_id;
    
    update gm_board_pieces P
    set p.piece_type_code = card_def.parameter1
    where P.piece_id = v_piece_id;
  
    -- Consume card.
    update gm_board_cards C
    set player = 0
    where C.game_id = p_game_id and C.card_id = v_card_id;
  
    insert into gm_game_history(game_id,  piece_id, player, old_xpos, old_ypos, new_xpos, new_ypos)
                           values(p_game_id, v_piece_id, v_player , p_xpos, p_ypos, 0, 0);

  end if;

end;
/
/
delete from gm_board_cards;
delete from gm_gamedef_cards;
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_detail, card_name, card_description, parameter1, routine) 
                      values('P2B', 'CHESS%', 'PIECE','PAWN', 'Pawn To Bishop', 'Change one of your Pawns into a Bishop.', 'BISHOP', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_detail, card_name, card_description, parameter1, routine)
                      values('P2N', 'CHESS%', 'PIECE','PAWN', 'Pawn To Knight', 'Change one of your Pawns into a Knight.', 'KNIGHT', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_detail, card_name, card_description, parameter1, routine)
                      values('P2R', 'CHESS%', 'PIECE','PAWN', 'Pawn To Rook', 'Change one of your Pawns into a Rook.', 'ROOK', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_detail, card_name, card_description, parameter1, routine)
                      values('P2Q', 'CHESS%', 'PIECE','PAWN', 'Pawn To Queen', 'Change one of your Pawns into a Queen.', 'QUEEN', 'REPLACE');

insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 1, 1, 'P2B');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 2, 1, 'P2N');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 3, 1, 'P2R');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 4, 1, 'P2Q');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 5, 1, 'P2B');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 6, 2, 'P2B');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 7, 2, 'P2B');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 8, 2, 'P2N');

insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 9, 0, 'P2R');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 10, 0, 'P2R');
commit;
/
