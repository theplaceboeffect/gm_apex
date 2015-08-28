alter session set current_schema=apex_gm;

/
/*********************************************************************************************************************/
create or replace package GM_GAMEDEF_LIB as
  procedure create_board(p_game_id number, p_game_name varchar2);  
end GM_GAMEDEF_LIB;
/
/*********************************************************************************************************************/
create or replace package body GM_GAMEDEF_LIB as
  /*********************************************************************************************************************/
  procedure create_board(p_game_id number, p_game_name varchar2) as
    
  begin
  
    -- Initialize the game board.
    insert into gm_boards(game_id, max_cols, max_rows, board_type) 
          select p_game_id, GD.max_cols, GD.max_rows, GD.gamedef_code
          from gm_gamedef_boards GD
          where GD.gamedef_code = p_game_name;

    -- Initialize the board squares
    insert into gm_board_states(game_id, ypos, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7, cell_8) 
    select p_game_id game_id, ypos
      , max(decode(xpos, 1, square_type_code)) cell_1
      , max(decode(xpos, 2, square_type_code)) cell_2
      , max(decode(xpos, 3, square_type_code)) cell_3
      , max(decode(xpos, 4, square_type_code)) cell_4
      , max(decode(xpos, 5, square_type_code)) cell_5
      , max(decode(xpos, 6, square_type_code)) cell_6
      , max(decode(xpos, 7, square_type_code)) cell_7
      , max(decode(xpos, 8, square_type_code)) cell_8
      --, max(decode(xpos, 9, location_name)) cell_9
      --, max(decode(xpos, 10, location_name)) cell_10
    from ( select ypos, xpos, square_type_code from gm_gamedef_layout where gamedef_code=p_game_name )
    group by ypos,p_game_id
    order by ypos;
    
    -- Initialize the pieces

    --/* Local SVG
    insert into gm_piece_types(game_id,piece_type_id, piece_name, can_jump, n_steps_per_move, directions_allowed) 
                  select p_game_id, piece_type_code, piece_name, can_jump, n_steps_per_move, directions_allowed 
                  from gm_gamedef_piece_types
                  where gamedef_code=p_game_name; 
                  
    -- Place white pieces
    insert into gm_board_pieces(game_id, piece_type_id, piece_id, xpos, ypos, player, status)
                select p_game_id, piece_type_code, piece_id, xpos, ypos, player, status
                from gm_gamedef_pieces
                where gamedef_code=p_game_name;

  end create_board;

end GM_GAMEDEF_LIB;