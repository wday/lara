/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $, Node */

// TODO: These variable names should be refactored to follow convention, i.e. only prepend with $ when it contains a jQuery object
var $content_box;
var $content_height;
var $content_top;
var $content_bottom;
var $model_width;
var $model_height;
var $model_start;
var $model_lowest;
var $header_height;
var $scroll_start;
var $scroll_end;

var fullScreen, exitFullScreen, minHeader, maxHeader, response_key;

var $scroll_handler = function () {
    // Don't do anything if the model is taller than the info/assessment block.
    if ($content_height > $model_height) {
        if (($(document).scrollTop() > $scroll_start) && ($(document).scrollTop() < $scroll_end)) {
            // Case 1: moving with scroll: scrolling below header but not at bottom of info/assessment block
            // console.debug('Moving: ' + $(document).scrollTop() + ', set to ' + ($model_start + ($(document).scrollTop() - $scroll_start)));
            $('.model-container').css({'position': 'absolute', 'top': ($model_start + ($(document).scrollTop() - $scroll_start)) + 'px', 'width': $model_width});
        } else if ($(document).scrollTop() >= $scroll_end) {
            // Case 2: fixed to bottom
            // console.debug('Bottom: ' + $(document).scrollTop() + ', set to ' + $model_lowest);
            $('.model-container').css({'position': 'absolute', 'top': $model_lowest + 'px', 'width': $model_width});
        } else {
            // Case 3: fixed to top: scrolling shows some bit of header
            // console.debug('Top: ' + $(document).scrollTop() + ', set to ' + $model_start);
            $('.model-container').css({'position': 'absolute', 'top': $model_start + 'px', 'width': $model_width});
        }
    }
};

function calculateDimensions() {
    if ($('.text') && $('.model-container')) {
        // Content starts at the bottom of the header, so this is the height of the header too.
        // Handy as a marker for when to start scrolling.
        $header_height = $('#content').offset().top;
        // Height of info/assessment block
        $content_box = $('.text').height();
        $content_height = $content_box - parseInt($('.text').css('padding-top'), 10) - parseInt($('.text').css('padding-bottom'), 10);
        // Top of info/assessment block (starting position of interactive, topmost location)
        $content_top = $('.text').offset().top;
        // Bottom location of info/assessment block
        $content_bottom = $(document).height() - ($content_top + $content_height);
        // Interactive dimensions
        $model_height = $('.model-container').height();
        $model_width = $('.model-container').css('width');
        // Scroll starts here
        $scroll_start = $header_height;
        $model_start = ($content_top - $header_height);
        // Scroll ends here
        // The travel space available to the model is the height of the content block minus the height of the interactive, so the scroll-end is scroll start plus that value.
        $scroll_end = $scroll_start + ($content_height - $model_height);
        // Interactive lowest position: highest of the stop point plus start point (pretty much where you are at the end of the scroll) or fixed-to-top value
        $model_lowest = Math.max(($model_start + ($scroll_end - $scroll_start)), $model_start);
    }
}

$(window).resize(function () {
    calculateDimensions();
});

function showPrompts() {
    if ($('#custom').is(':checked')) {
        $('.choices .custom-hidden').show();
    } else {
        $('.choices .custom-hidden').hide();
    }
}

function checkAnswer(q_id) {
    // check for valid answer
    if (!$('input:radio[name="questions[' + q_id + ']"]:checked').val()) {
        alert('Please select an answer before checking.');
    } else {
        var a_id = $('input:radio[name="questions[' + q_id + ']"]:checked').val().match(/embeddable__multiple_choice_choice_(\d+)/)[1];
        $.getJSON('/embeddable/multiple_choice/' + a_id + '/check', function (data) {
            var $modal = $('#modal'),
                modal_close = '<div class="close">Close</div>',
                $modal_container = $('#modal-container'),
                response;
            if (data.prompt) {
                response = data.prompt;
            } else if (data.choice) {
                response = 'Yes! You are correct.';
            } else {
                response = 'Sorry, that is incorrect.';
            }
            $modal.html('<div class="check-answer"><p class="response">' + response + '</p></div>')
                  .prepend(modal_close)
                  .css('top', $(window).scrollTop() + 40)
                  .show();
            $modal_container.show();
        });
    }
}

function showTutorial() {
    $('#overlay').fadeIn('fast');
    $('#tutorial').fadeIn('fast');
}

function setIframeHeight() {
    // This depends on a data-aspect_ratio attribute being set in the HTML.
    var aspectRatio = $('iframe[data-aspect_ratio]').attr('data-aspect_ratio'),
        targetHeight = $('.model, .model-edit').width() / aspectRatio;
    $('iframe[data-aspect_ratio]').height(targetHeight);
}

fullScreen = function () {
    $(document).unbind('scroll');
    $('#overlay').fadeIn('fast');
    $('.model').fadeOut('fast');

    $('.full-screen-toggle').attr('onclick', '').click(function () {
        exitFullScreen();
        return false;
    });
    $('.full-screen-toggle').html('Exit Full Screen');
    $('.model').css({'height': '90%', 'left': '5%', 'margin': '0', 'position': 'fixed', 'top': '5%', 'width': '90%', 'z-index': '100'});
    $('.model iframe').css({'height': '100%', 'width': '100%'});
    $('.model').fadeIn('fast');
};

