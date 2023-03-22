Config = Config or {}

Config.Target = 'rush-eye'

Config.Models = {
    ['prop_cctv_cam_06a'] = {
        ['offset'] = vector3(0, 0.5, 0),
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