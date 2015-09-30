alter session set current_schema=apex_gm;

create or replace package GM_CHESS as
  procedure create_board(p_game_id number);  
end GM_CHESS;
/

create or replace package body GM_CHESS as
  /*********************************************************************************************************************/
  procedure create_board(p_game_id number) as
    v_ypos number;
    v_board_id number;
    CAN_JUMP constant number := 1;
    CANNOT_JUMP constant number := 0;
  begin

    -- Initialize the game board.
    insert into gm_boards(game_id, max_cols, max_rows, board_type) 
                values (p_game_id, 8, 8, 'chess');

    for v_ypos in 0..3
    loop

      insert into gm_board_states(game_id, ypos, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7, cell_8) 
                          values (p_game_id, (v_ypos*2)+2,  0, 1, 0, 1, 0, 1, 0, 1);
      insert into gm_board_states(game_id, ypos, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7, cell_8) 
                          values (p_game_id, (v_ypos*2)+1,  1, 0, 1, 0, 1, 0, 1, 0);      
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
    insert into gm_piece_types(game_id,piece_type_id, piece_name, can_jump, n_steps_per_move, directions_allowed, svg_url) 
                         values(p_game_id, 1, 'pawn', CANNOT_JUMP,  1, '^', V('APP_IMAGES') || 'pawn.svg');
                         
    insert into gm_piece_types(game_id,piece_type_id, piece_name, can_jump, n_steps_per_move, directions_allowed, svg_url)
                         values(p_game_id, 2, 'bishop', CANNOT_JUMP, 0, 'X', V('APP_IMAGES')||'bishop.svg');
                         
    insert into gm_piece_types(game_id,piece_type_id, piece_name, can_jump, n_steps_per_move, directions_allowed, svg_url) 
                         values(p_game_id, 3, 'knight', CAN_JUMP, 1, '^^>:^^<:vv<:vv>:>>^:>>v:<<^:<<v'  ,V('APP_IMAGES')||'knight.svg'); -- 
                         
    insert into gm_piece_types(game_id,piece_type_id, piece_name, can_jump, n_steps_per_move, directions_allowed, svg_url) 
                        values(p_game_id, 4, 'rook',  CANNOT_JUMP, 0, '+', V('APP_IMAGES')||'rook.svg');
                        
    insert into gm_piece_types(game_id,piece_type_id, piece_name, can_jump, n_steps_per_move, directions_allowed, svg_url) 
                        values(p_game_id, 5, 'queen', CANNOT_JUMP, 0, 'O', V('APP_IMAGES')||'queen.svg');
                        
    insert into gm_piece_types(game_id,piece_type_id, piece_name, can_jump, n_steps_per_move, directions_allowed, svg_url) 
                        values(p_game_id, 6, 'king', CANNOT_JUMP, 1, 'O', V('APP_IMAGES')||'king.svg');
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
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,4,101,1,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,3,102,2,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,2,103,3,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,5,104,4,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,6,105,5,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,2,106,6,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,3,107,7,1,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,4,108,8,1,1,1);
  
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,109,1,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,110,2,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,111,3,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,112,4,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,113,5,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,114,6,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,115,7,2,1,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,116,8,2,1,1);
    
    -- Place black pieces
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,4,201,1,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,3,202,2,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,2,203,3,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,5,204,4,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,6,205,5,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,2,206,6,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,3,207,7,8,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,4,208,8,8,2,1);
  
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,209,1,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,210,2,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,211,3,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,212,4,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,213,5,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,214,6,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,215,7,7,2,1);
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status) values(p_game_id,1,216,8,7,2,1);

  end create_board;

end GM_CHESS;