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

