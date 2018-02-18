//
//  rangeDataSource.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 2/17/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation
import UIKit



class DropDownDataSource: NSObject, UIPickerViewDataSource {
  
  // Members passed in at init time
  var data : [String]!
  var provisionableIndex : Int!

  
  init(aProvisionableIndex: Int,
       someData: [String])
  {
    provisionableIndex = aProvisionableIndex
    data = someData
  }
  
  func getData(_ row: Int) -> String {
    return self.data![row]
  }
  
  
  // DataSource protocol
  
  // column count
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    // Fixed at one column
    return 1
  }
  
  // row count
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return data.count
  }
  
}
