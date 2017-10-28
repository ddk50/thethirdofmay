var ready = function () {    
    $('.date-input-btn').click(function () {
        var m = moment();   
        $('#date-input-form').val(m.format("YYYY/MM/DD HH:mm:ss"));
    });
    
    //    Dropzone.autoDiscover = false;
    $('#image_upload').dropzone({
//        uploadMultiple: false,
        url: "/admin/image/upload"
    });
}

$(document).ready(ready);
$(document).on('page:load', ready);
