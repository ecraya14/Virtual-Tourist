//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by ecraya14 on 30/08/2016.
//  Copyright © 2016 AppFish. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit

class PhotoAlbumViewController: CoreDataViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    // MARK:  - Properties
    
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var pin: Pin! //pin from TravelLocationViewController
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    var imageCache = NSCache()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let err as NSError {
            error = err
        }
        
        if let error = error {
            print("error with initial fetch: \(error)")
        }
        
        //download new collection of photos if fetchedResultsController has no objects
        //if error != nil || fetchedResultsController.fetchedObjects?.count == 0 {
          //  getNewCollection()
        //}
    }
    
    override func didReceiveMemoryWarning() {
         imageCache.removeAllObjects()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navItem.backBarButtonItem = UIBarButtonItem(title: "OK", style: .Plain, target: self, action: nil)
        newCollectionButton.backgroundColor = UIColor.whiteColor()
        mapView.addAnnotation(pin)
        centerMap()
        
        /*
         if pin.photos?.isEmpty != nil {
         newCollectionButton.enabled = false
         newCollectionButton.setTitle("No images", forState: .Normal)
         }
         */
        
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //mapView.frame.height
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = floor(self.photoCollectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        photoCollectionView.collectionViewLayout = layout
    }

    
    
    @IBAction func newCollection(sender: AnyObject) {
        
        getNewCollection({ (success) in
            if success {
                self.photoCollectionView.reloadData()
                self.newCollectionButton.enabled = true
                self.newCollectionButton.setTitle("New Collection", forState: .Normal)
            } else {
                //no photos, TODO: alert
            }
        })
        

        
    }
    func getNewCollection(completionHandlerNewCollection: (success: Bool) -> Void) {
        newCollectionButton.enabled = false
        dispatch_async(dispatch_get_main_queue(), {
            for img in self.fetchedResultsController.fetchedObjects as! [Photo] {
                self.sharedContext.deleteObject(img)
            }
            
        })
        CoreDataStackManager.sharedInstance().save()
        newCollectionButton.setTitle("Getting new photos", forState: .Normal)
        
        Client.sharedInstance().getImagesFromFlickr(self.pin) { (success, photosArray, errorString) in
            if success {
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.setNewImages(photosArray!) { (success) in
                        print("new collection of photos created")
                        completionHandlerNewCollection(success: true)
                    }
                })
                
            } else {
                print("no photos returned")
                //TODO: Alert
            }
        }
        
    }
    private func setNewImages(photosArray: [[String: AnyObject]], completionHandlerImages: (success: Bool) -> Void) {
        
        for img in photosArray {
            let photoID = img["id"] as! String
            let url = img[Client.FlickrResponseKeys.MediumURL] as? String
            let photo = Photo(id: photoID, url: url!, image: nil, context: self.sharedContext)
            photo.pins = self.pin
            
            CoreDataStackManager.sharedInstance().save()
        }
        completionHandlerImages(success: true)
    }
    
    
    func centerMap() {
        let regionRadius: CLLocationDistance = 10000.0 //meters
        let coordinate = CLLocationCoordinate2D(latitude: Double(pin.latitude!), longitude: Double(pin.longitude!))
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func back() {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fr = NSFetchRequest(entityName: "Photo")
        fr.predicate = NSPredicate(format: "pins == %@", self.pin)
        fr.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
}

// MARK:  - Collection Data Source
extension PhotoAlbumViewController{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let fcSections = fetchedResultsController.sections {
            return (fcSections.count)
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fcSections = fetchedResultsController.sections {
            return fcSections[section].numberOfObjects
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        cell.backgroundColor = UIColor.blueColor()
        self.sharedContext.deleteObject(photo)
        CoreDataStackManager.sharedInstance().save()
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.backgroundColor = UIColor.blueColor()
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        cell.photo.image = nil
        if photo.url != nil {
            if photo.image == nil {
                cell.activityIndicator.startAnimating()
                getImageData(photo, completionHandlerForImageData: { (image) in
                    if let image = image {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.photo.image = image
                            if let data = UIImagePNGRepresentation(image) {
                                
                                photo.image = data
                                photo.pins = self.pin
                                CoreDataStackManager.sharedInstance().save()
                            }
                            cell.activityIndicator.stopAnimating()
                            
                        }
                    }
                })
            } else {
                //have photo already
                cell.photo.image = UIImage(data: photo.image!)
                cell.activityIndicator.stopAnimating()
            }
            
        }
        
        return cell
    }
    
    func getImageData(photo: Photo, completionHandlerForImageData: UIImage? -> Void) {
        Client.sharedInstance().downloadImage(photo.url!) { (data, errorString) in
            if errorString == nil {
                completionHandlerForImageData(UIImage(data: data!))
            } else {
                completionHandlerForImageData(nil)
            }
        }
    }
    
}

// MARK:  - Delegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        
    }
    
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                            newIndexPath: NSIndexPath?) {
 
        switch(type){
            
        case .Insert:
            print("insert an item")
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            print("delete an item")
            deletedIndexPaths.append(indexPath!)
        case .Update:
            print("update an item")
            updatedIndexPaths.append(indexPath!)
        default:
            break
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        for indexPath in self.insertedIndexPaths {
            self.photoCollectionView.insertItemsAtIndexPaths([indexPath])
        }
        
        self.photoCollectionView.deleteItemsAtIndexPaths(deletedIndexPaths)
        
        for indexPath in self.updatedIndexPaths {
            self.photoCollectionView.reloadItemsAtIndexPaths([indexPath])
        }
        
        
        
    }
}
