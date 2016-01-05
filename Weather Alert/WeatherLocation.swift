//
//  WeatherLocation.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 05/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import Foundation
import CoreData


class WeatherLocation: NSManagedObject {

    var lastUpdated: NSDate?
    var windSpeed: Double?
    var windDegree: Double?

    var displayName: String {
        return "\(self.name), \(self.country)"
    }
}
