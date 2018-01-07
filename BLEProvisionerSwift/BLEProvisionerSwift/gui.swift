//
//  gui.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 12/29/17.
//  Copyright © 2017 lloyd konneker
//

import Foundation
import UIKit


extension ProvisionerViewController {
  
  
  func feedbackScanning(isScanning: Bool) {
    // TODO show net activity?
    
    //Button label by state is the feedback.
  }
  
  
  func feedbackConnected(isConnected: Bool) {
  }

  
  func alertResult(message: String ) {
    let alertController = UIAlertController(title: "Provisioner", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
    alertController.addAction(okAction)
    self.showViewController(alertController, sender: self)
  }
  
  
  /*
   Action is scan for provisionable and provision it.
   */
  func onActionStarted() {
    feedbackScanning(true)
    startTimedProvisioning()
    disconnectButton.enabled = false
  }
  
  
  func onActionExpired()  {
    feedbackScanning(false)
    alertResult("Failed to find device")
    disconnectButton.enabled = true
  }
  
  func onActionSuccess() {
    // cancel timer that would expire
    cancelTimer()
    
    feedbackScanning(false)
    alertResult("Provioned device")
    disconnectButton.enabled = true
  }

  
}
