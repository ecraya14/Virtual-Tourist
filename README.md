# Virtual-Tourist


The app downloads and stores images from Flickr. The app allows users to drop pins on a map, as if they were stops on a tour.  Users will then be able to download pictures for the location and persist both the actual pictures, and the location of the pictures. Users will also be able to move pins to download new pictures and remove pins if they do not need them anymore.

<h2>Implementation</h2>

The app has two view controller scenes:

TravelLocationMapViewController - shows the map and allows user to drop pins around the world. Users can drag pin to a new location after dropping them. As soon as a pin is dropped, photo data for the pin location is fetched from Flickr. The actual photo download occur in the PhotoAlbumViewController.

PhotoAlbumViewController - allow users to download photos and edit an album for a location. Users can create new collections and delete photos from existing albums.

The app uses CoreData to store Pins (NSManagedObjectContext.executeFetchRequest) and Photos (NSFetchedResultsController) objects. All API calls run in the background (NSURLSession.dataTaskWithRequest). Preloaded files saved in memory cache (NSCache) and file system (NSFileManager) and are removed as soon as a Photo object is removed from CoreData.

<h2>Requirements</h2>

<li>Xcode 7.2</li>
<li> Swift 2.0 </li>
