//
//  phoneView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/2/23.
//

import UIKit
import Firebase

class phoneView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    
    
    // Outlets
    
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var phoneField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let imgTitle = UIImage(named: "Bumpd_brandmark-01")
        navigationItem.titleView = UIImageView(image: imgTitle)
        if #available(iOS 16.0, *) {
            navigationItem.leftBarButtonItem?.isHidden = true
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    // Actions
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        
        guard let phone = phoneField.text, phone != "", let country = countryField.text, country != ""
            else {
                let alert = UIAlertController(title: "Forget Something?", message: "Please make a selection.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        print("YOUR PHONE NUMBER IS -->> \(country) \(phone)")
        
        self.databaseRef.child("Users").observe(.value) { (snapshot) in
            
            let number = snapshot.childSnapshot(forPath: "phone").value as? String ?? ""
            
            if phone != number {
                
                let uid = Auth.auth().currentUser?.uid
                let ref = self.databaseRef.child("Users/\(uid!)")
                
                let alert = UIAlertController(title: "Verifing...", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

                let userObj = ["phone": phone]

//                ref.updateChildValues(userObj)
                
                if let phoneNumber = self.phoneField.text, let countryCode = self.countryField.text {
                    
                    VerifyAPI.sendVerificationCode(countryCode, phoneNumber)
                    
//                    let go = self.storyboard?.instantiateViewController(withIdentifier: "verifyNav") as! verifyNav
//                    go.phoneNumber = self.phoneField.text!
//                    go.countryCode = self.countryField.text!
//                    self.present(go, animated: true, completion: nil)
                    
                }
                
            } else {
                
                let alert = UIAlertController(title: "Oh no!", message: "That phone number is already in use with another account.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }

}
