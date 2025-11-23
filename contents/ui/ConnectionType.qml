import QtQuick 2.15

// Connection type enum for wireless devices
QtObject {
    readonly property int wired: 0
    readonly property int bluetooth: 1
    readonly property int otherWireless: 2
}
