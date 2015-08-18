
create or replace view GM_BOARD_VIEW  as
  with pieces as (
      select  P.game_id ,
              P.piece_type_id ,
              P.x_location ,
              P.y_location ,
              P.player ,
              P.status ,
              T.piece_name
      from gm_board_pieces P
      join gm_piece_types T on P.piece_type_id = T.piece_type_id
      where T.game_id=v('P1_CURRENT_GAME')
    )
    ,board as (
      select distinct R.game_id, R.y_location row_number, 
          nvl(X1.player || '.' || X1.piece_name || '.' || X1.status,'') cell_1,
          nvl(X2.player || '.' || X2.piece_name || '.' || X2.status,'') cell_2,
          nvl(X3.player || '.' || X3.piece_name || '.' || X3.status,'') cell_3,
          nvl(X4.player || '.' || X4.piece_name || '.' || X4.status,'') cell_4,
          nvl(X5.player || '.' || X5.piece_name || '.' || X5.status,'') cell_5,
          nvl(X6.player || '.' || X6.piece_name || '.' || X6.status,'') cell_6,
          nvl(X7.player || '.' || X7.piece_name || '.' || X7.status,'') cell_7,
          nvl(X8.player || '.' || X8.piece_name || '.' || X8.status,'') cell_8
      from gm_board_pieces R
      left join pieces X1 on R.game_id = X1.game_id and X1.x_location=1 and R.y_location = X1.y_location
      left join pieces X2 on R.game_id = X2.game_id and X2.x_location=2 and R.y_location = X2.y_location
      left join pieces X3 on R.game_id = X3.game_id and X3.x_location=3 and R.y_location = X3.y_location
      left join pieces X4 on R.game_id = X4.game_id and X4.x_location=4 and R.y_location = X4.y_location
      left join pieces X5 on R.game_id = X5.game_id and X5.x_location=5 and R.y_location = X5.y_location
      left join pieces X6 on R.game_id = X6.game_id and X6.x_location=6 and R.y_location = X6.y_location
      left join pieces X7 on R.game_id = X7.game_id and X7.x_location=7 and R.y_location = X7.y_location
      left join pieces X8 on R.game_id = X8.game_id and X8.x_location=8 and R.y_location = X8.y_location
  )
  select
    B.game_id ,
    S.row_number,
    '<div class="' || B.board_type || '-' || S.cell_1  || '">' || p.cell_1 || '</div>' cell_1 ,
    '<div class="' || B.board_type || '-' || S.cell_2  || '">' || p.cell_2 || '</div>' cell_2 ,
    '<div class="' || B.board_type || '-' || S.cell_3  || '">' || p.cell_3 || '</div>' cell_3 ,
    '<div class="' || B.board_type || '-' || S.cell_4  || '">' || p.cell_4 || '</div>' cell_4 ,
    '<div class="' || B.board_type || '-' || S.cell_5  || '">' || p.cell_5 || '</div>' cell_5 ,
    '<div class="' || B.board_type || '-' || S.cell_6  || '">' || p.cell_6 || '</div>' cell_6 ,
    '<div class="' || B.board_type || '-' || S.cell_7  || '">' || p.cell_7 || '</div>' cell_7 ,
    '<div class="' || B.board_type || '-' || S.cell_8  || '">' || p.cell_8 || '</div>' cell_8 ,
    '<div class="' || B.board_type || '-' || S.cell_9  || '">' || '' || '</div>' cell_9 ,
    '<div class="' || B.board_type || '-' || S.cell_10 || '">' || '' || '</div>' cell_10 ,
    '<div class="' || B.board_type || '-' || S.cell_11 || '">' || '' || '</div>' cell_11 ,
    '<div class="' || B.board_type || '-' || S.cell_12 || '">' || '' || '</div>' cell_12
  from gm_board_states S
  join gm_boards B on S.game_id = B.game_id
  left join board P on S.game_id = P.game_id and S.row_number = P.row_number
  where S.game_id=v('P1_CURRENT_GAME')
  ;
