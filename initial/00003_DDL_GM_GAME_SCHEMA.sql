/**** GM_GAME_SCHEMA ****/
drop table gm_css;
drop table gm_game_history;
drop table gm_board_pieces;
drop table gm_piece_types;
drop table gm_board_states;
drop table gm_boards;
drop table gm_games;

drop sequence gm_piece_types_seq;
drop sequence GM_GAMES_seq;
drop sequence gm_board_pieces_id;
drop sequence gm_game_history_seq;
/

create table  gm_games 
(	
  game_id number,
  player1 nvarchar2(50),
  player2 nvarchar2(50),
  current_player number,
  gamestart_timestamp date,
--  lastmove_timestamp date,
--  lastmove_count number,
  constraint game_id_pk primary key (game_id)
);
/
create sequence gm_games_seq;
/
create table gm_boards
(
  game_id number,
  board_type varchar2(20),
  max_rows number,
  max_cols number,
  
  constraint boards_id_pk primary key (game_id),
  constraint boards_game_id_fk foreign key (game_id) references gm_games(game_id)

);
/
create table gm_board_states
(
  game_id number,
  ypos number,
  cell_1 varchar2(11),
  cell_2 varchar2(11),
  cell_3 varchar2(11),
  cell_4 varchar2(11),
  cell_5 varchar2(11),
  cell_6 varchar2(11),
  cell_7 varchar2(11),
  cell_8 varchar2(11),
  cell_9 varchar2(11),
  cell_10 varchar2(11),
  cell_11 varchar2(11),
  cell_12 varchar2(11),

  constraint board_states_id_pk primary key (game_id, ypos),
  constraint board_states_game_id_fk foreign key (game_id) references gm_games(game_id)

);
/
create table gm_piece_types
(
  game_id number,
  piece_type_code varchar2(20),
  piece_name varchar2(50),
  n_steps_per_move number,
  can_jump number,
  first_move varchar2(50),
  directions_allowed varchar2(50),
  capture_directions varchar2(50),
  move_directions varchar2(50),
  
  constraint piece_types_id_pk primary key (game_id, piece_type_code),
  constraint piece_types_game_id_fk foreign key (game_id) references gm_games(game_id)
);
/
create sequence gm_piece_types_seq;
/
create table gm_board_pieces
(
  game_id number,
  piece_id number,
  piece_type_code varchar2(20),
--  num_moves_made number,
  xpos number,
  ypos number,
  player number,
  status number,

  constraint board_pieces_id_pk primary key (game_id, piece_id),
  constraint board_pieces_piece_type_fk foreign key (game_id, piece_type_code) references gm_piece_types(game_id, piece_type_code),
  constraint board_pieces_game_id_fk foreign key (game_id) references gm_games(game_id)
);

/
create sequence gm_board_pieces_id;
/
create sequence gm_game_history_seq;
/
create table gm_game_history
(
  history_id number,
  game_id number,
  piece_id number,
  card_id number,
  player number,
  old_xpos number,
  old_ypos number,
  new_xpos number,
  new_ypos number,
  action varchar2(20),
  action_piece number,
  action_parameter varchar2(50),
  move_time date default sysdate,
  
  constraint game_history_pk primary key (history_id),
  constraint game_history_fk foreign key (game_id, piece_id) references gm_board_pieces(game_id, piece_id)

);
/
set define off;
create trigger bi_gm_game_history
before insert on gm_game_history
for each row
begin
  if :new.history_id is null then
    select gm_game_history_seq.nextval into :new.history_id from dual;
  end if;
end;
/
create table gm_css
(
  css_id number,
  css_selector varchar2(100),
  css_declaration_block varchar2(1000),
  
  constraint gm_css_pk primary key(css_id),
  constraint gm_css_unique_selector unique(css_selector)
);
/
