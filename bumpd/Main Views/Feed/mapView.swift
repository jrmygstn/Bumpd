//
//  mapView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/23/23.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces

class mapView: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15
    
    var bump = GMSMarker()
    var feed: Feed!
    
    let hq = CLLocation(latitude: 33.087561, longitude: -96.818984)
    
    // Outlets
    
    @IBOutlet weak var longField: UILabel!
    @IBOutlet weak var latField: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        //Create a map.
        
        let camera = GMSCameraPosition.camera(withLatitude: hq.coordinate.latitude,
                                              longitude: hq.coordinate.longitude,
                                              zoom: zoomLevel)
        
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        
        mapView.settings.compassButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setMinZoom(4, maxZoom: mapView.maxZoom)
        
        // Add the map to the view, hide it until we've got a location update.
        
        self.view.addSubview(mapView)
        mapView.isHidden = true
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        // Add map marker
        
        self.bump.position = CLLocationCoordinate2DMake(feed.lat, feed.long)
        self.bump.icon = UIImage(named: "marker-img")
        self.bump.title = feed.location
        self.latField.text = "\(feed.lat)"
        self.longField.text = "\(feed.long)"
        
        print("****THE INFO THAT SHOULD BE SHOWING IS-->> \(feed.lat), \(feed.long), \(feed.location)")
        
    }
    
    // Functions
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let camera = GMSCameraPosition.camera(withLatitude: feed.lat,
                                              longitude: feed.long,
                                              zoom: self.zoomLevel)
        
        if self.mapView.isHidden {
            self.mapView.isHidden = false
            self.mapView.camera = camera
        } else {
            self.mapView.animate(to: camera)
        }
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            print("Fatal error")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }

}
