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
            locationNameLabel.text = weatherLocation.name ?? "--"
            speedLabel.text = weatherLocation.windSpeed?.description ?? "--"

            if let degree = weatherLocation.windDegree {
                let rotaionRadians: CGFloat = CGFloat(M_PI * degree) / CGFloat(180)
                degreeArrowLabel.transform = CGAffineTransformMakeRotation(rotaionRadians)
                degreeLabel.text = "\(degree)°"
            }
        }
    }

}
