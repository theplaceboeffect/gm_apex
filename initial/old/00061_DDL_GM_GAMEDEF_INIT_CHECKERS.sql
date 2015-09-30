/*********************************************************************************************************************/
/* Create CHECKERS */
create or replace procedure gm_gamedef_mk_checkers as
  CANNOT_JUMP constant number := 0;
  CAN_JUMP constant number := 1;
  ypos number;
begin

  delete from gm_gamedef_pieces where gamedef_code='CHECKERS';
  delete from gm_gamedef_piece_types where gamedef_code='CHECKERS';
  delete from gm_gamedef_css where gamedef_code='CHECKERS';
  delete from gm_gamedef_layout where gamedef_code='CHECKERS';
  delete from gm_gamedef_squaretypes where gamedef_code='CHECKERS';
  delete from gm_gamedef_boards where gamedef_code='CHECKERS';
  
  -- define 8x8 board.
  insert into gm_gamedef_boards(gamedef_code, gamedef_name, max_rows, max_cols) values('CHECKERS', 'CHECKERS game board', 8, 8);
  
  -- define square types.
  insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( 'CHECKERS', 'BLACK','Black square');
  insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( 'CHECKERS', 'WHITE','White square');


  -- define each square on board.
  for ypos in 0..3 loop
    for xpos in 0..3 loop
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHECKERS'',' || (xpos*2 +1) || ',' || (ypos*2+1)|| ',' || '''WHITE'');');
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHECKERS'',' || (xpos*2 +2) || ',' || (ypos*2+1) || ',' || '''BLACK'');');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHECKERS', (xpos*2 +1) , (ypos*2+1) , 'WHITE');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHECKERS', (xpos*2 +2) , (ypos*2+1) , 'BLACK');
    end loop;
    for xpos in 0..3 loop
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHECKERS'',' || (xpos*2 +1) || ',' || (ypos*2+2)|| ',' || '''WHITE'');');
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHECKERS'',' || (xpos*2 +2) || ',' || (ypos*2+2) || ',' || '''BLACK'');');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHECKERS', (xpos*2 +1) , (ypos*2+2) , 'BLACK');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHECKERS', (xpos*2 +2) , (ypos*2+2) , 'WHITE');
    end loop;
  end loop;

  insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHECKERS', 'MAN', 'man', CANNOT_JUMP,  1, '\:/');
  insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHECKERS', 'KING', 'king', CANNOT_JUMP, 0, 'X');

  -- define piece locations
  -- Place white pieces
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',101,2,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',103,4,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',105,6,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',107,8,1,1,1);

  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',110,1,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',112,3,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',114,5,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','KING',116,7,2,1,1);
  
  -- Place black pieces
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',201,1,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',203,3,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',205,5,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',207,7,8,2,1);

  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',209,2,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',211,4,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',213,6,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','KING',215,8,7,2,1);

  -- define CSS

  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[type=CHECKERS-BLACK]','{ background-color: darkslategray;}', 1);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[type=CHECKERS-WHITE]','{ background-color: lightgray;}', 1);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '.bad-location',' {background-color: pink; border: 2px solid red;}', 1000);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '.good-location','{background-color: lightgreen; border: 2px solid darkgreen;}',1000);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '.capture-location','{background-color: sandybrown;border: 2px solid saddlebrown;}',1000);
  
  
  /*
  <a title="By user:malarz pl, User:Stellmach, User:Stannered [Public domain], via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File%3ADraughts_mdt45.svg"><img width="32" alt="Draughts mdt45" src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Draughts_mdt45.svg/32px-Draughts_mdt45.svg.png"/></a>
   */
  -- white pieces
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[player="1"][piece-name="man"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/9/90/Draughts_mlt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[player="1"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/a/a6/Draughts_klt45.svg");}',100);
  
  -- black pieces
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[player="2"][piece-name="man"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/0/0c/Draughts_mdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[player="2"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/9/9a/Draughts_kdt45.svg");}',100);
end;
/
exec gm_gamedef_mk_checkers;
commit;

/
