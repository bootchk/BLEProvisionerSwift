//
//  BLEPSemantics.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 12/29/17.
//  Copyright © 2017 lloyd konneker
//

import Foundation
import UIKit

/*
 Abstract semantics of user interface.
 Without regard for look and feel.
 */

extension ProvisionerViewController {
  
  
  func startTimedProvisioning()  {
    startSessionTimer()    // timeout, with completion onActionExpired
    bleDelegate.startScan();
  }
  
  
  /*
   Action is scan for provisionable and provision it.
   
   !!! Assert view already updated proxy model  with any value user chose
   */
  func tryProvisionRemoteDevice() {
    feedbackScanning(true)
    startTimedProvisioning()
    // Further actions disabled while this one is asynchronously executing
    enableActions(false)
  }
  
  func doModalAlert(_ message: String) {
    // self not know how to style widget, but only self can present it
    let alert: UIViewController = getAlertResultController(message)
    self.present(alert, animated: true, completion: nil)

  }
  
  func onActionExpired()  {
    feedbackScanning(false)
    // tell user we failed provisioned device, in app's terminology and user's language
    self.doModalAlert("<Failed to find device>")
    enableActions(true)
  }
  
  
  
  // protocol ProvisioningDelegate protocol method
  func didSucceedProvisioning() {
    // cancel timer that would expire
    cancelSessionTimer()
    
    feedbackScanning(false)
    // tell user we provisioned device, in app's terminology and user's language
    self.doModalAlert("<Provisioned device>")
    enableActions(true)
    
    
  }

  
}
