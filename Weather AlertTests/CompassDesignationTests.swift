//
//  CompassDesignationTests.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 07/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import XCTest
@testable
import Weather_Alert

class CompassDesignationTests: XCTestCase {

    private func testDegrees(degrees: Double..., yieldsDesignation expected: CompassDesignation?) {
        for degree in degrees {
            XCTAssertEqual(CompassDesignation.compassDesignationForDegree(degree), expected, "\(degree) did not yield expected \(expected)")
        }
    }
    
    func testCreatingNorth() {
        testDegrees(0, 10, 22.5, 337.51, 360, yieldsDesignation: .North)
    }

    func testCreatingNorthEast() {
        testDegrees(22.51, 35, 67.5, yieldsDesignation: .NorthEast)
    }

    func testCreatingEast() {
        testDegrees(67.51, 78, 112.5, yieldsDesignation: .East)
    }

    func testCreatingSouthEast() {
        testDegrees(112.51, 126, 157.5, yieldsDesignation: .SouthEast)
    }

    func testCreatingSouth() {
        testDegrees(157.51, 180, 202.5, yieldsDesignation: .South)
    }

    func testCreatingSouthWest() {
        testDegrees(202.51, 214, 247.5, yieldsDesignation: .SouthWest)
    }

    func testCreatingWest() {
        testDegrees(247.51, 261, 292.5, yieldsDesignation: .West)
    }

    func testCreatingNorthWest() {
        testDegrees(292.51, 310, 337.5, yieldsDesignation: .NorthWest)
    }
}
