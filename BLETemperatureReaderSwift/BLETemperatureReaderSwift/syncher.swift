//
//  syncher.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 1/6/18.
//  Copyright © 2018 Cloud City. All rights reserved.
//

import Foundation

/*
 Calculates offset from time of action (button pushed)
 to time action is sent to peripheral device.
 
 The offset is written to peripheral device
 so it can know what real time button was remotely pushed.
 */
class Syncher {
  
  var startScanTime:NSDate?
  //var discoverTime:NSDate?
  var offset:NSTimeInterval?
  
  func markStart() {
    startScanTime = NSDate()
  }
  
  func markEnd() {
    offset = NSDate().timeIntervalSinceDate(startScanTime!)
  }
  
  func getOffset() -> UInt8 {
    /*
     as a ratio to 255 of the offset to an interval of 10 seconds.
     That gives a resolution of about .04 seconds.
     The offset is usually at least 0.5 seconds (takes that long to connect and write)
     A value of 0 means offset was greater than the interval.
     */
    var result:UInt8
    if (offset > 10) {
      result = 0
    }
    else {
      result = UInt8( (offset! / 2) * 255 )
    }
    return result
  }
  
}
