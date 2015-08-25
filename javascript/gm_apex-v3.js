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

    this.reset_board_location_highlights=function reset_board_location_highlights() {
        //$('.board-location').css('border','0px');
        $('.board-location').removeClass('bad-location');
        $('.board-location').removeClass('good-location');
    }
}
//----------------------------------------------------
board=new gm_board();

function InitializeBoardDragAndDrop()
{
    d = dragula(Array.prototype.slice.call(document.querySelectorAll( '.board-location'))
                , {/* dragula options */
                    revertOnSpill:true,
                    accepts: function (piece, target, source, sibling) {
                        
                        // Do we really need to run this every time!
                        $("#"+piece.getAttribute('id')).attr('positions').split(':').forEach(function(item) { if (item != '') { console.log("Position " + item + " OK!"); $("#" + item).addClass('good-location') }});

                        $('.board-location').removeClass('bad-location');
                        if ($("#"+target.getAttribute('id')).hasClass('good-location') == false) {
                            $("#"+target.getAttribute('id')).addClass('bad-location');
                            return false;                                
                        }
                        return true;
                        if (typeof(occupied_by) !== 'undefined' && occupied_by != piece.getAttribute('id') )
                        {
                            //$("#"+target.getAttribute('id')).css('border','2px solid red');
                            $("#"+target.getAttribute('id')).addClass('bad-location');
                            return false;                                
                        }

                        // Suppress.
                        if (piece.getAttribute('id') == target.getAttribute('id')) {
                            console.log("REJECTING MOVE");
                            //board.color_piece(piece.getAttribute('id'), 'error');
                            return false;    
                        }

                        if (piece.getAttribute('id') != target.getAttribute('id'))
                        {
                            console.log('accepts: piece' + piece.getAttribute('id') + " moving into " + target.getAttribute('id') + " from " + source.getAttribute('id'));
                            board.dump_board_location(target, "Target");
                        }
                        return true; // elements can be dropped in any of the `containers` by default
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
            $("#"+piece.getAttribute('id')).attr('positions').split(':').forEach(function(item) { if (item != '') { console.log("Position " + item + " OK!"); $("#" + item).addClass('good-location')  } })    })
        ;
    d.on('cancel', function(piece,container) {
        console.log("ON CANCLE:(" + board.xpos(piece) + "," + board.ypos(piece) + ") container (" + board.xpos(container) + "," + board.ypos(container) + ")" );
        board.reset_board_location_highlights(); // reset borders 

    })
}
