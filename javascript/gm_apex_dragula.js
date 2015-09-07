//
//----------------------------------------------------
board=new gm_board();
last_attacked_location='';
last_accept_location='';

d=undefined;

function InitializeBoardDragAndDrop()
{
    console.log('Debug - InitializeBoardDragAndDrop');
    
    if (typeof d === 'undefined'){
        board=new gm_board();
        last_attacked_location='';
        last_accept_location='';
    } else {
        d.destroy();
    }
    
    $('[type="card"]').css({'background-color':'yellow','height':'30px','width':'60px'});
    $('.card-location').css({'background-color':'red','height':'40px','width':'100px'});
    board_locations=Array.prototype.slice.call(document.querySelectorAll( '.board-location'));
    card_locations=Array.prototype.slice.call(document.querySelectorAll( '.card-location'));

    d = dragula(Array.prototype.slice.call(board_locations)
                , {/* dragula options */
                    revertOnSpill:true,
                    accepts: function (piece, target, source, sibling) {
                        var current_location = target.getAttribute('id');
                        /*if (last_accept_location == current_location ) {
                            return true;
                        } else {
                            last_accept_location = current_location;                        
                        }*/
/*
                        var piece_type = piece.getAttribute('type');
                        if (piece_type === 'card')
                        {
                            console.log('Moving card ');
                            return true;
                        }
 */                      
                        board.show_valid_moves_for(piece);
                        $('.board-location').removeClass('bad-location');
                        
                        if ( current_location !== last_attacked_location) {
                            $('.board-location').removeClass('capture-location');
                        }
                        
                        if ($("#"+current_location ).hasClass('good-location') == false) {
                            $("#"+current_location ).addClass('bad-location');
                            return false;                                
                        }
                        return true;
                }
                });

    /* Define events */
    d.on('drop', function(piece,target,source) {
            console.log("ON DROP:(" + board.xpos(piece) + "," + board.ypos(piece) + ") -> (" + board.xpos(target) + "," + board.ypos(target) + ")" );
            var piece_type = piece.getAttribute('type');
            if (piece_type === 'card')
            {
                console.log('Dropping card ');
                return true;
            }
            board.reset_board_location_highlights(); // reset borders 
            OnMovePiece(piece);
    });
    d.on('over', function(piece,container,source) {
            console.log("ON OVER:(" + board.xpos(piece) + "," + board.ypos(piece) + ") container (" + board.xpos(container) + "," + board.ypos(container) + ")" );
            var piece_type = piece.getAttribute('type');
            if (piece_type === 'card')
            {
                console.log('Card over');
                return true;
            }

            var location = container.getAttribute('location');
            var source_location = source.getAttribute('location');
            var player=$('.game-piece[location="' + location +'"]').attr('player');
            var piece_player = piece.getAttribute('player');
        
            if ((typeof player === 'string') && (location != source_location) && 
                ($("#" + container.getAttribute('id')).hasClass('good-location') == true))
            {
                $("#"+container.getAttribute('id')).removeClass('good-location');
                $("#"+container.getAttribute('id')).addClass('capture-location');
                last_attacked_location=container.getAttribute('id');
                console.log('last_attacked_location=' + container.getAttribute('id'));
            } 
    });
        ;
    d.on('cancel', function(piece,container) {
        console.log("ON CANCEL:(" + board.xpos(piece) + "," + board.ypos(piece) + ") container (" + board.xpos(container) + "," + board.ypos(container) + ")" );
        var piece_type = piece.getAttribute('type');
        if (piece_type === 'card')
        {
            console.log('Cancel card  move');
            return true;
        }
        board.reset_board_location_highlights(); // reset borders 

    });
    
    d.on('drag', function(piece,container) {
        console.log("ON DRAG:(" + board.xpos(piece) + "," + board.ypos(piece) + ") container (" + board.xpos(container) + "," + board.ypos(container) + ")" );
        var piece_type = piece.getAttribute('type');
        if (piece_type === 'card')
        {
            console.log('Dragging card ');
            return true;
        }
       last_accept_location = '';
    });
         
    for (i in document.querySelectorAll( '.card-location')) { 
        d.containers.push(card_locations[i]); 
    }
    
    $(".game-piece").each(function(i,o) {
        new Opentip("#"+o.getAttribute('id')
            , 'id:' + o.getAttribute('id')
                    + '<br/>@' + o.getAttribute('xpos') + ',' + o.getAttribute('ypos')
                    + '<br/>Positions:' + o.getAttribute('positions')
                , o.getAttribute('piece-name') 
            );
    });
    


}