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
