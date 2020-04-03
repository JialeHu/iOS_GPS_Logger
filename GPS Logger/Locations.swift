//
//  Location.swift
//  GPS Logger
//
//  Created by HJL on 10/7/19.
//  Copyright © 2019 HJL. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct Locations {
    
    @discardableResult
    static func checkLocationServices(vc: UIViewController) -> Int8 {
        
        var state: Int8 = 0
        
        if CLLocationManager.locationServicesEnabled() {
            
            state = checkLocationAuthorization()
            if state != 1 && state != 2 {
                Alert.showAlert(on: vc, with: "Location Authorization", message: "Go to Settings > Privacy > GPS Logger > Always Allow")
            }
            
        } else {
            // Show alert
            Alert.showAlert(on: vc, with: "Location Service", message: "Go to Settings > Privacy > Turn On Location Services")

        }
        return state
    }
    
    static func setupLocManager(locDelegate: CLLocationManagerDelegate, locManager: CLLocationManager) {
        
        // Setup location manager
        locManager.delegate = locDelegate
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.allowsBackgroundLocationUpdates = true
        //locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
    }
    
    static func checkLocationAuthorization() -> Int8 {
        
        var state: Int8 = 0
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            state = 1
        case .authorizedWhenInUse:
            state = 2
        case .notDetermined:
            state = 3
        case .denied:
            state = 4
        case .restricted:
            state = 5
        default:
            break
        }
        
        return state
        
    }
    
    
}
