let cam

// Functions

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "updateCameras":
                SetupGoPros(event.data.cameras);
            break;
            case "updateAccessList":
                getAccessList(event.data.cameras);
            break;
        }
    })
});

function ConfirmationFrame() {
    $('.spinner-input-frame').css("display", "flex");
    setTimeout(function () {
        $('.spinner-input-frame').css("display", "none");
        $('.checkmark-input-frame').css("display", "flex");
        setTimeout(function () {
            $('.checkmark-input-frame').css("display", "none");
        }, 2000)
    }, 1000)
}

SetupGoPros = function(cams) {
    $(".gopro-lists").html("");
    if (JSON.stringify(cams) != "[]"){
        $.each(cams, function(i, cams){
            var Element = `<div class="gopro-list" id="cam-${cams.camid}">
                <div class="gopro-list-icon"><i class="fas fa-camera"></i></div>
                <div class="gopro-list-name">${cams.name}</div>
                <div class="gopro-action-buttons">
                    <i class="fas fa-eye" id="gopro-view-camera" data-id="${cams.camid}" data-toggle="tooltip" title="View"></i>
                    <i class="fas fa-thumbtack" id="gopro-track-camera" data-id="${cams.camid}" data-toggle="tooltip" title="Track"></i>
                    <i class="fas fa-users" id="gopro-get-access" data-id="${cams.camid}" data-toggle="tooltip" title="Add Someone"></i>
                    <i class="fas fa-tags" id="gopro-rename-camera" data-id="${cams.camid}" data-toggle="tooltip" title="Rename Camera"></i>  
                </div>
            </div>`;
            $(".gopro-lists").append(Element);
        });
    }else{
        $(".gopro-lists").html('<p class="nomails">Nothing Here! <i class="fas fa-frown" id="mail-frown"></i></p>');
    }
}

// Search Bar Filter

// Right now only the first search bar works, then breaks when you click into a job and back out. Second page doesn't work at all. SHIT DEV
$(document).ready(function(){
    $("#gopro-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".gopro-list").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).ready(function(){
    $("#gopro-access-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".gopro-list").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

// On Clicks

$(document).on('click', '#gopro-view-camera', function(e){
    e.preventDefault();
    cam = $(this).data('id')
    $.post("https://qb-phone/gopro-viewcam", JSON.stringify({
        camid: cam,
    }));

    QB.Phone.Functions.Close();
});

$(document).on('click', '#gopro-track-camera', function(e){
    e.preventDefault();
    cam = $(this).data('id')
    $.post("https://qb-phone/gopro-track", JSON.stringify({
        camid: cam,
    }));
});

// ACCESS PAGE

function closeDropDown(){
    dropdownOpen = false
    $('.phone-dropdown-menu').fadeOut(350);
}

function iluvcum(){
    $(".gopro-header").html("");

    var HeaderOption = `<span id="gopro-search-text">Search</span>
    <i class="fas fa-search" id="gopro-search-icon"></i>
    <input type="text" id="gopro-search" placeholder="" spellcheck="false">`

    $('.gopro-header').append(HeaderOption); // SETS HEADER
    // Load Main Page
    $.post('https://qb-phone/SetupGoPros', JSON.stringify({}), function(Cams){
        SetupGoPros(Cams);
    })
}

function getAccessList(camid){
    $(".gopro-lists").html("") // Resets the old screen

    // Fade out the old header to create the new header
    $(".gopro-header").html("");

    $.post('https://qb-phone/gopro-accesslist', JSON.stringify({camid: camid}), function(data){
        for (const [_, v] of Object.entries(data)) {
            console.log(v.name)
            var Element = `<div class="gopro-list" id="cam-${camid}">
                <div class="gopro-list-icon"><i class="fas fa-user"></i></div>
                <div class="gopro-list-name">${v.name}</div>
                <div class="gopro-list-extra">State ID: ${v.cid}</div>
                <div class="gopro-action-buttons" data-stateid="${v.cid}">
                </div>
            </div>`;
            $(".gopro-lists").append(Element);
        }
    });

    $.post('https://qb-phone/gopro-isowner', JSON.stringify({camid: camid}), function(owner){
        if (owner){
            var removeEmployeeIcon = `<i class="fas fa-user-alt-slash" id="gopro-removefrom-camera" data-id="${camid}" data-toggle="tooltip" title="Remove"></i>`
            $(removeEmployeeIcon).appendTo( $( ".gopro-action-buttons" ) );
        }
    });

    // Creates the new header
    var HeaderOption = `<span id="gopro-access-search-text">Search</span>
    <i class="fas fa-chevron-left" id="gopro-access-back-icon"></i>
    <i class="fas fa-search" id="gopro-access-search-icon"></i>
    <input type="text" id="gopro-access-search" placeholder="" spellcheck="false">`;

    $('.gopro-header').append(HeaderOption); // Creates the new header

    $.post('https://qb-phone/gopro-isowner', JSON.stringify({camid: camid}), function(owner){
        if (owner){
            var shit = `<i class="fas fa-ellipsis-v" id="gopro-access-extras-icon"></i>`
            $(shit).appendTo( $( ".gopro-header" ) );
        }
    });
}

$(document).on('click', '#gopro-access-back-icon', function(e){
    e.preventDefault();
    iluvcum()
});

$(document).on('click', '#gopro-access-extras-icon', function(e){
    e.preventDefault();
    $('#gopro-dropdown').html('')
    dropdownOpen = true

    var addPlayerOption = `<div class="list-content" id='gopro-addto-camera' ><i class="fas fa-user-plus"></i>Give Camera Access</div>`
    $(addPlayerOption).appendTo( $( "#gopro-dropdown" ) );

    $('#gopro-dropdown').fadeIn(350);
});

$(document).on('click', '#gopro-get-access', function(e){
    e.preventDefault();
    ClearInputNew()
    cam = $(this).data('id')
    getAccessList(cam)
});

$(document).on('click', '#gopro-removefrom-camera', function(e){
    e.preventDefault();
    var stateid = $(this).parent().data('stateid')
    setTimeout(function(){
        ConfirmationFrame()
    }, 150);
    $.post("https://qb-phone/gopro-removeaccess", JSON.stringify({
        camid: cam,
        stateid: stateid,
    }));
});

$(document).on('click', '#gopro-addto-camera', function(e){
    e.preventDefault();
    closeDropDown()
    $('#gopro-access-menu').fadeIn(350);
});

$(document).on('click', '#gopro-send-access', function(e){
    e.preventDefault();
    var stateid = $(".gopro-stateid-access").val();
    if(stateid != ""){
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post("https://qb-phone/gopro-giveaccess", JSON.stringify({
            camid: cam,
            stateid: stateid,
        }));
    }
    ClearInputNew()
    $('#gopro-access-menu').fadeOut(350);
});

// RENAME CAMERA

$(document).on('click', '#gopro-rename-camera', function(e){
    e.preventDefault();
    ClearInputNew()
    cam = $(this).data('id')
    $('#gopro-rename-menu').fadeIn(350);
});

$(document).on('click', '#gopro-rename-submit', function(e){
    e.preventDefault();
    var newName = $(".gopro-name-camera").val();
    if(newName){
        setTimeout(function(){
            ConfirmationFrame()
        }, 150);
        $.post("https://qb-phone/gopro-rename", JSON.stringify({
            camid: cam,
            name: newName,
        }));
    }
    ClearInputNew()
    $('#gopro-rename-menu').fadeOut(350);
});
