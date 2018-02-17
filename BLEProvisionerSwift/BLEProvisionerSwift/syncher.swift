//
//  syncher.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 1/6/18.
//  Copyright © 2018 Cloud City. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


/*
 Offset is duration from time of action (button pushed)
 to time action is sent to peripheral device.
 
 The offset is sent to provisioned device
 so it can know what real time button was remotely pushed.
 Real time button was pushed is time of arrival minus offset (after conversion of clock times.)
 */
class Syncher {
  
  var startScanTime:Date?
  //var discoverTime:NSDate?
  var offset:TimeInterval?
  
  func markStart() {
    startScanTime = Date()
  }
  
  func markEnd() {
    offset = Date().timeIntervalSince(startScanTime!)
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
