alter session set current_schema=apex_gm;

  create or replace view gm_chat_view as
  select  --round((sysdate - message_timestamp ) * 1440) 
          chat_id,
          to_char(sysdate,'HH24:MI:SS')
          mins_ago,
          from_user,
          message
  from gm_chat
  where message_timestamp > sysdate - 1/24;
