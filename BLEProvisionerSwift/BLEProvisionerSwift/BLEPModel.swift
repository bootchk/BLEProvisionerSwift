//
//  BLEPModel.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 2/16/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation

/*
 Model for provisioning.
 
 ProvisionableControl:  a control for an app on a remote device
 
 ProvisionableControlSet: set of ", each identified by an index
 
 ProvisionableControlProxy: a local representative i.e. a widget.
 A ProvisionableControlProxy does not reliably know the value of any ProvisionableControl instance on any remote device.
 It is probablistic that acting on a ProvisionableControlProxy has any effect, on an unknown one remote device.
 Acting on it DOES set the local value (even if it fails to control a remote device.)
 Every touch of the widget for a ProvisionableControlProxy changes local value, and trys to control some remote device.
 
 ProvisionMessage: a high-level message to a remote device, conveying an index and value (and other stuff) for a ProvisionableControl.
 
 ProvisionMessage are tunneled through one BLE characteristic (ProvisionableCharacteristic) of one BLE service (ProvisioningService).
 I.e.  sender multiplexes, receiver demultiplexes, on message.index.
 
 ProvisioningRange: effective range of Provisioning action, e.g. diameter of BLE communication.
 Implemented by sending a TSS in a ProvisionMessage (and receiver filters by comparing RSS to TSS.)
 ProvisioningRange is not a ProvisionableControl and does not have ProvisionableControlProxy, but does have a widget.
 */

/*
 Responsibilities:
   know index and value of current ProvisionableControlProxy (last one user acted on)
   know value of ProvisioningRange
   know values of ProvisionableControlProxy
 
 Collaborators:
   widgets for ProvisionableControlProxy set current ProvisionableControl
 
   widget sets ProvisioningRange
 
   GUI semantics get current ProvisionableControl (value and index) and ProvisioningRange (to make a ProvisionMessage)
 */

class CurrentProvisionable {
  // Properties
  // For ease of serialization, UInt8
  fileprivate var _index:UInt8 = 0
  var index:UInt8 {
    get {
      return _index
    }
    set { // default param name is newValue
      _index = newValue //
    }
  }
  
  fileprivate var _value:UInt8 = 0
  var value:UInt8 {
    get {
      return _value
    }
    set { // default param name is newValue
      _value = newValue //
    }
  }
}


// TODO enum?
class ProvisioningRange {
  // For ease of serialization, UInt8
  fileprivate var _range:UInt8 = 0
  var range:UInt8 {
    get {
      return _range
    }
    set { // default param name is newValue
      _range = newValue //
    }
  }
}


class Provisionable {
  // For ease of serialization, UInt8
  fileprivate var _range:UInt8 = 0
  var range:UInt8 {
    get {
      return _range
    }
    set { // default param name is newValue
      _range = newValue //
    }
  }
}


/*
 Pure class, no instance
 */
class BLEPModel {
  
  /*
   The current provisioning.
   Non null when user takes an action.
   */
  static var currentProvisionable: CurrentProvisionable = CurrentProvisionable()
  
  /*
  For a widget that is NOT a provisionable, but a control of the provisioning process.
  
  Also does not persist between sessions.
  */
  static var provisioningRange: ProvisioningRange = ProvisioningRange()
  
  
  // TODO default values from the application
  /*
   Values displayed in the proxies (the widgets).
   These DO NOT indicate values from the peripherals (Provisioning is one-way.)
 
   These are non-null when the app starts, before any user actions.
   
   These follow any user-actions. If current provisioning is not-null, it equals the provisioningProxy for the same index.
   
   Any values that followed user-actions DO NOT persist between sessions with app.
   
   Some are moot (for provisionableControls that are just signals) but must be one-to-one with proxy widgets
 */
  static var proxyValues: [UInt8] = [0, 1, 2, 3]
}

