alter session set current_schema=apex_gm;

--select gm_game_lib.gm_calc_valid_squares(3, 101) from dual;

create or replace package GM_GAME_LIB as

  function gm_move_in_direction( p_piece gm_board_pieces%rowtype, p_max_distance_per_move number,p_x_steps number, p_y_steps number, new_xpos in out number, new_ypos in out number) return nvarchar2;
  function gm_calc_valid_squares(p_game_id number, p_piece_id number) return varchar2;
  function format_piece(game_id number, piece_id number, player_number number, piece_name nvarchar2, svg_url nvarchar2, x_pos number, y_pos number) return nvarchar2;

  function new_game(p_player1 nvarchar2, p_player2 nvarchar2) return number;
  procedure output_board_config(p_game_id number);
  procedure move_piece(p_game_id number, p_piece_id number, p_x_pos number, p_y_pos number);

end GM_GAME_LIB;
/
create or replace package body GM_GAME_LIB as
  function gm_move_in_direction( p_piece gm_board_pieces%rowtype, p_max_distance_per_move number,p_x_steps number, p_y_steps number, new_xpos in out number, new_ypos in out number) return nvarchar2
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
      new_xpos := nvl(new_xpos, p_piece.x_pos) + step * p_x_steps;
      new_ypos := nvl(new_ypos, p_piece.y_pos) + step * p_y_steps;
      --return_positions := return_positions || '{' || new_xpos || ',' || new_ypos || ' step:' || step || ' ' || p_x_steps || ',' || p_y_steps || '}';
      
      if not stop_moving then
        -- if out of bounds then don't move further
        if new_xpos < 1 or new_xpos > 8 or new_ypos < 1 or new_ypos > 8 then
          new_position:='';
        else
          select count(*) into n from gm_board_pieces where game_id=p_piece.game_id and x_pos=new_xpos and y_pos=new_ypos;
          -- occupied
          if  (n <> 0) then
            select player into n from gm_board_pieces where game_id=p_piece.game_id and x_pos=new_xpos and y_pos=new_ypos;
            stop_moving := true;
            -- occupied by another player's piece ** TODO: Check for capture direction **
            if n <> p_piece.player then
                new_position:= 'loc-' || new_xpos || '-' || new_ypos || ':';
            else
                new_position:='';
            end if; 
          else
            -- not occupied.
            new_position := 'loc-' || new_xpos || '-' || new_ypos || ':';    
          end if; -- if occupied
        end if; -- in bounds;
        
      end if; -- if not stop_moving
      
      return_positions := return_positions || new_position;
    end loop; 
  
    return return_positions;
  end gm_move_in_direction;

  function gm_calc_valid_squares(p_game_id number, p_piece_id number) return varchar2
  as
  
    v_piece gm_board_pieces%rowtype;
    v_piece_definition gm_piece_types%rowtype;
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
  begin
  
    select P.* into v_piece from gm_board_pieces P where P.piece_id = p_piece_id and P.game_id=p_game_id;
    
    if v_piece.status = 0 then
      return '';
    end if;
    
    select PT.* into v_piece_definition from gm_piece_types PT where PT.piece_type_id = v_piece.piece_type_id and PT.game_id=p_game_id;
    
    -- Flip the y direction if the second player
    if v_piece.player = 1 then y_direction := 1; else y_direction := -1 ;end if;
    
    
    -- define the furthest a piece can move.
    if v_piece_definition.n_steps_per_move = 0 then
      max_distance_per_move := 8; --TODO: Replace with board size 
    else
      max_distance_per_move := v_piece_definition.n_steps_per_move;
    end if;

    -- define how many steps (currently 1) that a piece takes per move
    distance_per_step := (1 * y_direction);

    -- Current position is also valid!
    v_positions := 'loc-' || v_piece.x_pos || '-' || v_piece.y_pos || ':';
    
    v_move_choices := apex_util.string_to_table(v_piece_definition.directions_allowed,':');
    for z in 1..v_move_choices.count loop
      move_choice := v_move_choices(z);
      --v_positions:=v_positions||'**[DEBUG:move_choice' || move_choice || ']';
      new_x :=null;
      new_y :=null;
      
      for c in 1..length(move_choice) loop
        move_step := substr(move_choice,c,1);
        --v_positions := v_positions || '[DEBUG1:' || move_step || new_x || ',' || new_y || ']**' || chr(13);

        if move_step = '^' or move_step = '+' or move_step='O'then        
      new_x :=null;
      new_y :=null;
          v_positions := v_positions || gm_move_in_direction(v_piece, max_distance_per_move, 0, distance_per_step, new_x, new_y);
        end if;
    
        if move_step = 'v' or move_step = '+' or move_step='O'then        
      new_x :=null;
      new_y :=null;
          v_positions := v_positions || gm_move_in_direction(v_piece, max_distance_per_move, 0, (-distance_per_step), new_x, new_y);
        end if;
  
        if move_step = '<' or move_step = '+' or move_step='O'then        
      new_x :=null;
      new_y :=null;
          v_positions := v_positions || gm_move_in_direction(v_piece, max_distance_per_move, (-distance_per_step), 0, new_x, new_y);
        end if;
  
        if move_step = '>' or move_step = '+' or move_step='O'then        
      new_x :=null;
      new_y :=null;
          v_positions := v_positions || gm_move_in_direction(v_piece, max_distance_per_move, (distance_per_step), 0, new_x, new_y);
        end if;
  
        if move_step = 'X' or move_step='O' then    
      new_x :=null;
      new_y :=null;
          v_positions := v_positions || gm_move_in_direction(v_piece, max_distance_per_move, (distance_per_step), (-distance_per_step), new_x, new_y);
      new_x :=null;
      new_y :=null;
          v_positions := v_positions || gm_move_in_direction(v_piece, max_distance_per_move, (distance_per_step), (distance_per_step), new_x, new_y);
      new_x :=null;
      new_y :=null;
          v_positions := v_positions || gm_move_in_direction(v_piece, max_distance_per_move, (-distance_per_step), (-distance_per_step), new_x, new_y);
      new_x :=null;
      new_y :=null;
          v_positions := v_positions || gm_move_in_direction(v_piece, max_distance_per_move, (-distance_per_step), (distance_per_step), new_x, new_y);
        end if;
        --v_positions := v_positions || '[DEBUG2:' || move_step || new_x || ',' || new_y || ']**' || chr(13);
      end loop; -- for c    
    end loop; -- move_choice
  
    -- For each move combination (: - separated)
    -- For each direction:
    -- General piece
  
    return v_positions;
  end gm_calc_valid_squares;

  function format_piece(game_id number, piece_id number, player_number number, piece_name nvarchar2, svg_url nvarchar2, x_pos number, y_pos number) return nvarchar2 as
  begin
    if piece_id is null then 
      return ' ';
    else
    --- Unicode
    --return '<p id="piece-' || piece_id || '" player=' || player_number || ' xpos=1 ypos=' || y_pos || ' location="' || x_pos || '.' || y_pos || '" piece-name="' || piece_name  || '" class="game-piece">' || svg_url || '</p>';
  
    --- SVG images
    return '<img id="piece-' || piece_id || '" player=' || player_number 
                              || ' xpos=' || x_pos || ' ypos=' || y_pos || ' location="' || x_pos || '.' || y_pos 
                              || '" piece-name="' || piece_name  
                              || '" class="game-piece" type="image/svg+xml" src="' || svg_url 
                              || '" positions="' || gm_calc_valid_squares(game_id, piece_id)
                              || '"/>';
  
    --- Debugging
    --return '[' || piece_id , piece_name ) || x_pos || ',' || y_pos || ']';
    end if;
  
  end;

  procedure make_chess_board(p_game_id number) as
    v_y_pos number;
    v_board_id number;
  begin

    -- Initialize the game board.
    insert into gm_boards(game_id, max_cols, max_rows, board_type) 
                values (p_game_id, 8, 8, 'chess');

    for v_y_pos in 0..3
    loop

      insert into gm_board_states(game_id, y_pos, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7, cell_8) 
                          values (p_game_id, (v_y_pos*2)+2,  0, 1, 0, 1, 0, 1, 0, 1);
      insert into gm_board_states(game_id, y_pos, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7, cell_8) 
                          values (p_game_id, (v_y_pos*2)+1,  1, 0, 1, 0, 1, 0, 1, 0);
      
    end loop;
    
    -- Initialize the pieces
    /* Files on wikipedia
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 1, 'pawn', 1, 'F','https://upload.wikimedia.org/wikipedia/commons/d/d3/Chess_pgt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 2, 'bishop', 0, 'A','https://upload.wikimedia.org/wikipedia/commons/0/0e/Chess_bgt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 3, 'knight', 1, 'F1L2:F1R2:F2L1:F2R1','https://upload.wikimedia.org/wikipedia/commons/1/13/Chess_ngt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 4, 'rook', 0, 'O','https://upload.wikimedia.org/wikipedia/commons/8/85/Chess_rgt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 5, 'queen', 0, 'A', 'https://upload.wikimedia.org/wikipedia/commons/4/41/Chess_qgt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 6, 'king', 1, 'A', 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Chess_kgt45.svg');
    */
    --/* Local SVG
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 1, 'pawn',   1, '^'                                ,V('APP_IMAGES') || 'pawn.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 2, 'bishop', 0, 'X'                                ,V('APP_IMAGES')||'bishop.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 3, 'knight', 1, '^^>:^^<:vv<:vv>:>^^:<^^:>vv:<vv'  ,V('APP_IMAGES')||'knight.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 4, 'rook',   0, '+'                                ,V('APP_IMAGES')||'rook.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 5, 'queen',  0, 'O'                                ,V('APP_IMAGES')||'queen.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 6, 'king',   1, 'O'                                ,V('APP_IMAGES')||'king.svg');
    --*/
    /*
    -- Unicode
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 1, 'pawn', 1, 'F', '&#9817;');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 2, 'bishop', 0, 'A','&#9815;');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 3, 'knight', 1, 'F1L2:F1R2:F2L1:F2R1','&#9816;');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 4, 'rook', 0, 'O','&#9814;');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 5, 'queen', 0, 'A', '&#9813;');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 6, 'king', 1, 'A', '&#9812;');
    */
    
    -- Place white pieces
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,4,101,1,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,3,102,2,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,2,103,3,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,5,104,4,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,6,105,5,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,2,106,6,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,3,107,7,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,4,108,8,1,1,1);
  
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,109,1,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,110,2,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,111,3,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,112,4,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,113,5,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,114,6,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,115,7,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,116,8,2,1,1);
    
    -- Place black pieces
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,4,201,1,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,3,202,2,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,2,203,3,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,5,204,4,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,6,205,5,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,2,206,6,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,3,207,7,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,4,208,8,8,2,1);
  
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,209,1,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,210,2,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,211,3,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,212,4,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,213,5,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,214,6,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,215,7,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_pos, y_pos, player, status) values(p_game_id,1,216,8,7,2,1);

  end make_chess_board;
  
  function new_game(p_player1 nvarchar2, p_player2 nvarchar2) return number
  as
    v_p_game_id number;
  begin
    select gm_games_seq.nextval into v_p_game_id from sys.dual;  
    insert into gm_games(game_id,   player1,  player2,  gamestart_timestamp,  lastmove_timestamp, lastmove_count) 
                  values(v_p_game_id, p_player1, p_player2, sysdate, sysdate, 0);
    
    make_chess_board(v_p_game_id);
    
    return v_p_game_id;
  end new_game;
