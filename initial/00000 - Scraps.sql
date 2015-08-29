drop function gm_generate_board_location;
create or replace function gm_generate_board_location(p_game_id number, xpos number, ypos number) return varchar2 as
n number;
begin

  -- if out of bounds then return
  if xpos < 1 or xpos > 8 or ypos < 1 or ypos > 8 then
    --return 'loc-' || xpos || '-' || ypos || ':OOB';
    return '';
  end if;
  
  -- if occupied by own piece then return;
  select count(*) into n from gm_board_pieces where game_id=p_game_id and x_pos=xpos and y_pos=ypos;
  if  (n <> 0) then
    --return 'loc-' || xpos || '-' || ypos || ':OCC';
    return '';
  else
    return 'loc-' || xpos || '-' || ypos || ':';
  end if;
end;

---------------------------------------------------------------
declare
    cursor css_cursor is select css from gm_board_css;
begin
    for css in css_cursor loop
        htp.p(css.css);
    end loop;
end;
----------------------------------------------------------