/*** GM_GAMEDEF_SCHEMA ***/
drop table gm_gamedef_pieces;
drop table gm_gamedef_piece_types;
drop table gm_gamedef_css;
drop table gm_gamedef_layout;
drop table gm_gamedef_squaretypes;
drop table gm_gamedef_boards;
/
create table gm_gamedef_boards
(
  gamedef_code varchar2(8),
  gamedef_name varchar2(50),
  max_rows number,
  max_cols number,
  constraint gm_gd_boards_pk primary key (gamedef_code)
);
/
create table gm_gamedef_squaretypes
(
  square_type_code varchar2(8),
  gamedef_code varchar2(8),
  square_type_name varchar2(20),
  constraint gm_gd_squaretypes_pk primary key (gamedef_code, square_type_code),
  constraint gm_gd_squaretypes_gd_fk foreign key(gamedef_code) references gm_gamedef_boards(gamedef_code)
);
/
create table gm_gamedef_layout
(
  gamedef_code varchar2(8),
  
  xpos number,
  ypos number,
  square_type_code varchar2(8),
  constraint gm_gd_layout_pk primary key (gamedef_code, xpos, ypos),
  constraint gm_gd_layout_gd_fk foreign key(gamedef_code) references gm_gamedef_boards(gamedef_code),
  constraint gm_gd_layout_st_fk foreign key(gamedef_code, square_type_code) references gm_gamedef_squaretypes(gamedef_code, square_type_code)
);
/
create table gm_gamedef_piece_types
(
  gamedef_code varchar2(8),
  piece_type_code varchar2(8),

  piece_name varchar2(50),
  piece_notation varchar2(1),
  
  n_steps_per_move number,
  can_jump number,
  first_move varchar2(50),
  directions_allowed varchar2(50),
  capture_directions varchar2(50),
  move_directions varchar2(50),
  constraint gm_gd_piecetype_pk primary key (gamedef_code, piece_type_code),
  constraint gm_gd_piecetype_gd_fk foreign key(gamedef_code) references gm_gamedef_boards(gamedef_code)
);
/
create table gm_gamedef_pieces
(
  gamedef_code varchar2(8),
  piece_type_code varchar2(8),
  piece_id number,
  xpos number,
  ypos number,
  player varchar2(50),
  status number,
  constraint gm_gd_piece_pk primary key (gamedef_code, piece_id),
  constraint gm_gd_piece_gd_fk foreign key(gamedef_code) references gm_gamedef_boards(gamedef_code),
  constraint gm_gd_piece_pt_fk foreign key(gamedef_code,piece_type_code) references gm_gamedef_piece_types(gamedef_code,piece_type_code)
);
/
create table gm_gamedef_css
(
  gamedef_code varchar2(8),
  css_selector varchar(100),
  css_definition varchar(2000),
  css_order number,
  constraint gm_gd_css_pk primary key (gamedef_code, css_selector),
  constraint gm_gd_css_fk foreign key(gamedef_code) references gm_gamedef_boards(gamedef_code)
)
/
