alter session set current_schema=apex_gm;

select gm_calc_valid_squares(3,106) from dual;
  select gm_calc_valid_squares(3,104) from dual;


create or replace function gm_generate_board_location(p_game_id number, xpos number, ypos number) return varchar2 as
n number;
begin

  -- if out of bounds then return
  if xpos < 1 or xpos > 8 or ypos < 1 or ypos > 8 then
    --return 'loc-' || xpos || '-' || ypos || ':OOB';
    return '';
  end if;
  
  -- if occupied by own piece then return;
  select count(*) into n from gm_board_pieces where game_id=p_game_id and x_pos=xpos and y_pos=ypos;
  if  (n <> 0) then
    --return 'loc-' || xpos || '-' || ypos || ':OCC';
    return '';
  else
    return 'loc-' || xpos || '-' || ypos || ':';
  end if;
end;
/
create or replace function gm_calc_valid_squares(p_game_id number, p_piece_id number) return varchar2
as

  v_piece gm_board_pieces%rowtype;
  v_piece_definition gm_piece_types%rowtype;
  v_positions varchar2(1000);
  v_move_choices apex_application_global.vc_arr2;
  move_choice varchar2(100);
  new_x number;
  new_y number;
  y_direction number;
  distance_per_step number;
  step number;
  max_distance_per_move number;
  next_position varchar2(100);
  stop_moving boolean;
begin

  select P.* into v_piece from gm_board_pieces P where P.piece_id = p_piece_id and P.game_id=p_game_id;
  select PT.* into v_piece_definition from gm_piece_types PT where PT.piece_type_id = v_piece.piece_type_id and PT.game_id=p_game_id;
  
  -- Flip the y direction if the second player
  if v_piece.player = 1 then y_direction := 1; else y_direction := -1 ;end if;
  
  -- Current position is also valid!
  v_positions := 'loc-' || v_piece.x_pos || '-' || v_piece.y_pos || ':';
  
  v_move_choices := apex_util.string_to_table(v_piece_definition.directions_allowed,':');
  for z in 1..v_move_choices.count loop
    move_choice := v_move_choices(z);

    if v_piece_definition.n_steps_per_move = 0 then
      max_distance_per_move := 8; --TODO: Replace with board size 
    else
      max_distance_per_move := v_piece_definition.n_steps_per_move;
    end if;

    distance_per_step := (1 * y_direction);

