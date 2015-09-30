 alter session set current_schema=apex_gm;

create or replace package GM_CONNECTION_MANAGEMENT as

  function login return nvarchar2;
  procedure ping;

end;

/
create or replace package body GM_CONNECTION_MANAGEMENT as