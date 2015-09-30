
delete from gm_gamedef_piece_types where piece_type_code='LOCK';
insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                    values('CHESS', 'LOCK', 'lock', 'X', 0, 0, null, null, null, 0);
-- Board icon for lock
delete from gm_gamedef_css where css_selector='[player="3"][piece-name="lock"]:before';
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="3"][piece-name="lock"]:before' ,'{ font-family: FontAwesome; content: "\f023"; color: #F17171; font-size: 50px; position: absolute; top: 19px; left: 8px; }',100);

-- History icon for lock
delete from gm_gamedef_css where css_selector='[player="3"][piece-name="Hlock"]:before';
insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="3"][piece-name="Hlock"]:before' ,'{ font-family: FontAwesome; content: "\f023"; color: #F17171; font-size: 20px;  }',100);
commit;
/

create or replace package gm_card_lib as
  procedure cards_init;
  procedure board_init(p_game_id number);
  procedure process_card(p_game_id number, p_piece_id varchar2, p_xpos number, p_ypos number);
  
end gm_card_lib;
/
create or replace package body gm_card_lib as

  procedure cards_init as
  begin
    delete from gm_board_cards;

    delete from gm_gamedef_cards;
    
    
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine) 
                          values('OP2B', 'CHESS%', 'PIECE','PAWN', 'OWN', 'Pawn To Bishop', 'Change one of your Pawns into a Bishop.', 'BISHOP', 'REPLACE');
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('OP2N', 'CHESS%', 'PIECE','PAWN', 'OWN', 'Pawn To Knight', 'Change one of your Pawns into a Knight.', 'KNIGHT', 'REPLACE');
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('OP2R', 'CHESS%', 'PIECE','PAWN', 'OWN', 'Pawn To Rook', 'Change one of your Pawns into a Rook.', 'ROOK', 'REPLACE');
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('OP2Q', 'CHESS%', 'PIECE','PAWN', 'OWN', 'Pawn To Queen', 'Change one of your Pawns into a Queen.', 'QUEEN', 'REPLACE');
    
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('OA2P', 'CHESS%', 'PIECE','ANY', 'OWN', 'Any To Pawn', 'Change any of your own pieces into a pawn.', 'PAWN', 'REPLACE');
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('OA2Q', 'CHESS%', 'PIECE','ANY', 'OWN', 'Any To Queen', 'Change any of your own pieces into a queen.', 'QUEEN', 'REPLACE');
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('OB2N', 'CHESS%', 'PIECE','BISHOP', 'OWN', 'Any Bishop To Knight', 'Change any of your own bishops into a knight.', 'KNIGHT', 'REPLACE');
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('NA2P', 'CHESS%', 'PIECE','ANY', 'NME', 'Any To Pawn', 'Change any of your opponent''s piece into a pawn.', 'PAWN', 'REPLACE');
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('AA2P', 'CHESS%', 'PIECE','ANY', 'ANY', 'Any To Pawn', 'Change any piece into a pawn.', 'PAWN', 'REPLACE');
    
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('RMSQ', 'CHESS%', 'BOARD','EMPTY', 'NONE', 'Remove square', 'Remove square from play.', '', 'BOARD_CHANGE');
    insert into gm_gamedef_cards(gamedef_card_code, gamedef_code, used_for_class, used_for_piece_type_code, used_for_player, card_name, card_description, parameter1, routine)
                          values('MKSQ', 'CHESS%', 'PIECE','LOCK', 'SYS', 'Add square', 'Add square to play.', 'LOCK', 'BOARD_CHANGE');
  end;

  procedure board_init(p_game_id number) as
  begin

    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 1, 1, 'OP2B');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 2, 1, 'OP2N');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 3, 1, 'OP2R');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 4, 1, 'OP2Q');
    
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 5, 1, 'OA2P');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 6, 1, 'OA2P');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 7, 1, 'NA2P');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 8, 1, 'OA2Q');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 9, 1, 'OB2N');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 10, 1, 'RMSQ');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 11, 1, 'MKSQ');
    
    
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 12, 2, 'OA2P');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 13, 2, 'OA2Q');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 14, 2, 'OP2Q');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 15, 2, 'NA2P');
    --insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 13, 2, 'AA2P');
    
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 16, 0, 'OP2R');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 17, 0, 'OP2R');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 18, 2, 'OA2Q');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 19, 2, 'OB2N');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 20, 2, 'RMSQ');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 21, 2, 'MKSQ');
  end board_init;

  procedure process_card(p_game_id number, p_piece_id varchar2, p_xpos number, p_ypos number)
  as
    v_card_id number;
    v_piece_id number;
    v_player number;
    v_p1_in_check number;
    v_p2_in_check number;
    v_old_piece_type_code varchar(10);
    v_move_number number;
    card_def gm_gamedef_cards%rowtype;
    piece gm_board_pieces%rowtype;
  begin 
  
    v_card_id := replace(p_piece_id,'card-','');
  
    log_message('Processing card: [game_id=' || p_game_id || '][piece_id=' || p_piece_id || '][' || p_xpos || ',' || p_ypos || '][v_card_id=' || v_card_id || ']');
  
    -- Get card definition.
    select D.* into card_def
    from gm_board_cards C
    join gm_gamedef_cards D on C.gamedef_card_code = D.gamedef_card_code
    where C.game_id = p_game_id and C.card_id = v_card_id;
    select C.player into v_player from gm_board_cards C where C.game_id = p_game_id and C.card_id = v_card_id;
  
    if card_def.gamedef_card_code = 'RMSQ' then
      select nvl(max(piece_id),1000) + 1 into v_piece_id from gm_board_pieces where game_id=p_game_id and piece_type_code='LOCK';
      insert into gm_board_pieces(game_id, piece_id, piece_type_code, xpos, ypos, player, status) values(p_game_id, v_piece_id, 'LOCK', p_xpos, p_ypos,3,1);
      
      insert into gm_game_history(game_id,  piece_id, card_id, player, old_xpos, old_ypos, new_xpos, new_ypos, action, action_piece, action_parameter)
                             values(p_game_id, v_piece_id, v_card_id, v_player , p_xpos, p_ypos, 0, 0, 'CARD', v_card_id, v_old_piece_type_code);
                             

    elsif card_def.gamedef_card_code = 'MKSQ' then
      update gm_board_pieces set xpos=0,ypos=0,status=0 where game_id=p_game_id and xpos=p_xpos and ypos=p_ypos;  
    
      insert into gm_game_history(game_id,  piece_id, card_id, player, old_xpos, old_ypos, new_xpos, new_ypos, action, action_piece, action_parameter)
                             values(p_game_id, v_piece_id, v_card_id, v_player , p_xpos, p_ypos, 0, 0, 'CARD', v_card_id, v_old_piece_type_code);

    elsif card_def.routine = 'REPLACE' then
      -- TODO: Verify that the piece being replaced matches the card used_for_piece_type_code
    
      -- Retrieve the piece to apply the card onto
      select P.piece_id,  P.piece_type_code into v_piece_id, v_old_piece_type_code
      from gm_board_pieces P
      where P.xpos = p_xpos and P.ypos = p_ypos and P.game_id = p_game_id;
  
      -- Apply card.    
      update gm_board_pieces P
      set p.piece_type_code = card_def.parameter1
      where P.piece_id = v_piece_id;
    
    
    end if;
/* TODO: Put this back before release!
    -- Consume card.
    update gm_board_cards C
    set player = 0
    where C.game_id = p_game_id and C.card_id = v_card_id;
 */
 
     -- generate next set of moves
    gm_piece_lib.generate_piece_moves(p_game_id);
    
    -- check
    -- update history table.
    select current_move into v_move_number from gm_games where game_id = p_game_id;
    v_p1_in_check := gm_piece_lib.is_king_in_check(p_game_id,1);
    v_p2_in_check := gm_piece_lib.is_king_in_check(p_game_id,2);
    gm_piece_lib.remove_king_moves(p_game_id);

    -- Record card use.
    select current_move into v_move_number from gm_games where game_id = p_game_id;
    insert into gm_game_history(game_id,  piece_id, card_id, player, old_xpos, old_ypos, new_xpos, new_ypos, action, action_piece, action_parameter, move_number)
                           values(p_game_id, v_piece_id, v_card_id, v_player , p_xpos, p_ypos, 0, 0, 'CARD', v_card_id, v_old_piece_type_code, v_move_number);
  
  end;
end gm_card_lib;
/
