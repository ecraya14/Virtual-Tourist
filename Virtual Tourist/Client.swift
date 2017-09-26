//
//  Client.swift
//  VirtualTourist
//
//  Created by ecraya14 on 01/09/2016.
//  Copyright © 2016 AppFish. All rights reserved.
//

import Foundation

class Client : NSObject {


    var session = NSURLSession.sharedSession()
    
    override init() {
         super.init()
    }
    
    
    func getImagesFromFlickr(pin: Pin, completionHandlerForGetImages: (success: Bool, photosArray: [[String: AnyObject]]?, errorString: String?) -> Void) {
        
        let lat = pin.latitude
        let long = pin.longitude
        
        let methodParameters = [
            Client.FlickrParameterKeys.Method: Client.FlickrParameterValues.SearchMethod,
            Client.FlickrParameterKeys.APIKey: Client.FlickrParameterValues.APIKey,
            Client.FlickrParameterKeys.BoundingBox: bboxString(lat!, long: long!),
            Client.FlickrParameterKeys.SafeSearch: Client.FlickrParameterValues.UseSafeSearch,
            Client.FlickrParameterKeys.Extras: Client.FlickrParameterValues.MediumURL,
            Client.FlickrParameterKeys.Format: Client.FlickrParameterValues.ResponseFormat,
            Client.FlickrParameterKeys.PerPage: Client.FlickrParameterValues.PerPage,
            Client.FlickrParameterKeys.NoJSONCallback: Client.FlickrParameterValues.DisableJSONCallback
        ]
        
        
        // create session and request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // if an error occurs, print it
            func displayError(error: String) {
                print(error)
               completionHandlerForGetImages(success: false, photosArray: nil, errorString: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Client.FlickrResponseKeys.Status] as? String where stat == Client.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Client.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(Client.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Client.FlickrResponseKeys.Pages] as? Int else {
                displayError("Cannot find key '\(Client.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.displayImageFromFlickrBySearch(pin, methodParameters: methodParameters, withPageNumber: randomPage) { (success, photosArray, error) in
                if success {
                    completionHandlerForGetImages(success: true, photosArray: photosArray, errorString: nil)
                } else {
                    completionHandlerForGetImages(success: false, photosArray: nil, errorString: error)
                }
            }
            
        }
        
        // start the task!
        task.resume()
    }

    
    private func bboxString(lat: NSNumber, long: NSNumber) -> String {
        // ensure bbox is bounded by minimum and maximums
        let latitude = Double(lat)
        let longitude = Double(long)
            let minimumLon = max(longitude - Client.Constants.SearchBBoxHalfWidth, Client.Constants.SearchLonRange.0)
            let minimumLat = max(latitude - Client.Constants.SearchBBoxHalfHeight, Client.Constants.SearchLatRange.0)
            let maximumLon = min(longitude + Client.Constants.SearchBBoxHalfWidth, Client.Constants.SearchLonRange.1)
            let maximumLat = min(latitude + Client.Constants.SearchBBoxHalfHeight, Client.Constants.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    private func displayImageFromFlickrBySearch(pin: Pin, methodParameters: [String:AnyObject], withPageNumber: Int, completionHandlerForPhotos: (success: Bool, photosArray: [[String: AnyObject]]?, errorString: String?) -> Void) {
        
        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Client.FlickrParameterKeys.Page] = withPageNumber
        
        // create session and request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParametersWithPageNumber))
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
                completionHandlerForPhotos(success: false, photosArray: nil, errorString: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Client.FlickrResponseKeys.Status] as? String where stat == Client.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Client.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(Client.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Client.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Client.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                displayError("No Photos Found. Try a different location.")
                return
            } else {
                print("num of photos downloaded: \(photosArray.count)")
                completionHandlerForPhotos(success: true, photosArray: photosArray, errorString: nil)
                // if an image exists at the url, set the image and title
                //let imageURL = NSURL(string: imageUrlString)
                //if let imageData = NSData(contentsOfURL: imageURL!) {
            }
        }
        
        // start the task!
        task.resume()
    }
    
    func downloadImage(let imagePath:String, completionHandler: (imageData: NSData?, errorString: String?) -> Void){
        let session = NSURLSession.sharedSession()
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(imageData: nil, errorString: "Could not download image \(imagePath)")
            } else {
                
                completionHandler(imageData: data, errorString: nil)
            }
        }
        
        task.resume()
    }


    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Client.Constants.APIScheme
        components.host = Client.Constants.APIHost
        components.path = Client.Constants.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }


    
    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
    
    
}
