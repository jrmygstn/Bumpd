//
//  signupView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 4/25/23.
//

import UIKit
import Firebase

class signupView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    // Outlets
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var matchPwdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let imgTitle = UIImage(named: "Bumpd_brandmark-01")
        navigationItem.titleView = UIImageView(image: imgTitle)
        
    }
    
    // Actions
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "unwindToLanding", sender: nil)
        
    }
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        
        guard let name = nameField.text, name != "", let email = emailField.text?.replacingOccurrences(of: " ", with: ""), email != "", let password = passwordField.text, password != ""
            else {
                let alert = UIAlertController(title: "Forget Something?", message: "Please fill out all fields.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }

        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
            if (error != nil) {
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            guard let user = user else { return }

            let userObj = ["uid": user.user.uid , "email": email, "name": name]

            self.databaseRef.child("Users").child(user.user.uid).setValue(userObj)

            print("HERE'S YOUR NAME & EMAIL ADDRESS -->> \(name) \(email)")

        }

        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()

        changeRequest?.displayName = name

        changeRequest?.commitChanges { error in

            print("********Your change request was not completed!")

        }
        
        let go = self.storyboard?.instantiateViewController(withIdentifier: "identityNav")
        self.present(go!, animated: true, completion: nil)
        
    }

}
