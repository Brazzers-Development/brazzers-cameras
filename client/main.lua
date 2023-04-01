local QBCore = exports[Config.Core]:GetCoreObject()

local PlayerData = {}
local isLoggedIn = false

local cachedCameras = {}
local camera
local placingCamera = false

local viewCam
local viewingCamera = false
local camX = 0.0
local camY = 0.0
local camZ = 0.0
local camFov = 60.0

-- Functions

local function GetCurrentTime()
    local hours = GetClockHours()
    local minutes = GetClockMinutes()
    if hours < 10 then
        hours = tostring(0 .. GetClockHours())
    end
    if minutes < 10 then
        minutes = tostring(0 .. GetClockMinutes())
    end
    return tostring(hours .. ":" .. minutes)
end

local function RequestProp(prop)
    local hash = GetHashKey(prop)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(100)
        end
    end
end

local function haveAccessToCam(camid)
    local cid = QBCore.Functions.GetPlayerData().citizenid
    local retval = false
    if not cachedCameras[camid] then return end

    if cachedCameras[camid].owner == cid then
        retval = true
    end

    for _, v in pairs(cachedCameras[camid].access) do
        if v.cid == cid then
            retval = true
        end
    end

    return retval
end exports("haveAccessToCam", haveAccessToCam)

local function getMyCameras()
    local cid = QBCore.Functions.GetPlayerData().citizenid
    local cameraList = {}

    for k, v in pairs(cachedCameras) do
        if cachedCameras[v.camid].owner == cid then
            cameraList[#cameraList+1] = cachedCameras[k]
        end

        for _, access in pairs(cachedCameras[v.camid].access) do
            if access.cid == cid then
                cameraList[#cameraList+1] = cachedCameras[k]
            end
        end
    end

    table.sort(cameraList, function(a, b)
        return a.name < b.name
    end)

    return cameraList
end exports("getMyCameras", getMyCameras)

local function getAccessList(camid)
    if not cachedCameras[camid] then return end
    
    local accessList = {}

    if cachedCameras[camid].access then
        if #cachedCameras[camid].access > 0 then
            for _, v in pairs(cachedCameras[camid].access) do
                accessList[#accessList+1] = {
                    cid = v.cid,
                    name = v.name,
                }
            end
        end
    end

    table.sort(accessList, function(a, b)
        return a.name < b.name
    end)

    return accessList
end exports("getAccessList", getAccessList)

local function isCameraOwner(camid)
    if not cachedCameras[camid] then return end

    local cid = QBCore.Functions.GetPlayerData().citizenid
    local retval = false

    if cachedCameras[camid].owner == cid then
        retval = true
    end

    return retval
end exports("isCameraOwner", isCameraOwner)

local function fuckMe(coords, heading, model)
    TaskTurnPedToFaceCoord(PlayerPedId(), coords, 1.0)
    Wait(1000)
    TaskGoStraightToCoord(PlayerPedId(), coords.xyz, 1, -1, 0.0, 0.0)
    Wait(1500)
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})

    if model == 'prop_cctv_cam_06a' then
        coords = coords + vector3(0, -0.3, -0.3)
    end

    QBCore.Functions.Progressbar("placing_camera", 'Installing Camera', 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('brazzers-cameras:server:placeCamera', coords, heading, model)
    end, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        notification(Config.Lang['error']['canceled'], 'error')
    end)
end

