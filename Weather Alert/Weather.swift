//
//  Weather.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 06/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit

final class Weather {
    let id: Int!
    let main: String!
    let descriptionText: String!
    let icon: String!
    private(set) var image: UIImage?

    init?(data: [String : AnyObject]) {
        guard let id = data["id"] as? Int else {
            self.id = nil
            self.main = nil
            self.descriptionText = nil
            self.icon = nil
            return nil
        }
        guard let main = data["main"] as? String else {
            self.id = nil
            self.main = nil
            self.descriptionText = nil
            self.icon = nil
            return nil
        }
        guard let description = data["description"] as? String else {
            self.id = nil
            self.main = nil
            self.descriptionText = nil
            self.icon = nil
            return nil
        }
        guard let icon = data["icon"] as? String else {
            self.id = nil
            self.main = nil
            self.descriptionText = nil
            self.icon = nil
            return nil
        }

        self.id = id
        self.main = main
        self.descriptionText = description
        self.icon = icon
    }

    /**
     Load the image for the weather icon. Image is loaded from OpenWeatherMap.
     Image data requiest is performed on a background thread, but the callback will
     always be performed on the main thread
     
     - Paramater: callback An optional callback to be called when the image load request
                           has finished
    */
    func loadImage(callback: ((UIImage?, NSError?) -> Void)?) {
        func performCallback(image image: UIImage?, error: NSError?) {
            dispatch_async(dispatch_get_main_queue()) {
                callback?(image, error)
            }
        }

        if let url = NSURL(string: "http://openweathermap.org/img/w/\(self.icon).png") {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if let imageData = NSData(contentsOfURL: url) {
                    if let image = UIImage(data: imageData) {
                        performCallback(image: image, error: nil)
                    } else {
                        performCallback(image: nil, error: NSError(domain: "net.yetii.Weather-Alert", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "Failed to decode data as an image"
                            ]))
                    }
                } else {
                    performCallback(image: nil, error: NSError(domain: "net.yetii.Weather-Alert", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to load image data from URL"
                        ]))
                }
            }
        }
    }
}
