//
//  gui.swift
//  BLETemperatureReaderSwift
//
//  Created by lloyd konneker on 12/29/17.
//  Copyright © 2017 lloyd konneker
//

import Foundation
import UIKit


extension TemperatureViewController {
  
  // MARK: - Updating UI
  
  func feedbackScanning(isScanning: Bool) {
    if (isScanning) {
      temperatureLabel.font = UIFont(name: temperatureLabelFontName, size: temperatureLabelFontSizeMessage)
      temperatureLabel.text = "Scanning"
    }
    else {
      temperatureLabel.text = "Paused"
    }
  }
  
  
  func feedbackConnected(isConnected: Bool) {
    if (isConnected) {
      temperatureLabel.font = UIFont(name: temperatureLabelFontName, size: temperatureLabelFontSizeMessage)
      temperatureLabel.text = "Connected"
    }
    else {
      temperatureLabel.text = "Disconnected"
    }
  }

  
  /*
 func updateTemperatureDisplay() {
    if !circleDrawn {
      drawCircle()
    } else {
      circleView.hidden = false
    }
    
    updateBackgroundImageForTemperature(lastTemperature)
    temperatureLabel.font = UIFont(name: temperatureLabelFontName, size: temperatureLabelFontSizeTemp)
    temperatureLabel.text = " \(lastTemperature)°"
  }
 */
  
  /*
 func drawCircle() {
    circleView.hidden = false
    let circleLayer = CAShapeLayer()
    circleLayer.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, circleView.frame.width, circleView.frame.height)).CGPath
    circleView.layer.addSublayer(circleLayer)
    circleLayer.lineWidth = 2
    circleLayer.strokeColor = UIColor.whiteColor().CGColor
    circleLayer.fillColor = UIColor.clearColor().CGColor
    circleDrawn = true
  }
 */
  
  func tensValue(temperature:Int) -> Int {
    var temperatureTens = 10;
    if (temperature > 19) {
      if (temperature > 99) {
        temperatureTens = 100;
      } else {
        temperatureTens = 10 * Int(floor( Double(temperature / 10) + 0.5 ))
      }
    }
    return temperatureTens
  }
  
  
  
  /*
 func updateBackgroundImageForTemperature(temperature:Int) {
    let temperatureTens = tensValue(temperature)
    if temperatureTens != lastTemperatureTens {
      // generate file name of new background to show
      let temperatureFilename = "temp-\(temperatureTens)"
      print("*** BACKGROUND FILENAME: \(temperatureFilename)")
      
      // fade out old background, fade in new.
      let visibleBackground = backgroundImageViews[visibleBackgroundIndex]
      let invisibleBackground = backgroundImageViews[invisibleBackgroundIndex]
      invisibleBackground.image = UIImage(named: temperatureFilename)
      invisibleBackground.alpha = 0
      view.bringSubviewToFront(invisibleBackground)
      view.bringSubviewToFront(controlContainerView)
      UIView.animateWithDuration(0.5, animations: {
        invisibleBackground.alpha = 1;
        }, completion: { (finished) in
          visibleBackground.alpha = 0
          let indexTemp = self.visibleBackgroundIndex
          self.visibleBackgroundIndex = self.invisibleBackgroundIndex
          self.invisibleBackgroundIndex = indexTemp
          print("**** NEW INDICES - visible: \(self.visibleBackgroundIndex) - invisible: \(self.invisibleBackgroundIndex)")
      })
    }
  }
 */
  
  func displayTemperature(data:NSData) {
    // We'll get four bytes of data back, so we divide the byte count by two
    // because we're creating an array that holds two 16-bit (two-byte) values
    let dataLength = data.length / sizeof(UInt16)
    var dataArray = [UInt16](count:dataLength, repeatedValue: 0)
    data.getBytes(&dataArray, length: dataLength * sizeof(Int16))
    
    //        // output values for debugging/diagnostic purposes
    //        for i in 0 ..< dataLength {
    //            let nextInt:UInt16 = dataArray[i]
    //            print("next int: \(nextInt)")
    //        }
    
    let rawAmbientTemp:UInt16 = dataArray[Device.SensorDataIndexTempAmbient]
    print("*** AMBIENT TEMPERATURE SENSOR (C/F): \(rawAmbientTemp)");
    
    // Device also retrieves an infrared temperature sensor value, which we don't use in this demo.
    // However, for instructional purposes, here's how to get at it to compare to the ambient temperature:
    let rawInfraredTemp:UInt16 = dataArray[Device.SensorDataIndexTempInfrared]
    
    print("*** INFRARED TEMPERATURE SENSOR (C/F): \(rawInfraredTemp)");
    
    let temp = Int(rawAmbientTemp)
    lastTemperature = temp
    print("*** LAST TEMPERATURE CAPTURED: \(lastTemperature)° F")
    
    if UIApplication.sharedApplication().applicationState == .Active {
      //updateTemperatureDisplay()
    }
  }

  /*
  func displayHumidity(data:NSData) {
    let dataLength = data.length / sizeof(UInt16)
    var dataArray = [UInt16](count:dataLength, repeatedValue: 0)
    data.getBytes(&dataArray, length: dataLength * sizeof(Int16))
    
    for i in 0 ..< dataLength {
      let nextInt:UInt16 = dataArray[i]
      print("next int: \(nextInt)")
    }
    
    let rawHumidity:UInt16 = dataArray[Device.SensorDataIndexHumidity]
    print("*** HUMIDITY: \(rawHumidity)");
    humidityLabel.text = String(format: "Humidity: %.01f%%", rawHumidity)
    humidityLabel.hidden = false
    
  }
  */
}
