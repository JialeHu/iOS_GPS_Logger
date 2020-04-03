//
//  SecondViewController.swift
//  GPS Logger
//
//  Created by HJL on 10/7/19.
//  Copyright © 2019 HJL. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// Map Annotation
final class MapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
}

class SecondViewController: UIViewController {
    
    @IBOutlet weak var start2: UIButton!
    @IBOutlet weak var locButton: UIButton!
    @IBOutlet weak var clrButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let locMan = CLLocationManager()
    //var locButtonState = false
    var annotationCount: Int = 1
    
    deinit {
        // Delete Observer
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("V2 Loaded")
    
        start2.layer.cornerRadius = 8
        locButton.layer.cornerRadius = 8
        clrButton.layer.cornerRadius = 8
        
        // Add Oberver for MainModel
        NotificationCenter.default.addObserver(self, selector: #selector(didStart(notification:)), name: Notification.Name(rawValue: didStartKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStop(notification:)), name: Notification.Name(rawValue: didStopKey), object: nil)
        
        // Check Location Service & Set Center on Map
        mapView.showsUserLocation = true
        if Locations.checkLocationServices(vc: self) == 1 || Locations.checkLocationServices(vc: self) == 2 {
            mapView.showsUserLocation = true
            if let coordinate = locMan.location?.coordinate {
                mapView.setCenter(coordinate, animated: true)
            }
        }
        
        // Set Annotation
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        // Update Location from MainModel
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.model.newLocation2 = { (location: CLLocation) -> () in
            self.labelMap(location: location)
        }
                
    }
    
// MARK: - Button Func
    @IBAction func start2Press(_ sender: Any) {
        if start2.title(for: .normal) == "Start" {
        // Start from view 2
            start2.isEnabled = false
            annotationCount = 1
            // Update Main
            NotificationCenter.default.post(name: Notification.Name(rawValue: startKey), object: nil)
            
        } else if start2.title(for: .normal) == "Stop" {
        // Stop from view 2
            start2.isEnabled = false
            // Update Main
            NotificationCenter.default.post(name: Notification.Name(rawValue: stopKey), object: nil)
        } else {
            start2.isEnabled = false
        }
    }
    
    @IBAction func locPress(_ sender: Any) {
        
        // toggle state
//        locButtonState.toggle()
//        print(locButtonState)
//
//        if locButtonState {
//            let image1 = UIImage(systemName: "locaiton.fill")
//            locButton.setImage(image1, for: .normal)
//            locButton.tintColor = UIColor.white
//            centerViewOnMap()
//        } else {
//            let image0 = UIImage(systemName: "locaiton")
//            locButton.setImage(image0, for: .normal)
//            locButton.tintColor = UIColor.white
//        }
        
        centerViewOnMap()
        
    }
    
    @IBAction func clearPress(_ sender: Any) {
           clearLabel()
       }
    
// MARK: - Observer Func
    @objc func didStart(notification: NSNotification) {
        clearLabel()
        centerViewOnMap()
        start2.setTitle("Stop", for: .normal)
        start2.isEnabled = true
    }
    
    @objc func didStop(notification: NSNotification) {
        start2.setTitle("Start", for: .normal)
        start2.isEnabled = true
    }
    
// MARK: - Self Func
    func centerViewOnMap() {
        if let location = locMan.location {
            let range = location.horizontalAccuracy + 250
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: range, longitudinalMeters: range)
            mapView.setRegion(region, animated: true)
           }
        
       }
    
    func labelMap(location: CLLocation) {
        let annotation = MapAnnotation(coordinate: location.coordinate, title: "\(annotationCount)", subtitle: "")
        mapView.addAnnotation(annotation)
        if annotationCount % 5 == 0 {
            mapView.setCenter(location.coordinate, animated: true)
        }
        
        annotationCount += 1
    }
    
    func clearLabel() {
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
    }
    
}

// MARK: - Map View Delegate
extension SecondViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView {
            annotation.animatesWhenAdded = false
            annotation.titleVisibility = .visible
            annotation.subtitleVisibility = .hidden
            annotation.isDraggable = false
            
            if annotationCount == 1 || annotationCount % 10 == 0 {
                annotation.displayPriority = .required
            } else {
                annotation.displayPriority = .defaultLow
            }
            
            return annotation
        }
        return nil
    }
}



