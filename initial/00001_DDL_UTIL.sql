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
    n := round((sysdate - dt)*1440);
    s := 'mins';
    
    if n = 0 then
      n:=round((sysdate - dt)*18400);
      s:= 'secs';
    end if;
    
    return n || ' ' || s || ' ago.';
    
  end time_ago;
end GM_UTIL;
/
