//
//  ConciergeView.swift
//  bumpd
//
//  Created by Jeremy Gaston on 5/23/23.
//

import UIKit
import Firebase

class ConciergeView: UIViewController {
    
    // Variables
    
    var databaseRef: DatabaseReference! {
        
        return Database.database().reference()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkIfLoggedIn()
        
    }
    
    // Actions
    
    @IBAction func signupBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "toLanding", sender: nil)
        
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "toLogin", sender: nil)
        
    }
    
    // Functions
    
    func checkIfLoggedIn() {
        
        if Auth.auth().currentUser != nil {
            
            print("USER WAS ALREADY LOGGED IN!!!")
            
            self.checkAccountComplete()
            
        }
        
    }
    
    func checkAccountComplete() {
        
        let user = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(user!)").observe(.value, with: { snapshot in
            
            let gender = snapshot.childSnapshot(forPath: "gender").value as? String ?? ""
            
            if gender != "" {
                
                self.checkBirthdayComplete()
                
            } else {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "identityNav")
                self.present(vc!, animated: false, completion: nil)
                
            }
            
        })
        
    }
    
    func checkBirthdayComplete() {
        
        let user = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(user!)").observe(.value, with: { snapshot in
            
            let bday = snapshot.childSnapshot(forPath: "birthday").value as? String ?? ""
            
            if bday != "" {
                
                self.checkPhoneComplete()
                
            } else if bday == "" {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "birthdayNav")
                self.present(vc!, animated: false, completion: nil)
                
            }
            
        })
        
    }
    
    func checkPhoneComplete() {
        
        let user = Auth.auth().currentUser?.uid
        
        databaseRef.child("Users/\(user!)").observe(.value, with: { snapshot in
            
            let phone = snapshot.childSnapshot(forPath: "phone").value as? String ?? ""
            
            if phone != "" {
                
                self.setVersionNumber()
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainView")
                self.present(vc!, animated: false, completion: nil)
                
            } else if phone == "" {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "phoneNav")
                self.present(vc!, animated: false, completion: nil)
                
            }
            
        })
        
    }
    
    func setVersionNumber() {
        
        let uid = Auth.auth().currentUser?.uid
        let ref = databaseRef.child("Users/\(uid!)")
        
        let value = ["version": "1.0"]
        ref.updateChildValues(value)
        
    }

}
