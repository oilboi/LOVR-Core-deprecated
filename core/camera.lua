--this is a useful function for easily getting the 3D vector
--of the camera (in radians)
function core.get_camera_dir()
    return math.cos(core.camera.pitch) * math.cos(-core.camera.yaw-math.pi/2),
           math.sin(core.camera.pitch),
           math.cos(core.camera.pitch) * math.sin(-core.camera.yaw-math.pi/2)
end
