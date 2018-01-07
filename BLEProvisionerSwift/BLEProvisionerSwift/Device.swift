
import Foundation


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
    
    static let realSubjectDeviceAdvertisingUUID = "AA10"
  
  /*
    static let TemperatureServiceUUID = "F000AA00-0451-4000-B000-000000000000"
    static let TemperatureDataUUID =    "F000AA01-0451-4000-B000-000000000000"
    static let TemperatureConfig =      "F000AA02-0451-4000-B000-000000000000"

    static let HumidityServiceUUID = "F000AA20-0451-4000-B000-000000000000"
    static let HumidityDataUUID = "F000AA21-0451-4000-B000-000000000000"
    static let HumidityConfig = "F000AA22-0451-4000-B000-000000000000"

    static let SensorDataIndexTempInfrared = 0
    static let SensorDataIndexTempAmbient = 1
    static let SensorDataIndexHumidityTemp = 0
    static let SensorDataIndexHumidity = 1
 */
}
