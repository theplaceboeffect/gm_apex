alter session set current_schema=apex_gm;

--select gm_game_lib.calc_valid_squares(3, 101) from dual;

create or replace package GM_GAME_LIB as

  function move_in_direction( p_piece gm_board_pieces%rowtype, p_piece_type gm_piece_types%rowtype, p_max_distance_per_move number,p_x_steps number, p_y_steps number, new_xpos in out number, new_ypos in out number, ended_on out nvarchar2) return nvarchar2;
  function calc_valid_squares(p_game_id number, p_piece_id number) return varchar2;
  function format_piece(game_id number, piece_id number, player_number number, piece_name nvarchar2, svg_url nvarchar2, p_xpos number, p_ypos number) return nvarchar2;

  function new_game(p_player1 varchar2, p_player2 varchar2, p_game_type varchar2, p_fisher_game varchar2) return number;
  procedure output_board_config(p_game_id number);
  procedure move_piece(p_game_id number, p_piece_id number, p_xpos number, p_ypos number);

end GM_GAME_LIB;
/
create or replace package body GM_GAME_LIB as

  -- *****************************************************************************
  function move_in_direction( p_piece gm_board_pieces%rowtype, p_piece_type gm_piece_types%rowtype, p_max_distance_per_move number,p_x_steps number, p_y_steps number, new_xpos in out number, new_ypos in out number, ended_on out nvarchar2) return nvarchar2
  as
    new_position varchar2(100);
    return_positions varchar2(2000);
    --new_xpos number;
    --new_ypos number;
    player_occupying_square number;
    n number;
    stop_moving boolean;
  begin
    stop_moving := false;
    for step in 1..p_max_distance_per_move loop
      --return_positions := return_positions || '{' || new_xpos || ',' || new_ypos || '}';
      if p_piece_type.can_jump = 1 then
        new_xpos := nvl(new_xpos, p_piece.xpos) + step * p_x_steps;
        new_ypos := nvl(new_ypos, p_piece.ypos) + step * p_y_steps;
      else
        new_xpos := p_piece.xpos + step * p_x_steps;
        new_ypos := p_piece.ypos + step * p_y_steps;
      end if;
      --return_positions := return_positions || '{' || new_xpos || ',' || new_ypos || ' step:' || step || ' ' || p_x_steps || ',' || p_y_steps || '}';
      
      if not stop_moving then
        -- if out of bounds then don't move further
        if new_xpos < 1 or new_xpos > 8 or new_ypos < 1 or new_ypos > 8 then
          new_position:='';
          ended_on:='edge';
        else
          select count(*) into n from gm_board_pieces where game_id=p_piece.game_id and xpos=new_xpos and ypos=new_ypos;
          -- occupied
          if  (n <> 0) then
            select player into n from gm_board_pieces where game_id=p_piece.game_id and xpos=new_xpos and ypos=new_ypos;
            stop_moving := true;
            -- occupied by another player's piece ** TODO: Check for capture direction **
            if n <> p_piece.player then
                new_position:= 'loc-' || new_xpos || '-' || new_ypos || ':';
                ended_on:='nme';
            else
                new_position:='';
                ended_on:='own';
            end if; 
          else
            ended_on:='';
            -- not occupied.
            new_position := ':loc-' || new_xpos || '-' || new_ypos;    
          end if; -- if occupied
        end if; -- in bounds;
        
      end if; -- if not stop_moving
      
      if p_piece_type.can_jump = 1 then
        --return_positions := return_positions || new_position;
        null;
      else
        return_positions := return_positions || new_position;
      end if;
    end loop; 
  
    return return_positions;
  end move_in_direction;

  /*********************************************************************************************************************/
  function calc_valid_squares(p_game_id number, p_piece_id number) return varchar2
  as
  
    v_piece gm_board_pieces%rowtype;
    v_piece_type gm_piece_types%rowtype;
    v_positions varchar2(4000);
    v_move_choices apex_application_global.vc_arr2;
    move_choice varchar2(100);
    move_step varchar(1);
    new_x number;
    new_y number;
    new_position varchar2(50);
    y_direction number;
    distance_per_step number;
    step number;
    max_distance_per_move number;
    next_position varchar2(100);
    stop_moving boolean;
    ended_on varchar2(4);
  begin
  
    select P.* into v_piece from gm_board_pieces P where P.piece_id = p_piece_id and P.game_id=p_game_id;
    
    if v_piece.status = 0 then
      return '';
    end if;
    
    select PT.* into v_piece_type from gm_piece_types PT where PT.piece_type_id = v_piece.piece_type_id and PT.game_id=p_game_id;
    
    -- Flip the y direction if the second player
    if v_piece.player = 1 then y_direction := 1; else y_direction := -1 ;end if;
    
    
    -- define the furthest a piece can move.
    if v_piece_type.n_steps_per_move = 0 then
      max_distance_per_move := 8; --TODO: Replace with board size 
    else
      max_distance_per_move := v_piece_type.n_steps_per_move;
    end if;

    -- define how many steps (currently 1) that a piece takes per move
    distance_per_step := (1 * y_direction);

    -- Current position is also valid!
    v_positions := 'loc-' || v_piece.xpos || '-' || v_piece.ypos;
    
    v_move_choices := apex_util.string_to_table(v_piece_type.directions_allowed,':');
    dbms_output.put_line('---> Number of choices: ' || v_move_choices.count || ' from "' || v_piece_type.directions_allowed || '"' );
    for z in 1..v_move_choices.count loop
      move_choice := v_move_choices(z);

      new_x := null;
      new_y := null;
      dbms_output.put_line('');
      dbms_output.put_line('[DEBUG0: move_choice=' || move_choice || ']**');
      for c in 1..length(move_choice) loop
        move_step := substr(move_choice,c,1);
        dbms_output.put_line('[DEBUG1:move_step=' || move_step || new_x || ',' || new_y || ']**');
        
        if move_step = '^' or move_step = '+' or move_step='O'then
          dbms_output.put_line('[DEBUG1:move_step=' || move_step || new_x || ',' || new_y || ']**');
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, 0, distance_per_step, new_x, new_y, ended_on);
        end if;
    
        if move_step = 'v' or move_step = '+' or move_step='O'then        
          dbms_output.put_line('[DEBUG1:move_step=' || move_step || new_x || ',' || new_y || ']**');
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, 0, (-distance_per_step), new_x, new_y, ended_on);
        end if;
  
        if move_step = '<' or move_step = '+' or move_step='O'then        
          dbms_output.put_line('[DEBUG1:move_step=' || move_step || new_x || ',' || new_y || ']**');
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), 0, new_x, new_y, ended_on);
        end if;
  
        if move_step = '>' or move_step = '+' or move_step='O'then        
          dbms_output.put_line('[DEBUG1:move_step=' || move_step || new_x || ',' || new_y || ']**');
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, (distance_per_step), 0, new_x, new_y, ended_on);
        end if;
  
        if move_step = '\' or move_step = '+' or move_step='O'then        
          dbms_output.put_line('[DEBUG1:move_step=' || move_step || new_x || ',' || new_y || ']**');
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, (distance_per_step), (distance_per_step), new_x, new_y, ended_on);
        end if;

        if move_step = '/' or move_step = '+' or move_step='O'then        
          dbms_output.put_line('[DEBUG1:move_step=' || move_step || new_x || ',' || new_y || ']**');
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), (distance_per_step), new_x, new_y, ended_on);
        end if;

        if move_step = 'X' or move_step='O' then    
          
          dbms_output.put_line('DEBUG1:move_step=' || move_step || new_x || ',' || new_y);
                  
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, (distance_per_step), (-distance_per_step), new_x, new_y, ended_on);
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, (distance_per_step), (distance_per_step), new_x, new_y, ended_on);
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), (-distance_per_step), new_x, new_y, ended_on);
          v_positions := v_positions || move_in_direction(v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), (distance_per_step), new_x, new_y, ended_on);
        end if;
      end loop; -- for c
      dbms_output.put_line('DEBUG2:ended_on=' || ended_on);      
      if v_piece_type.can_jump = 1 and (ended_on = 'nme' or ended_on is null) then
        v_positions := v_positions || ':loc-' || new_x || '-' || new_y;
      end if;
      dbms_output.put_line('DEBUG3:v_positions=' || v_positions);
    end loop; -- move_choice
  
    -- For each move combination (: - separated)
    -- For each direction:
    -- General piece
  
    return v_positions;
  end calc_valid_squares;
  
  /*********************************************************************************************************************/
  function format_piece(game_id number, piece_id number, player_number number, piece_name nvarchar2, svg_url nvarchar2, p_xpos number, p_ypos number) return nvarchar2 as
  begin
    if piece_id is null then 
      return ' ';
    else
    --- Unicode
    --return '<p id="piece-' || piece_id || '" player=' || player_number || ' xpos=1 ypos=' || ypos || ' location="' || xpos || '.' || ypos || '" piece-name="' || piece_name  || '" class="game-piece">' || svg_url || '</p>';
  
    --- SVG images
    return '<div id="piece-' || piece_id || '" player=' || player_number 
                              || ' xpos=' || p_xpos || ' ypos=' || p_ypos || ' location="' || p_xpos || '.' || p_ypos 
                              || '" piece-name="' || piece_name  
                              || '" class="game-piece" type="image/svg+xml" src="' || svg_url 
                              || '" positions="' || calc_valid_squares(game_id, piece_id)
                              || '"/>';
  
    --- Debugging
    --return '[' || piece_id , piece_name ) || xpos || ',' || ypos || ']';
    end if;
  
  end;


  procedure move_piece(p_game_id number, p_piece_id number, p_xpos number, p_ypos number)
  as
    n_pieces number;
    v_player number;
    v_message varchar2(1000);
    v_piece gm_board_pieces%rowtype;
    v_piece_type gm_piece_types%rowtype;
  begin
    --log_message('move_piece: [p_game_id:' || p_game_id || '][p_piece_id:' || p_piece_id || '][x: ' || p_xpos || '][y: ' || p_ypos || ']');

    select P.* into v_piece from gm_board_pieces P where P.piece_id = p_piece_id and P.game_id=p_game_id;
    
    if v_piece.status = 0 then
      return;
    end if;
    
    select PT.* into v_piece_type from gm_piece_types PT where PT.piece_type_id = v_piece.piece_type_id and PT.game_id=p_game_id;

    select player into v_player from gm_board_pieces where game_id = p_game_id and piece_id = p_piece_id;
    v_message := 'player ' || v_piece.player || ' moved ' || v_piece_type.piece_name || ' from ' || v_piece.xpos || ',' || v_piece.ypos || ' to ' || p_xpos || ',' || p_ypos || '.'; 
    gm_chat_lib.say(v_message,'');
    
    -- Move piece    
    update gm_board_pieces
    set status = 0, xpos = 0, ypos = 0
    where game_id = p_game_id
      and xpos=p_xpos
      and ypos=p_ypos
      and player <> v_player;
      -- move piece if not occupied
      --and not exists (select * from gm_board_pieces where game_id = p_game_id and xpos=p_xpos and ypos=p_ypos and player <> v_player);

    update gm_board_pieces
    set xpos=p_xpos, ypos=p_ypos
    where game_id = p_game_id
      and piece_id = p_piece_id
      -- move piece if not occupied
      and not exists (select * from gm_board_pieces where game_id = p_game_id and xpos=p_xpos and ypos=p_ypos);

    update gm_games set lastmove_count=lastmove_count+1 where game_id = p_game_id;
  end;
  
