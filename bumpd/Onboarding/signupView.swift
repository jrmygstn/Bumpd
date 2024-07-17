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
    
    @IBAction func termBtnTapped(_ sender: Any) {
        
        let go = self.storyboard?.instantiateViewController(withIdentifier: "termsNav")
        self.present(go!, animated: true, completion: nil)
        
    }
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        
        guard let email = emailField.text?.trim, email != "",
              let password = passwordField.text?.trim, password != "",
              let matchPwd = matchPwdField.text?.trim, matchPwd != ""
        else {
                let alert = UIAlertController(title: "Forget Something?", message: "Please fill out all fields.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        if password == matchPwd {
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if (error != nil) {
                    let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard let user = user else { return }

                let userObj = ["uid": user.user.uid , "email": email]

                self.databaseRef.child("Users").child(user.user.uid).setValue(userObj)

                self.checkIfProfileComplete()
                
                //let go = self.storyboard?.instantiateViewController(withIdentifier: "usernameNav")
                //self.present(go!, animated: true, completion: nil)
            }
        } else if password != matchPwd {
            
            let alert = UIAlertController(title: "Uh oh!", message: "The passwords don't seem to match.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
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
