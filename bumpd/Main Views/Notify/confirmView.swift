//
//  confirmView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 8/17/23.
//

import UIKit
import Firebase

class confirmView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var notify: Notify?
    
    // Outlets
    
    @IBOutlet weak var authorImg: CustomizableImageView!
    @IBOutlet weak var recipImg: CustomizableImageView!
    @IBOutlet weak var recipLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupConfirm()
        
    }
    
    // Actions
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
    // Functions
    
    func setupConfirm() {
        
        let user = notify?.author
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(user!)").observeSingleEvent(of: .value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? ""
            let fullname = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            let name = fullname.components(separatedBy: " ")[0]
            
            self.recipImg.loadImageUsingCacheWithUrlString(urlString: img)
            self.recipLabel.text = " You just bumpd with \(name)"
            
        }
        
        databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snapshot) in
            
            let img = snapshot.childSnapshot(forPath: "img").value as? String ?? ""
            
            self.authorImg.loadImageUsingCacheWithUrlString(urlString: img)
        }
        
    }

}
