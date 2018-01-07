

import UIKit
import CoreBluetooth



class ProvisionerViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var backgroundImageView1: UIImageView!
    @IBOutlet weak var controlContainerView: UIView!
    // misnamed, not really a disconnect action
    @IBOutlet weak var disconnectButton: UIButton!
    
    // duration of search for provisionable
    let timerInterval:NSTimeInterval = 10.0
  
    var timer = NSTimer()
    
    // UI-related
    let buttonLabelFontName = "HelveticaNeue-Thin"
    let buttonLabelFontSizeMessage:CGFloat = 56.0
    
    var backgroundImageViews: [UIImageView]!
    
    
    // Core Bluetooth properties
    var centralManager:CBCentralManager!
    
    var peripheralProxy: PeripheralProxy!
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
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
        backgroundImageViews = [backgroundImageView1]
        view.bringSubviewToFront(backgroundImageViews[0])
        backgroundImageViews[0].alpha = 1
        view.bringSubviewToFront(controlContainerView)
        
        disconnectButton.enabled = true
        disconnectButton.setTitle( "Provision", forState:UIControlState.Normal)
        disconnectButton.setTitle( "Searching...", forState:UIControlState.Disabled)
        disconnectButton.titleLabel!.font = UIFont(name: buttonLabelFontName, size: buttonLabelFontSizeMessage)!
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

    
    func cancelTimer() {
        timer.invalidate()
    }
    
    
    
    
    // MARK: - Handling User Interaction
    
    @IBAction func handleDisconnectButtonTapped(sender: AnyObject) {
        // peripheralProxy.disconnect()
        onActionStarted()
    }
    
    
    
    
    // MARK: - Bluetooth scanning
    
    
    
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
    
    
    func stopScan() {
        print("stop scan")
        centralManager.stopScan()
    }
    
    
    @objc func timerExpired() {
        print("Timer fired...")
        onActionExpired()
    }

    
    func startTimedProvisioning()  {
        startTimer()    // timeout
        startScan();
    }
    

        
        
    // MARK: - CBCentralManagerDelegate methods
    
    // Invoked when the central manager’s state is updated.
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        /*
        Since most of these states impede app,
        alert user nothing is going to happen.
        */
        
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
