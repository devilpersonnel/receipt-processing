$(function () {

    var ul = $('#upload ul');

    $('#drop a').click(function () {
        // Simulate a click on the file input button
        // to show the file browser dialog
        $(this).parent().find('input').click();
    });

    // Initialize the jQuery File Upload plugin
    $('#upload').fileupload({
        formData: {
            timestamp: '23213123123123',
            api_token: '4b461a7794dd160a7c7bc1f993952d2a'
        },
        beforeSend: function (xhr, data) {
            var file = data.files[0];
            xhr.setRequestHeader('Rest-Signature', 'N2FkZTc5ZDE4M2Y0MzVlNGI2OWY0YTM2MzBmMzdhZjBiNzVjMTVlOQ==');
        },
        // This element will accept file drag/drop uploading
        dropZone: $('#drop'),

        // This function is called when a file is added to the queue;
        // either via the browse button, or via drag/drop:
        add: function (e, data) {
            $('#result').empty();
            $('body').waitMe(
                {
                    effect: 'win8',
                    text: 'Processing...'

                });

            $('#upload ul').empty();
            var tpl = $('<li class="working"><input type="text" value="0" data-width="48" data-height="48"' +
                ' data-fgColor="#0788a5" data-readOnly="1" data-bgColor="#3e4043" /><p></p><span></span></li>');


            // Append the file name and file size
            tpl.find('p').text(data.files[0].name)
                .append('<i>' + formatFileSize(data.files[0].size) + '</i>');

            // Add the HTML to the UL element
            data.context = tpl.appendTo(ul);

            // Initialize the knob plugin
            tpl.find('input').knob();

            // Listen for clicks on the cancel icon
            tpl.find('span').click(function () {

                if (tpl.hasClass('working')) {
                    jqXHR.abort();
                }

                tpl.fadeOut(function () {
                    tpl.remove();
                });

            });

            // Automatically upload the file once it is added to the queue
            var jqXHR = data.submit();
        },

        progress: function (e, data) {

            // Calculate the completion percentage of the upload
            var progress = parseInt(data.loaded / data.total * 100, 10);

            // Update the hidden input field and trigger a change
            // so that the jQuery knob plugin knows to update the dial
            data.context.find('input').val(progress).change();

            if (progress == 100) {
                data.context.removeClass('working');
            }
        }
        ,

        fail: function (e, data) {
            $('body').waitMe('hide');
            $('#result').empty();
            // Something has gone wrong!
            data.context.addClass('error');
        }
        ,
        success: function (e, data) {
            $('#result').empty();
            $('body').waitMe('hide');
            // Something has gone wrong!
            if (e.lines) {
                $.each(e.lines, function( index, value ) {
                    $('#result').append( value.text + "</br>");
                });
            }
            else {
                alert(e.meta.message);
            }
        }

    })
    ;

// Prevent the default action when a file is dropped on the window
    $(document).on('drop dragover', function (e) {
        e.preventDefault();
    });

// Helper function that formats the file sizes
    function formatFileSize(bytes) {
        if (typeof bytes !== 'number') {
            return '';
        }

        if (bytes >= 1000000000) {
            return (bytes / 1000000000).toFixed(2) + ' GB';
        }

        if (bytes >= 1000000) {
            return (bytes / 1000000).toFixed(2) + ' MB';
        }

        return (bytes / 1000).toFixed(2) + ' KB';
    }


    $(document).ready(function(){
        $("#receipt_upload_button").change(function(){
            readURL(this);
            $('#receipt_image_display').show();

        });
    });

    function readURL(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function (e) {
                $('#receipt_image_display').attr('src', e.target.result);
            }

            reader.readAsDataURL(input.files[0]);
        }
    }


})
;