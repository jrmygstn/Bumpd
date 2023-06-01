//
//  likeCVC.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/26/23.
//

import UIKit
import Firebase

class likeCVC: UICollectionViewCell {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var thumbnail: CustomizableImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnail.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    // Functions
    
    func configureLikes(lk: Likes){
        
        let uid = lk.uid
        
        databaseRef.child("Users/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImg%2Fprofile-img%402x.png?alt=media&token=22b312c9-65e0-4463-a126-21ee2fdcdd61"
            
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
            
        }
        
    }
    
}
