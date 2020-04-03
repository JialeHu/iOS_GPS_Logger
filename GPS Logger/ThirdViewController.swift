//
//  ThirdViewController.swift
//  GPS Logger
//
//  Created by HJL on 10/8/19.
//  Copyright © 2019 HJL. All rights reserved.
//

import UIKit
import CoreData

class ThirdViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var gpsDataAll = [GPSData]()
    var selectIndex = Int()
    
// MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("V3 Loaded")
        
        // Add Oberver for MainModel
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCore(notification:)), name: Notification.Name(rawValue: didSaveKey), object: nil)
        
        fetchData()
        self.tableView.reloadData()
        print("#Data: \(gpsDataAll.count)")
    }
    
// MARK: - Observer Func
    @objc func updateFromCore(notification: NSNotification) {
        print("updateFromCore Called")
        
        fetchData()
        self.tableView.reloadData()
    }
    
// MARK: - Self Func
    func fetchData() {
        let fetchRequest: NSFetchRequest<GPSData> = GPSData.fetchRequest()
        
        do {
            let dataArray = try PersistenceService.context.fetch(fetchRequest)
            self.gpsDataAll = dataArray
            self.tableView.reloadData()
            print("Fetch Succeed")
        } catch {
            print("Fetch Failed")
        }
    }
    
    // MARK: Cell Alert
    func cellAction(dataIndex: Int) {
        let alert = UIAlertController(title: "", message: "Save or Delete Data", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title:"Save",style: .default) { (_) in
            self.saveAlert(dataIndex: dataIndex)
        }
        let deleteAction = UIAlertAction(title:"Delete",style: .destructive) { (_) in
            self.deleteAlert(dataIndex: dataIndex)
        }
        
        alert.addAction(saveAction)
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // For layout bug, see extension
        alert.pruneNegativeWidthConstraints()
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveAlert(dataIndex: Int) {
        let alert = UIAlertController(title: "Save Data to File", message: "File Name:", preferredStyle: .alert)
            alert.addTextField { (textField) in
                if let date = self.gpsDataAll[dataIndex].dateD?.last {
                    let df = DateFormatter()
                    df.dateFormat = "MM_dd_yyyy_HHmmss"
                    textField.text = df.string(from: date)
                    textField.becomeFirstResponder()
                } else {
                    textField.placeholder = "File Name"
                }
                 
            }
        let actionSave = UIAlertAction(title: "Save", style: .default) { (_) in
            if let fileName = alert.textFields?.first?.text {
                if !fileName.isEmpty {
                    print(fileName)
                    // Save csv to File
                    self.saveData2csv(dataIndex: dataIndex, fileName: fileName)
                } else {
                    Alert.showAlert(on: self, with: "Not Saved", message: "Please Enter File Name")
                }
            } else {
                Alert.showAlert(on: self, with: "Not Saved", message: "Please Enter File Name")
            }
            
        }
        alert.addAction(actionSave)
        alert.addAction(UIAlertAction(title:"Cancel",style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteAlert(dataIndex: Int) {
        if let date = self.gpsDataAll[dataIndex].dateD?.last {
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yyyy_HH:mm:ss"
            let alert = UIAlertController(title: "Are you sure you want to delete:", message: df.string(from: date), preferredStyle: .alert)
            
            let trueDeleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                self.deleteCell(dataIndex: dataIndex)
            }
            alert.addAction(trueDeleteAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        } else {
            Alert.showAlert(on: self, with: "Data Not Found", message: "Please Try Again")
        }
        
    }
    
    // MARK: Save Delete Actions
    func saveData2csv(dataIndex: Int, fileName: String){
        let fullFileName = fileName + ".csv"
        //let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fullFileName)
        let path = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fullFileName)
        
        let data = self.gpsDataAll[dataIndex]
        let altitude = data.altitudeD!
        let course = data.courseD!
        let date = data.dateD!
        let horAcc = data.horAccD!
        let latitude = data.latitudeD!
        let longitude = data.longitudeD!
        let speed = data.speedD!
        let verAcc = data.verAccD!
        var dateUnix = [Double]()
        for d in date {
            dateUnix.append(d.timeIntervalSince1970)
        }
        
        var csvText = "Timestamps(Unix time),Latitude(deg),Longitude(deg),Speed(m/s),Course(deg),Altitude(m),Horizontal Accuracy(m),Vertical Accuracy(m)\n"
        for (index, _) in dateUnix.enumerated() {
            let newLine = "\(dateUnix[index]),\(latitude[index]),\(longitude[index]),\(speed[index]),\(course[index]),\(altitude[index]),\(horAcc[index]),\(verAcc[index])\n"
            csvText.append(contentsOf: newLine)
        }
        
        do {
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    
        let ac = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        self.present(ac, animated: true, completion: nil)
    }
    
    func deleteCell(dataIndex: Int) {
        self.fetchData()
        let dataToDelete = gpsDataAll[dataIndex]
        PersistenceService.context.delete(dataToDelete)
        print("Deleted")
        PersistenceService.saveContext()
        self.fetchData()
        self.tableView.reloadData()
        
    }
    
}

// MARK: - Table View
extension ThirdViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gpsDataAll.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellTitle = "DataError"
        var cellSubTitle = ""
        if let date = gpsDataAll[indexPath.row].dateD?.last {
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yyyy_HH:mm:ss"
            cellTitle = df.string(from: date)
            cellSubTitle = String(format: "Number of Data Points: %d", gpsDataAll[indexPath.row].dateD!.count)
        }
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = cellTitle
        cell.detailTextLabel?.text = cellSubTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        print("table index: \(selectIndex)")
        cellAction(dataIndex: selectIndex)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// For layout bug
extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
