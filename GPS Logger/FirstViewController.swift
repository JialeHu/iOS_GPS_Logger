//
//  FirstViewController.swift
//  GPS Logger
//
//  Created by HJL on 10/7/19.
//  Copyright © 2019 HJL. All rights reserved.
//

import UIKit
import CoreLocation


class FirstViewController: UIViewController {
    
    @IBOutlet weak var start1: UIButton!
    @IBOutlet weak var latVal: UILabel!
    @IBOutlet weak var longVal: UILabel!
    @IBOutlet weak var spdVal: UILabel!
    @IBOutlet weak var crsVal: UILabel!
    @IBOutlet weak var altVal: UILabel!
    @IBOutlet weak var horAcVal: UILabel!
    @IBOutlet weak var verAcVal: UILabel!
    @IBOutlet weak var timerVal: UILabel!
    
    //Setup timer
    let stopWatch = StopWatch()
    //var timerDuration = 0
    
    deinit {
        // Delete Observer
        NotificationCenter.default.removeObserver(self)
    }
        
// MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("V1 Loaded")
        
        start1.layer.cornerRadius = 8
        
        // Add Oberver for MainModel
        NotificationCenter.default.addObserver(self, selector: #selector(didStart(notification:)), name: Notification.Name(rawValue: didStartKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStop(notification:)), name: Notification.Name(rawValue: didStopKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notLocOn(notificaiton:)), name: Notification.Name(rawValue: notLocOnKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notLocAuth(notificaiton:)), name: Notification.Name(rawValue: notLocAuthKey), object: nil)
        
        // Update Location from MainModel
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.model.newLocation1 = { (location: CLLocation) -> () in
            self.Location2Label(location: location)
        }
        
    }

// MARK: - Button Func
    @IBAction func start1Press(_ sender: Any) {
        if start1.title(for: .normal) == "Start" {
        // Start from view 1
            // Update Main
            start1.isEnabled = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: startKey), object: nil)
            
        } else if start1.title(for: .normal) == "Stop" {
        // Stop from view 1
            // Update Main
            start1.isEnabled = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: stopKey), object: nil)
        } else {
            start1.isEnabled = false
        }
    }
    
// MARK: - Observer Func
    @objc func didStart(notification: NSNotification) {
        timerVal.text = "00:00"
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLabel(timer:)), userInfo: nil, repeats: true)
        stopWatch.start()
        
        start1.setTitle("Stop", for: .normal)
        start1.isEnabled = true
    }
    
    @objc func didStop(notification: NSNotification) {
        stopWatch.stop()
        ResetLabel()

        start1.setTitle("Start", for: .normal)
        start1.isEnabled = true
    }
    
    @objc func notLocOn(notificaiton: NSNotification) {
        Alert.showAlert(on: self, with: "Location Service", message: "Go to Settings > Privacy > Turn On Location Services")
    }
    
    @objc func notLocAuth(notificaiton: NSNotification) {
        Alert.showAlert(on: self, with: "Location Authorization", message: "Go to Settings > Privacy > GPS Logger > Always Allow")
    }
    
    // MARK: Timer Func
    @objc func updateTimerLabel(timer: Timer) {
        if self.stopWatch.isRunning {
            let minutes = Int(self.stopWatch.elapsedTime/60)
            let seconds = Int(self.stopWatch.elapsedTime) % 60
            self.timerVal.text = String(format: "%02d:%02d", minutes, seconds)
        
        } else {
            timer.invalidate()
        }
    }
    
// MARK: - Self Func
    func Location2Label(location: CLLocation) {
        latVal.text = String(format:"%.6f", location.coordinate.latitude)
        longVal.text = String(format:"%.6f", location.coordinate.longitude)
        spdVal.text = String(format:"%.6f", location.speed)
        crsVal.text = String(format:"%.6f", location.course)
        altVal.text = String(format:"%.6f", location.altitude)
        horAcVal.text = String(format:"%.6f", location.horizontalAccuracy)
        verAcVal.text = String(format:"%.6f", location.verticalAccuracy)
    }
    
    func ResetLabel() {
        latVal.text = "---"
        longVal.text = "---"
        spdVal.text = "---"
        crsVal.text = "---"
        altVal.text = "---"
        horAcVal.text = "---"
        verAcVal.text = "---"
        timerVal.text = "--:--"
    }
    
    
}


