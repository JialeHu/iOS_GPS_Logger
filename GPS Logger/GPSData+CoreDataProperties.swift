//
//  GPSData+CoreDataProperties.swift
//  GPS Logger
//
//  Created by HJL on 10/11/19.
//  Copyright © 2019 HJL. All rights reserved.
//
//

import Foundation
import CoreData


extension GPSData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GPSData> {
        return NSFetchRequest<GPSData>(entityName: "GPSData")
    }

    @NSManaged public var altitudeD: [Double]?
    @NSManaged public var courseD: [Double]?
    @NSManaged public var dateD: [Date]?
    @NSManaged public var horAccD: [Double]?
    @NSManaged public var latitudeD: [Double]?
    @NSManaged public var longitudeD: [Double]?
    @NSManaged public var speedD: [Double]?
    @NSManaged public var verAccD: [Double]?

}