exitFullScreen = function () {
    if (!($('body').hasClass('full'))) {
        $(document).bind('scroll', $scroll_handler());
    }
    $('#tutorial').fadeOut('fast');
    $('.model').fadeOut('fast');
    $('.full-screen-toggle').unbind('click').click(function () {
        fullScreen();
        return false;
    });
    $('.full-screen-toggle').html('Full Screen');
    $('.model').css({'height': '510px', 'left': 'auto', 'margin': '13px 0 20px', 'position': 'relative', 'top': 'auto', 'width': '100%', 'z-index': '1'});
    $('#overlay').fadeOut('slow');
    $('.model').fadeIn('fast');
};

function nextQuestion(num) {
    var curr_q = '.q' + (num - 1),
        next_q = '.q' + num;
    $(curr_q).fadeOut('fast', function () { $(next_q).fadeIn(); });
}

function prevQuestion(num) {
    var curr_q = '.q' + (num + 1),
        next_q = '.q' + num;
    $(curr_q).fadeOut('fast', function () { $(next_q).fadeIn(); });
}

function adjustWidth() {
    var model_width, width;
    if ($('.content').css('width') === '960px') {
        model_width = '60%';
        width = '95%';
    } else {
        model_width = '576px';
        width = '960px';
    }

    $('#header div').css('width', width);
    $('.content').css('width', width);
    $('div.model').css('width', model_width);
    $('#footer div').css('width', width);
}

/*** Storing activity responses in sessionStorage ***/

// For each data-storage_key in the page, stores the current response
function storeResponses () {
    console.log('Storing answers locally.');
    $('[data-storage_key]').each( function () {
        var storageKey, questionText, answerText = '';
        storageKey = $(this).data('storage_key');
        // This is the question
        $(this).find(".prompt").contents().filter( function () { questionText = this.textContent; });
        // This is the MC answer
        if ($(this).find("input:radio:checked").length > 0) {
            $(this).find("input:radio:checked").parent().contents().filter( function () { if (this.nodeType === Node.TEXT_NODE) { answerText += this.textContent; } } );
        }
        // This is the OR answer
        if ($(this).find("textarea").length > 0) {
            answerText = $(this).find("textarea").val();
        }
        if (answerText) {
            answerText.trim();
        }
        if (answerText) {
            sessionStorage.setItem(storageKey, JSON.stringify({ 'question': questionText, 'answer': answerText }));
        }
    });
}

// Zero out responses to all questions in this activity
// Depends on there being a data-storage_key div for each question on the page already
// (which is true of the summary page)
function resetActivity () {
    if ($('body.summary [data-storage_key]').length) {
        if (window.confirm("Are you sure you wish to delete all your answers to this activity?")) {
            $('[data-storage_key]').each( function () {
                var storageKey;
                storageKey = $(this).data('storage_key');
                console.log('Clearing data for ' + storageKey);
                sessionStorage.setItem(storageKey, null);
            });
        }
    }
}

// Returns an object with 'question' and 'answer' attributes
function getResponse (answerKey) {
    return JSON.parse(sessionStorage.getItem(answerKey));
}

// Set up questions on the page with previous responses
function restoreAnswers () {
    $('[data-storage_key]').each( function () {
        var storageKey, storedResponse;
        storageKey = $(this).data('storage_key');
        storedResponse = getResponse(storageKey);
        if (storedResponse) {
            // Is it open response?
            if ($(this).find('textarea').length > 0) {
                $(this).find('textarea').val(storedResponse.answer);
            }
            // Is it multiple choice?
            if ($(this).find('input:radio').length > 0) {
                $(this).find('label').each( function () {
                    var $radio;
                    $radio = $(this).find('input:radio');
                    $(this).contents().filter( function () {
                        if ((this.nodeType === Node.TEXT_NODE) && (this.textContent.trim() === storedResponse.answer.trim())) {
                            $radio.attr('checked', 'checked');
                        }
                    });
                });
            }
        } 
    });
}

/*** Updating server with activity responses in sessionStorage ***/

// Returns a string serializing the JSON of activity responses for storage on the server
function buildActivityResponseBlob () {
    var blob, activity_data, responses;
    blob = {};
    activity_data = JSON.parse(sessionStorage.getItem(response_key));
    // Build data into the blob
    // {
    //     'last_page': -1,
    //     'responses': [{
    //         'storage_key': '1_2_3_name',
    //         'question': 'lorem',
    //         'answer': 'ipsum'
    //     }]
    // }
    // blob.key = response_key;
    blob.last_page = activity_data.last_page;
    responses = [];
    activity_data.storage_keys.split(',').forEach( function (storageKey) {
        var local_response, push_response;
        local_response = getResponse(storageKey);
        if (local_response) {
            push_response = {
                'storage_key': storageKey,
                'question': local_response.question,
                'answer': local_response.answer
            };
            responses.push(push_response);
        }
    });
    blob.responses = JSON.stringify(responses);
    return { 'activity_response': blob };
}

