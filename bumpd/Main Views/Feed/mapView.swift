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
    
    // Outlets
    
    @IBOutlet weak var longField: UILabel!
    @IBOutlet weak var latField: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mainSetup()
    }
    
    // Setup
    
    func mainSetup() {
        setupLocationManager()
        setupMapView()
    }

    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        placesClient = GMSPlacesClient.shared()
    }

    func setupMapView() {
        let lat = feed.lat
        let long = feed.long
        
        let camera = GMSCameraPosition.camera(withLatitude: lat,
                                              longitude: long,
                                              zoom: zoomLevel)
        
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setMinZoom(4, maxZoom: mapView.maxZoom)
        mapView.isHidden = true
        
        // Set the map style
        setMapStyle()
        
        // Add map marker
        addMapMarker(lat: lat, long: long)
        
        self.latField.text = "\(lat)"
        self.longField.text = "\(long)"
    }

    func setMapStyle() {
        guard let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") else {
            NSLog("Unable to find style.json")
            return
        }
        
        do {
            mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }

    func addMapMarker(lat: Double, long: Double) {
        let position = CLLocationCoordinate2DMake(lat, long)
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "marker-img")
        marker.map = mapView
    }
    
    // Functions
    func handleMapLocation(locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: self.zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    func handleMapAuthStatus(status: CLAuthorizationStatus) {
        var newState: LocationAuthorizationState
        
        switch status {
        case .restricted:
            newState = RestrictedAuthorizationState()
        case .denied:
            newState = DeniedAuthorizationState()
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            newState = NotDeterminedAuthorizationState()
        case .authorizedAlways, .authorizedWhenInUse:
            newState = AuthorizedAuthorizationState()
        @unknown default:
            newState = UnknownAuthorizationState()
        }
        let authorizationHandler = LocationAuthorizationHandler(state: newState)
            authorizationHandler.handleAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        handleMapLocation(locations: locations)
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleMapAuthStatus(status: status)
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }

}
