//
//  memoryPhoto.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/15/23.
//

import UIKit
import Firebase

class memoryPhoto: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var memory: Memories!
    
    // Outlets
    
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fetchImage()
        
    }
    
    // Functions
    
    func fetchImage() {
        
        let id = memory.id
        
        databaseRef.child("Feed/\(id)/Memory").observe(.value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? "https://firebasestorage.googleapis.com/v0/b/bumpd-7f46b.appspot.com/o/profileImage%2Fdefault_profile%402x.png?alt=media&token=973f10a5-4b54-433f-859f-c6657bed5c29"
            
            self.thumbnail.loadImageUsingCacheWithUrlString(urlString: img)
            
        }
        
    }

}