-- exec gm_game_lib.move_piece(3,109,1,5);
-- select * from gm_board_pieces where game_id = 3 and piece_id = 109;
-- select * from gm_board_pieces where game_id = 3 and x_pos=1 and y_pos=5;
-- select * from gm_board_pieces where status=0;
/*
select * from gm_board_pieces 
   where game_id = p_game_id
      and piece_id = p_piece_id
      and x_pos=p_x_pos
      and y_pos=p_y_pos
      and player <> v_player;
*/
procedure move_piece(p_game_id number, p_piece_id number, p_x_pos number, p_y_pos number)
  as
    n_pieces number;
    v_player number;
  begin
    --log_message('move_piece: [p_game_id:' || p_game_id || '][p_piece_id:' || p_piece_id || '][x: ' || p_x_pos || '][y: ' || p_y_pos || ']');

    select player into v_player from gm_board_pieces where game_id = p_game_id and piece_id = p_piece_id;
    
    
    update gm_board_pieces
    set status = 0, x_pos = 0, y_pos = 0
    where game_id = p_game_id
      and x_pos=p_x_pos
      and y_pos=p_y_pos
      and player <> v_player;
      -- move piece if not occupied
      --and not exists (select * from gm_board_pieces where game_id = p_game_id and x_pos=p_x_pos and y_pos=p_y_pos and player <> v_player);
    update gm_board_pieces
    set x_pos=p_x_pos, y_pos=p_y_pos
    where game_id = p_game_id
      and piece_id = p_piece_id
      -- move piece if not occupied
      and not exists (select * from gm_board_pieces where game_id = p_game_id and x_pos=p_x_pos and y_pos=p_y_pos);

    update gm_games set lastmove_count=lastmove_count+1 where game_id = p_game_id;
  end;
  
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