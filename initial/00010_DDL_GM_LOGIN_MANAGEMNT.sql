alter session set current_schema=gm_apex;

create or replace package GM_LOGIN_MANAGEMENT as

  function login return nvarchar2;
  procedure ping;

end;

/
create or replace package body GM_LOGIN_MANAGEMENT as

    function login return nvarchar2 as
        v_username varchar2(50);
    begin
        if v('APP_USER') = 'APEX_PUBLIC_USER' then
            v_username := 'ANON' || v('APP_SESSION');
        else
            v_username := v('APP_USER');
        end if;
        
        merge into GM_ONLINE_USERS a
        using (select v_username username, 
                      v('APP_SESSION') session_id, 
                      current_timestamp login_timestamp, 
                      current_timestamp last_ping_timestamp 
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
                                    p_c002                 => v_username
                                   );
        return v_username;
    end login;
    
    procedure ping as
        v_username nvarchar2(50);
    begin
        select c002 into v_username from apex_collections where collection_name='GM_STATE' and c001='username';
        update GM_ONLINE_USERS set last_ping_timestamp = current_timestamp where username=v_username;
    end ping;

end GM_LOGIN_MANAGEMENT;