local function placeCamera(model)
    local ped = PlayerPedId()
    placingCamera = true

    RequestProp(model)
    camera = CreateObject(GetHashKey(model), 0, 0, 0, true, true, true)

    SetEntityCollision(camera, false, false)
    SetEntityInvincible(camera, true)
    FreezeEntityPosition(camera, true)

    CreateThread(function()
        while placingCamera do
            local playerCoords = GetEntityCoords(ped)
            local hit, coords, entity = RayCastGamePlayCamera(7)

            coords = coords + Config.Models[model]['offset']

            SetEntityCoords(camera, coords)
            if hit and #(GetEntityCoords(ped) - coords) <= 5 then
                SetEntityAlpha(camera, 150)
                DrawLine(coords.x, coords.y, coords.z, playerCoords.x, playerCoords.y, playerCoords.z, 255, 255, 255, 255)

                if IsControlJustPressed(0, 241) then
                    SetEntityRotation(camera, 0, 0, GetEntityHeading(camera) + 10, 2, true)
                end
    
                if IsControlJustPressed(0, 242) then
                    SetEntityRotation(camera, 0, 0, GetEntityHeading(camera) - 10, 2, true)
                end

                if IsControlJustPressed(0, 38) then
                    DeleteEntity(camera)
                    placingCamera = false
                    fuckMe(coords, GetEntityHeading(ped), model)
                    break
                end

                if IsControlJustPressed(0, 194) then
                    notification(Config.Lang['error']['canceled'], 'error')
                    DeleteEntity(camera)
                    placingCamera = false
                    break
                end
            else
                SetEntityAlpha(camera, 0)
            end
            Wait(3)
        end
    end)
end

local function createObject(camid, coords)
    local model = cachedCameras[camid].model
    RequestProp(model)

    local cameraObject = CreateObject(model, coords.x, coords.y, coords.z, 0, 0, 0)
    FreezeEntityPosition(cameraObject, true)
    SetEntityHeading(cameraObject, coords.w)
    return cameraObject
end

local function removeObject(camid)
    if not cachedCameras[camid] then return end

    DeleteObject(cachedCameras[camid]['object'])
    cachedCameras[camid]['rendered'] = false
    cachedCameras[camid]['object'] = nil
end

local function getCamByObject(entity)
    for _, cam in pairs(cachedCameras) do
        if cam['object'] == entity then
            return cam, cam.camid
        end
    end
    return false
end

local function destroyCamera(entity)
    local camera, camid = getCamByObject(entity)
    local coords = camera.coords
    
    TaskGoStraightToCoord(PlayerPedId(), coords.xyz, 1, -1, 0.0, 0.0)
    Wait(1500)
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    QBCore.Functions.Progressbar("destroying_camera", 'Destroying Camera', 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('brazzers-cameras:server:removeCamera', camid)
    end, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        notification(Config.Lang['error']['canceled'], 'error')
    end)
end

local function exitCam(model)
    DoScreenFadeOut(400)
    Wait(400)
    if Config.Models[model]['use-nui-filter'] then
        SendNUIMessage({
            action = "disableCam",
        })
    end
    viewingCamera = false
    DestroyCam(viewCam, true)
    viewCam = nil
    ClearFocus()
    RenderScriptCams(false, false, 0, 1, 0)
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    DoScreenFadeIn(400)
    FreezeEntityPosition(PlayerPedId(), false)
end

local function thanksZooForRotation(model)
    local newY = camY
    while viewingCamera do
        local instructions = setupScaleform("instructional_buttons")
        DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)

        DisableAllControlActions(0)
        EnableControlAction(0, 32, true)
        EnableControlAction(0, 33, true)
        EnableControlAction(0, 34, true)
        EnableControlAction(0, 35, true)
        EnableControlAction(0, 241, true)
        EnableControlAction(0, 242, true)
        EnableControlAction(0, 202, true)

        if Config.Models[model]['allow-movement'] then
            if IsControlPressed(0, 32) then -- UP
                if camX <= 10.0 then
                    camX = camX + 0.2
                end
            end

            if IsControlPressed(0, 33) then -- DOWN
                if camX >= -30.0 then
                    camX = camX -0.2
                end
            end

            if IsControlPressed(0, 34) then -- LEFT
                if newY - (camY + 0.1) < -Config.Models[model]['max-rotation'] then
                    camY = camY
                else
                    camY = camY + 0.1
                end
            end

            if IsControlPressed(0, 35) then -- RIGHT
                if newY - (camY - 0.1) <= Config.Models[model]['max-rotation'] then
                    camY = camY - 0.1
                end
            end

            if IsControlPressed(0, 241) then -- ZOOM IN
                if camFov > -1.0 then
                    camFov = camFov - 3.0
                    SetCamFov(viewCam, camFov)
                end
            end

            if IsControlPressed(0, 242) then -- ZOOM OUT
                if camFov < 110.0 then
                    camFov = camFov + 3.0
                    SetCamFov(viewCam, camFov)
                end
            end
        end
        
        if IsControlJustPressed(0, 202) then
            exitCam(model)
        end

        SetCamRot(viewCam, camX, 0.0, camY, 2)
        Wait(0)
    end
