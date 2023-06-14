//
//  Memories.swift
//  bumpd
//
//  Created by Jeremy Gaston on 6/14/23.
//

import Foundation
import Firebase

class Memories {
    
    var author: String
    var date: String
    var createdAt: Date
    var id: String
    var lat: Double
    var location: String
    var long: Double
    var month: String
    var recipient: String
    var ref: DatabaseReference!
    var key: String = ""
    
    init(author: String, timestamp: Double, date: String, id: String, lat: Double, location: String, long: Double, month: String, recipient: String) {
        
        self.author = author
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        self.date = date
        self.id = id
        self.lat = lat
        self.location = location
        self.long = long
        self.month = month
        self.recipient = recipient
        self.ref = Database.database().reference()
        
    }
    
}
