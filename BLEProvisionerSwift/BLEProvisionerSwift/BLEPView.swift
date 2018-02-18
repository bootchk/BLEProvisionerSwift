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
    let buttonLabelFontName = "HelveticaNeue-Thin"
    let buttonLabelFontSizeMessage:CGFloat = 56.0

    
    disconnectButton.isEnabled = true
    disconnectButton.setTitle( "<Provision>", for:UIControlState())
    //disconnectButton.setTitle( "<Searching...>", for:UIControlState.disabled)
    // Look
    disconnectButton.titleLabel!.font = UIFont(name: buttonLabelFontName, size: buttonLabelFontSizeMessage)!
    
    // quick hack, since iOS doesn't seem to provide a default style for buttons
    disconnectButton.layer.borderWidth = 1.0
    disconnectButton.layer.cornerRadius = 5.0
    disconnectButton.layer.borderColor = UIColor.gray.cgColor
  }
  
  
  func configureComboBox()  {
    let salutations = ["Mr.", "Ms.", "Mrs."]
    let rangeDataSource = DropDownDataSource(someData: salutations)
    
    pickerTextField.loadDropdownData(aDataSource: rangeDataSource,
                                     onSelect: handleComboBoxChosen
    )
    
    // Show down arrow
    pickerTextField.rightViewMode = .always
    // TODO either put image in assets, or do this all in IB
    pickerTextField.rightView = UIImageView(image: UIImage(named: "downArrow.png")) //"selectdrop"))
  }
  
  
  func configureInitialUI() {
    // lkk Why this?
    backgroundImageViews = [backgroundImageView1]
    //self.view.bringSubview(toFront: backgroundImageViews[0])
    // backgroundImageViews[0].alpha = 1
    
    self.view.bringSubview(toFront: controlContainerView)
    
    // TODO configure Provisioning process control widget (Range)
    
    // Configure Provisioning widgets
    configureButton()
    configureComboBox()
    
    // Initial state: no user action in progress
    feedbackScanning(false)
  }
  
  
  func updateBLEPModel(_ index: UInt8, value: UInt8) {
    /*
     Remember current widget.
     */
    BLEPModel.currentProvisionable.index = index
    BLEPModel.currentProvisionable.value = value
    
    /*
     Remember what value user tried to provision, even if provisioning fails.
     I.E. keep model corresponding with view's (widget's) value.
     */
    updateProvisionableProxyModel(index, value: value)
  }
  
  
  
  // MARK: User actions converted to abstract semantics
  
  @IBAction func handleDisconnectButtonTapped(_ sender: AnyObject) {
    
    /*
    Hardcode widget to provisionable relation.
    I.E. this button is for first provisionable.
    */
    updateBLEPModel(1, value: 99)  // value is dummy, action is a signal
    
    // Continue with: try to effect on remote device
    // viewDelegate?.onActionStarted()
    onActionStarted()
  }
  
  
  func handleComboBoxChosen(row: Int) {
    // assert row < max UInt8
    /*
    Provisioned value is row index.
    I.E. a code, not the String that the user chose.
    */
    updateBLEPModel(1, value: UInt8(row))
    onActionStarted()
  }
  
  
  /*
  User might have changed value of widget.
  Local change is effective even if later fail to provision remote device.
  */
  func updateProvisionableProxyModel(_ index: UInt8, value: UInt8) {
    BLEPModel.proxyValues[Int(index)] = value
  }
  
  
  // MARK: Implement abstract operations on GUI
  
  
  func feedbackScanning(_ isScanning: Bool) {
    /*
    HIG design notes: 
    1. show net activity widget is too obscure.
    2. activityIndicator widget is for non-quantifiable duration
    3. Duration is quantifiable (e.g. ten seconds max) so should use progress bar widget
    */
    progressView.isHidden = !isScanning
    
    // For now: Button label by state is also feedback.
  }

  
  func enableActions(_ shouldEnable: Bool) {
    /*
     Disable all the controls while async action is executing.
     So user cannot start two concurrent actions.
     We could leave the Range control enabled?
    */
    disconnectButton.isEnabled = shouldEnable
    pickerTextField.isEnabled = shouldEnable
    // TODO all the controls
  }
  
  /*
   Only self knows what style of alert.
   But only viewController can display it.
   */
 
  func getAlertResultController(_ message: String ) -> UIAlertController {
    let alertController = UIAlertController(title: "Provisioner", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
    alertController.addAction(okAction)
    return alertController
  }
  
  
  // MARK: progress
  
  func resetProgress() {
    progressView.setProgress(0.0, animated: false)
  }
  
  
}
