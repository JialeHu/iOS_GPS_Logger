//
//  MainController.swift
//  GPS Logger
//
//  Created by HJL on 10/8/19.
//  Copyright © 2019 HJL. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

// Notification Keys
let startKey = "app.FirstView.Start"
let stopKey = "app.FirstView.Stop"
let didStartKey = "app.MainModel.didStart"
let didStopKey = "app.MainModel.didStop"
let didSaveKey = "app.MainModel.didSave"
let notLocOnKey = "app.MainModel.notLocOn"
let notLocAuthKey = "app.MainModel.notLocAuth"

class MainModel: NSObject {
    // From NSObj for delegate protocol
    
    let locationManager = CLLocationManager()
    var newLocation1: ((_ location: CLLocation) -> ())?
    var newLocation2: ((_ location: CLLocation) -> ())?
    
    var locAuthState:Int8 = -1
    
    var locT: [CLLocation] = []

    // MARK: - Initializer
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didLaunch(notification:)), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate(notification:)), name: UIApplication.willTerminateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didStart(notification:)), name: Notification.Name(rawValue: startKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStop(notification:)), name: Notification.Name(rawValue: stopKey), object: nil)
    }
    
    deinit {
        // Delete Observer
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - App Cycle
    @objc func didLaunch(notification: NSNotification) {
        print("Launch")
        
        checkLocation()
    }
    
    @objc func didBackground(notification: NSNotification) {
        print("did Background")
        
    }
    
    @objc func willForeground(notification: NSNotification) {
        print("will Foreground")
        
    }
    
    @objc func willTerminate(notification: NSNotification) {
        print("will Terminate")
        
        locationManager.stopUpdatingLocation()
        save2Core()
        PersistenceService.saveContext()
    }
    
    
    // MARK: - Start Stop
    @objc func didStart(notification: NSNotification) {
        print("Start")
        
        locationManager.startUpdatingLocation()
        NotificationCenter.default.post(name: Notification.Name(rawValue: didStartKey), object: nil)
    }
    
    @objc func didStop(notification: NSNotification) {
        print("Stop")
        
        locationManager.stopUpdatingLocation()
        save2Core()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: didStopKey), object: nil)
    }
    
    // MARK: - Self Func
    private func checkLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locAuthState = Locations.checkLocationAuthorization()
            if locAuthState == 1 || locAuthState == 2 || locAuthState == 3 {
                Locations.setupLocManager(locDelegate: self, locManager: locationManager)
            } else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: notLocAuthKey), object: nil)
            }
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: notLocOnKey), object: nil)
        }
    }
    
        // MARK: Data Saving
    private func save2Core(){
        // Save Temporary Data to Core
        arrayCheck: if locT.isEmpty {
            print("TempDataArray is empty")
            break arrayCheck
        } else {
            // Save to Core
            let gpsData = GPSData(context: PersistenceService.context)
            
            var altitudeC: [Double] = []
            var courseC: [Double] = []
            var dateC: [Date] = []
            var horAccC: [Double] = []
            var latitudeC: [Double] = []
            var longitudeC: [Double] = []
            var speedC: [Double] = []
            var verAccC: [Double] = []
            for loc in locT {
                altitudeC.append(loc.altitude)
                courseC.append(loc.course)
                dateC.append(loc.timestamp)
                horAccC.append(loc.horizontalAccuracy)
                latitudeC.append(loc.coordinate.latitude)
                longitudeC.append(loc.coordinate.longitude)
                speedC.append(loc.speed)
                verAccC.append(loc.verticalAccuracy)
            }
            locT.removeAll()
            
            gpsData.altitudeD = altitudeC
            gpsData.courseD = courseC
            gpsData.dateD = dateC
            gpsData.horAccD = horAccC
            gpsData.latitudeD = latitudeC
            gpsData.longitudeD = longitudeC
            gpsData.speedD = speedC
            gpsData.verAccD = verAccC
            
            PersistenceService.saveContext()
            print("MainModel Context Saved")
            
            // Update File
            NotificationCenter.default.post(name: Notification.Name(rawValue: didSaveKey), object: nil)
        }

    }
    
}

// MARK: - Get Location Update
extension MainModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // New Location Available
    
        guard let location = locations.last else { return }
    
        // Save Data Temporarily
        locT.append(location)
        
        // Update LOG
        newLocation1?(location)
        
        // Update MAP
        newLocation2?(location)
        
    }
        
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Location Authorization Change
        
        // Show Alert
        checkLocation()
        // Stop Logging
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError: Error) {
        // Error
        print("Location Error")
        
        // Show Alert
        checkLocation()
        // Stop Logging
        
    }
    
}
