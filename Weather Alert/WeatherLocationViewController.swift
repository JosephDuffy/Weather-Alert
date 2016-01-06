//
//  WeatherLocationViewController.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 05/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit
import MapKit

class WeatherLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var temperatureWeatherDescriptionLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!

    var weatherLocation: WeatherLocation? {
        didSet {
            if isViewLoaded() {
                setup()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        assert(isViewLoaded(), "setup may only be called after the view is loaded")

        if let weatherLocation = weatherLocation {
            navigationItem.title = weatherLocation.name!

            var temperatureWeatherDescriptionText = ""
            if let temperature = weatherLocation.temperature {
                temperatureWeatherDescriptionText += "\(temperature)°C"
            }

            if let weather = weatherLocation.weathers?.first {
                if temperatureWeatherDescriptionText.characters.count > 0 {
                    temperatureWeatherDescriptionText += " - "
                }

                temperatureWeatherDescriptionText += weather.descriptionText
            }

            temperatureWeatherDescriptionLabel.text = temperatureWeatherDescriptionText
            
            if let windSpeed = weatherLocation.windSpeed {
                if let compassDesignation = weatherLocation.compassDesignation {
                    windLabel.text = "\(compassDesignation) - \(windSpeed) m/s"
                } else {
                    windLabel.text = "\(windSpeed) m/s"
                }
            } else {
                windLabel.text = "--"
            }

            // Remove all annotations
            mapView.removeAnnotations(mapView.annotations)

            if let location = weatherLocation.location {
                let region = MKCoordinateRegionMakeWithDistance(location, 50000, 50000)
                mapView.setRegion(region, animated: true)

                let pin = MKPointAnnotation()
                pin.coordinate = location
                mapView.addAnnotation(pin)
            }
        } else {
            mapView.hidden = true
            temperatureWeatherDescriptionLabel.text = nil
            windLabel.text = nil
            navigationItem.title = nil
        }
    }

}
