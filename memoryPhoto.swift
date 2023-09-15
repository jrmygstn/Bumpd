//
//  memoryPhoto.swift
//  
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fetchMemory()
        
    }
    
    // Functions
    
    func fetchMemory() {
        
        let
        
    }

}
