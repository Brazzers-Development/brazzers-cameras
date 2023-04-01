var dropdownOpen = false

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "enableCam":
                eatMyAss(event);
            break;
            case "disableCam":
                suckACock();
            break;
            case "open":
                $('.container').fadeIn(500);
                setupCameras(event.data.cameras);
            break;
            case "refreshCameras":
                setupCameras(event.data.cameras);
            break;
            case "refreshAccessList":
                getAccessList(event.data.cameras);
            break;
        }
    })
});

function setHomePageSearch(){
    $("#search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".list").filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
    });
}

function setAccessPageSearch(){
    $("#access-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".list").filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
    });
}

function suckACock(){
    $("#container-camera").css("display", "none");
}

function eatMyAss(event){
    var label = event.data.label
    var id = event.data.id
    var time = event.data.time

    var today = new Date();
    var date = (today.getMonth()+1)+'/'+(today.getDate())+'/'+today.getFullYear();
    var formatTime = "00:" + time

    $("#container-camera").css("display", "block")
    
    $("#cameraDate").html(date);
    $("#cameraIP").html("169.69.01."+id);
    $("#cameraTime").html(formatTime);
}

function closeDropDown(){
    dropdownOpen = false
    $('.dropdown-menu').fadeOut(350);
}

function setupCameras(cams){
    $(".header").html("");
    var HeaderOption = `<i class="fas fa-search" id="search-icon"></i>
    <input type="text" id="search" placeholder="" spellcheck="false">`
    $('.header').append(HeaderOption); // SETS HEADER

    setHomePageSearch()

    $(".lists").html("");
    if (JSON.stringify(cams) != "[]"){
        $.each(cams, function(i, cams){
            var element = `<div class="list" id="cam-${cams.camid}">
                <div class="list-icon"><i class="fas fa-camera"></i></div>
                <div class="list-name">${cams.name}</div>
                <div class="action-buttons">
                    <i class="fas fa-eye" id="view-camera" data-id="${cams.camid}"></i>
                    <i class="fas fa-thumbtack" id="track-camera" data-id="${cams.camid}"></i>
                    <i class="fas fa-users" id="get-access" data-id="${cams.camid}"></i>
                    <i class="fas fa-tags" id="rename-camera" data-id="${cams.camid}"></i>  
                </div>
            </div>`;
            $(".lists").append(element);
        });
    }else{
        $(".lists").html('<p class="nomails">Nothing Here! <i class="fas fa-frown" id="mail-frown"></i></p>');
    }
}

function getAccessList(camid){
    $(".lists").html("") // Resets the old screen

    // Fade out the old header to create the new header
    $(".header").html("");

    $.post('https://brazzers-cameras/accessList', JSON.stringify({camid: camid}), function(data){
        for (const [_, v] of Object.entries(data)) {
            var Element = `<div class="list" id="cam-${camid}">
                <div class="list-icon"><i class="fas fa-user"></i></div>
                <div class="list-name">${v.name}</div>
                <div class="list-extra">State ID: ${v.cid}</div>
                <div class="action-buttons" data-stateid="${v.cid}">
                </div>
            </div>`;
            $(".lists").append(Element);
        }
    });

    $.post('https://brazzers-cameras/isOwner', JSON.stringify({camid: camid}), function(owner){
        if (owner){
            var removeEmployeeIcon = `<i class="fas fa-user-alt-slash" id="removefrom-camera" data-id="${camid}"></i>`
            $(removeEmployeeIcon).appendTo( $( ".action-buttons" ) );
        }
    });

    // Creates the new header
    var HeaderOption = `<i class="fas fa-chevron-left" id="access-back-icon"></i>
    <i class="fas fa-search" id="access-search-icon"></i>
    <input type="text" id="access-search" placeholder="" spellcheck="false">`;

    $('.header').append(HeaderOption); // Creates the new header

    setAccessPageSearch()

    $.post('https://brazzers-cameras/isOwner', JSON.stringify({camid: camid}), function(owner){
        if (owner){
            var shit = `<i class="fas fa-ellipsis-v" id="access-extras-icon"></i>`
            $(shit).appendTo( $( ".header" ) );
        }
    });
}

// On Clicks

$(document).on('click', '#view-camera', function(e){
    e.preventDefault();
    cam = $(this).data('id')
    $.post("https://brazzers-cameras/viewCam", JSON.stringify({
        camid: cam,
    }));

    $('.container').fadeOut(250);
    $.post('https://brazzers-cameras/close');
});

$(document).on('click', '#track-camera', function(e){
    e.preventDefault();
    cam = $(this).data('id')
    $.post("https://brazzers-cameras/trackCam", JSON.stringify({
        camid: cam,
    }));
});

$(document).on('click', '#rename-camera', function(e){
    e.preventDefault();
    cam = $(this).data('id')
    $('#rename-menu').fadeIn(350);
});

$(document).on('click', '#rename-submit', function(e){
    e.preventDefault();
    var newName = $(".name-camera").val();
    if(newName){
        $.post("https://brazzers-cameras/renameCam", JSON.stringify({
            camid: cam,
            name: newName,
        }));
    }
    $('#rename-menu').fadeOut(350);
});

$(document).on('click', '#get-access', function(e){
    e.preventDefault();
    cam = $(this).data('id')
    getAccessList(cam)
});

$(document).on('click', '#access-back-icon', function(e){
    e.preventDefault();
    $.post('https://brazzers-cameras/setupCameras', JSON.stringify({}), function(Cams){
        setupCameras(Cams);
    })
});

$(document).on('click', '#access-extras-icon', function(e){
    e.preventDefault();
    $('#dropdown').html('')
    dropdownOpen = true

    var addPlayerOption = `<div class="list-content" id='addto-camera' ><i class="fas fa-user-plus"></i>Give Camera Access</div>`
    $(addPlayerOption).appendTo( $( "#dropdown" ) );

    $('#dropdown').fadeIn(350);
});

$(document).on('click', '#addto-camera', function(e){
    e.preventDefault();
    closeDropDown()
    $('#access-camera-menu').fadeIn(350);
});

$(document).on('click', '#access-camera-submit', function(e){
    e.preventDefault();
    var stateid = $(".stateid-access").val();
    if(stateid != ""){
        $.post("https://brazzers-cameras/giveAccess", JSON.stringify({
            camid: cam,
            stateid: stateid,
        }));
    }
    $('#access-camera-menu').fadeOut(350);
});

$(document).on('click', '#removefrom-camera', function(e){
    e.preventDefault();
    var stateid = $(this).parent().data('stateid')
    $.post("https://brazzers-cameras/removeAccess", JSON.stringify({
        camid: cam,
        stateid: stateid,
    }));
});

// Global Shit

$(document).on('click', '#cancel', function(e){
    e.preventDefault();
    $(".input-menu-text").val("");
    $('.input-menu-body').fadeOut(350);
});

$(document).on('click', '.close-button', function(e){
    e.preventDefault();
    $('.container').fadeOut(500);
    $.post('https://brazzers-cameras/close');
});

// Shit UI

$(document).on('keydown', function() {
    switch(event.keyCode) {
    case 27:
        if (dropdownOpen){
            $('.dropdown-menu').fadeOut(350);
            dropdownOpen = false
        }else{
            $('.container').fadeOut(500);
            $.post('https://brazzers-cameras/close');
        }
    break;
    }
});