/*    -- IF CAN JUMP 
    for step in 1..max_distance_per_move loop
      case 
      when move_choice = '^' then
        v_positions := v_positions || gm_generate_board_location(p_game_id, v_piece.x_pos , (v_piece.y_pos + distance_per_step) );
      when move_choice = 'X' then 
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos - step*distance_per_step) , (v_piece.y_pos - step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos - step*distance_per_step) , (v_piece.y_pos + step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos - step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos + step*distance_per_step) );
      when move_choice = '+' then 
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos) , (v_piece.y_pos - step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos) , (v_piece.y_pos + step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos) );
      when move_choice = 'O' then
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos - step*distance_per_step) , (v_piece.y_pos - step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos - step*distance_per_step) , (v_piece.y_pos + step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos - step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos + step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos) , (v_piece.y_pos - step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos) , (v_piece.y_pos + step*distance_per_step) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos) );
        v_positions := v_positions || gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos) );
      else
        null;
      end case;
    end loop;
*/
      -- CANNOT JUMP
      if move_choice = '^' then
        if not stop_moving then
          next_position := move_in_direction(p_game_id, v_piece.player, 0 /* xmovement*/, (v_piece.y_pos + distance_per_step), stop_moving);
        end if;
        
        
        stop_moving := false;
        for step in 1..max_distance_per_move loop
          next_position := gm_generate_board_location(p_game_id, v_piece.x_pos , (v_piece.y_pos + distance_per_step) );
          if next_position is null then
            stop_moving := true;
          end if;
          if not stop_moving then
            v_positions := v_positions || next_position;
          end if;
        end loop;
      end if;
      
      if move_choice = 'X' or move_choice='O' then 
        stop_moving := false;
        for step in 1..max_distance_per_move loop
          next_position := gm_generate_board_location(p_game_id, (v_piece.x_pos - step*distance_per_step) , (v_piece.y_pos - step*distance_per_step) );
          if next_position is null then
            stop_moving := true;
          end if;
          if not stop_moving then
            v_positions := v_positions || next_position;
          end if;
        end loop;
        stop_moving := false;
        for step in 1..max_distance_per_move loop
          next_position := gm_generate_board_location(p_game_id, (v_piece.x_pos - step*distance_per_step) , (v_piece.y_pos + step*distance_per_step) );
          if next_position is null then
            stop_moving := true;
          end if;
          if not stop_moving then
            v_positions := v_positions || next_position;
          end if;
        end loop;
        stop_moving := false;
        for step in 1..max_distance_per_move loop
          next_position := gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos - step*distance_per_step) );
          if next_position is null then
            stop_moving := true;
          end if;
          if not stop_moving then
            v_positions := v_positions || next_position;
          end if;
        end loop;
        stop_moving := false;
        for step in 1..max_distance_per_move loop
          next_position := gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos + step*distance_per_step) );
          if next_position is null then
            stop_moving := true;
          end if;
          if not stop_moving then
            v_positions := v_positions || next_position;
          end if;
        end loop;
      end if;
      
      if move_choice = '+' or move_choice='O' then 
        stop_moving := false;
        for step in 1..max_distance_per_move loop
          next_position := gm_generate_board_location(p_game_id, (v_piece.x_pos) , (v_piece.y_pos - step*distance_per_step) );
          if next_position is null then
            stop_moving := true;
          end if;
          if not stop_moving then
            v_positions := v_positions || next_position;
          end if;
        end loop;
        stop_moving := false;
        for step in 1..max_distance_per_move loop
          next_position := gm_generate_board_location(p_game_id, (v_piece.x_pos) , (v_piece.y_pos + step*distance_per_step) );
          if next_position is null then
            stop_moving := true;
          end if;
          if not stop_moving then
            v_positions := v_positions || next_position;
          end if;
        end loop;
        stop_moving := false;
        for step in 1..max_distance_per_move loop
          next_position := gm_generate_board_location(p_game_id, (v_piece.x_pos + step*distance_per_step) , (v_piece.y_pos) );
          if next_position is null then
            stop_moving := true;
          end if;
          if not stop_moving then
            v_positions := v_positions || next_position;
          end if;
        end loop;
        stop_moving := false;
        for step in 1..max_distance_per_move loop
          next_position := gm_generate_board_location(p_game_id, (v_piece.x_pos - step*distance_per_step) , (v_piece.y_pos) );
          if next_position is null then
            stop_moving := true;
          end if;
          if not stop_moving then
            v_positions := v_positions || next_position;
          end if;
        end loop;
      end if;
      
  end loop;
  
  -- For each move combination (: - separated)
  -- For each direction:
  -- General piece

  return v_positions;
end gm_calc_valid_squares;
/
create or replace function format_piece(game_id number, piece_id number, player_number number, piece_name nvarchar2, svg_url nvarchar2, x_pos number, y_pos number) return nvarchar2 as
begin
  if piece_id is null then 
    return ' ';
  else
  --- Unicode
  --return '<p id="piece-' || piece_id || '" player=' || player_number || ' xpos=1 ypos=' || y_pos || ' location="' || x_pos || '.' || y_pos || '" piece-name="' || piece_name  || '" class="game-piece">' || svg_url || '</p>';

  --- SVG images
  return '<img id="piece-' || piece_id || '" player=' || player_number 
                            || ' xpos=1 ypos=' || y_pos || ' location="' || x_pos || '.' || y_pos 
                            || '" piece-name="' || piece_name  
                            || '" class="game-piece" type="image/svg+xml" src="' || svg_url 
                            || '" positions="' || gm_calc_valid_squares(game_id, piece_id)
                            || '"/>';

  --- Debugging
  --return '[' || piece_id , piece_name ) || x_pos || ',' || y_pos || ']';
  end if;

