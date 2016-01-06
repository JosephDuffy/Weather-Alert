//
//  WeatherLocation.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 05/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import MapKit

let WeatherLocationDidReloadDataNotification = "WeatherLocationDidReloadData"

class WeatherLocation: NSManagedObject {

    var lastUpdated: NSDate?
    var windSpeed: Float?
    var windDegree: Float?
    var weathers: [Weather]?
    var location: CLLocationCoordinate2D? {
        if let latitude = self.latitude?.doubleValue, longitude = self.longitude?.doubleValue {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            return nil
        }
    }

    var displayName: String {
        return "\(self.name!), \(self.country!)"
    }
    var compassDesignation: String? {
        if let windDegree = self.windDegree {
            // These calculation assume that the point where the compass
            // designation changes is every 45 degrees. This is taken on the
            // assumption that 0-22.5° is N, 22.5-67.5° is NE, 67.5-112.5° is E, etc.
            let degreeIncrement: Float = 45
            var degreeToCheckAgainst: Float = 22.5
            var totalIterations = 0

            while windDegree > degreeToCheckAgainst {
                totalIterations += 1
                degreeToCheckAgainst += degreeIncrement
            }

            switch totalIterations {
            case 0:
                return "N"
            case 1:
                return "NE"
            case 2:
                return "E"
            case 3:
                return "SE"
            case 4:
                return "S"
            case 5:
                return "SW"
            case 6:
                return "W"
            case 7:
                return "NW"
            case 8:
                return "N"
            default:
                return "??"
            }
        } else {
            return nil
        }
    }
    private(set) var isLoadingData = false
    private weak var activeRequest: Request?

    func reloadData() {
        guard activeRequest == nil else { return }

        let request = Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters: [
            "id": self.cityId!.integerValue,
            "units": "metric",
            "APPID": AppDelegate.instance.openWeatherMapAPIKey
            ])
        self.activeRequest = request
        request.responseJSON { [weak self] response in
            guard self != nil else { return }

            self?.activeRequest = nil

            switch response.result {
            case .Success(let JSON):
                if let data = JSON as? [String: AnyObject] {
                    if let wind = data["wind"] as? [String : Float] {
                        if let windSpeed = wind["speed"] {
                            self?.windSpeed = windSpeed
                        }

                        if let windDegree = wind["deg"] {
                            self?.windDegree = windDegree
                        }
                    }

                    if let temperature = (data["main"] as? [String: AnyObject])?["temp"] as? Float {
                        self?.temperature = NSNumber(float: temperature)
                    }


                    if let weathersData = data["weather"] as? [[String : AnyObject]] {
                        var weathers = [Weather]()
                        for weatherData in weathersData {
                            if let weather = Weather(data: weatherData) {
                                weathers.append(weather)
                            }
                        }
                        
                        self?.weathers = weathers
                    }

                    if let location = data["coord"] as? [String : Double] {
                        if let latitude = location["lat"], longitude = location["lon"] {
                            self?.latitude = latitude
                            self?.longitude = longitude
                        }
                    }

                    self?.lastUpdated = NSDate()
                    self?.isLoadingData = false

                    NSNotificationCenter.defaultCenter().postNotificationName(WeatherLocationDidReloadDataNotification, object: self)
                } else {
                    print("Failed to get JSON data")
                    // TODO: Call callback with error
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
}

extension WeatherLocation {
    static func fromData(data: [String : AnyObject], moc: NSManagedObjectContext? = nil) -> WeatherLocation? {
        guard let id = data["id"] as? Int else { return nil }
        guard let name = data["name"] as? String else { return nil }
        guard let country = (data["sys"] as? [String: String])?["country"] else { return nil }
        guard let temperature = (data["main"] as? [String: AnyObject])?["temp"] as? Float else { return nil }
        guard let windData = data["wind"] as? [String: Float] else { return nil }
        guard let windDegree = windData["deg"] else { return nil }
        guard let windSpeed = windData["speed"] else { return nil }
        guard let weathersData = data["weather"] as? [[String : AnyObject]] else { return nil }

        let entity = NSEntityDescription.entityForName("WeatherLocation", inManagedObjectContext: moc ?? CoreDataManager.sharedInstance.managedObjectContext)!
        let newWeatherLocation = WeatherLocation(entity: entity, insertIntoManagedObjectContext: moc)
        newWeatherLocation.cityId = id
        newWeatherLocation.name = name
        newWeatherLocation.country = country
        newWeatherLocation.temperature = temperature
        newWeatherLocation.lastUpdated = NSDate()
        newWeatherLocation.windSpeed = windSpeed
        newWeatherLocation.windDegree = windDegree

        if let location = data["coord"] as? [String : Double] {
            if let latitude = location["lat"], longitude = location["lon"] {
                newWeatherLocation.latitude = latitude
                newWeatherLocation.longitude = longitude
            }
        }

        var weathers = [Weather]()
        for weatherData in weathersData {
            if let weather = Weather(data: weatherData) {
                weathers.append(weather)
            }
        }

        newWeatherLocation.weathers = weathers

        return newWeatherLocation
    }
}