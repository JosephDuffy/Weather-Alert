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

            if let weatherLocations = fetchedResultsController.fetchedObjects as? [WeatherLocation] {
                for weatherLocation in weatherLocations {
                    guard weatherLocation.isLoadingData == false else { return }

                    if weatherLocation.lastUpdated == nil {
                        weatherLocation.reloadData {[weak self] error in
                            if let indexPath = fetchedResultsController.indexPathForObject(weatherLocation) {
                                self?.collectionView?.reloadItemsAtIndexPaths([indexPath])
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error performing fetch: \(error)")
        }

        updateBarButton()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let weatherLocation = sender as? WeatherLocation where segue.identifier == "ShowWeatherLocation" {
            guard let secondaryAsNavController = segue.destinationViewController as? UINavigationController else { return }
            guard let scanViewController = secondaryAsNavController.topViewController as? WeatherLocationViewController else { return }

            return scanViewController.weatherLocation = weatherLocation
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (self.fetchedResultsController.sections?.count ?? 0) + 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == (self.fetchedResultsController.sections?.count ?? 0) {
            // Add new location section
            return 1
        } else {
            return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell

        if indexPath.section == collectionView.numberOfSections() - 1 {
            // Add new location section
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

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if editing {
            if indexPath.section == collectionView.numberOfSections() - 1 {
                // Don't allow selection of add new cell
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            } else if let weatherLocation = self.fetchedResultsController.objectAtIndexPath(indexPath) as? WeatherLocation {
                selectedWeatherLocations.insert(weatherLocation)
                updateBarButton()
            }
        } else {
            if indexPath.section == collectionView.numberOfSections() - 1 {
                // Show the add new location interface
                performSegueWithIdentifier("ShowAddNewWeatherLocation", sender: nil)
            } else if let weatherLocation = self.fetchedResultsController.objectAtIndexPath(indexPath) as? WeatherLocation {
                performSegueWithIdentifier("ShowWeatherLocation", sender: weatherLocation)
            }
        }
    }

    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if editing {
            if indexPath.section != collectionView.numberOfSections() - 1 {
                if let weatherLocation = self.fetchedResultsController.objectAtIndexPath(indexPath) as? WeatherLocation {
                    selectedWeatherLocations.remove(weatherLocation)
                    updateBarButton()
                }
            }
        }
    }

    // MARK:- Management

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

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
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reloadWeatherData")
            // Only enable reload button when there are added weather locations
            navigationItem.leftBarButtonItem?.enabled = collectionView?.numberOfSections() > 1
        }
    }

    func reloadWeatherData() {
        // TODO: Implement
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
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
        case .Delete:
            self.collectionView?.deleteItemsAtIndexPaths([indexPath!])
        case .Move:
            self.collectionView?.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        case .Update:
            self.collectionView?.reloadItemsAtIndexPaths([indexPath!])
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.collectionView?.insertSections(NSIndexSet(index: sectionIndex))
        case .Delete:
            self.collectionView?.deleteSections(NSIndexSet(index: sectionIndex))
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