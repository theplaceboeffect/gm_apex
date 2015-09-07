function OnMovePiece(e1)
{
    var piece_moved = $(e1).attr("id").replace('piece-','');
    var new_x = $(e1).parent().attr("id").split("-")[1];
    var new_y = $(e1).parent().attr("id").split("-")[2];
 
    
    console.log('piece_moved:' + piece_moved + " to " + new_x + "," + new_y);
    
    $s("P1_PIECE_MOVED", piece_moved);
    $s("P1_NEW_X", new_x);
    $s("P1_NEW_Y", new_y);
    
    $s("P1_TRIGGER_MOVE", $v("P1_TRIGGER_MOVE")+1);
    $("#GAME_BOARD").trigger('apexrefresh');
    $("#GAME_HISTORY").trigger('apexrefresh');
}
