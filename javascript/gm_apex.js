
last_highlighted_container_id=0;
function BoardCell_Occupied(container_id)
{ 
    //console.log( container_id  + ' - occupied:' + $("#"+container_id + " .game-piece").length);
    return $("#"+container_id + " .game-piece").length != 0;
}
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
        //console.log("COLORING:" + piece_id + " - " + piece_state);
        switch (piece_state)
        {
            case 'normal':
                $("#"+piece_id).removeClass('error');
                $("#"+piece_id).removeClass('ok_to_move');
                break;
            case 'ok_to_move':          
                 //$(piece_id).css('-webkit-filter','hue-rotate(120)');
                 $("#"+piece_id).addClass('error');
                 break;
            case 'error':          
                 //$(piece_id).css('-webkit-filter','hue-rotate(320)');
                 $("#"+piece_id).addClass('error');
                 break;
        }
        return piece_id;
    }
}

function BoardCell_Apply_HighlightForMove(container_id)
{
    return;
   if (typeof container_id!=='undefined' ) {
      BoardCell_Reset_HighlightForMove();
      if ( BoardCell_Occupied(container_id) ) {
          $("#"+container_id).css('-webkit-filter','hue-rotate(320deg)');
      } else {
          $("#"+container_id).css('-webkit-filter','hue-rotate(120deg)');
      }
      last_highlighted_container_id=container_id;
   }
}

function BoardCell_Reset_HighlightForMove()
{
    return;
      if (typeof last_highlighted_container_id !== 'undefined' ) {
          $("#"+last_highlighted_container_id).css('-webkit-filter','hue-rotate(0deg)');
          last_highlighted_container_id= undefined;
      }
}

function Piece_Apply_HighlightForMove(container_id,piece_id)
{
      if ( BoardCell_Occupied(container_id) && (board.xpos(container_id) != board.xpos(piece_id)) && (board.ypos(container_id) != board.ypos(piece_id)) ) {
        console.log(piece_id + ' occupied - coloring piece');
        //$("#"+piece_id).css('-webkit-filter','hue-rotate(220deg)');
        board.color_piece(piece_id, 'error');
      } else {
        console.log(piece_id + ' not occupied - reset coloring piece');
        $//("#"+piece_id).css('-webkit-filter','hue-rotate(0deg)');
        board.color_piece(piece_id, 'normal');
      }
}

function BoardCell_Reset_HighlightForMove()
{
    return;
      if (typeof last_highlighted_container_id !== 'undefined' ) {
          $("#"+last_highlighted_container_id).css('-webkit-filter','hue-rotate(0deg)');
          last_highlighted_container_id= undefined;
      }
}


function InitializeBoardDragAndDrop()
{
    board=new gm_board();
    d = dragula(Array.prototype.slice.call(document.querySelectorAll( '.board_location'))
                , {/* dragula options */
                    accepts: function (el, target, source, sibling) {
                        //console.log('accepts:' + el.getAttribute('id') + " into " + source.getAttribute('id') + " from " + source.getAttribute('id'));
                        if (BoardCell_Occupied(target.getAttribute('id'))) {
                            board.color_piece(el.getAttribute('id'), 'error');
                        } else { 
                            board.color_piece(el.getAttribute('id'), 'normal');
                        }
                        return true; // elements can be dropped in any of the `containers` by default
                  }
                });

    /* Define events */
    d.on('drop', function(piece,target,source) {
            console.log("ON DROP:(" + board.xpos(piece) + "," + board.ypos(piece) + ") -> (" + board.xpos(target) + "," + board.ypos(target) + ")" );
            BoardCell_Reset_HighlightForMove();
            if (board.xpos(target) === board.xpos(source) && board.ypos(target) === board.ypos(source) )
            {
                console.log('Not moved - returning');
                return;
            }
            console.log('Test Occupied:' + dropped_cell_is_occupied);
            if ( dropped_cell_is_occupied === false)
            {
                console.log('DECIDED TO MOVE');
                OnMovePiece(piece);
            } else { 
                console.log('MOVE CANCELED');
            }

        });
    d.on('over', function(piece,container,source) {
            return;
            container_id=container.getAttribute('id');
            piece_id=piece.getAttribute('id');
        
            BoardCell_Apply_HighlightForMove( container_id );
            Piece_Apply_HighlightForMove(container_id, piece_id);
        
            dropped_cell_is_occupied=BoardCell_Occupied(container_id);

        })
        ;
}