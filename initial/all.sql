/**** DDL_UTIL ****/

create or replace package GM_UTIL as
  function time_ago(dt date) return varchar2;
end GM_UTIL;
/
create or replace package body GM_UTIL as
  function time_ago(dt date) return varchar2 as
  n number;
  s varchar(10);
  begin
    n := round(sysdate - dt) * 24;
    s := 'hrs';
    
    if n = 0 then 
      n := round((sysdate - dt)*1440);
      s := 'mins';
    
      if n = 0 then
        n:=round((sysdate - dt)*18400);
        s:= 'secs';
      end if;
    end if;
    
    return n || ' ' || s || ' ago.';
    
  end time_ago;
end GM_UTIL;
/
/**** DDL_LOG ****/

drop table log_data;
drop sequence log_sequence;
drop procedure log_message;
/
create table log_data ( id number, t timestamp, message nvarchar2(1000));
create sequence log_sequence;
/
set define off
create or replace trigger bi_log
before insert on log_data
for each row
begin
  if :new.id is null then
    select log_sequence.nextval into :new.id from dual;
  end if;
  
  select current_timestamp into :new.t from dual;
end;
/
create or replace procedure log_message(p_message nvarchar2) as
begin
  insert into log_data(message) values(p_message);
end;
/
create or replace view l as select * from log_data order by id desc;
/
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
/**** GM_ONLINE_USERS ****/
drop table gm_online_users;
drop sequence gm_online_users_seq;
/

CREATE TABLE  "GM_ONLINE_USERS" 
   (	"ONLINE_USER_ID" NUMBER, 
	"USERNAME" NVARCHAR2(50), 
  user_icon varchar2(1000),
  ipaddress varchar2(20),
	"LOGIN_TIMESTAMP" date, 
	"LAST_PING_TIMESTAMP" date, 
	"SESSION_ID" NUMBER, 
	 CONSTRAINT "GM_ONLINE_USERS_PK" PRIMARY KEY ("ONLINE_USER_ID")
  USING INDEX  ENABLE
   )
/
create sequence gm_online_users_seq;
/
CREATE OR REPLACE TRIGGER  "BI_GM_ONLINE_USERS" 
  before insert on "GM_ONLINE_USERS"               
  for each row  
begin   
  if :NEW."ONLINE_USER_ID" is null then 
    select "GM_ONLINE_USERS_SEQ".nextval into :NEW."ONLINE_USER_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_GM_ONLINE_USERS" ENABLE;
/
CREATE OR REPLACE FORCE VIEW "GM_ONLINE_USERS_VIEW" as
  with x as (
    select   online_user_id,
              username,
              login_timestamp,
              last_ping_timestamp,
              session_id,
              round((sysdate - last_ping_timestamp ) * 1440) mins_ago
      from gm_online_users T
    )
    select username || ' logged on ' || mins_ago || ' mins_ago.' ||
            ' <a href=javascript:$s("P100_START_GAME_WITH","' || username 
              || '"); apex.submit("P100_START_GAME_WITH");>Start Game ...</a>' userinfo
            ,mins_ago
    from x
    order by mins_ago ;
/
set define off;
create or replace view gm_current_games_view as
  with x as (
    select G.game_id, G.player1, G.player2, min(H.move_time) gamestart_timestamp, max(H.move_time) lastmove_timestamp, count(H.game_id) lastmove_count, D.gamedef_name
    from gm_games G
    join gm_boards B on G.game_id = B.game_id
    join gm_gamedef_boards D on B.board_type = D.gamedef_code
    join gm_game_history H on G.game_id = H.game_id
    group by G.game_id, G.player1, G.player2, D.gamedef_name
  )
  select game_id,
          '<b><a href="javascript:GoToGame(' || game_id || ');">Game ' || game_id || ' - ' || gamedef_name || ' (' || player1 || ' vs ' || player2 || ')</b></a><br/>'
          ||'Started ' || gamestart_timestamp || '.<br/>'
          ||'Last Move ' || lastmove_count || ' made ' || lastmove_timestamp || '.'
          gameinfo
  from x;
/**** GM_CHAT_SCHEMA ****/

drop table GM_CHAT;
drop sequence GM_CHAT_seq;
/

CREATE TABLE  GM_CHAT 
(	
  chat_id number,
  from_user nvarchar2(50),
  to_user nvarchar2(50),
  message nvarchar2(100),
  message_timestamp date,
  CONSTRAINT chat_id_pk PRIMARY KEY (chat_id)
)
/
create sequence gm_chat_seq;
/
CREATE OR REPLACE TRIGGER  BI_GM_CHAT 
  before insert on GM_CHAT               
  for each row  
begin
  select gm_chat_seq.nextval into :new.chat_id from sys.dual;  
  :new.from_user := gm_login_lib.username;
  :new.message_timestamp := sysdate;
end; 
/
ALTER TRIGGER  BI_GM_CHAT ENABLE;
/
/**** GM_CARDS_SCHEMA ****/

drop table GM_BOARD_CARDS;
drop table GM_GAMEDEF_CARDS;

create table GM_GAMEDEF_CARDS
(
  gamedef_card_code varchar2(10),

  gamedef_code varchar2(10), -- Null to apply for all games
  used_for_class varchar2(20),   -- PLAYER, BOARD, CARD, TURN, PIECE
  used_for_piece_type_code varchar2(20),
  used_for_player varchar2(20), -- 'OWN','NME','ANY'
  
  card_name varchar2(50),
  card_description varchar2(1000),
  card_html varchar2(500),
  
  routine     varchar2(20),
  parameter1  varchar2(20),
  parameter2  varchar2(20),
  parameter3  varchar2(20),
  parameter4  varchar2(20),
  parameter5  varchar2(20),
  
  jquery_code varchar2(1000),
  css_code    varchar2(1000),
  sql_code    varchar2(1000),
  
  constraint gm_gd_cards_pk primary key (gamedef_card_code)
);
/

create table GM_BOARD_CARDS 
(
  game_id number,
  card_id number,
  gamedef_card_code varchar2(10),
  player number,
  parameter1 varchar2(10),
  parameter2 varchar2(10),
  parameter3 varchar2(10),
  parameter4 varchar2(10),
  parameter5 varchar2(10),

  constraint gm_board_cards_pk primary key (game_id, card_id),
  constraint gm_board_cards_player_ct unique(game_id, card_id,player),
  constraint gm_board_cards_carddef_fk foreign key(gamedef_card_code) references GM_GAMEDEF_CARDS(gamedef_card_code)
);
/

create or replace package GM_LOGIN_LIB as

  function login return nvarchar2;
  procedure ping;
  function username return varchar2;

end;

/
create or replace package body GM_LOGIN_LIB as

    function login return nvarchar2 as
        v_username varchar2(50);
        v_ipaddress varchar2(20);
    begin
        if v('APP_USER') = 'APEX_PUBLIC_USER' then
            v_username := 'ANON' || v('APP_SESSION');
        else
            v_username := v('APP_USER');
        end if;

        IF OWA.num_cgi_vars IS NOT NULL
        THEN
          -- PL/SQL gateway connection (WEB client)
          v_ipaddress := OWA_UTIL.get_cgi_env ('REMOTE_ADDR');
        ELSE
          -- Direct connection over tcp/ip network
          v_ipaddress := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
        END IF;

        merge into GM_ONLINE_USERS a
        using (select v_username username, 
                      v('APP_SESSION') session_id, 
                      sysdate login_timestamp, 
                      sysdate last_ping_timestamp 
                from dual) b
        on (a.username = b.username)
        when matched then
        update set
            a.session_id = b.session_id,
            a.login_timestamp = b.login_timestamp,
            a.last_ping_timestamp = b.login_timestamp,
            a.ipaddress = v_ipaddress
        when not matched then
            insert (username, session_id, login_timestamp, last_ping_timestamp, ipaddress)
            values (b.username, b.session_id, b.login_timestamp, b.last_ping_timestamp, v_ipaddress);
        
        if apex_collection.collection_exists('GM_STATE') then
            apex_collection.delete_collection('GM_STATE');
        end if;

        apex_collection.create_or_truncate_collection ('GM_STATE');
        apex_collection.add_member (p_collection_name      => 'GM_STATE',
                                    p_generate_md5         => 'NO',
                                    p_c001                 => 'username',
                                    p_c002                 => v_username
                                   );
        return v_username;
    end login;
    
    procedure ping as
        v_username nvarchar2(50);
    begin
        select c002 into v_username from apex_collections where collection_name='GM_STATE' and c001='username';
        update GM_ONLINE_USERS set last_ping_timestamp = current_timestamp where username=v_username;
    end ping;

    function username return varchar2 as
    v_username varchar2(30);
    begin
        select c002 into v_username from apex_collections where collection_name='GM_STATE' and c001='username';
        return v_username;
    end;

end GM_LOGIN_LIB;
/
/**** GM_CHAT_LIB ****/

create or replace package GM_CHAT_LIB as

  procedure say(p_message nvarchar2, p_to_user nvarchar2);

end GM_CHAT_LIB;

/
create or replace package body GM_CHAT_LIB as

  procedure say(p_message nvarchar2, p_to_user nvarchar2) as
  begin
    insert into gm_chat(message, to_user) values(p_message, p_to_user);
  end say;
  
end GM_CHAT_LIB;
/
/**** GM_CHAT_VIEW ***/

create or replace view gm_chat_view as
  select  --round((sysdate - message_timestamp ) * 1440) 
          chat_id,
          '<b>' || case when from_user = gm_login_lib.username then cast('[Me]' as nvarchar2(50)) else from_user end || '</b>  ' ||
          GM_UTIL.TIME_AGO(message_timestamp) || '<br/>' ||
          message chat_entry
  from gm_chat
  where message_timestamp > sysdate - 1/24
  order by chat_id desc
/

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
    gm_piece_lib.generate_piece_moves(p_game_id);
    update gm_games set current_player = 3 - current_player where game_id = p_game_id;
  end move_card;

  procedure move_piece(p_game_id number, p_piece_id number, p_xpos number, p_ypos number)
  as
  begin
    gm_piece_lib.move_piece(p_game_id, p_piece_id, p_xpos, p_ypos);
    gm_piece_lib.generate_piece_moves(p_game_id);
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
/**** GENERAL CSS ****/

delete from gm_css;
/


insert into gm_css(css_id, css_selector, css_declaration_block) values (110, '[type="card"]','{ background-color:yellow; height:45px; width:130px; }');
insert into gm_css(css_id, css_selector, css_declaration_block) values (120, '.card[card-action="REPLACE"]', '{align: center; background-color: #E7D0DB;color: #85144b;font-weight: bold;border-radius: 10px;border: solid 2px;border-color: #85144b; height:45px; width:130px; text-align: center; }');
insert into gm_css(css_id, css_selector, css_declaration_block) values (121, '.card[card-action="BOARD_CHANGE"]', '{background-color: #808F9F; color:#001f3f ;font-weight: bold;border-radius: 10px;border: solid 2px;border-color: #001f3f; height:45px; width:130px; text-align: center; }');
insert into gm_css(css_id, css_selector, css_declaration_block) values (122, '.card-location[is_current_player="N"]','{  -webkit-filter: blur(1px);  -moz-filter: blur(1px);  -o-filter: blur(1px);  -ms-filter: blur(1px);  filter: blur(1px);}');

