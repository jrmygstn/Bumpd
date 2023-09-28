//
//  UsersAdapter.swift
//  bumpd
//
//  Created by Alan Olvera on 27/09/23.
//

import Foundation
import Firebase
import CoreLocation

class UsersAdapter {
    func createUsersFrom(snapshots: [DataSnapshot]) -> [Users] {
        return snapshots.compactMap { (child: DataSnapshot) -> Users? in
            // Feed
            let age = child.childSnapshot(forPath: "age").value as? String ?? ""
            let birth = child.childSnapshot(forPath: "birthday").value as? String ?? ""
            let email = child.childSnapshot(forPath: "email").value as? String ?? ""
            let gender = child.childSnapshot(forPath: "gender").value as? String ?? ""
            let img = child.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
            let long = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
            let name = child.childSnapshot(forPath: "name").value as? String ?? ""
            let user = child.childSnapshot(forPath: "uid").value as? String ?? ""
            
            return Users(age: age, birthday: birth, email: email, gender: gender, img: img, latitude: lat, longitude: long, name: name, uid: user)
        }
    }
}
