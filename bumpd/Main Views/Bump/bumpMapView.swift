//
//  bumpMapView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 6/29/23.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import CoreLocation

class bumpMapView: UIViewController, GMSMapViewDelegate {
    
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
    
    let hq = CLLocation(latitude: 33.087561, longitude: -96.818984)
    
    // Outlets
    
    @IBOutlet weak var longField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        placesClient = GMSPlacesClient.shared()
        
        //Create a map.
        
        let camera = GMSCameraPosition.camera(withLatitude: hq.coordinate.latitude,
                                              longitude: hq.coordinate.longitude,
                                              zoom: zoomLevel)
        
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
//        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
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
        
    }

}

extension bumpMapView: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)")
        
        let lt: Double = Double(location.coordinate.latitude.formatted()) ?? 0.0
        let lng: Double = Double(location.coordinate.longitude.formatted()) ?? 0.0
        
        let values = ["latitude": lt, "longitude": lng]
        
        ref.updateChildValues(values)
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
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
            print("Error")
        }
    }
    
    // Handle location manager errors.
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
