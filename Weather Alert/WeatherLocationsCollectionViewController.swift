//
//  WeatherLocationsCollectionViewController.swift
//  Weather Alert
//
//  Created by Joseph Duffy on 05/01/2016.
//  Copyright © 2016 Yetii Ltd. All rights reserved.
//

import UIKit
import CoreData

private let WeatherLocationReuseIdentifier = "WeatherLocationCell"
private let AddNewWeatherLocationReuseIdentifier = "AddNewWeatherLocationCell"

class WeatherLocationsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private var fetchedResultsController: NSFetchedResultsController!
    private var selectedWeatherLocations = Set<WeatherLocation>()
    private var pendingChangesBlockOperations: [NSBlockOperation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.splitViewController?.delegate = self

        self.collectionView?.registerNib(UINib(nibName: "WeatherLocationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: WeatherLocationReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: "AddNewWeatherLocationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: AddNewWeatherLocationReuseIdentifier)

        navigationItem.rightBarButtonItem = editButtonItem()

        let fetchRequest = NSFetchRequest(entityName: "WeatherLocation")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "cityId", ascending: true)
        ]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        self.fetchedResultsController = fetchedResultsController

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }

        updateBarButton()
        reloadWeatherData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "weatherLocationDidReloadData:", name: WeatherLocationDidReloadDataNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: WeatherLocationDidReloadDataNotification, object: nil)
    }

    func weatherLocationDidReloadData(notification: NSNotification) {
        guard let weatherLocation = notification.object as? WeatherLocation else { return }
        reloadCellForWeatherLocation(weatherLocation)
    }

    private func reloadCellForWeatherLocation(weatherLocation: WeatherLocation) {
        guard let indexPath = fetchedResultsController.indexPathForObject(weatherLocation) else { return }

        collectionView?.reloadItemsAtIndexPaths([indexPath])
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let weatherLocation = sender as? WeatherLocation where segue.identifier == "ShowWeatherLocation" {
            guard let secondaryAsNavController = segue.destinationViewController as? UINavigationController else { return }
            guard let weatherLocationViewController = secondaryAsNavController.topViewController as? WeatherLocationViewController else { return }

            return weatherLocationViewController.weatherLocation = weatherLocation
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return  1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // +1 for Add New cell
        return (self.fetchedResultsController.sections?[section].numberOfObjects ?? 0) + 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell

        if indexPathIsForAddNewCell(indexPath) {
            // Add new location cell
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(AddNewWeatherLocationReuseIdentifier, forIndexPath: indexPath)
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(WeatherLocationReuseIdentifier, forIndexPath: indexPath) as! WeatherLocationCollectionViewCell
        
            (cell as! WeatherLocationCollectionViewCell).weatherLocation = self.fetchedResultsController.objectAtIndexPath(indexPath) as? WeatherLocation
        }

        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor.blackColor().CGColor

        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if editing {
            if indexPathIsForAddNewCell(indexPath) {
                // Don't allow selection of add new cell
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            } else if let weatherLocation = self.fetchedResultsController.objectAtIndexPath(indexPath) as? WeatherLocation {
                selectedWeatherLocations.insert(weatherLocation)
                updateBarButton()
            }
        } else {
            if indexPathIsForAddNewCell(indexPath) {
                // Show the add new location interface
                performSegueWithIdentifier("ShowAddNewWeatherLocation", sender: nil)
                collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            } else if let weatherLocation = self.fetchedResultsController.objectAtIndexPath(indexPath) as? WeatherLocation {
                setDisplayedWeatherLocation(weatherLocation)
            }
        }
    }

    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if editing {
            if !indexPathIsForAddNewCell(indexPath) {
                if let weatherLocation = self.fetchedResultsController.objectAtIndexPath(indexPath) as? WeatherLocation {
                    selectedWeatherLocations.remove(weatherLocation)
                    updateBarButton()
                }
            }
        }
    }

    // MARK:- Management

    private func indexPathIsForAddNewCell(indexPath: NSIndexPath) -> Bool {
        return indexPath.row == (fetchedResultsController.fetchedObjects?.count ?? 0)
    }

    private func setDisplayedWeatherLocation(weatherLocation: WeatherLocation?) {
        if let navigationController = splitViewController?.viewControllers.last as? UINavigationController where splitViewController?.viewControllers.count == 2 {
            // Set directly
            guard let weatherLocationViewController = navigationController.topViewController as? WeatherLocationViewController else { return }

            return weatherLocationViewController.weatherLocation = weatherLocation
        } else {
            // Set via segue
            performSegueWithIdentifier("ShowWeatherLocation", sender: weatherLocation)
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if let selectedIndexPaths = collectionView?.indexPathsForSelectedItems() {
            // This removed the highlighted colour when setting editing and
            // does not restore it. This could be improved by restoring, but
            // the index paths may change so this will be left for the future
            for selectedIndexPath in selectedIndexPaths {
                collectionView?.deselectItemAtIndexPath(selectedIndexPath, animated: false)
            }
        }

        if !editing {
            selectedWeatherLocations = []
        }

        collectionView?.allowsMultipleSelection = editing

        updateBarButton()
    }

    private func updateBarButton() {
        if editing {
            let title = selectedWeatherLocations.count < 2 ? "Delete" : "Delete \(selectedWeatherLocations.count)"
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: "deleteSelectedItems")
            navigationItem.leftBarButtonItem?.enabled = selectedWeatherLocations.count > 0
            navigationItem.leftBarButtonItem?.tintColor = .redColor()
        } else {
            // TODO: Change this for an activity indicator when reloading data
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadWeatherData")
            // Only enable reload button when there are added weather locations
            navigationItem.leftBarButtonItem?.enabled = collectionView?.numberOfSections() > 1

            let itemCount = fetchedResultsController.fetchedObjects?.count ?? 0
            navigationItem.leftBarButtonItem?.enabled = itemCount > 0
            navigationItem.rightBarButtonItem?.enabled = itemCount > 0
        }
    }

    func reloadWeatherData() {
        if let weatherLocations = fetchedResultsController.fetchedObjects as? [WeatherLocation] {
            for weatherLocation in weatherLocations {
                guard weatherLocation.isLoadingData == false else { return }

                // TOOD: Check for stale data (e.g., > 10 minutes old)
                if weatherLocation.lastUpdated == nil {
                    weatherLocation.reloadData()
                    reloadCellForWeatherLocation(weatherLocation)
                }
            }
        }
    }

    func deleteSelectedItems() {
        for selectedWeatherLocation in selectedWeatherLocations {
            CoreDataManager.sharedInstance.managedObjectContext.deleteObject(selectedWeatherLocation)
        }
        CoreDataManager.sharedInstance.saveContext()

        setEditing(false, animated: true)
    }

}

