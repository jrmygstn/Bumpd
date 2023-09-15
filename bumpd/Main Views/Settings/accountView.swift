//
//  accountView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 9/4/23.
//

import UIKit
import Firebase

class accountView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Actions
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
    @IBAction func deleteBtnTapped(_ sender: Any) {
        
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)")
        
        let alert = UIAlertController(title: "Are you sure?", message: "Did you mean to delete your account?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes, Delete!", style: .destructive, handler: { (alert) in
            
            user?.delete { error in
                if error != nil {
                
                    // An error happened.
                    
                } else {
                  
                    ref.removeValue()
                    
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "landingView")
                    self.present(controller!, animated: false, completion: nil)
                  
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