insert into gm_css(css_id, css_selector, css_declaration_block) values (129, '.card-location', '{ background-color:white; height:45px; width:130px; border: 0px }'); 
insert into gm_css(css_id, css_selector, css_declaration_block) values (130, '.history-piece','{height:25px; width:25px; background-size:25px 25px;}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (131, '.card-piece','{height:35px; width:35px; background-size:35px 35px;}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (132,'#player_icon_1','{width:50px;height:54px;}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (133,'#player_icon_2','{width:50px;height:54px;}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (140, '.card-piece[player="1"][piece-name="any"]', '{background-image: url("https://upload.wikimedia.org/wikipedia/commons/6/65/White_Stars_1.svg");}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (141, '.card-piece[player="2"][piece-name="any"]', '{background-image: url("https://upload.wikimedia.org/wikipedia/commons/c/c8/Black_Star.svg");}');
insert into gm_css(css_id, css_selector, css_declaration_block) values (142, '.card-piece[player="0"][piece-name="any"]', '{background-image: url("https://upload.wikimedia.org/wikipedia/commons/1/17/Yin_yang.svg");}');
commit;
/

/**** GM_BOARD_VIEW ****/
CREATE OR REPLACE FORCE VIEW gm_board_view as
  with pieces as (
        select  P.game_id ,
                P.piece_type_code ,
                P.piece_id ,
                P.xpos ,
                P.ypos ,
                P.player ,
                P.status ,
                T.piece_name
        from gm_board_pieces P
        join gm_piece_types T on P.piece_type_code = T.piece_type_code and P.game_id = T.game_id and P.status <> 0
      )
      , occupied_rows as (
        select distinct R.game_id, R.ypos
        from gm_board_pieces R
      )
      ,board as (
        select R.game_id, R.ypos ypos, 
           gm_piece_lib.format_piece(R.game_id, X1.piece_id, X1.player, X1.piece_name, 1, R.ypos) cell_1,
           gm_piece_lib.format_piece(R.game_id, X2.piece_id, X2.player, X2.piece_name, 2, R.ypos) cell_2,
           gm_piece_lib.format_piece(R.game_id, X3.piece_id, X3.player, X3.piece_name, 3, R.ypos) cell_3,
           gm_piece_lib.format_piece(R.game_id, X4.piece_id, X4.player, X4.piece_name, 4, R.ypos) cell_4,
           gm_piece_lib.format_piece(R.game_id, X5.piece_id, X5.player, X5.piece_name, 5, R.ypos) cell_5,
           gm_piece_lib.format_piece(R.game_id, X6.piece_id, X6.player, X6.piece_name, 6, R.ypos) cell_6,
           gm_piece_lib.format_piece(R.game_id, X7.piece_id, X7.player, X7.piece_name, 7, R.ypos) cell_7,
           gm_piece_lib.format_piece(R.game_id, X8.piece_id, X8.player, X8.piece_name, 8, R.ypos) cell_8
        from occupied_rows R
          left join pieces X1 on R.game_id = X1.game_id and X1.xpos=1 and R.ypos = X1.ypos and X1.status <> 0
          left join pieces X2 on R.game_id = X2.game_id and X2.xpos=2 and R.ypos = X2.ypos and X2.status <> 0
          left join pieces X3 on R.game_id = X3.game_id and X3.xpos=3 and R.ypos = X3.ypos and X3.status <> 0
          left join pieces X4 on R.game_id = X4.game_id and X4.xpos=4 and R.ypos = X4.ypos and X4.status <> 0
          left join pieces X5 on R.game_id = X5.game_id and X5.xpos=5 and R.ypos = X5.ypos and X5.status <> 0
          left join pieces X6 on R.game_id = X6.game_id and X6.xpos=6 and R.ypos = X6.ypos and X6.status <> 0
          left join pieces X7 on R.game_id = X7.game_id and X7.xpos=7 and R.ypos = X7.ypos and X7.status <> 0
          left join pieces X8 on R.game_id = X8.game_id and X8.xpos=8 and R.ypos = X8.ypos and X8.status <> 0
        
    )
    select
      B.game_id ,
      S.ypos,
      '<div id="loc-1-' || S.ypos  || '" class="board-location" xpos=1 ypos=' || S.ypos ||  ' location=1.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_1  || '">' || p.cell_1 || '</div>' cell_1 ,
      '<div id="loc-2-' || S.ypos  || '" class="board-location" xpos=2 ypos=' || S.ypos ||  ' location=2.' || S.ypos  ||  ' type="' || B.board_type || '-' || S.cell_2  || '">' || p.cell_2 || '</div>' cell_2 ,
      '<div id="loc-3-' || S.ypos  || '" class="board-location" xpos=3 ypos=' || S.ypos ||  ' location=3.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_3  || '">' || p.cell_3 || '</div>' cell_3 ,
      '<div id="loc-4-' || S.ypos  || '" class="board-location" xpos=4 ypos=' || S.ypos ||  ' location=4.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_4  || '">' || p.cell_4 || '</div>' cell_4 ,
      '<div id="loc-5-' || S.ypos  || '" class="board-location" xpos=5 ypos=' || S.ypos ||  ' location=5.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_5  || '">' || p.cell_5 || '</div>' cell_5 ,
      '<div id="loc-6-' || S.ypos  || '" class="board-location" xpos=6 ypos=' || S.ypos ||  ' location=6.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_6  || '">' || p.cell_6 || '</div>' cell_6 ,
      '<div id="loc-7-' || S.ypos  || '" class="board-location" xpos=7 ypos=' || S.ypos ||  ' location=7.' || S.ypos  ||  ' type="' || B.board_type || '-' || S.cell_7  || '">' || p.cell_7 || '</div>' cell_7 ,
      '<div id="loc-8-' || S.ypos  || '" class="board-location" xpos=8 ypos=' || S.ypos ||  ' location=8.' || S.ypos  ||  ' type="' || B.board_type || '-' || S.cell_8  || '">' || p.cell_8 || '</div>' cell_8 ,
      '<div id="loc-9-' || S.ypos  || '" class="board-location" xpos=9 ypos=' || S.ypos ||  ' location=9.' || S.ypos  || ' type="' || B.board_type || '-' || S.cell_9  || '">' || '' || '</div>' cell_9 ,
      '<div id="loc-10-' || S.ypos || '" class="board-location" xpos=10 ypos=' || S.ypos || ' location=10.' || S.ypos || ' type="' || B.board_type || '-' || S.cell_10 || '">' || '' || '</div>' cell_10 ,
      '<div id="loc-12-' || S.ypos || '" class="board-location" xpos=11 ypos=' || S.ypos || ' location=11.' || S.ypos || ' type="' || B.board_type || '-' || S.cell_11 || '">' || '' || '</div>' cell_11 ,
      '<div id="loc-11-' || S.ypos || '" class="board-location" xpos=12 ypos=' || S.ypos || ' location=12.' || S.ypos || ' type="' || B.board_type || '-' || S.cell_12 || '">' || '' || '</div>' cell_12
    from gm_board_states S
    join gm_boards B on S.game_id = B.game_id
    left join board P on S.game_id = P.game_id and S.ypos = P.ypos and S.game_id=P.game_id
    ;
/
create or replace view gm_board_css as
  select css, display_order 
  from (
    -- start CSS
    select '<style type="text/css">' css, -100000 display_order from dual
    union all
    select '[summary="???"] {}' css, 0 display_order from dual
    union all
    -- Board CSS
    select '[summary="GameBoard"] td {    padding: 0px 0px 0px 0px;}' css, 10 display_order from dual
    union all
    select '.board-location {  position: relative; height:' || v('P1_SQUARE_SIZE') || 'px;  width:' || v('P1_SQUARE_SIZE') || 'px;}' css, 10 display_order from dual
    union all
    select '.game-piece {height:' || v('P1_SQUARE_SIZE') || 'px;width:' || v('P1_SQUARE_SIZE') || 'px;background-size: ' || v('P1_SQUARE_SIZE') || 'px ' || v('P1_SQUARE_SIZE') || 'px;}' css, 10 display_order from dual
    union all
    select css_selector || css_declaration_block,css_id display_order from gm_css 
    union all
    -- GameDef CSS
    select css_selector || ' ' || css_definition board_css, css_order display_order
    from gm_gamedef_css where gamedef_code=(select board_type from gm_boards where game_id=v('P1_GAME_ID'))
    union all
    -- end CSS
    select '</style>' css, 100000 display_order from dual
    
  )
  order by display_order
  ;
/
create or replace view gm_board_history_view as
  with history as (
    select H.history_id
            , H.game_id
            --, H.piece_id
            , '<table>' ||
              '<tr>' ||
              --'<td rowspan=2><b>' || H.history_id || '</b></td>' ||
              -- show what happened
                case 
                when action='MOVE' then 
                  '<td><div class="history-piece" id="Hpiece-' || H.piece_id || '" player="' || P.player || '" piece-name="' || lower(P.piece_type_code) || '"</div></td>' ||
                  '<td>' || chr(96 + H.old_xpos)|| H.old_ypos || '-' || chr(96 + H.new_xpos) || H.new_ypos || '</td>'
                when action='CAPTURE' then 
                  '<td><div class="history-piece" id="Hpiece-' || H.piece_id || '" player="' || P.player || '" piece-name="' || lower(P.piece_type_code) || '"</div></td>' ||
                  '<td>' || chr(96 + H.old_xpos)|| H.old_ypos || 'x' || chr(96 + H.new_xpos) || H.new_ypos ||
                  '<td><div class="history-piece" id="Hpiece-' || H.action_piece || '" player="' || AP.player || '" piece-name="' || lower(AP.piece_type_code) || '"</div></td>'
                when action='CARD' then 
                  '<td><div class="history-piece" id="Hpiece-' || H.piece_id || '" player="' || P.player || '" piece-name="' || lower(H.action_parameter) || '"</div></td>' ||
                  '<td>' || 'CARD-' || ac.gamedef_card_code ||
                  '<td><div class="history-piece" id="Hpiece-' || H.piece_id || '" player="' || P.player || '" piece-name="' || lower(P.piece_type_code) || '"</div></td>'
                end     
                || '</tr></table>'
              history_item
    from gm_game_history H
    left join gm_board_pieces P on H.piece_id = P.piece_id and H.game_id = P.game_id
    left join gm_board_pieces AP on H.action_piece = AP.piece_id and H.game_id = AP.game_id
    left join gm_board_cards AC on H.action_piece = AC.card_id and H.game_id = AC.game_id
    where H.player > 0
  )
  select game_id, history_id, history_item
  from history;
/
create or replace view gm_board_history_list as
  with white_moves as (
    select game_id, rownum r, history_item
    from gm_board_history_view
    where game_id=v('P1_GAME_ID') and mod(history_id,2) = 0
    order by history_id
  ),
  black_moves as (
    select rownum r, history_item
    from gm_board_history_view
    where game_id=v('P1_GAME_ID') and mod(history_id,2) = 1
    order by history_id
  )
  select W.r, W.history_item white_move, B.history_item black_move
  from white_moves W
  left join black_moves B on W.r = B.r;

/
create or replace view gm_piece_moves as
    select collection_name, seq_id, c001 piece_type_code, 
            n001 game_id, n002 piece_id, n003 player, 
            n004 xpos, n005 ypos,
            c002 piece_move
    from apex_collections 
    where collection_name='GAME_STATE';
/

create or replace package GM_PIECE_LIB as
  procedure move_piece(p_game_id number, p_piece_id number, p_xpos number, p_ypos number);
  function move_in_direction( move_step char, p_piece gm_board_pieces%rowtype, p_piece_type gm_piece_types%rowtype, p_max_distance_per_move number,p_x_steps number, p_y_steps number, new_xpos in out number, new_ypos in out number, ended_on out nvarchar2) return nvarchar2;

  function format_piece(p_game_id number, p_piece_id number, p_player_number number, p_piece_name nvarchar2, p_xpos number, p_ypos number) return nvarchar2;
  function calc_valid_squares(p_game_id number, p_piece_id number) return varchar2;
  procedure generate_piece_moves(p_game_id number);

end GM_PIECE_LIB;

/

create or replace package body GM_PIECE_LIB as

  /*********************************************************************************************************************/
  procedure move_piece(p_game_id number, p_piece_id number, p_xpos number, p_ypos number)
  as
    n_pieces number;
    v_player number;
    v_message varchar2(1000);
    v_action varchar2(20);
    v_taken_piece_id number;
    v_taken_piece gm_board_pieces%rowtype;
    v_piece gm_board_pieces%rowtype;
    v_piece_type gm_piece_types%rowtype;
  begin
    --log_message('move_piece: [p_game_id:' || p_game_id || '][p_piece_id:' || p_piece_id || '][x: ' || p_xpos || '][y: ' || p_ypos || ']');

    select P.* into v_piece from gm_board_pieces P where P.piece_id = p_piece_id and P.game_id=p_game_id;
    
    if v_piece.status = 0 then
      return;
    end if;
    
    select PT.* into v_piece_type from gm_piece_types PT where PT.piece_type_code = v_piece.piece_type_code and PT.game_id=p_game_id;

    select player into v_player from gm_board_pieces where game_id = p_game_id and piece_id = p_piece_id;
    v_message := 'In game ' || p_game_id || ', player ' || v_piece.player || ' moved ' || v_piece_type.piece_name || ' from ' || v_piece.xpos || ',' || v_piece.ypos || ' to ' || p_xpos || ',' || p_ypos || '.'; 
    gm_chat_lib.say(v_message,'');
    
    -- Capture piece
    select sum(piece_id)
    into v_taken_piece_id
    from gm_board_pieces
    where game_id = p_game_id
      and xpos=p_xpos
      and ypos=p_ypos
      and player <> v_player;

    v_action := 'MOVE';
    
    if v_taken_piece_id is not null then
      
      select *
      into v_taken_piece
      from gm_board_pieces
      where game_id = p_game_id
          and piece_id = v_taken_piece_id;

      update gm_board_pieces
      set status = 0, xpos = 0, ypos = 0
      where game_id = p_game_id and piece_id = v_taken_piece.piece_id;
      v_action := 'CAPTURE';
      
    end if;

    -- Move piece
    update gm_board_pieces
    set xpos=p_xpos, ypos=p_ypos
    where game_id = p_game_id
      and piece_id = p_piece_id
      and not exists (select * from gm_board_pieces where game_id = p_game_id and xpos=p_xpos and ypos=p_ypos);

    -- update history table.
    insert into gm_game_history(game_id,piece_id,player, old_xpos, old_ypos, new_xpos, new_ypos, action, action_piece)
                    values(p_game_id, p_piece_id, v_player, v_piece.xpos, v_piece.ypos, p_xpos, p_ypos, v_action, v_taken_piece.piece_id);
  end move_piece;

 /*********************************************************************************************************************/
  function move_in_direction( move_step char, p_piece gm_board_pieces%rowtype, p_piece_type gm_piece_types%rowtype, p_max_distance_per_move number,p_x_steps number, p_y_steps number, new_xpos in out number, new_ypos in out number, ended_on out nvarchar2) return nvarchar2
  as
    new_position varchar2(100);
    return_positions varchar2(2000);
    player_occupying_square number;
    n number;
    stop_moving boolean;
  begin
    stop_moving := false;
    dbms_output.put_line('  move_in_direction:' || p_max_distance_per_move || ':Delta:' || p_x_steps || ',' || p_y_steps || ' New:' || new_xpos || ',' || new_ypos);
    for step in 1..p_max_distance_per_move loop
      new_xpos := nvl(new_xpos, p_piece.xpos) + p_x_steps;
      new_ypos := nvl(new_ypos, p_piece.ypos) + p_y_steps;
      
      if not stop_moving then
        dbms_output.put_line('  step-' || step || ':' || new_xpos || ',' || new_ypos);

        -- if out of bounds then don't move further
        if new_xpos < 1 or new_xpos > 8 or new_ypos < 1 or new_ypos > 8 then
          new_position:='';
          ended_on:='edge';
          stop_moving := true;
          dbms_output.put_line('  Returning: landed on edge @ '|| new_xpos || ',' || new_ypos);
        else
          select max(player) into n from gm_board_pieces where game_id=p_piece.game_id and xpos=new_xpos and ypos=new_ypos;
          -- occupied
          if  (n is not null) then
            --select player into n from gm_board_pieces where game_id=p_piece.game_id and xpos=new_xpos and ypos=new_ypos;
            stop_moving := true;
            -- occupied by another player's piece and NOT a system piece (e.g. Lock) ** TODO: Check for capture direction **
            if n <> p_piece.player and n <> 3 then
              dbms_output.put_line('test capture:' || move_step || '-' || p_piece_type.capture_directions || ' test=' || instr(nvl(p_piece_type.capture_directions,move_step),move_step));
              if instr(nvl(p_piece_type.capture_directions,move_step),move_step) > 0 then
                dbms_output.put_line('allow capture');
                new_position:= ':loc-' || new_xpos || '-' || new_ypos || ':';
                ended_on:='nme';
              else
                apex_debug_message.log_message('disallow capture',true,1);
                new_position:='';
                ended_on:='xcap';
              end if;
            else
                new_position:='';
                ended_on:='own';
            end if;
            dbms_output.put_line('  Returning: landed on ' || ended_on || ' @ '|| new_xpos || ',' || new_ypos);
            stop_moving := true;
          else
            ended_on:='';
            -- not occupied - make sure that this is a location we can move into.
            if instr(nvl(p_piece_type.move_directions,move_step),move_step) > 0 then
                new_position := ':loc-' || new_xpos || '-' || new_ypos;
            else
                new_position:='';
                ended_on := 'xmove';
                stop_moving := true;
            end if;
          end if; -- if occupied
        end if; -- in bounds;
        
      end if; -- if not stop_moving
      
      if p_piece_type.can_jump = 1 then
        --return_positions := return_positions || new_position;
        null;
      elsif stop_moving and ended_on = 'nme' then
        return_positions := return_positions || new_position;
        dbms_output.put_line('  NewLoc+Capture: @ '|| new_xpos || ',' || new_ypos);   
        exit;
      elsif not stop_moving then
        return_positions := return_positions || new_position;
        dbms_output.put_line('  NewLoc: @ '|| new_xpos || ',' || new_ypos);
      end if;
    end loop; 
    dbms_output.put_line('RETURNING: ' || return_positions);
    return return_positions;
  end move_in_direction;

  /*********************************************************************************************************************/
  function calc_valid_squares(p_game_id number, p_piece_id number) return varchar2
  as
  
    v_piece gm_board_pieces%rowtype;
    v_piece_type gm_piece_types%rowtype;
    v_positions varchar2(4000);
    v_move_choices apex_application_global.vc_arr2;
    move_choice varchar2(100);
    v_directions_allowed varchar2(100);
    move_step varchar(1);
    n_moves_made_by_piece  number;
    new_x number;
    new_y number;
    new_position varchar2(50);
    y_direction number;
    distance_per_step number;
    step number;
    max_distance_per_move number;
    next_position varchar2(100);
    stop_moving boolean;
    ended_on varchar2(10);
  begin
  
    select P.* into v_piece from gm_board_pieces P where P.piece_id = p_piece_id and P.game_id=p_game_id;
    
    if v_piece.status = 0 then
      return '';
    end if;
    
    select PT.* into v_piece_type from gm_piece_types PT where PT.piece_type_code = v_piece.piece_type_code and PT.game_id=p_game_id;
    
    -- Flip the y direction if the second player
    if v_piece.player = 1 then y_direction := 1; else y_direction := -1 ;end if;
    
    
    -- define the furthest a piece can move.
    if v_piece_type.n_steps_per_move = 0 then
      max_distance_per_move := 8; --TODO: Replace with board size 
    else
      max_distance_per_move := v_piece_type.n_steps_per_move;
    end if;

    -- define how many steps (currently 1) that a piece takes per move
    distance_per_step := (1 * y_direction);

    -- Current position is also valid!
    v_positions := 'loc-' || v_piece.xpos || '-' || v_piece.ypos;
    
    v_directions_allowed := case  
                             when v_piece_type.directions_allowed = '+' then '^:v:<:>'
                             when v_piece_type.directions_allowed = 'X' then '\:/:L:J'
                             when v_piece_type.directions_allowed = 'O' then '^:v:<:>:\:/:L:J'
                             else
                                v_piece_type.directions_allowed
                        end; 
    select count(*) into n_moves_made_by_piece from gm_game_history where game_id=p_game_id and piece_id=p_piece_id and player > 0;
    
    if n_moves_made_by_piece = 0 and v_piece_type.first_move is not null then
      v_move_choices := apex_util.string_to_table(v_piece_type.first_move,':');
      dbms_output.put_line('---> Number of choices: ' || v_move_choices.count || ' from "' || v_piece_type.first_move || '"' );
    else
      v_move_choices := apex_util.string_to_table(v_directions_allowed,':');
      dbms_output.put_line('---> Number of choices: ' || v_move_choices.count || ' from "' || v_directions_allowed || '"' );
    end if;
    
    for z in 1..v_move_choices.count loop
      move_choice := v_move_choices(z);
      new_x := null;
      new_y := null;
      dbms_output.put_line('');
      dbms_output.put_line('[DEBUG0: move_choice=' || move_choice || ']**');
      for c in 1..length(move_choice) loop
        move_step := substr(move_choice,c,1);
        
        dbms_output.put_line('[DEBUG1:move_step-' || c || '=' || move_step || new_x || ',' || new_y || '] v_positions=' || v_positions || ' ended_on=' || ended_on);
        if move_step = '^' then
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, 0, distance_per_step, new_x, new_y, ended_on);
        elsif move_step = 'v'then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, 0, (-distance_per_step), new_x, new_y, ended_on);
        elsif move_step = '<' then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), 0, new_x, new_y, ended_on);
        elsif move_step = '>' then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (distance_per_step), 0, new_x, new_y, ended_on);
        elsif move_step = '\' then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (distance_per_step), (distance_per_step), new_x, new_y, ended_on);
        elsif move_step = '/' then        
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), (distance_per_step), new_x, new_y, ended_on);
        elsif move_step = 'L' then    
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (-distance_per_step), (-distance_per_step), new_x, new_y, ended_on);
        elsif move_step = 'J' then    
          next_position :=  move_in_direction(move_step, v_piece, v_piece_type, max_distance_per_move, (distance_per_step), (-distance_per_step), new_x, new_y, ended_on);
        end if;
        v_positions := v_positions || next_position;
        dbms_output.put_line('[DEBUG1:move_step-' || c || '=' || move_step || new_x || ',' || new_y || '] v_positions=' || v_positions || ' added=' || next_position || ' ended_on=' || ended_on);
      end loop; -- for c
      
      dbms_output.put_line('DEBUG2:ended_on=' || ended_on);      
      if (v_piece_type.can_jump = 1 and ended_on = 'nme') or ended_on is null then
        v_positions := v_positions || ':loc-' || new_x || '-' || new_y;
            
      end if;
      
      dbms_output.put_line('DEBUG3:v_positions=' || v_positions);
    end loop; -- move_choice
  
    -- For each move combination (: - separated)
    -- For each direction:
    -- General piece
   
    return v_positions;
  end calc_valid_squares;
  
  /*********************************************************************************************************************/
  /*********************************************************************************************************************/
  function format_piece(p_game_id number, p_piece_id number, p_player_number number, p_piece_name nvarchar2, p_xpos number, p_ypos number) return nvarchar2 as
    v_piece_moves nvarchar2(1000);
    v_attacked_by nvarchar2(100);
    v_current_player number;
  begin
    -- TODO: refactor
    select current_player into v_current_player from gm_games where game_id=p_game_id;
    
    if p_piece_id is null then 
      return ' ';
    else
      with unique_moves as (      
          select distinct piece_move
          from gm_piece_moves 
          where game_id=p_game_id and piece_id=p_piece_id
      )
      select listagg(piece_move,':')  within group (order by 1) 
      into v_piece_moves
      from unique_moves
      group by 1;
      
      -- Figure out who is being attacked.
      begin      
        select listagg(piece_id,':') within group (order by 1)
          into v_attacked_by
          from gm_piece_moves NME 
          where NME.game_id = p_game_id and NME.player = 3 - p_player_number
          and NME.piece_move in (select 'loc-' || P.xpos || '-' || P.ypos from gm_board_pieces P where P.game_id = p_game_id and P.player = p_player_number and P.piece_id=p_piece_id)
        group by 1;
      exception
        when no_data_found then
          v_attacked_by := '';
      end;
      
      --- SVG images
      return '<div id="piece-' || p_piece_id || '" player=' || p_player_number 
                                || ' xpos=' || p_xpos || ' ypos=' || p_ypos || ' location="' || p_xpos || '.' || p_ypos 
                                || '" piece-name="' || p_piece_name  
                                || '" class="game-piece" type="game-piece"' 
                                || '" positions="' || v_piece_moves || '"'
                                || ' attacked_by="' || nvl(v_attacked_by,'') || '"'
                                || ' is_current_player="' || case when p_player_number = v_current_player then 'Y' else 'N' end || '"'
                                --|| '" positions2="' || calc_valid_squares(p_game_id, p_piece_id)
                                || '"/>';  
    end if;
  
  end format_piece;

  /*********************************************************************************************************************/

  procedure AddMoveFor(p_game_id number, p_piece gm_board_pieces%rowtype, p_xpos number, p_ypos number) as
  begin
    apex_collection.add_member(p_collection_name => 'GAME_STATE', p_n001=>p_game_id, 
    p_c001 => p_piece.piece_type_code, p_n002 => p_piece.piece_id, p_n003 => p_piece.player,
    p_n004 => p_xpos, p_n005 => p_ypos);

  end;

  /*************************************************************************************************************/
  procedure generate_piece_moves(p_game_id number) as
    v_moves varchar(1000);
    v_moves_array apex_application_global.vc_arr2;
    v_move number;
    v_xpos number;
    v_ypos number;
    v_exists number;
    v_piece_id number;
  begin

    if APEX_COLLECTION.COLLECTION_EXISTS (p_collection_name => 'GAME_STATE') = true then
      APEX_COLLECTION.DELETE_MEMBERS('GAME_STATE', '1', p_game_id);
    else
      APEX_COLLECTION.CREATE_COLLECTION('GAME_STATE');
    end if;

    for P in (select * from gm_board_pieces where game_id=p_game_id) loop
    
      -- TODO: Get rid of the loc-XX-YY logic
      v_moves := calc_valid_squares(p_game_id, p.piece_id);
      if v_moves is not null then
        v_moves_array:= apex_util.string_to_table(v_moves, ':');
        
        for v_move in 1..v_moves_array.count
        loop
         if v_moves_array(v_move) is not null then
            select count(*) into v_exists from gm_piece_moves C where C.piece_id = P.piece_id and C.player = P.player and C.game_id = P.game_id and C.piece_move = v_moves_array(v_move);
            if v_exists = 0 then
              apex_collection.add_member(p_collection_name => 'GAME_STATE', 
                                          p_c001 => P.game_id, 
                                          p_c002 => P.piece_type_code,
                                          p_c003 => v_moves_array(v_move),
                                          p_c004 => calc_valid_squares(p_game_id, p.piece_id),
    
                                          p_n001 => P.piece_id,
                                          p_n002 => P.player,
                                          p_n003 => P.game_id,
                                          p_n004 => P.xpos,
                                          P_n005 => P.ypos
                                          );
            end if;
         end if;
        end loop;      
      end if; /* if moves is not null */
    end loop;

    -- Kings cannot move into check - non-pawns attack along their lines of movement.
    for M in (
      select seq_id
      from gm_piece_moves P
      where P.game_id = p_game_id
        and P.piece_type_code='KING' 
        and P.piece_move in (select NME.piece_move 
                              from gm_piece_moves NME 
                              where NME.game_id = p_game_id 
                                and NME.player = 3 - P.player and NME.piece_type_code <> 'PAWN' )
    ) loop
      apex_collection.delete_member(p_collection_name => 'GAME_STATE', p_seq => M.seq_id);
    end loop;
    
    -- Kings cannot move into check -- pawns have diagonal attacks
    for M in (
      select seq_id
      from gm_piece_moves P
      where P.game_id = p_game_id
        and P.piece_type_code='KING' 
        and P.piece_move in (select 'loc-' || xpos || '-' || ypos pawn_attacks
                              from (
                                select xpos-1 xpos, ypos+1 ypos, player from gm_board_pieces 
                                where game_id=p_game_id and piece_type_code='PAWN'
                                union all
                                select xpos+1 xpos, ypos+1 ypos, player from gm_board_pieces 
                                where game_id=p_game_id and piece_type_code='PAWN'
                              ) where xpos>0 and xpos <9  and player=3 - P.player)
    ) loop
          apex_collection.delete_member(p_collection_name => 'GAME_STATE', p_seq => M.seq_id);
    end loop;
    
    -- If the King has no moves then it is CHECK-MATE!
    select count(*) into v_move from gm_piece_moves where game_id = p_game_id and piece_type_code='KING' and player=1;
    select xpos, ypos, piece_id into v_xpos, v_ypos, v_piece_id from gm_board_pieces where game_id = p_game_id and piece_type_code='KING' and player=1;
    if v_move = 0 then
      apex_collection.add_member(p_collection_name => 'GAME_STATE', 
                                          p_c001 => p_game_id, 
                                          p_c002 => 'KING',
                                          p_c003 => 'checkmate',
                                          p_c004 => calc_valid_squares(p_game_id, v_piece_id),
    
                                          p_n001 => v_piece_id,
                                          p_n002 => 1,
                                          p_n003 => p_game_id,
                                          p_n004 => v_xpos,
                                          P_n005 => v_ypos
                                          );
    end if;
  end generate_piece_moves;

