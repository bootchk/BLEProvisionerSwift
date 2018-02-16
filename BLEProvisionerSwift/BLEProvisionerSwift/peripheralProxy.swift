//
//  peripheralProxy.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 12/29/17.
//  Copyright © 2017 Lloyd Konneker. All rights reserved.
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

// extension TemperatureViewController {
  
  var realSubjectDevice: CBPeripheral?
  var centralManager: CBCentralManager?
  var peripheralName: String?
  
  let syncher = Syncher()
  
  // Proxy owns characteristics
  var temperatureCharacteristic:CBCharacteristic?
  var humidityCharacteristic:CBCharacteristic?

  var serviceProxy: ServiceProxy?
  
  
  
  func setPeripheral(central: CBCentralManager!,
                     peripheral: CBPeripheral!,
                     name: String?) {
    centralManager = central
    realSubjectDevice = peripheral
    peripheralName = name
    realSubjectDevice!.delegate = self
    serviceProxy = ServiceProxy()
  }
  
  
  // Is this peripheral of the BT use case we want?
  func isProvisionable() -> Bool {
    // TODO more than just name match
    return peripheralName == Device.CustomServiceShortName
  }
  
  
  func requestConnection() {
    print("request connection")
    centralManager!.connectPeripheral(realSubjectDevice!, options: nil)
  }
  
  
  func disconnect() {
      if let realSubjectDevice = self.realSubjectDevice {
        if let tc = self.temperatureCharacteristic {
          realSubjectDevice.setNotifyValue(false, forCharacteristic: tc)
        }
        if let hc = self.humidityCharacteristic {
          realSubjectDevice.setNotifyValue(false, forCharacteristic: hc)
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
        centralManager!.cancelPeripheralConnection(realSubjectDevice)
        
        disconnectModel()
    }
  }
  
  
  // Remembered objects no longer valid
  func disconnectModel() {
    temperatureCharacteristic = nil
    humidityCharacteristic = nil
    realSubjectDevice = nil
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
          onDiscoverDesiredService(service)
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
      for characteristic in characteristics {
        
        print("Discovered characteristic \(characteristic)")
        
        if serviceProxy!.isCharacteristicOfThisService(characteristic) {
          onDiscoverDesiredCharacteristic(characteristic)
        }
        /*
        
        // Temperature Data Characteristic
        if characteristic.UUID == CBUUID(string: Device.TemperatureDataUUID) {
          // Enable the IR Temperature Sensor notifications
          //temperatureCharacteristic = characteristic
          realSubjectDevice?.setNotifyValue(true, forCharacteristic: characteristic)
        }
        
        // Temperature Configuration Characteristic
        if characteristic.UUID == CBUUID(string: Device.TemperatureConfig) {
          // Enable IR Temperature Sensor
          realSubjectDevice?.writeValue(enableBytes, forCharacteristic: characteristic, type: .WithResponse)
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
  /*
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
  */
  
  
  func discoverAllServices() {
    
    // pass nil here to request ALL services be discovered.
    // If there was a subset of services we were interested in, we could pass the UUIDs here.
    // Doing so saves battery life and saves time.
    realSubjectDevice!.discoverServices(nil)
  }
  
  func discoverAllCharacteristics(forService: CBService!) {
    realSubjectDevice!.discoverCharacteristics(nil, forService: forService)
  }
  
  
  
  
  
  func writeValue(widgetValue: UInt8,
                  widgetIndex: UInt8,
                  eventOffset: UInt8,
                  tss:         UInt8,
                  characteristic: CBCharacteristic) {
    
    let bytesToWrite = ValueSerializer.serialize(widgetValue, widgetIndex: widgetIndex, eventOffset: eventOffset, tss: tss)
    
    // value to write
    //var valueToWrite:UInt8 = value
    //let bytesToWrite = NSData(bytes: &valueToWrite, length: sizeof(UInt8))

    // length of characteristic must be 4 else write fails?
    // type must correspond to characteristic property else write fails?
    realSubjectDevice!.writeValue(bytesToWrite, forCharacteristic: characteristic, type: .WithoutResponse)
  }
  
}
