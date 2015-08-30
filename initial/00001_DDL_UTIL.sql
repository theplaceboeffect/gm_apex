alter session set current_schema=gm_apex;

create or replace package GM_UTIL as
  function time_ago(dt date) return varchar2;
end GM_UTIL;
/
create or replace package body GM_UTIL as
  function time_ago(dt date) return varchar2 as
  begin
    return round((sysdate - dt)*1440) || ' mins ago';
  end time_ago;
end GM_UTIL;
