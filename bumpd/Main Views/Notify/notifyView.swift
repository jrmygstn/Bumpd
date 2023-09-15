//
//  notifyView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 7/27/23.
//

import UIKit
import Firebase

class notifyView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var notifyImg: UIImageView!
    @IBOutlet weak var notifyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let imgTitle = UIImage(named: "Bumped_logo_transparent-03")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
        checkForEmpty()
        
    }
    
    // Functions
    
    func checkForEmpty() {
        
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(uid!)/Notify").observe(.value) { (snapshot) in
            
            if snapshot.exists() {
                
                self.notifyImg.isHidden = true
                self.notifyLabel.isHidden = true
                
            } else {
                
                self.notifyImg.isHidden = false
                self.notifyLabel.isHidden = false
                
            }
            
        }
        
    }

}
