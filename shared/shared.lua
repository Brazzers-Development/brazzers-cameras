Config = Config or {}

Config.Core = 'qb-core'
Config.Target = 'rush-eye'

Config.RenewedPhone = true -- [true]: you're using the phone app instead of the standalone built UI
Config.EnableCommand = false -- this is only for standalone version if you wanna enable a command to open the menu
Config.Command = 'cameras'

Config.DeleteOnDays = true -- [true]: allows cameras to be deleted from the database after the amount of days set below
Config.DaysLasts = 7 -- [int] Above must be set to `true` for this to even do anything

Config.Models = {
    ['prop_cctv_cam_06a'] = {
        ['offset'] = vector3(0, 0, 0),
        ['allow-movement'] = true,
        ['max-rotation'] = 90,
        ['use-camera-filter'] = true,
        ['use-nui-filter'] = true,
        ['item'] = 'camera2',
    },
    ['prop_spycam'] = {
        ['offset'] = vector3(0, 0, 0),
        ['allow-movement'] = false,
        ['max-rotation'] = false,
        ['use-camera-filter'] = false,
        ['use-nui-filter'] = false,
        ['item'] = 'camera1',
    },
    ['prop_cctv_cam_07a'] = {
        ['offset'] = vector3(0, 0.5, 0),
        ['allow-movement'] = true,
        ['max-rotation'] = 360,
        ['use-camera-filter'] = true,
        ['use-nui-filter'] = true,
        ['item'] = 'camera3',
    },
}

Config.Lang = {
    ['primary'] = {
        ['placed'] = 'Camera placed',
        ['removed'] = 'Camera removed',
        ['added'] = 'added to',
        ['removedfrom'] = 'removed from camera',
        ['altername'] = 'Only the owner can alter the camera name',
        ['namechanged'] = 'Camera name changed to',
        ['marked'] = 'Camera marked on your GPS',
    },
    ['error'] = {
        ['stateid'] = 'State ID doesn\'t exist',
        ['canceled'] = 'Canceled',
        ['alreadyaccess'] = 'already has access to this camera',
    }
}