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
ALTER TRIGGER  "BI_GM_ONLINE_USERS" ENABLE
/