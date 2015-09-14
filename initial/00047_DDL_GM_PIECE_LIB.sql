
create or replace package GM_PIECE_LIB as
  procedure move_piece(p_game_id number, p_piece_id number, p_xpos number, p_ypos number);
  function move_in_direction( move_step char, p_piece gm_board_pieces%rowtype, p_piece_type gm_piece_types%rowtype, p_max_distance_per_move number,p_x_steps number, p_y_steps number, new_xpos in out number, new_ypos in out number, ended_on out nvarchar2) return nvarchar2;

  function format_piece(p_game_id number, p_piece_id number, p_player_number number, p_piece_name nvarchar2, p_xpos number, p_ypos number) return nvarchar2;
  function calc_valid_squares(p_game_id number, p_piece_id number) return varchar2;
  procedure generate_piece_moves(p_game_id number);

end GM_PIECE_LIB;

/

create or replace package body GM_PIECE_LIB as

  /*********************************************************************************************************************/
  procedure move_piece(p_game_id number, p_piece_id number, p_xpos number, p_ypos number)
  as
    n_pieces number;
    v_player number;
    v_message varchar2(1000);
    v_action varchar2(20);
    v_taken_piece_id number;
    v_taken_piece gm_board_pieces%rowtype;
    v_piece gm_board_pieces%rowtype;
    v_piece_type gm_piece_types%rowtype;
  begin
    --log_message('move_piece: [p_game_id:' || p_game_id || '][p_piece_id:' || p_piece_id || '][x: ' || p_xpos || '][y: ' || p_ypos || ']');

    select P.* into v_piece from gm_board_pieces P where P.piece_id = p_piece_id and P.game_id=p_game_id;
    
    if v_piece.status = 0 then
      return;
    end if;
    
    select PT.* into v_piece_type from gm_piece_types PT where PT.piece_type_code = v_piece.piece_type_code and PT.game_id=p_game_id;

    select player into v_player from gm_board_pieces where game_id = p_game_id and piece_id = p_piece_id;
    v_message := 'In game ' || p_game_id || ', player ' || v_piece.player || ' moved ' || v_piece_type.piece_name || ' from ' || v_piece.xpos || ',' || v_piece.ypos || ' to ' || p_xpos || ',' || p_ypos || '.'; 
    gm_chat_lib.say(v_message,'');
    
    -- Capture piece
    select sum(piece_id)
    into v_taken_piece_id
    from gm_board_pieces
    where game_id = p_game_id
      and xpos=p_xpos
      and ypos=p_ypos
      and player <> v_player;

    v_action := 'MOVE';
    
    if v_taken_piece_id is not null then
      
      select *
      into v_taken_piece
      from gm_board_pieces
      where game_id = p_game_id
          and piece_id = v_taken_piece_id;

      update gm_board_pieces
      set status = 0, xpos = 0, ypos = 0
      where game_id = p_game_id and piece_id = v_taken_piece.piece_id;
      v_action := 'CAPTURE';
      
    end if;

    -- Move piece
    update gm_board_pieces
    set xpos=p_xpos, ypos=p_ypos
    where game_id = p_game_id
      and piece_id = p_piece_id
      and not exists (select * from gm_board_pieces where game_id = p_game_id and xpos=p_xpos and ypos=p_ypos);

    -- update history table.
    insert into gm_game_history(game_id,piece_id,player, old_xpos, old_ypos, new_xpos, new_ypos, action, action_piece)
                    values(p_game_id, p_piece_id, v_player, v_piece.xpos, v_piece.ypos, p_xpos, p_ypos, v_action, v_taken_piece.piece_id);
  end move_piece;

 /*********************************************************************************************************************/
  function move_in_direction( move_step char, p_piece gm_board_pieces%rowtype, p_piece_type gm_piece_types%rowtype, p_max_distance_per_move number,p_x_steps number, p_y_steps number, new_xpos in out number, new_ypos in out number, ended_on out nvarchar2) return nvarchar2
  as
    new_position varchar2(100);
    return_positions varchar2(2000);
    player_occupying_square number;
    n number;
    stop_moving boolean;
  begin
    stop_moving := false;
    dbms_output.put_line('  move_in_direction:' || p_max_distance_per_move || ':Delta:' || p_x_steps || ',' || p_y_steps || ' New:' || new_xpos || ',' || new_ypos);
    for step in 1..p_max_distance_per_move loop
      new_xpos := nvl(new_xpos, p_piece.xpos) + p_x_steps;
      new_ypos := nvl(new_ypos, p_piece.ypos) + p_y_steps;
      
      if not stop_moving then
        dbms_output.put_line('  step-' || step || ':' || new_xpos || ',' || new_ypos);

        -- if out of bounds then don't move further
        if new_xpos < 1 or new_xpos > 8 or new_ypos < 1 or new_ypos > 8 then
          new_position:='';
          ended_on:='edge';
          stop_moving := true;
          dbms_output.put_line('  Returning: landed on edge @ '|| new_xpos || ',' || new_ypos);
        else
          select max(player) into n from gm_board_pieces where game_id=p_piece.game_id and xpos=new_xpos and ypos=new_ypos;
          -- occupied
          if  (n is not null) then
            --select player into n from gm_board_pieces where game_id=p_piece.game_id and xpos=new_xpos and ypos=new_ypos;
            stop_moving := true;
            -- occupied by another player's piece and NOT a system piece (e.g. Lock) ** TODO: Check for capture direction **
            if n <> p_piece.player and n <> 3 then
              dbms_output.put_line('test capture:' || move_step || '-' || p_piece_type.capture_directions || ' test=' || instr(nvl(p_piece_type.capture_directions,move_step),move_step));
              if instr(nvl(p_piece_type.capture_directions,move_step),move_step) > 0 then
                dbms_output.put_line('allow capture');
                new_position:= ':loc-' || new_xpos || '-' || new_ypos || ':';
                ended_on:='nme';
              else
                apex_debug_message.log_message('disallow capture',true,1);
                new_position:='';
                ended_on:='xcap';
              end if;
            else
                new_position:='';
                ended_on:='own';
            end if;
            dbms_output.put_line('  Returning: landed on ' || ended_on || ' @ '|| new_xpos || ',' || new_ypos);
            stop_moving := true;
          else
            ended_on:='';
            -- not occupied - make sure that this is a location we can move into.
            if instr(nvl(p_piece_type.move_directions,move_step),move_step) > 0 then
                new_position := ':loc-' || new_xpos || '-' || new_ypos;
            else
                new_position:='';
                ended_on := 'xmove';
                stop_moving := true;
            end if;
          end if; -- if occupied
        end if; -- in bounds;
        
      end if; -- if not stop_moving
      
      if p_piece_type.can_jump = 1 then
        --return_positions := return_positions || new_position;
        null;
      elsif stop_moving and ended_on = 'nme' then
        return_positions := return_positions || new_position;
        dbms_output.put_line('  NewLoc+Capture: @ '|| new_xpos || ',' || new_ypos);   
        exit;
      elsif not stop_moving then
        return_positions := return_positions || new_position;
        dbms_output.put_line('  NewLoc: @ '|| new_xpos || ',' || new_ypos);
      end if;
    end loop; 
    dbms_output.put_line('RETURNING: ' || return_positions);
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
    v_directions_allowed varchar2(100);
    move_step varchar(1);
    n_moves_made_by_piece  number;
    new_x number;
    new_y number;
    new_position varchar2(50);
    y_direction number;
    distance_per_step number;
    step number;
    max_distance_per_move number;
    next_position varchar2(100);
    stop_moving boolean;
    ended_on varchar2(10);
  begin
  
    select P.* into v_piece from gm_board_pieces P where P.piece_id = p_piece_id and P.game_id=p_game_id;
    
    if v_piece.status = 0 then
      return '';
    end if;
    
    select PT.* into v_piece_type from gm_piece_types PT where PT.piece_type_code = v_piece.piece_type_code and PT.game_id=p_game_id;
    
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
    
    v_directions_allowed := case  
                             when v_piece_type.directions_allowed = '+' then '^:v:<:>'
                             when v_piece_type.directions_allowed = 'X' then '\:/:L:J'
                             when v_piece_type.directions_allowed = 'O' then '^:v:<:>:\:/:L:J'
                             else
                                v_piece_type.directions_allowed
                        end; 
    select count(*) into n_moves_made_by_piece from gm_game_history where game_id=p_game_id and piece_id=p_piece_id and player > 0;
    
    if n_moves_made_by_piece = 0 and v_piece_type.first_move is not null then
      v_move_choices := apex_util.string_to_table(v_piece_type.first_move,':');
      dbms_output.put_line('---> Number of choices: ' || v_move_choices.count || ' from "' || v_piece_type.first_move || '"' );
    else
      v_move_choices := apex_util.string_to_table(v_directions_allowed,':');
      dbms_output.put_line('---> Number of choices: ' || v_move_choices.count || ' from "' || v_directions_allowed || '"' );
    end if;
    
    for z in 1..v_move_choices.count loop
      move_choice := v_move_choices(z);
      new_x := null;
      new_y := null;
      dbms_output.put_line('');
      dbms_output.put_line('[DEBUG0: move_choice=' || move_choice || ']**');
      for c in 1..length(move_choice) loop
        move_step := substr(move_choice,c,1);
        
        dbms_output.put_line('[DEBUG1:move_step-' || c || '=' || move_step || new_x || ',' || new_y || '] v_positions=' || v_positions || ' ended_on=' || ended_on);
        if move_step = '^' then
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, 0, distance_per_step, new_x, new_y, ended_on);
        elsif move_step = 'v'then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, 0, (-distance_per_step), new_x, new_y, ended_on);
        elsif move_step = '<' then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), 0, new_x, new_y, ended_on);
        elsif move_step = '>' then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (distance_per_step), 0, new_x, new_y, ended_on);
        elsif move_step = '\' then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (distance_per_step), (distance_per_step), new_x, new_y, ended_on);
        elsif move_step = '/' then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), (distance_per_step), new_x, new_y, ended_on);
        elsif move_step = 'L' then    
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), (-distance_per_step), new_x, new_y, ended_on);
        elsif move_step = 'J' then    
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (distance_per_step), (-distance_per_step), new_x, new_y, ended_on);
        end if;
        v_positions := v_positions || next_position;
        dbms_output.put_line('[DEBUG1:move_step-' || c || '=' || move_step || new_x || ',' || new_y || '] v_positions=' || v_positions || ' added=' || next_position || ' ended_on=' || ended_on);
      end loop; -- for c
      
      dbms_output.put_line('DEBUG2:ended_on=' || ended_on);      
      if (v_piece_type.can_jump = 1 and ended_on = 'nme') or ended_on is null then
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
  /*********************************************************************************************************************/
  function format_piece(p_game_id number, p_piece_id number, p_player_number number, p_piece_name nvarchar2, p_xpos number, p_ypos number) return nvarchar2 as
    v_piece_moves nvarchar2(1000);
    v_attacked_by nvarchar2(100);
  begin
    if p_piece_id is null then 
      return ' ';
    else
      with unique_moves as (      
          select distinct piece_move
          from gm_piece_moves 
          where game_id=p_game_id and piece_id=p_piece_id
      )
      select listagg(piece_move,':')  within group (order by 1) 
      into v_piece_moves
      from unique_moves
      group by 1;
      
      -- Figure out who is being attacked.
      begin      
        select listagg(piece_id,':') within group (order by 1)
          into v_attacked_by
          from gm_piece_moves NME 
          where NME.game_id = p_game_id and NME.player = 3 - p_player_number
          and NME.piece_move in (select 'loc-' || P.xpos || '-' || P.ypos from gm_board_pieces P where P.game_id = p_game_id and P.player = p_player_number and P.piece_id=p_piece_id)
        group by 1;
      exception
        when no_data_found then
          v_attacked_by := '';
      end;
      
      --- SVG images
      return '<div id="piece-' || p_piece_id || '" player=' || p_player_number 
                                || ' xpos=' || p_xpos || ' ypos=' || p_ypos || ' location="' || p_xpos || '.' || p_ypos 
                                || '" piece-name="' || p_piece_name  
                                || '" class="game-piece" type="game-piece"' 
                                || '" positions="' || v_piece_moves || '"'
                                || ' attacked_by="' || nvl(v_attacked_by,'') || '"'
                                --|| '" positions2="' || calc_valid_squares(p_game_id, p_piece_id)
                                || '"/>';  
    end if;
  
  end format_piece;

  /*********************************************************************************************************************/

  procedure AddMoveFor(p_game_id number, p_piece gm_board_pieces%rowtype, p_xpos number, p_ypos number) as
  begin
    apex_collection.add_member(p_collection_name => 'GAME_STATE', p_n001=>p_game_id, 
    p_c001 => p_piece.piece_type_code, p_n002 => p_piece.piece_id, p_n003 => p_piece.player,
    p_n004 => p_xpos, p_n005 => p_ypos);

  end;

  /*************************************************************************************************************/
  procedure generate_piece_moves(p_game_id number) as
    v_moves varchar(1000);
    v_moves_array apex_application_global.vc_arr2;
    v_move number;
    v_xpos number;
    v_ypos number;
    v_exists number;
  begin

    if APEX_COLLECTION.COLLECTION_EXISTS (p_collection_name => 'GAME_STATE') = true then
      APEX_COLLECTION.DELETE_MEMBERS('GAME_STATE', '1', p_game_id);
    else
      APEX_COLLECTION.CREATE_COLLECTION('GAME_STATE');
    end if;

    for P in (select * from gm_board_pieces where game_id=p_game_id) loop
    
      -- TODO: Get rid of the loc-XX-YY logic
      v_moves := calc_valid_squares(p_game_id, p.piece_id);
      if v_moves is not null then
        v_moves_array:= apex_util.string_to_table(v_moves, ':');
        
        for v_move in 1..v_moves_array.count
        loop
         if v_moves_array(v_move) is not null then
            select count(*) into v_exists from gm_piece_moves C where C.piece_id = P.piece_id and C.player = P.player and C.game_id = P.game_id and C.piece_move = v_moves_array(v_move);
            if v_exists = 0 then
              apex_collection.add_member(p_collection_name => 'GAME_STATE', 
                                          p_c001 => P.game_id, 
                                          p_c002 => P.piece_type_code,
                                          p_c003 => v_moves_array(v_move),
                                          p_c004 => calc_valid_squares(p_game_id, p.piece_id),
    
                                          p_n001 => P.piece_id,
                                          p_n002 => P.player,
                                          p_n003 => P.game_id,
                                          p_n004 => P.xpos,
                                          P_n005 => P.ypos
                                          );
            end if;
         end if;
        end loop;      
      end if; /* if moves is not null */
    end loop;

    -- Kings cannot move into check - non-pawns

    for M in (
      select seq_id
      from gm_piece_moves P
      where P.game_id = p_game_id
        and P.piece_type_code='KING' 
        and P.piece_move in (select NME.piece_move 
                              from gm_piece_moves NME 
                              where NME.game_id = p_game_id 
                                and NME.player = 3 - P.player and NME.piece_type_code <> 'PAWN' )
    ) loop
      apex_collection.delete_member(p_collection_name => 'GAME_STATE', p_seq => M.seq_id);
    end loop;
    
    -- Kings cannot move into check -- pawns have diagonal attacks
    for M in (
      select seq_id
      from gm_piece_moves P
      where P.game_id = p_game_id
        and P.piece_type_code='KING' 
        and P.piece_move in (select 'loc-' || xpos || '-' || ypos pawn_attacks
                              from (
                                select xpos-1 xpos, ypos+1 ypos, player from gm_board_pieces 
                                where game_id=p_game_id and piece_type_code='PAWN'
                                union all
                                select xpos+1 xpos, ypos+1 ypos, player from gm_board_pieces 
                                where game_id=p_game_id and piece_type_code='PAWN'
                              ) where xpos>0 and xpos <9  and player=3 - P.player)
    ) loop
          apex_collection.delete_member(p_collection_name => 'GAME_STATE', p_seq => M.seq_id);
    end loop;
  
  end generate_piece_moves;

end GM_PIECE_LIB;
/
