//
//  Settings.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/27/23.
//

import Foundation
import Firebase

class Settings {
    
    var friends: String
    var personal: String
    var world: String
    var friendsLoc: String
    var personalLoc: String
    var worldLoc: String
    var ref: DatabaseReference!
    var key: String = ""
    
    init(friends: String, personal: String, world: String, friendsLoc: String, personalLoc: String, worldLoc: String) {
        
        self.friends = friends
        self.personal = personal
        self.world = world
        self.friendsLoc = friendsLoc
        self.personalLoc = personalLoc
        self.worldLoc = worldLoc
        self.ref = Database.database().reference()
        
    }
    
}
