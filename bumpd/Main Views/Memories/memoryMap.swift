//
//  memoryMap.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/14/23.
//

import UIKit
import GoogleMaps
import GooglePlaces

class memoryMap: UIViewController, GMSMapViewDelegate {

    // Variables
    var mapView: GMSMapView!
    var zoomLevel: Float = 17.5
    var memory: Memories!
    
    // Outlets
    @IBOutlet weak var longField: UILabel!
    @IBOutlet weak var latField: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        //Create a map.
        let lat = memory.lat
        let long = memory.long
        let camera = GMSCameraPosition.camera(withLatitude: lat,
                                              longitude: long,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setMinZoom(4, maxZoom: mapView.maxZoom)
        self.view.addSubview(mapView)
        self.view.layoutIfNeeded()
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
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2DMake(lat, long)
            let marker = GMSMarker(position: position)
            self.mapView.camera = camera
            marker.icon = UIImage(named: "marker-img")
            marker.map = self.mapView
            // Animar la cámara para centrarla en el marcador
            self.mapView.animate(to: camera)
        }
        
        self.latField.text = "\(lat)"
        self.longField.text = "\(long)"
    }

}
