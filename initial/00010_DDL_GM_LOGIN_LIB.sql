alter session set current_schema=apex_gm;

create or replace package GM_LOGIN_LIB as

  function login return nvarchar2;
  function login_user(p_username nvarchar2 default null) return nvarchar2;
  function username return nvarchar2;
  procedure ping;

end GM_LOGIN_LIB;

/
create or replace package body GM_LOGIN_LIB as

    function login return nvarchar2 as
        v_username varchar2(50);
    begin
        if v('APP_USER') = 'APEX_PUBLIC_USER' then
            v_username := 'ANON' || v('APP_SESSION');
        else
            v_username := v('APP_USER');
        end if;
        
        return login_user(v_username);
    end login;
    
    function login_user(p_username nvarchar2) return nvarchar2 as
    begin
    
        merge into GM_ONLINE_USERS a
        using (select p_username username, 
                      v('APP_SESSION') session_id, 
                      sysdate login_timestamp, 
                      sysdate last_ping_timestamp 
                from dual) b
        on (a.username = b.username)
        when matched then
        update set
            a.session_id = b.session_id,
            a.login_timestamp = b.login_timestamp,
            a.last_ping_timestamp = b.login_timestamp
        when not matched then
            insert (username, session_id, login_timestamp, last_ping_timestamp)
            values (b.username, b.session_id, b.login_timestamp, b.last_ping_timestamp);
        
        if apex_collection.collection_exists('GM_STATE') then
            apex_collection.delete_collection('GM_STATE');
        end if;

        apex_collection.create_or_truncate_collection ('GM_STATE');
        apex_collection.add_member (p_collection_name      => 'GM_STATE',
                                    p_generate_md5         => 'NO',
                                    p_c001                 => 'username',
                                    p_c002                 => p_username
                                   );
        return p_username;
    end login_user;
    
    function username return nvarchar2
    as
        v_username nvarchar2(50);
    begin
        select c002 into v_username from apex_collections where collection_name='GM_STATE' and c001='username';
        return v_username;
    end username;
    
    procedure ping as
    begin
        update GM_ONLINE_USERS set last_ping_timestamp = current_timestamp where username=gm_login_lib.username;
    end ping;

end GM_LOGIN_LIB;

/
create view GM_ONLINE_USERS_VIEW as
  select  T.*, 
          round((sysdate - last_ping_timestamp ) * 1440) mins_ago
  from gm_online_users T
  where 
    round((sysdate  -last_ping_timestamp ) * 1440) < 30
  order by last_ping_timestamp desc
/