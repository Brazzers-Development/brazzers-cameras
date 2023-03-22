$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "enableCam":
                eatMyAss(event);
            break;
            case "disableCam":
                suckACock();
            break;
        }
    })
});

function suckACock(){
    $("#container").css("display", "none");
    $("#blockscreen").css("display", "none");
}

function eatMyAss(event){
    var label = event.data.label
    var id = event.data.id
    var connected = event.data.connected
    var time = event.data.time

    var today = new Date();
    var date = (today.getMonth()+1)+'/'+(today.getDate())+'/'+today.getFullYear();
    var formatTime = "00:" + time

    if (connected) {
        $("#container").css("display", "block")
        $("#blockscreen").css("display", "none");

        $("#cameraLabel").html(label);
        $("#cameraDate").html(date);
        $("#cameraIP").html("169.69.01."+id);
        $("#cameraConnected").html("CONNECTED");
        $("#cameraTime").html(formatTime);

        $("#cameraConnected").removeClass("disconnect");
        $("#cameraConnected").addClass("connect");
    } else {
        $("#blockscreen").css("display", "block");

        $("#cameraLabel").html("ERROR #400: BAD REQUEST");
        $("#cameraDate").html("ERROR");
        $("#cameraIP").html("ERROR");
        $("#cameraConnected").html("CONNECTION FAILED");
        $("#cameraTime").html("ERROR");

        $("#cameraConnected").removeClass("connect");
        $("#cameraConnected").addClass("disconnect");
    }
}