//
//  syncher.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 1/6/18.
//  Copyright © 2018 Cloud City. All rights reserved.
//

import Foundation

/*
 Offset is duration from time of action (button pushed)
 to time action is sent to peripheral device.
 
 The offset is sent to provisioned device
 so it can know what real time button was remotely pushed.
 Real time button was pushed is time of arrival minus offset (after conversion of clock times.)
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
    
    if (offset > AppConstants.sessionDuration) {
      print("Interval exceeded")
      result = 0
    }
    else {
      result = UInt8( (offset! / AppConstants.sessionDuration) * 255 )
    }
    return result
  }
  
}
