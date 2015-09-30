--> Code for card drag and drop
$('[type="card"]').css('background-color','red');
cards=Array.prototype.slice.call(document.querySelectorAll('.card'));
squares=Array.prototype.slice.call(document.querySelectorAll('.board-location'));
d = dragula([cards,squares]);
-------------------------------------------------------------------------------------
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
OLD CSS:
/***** pieces *****/
[type="CHECKERS-BLACK"] { background-color: darkslategray;}

.game-piece {
    width:70px
}
/*
.game-piece.error {
    -webkit-filter: hue-rotate(600deg) saturate(300);
}

.game-piece[player="1"] {
    -webkit-filter: hue-rotate(120deg) saturate(145);
        filter: hue-rotate(120deg) saturate(145);
}

.game-piece[player="2"] {
    -webkit-filter: hue-rotate(120deg) saturate(5);
        filter: hue-rotate(120deg) saturate(5);
}

.game-piece.error {
   -webkit-filter: hue-rotate(600deg) saturate(15);
        filter: hue-rotate(220deg) saturate(145);    
}
*/

/***** board *****/
[summary="Game Board 1"] td {
    background:red;
    padding: 0px 0px 0px 0px;
}

.board-location {
  height:70px;
  width:70px;
  color: cyan;
  font-weight: bold;
  
}

.t-Report-cell {
  height:70px;
  width:70px;
}

/*
.game-piece {
font-size: 50px;
}
*/
/*
.bad-location {
background-color: pink;
border: 2px solid red;
}

.good-location {
background-color: lightgreen;
border: 2px solid darkgreen;
}

.capture-location {
background-color: sandybrown;
border: 2px solid saddlebrown;
}
*/