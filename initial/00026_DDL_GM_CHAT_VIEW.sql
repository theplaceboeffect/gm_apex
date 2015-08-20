alter session set current_schema=apex_gm;

  create or replace view gm_chat_view as
  select  --round((sysdate - message_timestamp ) * 1440) 
          chat_id,
          '<b>' || case when from_user = gm_login_lib.username then cast('[Me]' as nvarchar2(50)) else from_user end || '</b>' ||
          to_char(message_timestamp,'HH24:MI:SS') || ' mins ago' || '<br/>' ||
          message chat_entry
  from gm_chat
  where message_timestamp > sysdate - 1/24;
