//
//  WeatherLocationCollectionViewCell.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 05/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit

class WeatherLocationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    var weatherLocation: WeatherLocation? {
        didSet {
            setup()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func setup() {
        if let weatherLocation = self.weatherLocation {
            weatherLocation.isLoadingData ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()

            // Units are in metric. See: http://openweathermap.org/weather-data

            locationNameLabel.text = weatherLocation.name ?? "--"
            if let windSpeed = weatherLocation.windSpeed {
                speedLabel.text = "\(windSpeed) m/s"
            } else {
                speedLabel.text = "--"
            }
            if let temperature = weatherLocation.temperature {
                temperatureLabel.text = "\(temperature)°C"
            } else {
                temperatureLabel.text = "--"
            }
        }
    }

}
