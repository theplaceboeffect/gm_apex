declare
  result nvarchar2(100);
begin
  result := gm_login_lib.login_user('user1');
  result := gm_login_lib.login_user('user2');
  gm_chat_lib.say('user1','hello');
end;
rollback;
declare
  game_id number;
begin
  game_id:=gm_game_lib.new_game('p1','p2');
end;

select * from gm_games;
select * from gm_boards;

delete from gm_games;
delete from gm_boards;
commit;

select * 
from gm_board_states 
where game_id=188
order by row_number;

select * from gm_piece_types;
select * from gm_board_pieces;