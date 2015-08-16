declare
  result nvarchar2(100);
begin
  result := gm_login_lib.login_user('user1');
  result := gm_login_lib.login_user('user2');
  gm_chat_lib.say('user1','hello');
end;

