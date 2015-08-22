last_highlighted_container_id=0;
function BoardCell_Occupied(container_id)
{ 
    //console.log( container_id  + ' - occupied:' + $("#"+container_id + " .game-piece").length);
    return $("#"+container_id + " .game-piece").length != 0;
}
function xpos(object)
{
   return $("#"+object.getAttribute('id')).attr('xpos');
}
function ypos(object)
{
   return $("#"+object.getAttribute('id')).attr('ypos');
}
function BoardCell_Apply_HighlightForMove(container_id)
{
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
      if (typeof last_highlighted_container_id !== 'undefined' ) {
          $("#"+last_highlighted_container_id).css('-webkit-filter','hue-rotate(0deg)');
          last_highlighted_container_id= undefined;
      }
}

function InitializeBoardDragAndDrop()
{
    dragularState = dragula(Array.prototype.slice.call(document.querySelectorAll('.board_location')))
                        .on('drop', function(el,target,source) {
                             BoardCell_Reset_HighlightForMove();
console.log("ON DROP:" + xpos(target) + "===" + xpos(el) + " && " + ypos(target) + "===" + ypos(el) )
                             if (xpos(target) === xpos(source) && ypos(target) === ypos(source) )
                             {
                                console.log('Not moved - returning');
                                return;
                             }
                             console.log('Test Occupied:' + dropped_cell_is_occupied);
                             if ( dropped_cell_is_occupied === false)
                             {console.log('DECIDED TO MOVE');
                                 OnMovePiece(el);
                             } else { console.log('MOVE CANCELED');
                                 dragularState.cancel();
                             }
                             
                        })
                        .on('over', function(el,container,source) {
                             container_id=container.getAttribute('id');
                             BoardCell_Apply_HighlightForMove( container_id );
                             dropped_cell_is_occupied=BoardCell_Occupied(container_id);

                         })
                         ;
}