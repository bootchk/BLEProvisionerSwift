//
//  serviceProxy.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 12/30/17.
//  Copyright © 2017 Lloyd Konneker. All rights reserved.
//

import Foundation
import CoreBluetooth


/*
 Represents service
 Knows how to identify service we are seeking.
 
 Many parameters are a real subject i.e. a discovered service from an advertising device/peripheral.
 */
class ServiceProxy {
  
  func isServerOfThisService(realSubjectService: CBService ) -> Bool {
    return realSubjectService.UUID == CBUUID(string: Device.CustomServiceUUID)
  }
  
  func isCharacteristicOfThisService(realSubjectCharacteristic: CBCharacteristic ) -> Bool {
    return realSubjectCharacteristic.UUID == CBUUID(string: Device.CustomCharacteristicUUID)
  }

  
}