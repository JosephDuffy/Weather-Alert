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
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
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

            if let weather = weatherLocation.weathers?.first {
                weatherLabel.text = weather.descriptionText

                if let image = weather.image {
                    imageView.image = image
                } else {
                    weather.loadImage {[weak self] image, error in
                        if let image = image {
                            self?.imageView.image = image
                        }
                    }
                }
            } else {
                weatherLabel.text = "--"
            }

            // Units are in metric. See: http://openweathermap.org/weather-data

            locationNameLabel.text = weatherLocation.name ?? "--"
            if let windSpeed = weatherLocation.windSpeed {
                if let compassDesignation = weatherLocation.compassDesignation {
                    speedLabel.text = "\(compassDesignation) - \(windSpeed) m/s"
                } else {
                    speedLabel.text = "\(windSpeed) m/s"
                }
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
