create or replace function format_piece(piece_id number, player_number number, piece_name nvarchar2, svg_url nvarchar2, x_pos number, y_pos number) return nvarchar2 as
begin

  if piece_id is null then 
    return ' ';
  else
    return '<img id="piece-' || piece_id || '" player=' || player_number || ' location="' || x_pos || '.' || y_pos || '" piece-name="' || piece_name  || '" class="game-piece" type="image/svg+xml" src="' || svg_url || '"/>';
  --return '[' || piece_id || '-' || piece_name || ':' || x_pos || ',' || y_pos || ']';
  end if;

end;
/
CREATE OR REPLACE FORCE VIEW gm_board_view as
  with pieces as (
        select  P.game_id ,
                P.piece_type_id ,
                P.piece_id ,
                P.x_location ,
                P.y_location ,
                P.player ,
                P.status ,
                T.piece_name,
                T.svg_url
        from gm_board_pieces P
        join gm_piece_types T on P.piece_type_id = T.piece_type_id and P.game_id = T.game_id
      )
      , occupied_rows as (
        select distinct R.game_id, R.y_location
        from gm_board_pieces R
      )
--      select format_piece(X2.piece_id, X2.player, X2.piece_name, X2.svg_url, 2, R.y_location) 
--      from occupied_rows R left join pieces X2 on r.game_id=x2.game_id and x2.x_location=2 and r.y_location=x2.y_location and x2.status <> 0;


      ,board as (
        select R.game_id, R.y_location row_number, 
           format_piece(X1.piece_id, X1.player, X1.piece_name, X1.svg_url, 1, R.y_location) cell_1,
           format_piece(X2.piece_id, X2.player, X2.piece_name, X2.svg_url, 2, R.y_location) cell_2,
           format_piece(X3.piece_id, X3.player, X3.piece_name, X3.svg_url, 3, R.y_location) cell_3,
           format_piece(X4.piece_id, X4.player, X4.piece_name, X4.svg_url, 4, R.y_location) cell_4,
           format_piece(X5.piece_id, X5.player, X5.piece_name, X5.svg_url, 5, R.y_location) cell_5,
           format_piece(X6.piece_id, X6.player, X6.piece_name, X6.svg_url, 6, R.y_location) cell_6,
           format_piece(X7.piece_id, X7.player, X7.piece_name, X7.svg_url, 7, R.y_location) cell_7,
           format_piece(X8.piece_id, X8.player, X8.piece_name, X8.svg_url, 8, R.y_location) cell_8
        from occupied_rows R
          left join pieces X1 on R.game_id = X1.game_id and X1.x_location=1 and R.y_location = X1.y_location and X1.status <> 0
          left join pieces X2 on R.game_id = X2.game_id and X2.x_location=2 and R.y_location = X2.y_location and X2.status <> 0
          left join pieces X3 on R.game_id = X3.game_id and X3.x_location=3 and R.y_location = X3.y_location and X3.status <> 0
          left join pieces X4 on R.game_id = X4.game_id and X4.x_location=4 and R.y_location = X4.y_location and X4.status <> 0
          left join pieces X5 on R.game_id = X5.game_id and X5.x_location=5 and R.y_location = X5.y_location and X5.status <> 0
          left join pieces X6 on R.game_id = X6.game_id and X6.x_location=6 and R.y_location = X6.y_location and X6.status <> 0
          left join pieces X7 on R.game_id = X7.game_id and X7.x_location=7 and R.y_location = X7.y_location and X7.status <> 0
          left join pieces X8 on R.game_id = X8.game_id and X8.x_location=8 and R.y_location = X8.y_location and X8.status <> 0
        
    )
    select
      B.game_id ,
      S.row_number,
      --<div id="loc-1-1" class="board_location" type="chess-0"><div>
      --<object id="piece-101" player=1 piece-name="rook" class="game-piece" type="image/svg+xml" data="https://upload.wikimedia.org/wikipedia/commons/8/85/Chess_rgt45.svg"/><
      --/div></div>
      '<div id="loc-1-' || S.row_number  || '" class="board_location" type="' || B.board_type || '-' || S.cell_1  || '">' || p.cell_1 || '</div>' cell_1 ,
      '<div id="loc-2-' || S.row_number  || '" class="board_location" type="' || B.board_type || '-' || S.cell_2  || '">' || p.cell_2 || '</div>' cell_2 ,
      '<div id="loc-3-' || S.row_number  || '" class="board_location" type="' || B.board_type || '-' || S.cell_3  || '">' || p.cell_3 || '</div>' cell_3 ,
      '<div id="loc-4-' || S.row_number  || '" class="board_location" type="' || B.board_type || '-' || S.cell_4  || '">' || p.cell_4 || '</div>' cell_4 ,
      '<div id="loc-5-' || S.row_number  || '" class="board_location" type="' || B.board_type || '-' || S.cell_5  || '">' || p.cell_5 || '</div>' cell_5 ,
      '<div id="loc-6-' || S.row_number  || '" class="board_location" type="' || B.board_type || '-' || S.cell_6  || '">' || p.cell_6 || '</div>' cell_6 ,
      '<div id="loc-7-' || S.row_number  || '" class="board_location" type="' || B.board_type || '-' || S.cell_7  || '">' || p.cell_7 || '</div>' cell_7 ,
      '<div id="loc-8-' || S.row_number  || '" class="board_location" type="' || B.board_type || '-' || S.cell_8  || '">' || p.cell_8 || '</div>' cell_8 ,
      '<div id="loc-9-' || S.row_number  || '" class="board_location" type="' || B.board_type || '-' || S.cell_9  || '">' || '' || '</div>' cell_9 ,
      '<div id="loc-10-' || S.row_number || '" class="board_location" type="' || B.board_type || '-' || S.cell_10 || '">' || '' || '</div>' cell_10 ,
      '<div id="loc-12-' || S.row_number || '" class="board_location" type="' || B.board_type || '-' || S.cell_11 || '">' || '' || '</div>' cell_11 ,
      '<div id="loc-11-' || S.row_number || '" class="board_location" type="' || B.board_type || '-' || S.cell_12 || '">' || '' || '</div>' cell_12
    from gm_board_states S
    join gm_boards B on S.game_id = B.game_id
    left join board P on S.game_id = P.game_id and S.row_number = P.row_number and S.game_id=P.game_id
    ;
/
--
select * from gm_board_view where game_id=1 and row_number=2 order by row_number;
