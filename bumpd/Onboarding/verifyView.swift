//
//  codeView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/2/23.
//

import UIKit
import Firebase

class verifyView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    var countryCode: String!
    var phoneNumber: String!
    
    
    // Outlets
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var codeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let imgTitle = UIImage(named: "Bumpd_brandmark-01")
        navigationItem.titleView = UIImageView(image: imgTitle)
        navigationItem.leftBarButtonItem?.isHidden = true
        
        setupText()
        
    }
    
    // Actions
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        
        guard let code = codeField.text, code != ""
            else {
                let alert = UIAlertController(title: "Forget Something?", message: "Please make a selection.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        if let code = codeField.text {
            VerifyAPI.validateVerificationCode(self.countryCode!, self.phoneNumber!, code) { checked in
                
                if checked.success {
                    let alert = UIAlertController(title: "Verification Successful!", message: "", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

                    let go = self.storyboard?.instantiateViewController(withIdentifier: "mainView")
                    self.present(go!, animated: true, completion: nil)
                    
                } else {
                    
                    let alertVC = UIAlertController(title: "", message: checked.message, preferredStyle: UIAlertController.Style.alert)
                    alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                    
                }
            }
        }
        
    }
    
    // Functions
    
    func setupText() {
        
        let uid = Auth.auth().currentUser?.uid
        
        self.databaseRef.child("Users/\(uid!)").observe(.value) { (snapshot) in
            
            let number = snapshot.childSnapshot(forPath: "phone").value as? String ?? ""
            
            self.textLabel.text = "Enter the code that was sent to \(number)"
            
        }
        
    }


}
