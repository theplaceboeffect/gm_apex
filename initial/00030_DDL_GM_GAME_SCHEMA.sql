alter session set current_schema=apex_gm;
/*
drop table GM_GAMES;
drop sequence GM_GAMES_seq;
drop table gm_boards;
drop table gm_board_states;
drop table gm_piece_types;
drop sequence gm_piece_types_seq;
drop table gm_board_pieces;
drop sequence gm_board_pieces_id;
*/

create table  gm_games 
(	
  game_id number,
  player1 nvarchar2(50),
  player2 nvarchar2(50),
  gamestart_timestamp date,
  lastmove_timestamp date,
  lastmove_count number,
  constraint game_id_pk primary key (game_id)
)
/
create sequence gm_games_seq;
/
create table gm_boards
(
  game_id number,
  board_type varchar2(20),
  max_rows number,
  max_cols number
);

create table gm_board_states
(
  game_id number,
  y_pos number,
  cell_1 number,
  cell_2 number,
  cell_3 number,
  cell_4 number,
  cell_5 number,
  cell_6 number,
  cell_7 number,
  cell_8 number,
  cell_9 number,
  cell_10 number,
  cell_11 number,
  cell_12 number,
  constraint board_id_pk primary key (game_id, y_pos)

);
/
create table gm_piece_types
(
  game_id number,
  piece_type_id number,
  piece_name varchar2(50),
  n_steps_per_move number,
  directions_allowed varchar2(100),
  svg_url varchar2(1000)
);
/
create sequence gm_piece_types_seq;
/
create table gm_board_pieces
(
  game_id number,
  piece_type_id number,
  piece_id number,
  x_pos number,
  y_pos number,
  player varchar2(50),
  status number
);
/
create sequence gm_board_pieces_id;
/