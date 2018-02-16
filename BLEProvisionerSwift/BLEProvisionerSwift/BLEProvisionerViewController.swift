

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
    
    // Should belong to separate View class
    @IBOutlet weak var backgroundImageView1: UIImageView!
    @IBOutlet weak var controlContainerView: UIView!
    
    // Widgets for ProvisionableControls
    // misnamed, not really a disconnect action
    @IBOutlet weak var disconnectButton: UIButton!
    
    // Widget for RangeControl
    @IBOutlet weak var pickerView: UIPickerView!
    
    // Miscellaneous Widgets
    @IBOutlet weak var progressView: UIProgressView!
    
    let buttonLabelFontName = "HelveticaNeue-Thin"
    let buttonLabelFontSizeMessage:CGFloat = 56.0
    
    var backgroundImageViews: [UIImageView]!
    
    let timerWithProgress: TimerWithProgress = TimerWithProgress()
    
    @IBOutlet weak var pickerTextField : UITextField!
    
    let salutations = ["", "Mr.", "Ms.", "Mrs."]
    
        
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleDelegate = BLEDelegate(delegate: self)
        
        configureInitialUI();
        
        pickerTextField.loadDropdownData(salutations)
        //pickerView.dataSource = pickerDelegate
        //pickerView.delegate = pickerDelegate
    }
    
    
    override func viewWillAppear(animated: Bool) {
        // If app has displayed sensor values, tell view to update them here
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
