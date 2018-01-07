//
//  businessLogic.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 1/1/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation
import CoreBluetooth


/*
 logic of application/business
 
 This chains business events together.
 The chain is:
 - user start action (push button)
 - discover device, 
 - connect
 - discover service
 - discover characteristic
 - write characteristic
 - (written device expected to disconnect itself)
 - wait for disconnect
 - enable action again (ready to repeat)
 With no delays
 
 TODO the value written is a "mark" of sync
 i.e. elapsed time from user button pushed to time of write to characteristic
 */


extension PeripheralProxy {

//class Logician {
  
  func onStartScan() {
    /*
    Record time of button press, later calculate delta and write it to characteristic.
    E.g. "mark" time now.
    */
    syncher.markStart()
  }
  
  
  func onDiscoverProvisionable() {
    // discoverTime = NSDate()
    print("Desired device FOUND!")
    // Immediately try connect
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
    
    // Write an offset from button push to now,
    syncher.markEnd()
    
    let writtenValue = syncher.getOffset()
    
    print("writing value: \(writtenValue)")
    
    // type must be correct type of BLE characteristic (one byte) else write fails?
    writeValue(writtenValue, characteristic: characteristic)
    
    /*
    In this app, expect peripheral to disconnect itself after a write
    */
  }
  
  
  func onDisconnected() {
    // Testing reveals this duration is about 1 second
    
    //let duration = NSDate().timeIntervalSinceDate(discoverTime!)
    //print("Time from discover to disconnected: \(duration)")
  }
  
  
  
  }


