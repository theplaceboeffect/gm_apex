function gm_board()
{
    this.last_highlighted_container_id=0;
    this.dragularState = undefined;
    
    /* Board container methods */
    function is_container_occupied(container_id) { 
        //console.log( container_id  + ' - occupied:' + $("#"+container_id + " .game-piece").length);
        return $("#" + container_id + " .game-piece").length != 0;
    }

    /* General utility methods */
    function xpos(object) {
        return $("#" + object.getAttribute('id')).attr('xpos');
    }
    function ypos(object) {
        return $("#" + object.getAttribute('id')).attr('ypos');
    }

    /* Drag and drop methods */
    function highlight_for_move(container_id) {
        if (typeof container_id !== 'undefined') {
            BoardCell_Reset_HighlightForMove();
            if (this.is_container_occupied(container_id)) {
                $("#" + container_id).css('-webkit-filter', 'hue-rotate(320deg)');
            } else {
                $("#" + container_id).css('-webkit-filter', 'hue-rotate(120deg)');
            }
            last_highlighted_container_id = container_id;
        }
    }

    function reset_highlight_for_move() {
        if (typeof last_highlighted_container_id !== 'undefined') {
            $("#" + last_highlighted_container_id).css('-webkit-filter', 'hue-rotate(0deg)');
            last_highlighted_container_id = undefined;
        }
    }

    /* Dragula methods */
    this.dragular_on_drop = function dragula_on_drop(el,target,source) {
        reset_highlight_for_move();
        console.log("ON DROP:" + this.xpos(target) + "===" + this.xpos(el) + " && " + this.ypos(target) + "===" + this.ypos(el) )
    
        if (this.xpos(target) === this.xpos(source) && this.ypos(target) === this.ypos(source) ) {
            console.log('Not moved - returning');
            return;
            }
            console.log('Test Occupied:' + dropped_cell_is_occupied);
            if ( dropped_cell_is_occupied === false) {
                console.log('DECIDED TO MOVE');
                OnMovePiece(el);
            } else { console.log('MOVE CANCELED');
                this.dragularState.cancel();
            }
    
    }
    
    this.dragular_on_over = function dragula_on_over(el, container, source) {
        container_id = container.getAttribute('id');
        highlight_for_move(container_id);
        dropped_cell_is_occupied = is_container_occupied(container_id);
    }
}

function InitializeBoardDragAndDrop() {
    var board = new gm_board();
    board.dragularState = dragula(Array.prototype.slice.call(document.querySelectorAll('.board_location')))
        .on('drop', board.dragula_on_drop)
        //.on('over', board.dragula_on_over)
    ;
}