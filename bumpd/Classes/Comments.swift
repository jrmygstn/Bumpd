//
//  Comments.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/13/23.
//

import Foundation
import Firebase

class Comments {
    
    var author: String
    var createdAt: Date
    var id: String
    var text: String
    var ref: DatabaseReference!
    var key: String = ""
    
    init(author: String, timestamp: Double, id: String, text: String) {
        
        self.author = author
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        self.id = id
        self.text = text
        self.ref = Database.database().reference()
        
    }
    
}
