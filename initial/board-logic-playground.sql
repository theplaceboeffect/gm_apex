alter session set current_schema=apex_gm;
/*
select * from gm_boards;
select * from gm_board_states;

select * 
from gm_board_pieces P
join gm_piece_types PT on P.piece_type_id = PT.piece_type_id and P.game_id = PT.game_id
where PT.game_id = 1 and PT.game_id = 1 
and P.piece_id=109;
*/

/

select gm_calc_valid_squares(1, 109) positions from dual;
select gm_calc_valid_squares(1, 209) positions from dual;
