//
//  Notify.swift
//  trainrpluspro
//
//  Created by Jeremy Gaston on 8/6/22.
//

import Foundation
import Firebase

class Notify {
    
    var approved: Bool
    var createdAt: Date
    var message: String
    var author: String
    var fid: String
    var id: String
    var unread: Bool
    var ref: DatabaseReference!
    var key: String = ""
    
    init(approved: Bool, timestamp: Double, message: String, author: String, fid: String, id: String, unread: Bool) {
        
        self.ref = Database.database().reference()
        self.approved = approved
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        self.message = message
        self.author = author
        self.fid = fid
        self.id = id
        self.unread = unread
        
    }
    
}
