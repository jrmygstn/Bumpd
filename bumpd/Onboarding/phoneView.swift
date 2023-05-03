//
//  phoneView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/2/23.
//

import UIKit
import Firebase
import SinchVerification

class phoneView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var verify: Verification!
    var apKey = "d687f7c3-83c5-441d-8876-8cedd8345f32"
    
    // Outlets
    
    @IBOutlet weak var phoneField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let imgTitle = UIImage(named: "Bumpd_brandmark-01")
        navigationItem.titleView = UIImageView(image: imgTitle)
        navigationItem.leftBarButtonItem?.isHidden = true
        
    }
    
    // Actions
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        
        guard let phone = phoneField.text, phone != ""
            else {
                let alert = UIAlertController(title: "Forget Something?", message: "Please make a selection.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        self.databaseRef.child("Users").observe(.value) { (snapshot) in
            
            let number = snapshot.childSnapshot(forPath: "phone").value as? String ?? ""
            let fullnum = "+1 \(number)"
            
            if phone != number {
                
                let uid = Auth.auth().currentUser?.uid
                let ref = self.databaseRef.child("Users/\(uid!)")
                
                self.verify = SMSVerification(self.apKey, phoneNumber: number)
                self.verify.initiate { (initiationResult, error) in
                    
                    if initiationResult.success == true {
                        
                        let alert = UIAlertController(title: "Verifing...", message: "", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        
                        let userObj = ["phone": phone]

                        ref.updateChildValues(userObj)
                        
                        let go = self.storyboard?.instantiateViewController(withIdentifier: "verifyNav")
                        self.present(go!, animated: true, completion: nil)
                        
                    } else {
                        
                        let alertVC = UIAlertController(title: "", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                        self.present(alertVC, animated: true, completion: nil)
                        
                    }
                    
                }
                
            } else {
                
                let alert = UIAlertController(title: "Oh no!", message: "That phone number is already in use with another account.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }

}
