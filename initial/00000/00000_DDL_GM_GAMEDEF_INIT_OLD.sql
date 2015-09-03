alter session set current_schema=apex_gm
/

/*********************************************************************************************************************/
/* Create chess */
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
/

-- define each square on board.
declare 
  ypos number;
begin
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
end;
/

-- define each pice
declare
  CANNOT_JUMP constant number := 0;
  CAN_JUMP constant number := 1;
begin
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHESS', 'PAWN', 'pawn', CANNOT_JUMP,  1, '^');
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHESS', 'BISHOP', 'bishop', CANNOT_JUMP, 0, 'X');
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHESS', 'KNIGHT', 'knight', CAN_JUMP, 1, '^^>:^^<:vv<:vv>:>>^:>>v:<<^:<<v');
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHESS', 'ROOK', 'rook',  CANNOT_JUMP, 0, '+');
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHESS', 'QUEEN', 'queen', CANNOT_JUMP, 0, 'O');
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHESS', 'KING', 'king', CANNOT_JUMP, 1, 'O');
end;
/                        

-- define CSS

insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[type=CHESS-BLACK]','{ background-color: darkslategray;}', 1);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[type=CHESS-WHITE]','{ background-color: lightgray;}', 1);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '.bad-location',' {background-color: pink; border: 2px solid red;}', 1000);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '.good-location','{background-color: lightgreen; border: 2px solid darkgreen;}',1000);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '.capture-location','{background-color: sandybrown;border: 2px solid saddlebrown;}',1000);

-- white pieces
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="pawn"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/45/Chess_plt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="rook"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/7/72/Chess_rlt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="knight"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/7/70/Chess_nlt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="bishop"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/b/b1/Chess_blt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="king"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/42/Chess_klt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="queen"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/1/15/Chess_qlt45.svg");}',100);

-- black pieces
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="pawn"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/c/c7/Chess_pdt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="rook"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/f/ff/Chess_rdt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="knight"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/e/ef/Chess_ndt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="bishop"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/9/98/Chess_bdt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="king"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/f/f0/Chess_kdt45.svg");}',100);
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="queen"]' ,'{height:70px;width:70px;background-size: 70px 70px; background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/47/Chess_qdt45.svg");}',100);

commit;

--select * from gm_board_css order by css_order;
/*
select * from gm_board_css;

update gm_gamedef_squaretypes set square_css='background-color: red;' where gamedef_code='CHESS' and square_type_code='BLACK';
update gm_gamedef_squaretypes set square_css='background-color: pink;' where gamedef_code='CHESS' and square_type_code='WHITE';
commit;
update gm_gamedef_squaretypes set square_css='background-color: blue;' where gamedef_code='CHESS' and square_type_code='BLACK';
update gm_gamedef_squaretypes set square_css='background-color: lightblue;' where gamedef_code='CHESS' and square_type_code='WHITE';
commit;
*/