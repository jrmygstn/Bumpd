//
//  memoryTopCVC.swift
//  bumpd
//
//  Created by Jeremy Gaston on 9/4/23.
//

import UIKit
import Firebase

class memoryTopCVC: UICollectionViewCell {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var authorImg: CustomizableImageView!
    @IBOutlet weak var metaData: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.authorImg.image = nil
        self.metaData.text = nil
        
    }
    
    func setupCell(bums: Bumpers) {
        
        let uid = bums.uid
        
        databaseRef.child("Users/\(uid)").observe(.value) { (snapshot) in
            
            let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let name = fullname.components(separatedBy: " ")[0]
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            
            self.metaData.text = "\(name)\n\(bums.bumps)"
            self.authorImg.loadImageUsingCacheWithUrlString(urlString: img)
            
        }
        
    }
    
}
