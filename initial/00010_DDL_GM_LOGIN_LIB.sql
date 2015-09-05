alter session set current_schema=apex_gm;

create or replace package GM_LOGIN_LIB as

  function login return nvarchar2;
  procedure ping;
  function username return varchar2;

end;

/
create or replace package body GM_LOGIN_LIB as

    function login return nvarchar2 as
        v_username varchar2(50);
        v_ipaddress varchar2(20);
    begin
        if v('APP_USER') = 'APEX_PUBLIC_USER' then
            v_username := 'ANON' || v('APP_SESSION');
        else
            v_username := v('APP_USER');
        end if;

        IF OWA.num_cgi_vars IS NOT NULL
        THEN
          -- PL/SQL gateway connection (WEB client)
          v_ipaddress := OWA_UTIL.get_cgi_env ('REMOTE_ADDR');
        ELSE
          -- Direct connection over tcp/ip network
          v_ipaddress := SYS_CONTEXT ('USERENV', 'IP_ADDRESS');
        END IF;

        merge into GM_ONLINE_USERS a
        using (select v_username username, 
                      v('APP_SESSION') session_id, 
                      sysdate login_timestamp, 
                      sysdate last_ping_timestamp 
                from dual) b
        on (a.username = b.username)
        when matched then
        update set
            a.session_id = b.session_id,
            a.login_timestamp = b.login_timestamp,
            a.last_ping_timestamp = b.login_timestamp,
            a.ipaddress = v_ipaddress
        when not matched then
            insert (username, session_id, login_timestamp, last_ping_timestamp, ipaddress)
            values (b.username, b.session_id, b.login_timestamp, b.last_ping_timestamp, v_ipaddress);
        
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

    function username return varchar2 as
    v_username varchar2(30);
    begin
        select c002 into v_username from apex_collections where collection_name='GM_STATE' and c001='username';
        return v_username;
    end;

end GM_LOGIN_LIB;
/
