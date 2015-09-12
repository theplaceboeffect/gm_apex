

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
  ),
  board_rows as (
    select to_number(nvl(v('P1_GAME_ID'),0)) game_id, rownum r 
    from gm_board_pieces P 
    where rownum <=  nvl( (select B.max_cols from gm_boards B where B.game_id=v('P1_GAME_ID')),8)
  ),
  board_cols as (
    select nvl(v('P1_GAME_ID'),0) game_id, rownum c 
    from gm_board_pieces P 
    where rownum <=  nvl( (select B.max_rows from gm_boards B where B.game_id=v('P1_GAME_ID')),8)
  ),
  empty_squares as (
    select BR.game_id, 'loc-' || bc.c || '-' || br.r board_location 
    from board_rows BR cross join board_cols BC 
    where (c,r) not in (select xpos,ypos from gm_board_pieces where game_id=v('P1_GAME_ID') and status>0)
  )

  select game_id, 0 player, 'EMPTY' piece_type_code, listagg(board_location,':') within group(order by board_location) board_locations 
  from empty_squares
  group by game_id
  union all
  select game_id, player, piece_type_code, board_locations
  from individual_pieces 
  union all
  select game_id, player, piece_type_code, board_locations
  from own_players_pieces
  union all
  select game_id, player, piece_type_code, board_locations
  from any_players_pieces
  ;
/
create or replace view gm_board_cards_view as
  select C.gamedef_card_code, C.card_id, C.player, C.game_id, CD.used_for_class, CD.used_for_piece_type_code, CD.card_name, CD.card_description,
          '<div class="card-location" id="card-loc-' || C.card_id || '">' || 
          ' <div class="card" type="card" id="card-' || C.card_id || '"'
          || ' player="' || C.player || '"'
          || ' card-action="' || CD.routine || '"'
          || ' positions="' || L.board_locations || '"'
          || '>'
          || case 
          
             when CD.gamedef_card_code='RMSQ' then
              '<i class="fa fa-lock fa-3x"></i>' || CD.card_description
             when CD.gamedef_card_code='MKSQ' then
              '<i class="fa fa-square-o fa-3x"/></i>' || ' ' ||  CD.card_description

            when CD.routine = 'REPLACE' then
              '<table><tr>'
              || '<td><div class="card-piece" player=' || decode(CD.used_for_player, 'OWN', C.player, 'NME', 3-C.player, 'ANY', 0) 
              || ' piece-name="' || lower(CD.used_for_piece_type_code) ||'" ></div></td>'
              || '<td>' || CD.gamedef_card_code || '</td>'
              || case when CD.used_for_player = 'ANY' then
                        '<td><div class="card-piece" player=' || 2 || ' piece-name="'|| lower(CD.parameter1) || '" ></div>'
                        ||'<div " class="card-piece" player=' || 1 || ' piece-name="'|| lower(CD.parameter1) || '" ></div></td>'
                  else
                      '<td><div class="card-piece" player=' || decode(CD.used_for_player, 'OWN', C.player, 'NME', 3-C.player, 'ANY', 0) 
                      || ' piece-name="'|| lower(CD.parameter1) || '" ></div></td>'
                  end
              || '</tr></table>'
            else
              CD.gamedef_card_code
            end
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
  and decode(CD.used_for_player, 'ANY', 0, 'OWN', C.player, 'NME', 3-C.player,'NONE', 0, 'SYS', 3) = L.player
where C.player > 0
;
/
