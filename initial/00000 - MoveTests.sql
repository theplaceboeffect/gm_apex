alter session set current_schema=apex_gm;

create or replace procedure GM_GenerateMoveTest(p_game_id number, p_piece_id number, p_xpos number, p_ypos number) as
v_moves varchar(4000);
v_piece_type gm_piece_types%rowtype;
begin
  update gm_board_pieces set status=0 ,x_pos=0, y_pos=0 where game_id=p_game_id;
  update gm_board_pieces set status=1, x_pos=p_xpos, y_pos=p_ypos where game_id=p_game_id and piece_id=p_piece_id;
  
  select gm_game_lib.calc_valid_squares(p_game_id, p_piece_id) into v_moves from dual;
  
  select * into v_piece_type 
  from gm_piece_types 
  where game_id = p_game_id and piece_type_id = (select piece_type_id from gm_board_pieces where game_id=p_game_id and piece_id=p_piece_id);
  commit;
  dbms_output.put_line('Moves for ' || v_piece_type.piece_name || '(' || v_piece_type.directions_allowed || ') on ' || p_xpos || ',' || p_ypos || ':' || v_moves);
end;
/
commit;
select gm_game_lib.gm_calc_valid_squares(1, 101) from dual;
select * from gm_board_pieces where game_id=3;
begin

  GM_GenerateMoveTest(1,101,4,6);
  GM_GenerateMoveTest(1,102,4,6);
  GM_GenerateMoveTest(1,103,4,6);
  GM_GenerateMoveTest(1,104,4,6);
  GM_GenerateMoveTest(1,105,4,6);
  GM_GenerateMoveTest(1,109,4,6);
end;
exec  GM_GenerateMoveTest(1,101,4,6);
exec  GM_GenerateMoveTest(1,102,4,6);
exec  GM_GenerateMoveTest(1,103,4,6);
exec  GM_GenerateMoveTest(1,104,4,6);
exec  GM_GenerateMoveTest(1,105,3,7);
exec  GM_GenerateMoveTest(1,109,4,3);