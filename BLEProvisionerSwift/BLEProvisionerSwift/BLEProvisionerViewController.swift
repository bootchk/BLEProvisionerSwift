

import UIKit
import CoreBluetooth



class ProvisionerViewController: UIViewController, ProvisioningDelegate {

    @IBOutlet weak var backgroundImageView1: UIImageView!
    @IBOutlet weak var controlContainerView: UIView!
    // misnamed, not really a disconnect action
    @IBOutlet weak var disconnectButton: UIButton!
  
    var timer = NSTimer()
    
    // UI-related
    let buttonLabelFontName = "HelveticaNeue-Thin"
    let buttonLabelFontSizeMessage:CGFloat = 56.0
    
    var backgroundImageViews: [UIImageView]!
    
    
    var bleDelegate: BLEDelegate!
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleDelegate = BLEDelegate(delegate: self)
      
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
  
    func startSessionTimer() {
        print("start timer")
        // Wait one second less to allow connections to finish
        timer = NSTimer.scheduledTimerWithTimeInterval(AppConstants.sessionDuration - 1,
                                                       target: self,
                                                       selector: #selector(timerExpired),
                                                       userInfo: nil,
                                                       repeats: false)
    }

    
    func cancelSessionTimer() {
        timer.invalidate()
    }
    
    
    
    
    // MARK: - Handling User Interaction
    
    @IBAction func handleDisconnectButtonTapped(sender: AnyObject) {

        onActionStarted()
    }
    
    
    
    
        
    
    @objc func timerExpired() {
        print("Timer fired...")
        
        bleDelegate.stopScan()
        // scanning is stopped but still might be a connection
        
        /*
         Race: timeout in middle of a connection.
         Let connection finish.
         The business logic ensures a finite time to finish.
         i.e. we will write and the peripheral will disconnect itself
         If something else happens and we keep scanning, user can always kill this app.
         */
        if (bleDelegate.isConnected()) {
            print("Connection in progress, waiting...")
            // wait for session to finish, or for connection to die.
        }
        else {
            onActionExpired()
        }
        // assert timer not running
        assert(!bleDelegate.isScanning())
    }

    
    func startTimedProvisioning()  {
        startSessionTimer()    // timeout
        bleDelegate.startScan();
    }

    
}
