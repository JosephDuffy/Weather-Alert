//
//  Weather.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 06/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import Foundation
import CoreData


class Weather: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Weather {
    static func fromData(data: [String : AnyObject], moc: NSManagedObjectContext? = nil) -> Weather? {
        guard let id = data["id"] as? Int else { return nil }
        guard let main = data["main"] as? String else { return nil }
        guard let description = data["description"] as? String else { return nil }
        guard let icon = data["icon"] as? String else { return nil }

        let entity = NSEntityDescription.entityForName("Weather", inManagedObjectContext: moc ?? CoreDataManager.sharedInstance.managedObjectContext)!
        let newWeather = Weather(entity: entity, insertIntoManagedObjectContext: moc)
        newWeather.id = id
        newWeather.main = main
        newWeather.descriptionText = description
        newWeather.icon = icon

        return newWeather
    }
}