end GM_PIECE_LIB;
/
/**** GM_GAMEDEF_LIB ****/

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
    insert into gm_piece_types(game_id,piece_type_code, piece_name, can_jump, n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions) 
                  select p_game_id, piece_type_code, piece_name, can_jump, n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions 
                  from gm_gamedef_piece_types
                  where gamedef_code=p_game_name; 
                  
    -- Place board pieces
    insert into gm_board_pieces(game_id, piece_type_code, piece_id, xpos, ypos, player, status)
                select p_game_id, piece_type_code, piece_id, xpos, ypos, player, status
                from gm_gamedef_pieces
                where gamedef_code=p_game_name;

  end create_board;

end GM_GAMEDEF_LIB;
/
/*********************************************************************************************************************/
/* Create CHECKERS */
create or replace procedure gm_gamedef_mk_checkers as
  CANNOT_JUMP constant number := 0;
  CAN_JUMP constant number := 1;
  ypos number;
begin

  delete from gm_gamedef_pieces where gamedef_code='CHECKERS';
  delete from gm_gamedef_piece_types where gamedef_code='CHECKERS';
  delete from gm_gamedef_css where gamedef_code='CHECKERS';
  delete from gm_gamedef_layout where gamedef_code='CHECKERS';
  delete from gm_gamedef_squaretypes where gamedef_code='CHECKERS';
  delete from gm_gamedef_boards where gamedef_code='CHECKERS';
  
  -- define 8x8 board.
  insert into gm_gamedef_boards(gamedef_code, gamedef_name, max_rows, max_cols) values('CHECKERS', 'CHECKERS game board', 8, 8);
  
  -- define square types.
  insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( 'CHECKERS', 'BLACK','Black square');
  insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( 'CHECKERS', 'WHITE','White square');


  -- define each square on board.
  for ypos in 0..3 loop
    for xpos in 0..3 loop
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHECKERS'',' || (xpos*2 +1) || ',' || (ypos*2+1)|| ',' || '''WHITE'');');
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHECKERS'',' || (xpos*2 +2) || ',' || (ypos*2+1) || ',' || '''BLACK'');');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHECKERS', (xpos*2 +1) , (ypos*2+1) , 'WHITE');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHECKERS', (xpos*2 +2) , (ypos*2+1) , 'BLACK');
    end loop;
    for xpos in 0..3 loop
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHECKERS'',' || (xpos*2 +1) || ',' || (ypos*2+2)|| ',' || '''WHITE'');');
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHECKERS'',' || (xpos*2 +2) || ',' || (ypos*2+2) || ',' || '''BLACK'');');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHECKERS', (xpos*2 +1) , (ypos*2+2) , 'BLACK');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHECKERS', (xpos*2 +2) , (ypos*2+2) , 'WHITE');
    end loop;
  end loop;

  insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHECKERS', 'MAN', 'man', CANNOT_JUMP,  1, '\:/');
  insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, can_jump,  n_steps_per_move, directions_allowed ) values('CHECKERS', 'KING', 'king', CANNOT_JUMP, 0, 'X');

  -- define piece locations
  -- Place white pieces
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',101,2,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',103,4,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',105,6,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',107,8,1,1,1);

  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',110,1,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',112,3,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',114,5,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','KING',116,7,2,1,1);
  
  -- Place black pieces
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',201,1,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',203,3,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',205,5,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',207,7,8,2,1);

  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',209,2,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',211,4,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','MAN',213,6,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHECKERS','KING',215,8,7,2,1);

  -- define CSS

  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[type=CHECKERS-BLACK]','{ background-color: darkslategray;}', 1);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[type=CHECKERS-WHITE]','{ background-color: lightgray;}', 1);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '.bad-location',' {background-color: pink; border: 2px solid red;}', 1000);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '.good-location','{background-color: lightgreen; border: 2px solid darkgreen;}',1000);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '.capture-location','{background-color: sandybrown;border: 2px solid saddlebrown;}',1000);
  
  
  /*
  <a title="By user:malarz pl, User:Stellmach, User:Stannered [Public domain], via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File%3ADraughts_mdt45.svg"><img width="32" alt="Draughts mdt45" src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Draughts_mdt45.svg/32px-Draughts_mdt45.svg.png"/></a>
   */
  -- white pieces
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[player="1"][piece-name="man"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/9/90/Draughts_mlt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[player="1"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/a/a6/Draughts_klt45.svg");}',100);
  
  -- black pieces
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[player="2"][piece-name="man"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/0/0c/Draughts_mdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHECKERS', '[player="2"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/9/9a/Draughts_kdt45.svg");}',100);
end;
/
exec gm_gamedef_mk_checkers;
commit;

/
/*********************************************************************************************************************/
/* Create chess */
create or replace procedure gm_gamedef_mk_chess as
  CANNOT_JUMP constant number := 0;
  CAN_JUMP constant number := 1;
  ypos number;
begin
  
  delete from gm_gamedef_pieces where gamedef_code='CHESS';
  delete from gm_gamedef_piece_types where gamedef_code='CHESS';
  delete from gm_gamedef_css where gamedef_code='CHESS';
  delete from gm_gamedef_layout where gamedef_code='CHESS';
  delete from gm_gamedef_squaretypes where gamedef_code='CHESS';
  delete from gm_gamedef_boards where gamedef_code='CHESS';

  -- define 8x8 board.
  insert into gm_gamedef_boards(gamedef_code, gamedef_name, max_rows, max_cols) values('CHESS', 'Chess game board', 8, 8);
  
  -- define square types.
  insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( 'CHESS', 'BLACK','Black square');
  insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( 'CHESS', 'WHITE','White square');

  for ypos in 0..3 loop
    for xpos in 0..3 loop
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHESS'',' || (xpos*2 +1) || ',' || (ypos*2+1)|| ',' || '''WHITE'');');
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHESS'',' || (xpos*2 +2) || ',' || (ypos*2+1) || ',' || '''BLACK'');');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHESS', (xpos*2 +1) , (ypos*2+1) , 'WHITE');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHESS', (xpos*2 +2) , (ypos*2+1) , 'BLACK');
    end loop;
    for xpos in 0..3 loop
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHESS'',' || (xpos*2 +1) || ',' || (ypos*2+2)|| ',' || '''WHITE'');');
      --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(''CHESS'',' || (xpos*2 +2) || ',' || (ypos*2+2) || ',' || '''BLACK'');');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHESS', (xpos*2 +1) , (ypos*2+2) , 'BLACK');
      insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('CHESS', (xpos*2 +2) , (ypos*2+2) , 'WHITE');
    end loop;
  end loop;
    
    -- define each pice
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions ) 
                                        values('CHESS', 'PAWN', 'pawn', 'P', CANNOT_JUMP,  1, '^^:^:\:/', '^:\:/','\/', '^');
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'BISHOP', 'bishop', 'B', CANNOT_JUMP, 0, null, 'X',null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'KNIGHT', 'knight', 'N',  CAN_JUMP, 1, null, '^^>:^^<:vv<:vv>:>>^:>>v:<<^:<<v', null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'ROOK', 'rook',  'R', CANNOT_JUMP, 0, null, '+', null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'QUEEN', 'queen', 'Q', CANNOT_JUMP, 0, null, 'O', null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values('CHESS', 'KING', 'king', 'K', CANNOT_JUMP, 1, null, 'O', null, null);

  -- define piece locations
  -- Place white pieces
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','ROOK',101,1,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KNIGHT',102,2,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','BISHOP',103,3,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KING',104,4,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','QUEEN',105,5,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','BISHOP',106,6,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KNIGHT',107,7,1,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','ROOK',108,8,1,1,1);

  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',109,1,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',110,2,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',111,3,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',112,4,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',113,5,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',114,6,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',115,7,2,1,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',116,8,2,1,1);
  
  -- Place black pieces
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','ROOK',201,1,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KNIGHT',202,2,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','BISHOP',203,3,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KING',204,4,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','QUEEN',205,5,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','BISHOP',206,6,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','KNIGHT',207,7,8,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','ROOK',208,8,8,2,1);

  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',209,1,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',210,2,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',211,3,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',212,4,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',213,5,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',214,6,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',215,7,7,2,1);
  insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values('CHESS','PAWN',216,8,7,2,1);

  -- define CSS
  
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[type=CHESS-BLACK]','{background-color: darkslategray;}', 1);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[type=CHESS-WHITE]','{background-color: lightgray;}', 1);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '.bad-location',' {background-color: pink; border: 2px solid red;}', 1000);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '.good-location','{background-color: lightgreen; border: 2px solid darkgreen;}',1000);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '.capture-location','{background-color: sandybrown;border: 2px solid saddlebrown;}',1002);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[piece-name="king"][positions="checkmate"]','{background-color: #CC3300;border: 2px solid white;}',1003);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[piece-name="king"]:not([attacked_by=""]):not([positions="checkmate"])','{background-color: #B8005C;border: 2px solid white;}',1004);

  -- white pieces
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="pawn"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/45/Chess_plt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="rook"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/7/72/Chess_rlt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="knight"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/7/70/Chess_nlt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="bishop"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/b/b1/Chess_blt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/42/Chess_klt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="1"][piece-name="queen"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/1/15/Chess_qlt45.svg");}',100);
  
  -- black pieces
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="pawn"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/c/c7/Chess_pdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="rook"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/f/ff/Chess_rdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="knight"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/e/ef/Chess_ndt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="bishop"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/9/98/Chess_bdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/f/f0/Chess_kdt45.svg");}',100);
  insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="2"][piece-name="queen"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/47/Chess_qdt45.svg");}',100);
end;
/
exec gm_gamedef_mk_chess;
/
commit;
/
/*
FISHER CHESS
Reference: https://en.wikipedia.org/wiki/Chess960
Moves from: http://koti.mbnet.fi/villes/php/fischerandom.php 
*/

drop table gm_fisher_positions;

create table GM_FISHER_POSITIONS (
  fisher_game_id number,
  starting_position varchar2(8),
  constraint fisher_game_pk primary key(fisher_game_id)
);
/
create or replace procedure populate_fisher_table as 
begin
   delete from gm_fisher_positions;

  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(0,'BBQNNRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(1,'BQNBNRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(2,'BQNNRBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(3,'BQNNRKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(4,'QBBNNRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(5,'QNBBNRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(6,'QNBNRBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(7,'QNBNRKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(8,'QBNNBRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(9,'QNNBBRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(10,'QNNRBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(11,'QNNRBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(12,'QBNNRKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(13,'QNNBRKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(14,'QNNRKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(15,'QNNRKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(16,'BBNQNRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(17,'BNQBNRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(18,'BNQNRBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(19,'BNQNRKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(20,'NBBQNRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(21,'NQBBNRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(22,'NQBNRBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(23,'NQBNRKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(24,'NBQNBRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(25,'NQNBBRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(26,'NQNRBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(27,'NQNRBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(28,'NBQNRKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(29,'NQNBRKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(30,'NQNRKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(31,'NQNRKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(32,'BBNNQRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(33,'BNNBQRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(34,'BNNQRBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(35,'BNNQRKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(36,'NBBNQRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(37,'NNBBQRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(38,'NNBQRBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(39,'NNBQRKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(40,'NBNQBRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(41,'NNQBBRKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(42,'NNQRBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(43,'NNQRBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(44,'NBNQRKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(45,'NNQBRKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(46,'NNQRKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(47,'NNQRKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(48,'BBNNRQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(49,'BNNBRQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(50,'BNNRQBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(51,'BNNRQKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(52,'NBBNRQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(53,'NNBBRQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(54,'NNBRQBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(55,'NNBRQKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(56,'NBNRBQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(57,'NNRBBQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(58,'NNRQBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(59,'NNRQBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(60,'NBNRQKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(61,'NNRBQKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(62,'NNRQKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(63,'NNRQKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(64,'BBNNRKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(65,'BNNBRKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(66,'BNNRKBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(67,'BNNRKQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(68,'NBBNRKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(69,'NNBBRKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(70,'NNBRKBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(71,'NNBRKQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(72,'NBNRBKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(73,'NNRBBKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(74,'NNRKBBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(75,'NNRKBQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(76,'NBNRKQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(77,'NNRBKQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(78,'NNRKQBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(79,'NNRKQRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(80,'BBNNRKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(81,'BNNBRKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(82,'BNNRKBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(83,'BNNRKRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(84,'NBBNRKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(85,'NNBBRKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(86,'NNBRKBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(87,'NNBRKRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(88,'NBNRBKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(89,'NNRBBKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(90,'NNRKBBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(91,'NNRKBRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(92,'NBNRKRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(93,'NNRBKRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(94,'NNRKRBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(95,'NNRKRQBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(96,'BBQNRNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(97,'BQNBRNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(98,'BQNRNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(99,'BQNRNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(100,'QBBNRNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(101,'QNBBRNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(102,'QNBRNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(103,'QNBRNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(104,'QBNRBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(105,'QNRBBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(106,'QNRNBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(107,'QNRNBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(108,'QBNRNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(109,'QNRBNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(110,'QNRNKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(111,'QNRNKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(112,'BBNQRNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(113,'BNQBRNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(114,'BNQRNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(115,'BNQRNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(116,'NBBQRNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(117,'NQBBRNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(118,'NQBRNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(119,'NQBRNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(120,'NBQRBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(121,'NQRBBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(122,'NQRNBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(123,'NQRNBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(124,'NBQRNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(125,'NQRBNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(126,'NQRNKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(127,'NQRNKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(128,'BBNRQNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(129,'BNRBQNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(130,'BNRQNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(131,'BNRQNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(132,'NBBRQNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(133,'NRBBQNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(134,'NRBQNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(135,'NRBQNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(136,'NBRQBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(137,'NRQBBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(138,'NRQNBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(139,'NRQNBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(140,'NBRQNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(141,'NRQBNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(142,'NRQNKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(143,'NRQNKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(144,'BBNRNQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(145,'BNRBNQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(146,'BNRNQBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(147,'BNRNQKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(148,'NBBRNQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(149,'NRBBNQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(150,'NRBNQBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(151,'NRBNQKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(152,'NBRNBQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(153,'NRNBBQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(154,'NRNQBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(155,'NRNQBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(156,'NBRNQKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(157,'NRNBQKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(158,'NRNQKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(159,'NRNQKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(160,'BBNRNKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(161,'BNRBNKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(162,'BNRNKBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(163,'BNRNKQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(164,'NBBRNKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(165,'NRBBNKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(166,'NRBNKBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(167,'NRBNKQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(168,'NBRNBKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(169,'NRNBBKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(170,'NRNKBBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(171,'NRNKBQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(172,'NBRNKQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(173,'NRNBKQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(174,'NRNKQBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(175,'NRNKQRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(176,'BBNRNKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(177,'BNRBNKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(178,'BNRNKBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(179,'BNRNKRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(180,'NBBRNKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(181,'NRBBNKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(182,'NRBNKBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(183,'NRBNKRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(184,'NBRNBKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(185,'NRNBBKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(186,'NRNKBBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(187,'NRNKBRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(188,'NBRNKRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(189,'NRNBKRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(190,'NRNKRBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(191,'NRNKRQBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(192,'BBQNRKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(193,'BQNBRKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(194,'BQNRKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(195,'BQNRKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(196,'QBBNRKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(197,'QNBBRKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(198,'QNBRKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(199,'QNBRKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(200,'QBNRBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(201,'QNRBBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(202,'QNRKBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(203,'QNRKBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(204,'QBNRKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(205,'QNRBKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(206,'QNRKNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(207,'QNRKNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(208,'BBNQRKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(209,'BNQBRKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(210,'BNQRKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(211,'BNQRKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(212,'NBBQRKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(213,'NQBBRKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(214,'NQBRKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(215,'NQBRKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(216,'NBQRBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(217,'NQRBBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(218,'NQRKBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(219,'NQRKBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(220,'NBQRKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(221,'NQRBKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(222,'NQRKNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(223,'NQRKNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(224,'BBNRQKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(225,'BNRBQKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(226,'BNRQKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(227,'BNRQKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(228,'NBBRQKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(229,'NRBBQKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(230,'NRBQKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(231,'NRBQKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(232,'NBRQBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(233,'NRQBBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(234,'NRQKBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(235,'NRQKBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(236,'NBRQKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(237,'NRQBKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(238,'NRQKNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(239,'NRQKNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(240,'BBNRKQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(241,'BNRBKQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(242,'BNRKQBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(243,'BNRKQNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(244,'NBBRKQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(245,'NRBBKQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(246,'NRBKQBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(247,'NRBKQNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(248,'NBRKBQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(249,'NRKBBQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(250,'NRKQBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(251,'NRKQBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(252,'NBRKQNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(253,'NRKBQNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(254,'NRKQNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(255,'NRKQNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(256,'BBNRKNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(257,'BNRBKNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(258,'BNRKNBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(259,'BNRKNQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(260,'NBBRKNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(261,'NRBBKNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(262,'NRBKNBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(263,'NRBKNQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(264,'NBRKBNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(265,'NRKBBNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(266,'NRKNBBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(267,'NRKNBQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(268,'NBRKNQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(269,'NRKBNQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(270,'NRKNQBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(271,'NRKNQRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(272,'BBNRKNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(273,'BNRBKNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(274,'BNRKNBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(275,'BNRKNRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(276,'NBBRKNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(277,'NRBBKNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(278,'NRBKNBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(279,'NRBKNRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(280,'NBRKBNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(281,'NRKBBNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(282,'NRKNBBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(283,'NRKNBRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(284,'NBRKNRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(285,'NRKBNRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(286,'NRKNRBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(287,'NRKNRQBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(288,'BBQNRKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(289,'BQNBRKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(290,'BQNRKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(291,'BQNRKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(292,'QBBNRKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(293,'QNBBRKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(294,'QNBRKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(295,'QNBRKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(296,'QBNRBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(297,'QNRBBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(298,'QNRKBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(299,'QNRKBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(300,'QBNRKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(301,'QNRBKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(302,'QNRKRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(303,'QNRKRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(304,'BBNQRKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(305,'BNQBRKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(306,'BNQRKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(307,'BNQRKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(308,'NBBQRKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(309,'NQBBRKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(310,'NQBRKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(311,'NQBRKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(312,'NBQRBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(313,'NQRBBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(314,'NQRKBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(315,'NQRKBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(316,'NBQRKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(317,'NQRBKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(318,'NQRKRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(319,'NQRKRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(320,'BBNRQKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(321,'BNRBQKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(322,'BNRQKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(323,'BNRQKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(324,'NBBRQKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(325,'NRBBQKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(326,'NRBQKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(327,'NRBQKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(328,'NBRQBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(329,'NRQBBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(330,'NRQKBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(331,'NRQKBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(332,'NBRQKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(333,'NRQBKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(334,'NRQKRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(335,'NRQKRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(336,'BBNRKQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(337,'BNRBKQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(338,'BNRKQBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(339,'BNRKQRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(340,'NBBRKQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(341,'NRBBKQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(342,'NRBKQBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(343,'NRBKQRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(344,'NBRKBQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(345,'NRKBBQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(346,'NRKQBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(347,'NRKQBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(348,'NBRKQRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(349,'NRKBQRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(350,'NRKQRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(351,'NRKQRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(352,'BBNRKRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(353,'BNRBKRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(354,'BNRKRBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(355,'BNRKRQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(356,'NBBRKRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(357,'NRBBKRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(358,'NRBKRBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(359,'NRBKRQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(360,'NBRKBRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(361,'NRKBBRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(362,'NRKRBBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(363,'NRKRBQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(364,'NBRKRQBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(365,'NRKBRQBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(366,'NRKRQBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(367,'NRKRQNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(368,'BBNRKRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(369,'BNRBKRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(370,'BNRKRBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(371,'BNRKRNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(372,'NBBRKRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(373,'NRBBKRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(374,'NRBKRBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(375,'NRBKRNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(376,'NBRKBRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(377,'NRKBBRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(378,'NRKRBBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(379,'NRKRBNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(380,'NBRKRNBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(381,'NRKBRNBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(382,'NRKRNBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(383,'NRKRNQBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(384,'BBQRNNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(385,'BQRBNNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(386,'BQRNNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(387,'BQRNNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(388,'QBBRNNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(389,'QRBBNNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(390,'QRBNNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(391,'QRBNNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(392,'QBRNBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(393,'QRNBBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(394,'QRNNBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(395,'QRNNBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(396,'QBRNNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(397,'QRNBNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(398,'QRNNKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(399,'QRNNKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(400,'BBRQNNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(401,'BRQBNNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(402,'BRQNNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(403,'BRQNNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(404,'RBBQNNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(405,'RQBBNNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(406,'RQBNNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(407,'RQBNNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(408,'RBQNBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(409,'RQNBBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(410,'RQNNBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(411,'RQNNBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(412,'RBQNNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(413,'RQNBNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(414,'RQNNKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(415,'RQNNKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(416,'BBRNQNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(417,'BRNBQNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(418,'BRNQNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(419,'BRNQNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(420,'RBBNQNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(421,'RNBBQNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(422,'RNBQNBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(423,'RNBQNKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(424,'RBNQBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(425,'RNQBBNKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(426,'RNQNBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(427,'RNQNBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(428,'RBNQNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(429,'RNQBNKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(430,'RNQNKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(431,'RNQNKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(432,'BBRNNQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(433,'BRNBNQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(434,'BRNNQBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(435,'BRNNQKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(436,'RBBNNQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(437,'RNBBNQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(438,'RNBNQBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(439,'RNBNQKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(440,'RBNNBQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(441,'RNNBBQKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(442,'RNNQBBKR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(443,'RNNQBKRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(444,'RBNNQKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(445,'RNNBQKBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(446,'RNNQKBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(447,'RNNQKRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(448,'BBRNNKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(449,'BRNBNKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(450,'BRNNKBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(451,'BRNNKQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(452,'RBBNNKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(453,'RNBBNKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(454,'RNBNKBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(455,'RNBNKQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(456,'RBNNBKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(457,'RNNBBKQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(458,'RNNKBBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(459,'RNNKBQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(460,'RBNNKQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(461,'RNNBKQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(462,'RNNKQBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(463,'RNNKQRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(464,'BBRNNKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(465,'BRNBNKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(466,'BRNNKBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(467,'BRNNKRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(468,'RBBNNKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(469,'RNBBNKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(470,'RNBNKBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(471,'RNBNKRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(472,'RBNNBKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(473,'RNNBBKRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(474,'RNNKBBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(475,'RNNKBRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(476,'RBNNKRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(477,'RNNBKRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(478,'RNNKRBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(479,'RNNKRQBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(480,'BBQRNKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(481,'BQRBNKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(482,'BQRNKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(483,'BQRNKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(484,'QBBRNKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(485,'QRBBNKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(486,'QRBNKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(487,'QRBNKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(488,'QBRNBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(489,'QRNBBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(490,'QRNKBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(491,'QRNKBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(492,'QBRNKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(493,'QRNBKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(494,'QRNKNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(495,'QRNKNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(496,'BBRQNKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(497,'BRQBNKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(498,'BRQNKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(499,'BRQNKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(500,'RBBQNKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(501,'RQBBNKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(502,'RQBNKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(503,'RQBNKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(504,'RBQNBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(505,'RQNBBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(506,'RQNKBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(507,'RQNKBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(508,'RBQNKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(509,'RQNBKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(510,'RQNKNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(511,'RQNKNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(512,'BBRNQKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(513,'BRNBQKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(514,'BRNQKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(515,'BRNQKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(516,'RBBNQKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(517,'RNBBQKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(518,'RNBQKBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(519,'RNBQKNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(520,'RBNQBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(521,'RNQBBKNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(522,'RNQKBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(523,'RNQKBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(524,'RBNQKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(525,'RNQBKNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(526,'RNQKNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(527,'RNQKNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(528,'BBRNKQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(529,'BRNBKQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(530,'BRNKQBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(531,'BRNKQNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(532,'RBBNKQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(533,'RNBBKQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(534,'RNBKQBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(535,'RNBKQNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(536,'RBNKBQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(537,'RNKBBQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(538,'RNKQBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(539,'RNKQBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(540,'RBNKQNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(541,'RNKBQNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(542,'RNKQNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(543,'RNKQNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(544,'BBRNKNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(545,'BRNBKNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(546,'BRNKNBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(547,'BRNKNQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(548,'RBBNKNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(549,'RNBBKNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(550,'RNBKNBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(551,'RNBKNQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(552,'RBNKBNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(553,'RNKBBNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(554,'RNKNBBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(555,'RNKNBQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(556,'RBNKNQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(557,'RNKBNQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(558,'RNKNQBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(559,'RNKNQRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(560,'BBRNKNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(561,'BRNBKNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(562,'BRNKNBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(563,'BRNKNRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(564,'RBBNKNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(565,'RNBBKNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(566,'RNBKNBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(567,'RNBKNRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(568,'RBNKBNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(569,'RNKBBNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(570,'RNKNBBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(571,'RNKNBRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(572,'RBNKNRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(573,'RNKBNRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(574,'RNKNRBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(575,'RNKNRQBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(576,'BBQRNKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(577,'BQRBNKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(578,'BQRNKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(579,'BQRNKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(580,'QBBRNKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(581,'QRBBNKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(582,'QRBNKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(583,'QRBNKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(584,'QBRNBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(585,'QRNBBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(586,'QRNKBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(587,'QRNKBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(588,'QBRNKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(589,'QRNBKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(590,'QRNKRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(591,'QRNKRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(592,'BBRQNKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(593,'BRQBNKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(594,'BRQNKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(595,'BRQNKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(596,'RBBQNKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(597,'RQBBNKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(598,'RQBNKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(599,'RQBNKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(600,'RBQNBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(601,'RQNBBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(602,'RQNKBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(603,'RQNKBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(604,'RBQNKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(605,'RQNBKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(606,'RQNKRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(607,'RQNKRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(608,'BBRNQKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(609,'BRNBQKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(610,'BRNQKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(611,'BRNQKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(612,'RBBNQKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(613,'RNBBQKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(614,'RNBQKBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(615,'RNBQKRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(616,'RBNQBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(617,'RNQBBKRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(618,'RNQKBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(619,'RNQKBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(620,'RBNQKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(621,'RNQBKRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(622,'RNQKRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(623,'RNQKRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(624,'BBRNKQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(625,'BRNBKQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(626,'BRNKQBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(627,'BRNKQRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(628,'RBBNKQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(629,'RNBBKQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(630,'RNBKQBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(631,'RNBKQRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(632,'RBNKBQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(633,'RNKBBQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(634,'RNKQBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(635,'RNKQBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(636,'RBNKQRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(637,'RNKBQRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(638,'RNKQRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(639,'RNKQRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(640,'BBRNKRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(641,'BRNBKRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(642,'BRNKRBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(643,'BRNKRQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(644,'RBBNKRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(645,'RNBBKRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(646,'RNBKRBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(647,'RNBKRQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(648,'RBNKBRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(649,'RNKBBRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(650,'RNKRBBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(651,'RNKRBQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(652,'RBNKRQBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(653,'RNKBRQBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(654,'RNKRQBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(655,'RNKRQNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(656,'BBRNKRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(657,'BRNBKRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(658,'BRNKRBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(659,'BRNKRNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(660,'RBBNKRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(661,'RNBBKRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(662,'RNBKRBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(663,'RNBKRNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(664,'RBNKBRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(665,'RNKBBRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(666,'RNKRBBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(667,'RNKRBNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(668,'RBNKRNBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(669,'RNKBRNBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(670,'RNKRNBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(671,'RNKRNQBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(672,'BBQRKNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(673,'BQRBKNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(674,'BQRKNBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(675,'BQRKNNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(676,'QBBRKNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(677,'QRBBKNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(678,'QRBKNBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(679,'QRBKNNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(680,'QBRKBNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(681,'QRKBBNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(682,'QRKNBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(683,'QRKNBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(684,'QBRKNNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(685,'QRKBNNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(686,'QRKNNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(687,'QRKNNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(688,'BBRQKNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(689,'BRQBKNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(690,'BRQKNBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(691,'BRQKNNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(692,'RBBQKNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(693,'RQBBKNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(694,'RQBKNBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(695,'RQBKNNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(696,'RBQKBNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(697,'RQKBBNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(698,'RQKNBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(699,'RQKNBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(700,'RBQKNNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(701,'RQKBNNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(702,'RQKNNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(703,'RQKNNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(704,'BBRKQNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(705,'BRKBQNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(706,'BRKQNBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(707,'BRKQNNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(708,'RBBKQNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(709,'RKBBQNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(710,'RKBQNBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(711,'RKBQNNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(712,'RBKQBNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(713,'RKQBBNNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(714,'RKQNBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(715,'RKQNBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(716,'RBKQNNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(717,'RKQBNNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(718,'RKQNNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(719,'RKQNNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(720,'BBRKNQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(721,'BRKBNQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(722,'BRKNQBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(723,'BRKNQNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(724,'RBBKNQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(725,'RKBBNQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(726,'RKBNQBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(727,'RKBNQNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(728,'RBKNBQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(729,'RKNBBQNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(730,'RKNQBBNR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(731,'RKNQBNRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(732,'RBKNQNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(733,'RKNBQNBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(734,'RKNQNBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(735,'RKNQNRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(736,'BBRKNNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(737,'BRKBNNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(738,'BRKNNBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(739,'BRKNNQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(740,'RBBKNNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(741,'RKBBNNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(742,'RKBNNBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(743,'RKBNNQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(744,'RBKNBNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(745,'RKNBBNQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(746,'RKNNBBQR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(747,'RKNNBQRB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(748,'RBKNNQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(749,'RKNBNQBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(750,'RKNNQBBR');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(751,'RKNNQRBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(752,'BBRKNNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(753,'BRKBNNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(754,'BRKNNBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(755,'BRKNNRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(756,'RBBKNNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(757,'RKBBNNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(758,'RKBNNBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(759,'RKBNNRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(760,'RBKNBNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(761,'RKNBBNRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(762,'RKNNBBRQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(763,'RKNNBRQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(764,'RBKNNRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(765,'RKNBNRBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(766,'RKNNRBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(767,'RKNNRQBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(768,'BBQRKNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(769,'BQRBKNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(770,'BQRKNBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(771,'BQRKNRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(772,'QBBRKNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(773,'QRBBKNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(774,'QRBKNBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(775,'QRBKNRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(776,'QBRKBNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(777,'QRKBBNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(778,'QRKNBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(779,'QRKNBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(780,'QBRKNRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(781,'QRKBNRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(782,'QRKNRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(783,'QRKNRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(784,'BBRQKNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(785,'BRQBKNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(786,'BRQKNBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(787,'BRQKNRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(788,'RBBQKNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(789,'RQBBKNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(790,'RQBKNBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(791,'RQBKNRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(792,'RBQKBNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(793,'RQKBBNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(794,'RQKNBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(795,'RQKNBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(796,'RBQKNRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(797,'RQKBNRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(798,'RQKNRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(799,'RQKNRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(800,'BBRKQNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(801,'BRKBQNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(802,'BRKQNBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(803,'BRKQNRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(804,'RBBKQNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(805,'RKBBQNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(806,'RKBQNBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(807,'RKBQNRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(808,'RBKQBNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(809,'RKQBBNRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(810,'RKQNBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(811,'RKQNBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(812,'RBKQNRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(813,'RKQBNRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(814,'RKQNRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(815,'RKQNRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(816,'BBRKNQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(817,'BRKBNQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(818,'BRKNQBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(819,'BRKNQRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(820,'RBBKNQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(821,'RKBBNQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(822,'RKBNQBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(823,'RKBNQRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(824,'RBKNBQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(825,'RKNBBQRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(826,'RKNQBBRN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(827,'RKNQBRNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(828,'RBKNQRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(829,'RKNBQRBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(830,'RKNQRBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(831,'RKNQRNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(832,'BBRKNRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(833,'BRKBNRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(834,'BRKNRBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(835,'BRKNRQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(836,'RBBKNRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(837,'RKBBNRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(838,'RKBNRBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(839,'RKBNRQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(840,'RBKNBRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(841,'RKNBBRQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(842,'RKNRBBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(843,'RKNRBQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(844,'RBKNRQBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(845,'RKNBRQBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(846,'RKNRQBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(847,'RKNRQNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(848,'BBRKNRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(849,'BRKBNRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(850,'BRKNRBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(851,'BRKNRNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(852,'RBBKNRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(853,'RKBBNRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(854,'RKBNRBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(855,'RKBNRNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(856,'RBKNBRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(857,'RKNBBRNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(858,'RKNRBBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(859,'RKNRBNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(860,'RBKNRNBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(861,'RKNBRNBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(862,'RKNRNBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(863,'RKNRNQBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(864,'BBQRKRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(865,'BQRBKRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(866,'BQRKRBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(867,'BQRKRNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(868,'QBBRKRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(869,'QRBBKRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(870,'QRBKRBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(871,'QRBKRNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(872,'QBRKBRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(873,'QRKBBRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(874,'QRKRBBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(875,'QRKRBNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(876,'QBRKRNBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(877,'QRKBRNBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(878,'QRKRNBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(879,'QRKRNNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(880,'BBRQKRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(881,'BRQBKRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(882,'BRQKRBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(883,'BRQKRNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(884,'RBBQKRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(885,'RQBBKRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(886,'RQBKRBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(887,'RQBKRNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(888,'RBQKBRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(889,'RQKBBRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(890,'RQKRBBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(891,'RQKRBNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(892,'RBQKRNBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(893,'RQKBRNBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(894,'RQKRNBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(895,'RQKRNNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(896,'BBRKQRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(897,'BRKBQRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(898,'BRKQRBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(899,'BRKQRNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(900,'RBBKQRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(901,'RKBBQRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(902,'RKBQRBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(903,'RKBQRNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(904,'RBKQBRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(905,'RKQBBRNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(906,'RKQRBBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(907,'RKQRBNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(908,'RBKQRNBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(909,'RKQBRNBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(910,'RKQRNBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(911,'RKQRNNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(912,'BBRKRQNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(913,'BRKBRQNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(914,'BRKRQBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(915,'BRKRQNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(916,'RBBKRQNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(917,'RKBBRQNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(918,'RKBRQBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(919,'RKBRQNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(920,'RBKRBQNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(921,'RKRBBQNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(922,'RKRQBBNN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(923,'RKRQBNNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(924,'RBKRQNBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(925,'RKRBQNBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(926,'RKRQNBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(927,'RKRQNNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(928,'BBRKRNQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(929,'BRKBRNQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(930,'BRKRNBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(931,'BRKRNQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(932,'RBBKRNQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(933,'RKBBRNQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(934,'RKBRNBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(935,'RKBRNQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(936,'RBKRBNQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(937,'RKRBBNQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(938,'RKRNBBQN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(939,'RKRNBQNB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(940,'RBKRNQBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(941,'RKRBNQBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(942,'RKRNQBBN');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(943,'RKRNQNBB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(944,'BBRKRNNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(945,'BRKBRNNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(946,'BRKRNBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(947,'BRKRNNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(948,'RBBKRNNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(949,'RKBBRNNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(950,'RKBRNBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(951,'RKBRNNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(952,'RBKRBNNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(953,'RKRBBNNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(954,'RKRNBBNQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(955,'RKRNBNQB');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(956,'RBKRNNBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(957,'RKRBNNBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(958,'RKRNNBBQ');
  insert into GM_FISHER_POSITIONS(fisher_game_id, starting_position) values(959,'RKRNNQBB');
end;
/
create or replace procedure populate_fisher_games 
as
  cursor fisher_games is select * from gm_fisher_positions;
  fisher_game_code varchar2(20);
  i number;
  ypos number;
  CANNOT_JUMP constant number := 0;
  CAN_JUMP constant number := 1;

begin

    delete from gm_gamedef_pieces where gamedef_code LIKE 'FISH%';
    delete from gm_gamedef_piece_types where gamedef_code LIKE 'FISH%';
    delete from gm_gamedef_css where gamedef_code LIKE 'FISH%';
    delete from gm_gamedef_layout where gamedef_code LIKE 'FISH%';
    delete from gm_gamedef_squaretypes where gamedef_code LIKE 'FISH%';
    delete from gm_gamedef_boards where gamedef_code LIKE 'FISH%';

    for game in fisher_games loop
      fisher_game_code := 'FISH_' || lpad(game.fisher_game_id,3,'0');
      
      select count(*) into i from gm_gamedef_boards where gamedef_code=fisher_game_code;
      if i=0 then
        --dbms_output.put_line('Fisher Game ' || lpad(game.fisher_game_id,3,'0') || ' - ' || game.starting_position);
        -- define 8x8 board.
        insert into gm_gamedef_boards(gamedef_code, gamedef_name, max_rows, max_cols) values(fisher_game_code, 'Fisher Game ID=' || lpad(game.fisher_game_id,3,'0') || ':' || game.starting_position, 8, 8);
        
        -- define square types.
        insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( fisher_game_code, 'BLACK','Black square');
        insert into gm_gamedef_squaretypes(gamedef_code, square_type_code, square_type_name) values( fisher_game_code, 'WHITE','White square');
        
        -- define each square on board.
        begin
          for ypos in 0..3 loop
            for xpos in 0..3 loop
              --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('fisher_game_code',' || (xpos*2 +1) || ',' || (ypos*2+1)|| ',' || '''WHITE'');');
              --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('fisher_game_code',' || (xpos*2 +2) || ',' || (ypos*2+1) || ',' || '''BLACK'');');
              insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(fisher_game_code, (xpos*2 +1) , (ypos*2+1) , 'WHITE');
              insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(fisher_game_code, (xpos*2 +2) , (ypos*2+1) , 'BLACK');
            end loop;
            for xpos in 0..3 loop
              --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('fisher_game_code',' || (xpos*2 +1) || ',' || (ypos*2+2)|| ',' || '''WHITE'');');
              --dbms_output.put_line ('insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values('fisher_game_code',' || (xpos*2 +2) || ',' || (ypos*2+2) || ',' || '''BLACK'');');
              insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(fisher_game_code, (xpos*2 +1) , (ypos*2+2) , 'BLACK');
              insert into gm_gamedef_layout(gamedef_code, xpos, ypos, square_type_code) values(fisher_game_code, (xpos*2 +2) , (ypos*2+2) , 'WHITE');
            end loop;
          end loop;
        end;
        
    -- define each pice
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions ) 
                                        values(fisher_game_code, 'PAWN', 'pawn', 'P', CANNOT_JUMP,  1, '^^:^:\:/', '^:\:/','\/', '^');
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values(fisher_game_code, 'BISHOP', 'bishop', 'B', CANNOT_JUMP, 0, null, 'X',null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values(fisher_game_code, 'KNIGHT', 'knight', 'N',  CAN_JUMP, 1, null, '^^>:^^<:vv<:vv>:>>^:>>v:<<^:<<v', null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values(fisher_game_code, 'ROOK', 'rook',  'R', CANNOT_JUMP, 0, null, '+', null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values(fisher_game_code, 'QUEEN', 'queen', 'Q', CANNOT_JUMP, 0, null, 'O', null, null);
    insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                        values(fisher_game_code, 'KING', 'king', 'K', CANNOT_JUMP, 1, null, 'O', null, null);
        -- define piece locations
        -- Place white pieces
        for i in 1 .. length(game.starting_position) loop
            insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,decode(substr(game.starting_position,i,1),'B','BISHOP','Q','QUEEN','N','KNIGHT','R','ROOK','K','KING'),100+i,i,1,1,1);
        end loop;
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',109,1,2,1,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',110,2,2,1,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',111,3,2,1,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',112,4,2,1,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',113,5,2,1,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',114,6,2,1,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',115,7,2,1,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',116,8,2,1,1);
            
        -- Place black pieces
        for i in 1 .. length(game.starting_position) loop
            insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,decode(substr(game.starting_position,i,1),'B','BISHOP','Q','QUEEN','N','KNIGHT','R','ROOK','K','KING'),200+i,i,8,2,1);
        end loop;
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',209,1,7,2,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',210,2,7,2,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',211,3,7,2,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',212,4,7,2,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',213,5,7,2,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',214,6,7,2,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',215,7,7,2,1);
        insert into gm_gamedef_pieces(gamedef_code, piece_type_code, piece_id, xpos, ypos, player, status) values(fisher_game_code,'PAWN',216,8,7,2,1);
        
        -- define CSS
        
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[type=' || fisher_game_code || '-BLACK]','{ background-color: darkslategray;}', 1);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[type=' || fisher_game_code || '-WHITE]','{ background-color: lightgray;}', 1);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '.bad-location',' {background-color: pink; border: 2px solid red;}', 1000);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '.good-location','{background-color: lightgreen; border: 2px solid darkgreen;}',1000);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '.capture-location','{background-color: sandybrown;border: 2px solid saddlebrown;}',1000);
        
        -- white pieces
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="1"][piece-name="pawn"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/45/Chess_plt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="1"][piece-name="rook"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/7/72/Chess_rlt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="1"][piece-name="knight"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/7/70/Chess_nlt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="1"][piece-name="bishop"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/b/b1/Chess_blt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="1"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/42/Chess_klt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="1"][piece-name="queen"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/1/15/Chess_qlt45.svg");}',100);
        
        -- black pieces
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="2"][piece-name="pawn"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/c/c7/Chess_pdt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="2"][piece-name="rook"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/f/ff/Chess_rdt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="2"][piece-name="knight"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/e/ef/Chess_ndt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="2"][piece-name="bishop"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/9/98/Chess_bdt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="2"][piece-name="king"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/f/f0/Chess_kdt45.svg");}',100);
        insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values(fisher_game_code, '[player="2"][piece-name="queen"]' ,'{background-image: url("https://upload.wikimedia.org/wikipedia/commons/4/47/Chess_qdt45.svg");}',100);
        commit;
      end if;
    end loop;
    
    exception
    when others then
      raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
end;
/
--exec populate_fisher_table;
--exec populate_fisher_games;
--/
--commit;
/
delete from gm_gamedef_piece_types where piece_type_code='LOCK';
insert into gm_gamedef_piece_types(gamedef_code, piece_type_code, piece_name, piece_notation, can_jump,  n_steps_per_move, first_move, directions_allowed, capture_directions, move_directions  ) 
                                    values('CHESS', 'LOCK', 'lock', 'X', 0, 0, null, null, null, 0);
delete from gm_gamedef_css where css_selector='[player="3"][piece-name="lock"]:before';

insert into gm_gamedef_css(gamedef_code, css_selector, css_definition, css_order) values('CHESS', '[player="3"][piece-name="lock"]:before' ,'{ font-family: FontAwesome; content: "\f023"; color: #F17171; font-size: 50px; position: absolute; top: 19px; left: 8px; }',100);
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
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 18, 1, 'OA2Q');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 19, 1, 'OB2N');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 20, 1, 'RMSQ');
    insert into gm_board_cards(game_id, card_id, player, gamedef_card_code) values(p_game_id, 21, 1, 'MKSQ');
  end board_init;

  procedure process_card(p_game_id number, p_piece_id varchar2, p_xpos number, p_ypos number)
  as
    v_card_id number;
    v_piece_id number;
    v_player number;
    v_old_piece_type_code varchar(10);
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
    -- Record card use.
    insert into gm_game_history(game_id,  piece_id, card_id, player, old_xpos, old_ypos, new_xpos, new_ypos, action, action_piece, action_parameter)
                           values(p_game_id, v_piece_id, v_card_id, v_player , p_xpos, p_ypos, 0, 0, 'CARD', v_card_id, v_old_piece_type_code);
  
  end;
end gm_card_lib;
/


create or replace view gm_board_piece_locs_view as
  with individual_pieces as (
    select game_id, player, piece_type_code, listagg('loc-' || xpos||'-'||ypos,':') within group(order by xpos) board_locations
    from gm_board_pieces P 
    where status=1 and P.piece_type_code not in ('KING')
    group by game_id, player, piece_type_code
  ),
  own_players_pieces as (
    select game_id, player, 'OWN' piece_type_code, listagg('loc-' || xpos||'-'||ypos,':') within group(order by xpos) board_locations
    from gm_board_pieces P
    where status=1 and P.piece_type_code not in ('KING')
    group by game_id, player
  ),
  any_players_pieces as (
    select game_id, 0 player, 'ANY' piece_type_code, listagg(board_locations,':') within group(order by game_id) board_locations
    from individual_pieces
    group by game_id
  ),
  board_rows as (
    select to_number(nvl(v('P1_GAME_ID'),0)) game_id, rownum r 
    from gm_board_pieces P 
    where rownum <=  nvl( (select B.max_cols from gm_boards B where B.game_id=v('P1_GAME_ID')),8)
  ),
  board_cols as (
    select nvl(v('P1_GAME_ID'),0) game_id, rownum c 
    from gm_board_pieces P 
    where rownum <=  nvl( (select B.max_rows from gm_boards B where B.game_id=v('P1_GAME_ID')),8)
  ),
  empty_squares as (
    select BR.game_id, 'loc-' || bc.c || '-' || br.r board_location 
    from board_rows BR cross join board_cols BC 
    where (c,r) not in (select xpos,ypos from gm_board_pieces where game_id=v('P1_GAME_ID') and status>0)
  )

  select game_id, 0 player, 'EMPTY' piece_type_code, listagg(board_location,':') within group(order by board_location) board_locations 
  from empty_squares
  group by game_id
  union all
  select game_id, player, piece_type_code, board_locations
  from individual_pieces 
  union all
  select game_id, player, piece_type_code, board_locations
  from own_players_pieces
  union all
  select game_id, player, piece_type_code, board_locations
  from any_players_pieces
  ;
/
create or replace view gm_board_cards_view as
  select C.gamedef_card_code, C.card_id, C.player, C.game_id, CD.used_for_class, CD.used_for_piece_type_code, CD.card_name, CD.card_description,
          '<div class="card-location" player="' || C.player || '" id="card-loc-' || C.card_id || '"'
          || ' is_current_player="' || case when G.current_player = C.player then 'Y' else 'N' end || '">'
          || ' <div class="card" type="card" id="card-' || C.card_id || '"'
          || ' player="' || C.player || '"'
          || ' card-action="' || CD.routine || '"'
          || ' positions="' || L.board_locations || '"'
          || '>'
          || case 
          
             when CD.gamedef_card_code='RMSQ' then
              '<i class="fa fa-lock fa-3x"></i>' || CD.card_description
             when CD.gamedef_card_code='MKSQ' then
              '<i class="fa fa-square-o fa-3x"/></i>' || ' ' ||  CD.card_description

            when CD.routine = 'REPLACE' then
              '<table><tr>'
              || '<td><div class="card-piece" player=' || decode(CD.used_for_player, 'OWN', C.player, 'NME', 3-C.player, 'ANY', 0) 
              || ' piece-name="' || lower(CD.used_for_piece_type_code) ||'"' 
              || '></div></td>'
              || '<td>' || CD.gamedef_card_code || '</td>'
              || case when CD.used_for_player = 'ANY' then
                        '<td><div class="card-piece" player=' || 2 || ' piece-name="'|| lower(CD.parameter1) || '" ></div>'
                        ||'<div " class="card-piece" player=' || 1 || ' piece-name="'|| lower(CD.parameter1) || '" ></div></td>'
                  else
                      '<td><div class="card-piece" player=' || decode(CD.used_for_player, 'OWN', C.player, 'NME', 3-C.player, 'ANY', 0) 
                      || ' piece-name="'|| lower(CD.parameter1) || '" ></div></td>'
                  end
              || '</tr></table>'
            else
              CD.gamedef_card_code
            end
          || '</div></div>' value,
          CD.card_name label
from gm_board_cards C
left join gm_games G on C.game_id = G.game_id
left join gm_gamedef_cards CD on C.gamedef_card_code = CD.gamedef_card_code
left join gm_board_piece_locs_view L on 
            C.game_id = L.game_id
            -- Logic to handle whether we are choosing ANY piece on the board, our OWN piece's or the opponent's (NME's)
            and case when CD.used_for_piece_type_code='ANY' and CD.used_for_player != 'ANY' then 'OWN' 
                      else CD.used_for_piece_type_code end 
                      = L.piece_type_code 
  and decode(CD.used_for_player, 'ANY', 0, 'OWN', C.player, 'NME', 3-C.player,'NONE', 0, 'SYS', 3) = L.player
where C.player > 0
;
/
