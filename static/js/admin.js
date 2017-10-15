var ready = function () {    
    $('.date-input-btn').click(function () {
        var m = moment();   
        $('#date-input-form').val(m.format("YYYY/MM/DD HH:mm:ss"));
    });
}

$(document).ready(ready);
$(document).on('page:load', ready);
