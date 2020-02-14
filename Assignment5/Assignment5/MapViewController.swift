//
//  ViewController.swift
//  Assignment5
//
//  Created by Yi Ding on 2/9/20.
//  Copyright © 2020 Yi Ding. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {mapView.delegate = self}
    }
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var placeDescription: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var selectedPlaceIndex : Int = 0 // index in DataManager.sharedInstance.placeArray
    
    //https://medium.com/hackernoon/mapkit-display-map-and-track-user-location-with-7-lines-of-swift-in-xcode-26bde7a5646d
    fileprivate var locationManager : CLLocationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.sharedInstance.loadAnnotationFromPlist(plistfilename: "Data")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        //https://developer.apple.com/documentation/mapkit/mkcoordinateregion
       let chicago = MKCoordinateRegion.init(
           center: CLLocationCoordinate2DMake(41.948287,-87.655697),
           latitudinalMeters: Double(0.00978871051851371), longitudinalMeters: Double(0.00816739331921212))
       self.mapView.setRegion(chicago, animated: true)
        
        //set triggers
        for place in DataManager.sharedInstance.placeArray {
            let content = UNMutableNotificationContent()
            content.title = "you are near " + place.name!
            content.body = place.longDescription!
            let region = CLCircularRegion(center: place.coordinate, radius: 6000, identifier: place.name!)
            region.notifyOnExit = false
            region.notifyOnEntry = true
            let trigger = UNLocationNotificationTrigger(region : region, repeats: false)
            let request = UNNotificationRequest(identifier: place.name!, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            monitorRegionAtLocation(center: place.coordinate, identifier: place.name!)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //mapviewcontroller initialization
        self.detailView.alpha = 0
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        
        //load data from the provided "Data.plist"
        //print(DataManager.sharedInstance.placeArray.count)
        mapView.addAnnotations(DataManager.sharedInstance.placeArray)
        mapView.showAnnotations(DataManager.sharedInstance.placeArray, animated: true)
        
        //self.mapView.showsUserLocation = true
        //self.mapView.isUserLocationVisible = true
    }
    
    //https://stackoverflow.com/questions/39206418/how-can-i-detect-which-annotation-was-selected-in-mapview
    //show detail info when tapping on annotaion
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedPlace : Place? = view.annotation as? Place
        self.placeTitle.text = selectedPlace?.name
        self.placeDescription.text = selectedPlace?.longDescription
        self.detailView.alpha = 1
        self.selectedPlaceIndex = selectedPlace!.index
        
        //update inFavourite status
        for placeIndex in DataManager.sharedInstance.favourites {
            if selectedPlaceIndex == placeIndex {
                selectedPlace?.inFavourites = true
            }
        }
        if selectedPlace!.inFavourites {
            self.favouriteButton.isSelected = true
        } else {
            self.favouriteButton.isSelected = false
        }
        self.favouriteButton.addTarget(self, action: #selector(changeFavouriteStatus), for: .touchDown)
        
    }
    //favouriteButton Actions
    @IBAction func changeFavouriteStatus(_ button : UIButton) {
        if DataManager.sharedInstance.isInFavourites(index: self.selectedPlaceIndex) {
            DataManager.sharedInstance.deleteFavourites(index : self.selectedPlaceIndex)
            button.isSelected = false
        } else {
            DataManager.sharedInstance.saveFavourites(index : self.selectedPlaceIndex)
            button.isSelected = true
        }
    }
    
    //set FVC's delegate to self
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favourite" {
            let destination = segue.destination as? FavouritesViewController
            destination?.delegate = self
        }
    }
    
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String ) {
        // Make sure the devices supports region monitoring.
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // Register the region.
            let maxDistance = self.locationManager.maximumRegionMonitoringDistance
            let region = CLCircularRegion(center: center,
                 radius: maxDistance, identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate, PlacesFavoritesDelegate {
    //adopt custom AnnotationView
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         if let annotation = annotation as? Place {
             let identifier = "Place"
             
             // Create a new view
             var view: PlaceMarkerView
             
             // Deque an annotation view or create a new one
             if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlaceMarkerView {
                 dequeuedView.annotation = annotation
                 view = dequeuedView
             } else {
                 view = PlaceMarkerView(annotation: annotation, reuseIdentifier: identifier)
                 view.canShowCallout = true
                 view.calloutOffset = CGPoint(x: -5, y: 5)
                 view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                 view.markerTintColor = .blue
                 view.glyphText = "❤︎"
             }
             return view
         }
         return nil
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.detailView.alpha = 0
    }
    
    //implement protocol
    func favouritePlace(placeIndex : Int) {
        print("called")
        let place = DataManager.sharedInstance.placeArray[placeIndex]
        let view = MKAnnotationView(annotation: place, reuseIdentifier: "Place")
        self.mapView.setCenter(place.coordinate, animated: true)
        self.mapView.selectedAnnotations = [place]
        mapView(self.mapView, didSelect: view)
    }
}


