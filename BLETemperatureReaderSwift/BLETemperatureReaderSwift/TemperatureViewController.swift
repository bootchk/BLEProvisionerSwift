//
//  TemperatureViewController.swift
//  iOSRemoteConfBLEDemo
//
//  Created by Evan Stone on 4/9/16.
//  Copyright © 2016 Cloud City. All rights reserved.
//

import UIKit
import CoreBluetooth

//import peripheralProxy

// Conform to CBCentralManagerDelegate, CBPeripheralDelegate protocols
class TemperatureViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var backgroundImageView1: UIImageView!
    @IBOutlet weak var backgroundImageView2: UIImageView!
    @IBOutlet weak var controlContainerView: UIView!
    //@IBOutlet weak var circleView: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var disconnectButton: UIButton!
    
    // define our scanning interval times
    let timerInterval:NSTimeInterval = 20.0
    let timerScanInterval:NSTimeInterval = 2.0
  
    var timer = NSTimer()
    
    // UI-related
    let temperatureLabelFontName = "HelveticaNeue-Thin"
    let temperatureLabelFontSizeMessage:CGFloat = 56.0
    let temperatureLabelFontSizeTemp:CGFloat = 81.0
    
    var backgroundImageViews: [UIImageView]!
    var visibleBackgroundIndex = 0
    var invisibleBackgroundIndex = 1
    
    var lastTemperatureTens = 0
    let defaultInitialTemperature = -9999
    var lastTemperature:Int!
    
    var lastHumidity:Double = -9999
    
    //var circleDrawn = false
    //var keepScanning = false
    //var isScanning = false
    
    
    // Core Bluetooth properties
    var centralManager:CBCentralManager!
    
    var peripheralProxy: PeripheralProxy!
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastTemperature = defaultInitialTemperature

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
      
        // configure initial UI
        /*
        temperatureLabel.font = UIFont(name: temperatureLabelFontName, size: temperatureLabelFontSizeMessage)
        temperatureLabel.text = "Searching"
        humidityLabel.text = ""
        humidityLabel.hidden = true
        */
        backgroundImageViews = [backgroundImageView1, backgroundImageView2]
        view.bringSubviewToFront(backgroundImageViews[0])
        backgroundImageViews[0].alpha = 1
        backgroundImageViews[1].alpha = 0
        view.bringSubviewToFront(controlContainerView)
        
        disconnectButton.enabled = true
        disconnectButton.setTitle( "Foo", forState:UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        // If app has displayed sensor values, update them here
    }
  
  
    // MARK: timers
  
    func startTimer() {
        print("start timer")
        timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval,
                                                       target: self,
                                                       selector: #selector(timerExpired),
                                                       userInfo: nil,
                                                       repeats: false)
    }
    
    // MARK: - Handling User Interaction
    
    // TODO rename
    @IBAction func handleDisconnectButtonTapped(sender: AnyObject) {
        // peripheralProxy.disconnect()
        onActionStarted()
    }
    
    func toggleScanning() {
        if centralManager.isScanning {
            feedbackScanning(true)
            stopScan()
        }
        else {
            
            startScan()
        }
    }
    
    
    // MARK: - Bluetooth scanning
    
    @objc func timerExpired() {
        // Scanning uses up battery on phone
        print("Timer fired...")
        
        onActionExpired()
    }
    
    
    func startScan() {
        print("start scan")
        //Option 1: Scan for all devices
        //centralManager.scanForPeripheralsWithServices(nil, options: nil)
        
        // Option 2: Scan for devices that have the service you're interested in...
        //let sensorTagAdvertisingUUID = CBUUID(string: Device.SensorTagAdvertisingUUID)
        //print("Scanning for SensorTag adverstising with UUID: \(sensorTagAdvertisingUUID)")
        //centralManager.scanForPeripheralsWithServices([sensorTagAdvertisingUUID], options: nil)
        centralManager.scanForPeripheralsWithServices([CBUUID(string: Device.CustomServiceUUID)], options: nil)
        
        
        peripheralProxy.onStartScan()
    }
    
    func stopScan() {
        print("stop scan")
        centralManager.stopScan()
    }
    
    
    
    func startTimedProvisioning()  {
        startTimer()    // timeout
        startScan();
    }
    
    
    
    /*
    func resumeScan() {
        if keepScanning {
            // Start scanning again...
            print("*** RESUMING SCAN!")
            disconnectButton.enabled = false
            feedbackScanning(true)
            _ = NSTimer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            startScan()
            
        } else {
            disconnectButton.enabled = true
        }
    }
    */
    
        
        
    // MARK: - CBCentralManagerDelegate methods
    
    // Invoked when the central manager’s state is updated.
    func centralManagerDidUpdateState(central: CBCentralManager) {
        var showAlert = true
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
            showAlert = false
            message = "Bluetooth LE is turned on and ready for communication."
            
            print(message);
        }
        
        if showAlert {
            let alertController = UIAlertController(title: "Central Manager State", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            self.showViewController(alertController, sender: self)
        }
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
        feedbackConnected(true)
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
        feedbackConnected(false)
        if error != nil {
            // We expect peripheral to initiate disconnect, but result is success
            onActionSuccess()
            
            print("****** DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        peripheralProxy.onDisconnected();
    }
    
    
    
    
    
}
