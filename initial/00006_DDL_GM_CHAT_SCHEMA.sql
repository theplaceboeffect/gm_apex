alter session set current_schema=apex_gm;
/*
drop table GM_CHAT;
drop sequence GM_CHAT_seq;
*/

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
