alter session set current_schema=apex_gm;
/*
drop table gm_online_users;
drop sequence gm_online_users_seq;
*/

CREATE TABLE  "GM_ONLINE_USERS" 
   (	"ONLINE_USER_ID" NUMBER, 
	"USERNAME" NVARCHAR2(50), 
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
create or replace view gm_current_games_view as
  with x as (
    select game_id, player1, player2, gamestart_timestamp, lastmove_timestamp, lastmove_count 
    from gm_games
  )
  select game_id,
          '<b>Game ' || game_id || ' (' || player1 || ' vs ' || player2 || ')</b><br/>'
          ||'Started ' || gamestart_timestamp || '.<br/>'
          ||'Last Move ' || lastmove_count || ' made ' || lastmove_timestamp || '.'
          gameinfo
  from x;
  
  select * from gm_current_games_view;