extension WeatherLocationsCollectionViewController: NSFetchedResultsControllerDelegate {

    /**
     This block operation code is used to fix a crash when multiple changes are
     performed in one action, such as deleting 2 items. This pattern is found
     is multiple places, but the first time this was shown appears to be from
     https://gist.github.com/iwasrobbed/5528897. This is a modified (and converted
     to swift) version of that code
    */

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        pendingChangesBlockOperations = []
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView?.performBatchUpdates({ () -> Void in
            for operation in self.pendingChangesBlockOperations {
                operation.start()
            }
            }, completion: { _ in
                self.pendingChangesBlockOperations = []
                self.updateBarButton()
        })
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            pendingChangesBlockOperations.append(NSBlockOperation(block: {
                self.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
            }))
        case .Delete:
            pendingChangesBlockOperations.append(NSBlockOperation(block: {
                self.collectionView?.deleteItemsAtIndexPaths([indexPath!])
            }))

            if let navigationController = splitViewController?.viewControllers.last as? UINavigationController where splitViewController?.viewControllers.count == 2 {
                // Set directly
                guard let weatherLocationViewController = navigationController.topViewController as? WeatherLocationViewController else { return }

                if let weatherLocation = anObject as? WeatherLocation {
                    if weatherLocationViewController.weatherLocation == weatherLocation {
                        weatherLocationViewController.weatherLocation = nil
                    }
                }
            }
        case .Move:
            pendingChangesBlockOperations.append(NSBlockOperation(block: {
                self.collectionView?.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
            }))
        case .Update:
            pendingChangesBlockOperations.append(NSBlockOperation(block: {
                self.collectionView?.reloadItemsAtIndexPaths([indexPath!])
            }))
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            pendingChangesBlockOperations.append(NSBlockOperation(block: {
                self.collectionView?.insertSections(NSIndexSet(index: sectionIndex))
            }))
        case .Delete:
            pendingChangesBlockOperations.append(NSBlockOperation(block: {
                self.collectionView?.deleteSections(NSIndexSet(index: sectionIndex))
            }))
        case .Move, .Update:
            break
        }
    }
}

extension WeatherLocationsCollectionViewController: UISplitViewControllerDelegate {
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return true }
        guard let scanViewController = secondaryAsNavController.topViewController as? WeatherLocationViewController else { return true }

        return scanViewController.weatherLocation == nil
    }
}