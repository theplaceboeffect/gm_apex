alter session set current_schema=apex_gm;

create table log ( id number, t timestamp, message varchar2(1000));
create sequence log_sequence;

set define off
create or replace trigger bi_log
before insert on log
for each row
begin
  if :new.id is null then
    select log_sequence.nextval into :new.id from dual;
  end if;
  
  select current_timestamp into :new.t from dual;
end;
