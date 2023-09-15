//
//  usernameView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 9/1/23.
//

import UIKit
import Firebase

class usernameView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var usernameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let imgTitle = UIImage(named: "Bumpd_brandmark-01")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
    }
    
    // Actions
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        
        guard let uname = usernameField.text, uname != ""
            else {
                let alert = UIAlertController(title: "Forget Something?", message: "Please fill out all fields.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        let uid = Auth.auth().currentUser?.uid

        let value = ["username": uname]

        self.databaseRef.child("Users/\(uid!)").updateChildValues(value)

        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()

        changeRequest?.displayName = uname

        changeRequest?.commitChanges { error in

            print("********Your change request was not completed!")

        }
        
        checkIfProfileComplete()
        
    }
    
    // Functions
    
    func checkIfProfileComplete() {
        
        let uid = Auth.auth().currentUser?.uid

        databaseRef.child("Users/\(uid!)").observeSingleEvent(of: .value) { (snap) in
            
            let image = snap.childSnapshot(forPath: "img").value as? String ?? ""
            let name = snap.childSnapshot(forPath: "name").value as? String ?? ""
            let birth = snap.childSnapshot(forPath: "birthday").value as? String ?? ""
            
            if image != "" && name != "" && birth != "" {
                
                let go = self.storyboard?.instantiateViewController(withIdentifier: "mainView")
                self.present(go!, animated: true, completion: nil)
                
            } else if image != "" && name != "" && birth == "" {
                
                let go = self.storyboard?.instantiateViewController(withIdentifier: "birthdayNav")
                self.present(go!, animated: true, completion: nil)
                
            } else if image == "" || name == "" {
                
                let go = self.storyboard?.instantiateViewController(withIdentifier: "picNav")
                self.present(go!, animated: true, completion: nil)
                
            }
            
        }
        
    }

}
