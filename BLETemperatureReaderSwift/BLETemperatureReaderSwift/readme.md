

An app that configures or provisions a Bluetooth BLE device.

For iOS written in Swift

App shows a button.  When pushed, finds a certain (custom) BLE device and writes one certain characteristic of the device.  The written value is a time interval since the button was pushed, so the device can calculate the real time the button was pushed.  More simply you could say that the app provisions or configures one value to a BT device.

The app is a BT client.  The BT peripheral device provides a service: able to be synchronized to the button push of the client app.

The service device can use little power advertising infrequently.  If the client app fails to find a peripheral device after a button push and before a certain timeout, the app alerts the user than no device was found (and provisioned.)  Also alerts on success.

As written, the app expects the peripheral to disconnect itself after being provisioned i.e. the app does not want to maintain a connection longer than required to write one characteristic.

Project derived from ZeroToBLESwift project on Github.