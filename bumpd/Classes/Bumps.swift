//
//  Bumps.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/9/23.
//

import Foundation
import Firebase

class Bumps {
    
    var author: String
    var createdAt: Date
    var id: String
    var location: String
    var latitude: Double
    var longitude: Double
    var recipient: String
    var ref: DatabaseReference!
    var key: String = ""
    
    init(author: String, timestamp: Double, id: String, location: String, latitude: Double, longitude: Double, recipient: String) {
        
        self.author = author
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        self.id = id
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.recipient = recipient
        self.ref = Database.database().reference()
        
    }
    
}
