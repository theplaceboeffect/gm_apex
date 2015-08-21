alter session set current_schema=apex_gm;


create or replace package GM_GAME_LIB as

  function new_game(p_player1 nvarchar2, p_player2 nvarchar2) return number;
  procedure output_board_config(p_game_id number);
  procedure move_piece(p_game_id number,  p_piece_id number, p_x_location number, p_y_location number);


end GM_GAME_LIB;
/
create or replace package body GM_GAME_LIB as

  procedure make_chess_board(p_game_id number) as
    v_row_number number;
    v_board_id number;
  begin

    -- Initialize the game board.
    insert into gm_boards(game_id, max_cols, max_rows, board_type, lastmove_count) 
                values (p_game_id, 8, 8, 'chess', 0);

    for v_row_number in 0..3
    loop

      insert into gm_board_states(game_id, row_number, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7, cell_8) 
                  values (p_game_id, (v_row_number*2)+2,  0, 1, 0, 1, 0, 1, 0, 1);
      insert into gm_board_states(game_id, row_number, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7, cell_8) 
                  values (p_game_id, (v_row_number*2)+1,  1, 0, 1, 0, 1, 0, 1, 0);
      
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
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 1, 'pawn', 1, 'F', V('APP_IMAGES') || 'pawn.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 2, 'bishop', 0, 'A',V('APP_IMAGES')||'bishop.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 3, 'knight', 1, 'F1L2:F1R2:F2L1:F2R1',V('APP_IMAGES')||'knight.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 4, 'rook', 0, 'O',V('APP_IMAGES')||'rook.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 5, 'queen', 0, 'A', V('APP_IMAGES')||'queen.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 6, 'king', 1, 'A', V('APP_IMAGES')||'king.svg');

    -- Place white pieces
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,4,101,1,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,3,102,2,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,2,103,3,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,5,104,4,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,6,105,5,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,2,106,6,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,3,107,7,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,4,108,8,1,1,1);
  
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,109,1,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,110,2,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,111,3,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,112,4,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,113,5,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,114,6,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,115,7,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,116,8,2,1,1);
    
    -- Place black pieces
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,4,201,1,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,3,202,2,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,2,203,3,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,5,204,4,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,6,205,5,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,2,206,6,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,3,207,7,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,4,208,8,8,2,1);
  
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,209,1,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,210,2,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,211,3,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,212,4,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,213,5,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,214,6,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,215,7,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, x_location, y_location, player, status) values(p_game_id,1,216,8,7,2,1);

  end make_chess_board;
  
  function new_game(p_player1 nvarchar2, p_player2 nvarchar2) return number
  as
    v_p_game_id number;
  begin
    select gm_games_seq.nextval into v_p_game_id from sys.dual;  
    insert into gm_games(game_id,   player1,  player2,  gamestart_timestamp,  lastmove_timestamp) 
                  values(v_p_game_id, p_player1, p_player2, sysdate, sysdate);
    
    make_chess_board(v_p_game_id);
    
    return v_p_game_id;
  end new_game;
  
  procedure move_piece(p_game_id number,  p_piece_id number, p_x_location number, p_y_location number)
  as
  begin
    log_message('move_piece: [p_game_id:' || p_game_id || '][p_piece_id:' || p_piece_id || '][x: ' || p_x_location || '][y: ' || p_y_location || ']');

    update gm_board_pieces
    set x_location=p_x_location, y_location=p_y_location
    where game_id = p_game_id
      and piece_id = p_piece_id;

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