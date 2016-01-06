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
    @IBOutlet weak var degreeArrowLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var degreeLabel: UILabel!
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
            
            locationNameLabel.text = weatherLocation.name ?? "--"
            if let windSpeed = weatherLocation.windSpeed {
                // Units are in metric. See: http://openweathermap.org/weather-data
                speedLabel.text = "\(windSpeed) m/s"
            } else {
                speedLabel.text = "--"
            }
            degreeLabel.text = weatherLocation.compassDesignation ?? "--"

            if let degree = weatherLocation.windDegree {
                let rotaionRadians: CGFloat = CGFloat(Float(M_PI) * degree) / CGFloat(180)
                degreeArrowLabel.transform = CGAffineTransformMakeRotation(rotaionRadians)

            }
        }
    }

}
