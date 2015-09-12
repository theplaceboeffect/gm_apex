/**** GM_GAME_LIB ****/
create or replace package GM_GAME_LIB as

  procedure move_card(p_game_id number, p_piece_id varchar2, p_xpos number, p_ypos number);
  procedure move_piece(p_game_id number, p_piece_id number, p_xpos number, p_ypos number);

  function new_game(p_player1 varchar2, p_player2 varchar2, p_game_type varchar2, p_fisher_game varchar2) return number;
  procedure output_board_config(p_game_id number);
end GM_GAME_LIB;
/
create or replace package body GM_GAME_LIB as

 

  /*********************************************************************************************************************/
  procedure move_card(p_game_id number, p_piece_id varchar2, p_xpos number, p_ypos number)
  as
  begin
    gm_card_lib.process_card(p_game_id, p_piece_id, p_xpos, p_ypos);
    update gm_games set current_player = 3 - current_player where game_id = p_game_id;
  end move_card;

  procedure move_piece(p_game_id number, p_piece_id number, p_xpos number, p_ypos number)
  as
  begin
    gm_piece_lib.move_piece(p_game_id, p_piece_id, p_xpos, p_ypos);
    update gm_games set current_player = 3 - current_player where game_id = p_game_id;
  end move_piece;

/*******************************************************************************************/
  function new_game(p_player1 varchar2, p_player2 varchar2, p_game_type varchar2, p_fisher_game varchar2) return number
  as
    v_game_id number;
  begin
    select gm_games_seq.nextval into v_game_id from sys.dual;  
    insert into gm_games(game_id,   player1,  player2, current_player) 
                  values(v_game_id, p_player1, p_player2, 1);
    
    if p_game_type = 'FISHER' then 
      gm_gamedef_lib.create_board(v_game_id, p_fisher_game);
    else
      gm_gamedef_lib.create_board(v_game_id, p_game_type);
    end if;
    
    -- initialise cards.
    gm_card_lib.cards_init;
    gm_card_lib.board_init(v_game_id);
    
    
    -- update history table.
    insert into gm_game_history(game_id,piece_id,player, old_xpos, old_ypos, new_xpos, new_ypos)
        select v_game_id, piece_id, -1, null, null, xpos, ypos
        from gm_board_pieces 
        where game_id = v_game_id;
        
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
/
