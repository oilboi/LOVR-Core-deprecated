
function lovr.conf(t)

    -- Set the project identity
    t.identity = 'default'

    -- Hotkeys
    t.hotkeys = true

    -- Headset settings
    t.headset.drivers = { 'leap', 'openxr', 'oculus', 'oculusmobile', 'openvr', 'webvr', 'desktop' }
    t.headset.msaa = 4
    t.headset.offset = 0

    -- Math settings
    --t.math.globals = true

    -- Enable or disable different modules
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.headset = false
    t.modules.math = true
    t.modules.physics = true
    t.modules.thread = true
    t.modules.timer = true

    -- Configure the desktop window
    t.window.width = 1080
    t.window.height = 600
    t.window.fullscreen = false
    t.window.msaa = 0
    t.window.vsync = 1
    t.window.title = 'Core'
    t.window.icon = nil
  end