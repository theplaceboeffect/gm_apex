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
create or replace view gm_board_piece_locs_view as
  with individual_pieces as (
    select game_id, player, piece_type_code, listagg('loc-' || xpos||'-'||ypos,':') within group(order by xpos) board_locations
    from gm_board_pieces P 
    where status=1 and P.piece_type_code not in ('KING')
    group by game_id, player, piece_type_code
  ),
  own_players_pieces as (
    select game_id, player, 'OWN' piece_type_code, listagg('loc-' || xpos||'-'||ypos,':') within group(order by xpos) board_locations
    from gm_board_pieces P
    where status=1 and P.piece_type_code not in ('KING')
    group by game_id, player
  ),
  any_players_pieces as (
    select game_id, 0 player, 'ANY' piece_type_code, listagg(board_locations,':') within group(order by game_id) board_locations
    from individual_pieces
    group by game_id
  )
  select game_id, player, piece_type_code, board_locations
  from individual_pieces
  union all
  select game_id, player, piece_type_code, board_locations
  from own_players_pieces
  union all
  select game_id, player, piece_type_code, board_locations
  from any_players_pieces;
/

create or replace view gm_board_cards_view as
  select C.gamedef_card_code, C.card_id, C.player, C.game_id, CD.used_for_class, CD.used_for_piece_type_code, CD.card_name, CD.card_description,
          '<div class="card-location" id="card-loc-' || C.card_id || '">' || 
          ' <div class="card" type="card" id="card-' || C.card_id || '"'
          || ' positions="' || L.board_locations || '"'
          || '>' || CD.gamedef_card_code
          || '</div></div>' value,
          CD.card_name label
from gm_board_cards C
left join gm_gamedef_cards CD on C.gamedef_card_code = CD.gamedef_card_code
left join gm_board_piece_locs_view L on 
  C.game_id = L.game_id
  -- Logic to handle whether we are choosing ANY piece on the board, our OWN piece's or the opponent's (NME's)
  and case when CD.used_for_piece_type_code='ANY' and CD.used_for_player != 'ANY' then 'OWN' 
            else CD.used_for_piece_type_code end 
            = L.piece_type_code 
  and decode(CD.used_for_player, 'ANY', 0, 'OWN', C.player, 'NME', 3-C.player) = L.player
where C.player > 0
;
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
    -- TODO: Verify that the piece being replaced matches the card used_for_piece_type_code
  
    -- Retrieve the piece to apply the card onto
    select P.piece_id into v_piece_id
    from gm_board_pieces P
    where P.xpos = p_xpos and P.ypos = p_ypos and P.game_id = p_game_id;

    -- Apply card.    
    update gm_board_pieces P
    set p.piece_type_code = card_def.parameter1
    where P.piece_id = v_piece_id;
  
    -- Consume card.
    update gm_board_cards C
    set player = 0
    where C.game_id = p_game_id and C.card_id = v_card_id;
  
    -- Record card use.
    insert into gm_game_history(game_id,  piece_id, player, old_xpos, old_ypos, new_xpos, new_ypos)
                           values(p_game_id, v_piece_id, v_player , p_xpos, p_ypos, 0, 0);
  end if;

end;
/
delete from gm_gamedef_cards;
delete from gm_board_cards;
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine) 
                      values('OP2B', 'CHESS%', 'PIECE','PAWN', 'OWN', 'Pawn To Bishop', 'Change one of your Pawns into a Bishop.', 'BISHOP', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                      values('OP2N', 'CHESS%', 'PIECE','PAWN', 'OWN', 'Pawn To Knight', 'Change one of your Pawns into a Knight.', 'KNIGHT', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                      values('OP2R', 'CHESS%', 'PIECE','PAWN', 'OWN', 'Pawn To Rook', 'Change one of your Pawns into a Rook.', 'ROOK', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                      values('OP2Q', 'CHESS%', 'PIECE','PAWN', 'OWN', 'Pawn To Queen', 'Change one of your Pawns into a Queen.', 'QUEEN', 'REPLACE');

insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                      values('OA2P', 'CHESS%', 'PIECE','ANY', 'OWN', 'Any To Pawn', 'Change any of your own pieces into a pawn.', 'PAWN', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                      values('OA2Q', 'CHESS%', 'PIECE','ANY', 'OWN', 'Any To Queen', 'Change any of your own pieces into a queen.', 'QUEEN', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                      values('OB2Q', 'CHESS%', 'PIECE','BISHOP', 'OWN', 'Any Bishop To Knight', 'Change any of your own bishops into a knight.', 'KNIGHT', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                      values('NA2P', 'CHESS%', 'PIECE','ANY', 'NME', 'Any To Pawn', 'Change any of your opponent''s piece into a pawn.', 'PAWN', 'REPLACE');
insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                      values('AA2P', 'CHESS%', 'PIECE','ANY', 'ANY', 'Any To Pawn', 'Change any piece into a pawn.', 'PAWN', 'REPLACE');

insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 1, 1, 'OP2B');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 2, 1, 'OP2N');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 3, 1, 'OP2R');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 4, 1, 'OP2Q');

insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 5, 1, 'OA2P');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 6, 1, 'OA2P');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 7, 1, 'NA2P');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 8, 1, 'OA2Q');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 16, 1, 'OB2Q');

insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 9, 2, 'OA2P');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 10, 2, 'OA2Q');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 11, 2, 'OB2Q');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 12, 2, 'NA2P');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 13, 2, 'AA2P');

insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 14, 0, 'OP2R');
insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(3, 15, 0, 'OP2R');
commit;
/
