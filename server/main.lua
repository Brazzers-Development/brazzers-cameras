local QBCore = exports['qb-core']:GetCoreObject()

local cachedCameras = {}

-- Functions

local function getOfflinePlayer(cid)
    local result = MySQL.query.await("SELECT * FROM players WHERE citizenid = ?", {cid})
    if result[1] then
        for _, v in pairs(result) do
            return json.decode(v.charinfo)
        end
    end
end

local function generateCameraID()
    local UniqueFound = false
    local uniqueItemId = nil
    while not UniqueFound do
        uniqueItemId = string.upper('CAM-'..math.random(1111, 9999))
        local query = '%' .. uniqueItemId .. '%'
        local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM player_cameras WHERE camid LIKE ?', { query })
        if result == 0 then
            UniqueFound = true
        end
    end
    return uniqueItemId
end exports("generateBusinessId", generateBusinessId)

local function haveAccessToCam(cid, camid)
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

local function getMyCameras(cid)
    local cameraList = {}

    for k, v in pairs(cachedCameras) do
        if cachedCameras[v.camid].owner == cid then
            cameraList[#cameraList+1] = cachedCameras[k]
        end

        if cachedCameras[v.camid].access == cid then
            cameraList[#cameraList+1] = cachedCameras[k]
        end
    end

    table.sort(cameraList, function(a, b)
        return a.name < b.name
    end)

    return cameraList
end exports("getMyCameras", getMyCameras)

-- Events

RegisterNetEvent('brazzers-cameras:server:placeCamera', function(coords, heading, model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local CID = Player.PlayerData.citizenid
    local camID = generateCameraID()
    if not camID then return end

    local newCoords = {x = coords.x, y = coords.y, z = coords.z, w = heading}

    MySQL.insert('INSERT INTO player_cameras (`camid`, `name`, `owner`, `coords`, `model`) VALUES (?, ?, ?, ?, ?)', 
    {camID, camID, CID, json.encode(newCoords), model})

    Wait(100)
    cachedCameras[camID] = {camid = camID, name = camID, owner = CID, access = {}, coords = newCoords, model = model}
    TriggerClientEvent('brazzers-cameras:client:addCamera', -1, {camid = camID, name = camID, owner = CID, access = {}, coords = newCoords, model = model})

    TriggerClientEvent('QBCore:Notify', src, 'Camera placed', 'primary')

    -- Remove Item
    local item = Config.Models[model]['item']
    Player.Functions.RemoveItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove')
end)

RegisterNetEvent('brazzers-cameras:server:removeCamera', function(camid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not cachedCameras[camid] then return end

    MySQL.Async.execute('DELETE FROM player_cameras WHERE camid = ?', {camid})

    Wait(100)
    cachedCameras[camid] = nil
    TriggerClientEvent('brazzers-cameras:client:removeCamera', -1, camid)

    TriggerClientEvent('QBCore:Notify', src, 'Camera removed', 'primary')
end)

RegisterNetEvent('brazzers-cameras:server:addToCamera', function(cid, camid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not cachedCameras[camid] then return end

    local otherPlayer = getOfflinePlayer(cid)
    if not otherPlayer then return TriggerClientEvent('DoLongHudText', src, 'State ID doesn\'t exist', 2) end

    local name = otherPlayer.firstname..' '..otherPlayer.lastname
    local hasAccess = haveAccessToCam(cid, camid)
    if hasAccess then return TriggerClientEvent('QBCore:Notify', src, name..' already has access to this camera', 'error') end

    cachedCameras[camid].access[#cachedCameras[camid].access + 1] = {
        cid = cid,
        name = name,
    }

    MySQL.update("UPDATE player_cameras SET access = ? WHERE camid = ?",
    {json.encode(cachedCameras[camid].access), camid })

    Wait(100)
    TriggerClientEvent('brazzers-cameras:client:updateAccess', -1, cachedCameras[camid].access, camid)

    TriggerClientEvent('QBCore:Notify', src, name..' added to '..camid, 'primary')

    -- UPDATE NUI
    TriggerClientEvent('qb-phone:client:updateAccessList', src, camid)
end)

RegisterNetEvent('brazzers-cameras:server:removeFromCamera', function(cid, camid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not cachedCameras[camid] then return end

    local currentAccess = {}
    local otherPlayer = getOfflinePlayer(cid)
    if not otherPlayer then return TriggerClientEvent('DoLongHudText', src, 'State ID doesn\'t exist', 2) end
    local name = otherPlayer.firstname..' '..otherPlayer.lastname

    for k, v in pairs(cachedCameras[camid].access) do
        if v.cid ~= tostring(cid) then
            currentAccess[#currentAccess+1] = cachedCameras[camid].access[k]
        end
    end

    MySQL.update("UPDATE player_cameras SET access = ? WHERE camid = ?",
    {json.encode(currentAccess), camid })

    Wait(100)
    cachedCameras[camid].access = currentAccess
    TriggerClientEvent('brazzers-cameras:client:updateAccess', -1, currentAccess, camid)

    TriggerClientEvent('QBCore:Notify', src, name..' removed from camera', 'primary')

    -- UPDATE NUI
    TriggerClientEvent('qb-phone:client:updateAccessList', src, camid)
end)

RegisterNetEvent('brazzers-cameras:server:renameCamera', function(camid, name)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if not cachedCameras[camid] then return end

    if cachedCameras[camid].owner ~= cid then return TriggerClientEvent('QBCore:Notify', src, 'Only the owner can alter the camera name', 'primary') end

    cachedCameras[camid].name = name

    MySQL.update("UPDATE player_cameras SET name = ? WHERE camid = ?",
    {cachedCameras[camid].name, camid })

    Wait(100)
    TriggerClientEvent('brazzers-cameras:client:updateName', -1, cachedCameras[camid].name, camid)

    TriggerClientEvent('QBCore:Notify', src, 'Camera name changed to '..name, 'primary')

    -- UPDATE NUI
    local cameras = getMyCameras(cid)
    TriggerClientEvent('qb-phone:client:updateCameras', src, cameras)
end)

-- Threads

CreateThread(function()
    local result = MySQL.Sync.fetchAll('SELECT * FROM player_cameras')
    if not result then return end
    for _, v in pairs(result) do
        cachedCameras[v.camid] = {
            camid = v.camid,
            name = v.name,
            owner = v.owner,
            access = json.decode(v.access),
            coords = json.decode(v.coords),
            model = v.model,
        }
    end
end)

-- Useable Items

for k, v in pairs(Config.Models) do
    QBCore.Functions.CreateUseableItem(v['item'], function(source, item)
        TriggerClientEvent('brazzers-cameras:client:placeDownCamera', source, k)
    end)
end

-- Callbacks

QBCore.Functions.CreateCallback('brazzers-cameras:server:getCameras', function(_, cb)
	cb(cachedCameras)
end)