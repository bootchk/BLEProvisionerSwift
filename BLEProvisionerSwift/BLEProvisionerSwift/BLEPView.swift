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
 
 // viewDelegate?.onActionStarted()
 }
 */


extension ProvisionerViewController {
  
  func styleButton(aButton: UIButton) {
    /*
     Look i.e. style
     
     Mostly done in IB.
    */
    
    //let buttonLabelFontName = "HelveticaNeue-Thin"
    //let buttonLabelFontSizeMessage:CGFloat = 56.0
    //disconnectButton.titleLabel!.font = UIFont(name: buttonLabelFontName, size: buttonLabelFontSizeMessage)!
    
    /*
     Frame
     iOS doesn't seem to provide a default style for buttons
     */
    aButton.layer.borderWidth = 1.0
    aButton.layer.cornerRadius = 5.0
    aButton.layer.borderColor = UIColor.gray.cgColor
  }
  
  
  func configureButton(aButton: UIButton) {
    styleButton(aButton: aButton)
    
    // enabling is by the VC via enableActions
    // disconnectButton.setTitle( "<Provision>", for:UIControlState())
    //disconnectButton.setTitle( "<Searching...>", for:UIControlState.disabled)
  }
  
  
  
  /*
   Data becomes coded by index when sent to Provisionee.
   We don't need an enum because Provisioner doesn't really understand
   what the data means to the Provisionee.
   
   Even for the Range ComboBox
   */
  
  func configureProvisionableComboBox(
    parentTextField: UITextField,
    dataSource: DropDownDataSource)  {
    /*
    Crux difference: a provisionable has a callback to start provisioning remote device
    */
    
    
    parentTextField.setDropdownInputMethod(aDataSource: dataSource,
                                           onSelect: handleProvisionableComboBoxChosen
    )
    
    // Show down arrow
    //parentTextField.rightViewMode = .always
    // TODO either put image in assets, or do this all in IB
    //parentTextField.rightView = UIImageView(image: UIImage(named: "downArrow.png")) //"selectdrop"))
  }
  
  
  func configureProcessComboBox(
    parentTextField: UITextField,
    dataSource: DropDownDataSource)  {
    /*
     Crux difference: a process has impotent callback.
     Setting model.range is all it does.
     Later any provisioning process accesses model.range.
     */
    
    
    parentTextField.setDropdownInputMethod(aDataSource: dataSource,
                                           onSelect: handleProcessComboBoxChosen
    )
    
  }
  
  
  func configureInitialUI() {
    // Ancestor project had a background image
    
    self.view.bringSubview(toFront: controlContainerView)
    
    // configure Provisioning process control widget (Range)
    let rangeDataSource = DropDownDataSource(aProvisionableIndex: 99, someData: ["Near", "Mid", "Far"])
    configureProcessComboBox(parentTextField: rangeTextField, dataSource: rangeDataSource)
    
    // Configure Provisioning widgets
    configureButton(aButton: blinkNowButton)  // 0
    configureButton(aButton: scatterButton)   // 1
    
    // 2
    let blinkCycleDataSource = DropDownDataSource(aProvisionableIndex: 2, someData: ["2 seconds", "4 seconds", "8 seconds"])
    configureProvisionableComboBox(parentTextField: blinkCycleTextField, dataSource: blinkCycleDataSource)
    
    // 3
    let clusterSizeDataSource = DropDownDataSource(aProvisionableIndex: 3, someData: ["Small", "Mid", "Large"])
    configureProvisionableComboBox(parentTextField: clusterSizeTextField, dataSource: clusterSizeDataSource)
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
  
  
  
  /*
   Hardcode widget to provisionable relation.
   I.E. this button is for first provisionable.
   */
  @IBAction func handleBlinkNowButtonTapped(_ sender: AnyObject) {
    // 0 means: first ProvisionableControl
    updateBLEPModel(0, value: 99)  // value is dummy, action is a signal
    
    tryProvisionRemoteDevice()
  }
  
  @IBAction func handleScatterButtonTapped(_ sender: AnyObject) {
    // 1 means: second ProvisionableControl
    updateBLEPModel(1, value: 99)  // value is dummy, action is a signal
    
    tryProvisionRemoteDevice()
  }

  
  
  
  
  
  func handleProvisionableComboBoxChosen(
    dataSource: DropDownDataSource,
    row: Int)
  {
    // assert row < max UInt8
    /*
    User chose row in picker.
    Provisioned value is that row's index in picker data.
    I.E. a code, not the String that the user chose.
    */
    
    // data source knows index of provisionable
    updateBLEPModel(UInt8(dataSource.provisionableIndex), value: UInt8(row))
    tryProvisionRemoteDevice()
  }
  
  
  
  
  
  func handleProcessComboBoxChosen(
    dataSource: DropDownDataSource,
    row: Int)
  {
    // assert row < max UInt8
    /*
     Provisioned value is row index.
     I.E. a code, not the String that the user chose.
     */
    print("Process combobox chosen")
    // Does nothing?? Update process model.
  }
  
  
  /*
  User might have changed value of widget.
  Local change is effective even if later fail to provision remote device.
  */
  func updateProvisionableProxyModel(_ index: UInt8, value: UInt8) {
    BLEPModel.proxyValues[Int(index)] = value
  }
  
  
  // MARK: Implement abstract operations on view
  
  
  func feedbackScanning(_ isScanning: Bool) {
    /*
    HIG design notes: 
    1. show net activity widget is too obscure.
    2. activityIndicator widget is for non-quantifiable duration
    3. Duration is quantifiable (e.g. ten seconds max) so should use progress bar widget
     
    Do NOT change button label by state to indicate progress.
    */
    
    /*
     Do not hide the progressView, it leads to CGContext warnings.
     but reset it if not scanning
     Not this: progressView.isHidden = !isScanning
     */
    if (!isScanning) {
      resetProgress()
    }
  }

  
  func enableActions(_ shouldEnable: Bool) {
    /*
     Disable all the controls while async action is executing.
     So user cannot start two concurrent actions.
     We could leave the Range control enabled?
    */
    blinkNowButton.isEnabled = shouldEnable
    scatterButton.isEnabled = shouldEnable
    
    // TODO textField doesn't have any feedback to show disabled
    rangeTextField.isEnabled = shouldEnable
    clusterSizeTextField.isEnabled = shouldEnable
    blinkCycleTextField.isEnabled = shouldEnable
  }
  
  /*
   Only self knows what style of alert.
   But only viewController can display it.
   */
 
  func getAlertResultController(_ message: String ) -> UIAlertController {
    let alertController = UIAlertController(title: "Fireflies", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
    alertController.addAction(okAction)
    return alertController
  }
  
  
  // MARK: progress
  
  func resetProgress() {
    progressView.setProgress(0.0, animated: false)
  }
  
  // TODO TimerWithProgress knows progressView but shouldn't?
  
}
