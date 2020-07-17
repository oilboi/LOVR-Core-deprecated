
function lovr.conf(t)

    -- Set the project identity
    t.identity = 'Core'

    -- Hotkeys
    t.hotkeys = true

    -- Headset settings
    t.headset.drivers = {}--{ 'leap', 'openxr', 'oculus', 'oculusmobile', 'openvr', 'webvr', 'desktop' }
    t.headset.msaa = 0
    t.headset.offset = 0

    -- Math settings
    --t.math.globals = true

    -- Enable or disable different modules
    t.modules.audio = false
    t.modules.data = false
    t.modules.event = true
    t.modules.graphics = true
    t.modules.headset = false
    t.modules.math = true
    t.modules.physics = true
    t.modules.thread = true
    t.modules.timer = true

    -- Configure the desktop window
    t.window.width = 1900
    t.window.height = 900
    t.window.fullscreen = true
    t.window.msaa = 0
    t.window.title = 'Core'
    t.window.icon = nil
  end
