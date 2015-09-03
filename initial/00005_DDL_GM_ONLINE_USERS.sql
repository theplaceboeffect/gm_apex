/**** GM_ONLINE_USERS ****/
drop table gm_online_users;
drop sequence gm_online_users_seq;
/

CREATE TABLE  "GM_ONLINE_USERS" 
   (	"ONLINE_USER_ID" NUMBER, 
	"USERNAME" NVARCHAR2(50), 
  user_icon varchar2(1000),
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
