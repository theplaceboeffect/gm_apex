/*********************************************************************************************************************/
/* Create chess */
create or replace procedure gm_gamedef_mk_chess as
  CANNOT_JUMP constant number := 0;
  CAN_JUMP constant number := 1;
  ypos number;
begin
  
  delete from gm_gamedef_pieces where gamedef_code='CHESS';
  delete from gm_gamedef_piece_types where gamedef_code='CHESS';
  delete from gm_gamedef_css where gamedef_code='CHESS';
  delete from gm_gamedef_layout where gamedef_code='CHESS';
  delete from gm_gamedef_squaretypes where gamedef_code='CHESS';
  delete from gm_gamedef_boards where gamedef_code='CHESS';

  -- define 8x8 board.
  insert into gm_gamedef_boards(gamedef_code, gamedef_name, max_rows, max_cols) values('CHESS', 'Chess game board', 8, 8);
  
  -- define square types.
  insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( 'CHESS', 'BLACK','Black square');
  insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( 'CHESS', 'WHITE','White square');

  for ypos in 0..3 loop
    for xpos in 0..3 loop
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHESS'',' || (xpos*2 +1) || ',' || (ypos*2+1)|| ',' || '''WHITE'');');
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHESS'',' || (xpos*2 +2) || ',' || (ypos*2+1) || ',' || '''BLACK'');');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHESS', (xpos*2 +1) , (ypos*2+1) , 'WHITE');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHESS', (xpos*2 +2) , (ypos*2+1) , 'BLACK');
    end loop;
    for xpos in 0..3 loop
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHESS'',' || (xpos*2 +1) || ',' || (ypos*2+2)|| ',' || '''WHITE'');');
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHESS'',' || (xpos*2 +2) || ',' || (ypos*2+2) || ',' || '''BLACK'');');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHESS', (xpos*2 +1) , (ypos*2+2) , 'BLACK');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHESS', (xpos*2 +2) , (ypos*2+2) , 'WHITE');
    end loop;
  end loop;
    
    -- define each pice
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions ) 
                                        values('CHESS', 'PAWN', 'pawn', 'P', CANNOT_JUMP,  1, '^^:^:\:/', '^:\:/','\/', '^');
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'BISHOP', 'bishop', 'B', CANNOT_JUMP, 0, null, 'X',null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'KNIGHT', 'knight', 'N',  CAN_JUMP, 1, null, '^^>:^^<:vv<:vv>:>>^:>>v:<<^:<<v', null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'ROOK', 'rook',  'R', CANNOT_JUMP, 0, null, '+', null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'QUEEN', 'queen', 'Q', CANNOT_JUMP, 0, null, 'O', null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'KING', 'king', 'K', CANNOT_JUMP, 1, null, 'O', null, null);

  -- define piece locations
  -- Place white pieces
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','ROOK',101,1,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KNIGHT',102,2,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','BISHOP',103,3,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KING',104,4,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','QUEEN',105,5,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','BISHOP',106,6,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KNIGHT',107,7,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','ROOK',108,8,1,1,1);

  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',109,1,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',110,2,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',111,3,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',112,4,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',113,5,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',114,6,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',115,7,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',116,8,2,1,1);
  
  -- Place black pieces
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','ROOK',201,1,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KNIGHT',202,2,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','BISHOP',203,3,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KING',204,4,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','QUEEN',205,5,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','BISHOP',206,6,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KNIGHT',207,7,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','ROOK',208,8,8,2,1);

  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',209,1,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',210,2,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',211,3,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',212,4,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',213,5,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',214,6,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',215,7,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',216,8,7,2,1);

  -- define CSS
  
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[type=CHESS-BLACK]','{background-color: darkslategray;}', 1);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[type=CHESS-WHITE]','{background-color: lightgray;}', 1);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '.bad-location',' {background-color: pink; border: 2px solid red;}', 1000);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '.good-location','{background-color: lightgreen; border: 2px solid darkgreen;}',1000);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '.capture-location','{background-color: sandybrown;border: 2px solid saddlebrown;}',1002);
  
  -- white pieces
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="pawn"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/45/Chess_plt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="rook"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/7/72/Chess_rlt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="knight"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/7/70/Chess_nlt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="bishop"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/b/b1/Chess_blt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/42/Chess_klt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="queen"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/1/15/Chess_qlt45.svg");}',100);
  
  -- black pieces
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="pawn"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/c/c7/Chess_pdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="rook"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/f/ff/Chess_rdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="knight"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/e/ef/Chess_ndt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="bishop"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/9/98/Chess_bdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/f/f0/Chess_kdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="queen"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/47/Chess_qdt45.svg");}',100);
end;
/
exec gm_gamedef_mk_chess;
/
commit;
/
