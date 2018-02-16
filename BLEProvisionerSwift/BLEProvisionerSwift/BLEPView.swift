//
//  BLEPView.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 2/15/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation
import UIKit



/*
 Methods to change abstract features of the view.
   feedbackScanning
   enableActions
   etc.
 
 It should call other VC methods only for abstract UI semantics.
 
 It implements look and feel.
 This file should isolate all IB and GUI implementation (except for properties).
 I.E. if code is an IBAction or uses an IBOutlet, code should be here.
 */

/*
 Currently implemented as extension.

 Cruft from failed attempt to implement by separate class view.
 Failed because I don't know IB well enough to set IBReferences to FileOwner?
 Used by the view controller.
 View has delegate the VC.
 
 // class BLEPView: UIView {
 // IBOutlets here
 
 //var viewDelegate: BLEPViewDelegate?
 protocol BLEPViewDelegate: class {
  func onActionStarted()
 
 override func awakeFromNib() {
 super.awakeFromNib()
 self.configureInitialUI()
 }
 */


extension ProvisionerViewController {
  
  func configureButton() {
    disconnectButton.enabled = true
    disconnectButton.setTitle( "Provision", forState:UIControlState.Normal)
    disconnectButton.setTitle( "Searching...", forState:UIControlState.Disabled)
    // Look
    disconnectButton.titleLabel!.font = UIFont(name: buttonLabelFontName, size: buttonLabelFontSizeMessage)!
    
    // quick hack, since iOS doesn't seem to provide a default style for buttons
    disconnectButton.layer.borderWidth = 1.0
    disconnectButton.layer.cornerRadius = 5.0
    disconnectButton.layer.borderColor = UIColor.grayColor().CGColor
  }
  
  func configureInitialUI() {
    backgroundImageViews = [backgroundImageView1]
    self.view.bringSubviewToFront(backgroundImageViews[0])
    backgroundImageViews[0].alpha = 1
    self.view.bringSubviewToFront(controlContainerView)
    
    configureButton()
  }
  
  
  
  // MARK: User actions converted to abstract semantics
  
  @IBAction func handleDisconnectButtonTapped(sender: AnyObject) {
    
    // viewDelegate?.onActionStarted()
    onActionStarted()
  }
  
  
  
  // MARK: Implement abstract operations on GUI
  
  
  func feedbackScanning(isScanning: Bool) {
    // TODO show net activity?
    
    //Button label by state is the feedback.
  }

  
  func enableActions(shouldEnable: Bool) {
    disconnectButton.enabled = shouldEnable
  }
  
  /*
   Only self knows what style of alert.
   But only viewController can display it.
   */
 
  func getAlertResultController(message: String ) -> UIAlertController {
    let alertController = UIAlertController(title: "Provisioner", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
    alertController.addAction(okAction)
    return alertController
  }
  
}