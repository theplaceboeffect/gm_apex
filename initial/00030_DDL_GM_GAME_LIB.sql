create or replace package body GM_GAME_LIB as

  procedure make_checkers_board(p_game_id number) as
    v_row_number number;
    v_board_id number;
  begin

    -- Initialize the game board.
    insert into gm_boards(game_id, max_cols, max_rows, board_type) 
                values (p_game_id, 8, 8, 'chess');

    for v_row_number in 0..3
    loop

      insert into gm_board_states(game_id, row_number, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7, cell_8) 
                  values (p_game_id, (v_row_number*2)+2,  0, 1, 0, 1, 0, 1, 0, 1);
      insert into gm_board_states(game_id, row_number, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7, cell_8) 
                  values (p_game_id, (v_row_number*2)+1,  1, 0, 1, 0, 1, 0, 1, 0);
      
    end loop;
    
    -- Initialize the pieces
    -- A = all directions
    -- F = forward
    -- F1L2 = forward 1, right 2
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 1, 'pawn', 1, 'F','https://upload.wikimedia.org/wikipedia/commons/d/d3/Chess_pgt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 2, 'bishop', 0, 'A','https://upload.wikimedia.org/wikipedia/commons/0/0e/Chess_bgt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 3, 'knight', 1, 'F1L2:F1R2:F2L1:F2R1','https://upload.wikimedia.org/wikipedia/commons/1/13/Chess_ngt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 4, 'rook', 0, 'O','https://upload.wikimedia.org/wikipedia/commons/8/85/Chess_rgt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 5, 'queen', 0, 'A', 'https://upload.wikimedia.org/wikipedia/commons/4/41/Chess_qgt45.svg');
    insert into gm_piece_types(game_id,piece_type_id, piece_name, n_steps_per_move, directions_allowed, svg_url) values(p_game_id, 6, 'king', 1, 'A', 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Chess_kgt45.svg');

    -- Place white pieces
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,4,1,1,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,3,2,1,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,2,3,1,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,5,4,1,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,6,5,1,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,2,6,1,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,3,7,1,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,4,8,1,1,1);
  
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,1,2,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,2,2,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,3,2,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,4,2,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,5,2,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,6,2,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,7,2,1,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,8,2,1,1);
    
    -- Place black pieces
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,4,1,8,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,3,2,8,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,2,3,8,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,5,4,8,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,6,5,8,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,2,6,8,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,3,7,8,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,4,8,8,2,1);
  
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,1,7,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,2,7,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,3,7,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,4,7,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,5,7,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,6,7,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,7,7,2,1);
    insert into gm_board_pieces(game_id,piece_type_id, x_location, y_location, player, status) values(p_game_id,1,8,7,2,1);
  end make_checkers_board;
  
  function new_game(p_player1 nvarchar2, p_player2 nvarchar2) return number
  as
    v_p_game_id number;
  begin
    select gm_games_seq.nextval into v_p_game_id from sys.dual;  
    insert into gm_games(game_id,   player1,  player2,  gamestart_timestamp,  lastmove_timestamp) 
                  values(v_p_game_id, p_player1, p_player2, sysdate, sysdate);
    
    make_checkers_board(v_p_game_id);
    
    return v_p_game_id;
  end new_game;
  
end GM_GAME_LIB;




    
