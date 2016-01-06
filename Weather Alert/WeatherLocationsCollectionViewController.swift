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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.splitViewController?.delegate = self

        self.collectionView?.registerNib(UINib(nibName: "WeatherLocationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: WeatherLocationReuseIdentifier)
        self.collectionView?.registerNib(UINib(nibName: "AddNewWeatherLocationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: AddNewWeatherLocationReuseIdentifier)

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
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Always return 1 more than the actual number of fetched items to ensure the "add new location"
        // cell will always be displayed
        return (self.fetchedResultsController.sections?[section].numberOfObjects ?? 0) + 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell

        let itemsInSection = self.collectionView?.numberOfItemsInSection(indexPath.section) ?? 0
        if indexPath.row == itemsInSection - 1 {
            // Last item in section
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
        let itemsInSection = self.collectionView?.numberOfItemsInSection(indexPath.section) ?? 0

        if indexPath.row == itemsInSection - 1 {
            // Show the add new location interface
            self.performSegueWithIdentifier("ShowAddNewWeatherLocation", sender: nil)
        }
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

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