

import UIKit



/*
 Cruft from attempt to make view is separate class:
 , BLEPViewDelegate
 
 in viewDidLoad
 // Set up the view with the view model and set up view controller as delegate
 self.blepView().viewDelegate = self
 
 // todo property
 // Returns our view of type BLEPView so we can call abstract GUI methods on it
 func blepView()-> BLEPView {
 return self.view as! BLEPView
 }

 */

class ProvisionerViewController: UIViewController, ProvisioningDelegate, TimerDelegate {
  
    

    // Delegate for BLE actions
    var bleDelegate: BLEDelegate!

    // BLEPModel is pure class with static data members
    
    let timerWithProgress: TimerWithProgress = TimerWithProgress()
    
    
    
    
    // IB stuff should belong to separate View class, if Swift allowed extensions to have data members
    
    // control container view seems required for an iOS app
    @IBOutlet weak var controlContainerView: UIStackView!
    
    // Widgets for ProvisionableControls
    
    @IBOutlet weak var blinkNowButton: UIButton!
    @IBOutlet weak var scatterButton: UIButton!
    
    @IBOutlet weak var blinkCycleTextField : UITextField!
    @IBOutlet weak var clusterSizeTextField : UITextField!

    
    // Widget for process control: range of provisioning commands
    @IBOutlet weak var rangeTextField : UITextField!
    
    // Miscellaneous Widgets
    @IBOutlet weak var progressView: UIProgressView!

    
    
    
    
    
        
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleDelegate = BLEDelegate(delegate: self)
        
        configureInitialUI();
        
        // Initial state: no user action in progress
        feedbackScanning(false)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // If there was any communication BACK from the Provisionee, (BLE notifications?) tell view to update them here
    }
  
    
    /*func showViewController(viewController: UIViewController, sender: NSObject) {
        self.show(viewController, sender)
    }
    */
    
  
    // MARK: session timer
  
    func startSessionTimer() {
        print("start timer")
        
         // Wait one second less to allow connections to finish
        timerWithProgress.start(AppConstants.sessionDuration - 1, aDelegate: self, aProgress: progressView)
    }

    
    func cancelSessionTimer() {
        timerWithProgress.cancel()
        resetProgress()
    }
    
    
    func onTimerExpired() {
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
        resetProgress()
        // assert timer not running
        assert(!bleDelegate.isScanning())
    }
    
}
