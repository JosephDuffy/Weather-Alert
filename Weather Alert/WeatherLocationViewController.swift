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
            self.navigationItem.title = weatherLocation.name!
        }
    }

}
