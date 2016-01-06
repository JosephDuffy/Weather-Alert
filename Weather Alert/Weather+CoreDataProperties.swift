//
//  Weather+CoreDataProperties.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 06/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Weather {

    @NSManaged var id: NSNumber?
    @NSManaged var main: String?
    @NSManaged var descriptionText: String?
    @NSManaged var icon: String?
    @NSManaged var weatherLocation: WeatherLocation?

}
