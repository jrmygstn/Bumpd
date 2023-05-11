//
//  Likes.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/9/23.
//

import Foundation
import Firebase

class Likes {
    
    var uid: String
    var ref: DatabaseReference!
    var key: String = ""
    
    init(uid: String) {
        
        self.uid = uid
        self.ref = Database.database().reference()
        
    }
    
}
