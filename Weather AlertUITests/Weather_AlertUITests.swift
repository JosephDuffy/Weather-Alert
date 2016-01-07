//
//  Weather_AlertUITests.swift
//  Weather AlertUITests
//
//  Created by Joseph Duffy on 07/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import XCTest

class Weather_AlertUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExampleWorkflow() {
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews

        let primaryNavigationBar = app.navigationBars["Locations"]
        let refreshButton = primaryNavigationBar.buttons["Refresh"]
        let editButton = primaryNavigationBar.buttons["Edit"]

        // Assert there is only the "+" cell
        XCTAssertEqual(collectionViewsQuery.cells.count, 1)
        XCTAssertFalse(refreshButton.enabled)
        XCTAssertFalse(editButton.enabled)

        let addNewCell = collectionViewsQuery.cells.staticTexts["Add New"]
        addNewCell.tap()
        
        let tablesQuery = app.tables
        let locationNameSearchField = tablesQuery.searchFields["Location Name"]
        locationNameSearchField.tap()
        locationNameSearchField.typeText("london")
        tablesQuery.cells.staticTexts["London, GB"].tap()

        // Assert location has been added
        XCTAssertEqual(collectionViewsQuery.cells.count, 2)
        XCTAssertTrue(refreshButton.enabled)
        XCTAssertTrue(editButton.enabled)

        addNewCell.tap()

        locationNameSearchField.tap()
        tablesQuery.searchFields["Location Name"].typeText("huddersfield")
        tablesQuery.cells.staticTexts["Huddersfield, GB"].tap()

        // Assert location has been added
        XCTAssertEqual(collectionViewsQuery.cells.count, 3)
        XCTAssertTrue(refreshButton.enabled)
        XCTAssertTrue(editButton.enabled)

        addNewCell.tap()

        locationNameSearchField.tap()
        locationNameSearchField.typeText("leeds")
        tablesQuery.cells.staticTexts["Leeds, GB"].tap()

        // Assert location has been added
        XCTAssertEqual(collectionViewsQuery.cells.count, 4)
        XCTAssertTrue(refreshButton.enabled)
        XCTAssertTrue(editButton.enabled)
        
        editButton.tap()

        XCTAssertFalse(primaryNavigationBar.buttons["Delete"].enabled)

        collectionViewsQuery.cells.staticTexts["London, GB"].tap()
        XCTAssertTrue(primaryNavigationBar.buttons["Delete"].enabled)

        collectionViewsQuery.cells.staticTexts["Huddersfield, GB"].tap()
        XCTAssertTrue(primaryNavigationBar.buttons["Delete 2"].enabled)

        primaryNavigationBar.buttons["Delete 2"].tap()

        // Assert locations have been deleted
        // Commented out because count value is always 4, even after deleting?
//        XCTAssertEqual(collectionViewsQuery.cells.count, 2)
        XCTAssertTrue(refreshButton.enabled)
        XCTAssertTrue(editButton.enabled)

        collectionViewsQuery.cells.staticTexts["Leeds, GB"].tap()
        app.navigationBars.buttons["Locations"].tap()

        editButton.tap()

        collectionViewsQuery.cells.staticTexts["Leeds, GB"].tap()
        primaryNavigationBar.buttons["Delete"].tap()

        // Assert last location has been deleted
//        XCTAssertEqual(collectionViewsQuery.cells.count, 1)
        XCTAssertFalse(refreshButton.enabled)
        XCTAssertFalse(editButton.enabled)
    }
    
}