/*******************************************************************************************/
  function new_game(p_player1 varchar2, p_player2 varchar2, p_game_type varchar2, p_fisher_game varchar2) return number
  as
    v_game_id number;
  begin
    select gm_games_seq.nextval into v_game_id from sys.dual;  
    insert into gm_games(game_id,   player1,  player2,  gamestart_timestamp,  lastmove_timestamp, lastmove_count) 
                  values(v_game_id, p_player1, p_player2, sysdate, sysdate, 0);
    
    if p_game_type = 'FISHER' then 
      gm_gamedef_lib.create_board(v_game_id, p_fisher_game);
    else
      gm_gamedef_lib.create_board(v_game_id, p_game_type);
    end if;
    
    log_message('Created new game ' || v_game_id || ': ' || p_game_type || ' ' || p_fisher_game);
    return v_game_id;
  end new_game;

/*******************************************************************************************/
  procedure output_board_config(p_game_id number)
  as
    c sys_refcursor;
  begin

    htp.p('<script>');

    open c for
      select * 
      from gm_piece_types
      where game_id = p_game_id;
      
    apex_json.initialize_clob_output;
    apex_json.open_object;    
    apex_json.write(c);
    apex_json.close_object;
    htp.p('pieces=');
    htp.p(apex_json.get_clob_output);
    apex_json.free_output;
    htp.p(';');
     
    open c for
      select * 
      from gm_boards
      where game_id = p_game_id;
    
    apex_json.initialize_clob_output;
    apex_json.open_object;    
    apex_json.write(c);
    apex_json.close_object;

    htp.p('board=');
    htp.p(apex_json.get_clob_output);
    apex_json.free_output;
    htp.p(';');
    
    htp.p('</script>');
  end output_board_config;

end GM_GAME_LIB;