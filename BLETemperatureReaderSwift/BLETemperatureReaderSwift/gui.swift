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
  
  // MARK: - Updating UI
  
  func feedbackScanning(isScanning: Bool) {
    // TODO show net activity?
    
    //Button label by state is the feedback.
 
    /*
    if (isScanning) {
      temperatureLabel.font = UIFont(name: temperatureLabelFontName, size: temperatureLabelFontSizeMessage)
      temperatureLabel.text = "Scanning"
    }
    else {
      temperatureLabel.text = "Paused"
    }
   */
  }
  
  
  func feedbackConnected(isConnected: Bool) {
    /*
    if (isConnected) {
      temperatureLabel.font = UIFont(name: temperatureLabelFontName, size: temperatureLabelFontSizeMessage)
      temperatureLabel.text = "Connected"
    }
    else {
      temperatureLabel.text = "Disconnected"
    }
    */
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
    
    // alert user of failure
    alertResult("Failed to find device")
    disconnectButton.enabled = true
  }
  
  func onActionSuccess() {
    cancelTimer()
    feedbackScanning(false)
    alertResult("Provioned device")
    disconnectButton.enabled = true
  }

  
}
