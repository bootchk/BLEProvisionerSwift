//
//  peripheralProxy.swift
//  BLETemperatureReaderSwift
//
//  Created by lloyd konneker on 12/29/17.
//  Copyright © 2017 Cloud City. All rights reserved.
//

import Foundation
import CoreBluetooth




/*
 Proxy pattern
 
 Real subject is a peripheral as returned by CB
 Also knows the central
 
 Responsibilities:
 - handling CBPeripheralDelegate methods
 - recognizing desired specific peripheral (by name and service)
 - knowing services and characteristics of peripheral
*/

class PeripheralProxy: NSObject, CBPeripheralDelegate {
  
  var sensorTag: CBPeripheral?
  var centralManager: CBCentralManager?
  var peripheralName: String?
  
  // Proxy owns characteristics
  var temperatureCharacteristic:CBCharacteristic?
  var humidityCharacteristic:CBCharacteristic?

  var serviceProxy: ServiceProxy?
  
  
  
  func setPeripheral(central: CBCentralManager!,
                     peripheral: CBPeripheral!,
                     name: String?) {
    centralManager = central
    sensorTag = peripheral
    peripheralName = name
    sensorTag!.delegate = self
    serviceProxy = ServiceProxy()
  }
  
  // Is this peripheral of the BT use case we want?
  func isProvisionable() -> Bool {
    // TODO more than just name match
    return peripheralName == "Firefl"  // "N07A2"
  }
  
  func requestConnection() {
    print("request connection")
    centralManager!.connectPeripheral(sensorTag!, options: nil)
  }
  
  
  func disconnect() {
      if let sensorTag = self.sensorTag {
        if let tc = self.temperatureCharacteristic {
          sensorTag.setNotifyValue(false, forCharacteristic: tc)
        }
        if let hc = self.humidityCharacteristic {
          sensorTag.setNotifyValue(false, forCharacteristic: hc)
        }
        
        /*
         NOTE: The cancelPeripheralConnection: method is nonblocking, and any CBPeripheral class commands
         that are still pending to the peripheral you’re trying to disconnect may or may not finish executing.
         Because other apps may still have a connection to the peripheral, canceling a local connection
         does not guarantee that the underlying physical link is immediately disconnected.
         
         From your app’s perspective, however, the peripheral is considered disconnected, and the central manager
         object calls the centralManager:didDisconnectPeripheral:error: method of its delegate object.
         
         Which will call self.onDisconnected()
         */
        centralManager!.cancelPeripheralConnection(sensorTag)
    }
  }
  
  
  func onDisconnected() {
    temperatureCharacteristic = nil
    humidityCharacteristic = nil
    sensorTag = nil
  }
  
  
  
  //MARK: - CBPeripheralDelegate methods
  
  /*
   Invoked when you discover the peripheral’s available services.
   
   This method is invoked when your app calls the discoverServices: method.
   If the services of the peripheral are successfully discovered, you can access them
   through the peripheral’s services property.
   
   If successful, the error parameter is nil.
   If unsuccessful, the error parameter returns the cause of the failure.
   */
  // When the specified services are discovered, the peripheral calls the peripheral:didDiscoverServices: method of its delegate object.
  func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    if error != nil {
      print("ERROR DISCOVERING SERVICES: \(error?.localizedDescription)")
      return
    }
    
    // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
    if let services = peripheral.services {
      for service in services {
        print("Discovered service \(service)")
        if serviceProxy!.isServerOfThisService(service) {
          peripheral.discoverCharacteristics(nil, forService: service)
        }
      }
    }
  }
  
  
  /*
   Invoked when you discover the characteristics of a specified service.
   
   If the characteristics of the specified service are successfully discovered, you can access
   them through the service's characteristics property.
   
   If successful, the error parameter is nil.
   If unsuccessful, the error parameter returns the cause of the failure.
   */
  func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    if error != nil {
      print("ERROR DISCOVERING CHARACTERISTICS: \(error?.localizedDescription)")
      return
    }
    
    if let characteristics = service.characteristics {
      // value to write
      var enableValue:UInt8 = 7
      let enableBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
      
      for characteristic in characteristics {
        
        print("Discovered characteristic \(characteristic)")
        
        if serviceProxy!.isCharacteristicOfThisService(characteristic) {
          print("writing value")
          // type must be correct else write fails?
          peripheral.writeValue(enableBytes, forCharacteristic: characteristic, type: .WithoutResponse)
          // Peripheral expected to disconnect itself after a write
        }
        /*
        
        // Temperature Data Characteristic
        if characteristic.UUID == CBUUID(string: Device.TemperatureDataUUID) {
          // Enable the IR Temperature Sensor notifications
          //temperatureCharacteristic = characteristic
          sensorTag?.setNotifyValue(true, forCharacteristic: characteristic)
        }
        
        // Temperature Configuration Characteristic
        if characteristic.UUID == CBUUID(string: Device.TemperatureConfig) {
          // Enable IR Temperature Sensor
          sensorTag?.writeValue(enableBytes, forCharacteristic: characteristic, type: .WithResponse)
        }
        
        if characteristic.UUID == CBUUID(string: Device.HumidityDataUUID) {
          // Enable Humidity Sensor notifications
          //humidityCharacteristic = characteristic
          sensorTag?.setNotifyValue(true, forCharacteristic: characteristic)
        }
        
        if characteristic.UUID == CBUUID(string: Device.HumidityConfig) {
          // Enable Humidity Temperature Sensor
          sensorTag?.writeValue(enableBytes, forCharacteristic: characteristic, type: .WithResponse)
        }
       */
      }
    }
  }
  
  
  /*
   Invoked when you retrieve a specified characteristic’s value,
   or when the peripheral device notifies your app that the characteristic’s value has changed.
   
   This method is invoked when your app calls the readValueForCharacteristic: method,
   or when the peripheral notifies your app that the value of the characteristic for
   which notifications and indications are enabled has changed.
   
   If successful, the error parameter is nil.
   If unsuccessful, the error parameter returns the cause of the failure.
   */
  func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    if error != nil {
      print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(error?.localizedDescription)")
      return
    }
    
    // extract the data from the characteristic's value property and display the value based on the characteristic type
    if let dataBytes = characteristic.value {
      if characteristic.UUID == CBUUID(string: Device.TemperatureDataUUID) {
        //displayTemperature(dataBytes)
      } else if characteristic.UUID == CBUUID(string: Device.HumidityDataUUID) {
        //displayHumidity(dataBytes)
      }
    }
  }
  
  
  
}
