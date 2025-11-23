import QtQuick 2.15

// Device information parser for UPower output
QtObject {
    id: parser
    
    required property var connectionTypes
    
    function parseDeviceInfo(output) {
        var lines = output.split("\n")
        var device = {
            name: "",
            serial: "",
            nativePath: "",
            percentage: -1,
            type: "",
            icon: "input-mouse",
            connectionType: connectionTypes.wired
        }
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            
            // Detect wireless devices and determine connection type
            if (line.indexOf("native-path:") !== -1) {
                device.nativePath = line.split(":")[1].trim()
                var path = line.toLowerCase()
                
                // Bluetooth devices have MAC addresses in their native path
                var hasMacAddress = /[0-9a-f]{2}[:\-_][0-9a-f]{2}[:\-_][0-9a-f]{2}/.test(path)
                
                if (path.indexOf("bluez") !== -1 || 
                    path.indexOf("bluetooth") !== -1 ||
                    hasMacAddress) {
                    device.connectionType = connectionTypes.bluetooth
                }
                else if (path.indexOf("gip") !== -1) {
                    device.connectionType = connectionTypes.wireless
                }
            }
            
            // Get device serial/MAC address
            if (line.indexOf("serial:") !== -1) {
                device.serial = line.split(":").slice(1).join(":").trim()
            }
            
            // Get device model/name
            if (line.indexOf("model:") !== -1) {
                device.name = line.split(":")[1].trim()
            }
            
            // Get battery percentage
            if (line.indexOf("percentage:") !== -1) {
                var percentStr = line.split(":")[1].trim().replace("%", "")
                device.percentage = parseInt(percentStr)
            }
            
            // Determine device type and icon
            var lowerLine = line.toLowerCase()
            if (lowerLine.indexOf("gaming-input") !== -1 || 
                lowerLine.indexOf("gaming") !== -1 || 
                lowerLine.indexOf("controller") !== -1 || 
                lowerLine.indexOf("gamepad") !== -1 ||
                lowerLine.indexOf("dualsense") !== -1 ||
                lowerLine.indexOf("dualshock") !== -1 ||
                lowerLine.indexOf("xbox") !== -1) {
                device.type = "gamepad"
                device.icon = "input-gamepad"
            } else if (lowerLine.indexOf("mouse") !== -1) {
                device.type = "mouse"
                device.icon = "input-mouse"
            } else if (lowerLine.indexOf("keyboard") !== -1) {
                device.type = "keyboard"
                device.icon = "input-keyboard"
            } else if (lowerLine.indexOf("headset") !== -1 || 
                       lowerLine.indexOf("headphone") !== -1 ||
                       lowerLine.indexOf("earbuds") !== -1) {
                device.type = "headset"
                device.icon = "audio-headset"
            } else if (lowerLine.indexOf("phone") !== -1 ||
                       lowerLine.indexOf("mobile") !== -1) {
                device.type = "phone"
                device.icon = "smartphone"
            } else if (lowerLine.indexOf("tablet") !== -1) {
                device.type = "tablet"
                device.icon = "tablet"
            }
        }
        
        // Use native path as identifier if no serial/MAC 
        if (!device.serial && device.nativePath) {
            device.serial = device.nativePath
        }
        
        return device
    }
}
