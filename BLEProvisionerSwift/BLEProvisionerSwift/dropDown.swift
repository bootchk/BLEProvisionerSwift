//
//  dropDown.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 2/16/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation
import UIKit


typealias SelectionHandler = (DropDownDataSource, Int) -> Void


/*
 Extend with method that:
 creates input method of Dropdown type 
 for all UITextFields
 */
extension UITextField {
  
  func setDropdownInputMethod(aDataSource: DropDownDataSource,
                        onSelect selectionHandler : @escaping SelectionHandler
                       )
  {
    self.inputView = DropDown(aDataSource: aDataSource,
                              dropdownField: self,
                              onSelect: selectionHandler)
  }
}



/*
 A picker (dropdown/dropup spinner) specialized as an input method to a text field
 
 Initialized with the owning text view and datasource.
 
 The owning text view typically created with IB.
 Parent of text view initializes it with DropDown by calling method setDropdownInputMethod
 The owning text view DropDown when the user chooses the text view's input method.
 The default input method is a keyboard, the same machinery will show any (custom, like this) input method.
 */



// Subclass of UIPickerView that is its own ViewDelegate
// DataSource is passed in
class DropDown: UIPickerView, UIPickerViewDelegate {	// , UIPickerViewDataSource
  
  // Members passed in at init time
  var dropDownDataSource : DropDownDataSource! // [String]!
  var pickerTextField : UITextField!
  var selectionHandler : SelectionHandler?
  
  
  init(aDataSource: DropDownDataSource,
       dropdownField: UITextField,
       onSelect selectionHandler : @escaping SelectionHandler
       )
  {
    //super.init()  
    super.init(frame: CGRect.zero)
    
    self.dropDownDataSource = aDataSource     // !!! NOT dataSource, which is a member of superclass UIPickerView
    self.pickerTextField = dropdownField
    self.selectionHandler = selectionHandler
    
    // !!! Class is its own delegate for UIPickerViewDelegate protocol.  See below
    self.delegate = self
    
    // Class is NOT its own delegate for DataSource protocol
    self.dataSource = aDataSource
    
    /*
    Schedule for later execution: closure that enables self's text field.
    We can't do this now, because initialization of self is not done yet?
    */
    DispatchQueue.main.async(
      execute: {
        // if data is not empty?  Why would it ever be empty?
        if self.dropDownDataSource.pickerView(self, numberOfRowsInComponent: 1) > 0 {
          // self.numberOfRows(inComponent: 1) > 0 {   // dropDownDataSource.count > 0 {
          // Default to first row of data
          self.pickerTextField.text = self.dropDownDataSource.getData(0) // WAS: self.data[0]
          self.pickerTextField.isEnabled = true
        } else {
          self.pickerTextField.text = nil
          self.pickerTextField.isEnabled = false
        }
      } // end closure
    )
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  
  // UIPickerViewDelegate protocol
  
  // return data for given row and component (column)
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return dropDownDataSource.getData(row)
  }

  
  /*
   The crux: selecting from picker populates text field
   */
  // On user did select
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    print("Selected")
    pickerTextField.text = dropDownDataSource.getData(row)

    
    pickerTextField.resignFirstResponder()
    
    // signal parent that user chose row of widget
    // parent can access DataSource by row to get String
    selectionHandler?(self.dataSource as! DropDownDataSource, row)
  }

}
