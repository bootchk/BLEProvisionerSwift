BLEProvisionerSwift


An app that configures i.e. provisions a remote device using Bluetooth BLE.

For iOS written in Swift

App shows a button.  When pushed, finds a certain (custom) BLE device and writes one certain characteristic of the device.  The written value is a time interval since the button was pushed, so the device can calculate the real time the button was pushed.  More simply you could say that the app provisions or configures one value to a BT device.

The app is a BT client.  The BT peripheral device provides a service: able to be synchronized to the button push of the client app.

The service device can use little power, advertising infrequently.  If the client app fails to find a peripheral device after a button push and before a certain timeout, the app alerts the user than no device was found (provisioned.)  Also alerts on success.

As written, the app expects the peripheral to disconnect itself after being provisioned i.e. the app does not want to maintain a connection longer than required to write one characteristic.

The time interval to find and provision depends on how often the peripheral is advertising and the RF environment.

The time interval to provision (from time app discovers peripheral to time app writes characteristic) is typically about half a second.  That probably results from properties of the Bluetooth protocol and probably doesn't result from properties of iOS or app software implementations.

Project derived from ZeroToBLESwift project on Github.

Test cases:

Finds a device:
    1. Press Provision button
        Expect "Searching" to appear.
    2. Wait no more than ten seconds
       Expect an alert "Provisioned device"
       Expect device's characteristic to be written with the time since Provision button was pushed as a ratio to 255 of ten seconds.
    3. Press OK
       Expect "Provision" button enabled again.


Fail to find device:
    1. Press Provision button
        Expect "Searching" to appear.
    2. Wait
       Expect no more than ten seconds elapsed
       Expect an alert "Failed to find device"
    3. Press OK
       Expect "Provision" button enabled again.
  
Find device at the last moment:
Repeat many times, varying timing relative to when the device is awake (the peripheral is asleep mostly).
When the timing is such that a device is found just before a session ends, should behave as for "Finds a device".  Expect one alert or the other, but not both.  In rare cases, the characteristic may be written with a 0, meaning the time since "Provision" button was pushed was greater than ten seconds.

Device dies after connection:
If the device dies after a connection is made, the app should eventually (?) timeout the connection.
    

