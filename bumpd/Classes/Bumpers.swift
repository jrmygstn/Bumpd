//
//  Bump.swift
//  bumpd
//
//  Created by Jeremy Gaston on 6/7/23.
//

import Foundation
import Firebase

class Bumpers {
    
    var uid: String
    var bumps: Int
    var ref: DatabaseReference!
    var key: String = ""
    
    init(uid: String, bumps: Int) {
        
        self.uid = uid
        self.bumps = bumps
        self.ref = Database.database().reference()
        
    }
    
}
