//
//  businessLogic.swift
//  BLETemperatureReaderSwift
//
//  Created by lloyd konneker on 1/1/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation
import CoreBluetooth


/*
 logic of application/business
 
 This chains business events together.
 The logic is discover device, connect, discover service, discover characteristic, write it, then disconnect.
 With no delays
 */


extension PeripheralProxy {

//class Logician {
  
  func onStartScan() {
    /*
    Record time of button press, later calculate delta and write it to characteristic.
    E.g. "mark" time now.
    */
    startScanTime = NSDate()
  }
  
  
  func onDiscoverProvisionable() {
    // Immediately try connect
    
    discoverTime = NSDate()
    
    print("Desired device FOUND!")
    // to save power, stop scanning for other devices
    // keepScanning = false
    //disconnectButton.enabled = true
    
    requestConnection()
  }
  
  
  func onConnected() {
    // Immediately try discover services
    discoverAllServices()
  }
  
  
  func onDiscoverDesiredService(service: CBService!) {
    // Immediately try discover characteristics
    discoverAllCharacteristics(service)
  }
  
  
  func onDiscoverDesiredCharacteristic(characteristic:CBCharacteristic!) {
    // Immediately write the characteristic
    print("writing value")
    // type must be correct else write fails?
    writeValue(1, characteristic: characteristic)
    
    /*
    In this app, expect peripheral to disconnect itself after a write
    */
    let duration = NSDate().timeIntervalSinceDate(discoverTime!)
    print("Time from discover to write: \(duration)")
 
  }
  
  
  func onDisconnected() {
    let duration = NSDate().timeIntervalSinceDate(discoverTime!)
    print("Time from discover to disconnected: \(duration)")
  }
  
  
  
  }


