//
//  moreCVC.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/26/23.
//

import UIKit
import Firebase

class moreCVC: UICollectionViewCell {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var countLabel: UILabel!
    
    // Functions
    
}
