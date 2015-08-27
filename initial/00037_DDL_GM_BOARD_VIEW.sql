alter session set current_schema=apex_gm;

CREATE OR REPLACE FORCE VIEW gm_board_view as
  with pieces as (
        select  P.game_id ,
                P.piece_type_id ,
                P.piece_id ,
                P.xpos ,
                P.ypos ,
                P.player ,
                P.status ,
                T.piece_name,
                T.svg_url
        from gm_board_pieces P
        join gm_piece_types T on P.piece_type_id = T.piece_type_id and P.game_id = T.game_id
      )
      , occupied_rows as (
        select distinct R.game_id, R.ypos
        from gm_board_pieces R
      )
      ,board as (
        select R.game_id, R.ypos ypos, 
           gm_game_lib.format_piece(R.game_id, X1.piece_id, X1.player, X1.piece_name, X1.svg_url, 1, R.ypos) cell_1,
           gm_game_lib.format_piece(R.game_id, X2.piece_id, X2.player, X2.piece_name, X2.svg_url, 2, R.ypos) cell_2,
           gm_game_lib.format_piece(R.game_id, X3.piece_id, X3.player, X3.piece_name, X3.svg_url, 3, R.ypos) cell_3,
           gm_game_lib.format_piece(R.game_id, X4.piece_id, X4.player, X4.piece_name, X4.svg_url, 4, R.ypos) cell_4,
           gm_game_lib.format_piece(R.game_id, X5.piece_id, X5.player, X5.piece_name, X5.svg_url, 5, R.ypos) cell_5,
           gm_game_lib.format_piece(R.game_id, X6.piece_id, X6.player, X6.piece_name, X6.svg_url, 6, R.ypos) cell_6,
           gm_game_lib.format_piece(R.game_id, X7.piece_id, X7.player, X7.piece_name, X7.svg_url, 7, R.ypos) cell_7,
           gm_game_lib.format_piece(R.game_id, X8.piece_id, X8.player, X8.piece_name, X8.svg_url, 8, R.ypos) cell_8
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
      '<div id="loc-1-' || S.ypos  || '" class="board-location" xpos=1 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_1  || '">' || p.cell_1 || '</div>' cell_1 ,
      '<div id="loc-2-' || S.ypos  || '" class="board-location" xpos=2 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_2  || '">' || p.cell_2 || '</div>' cell_2 ,
      '<div id="loc-3-' || S.ypos  || '" class="board-location" xpos=3 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_3  || '">' || p.cell_3 || '</div>' cell_3 ,
      '<div id="loc-4-' || S.ypos  || '" class="board-location" xpos=4 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_4  || '">' || p.cell_4 || '</div>' cell_4 ,
      '<div id="loc-5-' || S.ypos  || '" class="board-location" xpos=5 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_5  || '">' || p.cell_5 || '</div>' cell_5 ,
      '<div id="loc-6-' || S.ypos  || '" class="board-location" xpos=6 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_6  || '">' || p.cell_6 || '</div>' cell_6 ,
      '<div id="loc-7-' || S.ypos  || '" class="board-location" xpos=7 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_7  || '">' || p.cell_7 || '</div>' cell_7 ,
      '<div id="loc-8-' || S.ypos  || '" class="board-location" xpos=8 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_8  || '">' || p.cell_8 || '</div>' cell_8 ,
      '<div id="loc-9-' || S.ypos  || '" class="board-location" xpos=9 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_9  || '">' || '' || '</div>' cell_9 ,
      '<div id="loc-10-' || S.ypos || '" class="board-location" xpos=10 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_10 || '">' || '' || '</div>' cell_10 ,
      '<div id="loc-12-' || S.ypos || '" class="board-location" xpos=11 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_11 || '">' || '' || '</div>' cell_11 ,
      '<div id="loc-11-' || S.ypos || '" class="board-location" xpos=12 ypos=' || S.ypos || ' type="' || B.board_type || '-' || S.cell_12 || '">' || '' || '</div>' cell_12
    from gm_board_states S
    join gm_boards B on S.game_id = B.game_id
    left join board P on S.game_id = P.game_id and S.ypos = P.ypos and S.game_id=P.game_id
    ;
/