//
//  TravelLocationMapViewController.swift
//  VirtualTourist
//
//  Created by ecraya14 on 30/08/2016.
//  Copyright © 2016 AppFish. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapViewController: CoreDataViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var isDownloading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationMapViewController.longPress(_:)))
        longPressGesture.minimumPressDuration = 0.8
        mapView.addGestureRecognizer(longPressGesture)
        
        //create a fetchRequest and FetchedResultsController
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false)]
        //fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // We will create an MKPointAnnotation for each object in "photoLocations". The
        // point annotations will be stored in an array, and then provided to the map view.
        FillMapFromStorage()
        
        
    }
    
    func longPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(self.mapView)
            let newCoord: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            let pinAnnotation = Pin(latitude: newCoord.latitude, longitude: newCoord.longitude, context: sharedContext)
            mapView.addAnnotation(pinAnnotation)
            isDownloading = true
            dispatch_async(dispatch_get_main_queue(), {
                self.getImagesFromFlickr(pinAnnotation)
            })
            CoreDataStackManager.sharedInstance().save()
            print("got photos")
        }
    }
    
    func getImagesFromFlickr(pin: Pin) {
        Client.sharedInstance().getImagesFromFlickr(pin) { (success, photosArray, errorString) in
            if success {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    for img in photosArray! {
                        let photoID = img["id"] as! String
                        let url = img[Client.FlickrResponseKeys.MediumURL] as? String
                        let photo = Photo(id: photoID, url: url!, image: nil, context: self.sharedContext)
                        photo.pins = pin
                        
                        CoreDataStackManager.sharedInstance().save()
                    }
                })
                self.isDownloading = false
                print("photos created")
                
            } else {
                print("no photos returned")
                //TODO: Alert
            }
            
            
        }
    }    
    // We will create an MKPointAnnotation for each Pin object. The
    // point annotations will be stored, and then provided to the map view
    func FillMapFromStorage() {
        do {
            let storagePins = try sharedContext.executeFetchRequest(NSFetchRequest(entityName: "Pin")) as! [Pin]
            for pin in storagePins {
                mapView.addAnnotation(pin)
            }
        } catch {
            print(error)
            //show alert, could not load existing data
        }
    }
    
    
    // MARK: - MKMapViewDelegate
    
    
    // This delegate method is implemented to respond to taps.
    // When a pin is tapped, the app transitions to the photo album
    // associated with the pin location.
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if !isDownloading {
            let photoAlbumVC = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            let pin = view.annotation as! Pin
            
            
            photoAlbumVC.pin = pin
            mapView.deselectAnnotation(view.annotation, animated: false)
            presentViewController(photoAlbumVC, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Please wait", message: "Photos are downloading", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        switch newState {
        case .Starting:
            view.dragState = .Dragging
        case .Ending, .Canceling:
            view.dragState = .None
        default:
            break
        }
    }
}
