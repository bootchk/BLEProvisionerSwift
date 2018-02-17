//
//  valueSerializer.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 2/14/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation


/*
 Serialize various values into NSData
 to be written to a BLE characteristic.
 Peripheral will unserialize.
 
 We only use one BLE characteristic.
 All the GUI widgets write to the same characteristic.
 
 Values:
    widget index
    offset:  time since widget was activated (button pressed)
    Widget value
 */

class ValueSerializer  {
  
  // class method
  class func serialize(_ widgetValue: UInt8,
                       widgetIndex: UInt8,
                       eventOffset: UInt8,
                       tss:         UInt8) -> Data {
    
    var bytes = [UInt8](repeating: 0, count: 4)
    bytes[0] = widgetValue
    bytes[1] = widgetIndex
    bytes[2] = eventOffset
    bytes[3] = tss
    let result = Data(buffer: UnsafeBufferPointer(start: &bytes, count: 4))
    return result
  }
  
  // No unserialize method:  implemented on BT peripheral
}
