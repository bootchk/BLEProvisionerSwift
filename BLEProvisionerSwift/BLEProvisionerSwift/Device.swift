
import Foundation


/*
 config i.e. constants of the app
 */


struct AppConstants {
  // duration of search/scan for provisionable
  static let sessionDuration:TimeInterval = 10.0
}



/*
 Constant identifiers for device, service, characteristics.
 
 Custom: not defined by BT consortium/org
 Others: well-known, registered with BT org
 */

struct Device {
  
  
  static let CustomDeviceUUID =         "8A0B38BC-1CB5-5E43-D417-9F74D55C0AE3"
  static let CustomServiceShortName = "Firefl"
  // over the air
  // static let CustomDeviceAdvertisingUUID = "AA10"
  static let CustomServiceUUID =        "03B80E5A-EDE8-4B33-A751-6CE34EC4C700"
  static let CustomCharacteristicUUID = "7772E5DB-3868-4112-A1A9-F2669D106BF3"
  
  // Not used:  apparently no way to check length of characteristic on iOS
  static let ExpectedCharacteristicLength = 4
  
  
  static let realSubjectDeviceAdvertisingUUID = "AA10"
}
