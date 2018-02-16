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
  
  
  func updateBLEPModel(index: UInt8, value: UInt8) {
    /*
     Remember current widget.
     */
    BLEPModel.currentProvisionable.index = index
    BLEPModel.currentProvisionable.value = value
    
    /*
     Remember what value user tried to provision, even if provisioning fails.
     I.E. keep model corresponding with widget's value.
     */
    updateProvisionableProxyModel(index, value: value)
  }
  
  
  // MARK: User actions converted to abstract semantics
  
  @IBAction func handleDisconnectButtonTapped(sender: AnyObject) {
    
    /*
    Hardcode widget to provisionable relation.
    I.E. this button is for first provisionable.
    */
    updateBLEPModel(1, value: 5)  // TODO value from widget
    
    // Continue with: try to effect on remote device
    // viewDelegate?.onActionStarted()
    onActionStarted()
  }
  
  
  /*
  User might have changed value of widget.
  Local change is effective even if later fail to provision remote device.
  */
  func updateProvisionableProxyModel(index: UInt8, value: UInt8) {
    BLEPModel.proxyValues[Int(index)] = value
  }
  
  
  // MARK: Implement abstract operations on GUI
  
  
  func feedbackScanning(isScanning: Bool) {
    /*
    HIG design notes: 
    1. show net activity is too obscure.
    2. activityIndicator is for non-quantifiable duration
    3. Duration is quantifiable (e.g. ten seconds max) so should use progress bar.
    */
    // TODO progress bar
    
    // For now: Button label by state is the feedback.
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