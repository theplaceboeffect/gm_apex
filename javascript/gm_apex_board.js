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