end

local function viewCamera(camid)
    if not cachedCameras[camid] then return end
    if not haveAccessToCam(camid) then return print("NO ACCESS") end
    if viewingCamera then return end

    local coords = cachedCameras[camid].coords
    local model = cachedCameras[camid].model

    viewingCamera = true
    DoScreenFadeOut(400)

    Wait(400)
    FreezeEntityPosition(PlayerPedId(), true)
    viewCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamFov(viewCam, camFov)
    SetCamCoord(viewCam, coords.x, coords.y, coords.z)
    camZ = coords.w - 180
    if model == 'prop_cctv_cam_07a' then
        camZ = coords.w
    end


    camY = camZ

    if Config.Models[model]['use-nui-filter'] then
        SendNUIMessage({
            action = "enableCam",
            label = cachedCameras[camid].name,
            id = camid,
            time = GetCurrentTime(),
        })
    end

    SetCamRot(viewCam, camX, 0.0, camZ, 2)
    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0, 0, 0)
    RenderScriptCams(true, false, 0, 1, 0)

    if Config.Models[model]['use-camera-filter'] then
        SetTimecycleModifier("heliGunCam")
        SetTimecycleModifierStrength(0.7)
    end

    DoScreenFadeIn(250)
    thanksZooForRotation(model)
end exports("viewCamera", viewCamera)

local function trackCamera(camid)
    if not cachedCameras[camid] then return end
    local coords = cachedCameras[camid].coords
    SetNewWaypoint(coords.x, coords.y)
    notification(Config.Lang['primary']['marked'], 'primary')
end exports("trackCamera", trackCamera)

-- Events

RegisterNetEvent('brazzers-cameras:client:placeDownCamera', function(model)
    placeCamera(model)
end)

RegisterNetEvent('brazzers-cameras:client:addCamera', function(data)
    cachedCameras[data.camid] = data
end)

RegisterNetEvent('brazzers-cameras:client:removeCamera', function(camid)
    removeObject(camid)
    cachedCameras[camid] = nil
end)

RegisterNetEvent('brazzers-cameras:client:updateAccess', function(access, camid)
    cachedCameras[camid].access = access
end)

RegisterNetEvent('brazzers-cameras:client:updateName', function(name, camid)
    cachedCameras[camid].name = name
end)

-- Handlers

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true

    QBCore.Functions.TriggerCallback('brazzers-cameras:server:getCameras', function(result)
		cachedCameras = result
    end)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == 'brazzers-cameras' then
        for k, v in pairs(cachedCameras) do
            if v["rendered"] then
                DeleteObject(v["object"])
            end
        end
    end
end)

-- Threads

CreateThread(function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true

    QBCore.Functions.TriggerCallback('brazzers-cameras:server:getCameras', function(result)
		cachedCameras = result
    end)

    for model, _ in pairs(Config.Models) do
        exports[Config.Target]:AddTargetModel(model, {
            options = {
                {
                    icon = 'fas fa-camera',
                    label = 'Destroy Camera',
                    action = function(entity)
                        destroyCamera(entity)
                    end,
                },
            },
            distance = 2.5,
        })
    end
end)

CreateThread(function()
    while true do
        local sleep = 1500
        if not cachedCameras then cachedCameras = {} end
        for _, v in pairs(cachedCameras) do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            if #(pos - vector3(tonumber(v.coords.x), tonumber(v.coords.y), tonumber(v.coords.z))) < 100 then
                if not v['rendered'] then
                    local model = createObject(v.camid, v.coords)
                    v['rendered'] = true
                    v['object'] = model
                end
            end
            if #(pos - vector3(tonumber(v.coords.x), tonumber(v.coords.y), tonumber(v.coords.z))) >= 100 and v['rendered'] then
                if DoesEntityExist(v['object']) then
                    removeObject(v.camid)
                end
            end
        end
        Wait(sleep)
    end
end)