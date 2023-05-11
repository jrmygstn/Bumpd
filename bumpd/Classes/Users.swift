//
//  Users.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/9/23.
//

import Foundation
import Firebase

class Users {
    
    var age: String
    var birthday: String
    var email: String
    var gender: String
    var img: String
    var name: String
    var uid: String
    var ref: DatabaseReference!
    var key: String = ""
    
    init(age: String, birthday: String, email: String, gender: String, img: String, name: String, uid: String) {
        
        self.age = age
        self.birthday = birthday
        self.email = email
        self.gender = gender
        self.img = img
        self.name = name
        self.uid = uid
        self.ref = Database.database().reference()
        
    }
    
}
