//
//  gui.swift
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
   */
  func onActionStarted() {
    feedbackScanning(true)
    startTimedProvisioning()
    // Further actions disabled while this one is asynchronously executing
    enableActions(false)
  }
  
  func doModalAlert(message: String) {
    // self not know how to style widget, but only self can present it
    let alert: UIViewController = getAlertResultController(message)
    self.presentViewController(alert, animated: true, completion: nil)

  }
  
  func onActionExpired()  {
    feedbackScanning(false)
    self.doModalAlert("Failed to find device")
    enableActions(true)
  }
  
  
  
  // protocol ProvisioningDelegate protocol method
  func didSucceedProvisioning() {
    // cancel timer that would expire
    cancelSessionTimer()
    
    feedbackScanning(false)
    self.doModalAlert("Provisioned device")
    enableActions(true)
  }

  
}
