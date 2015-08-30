alter session set current_schema=apex_gm;

drop table log_data;
drop sequence log_sequence;
drop procedure log_message;
/
create table log_data ( id number, t timestamp, message nvarchar2(1000));
create sequence log_sequence;

set define off
create or replace trigger bi_log
before insert on log_data
for each row
begin
  if :new.id is null then
    select log_sequence.nextval into :new.id from dual;
  end if;
  
  select current_timestamp into :new.t from dual;
end;

create or replace procedure log_message(p_message nvarchar2) as
begin
  insert into log_data(message) values(p_message);
end;

create view l as select * from log_data order by id desc;

select * from l;


select * from gm_board_pieces where piece_id=109 and game_id=1;
