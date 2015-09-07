last_ping=new Date().getTime();
PING_INTERVAL = 3 * 1000;
last_move_count = 0;
last_chat_id = $v("P1_LAST_CHAT_ID");
last_move_id = $v("P1_LAST_MOVE_ID");

function RefreshEverything()
{
    if (d.dragging == false) {
        //console.log('Looking for changes ...');

        if ($v("P1_LAST_MOVE_ID") > last_move_id ) {
            //console.log('Refreshing game board');
            $("#GAME_BOARD").trigger('apexrefresh');
            $("#GM_STATE").trigger('apexrefresh');       
            $("#P1_CARDS").trigger('apexrefresh');
            $("#P2_CARDS").trigger('apexrefresh');        
        } /*
        else {
            console.log('Skipping refresh of game board.');
            
        }*/
        
        if ($v("P1_LAST_CHAT_ID") > last_chat_id ) {
            //console.log('Refreshing chat');
            $("#GM_CHAT_HISTORY").trigger('apexrefresh');
        } 
        /*else {
            console.log('Skipping refresh of chat board.');
        }*/
    } 
    else {
        //console.log('Skipping refresh because we are dragging.');
        $s("P1_LAST_MOVE_ID", last_move_id);
        $s("P1_LAST_CHAT_ID", last_chat_id);
    }
}

function PingServer()
{
    var now=new Date().getTime();
    //console.log("DIFF:" + (now - last_ping));

    if (now - last_ping > PING_INTERVAL) {        
        $s("P1_PING_TRIGGER", parseInt($v("P1_PING_TRIGGER"))+1);
        last_ping=new Date().getTime();
    }
}
