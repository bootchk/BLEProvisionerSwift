//
//  timerWithProgress.swift
//  BLEProvisionerSwift
//
//  Created by lloyd konneker on 2/16/18.
//  Copyright © 2018 Lloyd Konneker. All rights reserved.
//

import Foundation
import UIKit


protocol TimerDelegate: class {
  func onTimerExpired()
}


/*
 Hides legacy NS details.
 Hides side effect progress.
 */
class TimerWithProgress {
  var counter: UInt = 0
  var timer = Timer()
  var delegate: TimerDelegate?
  var sessionDuration: UInt = 0
  var progress: UIProgressView?
  
  func startTick() {
    // Start timer on one second tick
    timer = Timer.scheduledTimer(timeInterval: 1,
                                                   target: self,
                                                   selector: #selector(timerTick),
                                                   userInfo: nil,
                                                   repeats: false)
  }
  
  func start (_ duration: TimeInterval,
              aDelegate: TimerDelegate,
              aProgress: UIProgressView)
  {
    delegate = aDelegate
    counter = 0
    sessionDuration = 10
    progress = aProgress
    
    startTick()
  }
  
  
  @objc func timerTick() {
    counter += 1
    progress?.setProgress(Float(counter)/Float(sessionDuration), animated: false)
    if (counter > sessionDuration) {
      delegate?.onTimerExpired()
    }
    else {
      startTick()
    }
    
  }
  
  func cancel() { timer.invalidate() }
  
  
  
}
