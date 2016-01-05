//
//  AddNewLocationTableViewController.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 05/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class AddNewLocationTableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!

    private var activeRequest: Request?
    private var resultCities: [OpenWeatherMapCity]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.resultCities != nil ? 1 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultCities?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)

        if let resultCities = self.resultCities {
            if resultCities.count > indexPath.row {
                let city = resultCities[indexPath.row]
                cell.textLabel?.text = city.displayName
            }
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let resultCities = self.resultCities {
            if resultCities.count > indexPath.row {
                let city = resultCities[indexPath.row]

                let moc = CoreDataManager.sharedInstance.managedObjectContext
                let entity = NSEntityDescription.entityForName("WeatherLocation", inManagedObjectContext: moc)!
                let newWeatherLocation = WeatherLocation(entity: entity, insertIntoManagedObjectContext: moc)
                newWeatherLocation.cityId = city.id
                newWeatherLocation.name = city.name
                newWeatherLocation.country = city.country
                newWeatherLocation.lastUpdated = city.dataTimestamp
                newWeatherLocation.windSpeed = city.windSpeed
                newWeatherLocation.windDegree = city.windDegree

                do {
                    try CoreDataManager.sharedInstance.managedObjectContext.save()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } catch {
                    // TODO: Display error to users
                    print(error)
                }
            }
        }
    }

    func searchForText(text: String) {
        if let activeRequest = self.activeRequest {
            activeRequest.cancel()
        }

        // API returns 404 for text < 3 characters
        guard text.characters.count > 2 else {
            resultCities = nil
            tableView.reloadData()

            return
        }

        // See: http://openweathermap.org/current#accuracy
        let request = Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/find", parameters: [
            "q": text,
            "mode": "like",
            "APPID": AppDelegate.instance.openWeatherMapAPIKey
            ])
        self.activeRequest = request
        request.responseJSON { [weak self] response in
            // Use weak self and a guard check here to ensure that
            // the view controller is not kept in memory in the event
            // of the user closing the view controller when a request
            // is still active. Returning at this point also lowers
            // the ammount of processing required, helping improve
            // battery usage and overall performance
            guard self != nil else { return }

            switch response.result {
            case .Success(let JSON):
                if let data = JSON as? [String: AnyObject] {
                    if let citiesData = data["list"] as? [[String: AnyObject]] {
                        var cities = [OpenWeatherMapCity]()

                        for cityData in citiesData {
                            if let city = OpenWeatherMapCity(data: cityData) {
                                cities.append(city)
                            } else {
                                print("Failed to parse city")
                            }
                        }

                        self?.resultCities = cities

                        // Display the data
                        self?.tableView.reloadData()
                    } else {
                        print("Failed to get cities")
                    }
                } else {
                    print("Failed to get JSON data")
                }
            case .Failure(let error):
                // TODO: Display to the user
                print("Request failed with error: \(error)")
            }
        }
    }

    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension AddNewLocationTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchForText(searchText)
    }
}

private struct OpenWeatherMapCity {
    let id: Int
    let name: String
    let country: String
    let windDegree: Double
    let windSpeed: Double
    let dataTimestamp: NSDate
    var displayName: String {
        return "\(name), \(country)"
    }

    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? Int else { return nil }
        guard let name = data["name"] as? String else { return nil }
        guard let country = (data["sys"] as? [String: String])?["country"] else { return nil }
        guard let windData = data["wind"] as? [String: Double] else { return nil }
        guard let windDegree = windData["deg"] else { return nil }
        guard let windSpeed = windData["speed"] else { return nil }

        self.id = id
        self.name = name
        self.country = country
        self.windDegree = windDegree
        self.windSpeed = windSpeed
        self.dataTimestamp = NSDate()
    }
}