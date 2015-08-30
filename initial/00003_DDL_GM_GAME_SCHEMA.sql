alter session set current_schema=apex_gm;

drop table GM_GAMES;
drop sequence GM_GAMES_seq;
drop table gm_boards;
drop table gm_board_states;
drop table gm_piece_types;
drop sequence gm_piece_types_seq;
drop table gm_board_pieces;
drop sequence gm_board_pieces_id;
/

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
  constraint board_id_pk primary key (game_id, ypos)

);
/
create table gm_piece_types
(
  game_id number,
  piece_type_id varchar2(20),
  piece_name varchar2(50),
  n_steps_per_move number,
  can_jump number,
  directions_allowed varchar2(100),
  svg_url varchar2(1000)
);
/
create sequence gm_piece_types_seq;
/
create table gm_board_pieces
(
  game_id number,
  piece_type_id varchar2(20),
  piece_id number,
  xpos number,
  ypos number,
  player varchar2(50),
  status number
);
/
create sequence gm_board_pieces_id;
/