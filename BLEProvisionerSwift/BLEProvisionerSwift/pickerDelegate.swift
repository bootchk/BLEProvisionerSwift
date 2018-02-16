//
//  pickerDelegate.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 2/16/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation
import UIKit


/*
 Create input method of Dropdown type for all UITextFieldss
 */
extension UITextField {
  func loadDropdownData(data: [String]) {
    self.inputView = DropDown(pickerData: data, dropdownField: self)
  }
}


/*
 Text field with input method a picker (dropdown/dropup)
 */
// Subclass of UIPickerView that is its own delegate
class DropDown: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
  //
  //var pickerData: [String] = ["Item 1", "Item 2", "Item 3"]
  
  // Members passed in at init time
  var pickerData : [String]!
  var pickerTextField : UITextField!
  
  init(pickerData: [String], dropdownField: UITextField) {
    super.init(frame: CGRectZero)
    
    self.pickerData = pickerData
    self.pickerTextField = dropdownField
    
    // !!! Class is its own delegates
    self.delegate = self
    self.dataSource = self
    
    /*
    lkk Don't understand this
    */
    dispatch_async(dispatch_get_main_queue(), {
      if pickerData.count > 0 {
        self.pickerTextField.text = self.pickerData[0]
        self.pickerTextField.enabled = true
      } else {
        self.pickerTextField.text = nil
        self.pickerTextField.enabled = false
      }
    })
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  
  // DataSource protocol
  
  // column count
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  // row count
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
  }
  
  // return data for given row and component (column)
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
  }
  
  
  
  // UIPickerViewDelegate protocol
  
  /*
   The crux: selecting from picker populates text field
   */
  // On user did select
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    print("Selected")
    pickerTextField.text = pickerData[row]
    
    pickerTextField.resignFirstResponder()
    
    //if ((self.pickerTextField.text != nil) && (self.selectionHandler != nil)) {
    //  selectionHandler(selectedText: self.pickerTextField.text!)
    //}
  }

}