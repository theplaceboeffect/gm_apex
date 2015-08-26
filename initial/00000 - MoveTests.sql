alter session set current_schema=apex_gm;

create or replace procedure GM_GenerateMoveTest(p_game_id number, p_piece_id number, p_xpos number, p_ypos number) as
v_moves varchar(4000);
v_piece_type gm_piece_types%rowtype;
begin
  update gm_board_pieces set status=0 where game_id=p_game_id;
  update gm_board_pieces set status=1, x_pos=p_xpos, y_pos=p_ypos where game_id=p_game_id and piece_id=p_piece_id;
  
  select gm_game_lib.gm_calc_valid_squares(p_game_id, p_piece_id) into v_moves from dual;
  
  select * into v_piece_type 
  from gm_piece_types 
  where game_id = p_game_id and piece_type_id = (select piece_type_id from gm_board_pieces where game_id=p_game_id and piece_id=p_piece_id);
  
  dbms_output.put_line('Moves for ' || v_piece_type.piece_name || '(' || v_piece_type.directions_allowed || ') on ' || p_xpos || ',' || p_ypos || ':' || v_moves);
end;
/

exec GM_GenerateMoveTest(3,101,4,4);
exec GM_GenerateMoveTest(3,102,4,4);
exec GM_GenerateMoveTest(3,103,4,4);
exec GM_GenerateMoveTest(3,104,4,4);
exec GM_GenerateMoveTest(3,105,4,4);
exec GM_GenerateMoveTest(3,109,4,4);
