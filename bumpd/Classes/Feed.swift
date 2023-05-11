//
//  Feed.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/9/23.
//

import Foundation
import Firebase

class Feed {
    
    var author: String
    var createdAt: Date
    var id: String
    var likes: Likes
    var location: String
    var recipient: String
    var ref: DatabaseReference!
    var key: String = ""
    
    init(author: String, timestamp: Double, id: String, likes: Likes, location: String, recipient: String) {
        
        self.author = author
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        self.id = id
        self.likes = likes
        self.location = location
        self.recipient = recipient
        self.ref = Database.database().reference()
        
    }
    
}