end;
/
CREATE OR REPLACE FORCE VIEW gm_board_view as
  with pieces as (
        select  P.game_id ,
                P.piece_type_id ,
                P.piece_id ,
                P.x_pos ,
                P.y_pos ,
                P.player ,
                P.status ,
                T.piece_name,
                T.svg_url
        from gm_board_pieces P
        join gm_piece_types T on P.piece_type_id = T.piece_type_id and P.game_id = T.game_id
      )
      , occupied_rows as (
        select distinct R.game_id, R.y_pos
        from gm_board_pieces R
      )
      ,board as (
        select R.game_id, R.y_pos y_pos, 
           format_piece(R.game_id, X1.piece_id, X1.player, X1.piece_name, X1.svg_url, 1, R.y_pos) cell_1,
           format_piece(R.game_id, X2.piece_id, X2.player, X2.piece_name, X2.svg_url, 2, R.y_pos) cell_2,
           format_piece(R.game_id, X3.piece_id, X3.player, X3.piece_name, X3.svg_url, 3, R.y_pos) cell_3,
           format_piece(R.game_id, X4.piece_id, X4.player, X4.piece_name, X4.svg_url, 4, R.y_pos) cell_4,
           format_piece(R.game_id, X5.piece_id, X5.player, X5.piece_name, X5.svg_url, 5, R.y_pos) cell_5,
           format_piece(R.game_id, X6.piece_id, X6.player, X6.piece_name, X6.svg_url, 6, R.y_pos) cell_6,
           format_piece(R.game_id, X7.piece_id, X7.player, X7.piece_name, X7.svg_url, 7, R.y_pos) cell_7,
           format_piece(R.game_id, X8.piece_id, X8.player, X8.piece_name, X8.svg_url, 8, R.y_pos) cell_8
        from occupied_rows R
          left join pieces X1 on R.game_id = X1.game_id and X1.x_pos=1 and R.y_pos = X1.y_pos and X1.status <> 0
          left join pieces X2 on R.game_id = X2.game_id and X2.x_pos=2 and R.y_pos = X2.y_pos and X2.status <> 0
          left join pieces X3 on R.game_id = X3.game_id and X3.x_pos=3 and R.y_pos = X3.y_pos and X3.status <> 0
          left join pieces X4 on R.game_id = X4.game_id and X4.x_pos=4 and R.y_pos = X4.y_pos and X4.status <> 0
          left join pieces X5 on R.game_id = X5.game_id and X5.x_pos=5 and R.y_pos = X5.y_pos and X5.status <> 0
          left join pieces X6 on R.game_id = X6.game_id and X6.x_pos=6 and R.y_pos = X6.y_pos and X6.status <> 0
          left join pieces X7 on R.game_id = X7.game_id and X7.x_pos=7 and R.y_pos = X7.y_pos and X7.status <> 0
          left join pieces X8 on R.game_id = X8.game_id and X8.x_pos=8 and R.y_pos = X8.y_pos and X8.status <> 0
        
    )
    select
      B.game_id ,
      S.y_pos,
      '<div id="loc-1-' || S.y_pos  || '" class="board-location" xpos=1 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_1  || '">' || p.cell_1 || '</div>' cell_1 ,
      '<div id="loc-2-' || S.y_pos  || '" class="board-location" xpos=2 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_2  || '">' || p.cell_2 || '</div>' cell_2 ,
      '<div id="loc-3-' || S.y_pos  || '" class="board-location" xpos=3 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_3  || '">' || p.cell_3 || '</div>' cell_3 ,
      '<div id="loc-4-' || S.y_pos  || '" class="board-location" xpos=4 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_4  || '">' || p.cell_4 || '</div>' cell_4 ,
      '<div id="loc-5-' || S.y_pos  || '" class="board-location" xpos=5 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_5  || '">' || p.cell_5 || '</div>' cell_5 ,
      '<div id="loc-6-' || S.y_pos  || '" class="board-location" xpos=6 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_6  || '">' || p.cell_6 || '</div>' cell_6 ,
      '<div id="loc-7-' || S.y_pos  || '" class="board-location" xpos=7 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_7  || '">' || p.cell_7 || '</div>' cell_7 ,
      '<div id="loc-8-' || S.y_pos  || '" class="board-location" xpos=8 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_8  || '">' || p.cell_8 || '</div>' cell_8 ,
      '<div id="loc-9-' || S.y_pos  || '" class="board-location" xpos=9 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_9  || '">' || '' || '</div>' cell_9 ,
      '<div id="loc-10-' || S.y_pos || '" class="board-location" xpos=10 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_10 || '">' || '' || '</div>' cell_10 ,
      '<div id="loc-12-' || S.y_pos || '" class="board-location" xpos=11 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_11 || '">' || '' || '</div>' cell_11 ,
      '<div id="loc-11-' || S.y_pos || '" class="board-location" xpos=12 ypos=' || S.y_pos || ' type="' || B.board_type || '-' || S.cell_12 || '">' || '' || '</div>' cell_12
    from gm_board_states S
    join gm_boards B on S.game_id = B.game_id
    left join board P on S.game_id = P.game_id and S.y_pos = P.y_pos and S.game_id=P.game_id
    ;
/