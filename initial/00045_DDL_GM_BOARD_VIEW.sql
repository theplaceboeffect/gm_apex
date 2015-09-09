/**** GENERAL CSS ****/

delete from gm_css;
/
insert into gm_css(css_id, css_selector, css_declaration_block) values (110, '[type="card"]','{ background-color:yellow; height:45px; width:130px; }');
insert into gm_css(css_id, css_selector, css_declaration_block) values (120, '.card[card-action="REPLACE"]', '{align: center; background-color: #E7D0DB;color: #85144b;font-weight: bold;border-radius: 10px;border: solid 2px;border-color: #85144b; height:45px; width:130px; text-align: center; }');
insert into gm_css(css_id, css_selector, css_declaration_block) values (121, '.card[card-action="BOARD_CHANGE"]', '{background-color: #808F9F; color:#001f3f ;font-weight: bold;border-radius: 10px;border: solid 2px;border-color: #001f3f; height:45px; width:130px; text-align: center; }');
insert into gm_css(css_id, css_selector, css_declaration_block) values (129, '.card-location', '{ background-color:white; height:45px; width:130px; border: 0px }'); 
insert into gm_css(css_id, css_selector, css_declaration_block) values (130, '.history-piece','{height:25px; width:25px; background-size:25px 25px;}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (131, '.card-piece','{height:35px; width:35px; background-size:35px 35px;}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (140, '.card-piece[player="1"][piece-name="any"]', '{background-image: url("https://upload.wikimedia.org/wikipedia/commons/6/65/White_Stars_1.svg");}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (141, '.card-piece[player="2"][piece-name="any"]', '{background-image: url("https://upload.wikimedia.org/wikipedia/commons/c/c8/Black_Star.svg");}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (142, '.card-piece[player="0"][piece-name="any"]', '{background-image: url("https://upload.wikimedia.org/wikipedia/commons/1/17/Yin_yang.svg");}');
commit;
/

/**** GM_BOARD_VIEW ****/
CREATE OR REPLACE FORCE VIEW gm_board_view as
  with pieces as (
        select  P.game_id ,
                P.piece_type_code ,
                P.piece_id ,
                P.xpos ,
                P.ypos ,
                P.player ,
                P.status ,
                T.piece_name
        from gm_board_pieces P
        join gm_piece_types T on P.piece_type_code = T.piece_type_code and P.game_id = T.game_id and P.status <> 0
      )
      , occupied_rows as (
        select distinct R.game_id, R.ypos
        from gm_board_pieces R
      )
      ,board as (
        select R.game_id, R.ypos ypos, 
           gm_piece_lib.format_piece(R.game_id, X1.piece_id, X1.player, X1.piece_name, 1, R.ypos) cell_1,
           gm_piece_lib.format_piece(R.game_id, X2.piece_id, X2.player, X2.piece_name, 2, R.ypos) cell_2,
           gm_piece_lib.format_piece(R.game_id, X3.piece_id, X3.player, X3.piece_name, 3, R.ypos) cell_3,
           gm_piece_lib.format_piece(R.game_id, X4.piece_id, X4.player, X4.piece_name, 4, R.ypos) cell_4,
           gm_piece_lib.format_piece(R.game_id, X5.piece_id, X5.player, X5.piece_name, 5, R.ypos) cell_5,
           gm_piece_lib.format_piece(R.game_id, X6.piece_id, X6.player, X6.piece_name, 6, R.ypos) cell_6,
           gm_piece_lib.format_piece(R.game_id, X7.piece_id, X7.player, X7.piece_name, 7, R.ypos) cell_7,
           gm_piece_lib.format_piece(R.game_id, X8.piece_id, X8.player, X8.piece_name, 8, R.ypos) cell_8
        from occupied_rows R
          left join pieces X1 on R.game_id = X1.game_id and X1.xpos=1 and R.ypos = X1.ypos and X1.status <> 0
          left join pieces X2 on R.game_id = X2.game_id and X2.xpos=2 and R.ypos = X2.ypos and X2.status <> 0
          left join pieces X3 on R.game_id = X3.game_id and X3.xpos=3 and R.ypos = X3.ypos and X3.status <> 0
          left join pieces X4 on R.game_id = X4.game_id and X4.xpos=4 and R.ypos = X4.ypos and X4.status <> 0
          left join pieces X5 on R.game_id = X5.game_id and X5.xpos=5 and R.ypos = X5.ypos and X5.status <> 0
          left join pieces X6 on R.game_id = X6.game_id and X6.xpos=6 and R.ypos = X6.ypos and X6.status <> 0
          left join pieces X7 on R.game_id = X7.game_id and X7.xpos=7 and R.ypos = X7.ypos and X7.status <> 0
          left join pieces X8 on R.game_id = X8.game_id and X8.xpos=8 and R.ypos = X8.ypos and X8.status <> 0
        
    )
    select
      B.game_id ,
      S.ypos,
      '<div id="loc-1-' || S.ypos  || '" class="board-location" xpos=1 ypos=' || S.ypos ||  ' location=1.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_1  || '">' || p.cell_1 || '</div>' cell_1 ,
      '<div id="loc-2-' || S.ypos  || '" class="board-location" xpos=2 ypos=' || S.ypos ||  ' location=2.' || S.ypos  ||  ' type="' || B.board_type || '-' || S.cell_2  || '">' || p.cell_2 || '</div>' cell_2 ,
      '<div id="loc-3-' || S.ypos  || '" class="board-location" xpos=3 ypos=' || S.ypos ||  ' location=3.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_3  || '">' || p.cell_3 || '</div>' cell_3 ,
      '<div id="loc-4-' || S.ypos  || '" class="board-location" xpos=4 ypos=' || S.ypos ||  ' location=4.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_4  || '">' || p.cell_4 || '</div>' cell_4 ,
      '<div id="loc-5-' || S.ypos  || '" class="board-location" xpos=5 ypos=' || S.ypos ||  ' location=5.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_5  || '">' || p.cell_5 || '</div>' cell_5 ,
      '<div id="loc-6-' || S.ypos  || '" class="board-location" xpos=6 ypos=' || S.ypos ||  ' location=6.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_6  || '">' || p.cell_6 || '</div>' cell_6 ,
      '<div id="loc-7-' || S.ypos  || '" class="board-location" xpos=7 ypos=' || S.ypos ||  ' location=7.' || S.ypos  ||  ' type="' || B.board_type || '-' || S.cell_7  || '">' || p.cell_7 || '</div>' cell_7 ,
      '<div id="loc-8-' || S.ypos  || '" class="board-location" xpos=8 ypos=' || S.ypos ||  ' location=8.' || S.ypos  ||  ' type="' || B.board_type || '-' || S.cell_8  || '">' || p.cell_8 || '</div>' cell_8 ,
      '<div id="loc-9-' || S.ypos  || '" class="board-location" xpos=9 ypos=' || S.ypos ||  ' location=9.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_9  || '">' || '' || '</div>' cell_9 ,
      '<div id="loc-10-' || S.ypos || '" class="board-location" xpos=10 ypos=' || S.ypos || ' location=10.' || S.ypos || ' type="' || B.board_type || '-' || S.cell_10 || '">' || '' || '</div>' cell_10 ,
      '<div id="loc-12-' || S.ypos || '" class="board-location" xpos=11 ypos=' || S.ypos || ' location=11.' || S.ypos || ' type="' || B.board_type || '-' || S.cell_11 || '">' || '' || '</div>' cell_11 ,
      '<div id="loc-11-' || S.ypos || '" class="board-location" xpos=12 ypos=' || S.ypos || ' location=12.' || S.ypos || ' type="' || B.board_type || '-' || S.cell_12 || '">' || '' || '</div>' cell_12
    from gm_board_states S
    join gm_boards B on S.game_id = B.game_id
    left join board P on S.game_id = P.game_id and S.ypos = P.ypos and S.game_id=P.game_id
    ;
/
create or replace view gm_board_css as
  select css, display_order 
  from (
    -- start CSS
    select '<style type="text/css">' css, -100000 display_order from dual
    union all
    select '[summary="???"] {}' css, 0 display_order from dual
    union all
    -- Board CSS
    select '[summary="GameBoard"] td {    padding: 0px 0px 0px 0px;}' css, 10 display_order from dual
    union all
    select '.board-location {  position: relative; height:' || v('P1_SQUARE_SIZE') || 'px;  width:' || v('P1_SQUARE_SIZE') || 'px;}' css, 10 display_order from dual
    union all
    select '.game-piece {height:' || v('P1_SQUARE_SIZE') || 'px;width:' || v('P1_SQUARE_SIZE') || 'px;background-size: ' || v('P1_SQUARE_SIZE') || 'px ' || v('P1_SQUARE_SIZE') || 'px;}' css, 10 display_order from dual
    union all
    select css_selector || css_declaration_block,css_id display_order from gm_css 
    union all
    -- GameDef CSS
    select css_selector || ' ' || css_definition board_css, css_order display_order
    from gm_gamedef_css where gamedef_code=(select board_type from gm_boards where game_id=v('P1_GAME_ID'))
    union all
    -- end CSS
    select '</style>' css, 100000 display_order from dual
    
  )
  order by display_order
  ;
/
create or replace view gm_board_history_view as
  with history as (
    select H.history_id
            , H.game_id
            --, H.piece_id
            , '<table>' ||
              '<tr>' ||
              --'<td rowspan=2><b>' || H.history_id || '</b></td>' ||
              -- show what happened
                case 
                when action='MOVE' then 
                  '<td><div class="history-piece" id="Hpiece-' || H.piece_id || '" player="' || P.player || '" piece-name="' || lower(P.piece_type_code) || '"</div></td>' ||
                  '<td>' || chr(96 + H.old_xpos)|| H.old_ypos || '-' || chr(96 + H.new_xpos) || H.new_ypos || '</td>'
                when action='CAPTURE' then 
                  '<td><div class="history-piece" id="Hpiece-' || H.piece_id || '" player="' || P.player || '" piece-name="' || lower(P.piece_type_code) || '"</div></td>' ||
                  '<td>' || chr(96 + H.old_xpos)|| H.old_ypos || 'x' || chr(96 + H.new_xpos) || H.new_ypos ||
                  '<td><div class="history-piece" id="Hpiece-' || H.action_piece || '" player="' || AP.player || '" piece-name="' || lower(AP.piece_type_code) || '"</div></td>'
                when action='CARD' then 
                  '<td><div class="history-piece" id="Hpiece-' || H.piece_id || '" player="' || P.player || '" piece-name="' || lower(H.action_parameter) || '"</div></td>' ||
                  '<td>' || 'CARD-' || ac.gamedef_card_code ||
                  '<td><div class="history-piece" id="Hpiece-' || H.piece_id || '" player="' || P.player || '" piece-name="' || lower(P.piece_type_code) || '"</div></td>'
                end     
                || '</tr></table>'
              history_item
    from gm_game_history H
    left join gm_board_pieces P on H.piece_id = P.piece_id and H.game_id = P.game_id
    left join gm_board_pieces AP on H.action_piece = AP.piece_id and H.game_id = AP.game_id
    left join gm_board_cards AC on H.action_piece = AC.card_id and H.game_id = AC.game_id
    where H.player > 0
  )
  select game_id, history_id, history_item
  from history;
  /


