function gm_board()
{
    this.get_id=function get_id(object)
    {
        if (typeof object === 'object') {
            return "#"+object.getAttribute('id');
        } else {
            return object 
        }        
    }
    this.xpos=function xpos(object)
    {
        return $(this.get_id(object)).attr('xpos');
    }

    this.ypos=function ypos(object)
    {
        return $(this.get_id(object)).attr('ypos');
    }

    this.color_piece=function color_piece(piece, piece_state)
    {
        var piece_id = this.get_id(piece);
        switch (piece_state)
        {
            case 'normal':
                $("#"+piece_id).removeClass('error');
                $("#"+piece_id).removeClass('ok_to_move');
                break;
            case 'ok_to_move':
                $("#"+piece_id).addClass('error');
                break;
            case 'error':
                $("#"+piece_id).addClass('error');
                break;
        }
        return piece_id;
    }
    this.is_board_location_occupied=function is_board_location_occupied(board_location)
    {
        var id = this.get_id(board_location);
        var content_id = $(id +" :first-child").attr("id");
        return typeof(content_id) !== undefined;
    }

    this.is_board_location_occupied_by=function is_board_location_occupied_by(board_location)
    {
        var id = this.get_id(board_location);
        var content_id = $(id +" :first-child").attr("id");
        return content_id;
    }

    this.dump_board_location=function dump_board_location(board_location, location_name)
    {
        console.log("----" + location_name + "----");
        id = this.get_id(board_location); 
        debug_string = "[ID:" + id +  "][xpos,ypos:" + $(id).attr("xpos") + "," + $(id).attr("ypos") + "][occupied:" + this.is_board_location_occupied(board_location) +"]";

        content_id = "#" + $(id +" :first-child").attr("id");

        if (typeof(content_id) === undefined ) {
            debug_string += "[EMPTY]";
        } else {
            debug_string += "[content_id:" + content_id + "][piece-name:" + $(content_id).attr("piece-name") + "][contents_xpos,ypos:" + $(content_id).attr("xpos") + "," + $(content_id).attr("ypos") +"]";
        }
        console.log(debug_string);
    }

    this.show_valid_moves_for=function show_valid_moves_for(piece) {
        $("#"+piece.getAttribute('id')).attr('positions').split(':').forEach(function(item) { if (item != '') { $("#" + item).addClass('good-location') }});
    }
    this.reset_board_location_highlights=function reset_board_location_highlights() {
        //$('.board-location').css('border','0px');
        $('.board-location').removeClass('bad-location');
        $('.board-location').removeClass('good-location');
        $('.board-location').removeClass('capture-location');
    }
}

//
//----------------------------------------------------
board=new gm_board();
last_attacked_location='';
last_accept_location='';

function InitializeBoardDragAndDrop()
{
    d = dragula(Array.prototype.slice.call(document.querySelectorAll( '.board-location'))
                , {/* dragula options */
                    revertOnSpill:true,
                    accepts: function (piece, target, source, sibling) {
                        var current_location = target.getAttribute('id');
                        if (last_accept_location == current_location ) {
                            return;
                        } else {
                            last_accept_location = current_location;                        
                        }
                            
                        // Do we really need to run this every time!?
                        board.show_valid_moves_for(piece);
                        $('.board-location').removeClass('bad-location');
                        
                        if ( current_location !== last_attacked_location) {
                            $('.board-location').removeClass('capture-location');
                        }
                        
                        if ($("#"+current_location ).hasClass('good-location') == false) {
                            $("#"+current_location ).addClass('bad-location');
                            $('.board-location').removeClass('capture-location');
                            return false;                                
                        }
                        return true;
                }
                });

    /* Define events */
    d.on('drop', function(piece,target,source) {
            console.log("ON DROP:(" + board.xpos(piece) + "," + board.ypos(piece) + ") -> (" + board.xpos(target) + "," + board.ypos(target) + ")" );
            board.reset_board_location_highlights(); // reset borders 
            OnMovePiece(piece);
    });
    d.on('over', function(piece,container,source) {
            console.log("ON OVER:(" + board.xpos(piece) + "," + board.ypos(piece) + ") container (" + board.xpos(container) + "," + board.ypos(container) + ")" );
            
            var location = container.getAttribute('location');
            var source_location = source.getAttribute('location');
            var player=$('.game-piece[location="' + location +'"]').attr('player');

            if ((typeof player === 'string') && (location != source_location) ){
                $("#"+container.getAttribute('id')).removeClass('good-location');
                $("#"+container.getAttribute('id')).addClass('capture-location');
                last_attacked_location=container.getAttribute('id');
                console.log('last_attacked_location=' + container.getAttribute('id'));
            } 
    });
        ;
    d.on('cancel', function(piece,container) {
        console.log("ON CANCEL:(" + board.xpos(piece) + "," + board.ypos(piece) + ") container (" + board.xpos(container) + "," + board.ypos(container) + ")" );
        board.reset_board_location_highlights(); // reset borders 

    });
    
    d.on('drag', function(piece,container) {
        console.log("ON DRAG:(" + board.xpos(piece) + "," + board.ypos(piece) + ") container (" + board.xpos(container) + "," + board.ypos(container) + ")" );
    });
         
    $(".game-piece").each(function(i,o) {
        new Opentip("#"+o.getAttribute('id')
            , 'id:' + o.getAttribute('id')
                    + '<br/>@' + o.getAttribute('xpos') + ',' + o.getAttribute('ypos')
                    + '<br/>Positions:' + o.getAttribute('positions')
                , o.getAttribute('piece-name') 
            );
    });
    


}


/***************************************************************
function InitializeBoardDragAndDrop()
{
    dragularState = dragula(Array.prototype.slice.call(document.querySelectorAll('.board-location')))
                        .on('drop', function(e1) {OnMovePiece(e1);})
                        .on('over', function(e1) {console.log(' on over ...');})
    ;
}
***************************************************************/
/***************************************************************/
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
}
/***************************************************************/
last_ping=new Date().getTime();
PING_INTERVAL = 300 * 1000;
last_move_count = 0;

function RefreshEverything()
{
        console.log('Refreshing ...');
        var ajax_call = new htmldb_Get(null,$v('pFlowId'), 'APPLICATION_PROCESS=PING',0);
        ajax_call.get();
        $("P1_LASTMOVE_COUNT").trigger('apexrefresh');
        $("#GM_CHAT").trigger('apexrefresh');
        $("#GAME_BOARD").trigger('apexrefresh');
        $("#CURRENT_USERS").trigger('apexrefresh');
        $("#GM_STATE").trigger('apexrefresh');   
        $("#P1_LASTMOVE_COUNT").trigger('apexrefresh');

}
function PingServer()
{
    var now=new Date().getTime();
    console.log("DIFF:" + (now - last_ping));

    if (now - last_ping > PING_INTERVAL) {
        RefreshEverything()
        last_ping=new Date().getTime();
    }
}
