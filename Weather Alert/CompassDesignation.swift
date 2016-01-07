//
//  CompassDesignation.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 07/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import Foundation
import MapKit

enum CompassDesignation {
    case North
    case NorthEast
    case East
    case SouthEast
    case South
    case SouthWest
    case West
    case NorthWest

    static func compassDesignationForDegree(degree: Double) -> CompassDesignation? {
        // These calculation assume that the point where the compass
        // designation changes is every 45 degrees. This is taken on the
        // assumption that 0-22.5° is N, 22.5-67.5° is NE, 67.5-112.5° is E, etc.
        let degreeIncrement: Double = 45
        var degreeToCheckAgainst: Double = 22.5
        var totalIterations = 0

        while degree > degreeToCheckAgainst {
            totalIterations += 1
            degreeToCheckAgainst += degreeIncrement
        }

        switch totalIterations {
        case 0:
            return .North
        case 1:
            return .NorthEast
        case 2:
            return .East
        case 3:
            return .SouthEast
        case 4:
            return .South
        case 5:
            return .SouthWest
        case 6:
            return .West
        case 7:
            return .NorthWest
        case 8:
            return .North
        default:
            return nil
        }
    }

    var name: String {
        switch self {
        case .North:
            return "North"
        case .NorthEast:
            return "North East"
        case .East:
            return "East"
        case .SouthEast:
            return "South East"
        case .South:
            return "South"
        case .SouthWest:
            return "South West"
        case .West:
            return "West"
        case .NorthWest:
            return "North West"
        }
    }

    var shortName: String {
        switch self {
        case .North:
            return "N"
        case .NorthEast:
            return "NE"
        case .East:
            return "E"
        case .SouthEast:
            return "SE"
        case .South:
            return "S"
        case .SouthWest:
            return "SW"
        case .West:
            return "W"
        case .NorthWest:
            return "NW"
        }
    }
}