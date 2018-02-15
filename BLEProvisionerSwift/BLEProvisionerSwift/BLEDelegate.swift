//
//  BLEDelegate.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 2/15/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol ProvisioningDelegate: class {
  func didSucceedProvisioning()
}



/*
 Facade to CoreBluetooth
 
 Both sides of connection: Central and Peripheral
 
 CBCentral and CBPeripheral delegate to self.
 Self delegates to ProvisioningDelegate
 */

// CBCentralManagerDelegate requires NSObject
class BLEDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate  {
  
  // self role is BT Central, a client
  var centralManager:CBCentralManager!
  // proxy to remote BT Peripheral, a server
  var peripheralProxy: PeripheralProxy!
  
  // magical link to delegates
  weak var delegate: ProvisioningDelegate?
  
  
  
  init(delegate: ProvisioningDelegate?) {
    
    super.init()
    
    self.delegate = delegate
    
    // Create our CBCentral Manager
    // delegate: The delegate that will receive central role events. Typically self.
    // queue:    The dispatch queue to use to dispatch the central role events.
    //           If the value is nil, the central manager dispatches central role events using the main queue.
    centralManager = CBCentralManager(delegate: self, queue: nil)
    
    // Central Manager Initialization Options (Apple Developer Docs): http://tinyurl.com/zzvsgjh
    //  CBCentralManagerOptionShowPowerAlertKey
    //  CBCentralManagerOptionRestoreIdentifierKey
    //      To opt in to state preservation and restoration in an app that uses only one instance of a
    //      CBCentralManager object to implement the central role, specify this initialization option and provide
    //      a restoration identifier for the central manager when you allocate and initialize it.
    //centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    
    peripheralProxy = PeripheralProxy()
  }
  
  
  
  
  
  // MARK: - Bluetooth scanning
  
  func stopScan() {
    print("stop scan")
    centralManager.stopScan()
  }

  
  func startScan() {
    print("start scan")
    //Option 1: Scan for all devices
    //centralManager.scanForPeripheralsWithServices(nil, options: nil)
    
    // Option 2: Scan for devices that have the service you're interested in...
    //let realSubjectDeviceAdvertisingUUID = CBUUID(string: Device.realSubjectDeviceAdvertisingUUID)
    //print("Scanning for realSubjectDevice adverstising with UUID: \(realSubjectDeviceAdvertisingUUID)")
    //centralManager.scanForPeripheralsWithServices([realSubjectDeviceAdvertisingUUID], options: nil)
    centralManager.scanForPeripheralsWithServices([CBUUID(string: Device.CustomServiceUUID)], options: nil)
    
    
    peripheralProxy.onStartScan()
  }
  

  func isScanning() ->Bool {
    return centralManager.isScanning
  }
  
  
  func isConnected() ->Bool {
    let list = centralManager.retrieveConnectedPeripheralsWithServices([CBUUID(string: Device.CustomServiceUUID), ])
    print(list)
    // Assume no other app is connecting to the service, else will get a non-empty list
    return !list.isEmpty
  }

  
  
  
  
  // MARK: - CBCentralManagerDelegate methods
  
  // Invoked when the central manager’s state is updated.
  func centralManagerDidUpdateState(central: CBCentralManager) {
    
    /*
     Since most of these states impede app,
     alert user nothing is going to happen.
     */
    
    //var showAlert = true
    var message = ""
    
    switch central.state {
    case .PoweredOff:
      message = "Bluetooth on this device is currently powered off."
    case .Unsupported:
      message = "This device does not support Bluetooth Low Energy."
    case .Unauthorized:
      message = "This app is not authorized to use Bluetooth Low Energy."
    case .Resetting:
      message = "The BLE Manager is resetting; a state update is pending."
    case .Unknown:
      message = "The state of the BLE Manager is unknown."
    case .PoweredOn:
      //showAlert = false
      message = "Bluetooth LE is turned on and ready for communication."
      
      print(message);
    }
    /*
    if showAlert {
      let alertController = UIAlertController(title: "Central Manager State", message: message, preferredStyle: UIAlertControllerStyle.Alert)
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
      alertController.addAction(okAction)
      self.showViewController(alertController, sender: self)
    }
 */
  }
  
  
  /*
   Invoked when the central manager discovers a peripheral while scanning.
   
   The advertisement data can be accessed through the keys listed in Advertisement Data Retrieval Keys.
   You must retain a local copy of the peripheral if any command is to be performed on it.
   In use cases where it makes sense for your app to automatically connect to a peripheral that is
   located within a certain range, you can use RSSI data to determine the proximity of a discovered
   peripheral device.
   
   central - The central manager providing the update.
   peripheral - The discovered peripheral.
   advertisementData - A dictionary containing any advertisement data.
   RSSI - The current received signal strength indicator (RSSI) of the peripheral, in decibels.
   
   */
  func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    print("centralManager didDiscoverPeripheral - CBAdvertisementDataLocalNameKey is \"\(CBAdvertisementDataLocalNameKey)\"")
    
    // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
    if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
      print("NEXT PERIPHERAL NAME: \(peripheralName)")
      print("NEXT PERIPHERAL UUID: \(peripheral.identifier.UUIDString)")
      
      // Can get advertisement without peripheral
      if let thePeripheral: CBPeripheral = peripheral {
        peripheralProxy.setPeripheral(central, peripheral: thePeripheral, name: peripheralName);
        
        if peripheralProxy.isProvisionable() {
          peripheralProxy.onDiscoverProvisionable()
        }
      }
    }
    else {
      print("advertised but no peripheral")
    }
  }
  
  
  /*
   Invoked when a connection is successfully created with a peripheral.
   
   This method is invoked when a call to connectPeripheral:options: is successful.
   You typically implement this method to set the peripheral’s delegate and to discover its services.
   */
  func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    print("**** SUCCESSFULLY CONNECTED!!!")
    
    // User is not interested
    
    // Business logic
    peripheralProxy.onConnected()
  }
  
  
  /*
   Invoked when the central manager fails to create a connection with a peripheral.
   
   This method is invoked when a connection initiated via the connectPeripheral:options: method fails to complete.
   Because connection attempts do not time out, a failed connection usually indicates a transient issue,
   in which case you may attempt to connect to the peripheral again.
   */
  func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    print("**** CONNECTION TO desired device FAILED!!!")
  }
  
  
  /*
   Invoked when an existing connection with a peripheral is torn down.
   
   This method is invoked when a peripheral connected via the connectPeripheral:options: method is disconnected.
   If the disconnection was not initiated by cancelPeripheralConnection:, the error param shows the cause.
   After this method is called, no more methods are invoked on the peripheral device’s CBPeripheralDelegate object.
   
   When disconnected, all of the peripheral's services, characteristics, and characteristic descriptors are invalidated.
   */
  func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    print("**** DISCONNECTED FROM desired device!")
    if error != nil {
      
      // We expect peripheral to initiate disconnect, but result is success
      
      // Notify any delegates
      delegate?.didSucceedProvisioning()
      
      print("****** DISCONNECTION DETAILS: \(error!.localizedDescription)")
    }
    peripheralProxy.onDisconnected();
  }
  

}
