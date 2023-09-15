//
//  Feed.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/9/23.
//

import Foundation
import Firebase

class Feed {
    
    var approved: Bool
    var authId: String
    var author: String
    var bumpId: String
    var createdAt: Date
    var id: String
    var lat: Double
    var likes: Likes
    var location: String
    var long: Double
    var recipId: String
    var recipient: String
    var ref: DatabaseReference!
    var key: String = ""
    
    init(approved: Bool, authId: String, author: String, bumpId: String, timestamp: Double, id: String, lat: Double, likes: Likes, location: String, long: Double, recipId: String, recipient: String) {
        
        self.approved = approved
        self.authId = authId
        self.author = author
        self.bumpId = bumpId
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        self.id = id
        self.lat = lat
        self.likes = likes
        self.location = location
        self.long = long
        self.recipId = recipId
        self.recipient = recipient
        self.ref = Database.database().reference()
        
    }
    
}