// Splits out responses from an ActivityReponse blob into data in sessionStore
function parseActivityResponseBlob (blob) {
    var activity_data, responses;
    // Build activity_data object
    // Note that activity_id and storage_keys always come from the server - we don't send them back
    activity_data = {
        'activity_id': blob.activity_id,
        'last_page': blob.last_page,
        'storage_keys': blob.storage_keys
    };
    // Store activity_data object
    sessionStorage.setItem(blob.key, JSON.stringify(activity_data));
    // Store responses
    responses = JSON.parse(blob.responses);
    if (responses) {
        try {
            responses.forEach( function (resp) {
                sessionStorage.setItem(resp.storage_key, JSON.stringify({ 'question': resp.question, 'answer': resp.answer }));
            });
        }
        catch(e) {
            console.warn(e);
            console.log(blob.responses);
        }
    } else {
        console.log('No responses found in server data');
    }
}

// Updates server's version of this activity's responses
function updateServer () {
    var activity_id;
    if (response_key) {
        try {
            activity_id = JSON.parse(sessionStorage.getItem(response_key)).activity_id;
        }
        catch (e) {
            console.warn('No activity_id in sessionStore; parsing from document.location.pathname instead.');
            activity_id = /\/activities\/(\d+)/i.exec(document.location.pathname)[1];
        }
        $.ajax({
            url: '/activities/' + activity_id + '/activity_responses/' + response_key,
            type: 'PUT',
            data: buildActivityResponseBlob(),
            success: function (data) {
                console.log(data);
                parseActivityResponseBlob(data);
            }
        });
    }
}

// Update sessionStore with any data stored on the server
function updateSessionStore () {
    var activity_id;
    if (response_key) {
        try {
            activity_id = JSON.parse(sessionStorage.getItem(response_key)).activity_id;
        }
        catch (e) {
            console.warn('No activity_id in sessionStore; parsing from document.location.pathname instead.');
            activity_id = /\/activities\/(\d+)/i.exec(document.location.pathname)[1];
        }
        $.get('/activities/' + activity_id + '/activity_responses/' + response_key, function(data) {
            console.log(data);
            parseActivityResponseBlob(data);
        });
    }
}

/*** End of response storage ***/

// Update the modal edit window with a returned partial
$(function () {
    $('[data-remote][data-replace]')
        .data('type', 'html')
        .live('ajax:success', function (event, data) {
            var $this = $(this);
            $($this.data('replace')).html(data.html);
            $this.trigger('ajax:replaced');
        });
});

$(document).ready(function () {
    // prepare for scrolling model
    if ($('.model-container').length) {
        calculateDimensions();
        $(document).bind('scroll', $scroll_handler);
    }

    // add event listeners
    $('input[type=radio]').click(function () {
        $('#check').removeClass('disabled');
    });
    $('#overlay').click(function () {
        exitFullScreen();
    });
    $('.full-screen-toggle').click(function () {
        fullScreen();
        return false;
    });

    // Adjust iframe to have correct aspect ratio
    setIframeHeight();

    // Set up sortable list
    $('#sort_embeddables').sortable({ handle: '.drag_handle',
        opacity: 0.8,
        tolerance: 'pointer',
        update: function () {
            $.ajax({
                type: "GET",
                url: "reorder_embeddables",
                data: $("#sort_embeddables").sortable("serialize")
            });
        }
    });
    $('#sort-pages').sortable({ handle: '.drag_handle',
        opacity: 0.8,
        tolerance: 'pointer',
        update: function () {
            $.ajax({
                type: "GET",
                url: "reorder_pages",
                data: $('#sort-pages').sortable("serialize")
            });
        }
    });

    if ($('body[data-session-key]').length) {
        // Ongoing activity session: update sessionStore from the server
        console.log('Setting response_key and updating from server');
        response_key = $('body[data-session-key]').data('session-key');
        updateSessionStore();
    } else {
        response_key = null;
    }

    if (sessionStorage && $("[data-storage_key]").length) {
        // Set up to store responses
        // Update sessionStore on-blur for the open response textarea
        $("[data-storage_key] textarea").blur(function () {
            console.log('Storing in sessionStore');
            storeResponses();
        });
        // Update sessionStore on-click for the multiple choice radio buttons
        $("[data-storage_key] input:radio").click(function () {
            console.log('Storing in sessionStore');
            storeResponses();
        });
        // Post up to the server on unload
        // FIXME: Something's wrong here, in that the success callback doesn't get called and the server is not updated.
        // The updateServer() method works when called by itself, but not when it's called here.
        $(window).unload(function () { 
            console.log('Updating to server');
            updateServer();
        });
        // Restore previously stored responses
        restoreAnswers();
    }

    // Display response summary
    if ($('body.summary [data-storage_key]').length) {
        updateSessionStore(); // TODO: Wait until this is done to move on.
        $('[data-storage_key]').each( function () {
            var qResponse = getResponse($(this).data('storage_key'));
            if (qResponse) {
                $(this).html('<p class="question">' + qResponse.question + '</p><p class="response">' + qResponse.answer + '</p>'); 
            }
        });
    }
});
